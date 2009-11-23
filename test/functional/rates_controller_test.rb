require 'test_helper'

class RatesControllerTest < ActionController::TestCase
  
  test "can_create_rate" do
  
    assert_difference('Rate.count') do
      post :create, :client_id => clients(:one).id, :contract_id => contracts(:one).id,
        :rate_type => 'Overtime', :effective_date => '2009-05-01', :end_date => '2009-05-12',
        :rate => { :name => 'Test OT Rate', :payRate => 13.50, :comment => 'Test OT Rate' }
    end

    assert_redirected_to client_contract_rates_path(assigns(:client))
  end

  test "should_get_new" do
    session[:agencyId] = agencies(:one).id
    session[:nameType] = agencies(:one).contractNameType
    get :new, :client_id => clients(:one).id, :contract_id => contracts(:one).id
    assert_response :success
  end

  test "should_get_edit" do
    session[:agencyId] = agencies(:one).id
    session[:nameType] = agencies(:one).contractNameType
    get :edit, :id => rates(:standard_1).id, :client_id => clients(:one).id, :contract_id => contracts(:one).id
    assert_response :success
  end

  test "can_update_rate" do
    session[:agencyId] = agencies(:one).id
    session[:nameType] = agencies(:one).contractNameType
    put :update, :id => rates(:overtime_1).id, :client_id => clients(:one).id, :contract_id => contracts(:one).id,
      :rate_type => 'Overtime', :effective_date => '2009-05-01', :end_date => '2009-05-12',
      :rate => { :payRate => 18.75 }
    assert_redirected_to client_contract_rates_path(assigns(:client))
  end

  test "should_get_index" do
    session[:agencyId] = agencies(:one).id
    session[:nameType] = agencies(:one).contractNameType
    get :index, :client_id => clients(:one).id, :contract_id => contracts(:one).id
    assert_response :success
    assert_not_nil assigns(:rates)
  end

  test "can_destroy_rate" do
    assert_difference('Rate.count', -1) do
      delete :destroy, :id => rates(:standard_1).id, :client_id => clients(:one).id, :contract_id => contracts(:one).id
    end

    assert_redirected_to client_contract_rates_path(assigns(:client))
  end

end
