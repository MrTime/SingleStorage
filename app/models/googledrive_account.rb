require 'google/api_client'

class GoogledriveAccount < Account
  store :data, accessors: [:access_token, :refresh_token, :expires_in, :issued_at],  coder: JSON

  before_create :extract_google_drive_account

  def extract_google_drive_account
    account_info = user_info
    about_info = about 
    self.login = account_info.email
    self.total_size = about_info['quotaBytesTotal'].to_i
    self.available_size = about_info['quotaBytesTotal'].to_i - about_info['quotaBytesUsed'].to_i
  end

  def fetch_files
    fetch_directory('root')
  end

  def fetch_directory(path, parent = nil)
    path = parent.data[:id] if parent

    files = files_list(path)
    Item.transaction do
      files.each do |f| 
        item = items.new(file_attributes(f))
        item.path = file_path(f, parent) 
        item.parent_item_id = parent.id if parent
        item.save
      end
    end
  end

  def upload_to(file, item)
    drive = api_client.discovered_api('drive', 'v2')
    gfile = drive.files.insert.request_schema.new({
      'title' => file.original_filename,
      'mimeType' => file.content_type
    })

    media = Google::APIClient::UploadIO.new(file.path, file.content_type)
    result = api_client.execute(
      :api_method => drive.files.insert,
      :body_object => gfile,
      :media => media,
      :parameters => {
      'uploadType' => 'multipart',
      'alt' => 'json'})

      item.update_attributes(file_attributes(result.data))
  end

  def download_url(item) 
    url = ''
    drive = api_client.discovered_api('drive', 'v2')
    parameters = {}
    parameters['fileId'] = item.data[:id]
    parameters['fields'] = 'id,title,downloadUrl'
    result = api_client.execute(
      :api_method => drive.files.get,
      :parameters => parameters)
    if result.status == 200
      metadata = result.data
      url = metadata.download_url
    else
      logger.error "An error occurred: #{result.data['error']['message']}"
    end

    logger.debug "info: #{metadata.inspect}"
    url
  end

  def preview_url(item) 
    file_info(item)['alternateLink']
  end

  def file_attributes(f)
    if f['mimeType'] == 'application/vnd.google-apps.folder'
      type = :directory
      mimetype = nil
    else
      type = :file
      mimetype = f['mimeType']
    end

    {
      file_size: f['file_size'],
      file_type: type,
      mime_type: mimetype,
      data: {
        id: f['id']
      }
    }
  end

  def user_info
    oauth2 = api_client.discovered_api('oauth2', 'v2')
    result = api_client.execute!(:api_method => oauth2.userinfo.get)
    user_info = nil

    if result.status == 200
      user_info = result.data
    else
      logger.error "An error occurred: #{result.data['error']['message']}"
      self.errors.add :base, :unable_retrieve
    end
    if user_info != nil && user_info.id != nil
      return user_info
    end
    self.errors.add :base, :unable_retrieve
  end

  def api_client
    if @client.nil?
      @client = Google::APIClient.new
      @client.authorization.client_id = Rails.application.secrets.googledrive['client_id']
      @client.authorization.client_secret = Rails.application.secrets.googledrive['client_secret']
      @client.authorization.scope = ['https://www.googleapis.com/auth/drive',
                                     'https://www.googleapis.com/auth/userinfo']
      @client.authorization.update_token!(access_token: self.access_token,
                            refresh_token: self.refresh_token,
                            expires_in: self.expires_in.to_i,
                            issued_at: self.issued_at)
    end

    update_tokens(@client)

    @client
  end

  private

  def update_tokens(client)
    auth = client.authorization
    return unless auth.expired?

    auth.fetch_access_token!
    self.update_attributes(access_token: auth.access_token,
                           refresh_token: auth.refresh_token,
                           expires_in: auth.expires_in.to_i,
                           issued_at: auth.issued_at)
  end

  def about
    drive = api_client.discovered_api('drive', 'v2')
    result = api_client.execute(api_method: drive.about.get)

    if result.status == 200
      about = result.data
    else
      logger.error "An error occurred: #{result.data['error']['message']}"
    end

    about
  end

  def files_list id
    drive = api_client.discovered_api('drive', 'v2')
    list = []
    page_token = nil

    begin
      parameters = {}
      parameters['q'] = "'#{id}' in parents"
      if page_token.to_s != ''
        parameters['pageToken'] = page_token
      end

      result = api_client.execute(
        :api_method => drive.files.list,
        :parameters => parameters)

        if result.status == 200
          files = result.data
          files.items.each do |f|
            list << f
          end
          page_token = files.next_page_token
        else
          logger.error "An error occurred: #{result.data['error']['message']}"
          page_token = nil
        end
    end while page_token.to_s != ''

    list
  end

  def file_path item, parent = nil
    path = ""
    path << parent.path if parent
    path << "/#{item['title']}"
    path
  end

  def file_info item
    drive = api_client.discovered_api('drive', 'v2')

    parameters = {}
    parameters['fileId'] = item.data[:id]
    result = api_client.execute(api_method: drive.files.get, parameters: parameters)

    if result.status == 200
      info = result.data
    else
      logger.error "An error occurred: #{result.data['error']['message']}"
    end

    puts info

    info
  end

end
