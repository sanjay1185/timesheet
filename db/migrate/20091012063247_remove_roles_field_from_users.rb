class RemoveRolesFieldFromUsers < ActiveRecord::Migration
  def self.up
    remove_column :users, :roles
  end

  def self.down
    add_column :users, :roles, :string
  end
end
