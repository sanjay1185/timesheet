class AddRateTypeToTimesheets < ActiveRecord::Migration
  def self.up
    add_column :timesheets, :rateType, :string, :limit => 10, :null => false, :default => 'Hour'
    add_column :timesheet_entries, :rateType, :string, :limit => 10, :null => false, :default => 'Hour'
  end

  def self.down
    remove_column :timesheets, :rateType
    remove_column :timesheet_entries, :rateType
  end
end
