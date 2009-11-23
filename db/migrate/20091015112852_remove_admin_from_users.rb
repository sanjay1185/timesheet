class RemoveAdminFromUsers < ActiveRecord::Migration
  def self.up
    remove_column :users, :admin
  end

  def self.down
  end
end
