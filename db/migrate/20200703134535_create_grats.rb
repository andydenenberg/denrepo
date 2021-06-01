class CreateGrats < ActiveRecord::Migration[5.2]
  def change
    create_table :grats do |t|
      t.datetime :close_date
      t.string :symbol
      t.decimal :quantity
      t.decimal :cost
      t.decimal :current_price
      t.string :call_exp_date
      t.decimal :call_strike
      t.decimal :call_bid
      t.decimal :call_ask
      t.string :put_exp_date
      t.decimal :put_strike
      t.decimal :put_bid
      t.decimal :put_ask
      t.string :note

      t.timestamps
    end
  end
end
