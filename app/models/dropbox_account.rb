require 'dropbox_sdk'

class DropboxAccount < Account
  store :data, accessors: [:access_token, :uid],  coder: JSON

  def icon
    "dropbox-icon-48.png"
  end

  def fetch_info
    account_info = dropbox_client.account_info
    self.uid = account_info['uid']
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
    #folders = []

    Item.transaction do
      files = dropbox_client.metadata(path)['contents']
      files.each do |f|
        item = if f['is_dir']
                 FolderItem.new(folder_attributes(f))
               else
                 FileItem.new(file_attributes(f))
               end

        item.account = self
        item.parent_item_id = parent.id if parent
        item.add_chunk Chunk.new(0...(item.file_size-1), self) if item.is_a? FileItem
        item.save
      end
    end

    #folders.each do |f|
    #  fetch_directory(f.name, f)
    #end
  end

  def upload_to(path, file, range, session)
    begin
      session[:path] = path
      resp = JSON.parse(dropbox_client.partial_chunked_upload(file.read(range.size), session[:id], range.begin).body)
      logger.debug "upload resp #{resp['upload_id']}"
      if session[:id].nil?
        session[:id] = resp['upload_id']
      end

      super
    rescue DropboxAuthError => e
      item.errors.add(:base, "Dropbox auth error: #{e}")
      logger.info "Dropbox auth error: #{e}"
    rescue DropboxError => e
      item.errors.add(:base, "Dropbox API error: #{e}")
      logger.info "Dropbox API error: #{e}"
    end
  end

  def remove_file(item)
    begin
      dropbox_client.file_delete(item.path)

    rescue DropboxAuthError => e
      logger.info "Dropbox auth error: #{e}"
      nil
    rescue DropboxError => e
      logger.info "Dropbox API error: #{e}"
      nil
    end
  end

  def finish_upload(session)
    begin
      logger.debug "FINISH_UPLOAD"
      resp = dropbox_client.commit_chunked_upload(session[:path], session[:id])
      logger.debug "upload resp #{resp.inspect}"
      session[:id] = nil
      session[:path] = nil

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
      dropbox_client.media(item.path)['url']

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

  protected

  def file_attributes(f)
    {
      path: f['path'], 
      file_size: f['size'],
      mime_type: f['mime_type'],
      icon: f['icon']
    }
  end

  def folder_attributes(f)
    {
      path: f['path'], 
      icon: f['icon']
    }
  end
end
