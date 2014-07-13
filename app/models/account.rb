class Account < ActiveRecord::Base
  belongs_to :user
  has_many :items, dependent: :delete_all

  validates :login, uniqueness: {scope: :type}

  after_create :queue_fetch_files

  scope :with_available_bytes, -> (size) { where("available_size >= ?", size) }

  def queue_fetch_files
    Resque.enqueue(AccountFilesFetcher, self.id, nil, '/')
  end

  def upload_to(path, file, range, session)
    Chunk.new(range, self)
  end

  def remove_file(item)
    raise NotImplementedError
  end

  def fetch_info
    raise NotImplementedError
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
