class Item < ActiveRecord::Base
  enum file_type: [:file, :directory]
  belongs_to :account
end
