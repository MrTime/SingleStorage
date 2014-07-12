class AccountFilesFetcher
  @queue = :account_files

  def self.perform id
    Account.find(id).fetch_files
  end
end
