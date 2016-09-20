require 'test_helper'

class StaffTimesControllerTest < ActionController::TestCase
  setup do
    @staff_time = staff_times(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:staff_times)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create staff_time" do
    assert_difference('StaffTime.count') do
      post :create, staff_time: {  }
    end

    assert_redirected_to staff_time_path(assigns(:staff_time))
  end

  test "should show staff_time" do
    get :show, id: @staff_time
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @staff_time
    assert_response :success
  end

  test "should update staff_time" do
    patch :update, id: @staff_time, staff_time: {  }
    assert_redirected_to staff_time_path(assigns(:staff_time))
  end

  test "should destroy staff_time" do
    assert_difference('StaffTime.count', -1) do
      delete :destroy, id: @staff_time
    end

    assert_redirected_to staff_times_path
  end
end
