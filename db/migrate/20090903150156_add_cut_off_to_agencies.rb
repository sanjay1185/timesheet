class AddCutOffToAgencies < ActiveRecord::Migration
  def self.up
    add_column :agencies, :autoReminder, :boolean, :null => false, :default => false
    add_column :agencies, :cutOffDay, :integer
    add_column :agencies, :cutOffTime, :time 
  end

  def self.down
    remove_column :agencies, :autoReminder
    remove_column :agencies, :cutOffDay
    remove_column :agencies, :cutOffTime
  end
end
