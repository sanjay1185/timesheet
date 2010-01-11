class AddUserIdToContract < ActiveRecord::Migration
  def self.up
    add_column :contracts, :contractor_user_id, :integer
  end

  def self.down
    remove_column :contracts, :contractor_user_id
  end
end
