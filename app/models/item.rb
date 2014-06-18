class Item < ActiveRecord::Base
  attr_accessor :content
  enum file_type: [:file, :directory]
  belongs_to :account

  validates :account, presence: true

  def content=(file)
    self.account.upload_to(file, self)
  end
end
