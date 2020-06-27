json.extract! stock, :id, :symbol, :last_price, :last_change, :update, :created_at, :updated_at
json.url stock_url(stock, format: :json)
