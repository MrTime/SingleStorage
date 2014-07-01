class RenameItemsNameField < ActiveRecord::Migration
  def change
    rename_column :items, :name, :path
  end
end
