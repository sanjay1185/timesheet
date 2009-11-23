require 'test_helper'

class TimesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:times)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create time" do
    assert_difference('Time.count') do
      post :create, :time => { }
    end

    assert_redirected_to time_path(assigns(:time))
  end

  test "should show time" do
    get :show, :id => times(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => times(:one).id
    assert_response :success
  end

  test "should update time" do
    put :update, :id => times(:one).id, :time => { }
    assert_redirected_to time_path(assigns(:time))
  end

  test "should destroy time" do
    assert_difference('Time.count', -1) do
      delete :destroy, :id => times(:one).id
    end

    assert_redirected_to times_path
  end
end
