module ControllerMacros
  def login_admin
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:admin]
      role = FactoryGirl.create(:role, :admin_role)
      user = FactoryGirl.create(:user, :admin, role: role)
      sign_in user
    end
  end

  def login_super_admin
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:admin]
      role = FactoryGirl.create(:role, :super_admin_role)
      user = FactoryGirl.create(:user, :super_admin, role: role)
      sign_in user # sign_in(scope, resource)
    end
  end

  def login_user
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      role = FactoryGirl.create(:role)
      user = FactoryGirl.create(:user, role: role)
      #user.confirm! # or set a confirmed_at inside the factory. Only necessary if you are using the "confirmable" module
      sign_in user
    end
  end
end