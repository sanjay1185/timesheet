class AlertManager
  
  def self.send_expiry_emails
    
    agencies = Agency.find(:all, :conditions => ['trial = ?', true])

    for agency in agencies
      send_alerts_on = [1, 3, 5, 7]
      days_left = agency.days_left_of_trial
      if send_alerts_on.include?(days_left)
        AgencyMailer.deliver_send_expiry_alert(agency.email, days_left)
      elsif days_left == 0
        AgencyMailer.deliver_send_expired_alert(agency)
        agency.disable_users
      end
    end

    return
  end

  def self.send_automated_reminders
    
    # define periods for sending alerts
    send_alerts_on = [24, 8, 2]
    
    # get agencies that have autoReminder set to true
    agencies = Agency.find(:all, :conditions => ['autoReminder = ?', true])
    
    # get the time for NOW... this same date/time value should be used throughout
    today = Time.now
    
    # set the time without any seconds as we need to do a comparison
    now = DateTime.new(today.year, today.month, today.day, today.hour, today.min)  
    count = 0
    
    for agency in agencies
      
      # set the cut off date and time for this agency. set it to today initially
      cut_off = DateTime.new(today.year, today.month, today.day, agency.cutOffTime.hour, agency.cutOffTime.min)
      
      # if it's not the same day as today then we need to get the next cut of date
      if today.wday != agency.cutOffDay
              
        # keep adding days until we get to the correct day
        while cut_off.wday != agency.cutOffDay do
          
          cut_off = cut_off + 1.day
          
        end  
      
      end
        
      # we now have a cut off date and time
      # next we loop through the send_alerts_on values
      for n in send_alerts_on
        
        # only send one alert when we have a match then exit the loop
        if (cut_off - n.hours) == now
            
            # we have a match on the cut off alert
            
            # get the approvers that have one or more timesheets that fall in the period
            approvers = User.get_approvers_with_outstanding_timesheets(agency.id, cut_off)
            
            for approver in approvers
              
              # send alert to approvers
              AgencyMailer.deliver_send_outstanding_alert_to_approver(agency, approver)
              count += 1
              
            end
            
            # get the contractors that have one or more timesheets that fall in the period
            contractors = User.get_contractors_with_outstanding_timesheets(agency.id, cut_off)
            
            for contractor in contractors
              
              # send alerts to contractors
              AgencyMailer.deliver_send_outstanding_alert_to_contractor(agency, contractor)
              count += 1
              
            end
            
            # found a match - so stop
            break
            
        end
        
      end
      
    end
    
    return count
    
  end
  
end