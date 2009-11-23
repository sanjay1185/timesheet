require 'test_helper'

class RateTest < ActiveSupport::TestCase
  fixtures :contracts, :rates

  test "validity_test" do

    contract = contracts(:sw_pa_assistant)
    rate = contract.rates.build
    assert(!rate.valid?)
    rate.chargeRate = 13
    rate.default = false
    rate.effectiveDate = Date.new(2009,10,01)
    rate.category = 'Overtime'
    rate.rateType = 'Hour'
    rate.name = 'Some Overtime'

    assert(rate.valid?)
    
  end

  test "rates_for_contract" do
    contract = contracts(:sw_pa_assistant)
    rates = contract.rates

    assert_not_nil rates, 'No rates found for contract'
  end

end
