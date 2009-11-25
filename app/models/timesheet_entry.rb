class TimesheetEntry < ActiveRecord::Base

  #############################################################################
  # Relationships
  #############################################################################
  belongs_to :timesheet
	belongs_to :rate

  #############################################################################
  # Other attributes
  #############################################################################
  attr_accessor :requireFullWeek, :requireTimes, :is_bank_hol
  attr_accessible :rateType, :dayValue, :disabled, :timesheet_id, :dateValue, :hours, :netAmount, :startTime, :finishTime, :breakHours, :rate_id, :manual, :is_bank_hol, :requireTimes, :requireFullWeek, :deleted
 
  #############################################################################
  # Validation
  #############################################################################
  validates_format_of :startTime, :with => /^([0-1]?[0-9]|2[0-3]):([0134][05])$/, :on => :update, :message => "Format of start time is incorrect (make sure you specify 15 min intervals)", :allow_blank => true
  validates_format_of :finishTime, :with => /^([0-1]?[0-9]|2[0-3]):([0134][05])$/, :on => :update, :message => "Format of finish time is incorrect (make sure you specify 15 min intervals)", :allow_blank => true
  validates_format_of :breakHours, :with => /^([0-1]?[0-9]|2[0-3]):([0134][05])$/, :on => :update, :message => "Format of break hours is incorrect (make sure you specify 15 min intervals)", :allow_blank => true
  validates_format_of :hours, :with => /^([0-1]?[0-9]|2[0-3]):([0134][05])$/, :on => :update, :message => "Format of total hours is incorrect (make sure you specify 15 min intervals)", :allow_blank => true

  #############################################################################
  # Call back events
  #############################################################################
  
  #############################################################################
  # Overridden methods
  #############################################################################
  def validate

    # no need to validate if disabled
    return if disabled?

    # validate that we've filled in all the days
    if rateType == 'Day'

      if dayValue == 0

        if requireFullWeek == true

            # must fill in whole week, and datValue is 0
            errors.add(:dayValue, "You must supply a day value for all shifts, including weekends")

        else

          # requireFullWeek is false
          if (dateValue.wday != 6 && dateValue.wday != 0)

            # an entry is not filled in for mon to fri
            errors.add(:dayValue, "You must supply a day value for each shift, Mon - Fri")
            
          end
          
        end

      end

      # return as there is no need to validate anything else
      return
      
    end

    # now validating hourly rate entry
    if hours.blank?
      
      # can we allow blank hours?
      if is_bank_hol == false
        
        if requireFullWeek == true
                   
          # its not a bank holiday and we need the whole week
          msg = "Hours must be supplied for all days"

        else

          # its not a bank hol and we dont need the whole week
          if (dateValue.wday != 6 && dateValue.wday != 0)

            # an entry for mon-fri isnt supplied
            msg = "Hours must be supplied for Monday - Friday"
            
          end

        end
        
      end

      if !msg.blank?

        errors.add(:hours, msg)

      end

    end

    # validate start, end and break times
    if !startTime.blank? && !finishTime.blank? && !hours.blank? && requireTimes

      time_difference = Time.parse(finishTime) - Time.parse(startTime)
      break_seconds = Time.parse(breakHours) - Time.parse("00:00") unless breakHours.blank?
      time_difference -= break_seconds unless break_seconds.nil?
      specified_hours = Time.parse(hours) - Time.parse("00:00")
      
      if (time_difference <=> specified_hours) != 0
        
        # the time entered in hours doesnt match the calculation
        errors.add(:hours, "Make sure the hours supplied correctly relates to the time periods")
      
      end

    end

    # check times are valid
    if (startTime.blank? || finishTime.blank?)
      
      #logger.info("date: #{dateValue}, manual: #{manual}, disabled: #{disabled}, rateType: #{rateType}, rate category: #{rate.category}")
      
      if requireTimes == true

        # if we dont require full week and this is a w/e then dont bother carrying on
        if requireFullWeek == false && (dateValue.wday == 6 || dateValue.wday == 0)
          return
        end

        # if we get here then there's a prob so display error
        errors.add(:startTime, "You must supply start times") if startTime.blank? && rate.category != 'Unpaid'
        errors.add(:finishTime, "You must supply finish times") if finishTime.blank? && rate.category != 'Unpaid'

      end

    end
    
  end

  #############################################################################
  # Custom methods
  #############################################################################
   
  #----------------------------------------------------------------------------
  # calculate the value for this entry
  #----------------------------------------------------------------------------
  def calc

    # get the amount (hrs or days)
    if self.rateType == 'Hour'

      std = self.hours.nil? ? 0 : TimeUtil.hours_to_numeric(self.hours)

    else

      std = dayValue.nil? ? 0 : dayValue
      
    end

    amt = 0
    
    amt = std * self.chargeRate unless self.chargeRate.nil? || self.chargeRate == 0
    self.netAmount = amt

    puts "amt was #{amt}"
    return amt
    
  end

  #----------------------------------------------------------------------------
  # format the hours correctly
  #----------------------------------------------------------------------------
	def format_hours

    self.breakHours = self.breakHours[1,self.breakHours.length] if !self.breakHours.blank? && self.breakHours =~ /0[0-9]:/
		self.hours = self.hours[1,hours.length] if !self.hours.blank? && self.hours =~ /0[0-9]:/
    
	end
    
end
