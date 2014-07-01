class Account < ActiveRecord::Base
  belongs_to :user
  has_many :items

  def upload_to
    raise NotImplementedError
  end

  def fetch_directory(path, parent = nil)
    raise NotImplementedError
  end

  def fetch_files
    raise NotImplementedError
  end
end
