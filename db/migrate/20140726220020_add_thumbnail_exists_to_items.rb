class AddThumbnailExistsToItems < ActiveRecord::Migration
  def change
    add_column :items, :thumbnail_exists, :boolean, default: false
  end
end
