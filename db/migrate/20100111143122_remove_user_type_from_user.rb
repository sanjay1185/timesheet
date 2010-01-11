class RemoveUserTypeFromUser < ActiveRecord::Migration
  def self.up
    remove_column :users, :userType
  end

  def self.down
  end
end
