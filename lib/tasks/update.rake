namespace :update do
  
  desc 'Refresh Prices'
    task :refresh_data => :environment do
      Options.refresh_data
    end
  end
  
end
#   def self.stock_price(symbol)  
#     url = "https://api.iextrading.com/1.0/stock/#{symbol.upcase}/quote" 
#     @agent = Mechanize.new
#     ret = [ ]
#       begin
#         page = @agent.get(url)
#         data = JSON.parse(page.body) 
#         
#         #puts data
#         
#         last_price = data['latestPrice'].to_s
#         change = data["change"].to_s
#         time = data["latestTime"]
#         date = Time.parse(time) - 1.hour
#         puts time
#         
#         ret = [symbol.upcase, last_price, change, Time.now.to_s ] #date.strftime("%Y/%m/%d %H:%M%p")]
#       rescue Errno::ETIMEDOUT, Timeout::Error, Net::HTTPNotFound, Mechanize::ResponseCodeError
# #        puts "#{symbol} - Unknown Response"
#       end       
#     return ret
#   end 
# 
# 
# desc 'Store Options and Prices'
#   task :store_options => :environment do
#   @stocks =       [ [ 'AMAT', '01/21/2022', 12800, 42.28, 57.5, 65 ],
#                   [ 'CRM', '01/21/2022', 24000, 134.31, 180.0, 200.0 ],
#                   [ 'CSCO', '01/21/2022', 63000, 39.06, 42.5, 47.5 ],
#                   [ 'INTC', '01/21/2022', 15365, 54.13, 60.0, 65.0 ],
#                   [ 'MSFT', '01/21/2022', 12110, 153.83, 190.0, 220.0 ] ]
#   @stocks.each do |s|
#    
#     call = Options.option_price(s[0], s[4], s[1], 'Call Option')
#      put = Options.option_price(s[0], s[4], s[1], 'Put Option')
#     
#     h = Grat.create ( { 
#       close_date: Date.today.strftime("%Y/%m/%d"),
#       symbol: s[0],
#       quantity: s[2],
#       cost: s[3],
#       current_price: Options.repo_price(s[0])[1],
#       call_exp_date: s[1],
#       call_strike: s[5],
#       call_bid: call['Bid'],
#       call_ask: call['Ask'],namespace :update do
#  
# 
# desc 'Store Options and Prices'
#   task :store_options => :environment do
#   @stocks =       [ [ 'AMAT', '01/21/2022', 12800, 42.28, 57.5, 65 ],
#                   [ 'CRM', '01/21/2022', 24000, 134.31, 180.0, 200.0 ],
#                   [ 'CSCO', '01/21/2022', 63000, 39.06, 42.5, 47.5 ],
#                   [ 'INTC', '01/21/2022', 15365, 54.13, 60.0, 65.0 ],
#                   [ 'MSFT', '01/21/2022', 12110, 153.83, 190.0, 220.0 ] ]
#   @stocks.each do |s|
#    
#     call = Options.option_price(s[0], s[4], s[1], 'Call Option')
#      put = Options.option_price(s[0], s[4], s[1], 'Put Option')
#     
#     h = Grat.create ( { 
#       close_date: Date.today.strftime("%Y/%m/%d"),
#       symbol: s[0],
#       quantity: s[2],
#       cost: s[3],
#       current_price: Options.repo_price(s[0])[1],
#       call_exp_date: s[1],
#       call_strike: s[5],
#       call_bid: call['Bid'],
#       call_ask: call['Ask'],
#       put_exp_date: s[1],
#       put_strike: s[4],
#       put_bid: put['Bid'],
#       put_ask: put['Ask'],
#       note: nil
#       } )
#   end 
# 
# end
# 
# def load_data  
#   
# # https://finance.yahoo.com/portfolio/p_8/view/view_4
#   
#  require 'csv'
#     file = File.open("/Users/andydenenberg/Downloads/quotes.csv")
#     data = CSV.parse(file.read)
#     puts
#     puts "Stock.delete_all"
#     puts
#     data[1..data.length].each do |s|
#     	lc = s[4] ? s[4] : 0
#     	puts "Stock.create symbol: '#{s[0]}', last_price: #{s[1]}, last_change: #{lc} "
#     end 
#     data = nil
# end
# 
# # rails g scaffold grat close_date:datetime symbol:string quantity:decimal cost:decimal current_price:decimal call_exp_date:datetime call_strike:decimal call_bid:decimal call_ask:decimal put_exp_date: datetime put_strike:decimal put_bid:decimal put_ask:decimal 
# 
# 
# end
# 
#       put_exp_date: s[1],
#       put_strike: s[4],
#       put_bid: put['Bid'],
#       put_ask: put['Ask'],
#       note: nil
#       } )
#   end 
# 
# end
# 
# def load_data  
#  require 'csv'
#     file = File.open("/Users/andydenenberg/Downloads/quotes.csv")
#     data = CSV.parse(file.read)
#     puts
#     data[1..data.length].each do |s|
#     	lc = s[4] ? s[4] : 0
#     	puts "Stock.create symbol: '#{s[0]}', last_price: #{s[1]}, last_change: #{lc} "
#     end 
# end
# 
# # rails g scaffold grat close_date:datetime symbol:string quantity:decimal cost:decimal current_price:decimal call_exp_date:datetime call_strike:decimal call_bid:decimal call_ask:decimal put_exp_date: datetime put_strike:decimal put_bid:decimal put_ask:decimal 
# 
# 
# end
