require 'test_helper'

class TimesheetTest < ActiveSupport::TestCase

  fixtures :contracts, :clients, :timesheets, :timesheet_entries, :rates
  
  test "calculate_basic_totals_default_rates_test" do
    
    # load the timesheet
    timesheet = timesheets(:basic_with_5_ot)

    # call the calc method
    timesheet.calc

    mon = timesheet.timesheet_entries.select {|e| e.id == timesheet_entries(:mon_basic_with_5_ot).id }[0]
    assert_not_nil mon, "Entry for Monday was nil"
    assert mon.netAmount == 96, "netTotal was #{mon.netAmount}, but should have been 96"

    tue = timesheet.timesheet_entries.select {|e| e.id == timesheet_entries(:tue_basic_with_5_ot).id }[0]
    assert_not_nil tue, "Entry for Tuesday was nil"
    assert tue.netAmount == 96, "netAmount was #{tue.netAmount}, but should have been 96"

		wed = timesheet.timesheet_entries.select {|e| e.id == timesheet_entries(:wed_basic_with_5_ot).id }[0]
    assert_not_nil wed, "Entry for Wednesday was nil"
    assert wed.netAmount == 96, "netAmount was #{wed.netAmount}, but should have been 96"

		wed_ot = timesheet.timesheet_entries.select {|e| e.id == timesheet_entries(:wed_basic_with_5_ot_1).id }[0]
		assert_not_nil wed_ot, "Entry for Wednesday (OT) was nil"
    assert wed_ot.netAmount == 22.5, "netAmount was #{wed_ot.netAmount}, but should have been 22.5"

		thu = timesheet.timesheet_entries.select {|e| e.id == timesheet_entries(:thu_basic_with_5_ot).id }[0]
    assert_not_nil thu, "Entry for Thursday was nil"
    assert thu.netAmount == 96, "netAmount was #{thu.netAmount}, but should have been 96"

		thu_ot = timesheet.timesheet_entries.select {|e| e.id == timesheet_entries(:thu_basic_with_5_ot_1).id }[0]
    assert_not_nil thu_ot, "Entry for Thursday (OT) was nil"
    assert thu_ot.netAmount == 22.5, "netAmount was #{thu_ot.netAmount}, but should have been 22.5"

		fri = timesheet.timesheet_entries.select {|e| e.id == timesheet_entries(:fri_basic_with_5_ot).id }[0]
    assert_not_nil fri, "Entry for Friday was nil"
    assert fri.netAmount == 96, "netAmount was #{fri.netAmount}, but should have been 96"

    fri_ot = timesheet.timesheet_entries.select {|e| e.id == timesheet_entries(:fri_basic_with_5_ot_1).id }[0]
    assert_not_nil fri_ot, "Entry for Friday (OT) was nil"
    assert fri_ot.netAmount == 7.5, "netAmount was #{fri_ot.netAmount}, but should have been 7.5"

		sat = timesheet.timesheet_entries.select {|e| e.id == timesheet_entries(:sat_basic_with_5_ot).id }[0]
    assert_not_nil sat, "Entry for Saturday was nil"
    assert sat.netAmount == 0, "Saturdays netAmount was not zero, but was #{sat.netAmount}"

		sun = timesheet.timesheet_entries.select {|e| e.id == timesheet_entries(:sun_basic_with_5_ot).id }[0]
    assert_not_nil sun, "Entry for Sunday was nil"
    assert sun.netAmount == 0, "Sundays netAmount was not zero, but was #{sun.netAmount}"
    
  end

  test "daily_timesheet_calculation_test" do

    # load the timesheet
    timesheet = timesheets(:standard_week_with_2_hrs_ot)

    timesheet.calc

    mon = timesheet.timesheet_entries.select {|e| e.id == timesheet_entries(:sw_daily_2_ot_mon).id }[0]
    assert_not_nil mon, "Entry for Monday was nil"
    assert mon.netAmount == 85, "netTotal was #{mon.netAmount}, but should have been 85"

    tue = timesheet.timesheet_entries.select {|e| e.id == timesheet_entries(:sw_daily_2_ot_mon).id }[0]
    assert_not_nil tue, "Entry for Tuesday was nil"
    assert tue.netAmount == 85, "netAmount was #{tue.netAmount}, but should have been 85"

		tue_ot = timesheet.timesheet_entries.select {|e| e.id == timesheet_entries(:sw_daily_2_ot_tue_ot).id }[0]
    assert_not_nil tue_ot, "Entry for Tue (OT) was nil"
    assert tue_ot.netAmount == 30, "netAmount was #{tue_ot.netAmount}, but should have been 30"

		wed = timesheet.timesheet_entries.select {|e| e.id == timesheet_entries(:sw_daily_2_ot_wed).id }[0]
		assert_not_nil wed, "Entry for Wednesday was nil"
    assert wed.netAmount == 85, "netAmount was #{wed.netAmount}, but should have been 85"

		thu = timesheet.timesheet_entries.select {|e| e.id == timesheet_entries(:sw_daily_2_ot_thu).id }[0]
    assert_not_nil thu, "Entry for Thursday was nil"
    assert thu.netAmount == 85, "netAmount was #{thu.netAmount}, but should have been 85"

		fri = timesheet.timesheet_entries.select {|e| e.id == timesheet_entries(:sw_daily_2_ot_fri).id }[0]
    assert_not_nil fri, "Entry for Friday was nil"
    assert fri.netAmount == 85, "netAmount was #{fri.netAmount}, but should have been 85"

		sat = timesheet.timesheet_entries.select {|e| e.id == timesheet_entries(:sw_daily_2_ot_sat).id }[0]
    assert_not_nil sat, "Entry for Saturday was nil"
    assert sat.netAmount == 0, "Saturdays netAmount was not zero, but was #{sat.netAmount}"

		sun = timesheet.timesheet_entries.select {|e| e.id == timesheet_entries(:sw_daily_2_ot_sun).id }[0]
    assert_not_nil sun, "Entry for Sunday was nil"
    assert sun.netAmount == 0, "Sundays netAmount was not zero, but was #{sun.netAmount}"

    
  end
  
end
