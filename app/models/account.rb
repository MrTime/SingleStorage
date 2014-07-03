class Account < ActiveRecord::Base
  belongs_to :user
  has_many :items

  after_create :fetch_files

  scope :with_available_bytes, -> (size) { where("available_size >= ?", size) }

  def upload_to
    raise NotImplementedError
  end

  def fetch_directory(path, parent = nil)
    raise NotImplementedError
  end

  def fetch_files
    raise NotImplementedError
  end

  def preview_url(item) 
    raise NotImplementedError
  end
end
