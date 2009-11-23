require 'test_helper'

class TimesheetEntriesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:timesheet_entries)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create timesheet_entry" do
    assert_difference('TimesheetEntry.count') do
      post :create, :timesheet_entry => { }
    end

    assert_redirected_to timesheet_entry_path(assigns(:timesheet_entry))
  end

  test "should show timesheet_entry" do
    get :show, :id => timesheet_entries(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => timesheet_entries(:one).id
    assert_response :success
  end

  test "should update timesheet_entry" do
    put :update, :id => timesheet_entries(:one).id, :timesheet_entry => { }
    assert_redirected_to timesheet_entry_path(assigns(:timesheet_entry))
  end

  test "should destroy timesheet_entry" do
    assert_difference('TimesheetEntry.count', -1) do
      delete :destroy, :id => timesheet_entries(:one).id
    end

    assert_redirected_to timesheet_entries_path
  end
end
