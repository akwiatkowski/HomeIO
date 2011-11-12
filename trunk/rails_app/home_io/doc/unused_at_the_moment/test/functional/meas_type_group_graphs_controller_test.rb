require 'test_helper'

class MeasTypeGroupGraphsControllerTest < ActionController::TestCase
  setup do
    @meas_type_group_graph = meas_type_group_graphs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:meas_type_group_graphs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create meas_type_group_graph" do
    assert_difference('MeasTypeGroupGraph.count') do
      post :create, :meas_type_group_graph => @meas_type_group_graph.attributes
    end

    assert_redirected_to meas_type_group_graph_path(assigns(:meas_type_group_graph))
  end

  test "should show meas_type_group_graph" do
    get :show, :id => @meas_type_group_graph.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @meas_type_group_graph.to_param
    assert_response :success
  end

  test "should update meas_type_group_graph" do
    put :update, :id => @meas_type_group_graph.to_param, :meas_type_group_graph => @meas_type_group_graph.attributes
    assert_redirected_to meas_type_group_graph_path(assigns(:meas_type_group_graph))
  end

  test "should destroy meas_type_group_graph" do
    assert_difference('MeasTypeGroupGraph.count', -1) do
      delete :destroy, :id => @meas_type_group_graph.to_param
    end

    assert_redirected_to meas_type_group_graphs_path
  end
end
