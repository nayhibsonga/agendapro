require 'test_helper'

class PaymentStatusesControllerTest < ActionController::TestCase
  setup do
    @payment_status = payment_statuses(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:payment_statuses)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create payment_status" do
    assert_difference('PaymentStatus.count') do
      post :create, payment_status: {  }
    end

    assert_redirected_to payment_status_path(assigns(:payment_status))
  end

  test "should show payment_status" do
    get :show, id: @payment_status
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @payment_status
    assert_response :success
  end

  test "should update payment_status" do
    patch :update, id: @payment_status, payment_status: {  }
    assert_redirected_to payment_status_path(assigns(:payment_status))
  end

  test "should destroy payment_status" do
    assert_difference('PaymentStatus.count', -1) do
      delete :destroy, id: @payment_status
    end

    assert_redirected_to payment_statuses_path
  end
end
