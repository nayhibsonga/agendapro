require 'test_helper'

class LocationTimesControllerTest < ActionController::TestCase
  setup do
    @location_time = location_times(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:location_times)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create location_time" do
    assert_difference('LocationTime.count') do
      post :create, location_time: {  }
    end

    assert_redirected_to location_time_path(assigns(:location_time))
  end

  test "should show location_time" do
    get :show, id: @location_time
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @location_time
    assert_response :success
  end

  test "should update location_time" do
    patch :update, id: @location_time, location_time: {  }
    assert_redirected_to location_time_path(assigns(:location_time))
  end

  test "should destroy location_time" do
    assert_difference('LocationTime.count', -1) do
      delete :destroy, id: @location_time
    end

    assert_redirected_to location_times_path
  end
end
