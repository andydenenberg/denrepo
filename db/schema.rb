# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_07_03_134535) do

  create_table "grats", force: :cascade do |t|
    t.datetime "close_date"
    t.string "symbol"
    t.decimal "quantity"
    t.decimal "cost"
    t.decimal "current_price"
    t.string "call_exp_date"
    t.decimal "call_strike"
    t.decimal "call_bid"
    t.decimal "call_ask"
    t.string "put_exp_date"
    t.decimal "put_strike"
    t.decimal "put_bid"
    t.decimal "put_ask"
    t.string "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "stocks", force: :cascade do |t|
    t.string "symbol"
    t.decimal "last_price"
    t.decimal "last_change"
    t.datetime "last_updated"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
