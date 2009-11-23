class SetupTimesheetHistory < ActiveRecord::Migration
  def self.up
    
    # remove unused fields from timesheets
    remove_column :timesheets, :period
    remove_column :timesheets, :approverName
    remove_column :timesheets, :approvalDateTime
    remove_column :timesheets, :dayLength
    remove_column :timesheets, :approveCode
    remove_column :timesheets, :submittedDateTime
    remove_column :timesheets, :deniedDateTime
    remove_column :timesheets, :deniedBy
    
    # add userName
    add_column :timesheets, :userName, :string, :limit => 75
    
    # add deleted to entries
    add_column :timesheet_entries, :deleted, :boolean, :null => false, :default => false
    
    # create timesheet_histories table
    create_table "timesheet_histories", :force => true do |t|
      t.date     "startDate",                                                                             :null => false
      t.decimal  "totalDays",                          :precision => 8, :scale => 2
      t.string   "totalHours",           :limit => 6
      t.boolean  "invoiced",                                                         :default => false
      t.string   "status",               :limit => 20,                               :default => "DRAFT", :null => false
      t.string   "userName",             :limit => 75
      t.string   "note"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.datetime "lastExportedDateTime"
      t.float    "netAmount"
      t.float    "taxAmount"
      t.integer  "original_timesheet_id"
    end
    
    add_index "timesheet_histories", ["original_timesheet_id"], :name => "index_timesheet_histories_on_original_timesheet_id"
    
    # create timesheet_entry_histories
    create_table "timesheet_entry_histories", :force => true do |t|
      t.date     "dateValue",                                                                    :null => false
      t.integer  "timesheet_history_id",                                                                 :null => false
      t.string   "hours",        :limit => 5
      t.boolean  "disabled",                                                 :default => false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.float    "netAmount"
      t.string   "startTime",    :limit => 5
      t.string   "finishTime",   :limit => 5
      t.string   "breakHours",   :limit => 5
      t.boolean  "manual",                                                   :default => false,  :null => false
      t.decimal  "chargeRate",                 :precision => 8, :scale => 2
      t.integer  "rate_id"
      t.string   "rateType",     :limit => 10,                               :default => "Hour", :null => false
      t.decimal  "dayValue",                   :precision => 8, :scale => 2
      t.integer  "original_timesheet_id"
    end
    
    add_index "timesheet_entry_histories", ["original_timesheet_id"], :name => "index_timesheet_entry_histories_on_original_timesheet_id"
    
  end
  
  def self.down
  end
end
