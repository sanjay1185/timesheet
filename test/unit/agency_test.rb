require 'test_helper'

class AgencyTest < ActiveSupport::TestCase

  # test that we get the correct days left from the date
  # the agency was created from 30 days.
  test "get correct trial days" do
    agency = agencies(:trial_agency)
    days_left = agency.days_left_of_trial
    assert days_left == 30
	end

  test "validation_test" do
    agency = Agency.new
    assert !agency.valid?

    agency.name = "Some Recuitment"
    agency.addr1 = "123 Bum St"
    agency.city = "London"
    agency.postCode = "W5 7JJ"
    agency.phone = "020 8411 4243"
    agency.fax = "020 8412 4213"

    assert !agency.valid?
    agency.email = "bob@some.com"

    agency.phone = "0124213542154216587845124521325412"
    assert !agency.valid?
  end

  test "increment invoice number" do
    invoice_number = Agency.increment_invoice_number(agencies(:sherridan_ward).id)
    assert invoice_number == 1
    agency = Agency.find(agencies(:sherridan_ward).id)
    assert agency.nextInvoiceNumber == 2   
  end
  
end
