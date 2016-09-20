require 'test_helper'

class EconomicSectorsDictionariesControllerTest < ActionController::TestCase
  setup do
    @economic_sectors_dictionary = economic_sectors_dictionaries(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:economic_sectors_dictionaries)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create economic_sectors_dictionary" do
    assert_difference('EconomicSectorsDictionary.count') do
      post :create, economic_sectors_dictionary: { economic_sector_id: @economic_sectors_dictionary.economic_sector_id, name: @economic_sectors_dictionary.name }
    end

    assert_redirected_to economic_sectors_dictionary_path(assigns(:economic_sectors_dictionary))
  end

  test "should show economic_sectors_dictionary" do
    get :show, id: @economic_sectors_dictionary
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @economic_sectors_dictionary
    assert_response :success
  end

  test "should update economic_sectors_dictionary" do
    patch :update, id: @economic_sectors_dictionary, economic_sectors_dictionary: { economic_sector_id: @economic_sectors_dictionary.economic_sector_id, name: @economic_sectors_dictionary.name }
    assert_redirected_to economic_sectors_dictionary_path(assigns(:economic_sectors_dictionary))
  end

  test "should destroy economic_sectors_dictionary" do
    assert_difference('EconomicSectorsDictionary.count', -1) do
      delete :destroy, id: @economic_sectors_dictionary
    end

    assert_redirected_to economic_sectors_dictionaries_path
  end
end
