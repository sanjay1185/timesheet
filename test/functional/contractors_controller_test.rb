require 'test_helper'

class ContractorsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:contractors)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create contractor" do
    assert_difference('Contractor.count') do
      post :create, :contractor => { }
    end

    assert_redirected_to contractor_path(assigns(:contractor))
  end

  test "should show contractor" do
    get :show, :id => contractors(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => contractors(:one).id
    assert_response :success
  end

  test "should update contractor" do
    put :update, :id => contractors(:one).id, :contractor => { }
    assert_redirected_to contractor_path(assigns(:contractor))
  end

  test "should destroy contractor" do
    assert_difference('Contractor.count', -1) do
      delete :destroy, :id => contractors(:one).id
    end

    assert_redirected_to contractors_path
  end
end
