class AddTimesToTimesheet < ActiveRecord::Migration
  def self.up
    add_column :timesheets, :submittedDateTime, :datetime
    add_column :timesheets, :deniedDateTime, :datetime
    add_column :timesheets, :deniedBy, :string, :limit => 75
  end

  def self.down
    remove_column :timesheets, :submittedDateTime
    remove_column :timesheets, :deniedDateTime
    remove_column :timesheets, :deniedBy
  end
end
