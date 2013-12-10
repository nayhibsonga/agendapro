require 'test_helper'

class CompanySettingsControllerTest < ActionController::TestCase
  setup do
    @company_setting = company_settings(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:company_settings)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create company_setting" do
    assert_difference('CompanySetting.count') do
      post :create, company_setting: {  }
    end

    assert_redirected_to company_setting_path(assigns(:company_setting))
  end

  test "should show company_setting" do
    get :show, id: @company_setting
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @company_setting
    assert_response :success
  end

  test "should update company_setting" do
    patch :update, id: @company_setting, company_setting: {  }
    assert_redirected_to company_setting_path(assigns(:company_setting))
  end

  test "should destroy company_setting" do
    assert_difference('CompanySetting.count', -1) do
      delete :destroy, id: @company_setting
    end

    assert_redirected_to company_settings_path
  end
end
