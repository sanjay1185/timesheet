class AddReadOnlyToRolesUsers < ActiveRecord::Migration
  def self.up
    add_column :permissions, :readOnly, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :permissions, :readOnly
  end
end
