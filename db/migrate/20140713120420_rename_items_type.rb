class RenameItemsType < ActiveRecord::Migration
  def change
    rename_column :items, :file_type, :type
    change_column :items, :type, :string
  end
end
