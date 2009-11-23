class RemoveColsFromEntries < ActiveRecord::Migration
  def self.up
		remove_column :timesheet_entries, :dayValue
		remove_column :timesheet_entries, :onCall
  end

  def self.down
  end
end
