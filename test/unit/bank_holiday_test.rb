require 'test_helper'

class BankHolidayTest < ActiveSupport::TestCase

  fixtures :bank_holidays

  test "bank holiday dates test" do
    assert(BankHoliday.is_holiday(Date.new(2009,8,31), 'UK'), "31/08/09 is a bank hol")
    assert(!BankHoliday.is_holiday(Date.new(2009,8,29), 'UK'), "29/08/09 is not a bank hol")
  end
  
end
