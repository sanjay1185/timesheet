class RemoveContractorFromTimesheet < ActiveRecord::Migration
  def self.up
    remove_column :timesheets, :contractor_id
  end

  def self.down
  end
end
