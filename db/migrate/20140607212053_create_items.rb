class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.string :name
      t.integer :permissions
      t.integer :parent_file_id
      t.integer :account_id, null: false
      t.integer :file_type
      t.string :mime_type

      t.timestamps
    end
  end
end
