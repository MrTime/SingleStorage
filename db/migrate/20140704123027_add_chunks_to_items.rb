class AddChunksToItems < ActiveRecord::Migration
  def change
    add_column :items, :chunks, :text
  end
end
