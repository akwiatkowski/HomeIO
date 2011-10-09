require 'test_helper'

class MeasTypeGroupsControllerTest < ActionController::TestCase
  setup do
    @meas_type_group = meas_type_groups(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:meas_type_groups)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create meas_type_group" do
    assert_difference('MeasTypeGroup.count') do
      post :create, :meas_type_group => @meas_type_group.attributes
    end

    assert_redirected_to meas_type_group_path(assigns(:meas_type_group))
  end

  test "should show meas_type_group" do
    get :show, :id => @meas_type_group.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @meas_type_group.to_param
    assert_response :success
  end

  test "should update meas_type_group" do
    put :update, :id => @meas_type_group.to_param, :meas_type_group => @meas_type_group.attributes
    assert_redirected_to meas_type_group_path(assigns(:meas_type_group))
  end

  test "should destroy meas_type_group" do
    assert_difference('MeasTypeGroup.count', -1) do
      delete :destroy, :id => @meas_type_group.to_param
    end

    assert_redirected_to meas_type_groups_path
  end
end
