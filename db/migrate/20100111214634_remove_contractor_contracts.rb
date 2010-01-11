class RemoveContractorContracts < ActiveRecord::Migration
  def self.up
    
    drop_table :contractors_contracts
    
  end

  def self.down
    
    create_table "contractors_contracts", :id => false, :force => true do |t|
      t.integer "contractor_id",   :null => false
      t.integer "contract_id",     :null => false
      t.date    "terminationDate"
    end
  
    add_index "contractors_contracts", ["contractor_id", "contract_id"], :name => "index_contractors_contracts_on_contractor_id_and_contract_id", :unique => true


  end
end
