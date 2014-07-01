class Item < ActiveRecord::Base
  extend FriendlyId

  attr_accessor :content, :name
  enum file_type: [:file, :directory]
  serialize :data, Hash
  friendly_id :path, use: :slugged

  belongs_to :account
  has_many :children, class_name: 'Item', foreign_key: 'parent_item_id'
  belongs_to :parent, class_name: 'Item'

  validates :account, presence: true

  scope :root, -> { where(parent_item_id: nil) } 

  def name
    File.basename(self.path)
  end

  def content=(file)
    self.account.upload_to(file, self)
  end

  def download_url
    self.account.download_url(self)
  end

  def preview_url
    self.account.preview_url(self)
  end

  def return_item
    it = self.clone
    it.name = '..'
    it
  end
end
