require 'google/api_client'

class GoogledriveAccount < Account
  store :data, accessors: [:access_token, :refresh_token, :expires_in, :issued_at],  coder: JSON

  before_create :extract_google_drive_account
  after_create :fetch_files

  def extract_google_drive_account
    account_info = user_info
    self.login = account_info.email
    self.total_size = 9 * 10**9
  end

  def fetch_files
    drive = api_client.discovered_api('drive', 'v2')
    page_token = nil
    begin
      parameters = {}
      if page_token.to_s != ''
        parameters['pageToken'] = page_token
      end
      result = api_client.execute(
        :api_method => drive.files.list,
        :parameters => parameters)
        if result.status == 200
          files = result.data
          files.items.each do |f|
            items.create!(file_attributes(f))
          end
          page_token = files.next_page_token
        else
          logger.error "An error occurred: #{result.data['error']['message']}"
          page_token = nil
        end
    end while page_token.to_s != ''
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
  end

  def file_attributes(f)
    logger.debug f.inspect
    { name: f['originalFilename'] }
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
    return @client unless @client.nil?
    @client = Google::APIClient.new
    @client.authorization.client_id = Rails.application.secrets.googledrive['client_id']
    @client.authorization.client_secret = Rails.application.secrets.googledrive['client_secret']
    @client.authorization.scope = ['https://www.googleapis.com/auth/drive',
                                   'https://www.googleapis.com/auth/userinfo']
    @client.authorization.update_token!(access_token: self.access_token,
                          refresh_token: self.refresh_token,
                          expires_in: self.expires_in,
                          issued_at: self.issued_at)
    @client
  end

end
