require 'test_helper'

class StaffCodesControllerTest < ActionController::TestCase
  setup do
    @staff_code = staff_codes(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:staff_codes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create staff_code" do
    assert_difference('StaffCode.count') do
      post :create, staff_code: {  }
    end

    assert_redirected_to staff_code_path(assigns(:staff_code))
  end

  test "should show staff_code" do
    get :show, id: @staff_code
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @staff_code
    assert_response :success
  end

  test "should update staff_code" do
    patch :update, id: @staff_code, staff_code: {  }
    assert_redirected_to staff_code_path(assigns(:staff_code))
  end

  test "should destroy staff_code" do
    assert_difference('StaffCode.count', -1) do
      delete :destroy, id: @staff_code
    end

    assert_redirected_to staff_codes_path
  end
end
