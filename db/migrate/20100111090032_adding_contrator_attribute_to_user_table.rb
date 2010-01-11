class AddingContratorAttributeToUserTable < ActiveRecord::Migration
  def self.up
    add_column :users,:companyName,:string
    add_column :users,:vatNumber,:string
    add_column :users,:companyNumber,:string
    add_column :users,:contract_id,:integer
  end

  def self.down
    remove_column :users,:companyName
    remove_column :users,:vatNumber
    remove_column :users,:companyNumber
    remove_column :users,:contract_id
  end
end
