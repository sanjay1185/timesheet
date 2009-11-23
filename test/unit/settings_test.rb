require 'test_helper'

class SettingsTest < ActiveSupport::TestCase
  fixtures :settings

  test "get setting with and without dates" do
    # should get the later ni_rate
    ni_rate_newer = Settings.get_setting('ni_rate', Date.new(2009,06,01))
    ni_rate = Settings.get_setting('ni_rate', Date.new(2009,05,01))

    assert_not_equal ni_rate_newer, ni_rate, "the same ni_rate was returned!"
    assert_equal "12.8", ni_rate.value, "ni_rate should have been 12.8"
    assert_equal "12.9", ni_rate_newer.value, "ni_rate should have been 12.9"
  end

  test "get setting with no date" do
    vat_number = Settings.get_setting('vat_number')

    assert_not_nil vat_number, "setting was nil"
    assert_equal "906 1781 27", vat_number.value, "vat number should have been 906 1781 27"
  end



end