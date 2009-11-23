class TimesheetAutomator
  
  #----------------------------------------------------------------------------
  # create draft timesheets for each user with an active contract
  #----------------------------------------------------------------------------
  def self.create_next_timesheets
    
    users = User.find(:all, :conditions => ["active = ?", true])
    
    for user in users
      
      user.create_draft_timesheets
      
    end
    
  end
  
end