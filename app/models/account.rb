class Account < ActiveRecord::Base
  belongs_to :user
  has_many :items

  after_create :fetch_files

  scope :with_available_bytes, -> (size) { where("available_size >= ?", size) }

  def upload_to(path, file, range, session)
    #raise NotImplementedError
    session[:id] = 1234
    Chunk.new(range, self)
  end

  def finish_upload(session)
    logger.debug "finished #{session[:id]}"
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
