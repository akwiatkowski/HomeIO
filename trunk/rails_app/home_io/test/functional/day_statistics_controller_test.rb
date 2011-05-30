require 'test_helper'

class DayStatisticsControllerTest < ActionController::TestCase
  setup do
    @day_statistic = day_statistics(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:day_statistics)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create day_statistic" do
    assert_difference('DayStatistic.count') do
      post :create, :day_statistic => @day_statistic.attributes
    end

    assert_redirected_to day_statistic_path(assigns(:day_statistic))
  end

  test "should show day_statistic" do
    get :show, :id => @day_statistic.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @day_statistic.to_param
    assert_response :success
  end

  test "should update day_statistic" do
    put :update, :id => @day_statistic.to_param, :day_statistic => @day_statistic.attributes
    assert_redirected_to day_statistic_path(assigns(:day_statistic))
  end

  test "should destroy day_statistic" do
    assert_difference('DayStatistic.count', -1) do
      delete :destroy, :id => @day_statistic.to_param
    end

    assert_redirected_to day_statistics_path
  end
end
