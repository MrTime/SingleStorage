require 'dropbox_sdk'

class DropboxAccount < Account
  store :data, accessors: [:access_token],  coder: JSON

  before_create :extract_dropbox_account
  after_create :fetch_files

  def extract_dropbox_account
    account_info = dropbox_client.account_info
    self.login = account_info['display_name']
    self.total_size = account_info['quota_info']['quota']
  end

  def dropbox_client
    @client ||= DropboxClient.new(access_token) if access_token
  end

  def fetch_files
    files = dropbox_client.metadata('/')["contents"]

    files.each do |f|
      items.create!(name: f["path"], file_type: f['is_dir'] == true ? :directory : :file)
    end
  end
end
