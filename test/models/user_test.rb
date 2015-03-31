require 'test_helper'

class UserTest < ActiveSupport::TestCase

  test "email_test" do
  	user = User.new(users(:user_1).attributes.to_options)
  	user.id = nil
    assert_not user.save, "Saved user with existing email"
  end

end
