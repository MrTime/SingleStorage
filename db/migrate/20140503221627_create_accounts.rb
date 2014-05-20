class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.string :login
      t.string :adapter_type
      t.text :data
      t.references :user

      t.timestamps
    end
  end
end
