require 'test_helper'

class ContractTest < ActiveSupport::TestCase
  
  test "cant set end date < last timesheet date" do
    ctrct = contracts(:sw_pa_assistant)
    # last timesheet end date is 2009-05-04
    ctrct.endDate = Date.new(2009,05,03)
    assert !ctrct.valid?
  end

  test "cant set end date < start date" do
    ctrct = contracts(:sw_pa_assistant)
    ctrct.startDate = Date.parse("2009-04-19")
    assert !ctrct.valid?
  end

  test "new contract has status of 'INACTIVE'" do
    c = Contract.new
    assert c.status == 'INACTIVE'
  end

  test "contract must start on a monday" do
    c = contracts(:sw_error_non_monday)
    assert !c.valid?
  end
  
end
