require 'dropbox_sdk'

class DropboxAccount < Account
  store :data, accessors: [:access_token],  coder: JSON

  before_create :extract_dropbox_account
  after_create :fetch_files

  def extract_dropbox_account
    account_info = dropbox_client.account_info
    self.login = account_info['display_name']
    quota = account_info['quota_info']
    self.total_size = quota['quota'].to_i
    self.available_size = quota['quota'].to_i - quota['normal'].to_i - quota['shared'].to_i
  end

  def dropbox_client
    @client ||= DropboxClient.new(access_token) if access_token
  end

  def fetch_files
    fetch_directory('/')
  end
  
  def fetch_directory(path, parent = nil)
    folders = []

    Item.transaction do
      files = dropbox_client.metadata(path)['contents']
      files.each do |f|
        item = items.new(file_attributes(f))
        item.parent_item_id = parent.id if parent
        item.save!

        folders << item if item.directory?
      end
    end

    #folders.each do |f|
    #  fetch_directory(f.name, f)
    #end
  end

  def upload_to(file, item)
    begin
      # Upload the POST'd file to Dropbox, keeping the same name
      resp = dropbox_client.put_file(file.original_filename, file.read)

      item.update_attributes(file_attributes(resp))

    rescue DropboxAuthError => e
      item.errors.add(:base, "Dropbox auth error: #{e}")
      logger.info "Dropbox auth error: #{e}"
    rescue DropboxError => e
      item.errors.add(:base, "Dropbox API error: #{e}")
      logger.info "Dropbox API error: #{e}"
    end
  end

  def download_url(item) 
    begin
      dropbox_client.media(item.name)['url']

    rescue DropboxAuthError => e
      logger.info "Dropbox auth error: #{e}"
      nil
    rescue DropboxError => e
      logger.info "Dropbox API error: #{e}"
      nil
    end
  end

  def preview_url(item) 
    begin
      dropbox_client.media(item.path)['url']

    rescue DropboxAuthError => e
      logger.info "Dropbox auth error: #{e}"
      nil
    rescue DropboxError => e
      logger.info "Dropbox API error: #{e}"
      nil
    end
  end

  def file_attributes(f)
    {
      path: f['path'], 
      file_size: f['size'],
      file_type: f['is_dir'] == true ? :directory : :file,
      mime_type: f['mime_type']
    }
  end
end
