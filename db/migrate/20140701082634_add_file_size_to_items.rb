class AddFileSizeToItems < ActiveRecord::Migration
  def change
    add_column :items, :file_size, :integer
  end
end
