class TimesheetEntryHistory < ActiveRecord::Base
  
  #############################################################################
  # Relationships
  #############################################################################
  belongs_to :timesheet_history
  belongs_to :rate
  
end