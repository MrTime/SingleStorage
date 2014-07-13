class FolderItem < Item
  has_many :children, class_name: 'Item', foreign_key: 'parent_item_id'

  after_create :fetch_files

  def children
    self.account.fetch_directory(self.path, self) if super.empty?
    super
  end

  def fetch_files
    Resque.enqueue(AccountFilesFetcher, self.account_id, self.id, self.path)
  end
end
