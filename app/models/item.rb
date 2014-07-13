class Item < ActiveRecord::Base
  extend FriendlyId

  after_destroy :clean_account
  
  attr_accessor :name, :dirname, :accounts, :icon
  serialize :data, Hash
  friendly_id :path, use: :slugged

  belongs_to :account
  belongs_to :parent, class_name: 'Item', foreign_key: 'parent_item_id'

  validates :account, presence: true
  validates :path, uniqueness: { scope: :account_id }

  scope :root, -> { where(parent_item_id: nil) } 
  scope :files, -> { order('type desc, path asc') } 
  scope :by_path, -> (path) { where(path: path) }

  def clean_account
    self.account.remove_file(self)
  end

  def name
    File.basename(self.path)
  end

  def dirname
    File.dirname(self.path)
  end

  def icon
    self.data[:icon]
  end

  def icon=(n)
    self.data[:icon] = n
  end

  def accounts=(accounts)
    self.account = accounts.sample
  end
end
