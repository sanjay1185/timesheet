class TimesheetHistory < ActiveRecord::Base
  
  #############################################################################
  # Relationships
  #############################################################################
  belongs_to :contract
  belongs_to :contractor
  has_many :timesheet_entry_histories, :dependent => :destroy, :order => "dateValue asc, manual"
  
  #----------------------------------------------------------------------------
  # Expose the timesheet_entries as 'entries'
  #----------------------------------------------------------------------------
  def entries
  
    return self.timesheet_entry_histories
  
  end

  def self.get_all_notes(id)
      
    notes = TimesheetHistory.find(:all, :conditions => "original_timesheet_id = #{id} and note is not null", :select => "updated_at, userName, note", :order => "updated_at desc")
    
    return notes.select {|n| !n.note.blank?}
    
  end
  
  #----------------------------------------------------------------------------
  # Update the entries for this historical timesheet
  #----------------------------------------------------------------------------
  def update_entries_history(entries)
  
    for entry in entries do

      teh = TimesheetEntryHistory.new
      teh.dateValue = entry.dateValue
      teh.hours = entry.hours
      teh.disabled = entry.disabled
      teh.created_at = entry.created_at
      teh.updated_at = entry.updated_at
      teh.netAmount = entry.netAmount
      teh.startTime = entry.startTime
      teh.finishTime = entry.finishTime
      teh.breakHours = entry.breakHours
      teh.manual = entry.manual
      teh.chargeRate = entry.chargeRate
      teh.rate_id = entry.rate_id
      teh.rateType = entry.rateType
      teh.dayValue = entry.dayValue
      teh.original_timesheet_id = entry.timesheet_id
      # it seems that new entries are being written to DB somewhere before we get here
      # and we don't want them. so, need to check for null values!
      self.timesheet_entry_histories << teh unless teh.hours.nil? && teh.dayValue.nil?
      
    end
    
  end
  
end