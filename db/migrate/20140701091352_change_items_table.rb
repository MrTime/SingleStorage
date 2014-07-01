class ChangeItemsTable < ActiveRecord::Migration
  def change
    rename_column :items, :parent_file_id, :parent_item_id
  end
end
