class Account < ActiveRecord::Base
  belongs_to :user
  has_many :items

  def upload_to
    raise NotImplementedError
  end
end
