require 'test_helper'

class OverseersControllerTest < ActionController::TestCase
  setup do
    @overseer = overseers(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:overseers)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create overseer" do
    assert_difference('Overseer.count') do
      post :create, :overseer => @overseer.attributes
    end

    assert_redirected_to overseer_path(assigns(:overseer))
  end

  test "should show overseer" do
    get :show, :id => @overseer.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @overseer.to_param
    assert_response :success
  end

  test "should update overseer" do
    put :update, :id => @overseer.to_param, :overseer => @overseer.attributes
    assert_redirected_to overseer_path(assigns(:overseer))
  end

  test "should destroy overseer" do
    assert_difference('Overseer.count', -1) do
      delete :destroy, :id => @overseer.to_param
    end

    assert_redirected_to overseers_path
  end
end
