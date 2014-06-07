class AddTotalSizeToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :total_size, :bigint
  end
end
