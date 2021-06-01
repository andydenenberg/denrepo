require 'test_helper'

class GratsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @grat = grats(:one)
  end

  test "should get index" do
    get grats_url
    assert_response :success
  end

  test "should get new" do
    get new_grat_url
    assert_response :success
  end

  test "should create grat" do
    assert_difference('Grat.count') do
      post grats_url, params: { grat: { call_ask: @grat.call_ask, call_bid: @grat.call_bid, call_exp_date: @grat.call_exp_date, call_strike: @grat.call_strike, close_date: @grat.close_date, cost: @grat.cost, current_price: @grat.current_price, datetime: @grat.datetime, put_ask: @grat.put_ask, put_bid: @grat.put_bid, put_exp_date: @grat.put_exp_date, put_strike: @grat.put_strike, quantity: @grat.quantity, symbol: @grat.symbol } }
    end

    assert_redirected_to grat_url(Grat.last)
  end

  test "should show grat" do
    get grat_url(@grat)
    assert_response :success
  end

  test "should get edit" do
    get edit_grat_url(@grat)
    assert_response :success
  end

  test "should update grat" do
    patch grat_url(@grat), params: { grat: { call_ask: @grat.call_ask, call_bid: @grat.call_bid, call_exp_date: @grat.call_exp_date, call_strike: @grat.call_strike, close_date: @grat.close_date, cost: @grat.cost, current_price: @grat.current_price, datetime: @grat.datetime, put_ask: @grat.put_ask, put_bid: @grat.put_bid, put_exp_date: @grat.put_exp_date, put_strike: @grat.put_strike, quantity: @grat.quantity, symbol: @grat.symbol } }
    assert_redirected_to grat_url(@grat)
  end

  test "should destroy grat" do
    assert_difference('Grat.count', -1) do
      delete grat_url(@grat)
    end

    assert_redirected_to grats_url
  end
end
