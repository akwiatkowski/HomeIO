require 'test_helper'

class ActionEventsControllerTest < ActionController::TestCase
  setup do
    @action_event = action_events(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:action_events)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create action_event" do
    assert_difference('ActionEvent.count') do
      post :create, :action_event => @action_event.attributes
    end

    assert_redirected_to action_event_path(assigns(:action_event))
  end

  test "should show action_event" do
    get :show, :id => @action_event.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @action_event.to_param
    assert_response :success
  end

  test "should update action_event" do
    put :update, :id => @action_event.to_param, :action_event => @action_event.attributes
    assert_redirected_to action_event_path(assigns(:action_event))
  end

  test "should destroy action_event" do
    assert_difference('ActionEvent.count', -1) do
      delete :destroy, :id => @action_event.to_param
    end

    assert_redirected_to action_events_path
  end
end
