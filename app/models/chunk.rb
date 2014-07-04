class Chunk
  attr_accessor :begins, :ends, :account

  def initialize(range, account)
    @begins = range.begin
    @ends = range.end
    @account = account.id
  end

  def add_chunk c
    if c.begins == self.ends+1
      self.ends = c.ends
    end
  end

  def size
    @ends - @begins
  end

  def inspect
    "#{@begins}..#{@ends}: #{@account}"
  end
end
