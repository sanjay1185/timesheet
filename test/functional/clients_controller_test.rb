require 'test_helper'

class ClientsControllerTest < ActionController::TestCase

  def setup
    perform_login('aaron', 'test')
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:clients)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create client" do
    assert_difference('Client.count') do
      post :create, :client => {:name => 'Test Client',
        :addr1 => '12 Some St',
        :city => 'London',
        :postCode => 'E1 7GD',
        :margin => 20,
        :monthlyInvoicePeriodStartDay => 1 }, :period => 'Monthly'
    end

    assert_equal 'Client successfully created', flash[:notice]
    assert_redirected_to edit_client_path(assigns(:client))
  end

  test "should get edit" do
    get :edit, :id => clients(:abn_amro).id
    assert_response :success
  end

  test "should update client" do
    put :update, :id => clients(:abn_amro).id, :client => { :postCode => 'TT1 1TT'}, :period => 'Weekly'

    client = Client.find(clients(:abn_amro).id)

    assert_equal 'TT1 1TT', client.postCode
    assert_equal 'Weekly', client.invoicePeriod
    
    assert_equal 'Client saved', flash[:notice]
    assert_response :success
  end

  test "should destroy client" do
    assert_difference('Client.count', -1) do
      delete :destroy, :id => clients(:abn_amro).id
    end

    assert_redirected_to clients_path
  end
end
