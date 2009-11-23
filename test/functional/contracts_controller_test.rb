require 'test_helper'

class ContractsControllerTest < ActionController::TestCase

  test "changing end date of contract - check status" do
    # login
    perform_login('aaron', 'test')
    # update contract to last timesheet date - should be set to COMPLETE
    put :update, :id => contracts(:sw_pa_assistant).id, :client_id => clients(:abn_amro).id, :contract => { :endDate => Date.new(2009,05,10) }
    re_read_contract = Contract.find(1)
    assert re_read_contract.status == 'COMPLETE'
    # update contract to later date - should be set to ACTIVE
    put :update, :id => contracts(:sw_pa_assistant).id, :client_id => clients(:abn_amro).id, :contract => { :endDate => Date.new(2009,06,30) }
    re_read_contract = Contract.find(1)
    assert re_read_contract.status == 'ACTIVE'
  end

end