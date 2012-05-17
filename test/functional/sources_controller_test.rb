require 'test_helper'

class SourcesControllerTest < ActionController::TestCase
  setup do
    @user = FactoryGirl.build(:user)
    @source = FactoryGirl.build(:source)
  end

  test "should get index" do
    login_user
    get :index
    assert_response :success
    assert_not_nil assigns(:sources)
  end
end
