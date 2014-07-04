class Item < ActiveRecord::Base
  extend FriendlyId

  attr_accessor :name, :dirname, :accounts
  enum file_type: [:file, :directory]
  serialize :data, Hash
  serialize :chunks, Array
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

  def dirname
    File.dirname(self.path)
  end

  def accounts=(accounts)
    self.account = accounts.sample
  end

  def upload_complete?
    self.chunks.inject(0) {|size,c| size + c.size } == self.file_size - 1
  end

  def write_content(file, range)
    raise "Path is empty" if self.path.blank?
    raise "Account is empty" if self.path.blank?

    data[:upload_session] ||= {}

    add_chunk(self.account.upload_to(path, file, range, data[:upload_session]))

    finish_upload if upload_complete?
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

  protected

  def add_chunk new_chunk
    if self.chunks.nil?
      self.chunks = [new_chunk]
    else
      if prev_chunk = self.chunks.find {|c| c.ends == new_chunk.begins - 1 }
        prev_chunk.add_chunk new_chunk
      else
        self.chunks << new_chunk
      end
    end
  end

  def finish_upload
    self.account.finish_upload(data[:upload_session])
  end
end
