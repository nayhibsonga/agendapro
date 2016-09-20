require 'test_helper'

class EconomicSectorsControllerTest < ActionController::TestCase
  setup do
    @economic_sector = economic_sectors(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:economic_sectors)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create economic_sector" do
    assert_difference('EconomicSector.count') do
      post :create, economic_sector: {  }
    end

    assert_redirected_to economic_sector_path(assigns(:economic_sector))
  end

  test "should show economic_sector" do
    get :show, id: @economic_sector
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @economic_sector
    assert_response :success
  end

  test "should update economic_sector" do
    patch :update, id: @economic_sector, economic_sector: {  }
    assert_redirected_to economic_sector_path(assigns(:economic_sector))
  end

  test "should destroy economic_sector" do
    assert_difference('EconomicSector.count', -1) do
      delete :destroy, id: @economic_sector
    end

    assert_redirected_to economic_sectors_path
  end
end
