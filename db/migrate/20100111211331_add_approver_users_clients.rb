class AddApproverUsersClients < ActiveRecord::Migration
  def self.up
    create_table "approver_users_clients", :id => false, :force => true do |t|
      t.integer "approver_user_id", :null => false
      t.integer "client_id",   :null => false
    end
    create_table "approver_users_contracts", :id => false, :force => true do |t|
      t.integer "approver_user_id", :null => false
      t.integer "contract_id",   :null => false
    end
  end

  def self.down
    drop_table :approver_users_clients
    drop_table :approver_users_contracts
  end
end
