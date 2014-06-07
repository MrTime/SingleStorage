require 'dropbox_sdk'

class DropboxAccount < Account
  store :data, accessors: [:access_token],  coder: JSON

  before_create :extract_dropbox_account

  def extract_dropbox_account
    account_info = dropbox_client.account_info
    logger.debug account_info.inspect
    self.login = account_info['display_name']
    self.total_size = account_info['quota_info']['quota']
  end

  def dropbox_client
    @client ||= DropboxClient.new(access_token) if access_token
  end
end
