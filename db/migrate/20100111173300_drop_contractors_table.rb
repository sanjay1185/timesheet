class DropContractorsTable < ActiveRecord::Migration
  def self.up
    drop_table :contractors
  end

  def self.down
    create_table "contractors", :force => true do |t|
      t.string   "companyName",   :limit => 100
      t.string   "vatNumber",     :limit => 30
      t.string   "companyNumber", :limit => 30
      t.integer  "user_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  
    add_index "contractors", ["companyName"], :name => "index_contractors_on_companyName"
    add_index "contractors", ["user_id"], :name => "index_contractors_on_user_id"
  end
end
