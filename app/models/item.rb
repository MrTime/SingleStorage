class Item < ActiveRecord::Base
  extend FriendlyId

  attr_accessor :name, :accounts
  enum file_type: [:file, :directory]
  serialize :data, Hash
  friendly_id :path, use: :slugged

  belongs_to :account
  has_many :children, class_name: 'Item', foreign_key: 'parent_item_id'
  belongs_to :parent, class_name: 'Item', foreign_key: 'parent_item_id'

  validates :account, presence: true
  validates :path, uniqueness: { scope: :account_id }

  scope :root, -> { where(parent_item_id: nil) } 
  scope :files, -> { order('file_type desc, path asc') } 
  scope :by_path, -> (path) { where(path: path) }

  def name
    File.basename(self.path)
  end

  def accounts=(accounts)
    self.account = accounts.sample
  end

  def write_content(file, starts, ends)
    #self.account.upload_to(file.first, self)
  end

  def download_url
    self.account.download_url(self)
  end

  def preview_url
    #self.account.preview_url(self)
    ""
  end

  def return_item
    it = self.clone
    it.name = '..'
    it
  end

  def children
    if directory? and super.empty?
      self.account.fetch_directory(self.path, self)
    end

    super
  end
end
