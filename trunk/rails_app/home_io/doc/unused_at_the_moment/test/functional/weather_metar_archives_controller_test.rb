require 'test_helper'

class WeatherMetarArchivesControllerTest < ActionController::TestCase
  setup do
    @weather_metar_archive = weather_metar_archives(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:weather_metar_archives)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create weather_metar_archive" do
    assert_difference('WeatherMetarArchive.count') do
      post :create, :weather_metar_archive => @weather_metar_archive.attributes
    end

    assert_redirected_to weather_metar_archive_path(assigns(:weather_metar_archive))
  end

  test "should show weather_metar_archive" do
    get :show, :id => @weather_metar_archive.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @weather_metar_archive.to_param
    assert_response :success
  end

  test "should update weather_metar_archive" do
    put :update, :id => @weather_metar_archive.to_param, :weather_metar_archive => @weather_metar_archive.attributes
    assert_redirected_to weather_metar_archive_path(assigns(:weather_metar_archive))
  end

  test "should destroy weather_metar_archive" do
    assert_difference('WeatherMetarArchive.count', -1) do
      delete :destroy, :id => @weather_metar_archive.to_param
    end

    assert_redirected_to weather_metar_archives_path
  end
end
