require 'test_helper'

class MeasArchivesControllerTest < ActionController::TestCase
  setup do
    @meas_archive = meas_archives(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:meas_archives)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create meas_archive" do
    assert_difference('MeasArchive.count') do
      post :create, :meas_archive => @meas_archive.attributes
    end

    assert_redirected_to meas_archive_path(assigns(:meas_archive))
  end

  test "should show meas_archive" do
    get :show, :id => @meas_archive.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @meas_archive.to_param
    assert_response :success
  end

  test "should update meas_archive" do
    put :update, :id => @meas_archive.to_param, :meas_archive => @meas_archive.attributes
    assert_redirected_to meas_archive_path(assigns(:meas_archive))
  end

  test "should destroy meas_archive" do
    assert_difference('MeasArchive.count', -1) do
      delete :destroy, :id => @meas_archive.to_param
    end

    assert_redirected_to meas_archives_path
  end
end
