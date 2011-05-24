require 'test_helper'

class HomeArchivesControllerTest < ActionController::TestCase
  setup do
    @home_archive = home_archives(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:home_archives)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create home_archive" do
    assert_difference('HomeArchive.count') do
      post :create, :home_archive => @home_archive.attributes
    end

    assert_redirected_to home_archive_path(assigns(:home_archive))
  end

  test "should show home_archive" do
    get :show, :id => @home_archive.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @home_archive.to_param
    assert_response :success
  end

  test "should update home_archive" do
    put :update, :id => @home_archive.to_param, :home_archive => @home_archive.attributes
    assert_redirected_to home_archive_path(assigns(:home_archive))
  end

  test "should destroy home_archive" do
    assert_difference('HomeArchive.count', -1) do
      delete :destroy, :id => @home_archive.to_param
    end

    assert_redirected_to home_archives_path
  end
end
