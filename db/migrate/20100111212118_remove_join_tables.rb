class RemoveJoinTables < ActiveRecord::Migration
  def self.up
    drop_table :clients_users
    drop_table :contracts_users
  end

  def self.down
    
    create_table "clients_users", :id => false, :force => true do |t|
      t.integer "client_id", :null => false
      t.integer "user_id",   :null => false
    end
  
    add_index "clients_users", ["client_id", "user_id"], :name => "index_clients_users_on_client_id_and_user_id", :unique => true

    create_table "contracts_users", :id => false, :force => true do |t|
      t.integer "contract_id",                    :null => false
      t.integer "user_id",                        :null => false
      t.boolean "isDefault",   :default => false, :null => false
    end
  
    add_index "contracts_users", ["contract_id", "user_id"], :name => "index_contracts_users_on_contract_id_and_user_id", :unique => true

  end
end
