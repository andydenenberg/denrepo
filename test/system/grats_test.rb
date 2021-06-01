require "application_system_test_case"

class GratsTest < ApplicationSystemTestCase
  setup do
    @grat = grats(:one)
  end

  test "visiting the index" do
    visit grats_url
    assert_selector "h1", text: "Grats"
  end

  test "creating a Grat" do
    visit grats_url
    click_on "New Grat"

    fill_in "Call ask", with: @grat.call_ask
    fill_in "Call bid", with: @grat.call_bid
    fill_in "Call exp date", with: @grat.call_exp_date
    fill_in "Call strike", with: @grat.call_strike
    fill_in "Close date", with: @grat.close_date
    fill_in "Cost", with: @grat.cost
    fill_in "Current price", with: @grat.current_price
    fill_in "Datetime", with: @grat.datetime
    fill_in "Put ask", with: @grat.put_ask
    fill_in "Put bid", with: @grat.put_bid
    fill_in "Put exp date", with: @grat.put_exp_date
    fill_in "Put strike", with: @grat.put_strike
    fill_in "Quantity", with: @grat.quantity
    fill_in "Symbol", with: @grat.symbol
    click_on "Create Grat"

    assert_text "Grat was successfully created"
    click_on "Back"
  end

  test "updating a Grat" do
    visit grats_url
    click_on "Edit", match: :first

    fill_in "Call ask", with: @grat.call_ask
    fill_in "Call bid", with: @grat.call_bid
    fill_in "Call exp date", with: @grat.call_exp_date
    fill_in "Call strike", with: @grat.call_strike
    fill_in "Close date", with: @grat.close_date
    fill_in "Cost", with: @grat.cost
    fill_in "Current price", with: @grat.current_price
    fill_in "Datetime", with: @grat.datetime
    fill_in "Put ask", with: @grat.put_ask
    fill_in "Put bid", with: @grat.put_bid
    fill_in "Put exp date", with: @grat.put_exp_date
    fill_in "Put strike", with: @grat.put_strike
    fill_in "Quantity", with: @grat.quantity
    fill_in "Symbol", with: @grat.symbol
    click_on "Update Grat"

    assert_text "Grat was successfully updated"
    click_on "Back"
  end

  test "destroying a Grat" do
    visit grats_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Grat was successfully destroyed"
  end
end
