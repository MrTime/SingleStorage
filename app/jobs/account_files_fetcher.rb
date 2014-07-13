class AccountFilesFetcher
  @queue = :account_files

  def self.perform account_id, parent_item_id, path
    parent_item = Item.where(id: parent_item_id).first
    Account.find(account_id).fetch_directory path, parent_item
  end
end
