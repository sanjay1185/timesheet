class AddMoreSettingsToAgency < ActiveRecord::Migration
  
  def self.up
    add_column :agencies, :useInvoicing, :boolean, :default => true, :null => false
    add_column :agencies, :calculatePAYE, :boolean, :default => true, :null => false
  end

  def self.down
    remove_column :agencies, :userInvoicing
    remove_column :agencies, :calculatePAYE
  end
  
end
