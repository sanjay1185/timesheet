class AddRoles < ActiveRecord::Migration
  def self.up
    create_table "roles", :force => true do |t|
      t.string "name", :limit => 30, :null => :false
      t.string "description"
    end
    
    create_table "permissions", :force => true do |t|
      t.integer "role_id", :null => :false
      t.integer "user_id", :null => :false
    end
  end
  
  def self.down
    
  end
end
