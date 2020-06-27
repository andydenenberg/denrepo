class CreateStocks < ActiveRecord::Migration[5.2]
  def change
    create_table :stocks do |t|
      t.string :symbol
      t.decimal :last_price
      t.decimal :last_change
      t.datetime :last_updated

      t.timestamps
    end
  end
end
