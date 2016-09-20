require 'test_helper'

class BillingInfosControllerTest < ActionController::TestCase
  setup do
    @billing_info = billing_infos(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:billing_infos)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create billing_info" do
    assert_difference('BillingInfo.count') do
      post :create, billing_info: { address: @billing_info.address, company_id: @billing_info.company_id, email: @billing_info.email, name: @billing_info.name, phone: @billing_info.phone, rut: @billing_info.rut, sector: @billing_info.sector }
    end

    assert_redirected_to billing_info_path(assigns(:billing_info))
  end

  test "should show billing_info" do
    get :show, id: @billing_info
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @billing_info
    assert_response :success
  end

  test "should update billing_info" do
    patch :update, id: @billing_info, billing_info: { address: @billing_info.address, company_id: @billing_info.company_id, email: @billing_info.email, name: @billing_info.name, phone: @billing_info.phone, rut: @billing_info.rut, sector: @billing_info.sector }
    assert_redirected_to billing_info_path(assigns(:billing_info))
  end

  test "should destroy billing_info" do
    assert_difference('BillingInfo.count', -1) do
      delete :destroy, id: @billing_info
    end

    assert_redirected_to billing_infos_path
  end
end
