require 'test_helper'

class CompanyFromEmailsControllerTest < ActionController::TestCase
  setup do
    @company_from_email = company_from_emails(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:company_from_emails)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create company_from_email" do
    assert_difference('CompanyFromEmail.count') do
      post :create, company_from_email: { company_id: @company_from_email.company_id, email: @company_from_email.email }
    end

    assert_redirected_to company_from_email_path(assigns(:company_from_email))
  end

  test "should show company_from_email" do
    get :show, id: @company_from_email
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @company_from_email
    assert_response :success
  end

  test "should update company_from_email" do
    patch :update, id: @company_from_email, company_from_email: { company_id: @company_from_email.company_id, email: @company_from_email.email }
    assert_redirected_to company_from_email_path(assigns(:company_from_email))
  end

  test "should destroy company_from_email" do
    assert_difference('CompanyFromEmail.count', -1) do
      delete :destroy, id: @company_from_email
    end

    assert_redirected_to company_from_emails_path
  end
end
