class FileItem < Item
  serialize :chunks, Array

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

  def uploaded_size
    Chunk
    (chunks.inject(0) {|sum, c| sum + c.size }) + 1
  end

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

  protected

  def finish_upload
    self.account.finish_upload(data[:upload_session])
  end
end
