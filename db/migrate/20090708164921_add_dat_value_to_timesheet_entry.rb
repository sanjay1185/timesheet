class AddDatValueToTimesheetEntry < ActiveRecord::Migration
  def self.up
    add_column :timesheet_entries, :dayValue, :decimal, :precision => 8, :scale => 2
  end

  def self.down
    remove_column :timesheet_entries, :dayValue
  end
end
