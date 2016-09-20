require 'test_helper'

class NumericParametersControllerTest < ActionController::TestCase
  setup do
    @numeric_parameter = numeric_parameters(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:numeric_parameters)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create numeric_parameter" do
    assert_difference('NumericParameter.count') do
      post :create, numeric_parameter: { name: @numeric_parameter.name, value: @numeric_parameter.value }
    end

    assert_redirected_to numeric_parameter_path(assigns(:numeric_parameter))
  end

  test "should show numeric_parameter" do
    get :show, id: @numeric_parameter
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @numeric_parameter
    assert_response :success
  end

  test "should update numeric_parameter" do
    patch :update, id: @numeric_parameter, numeric_parameter: { name: @numeric_parameter.name, value: @numeric_parameter.value }
    assert_redirected_to numeric_parameter_path(assigns(:numeric_parameter))
  end

  test "should destroy numeric_parameter" do
    assert_difference('NumericParameter.count', -1) do
      delete :destroy, id: @numeric_parameter
    end

    assert_redirected_to numeric_parameters_path
  end
end
