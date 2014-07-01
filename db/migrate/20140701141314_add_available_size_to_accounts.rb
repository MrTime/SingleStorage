class AddAvailableSizeToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :available_size, :bigint
  end
end
