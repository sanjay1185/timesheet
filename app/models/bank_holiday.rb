class BankHoliday < ActiveRecord::Base

  #############################################################################
  # Custom Methods
  #############################################################################

  #----------------------------------------------------------------------------
  # Check the date to see if it is a bank holiday
  #----------------------------------------------------------------------------
  def self.is_holiday(the_date, country_code)

    conditions = []
    conditions.add_condition!(['holidayDate = ?', the_date])
    conditions.add_condition!(['countryCode = ?', country_code])

    return BankHoliday.exists?(conditions)
  
  end
  
end
