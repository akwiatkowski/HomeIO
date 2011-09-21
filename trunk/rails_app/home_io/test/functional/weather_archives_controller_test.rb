require 'test_helper'

class WeatherArchivesControllerTest < ActionController::TestCase
  setup do
    @weather_archive = weather_archives(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:weather_archives)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create weather_archive" do
    assert_difference('WeatherArchive.count') do
      post :create, :weather_archives => @weather_archive.attributes
    end

    assert_redirected_to weather_archive_path(assigns(:weather_archives))
  end

  test "should show weather_archive" do
    get :show, :id => @weather_archive.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @weather_archive.to_param
    assert_response :success
  end

  test "should update weather_archive" do
    put :update, :id => @weather_archive.to_param, :weather_archives => @weather_archive.attributes
    assert_redirected_to weather_archive_path(assigns(:weather_archives))
  end

  test "should destroy weather_archive" do
    assert_difference('WeatherArchive.count', -1) do
      delete :destroy, :id => @weather_archive.to_param
    end

    assert_redirected_to weather_archives_path
  end
end
