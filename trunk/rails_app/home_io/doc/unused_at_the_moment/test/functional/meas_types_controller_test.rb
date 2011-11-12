require 'test_helper'

class MeasTypesControllerTest < ActionController::TestCase
  setup do
    @meas_type = meas_types(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:meas_types)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create meas_type" do
    assert_difference('MeasType.count') do
      post :create, :meas_type => @meas_type.attributes
    end

    assert_redirected_to meas_type_path(assigns(:meas_type))
  end

  test "should show meas_type" do
    get :show, :id => @meas_type.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @meas_type.to_param
    assert_response :success
  end

  test "should update meas_type" do
    put :update, :id => @meas_type.to_param, :meas_type => @meas_type.attributes
    assert_redirected_to meas_type_path(assigns(:meas_type))
  end

  test "should destroy meas_type" do
    assert_difference('MeasType.count', -1) do
      delete :destroy, :id => @meas_type.to_param
    end

    assert_redirected_to meas_types_path
  end
end
