class AddOptionsToContract < ActiveRecord::Migration
  def self.up
    add_column :contracts, :allowOvertime, :boolean, :null => false, :default => false
    add_column :contracts, :allowBankHolidays, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :contracts, :allowOvertime
    remove_column :contracts, :allowBankHolidays
  end
end
