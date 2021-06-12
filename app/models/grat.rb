class Grat < ApplicationRecord
  
  def self.history
    text = '<br>'
    grats = Grat.all
    remaining = [ 10724, 16271, 40213, 7770, 8245 ]
    fvm_funding = [ 582976.00, 3457800.00, 2565990.00, 882642.43, 1962304.40 ] 
    gains = [ ]
    options = [ ]
    total_gain = 0
    data = { }
    grats.each do |stock|
      current = stock.grat_stats
      gains.push current
      
      data[stock.symbol] = stock.gains
#      puts data.inspect
      
      total_gain += current[5]
#      puts stock.symbol
#      options.push stock.collar_stats

    end   
    
    daily_gain = 0
    residual_total_gain = 0
    daily_total_change = 0
    history = [ ]

    grats.each_with_index do |g,i| 
    residual_value =  gains[i][1] * ( remaining[i] - (fvm_funding[i] * 0.509009462) /  gains[i][1] )
    residual_total_gain = residual_total_gain + residual_value
    residual_shares = ( remaining[i] - (fvm_funding[i] * 0.509009462) /  gains[i][1] )
		  
		  
    daily_gain = daily_gain + gains[i][11]		  
    daily_total_change = daily_total_change + residual_shares * gains[i][2]

    text += g.symbol + "<br>"
    text += "Remaining Shares = #{remaining[i]}<br>"
    text += "Remaining Value = #{remaining[i] * gains[i][1]}<br>"
    text += "2nd yr Shares = #{( (fvm_funding[i] * 0.509009462) /  gains[i][1] )}<br>"
    text += "Residual Shares = #{residual_shares}<br>"
    text += "Residual Value = #{residual_value}<br>"
    text += "Daily Change = #{gains[i][2]  * residual_shares}<br>"
    text += "<br>"
    
    history.push [ g.symbol, remaining[i].to_s, (remaining[i] * gains[i][1]).to_s, ((fvm_funding[i] * 0.509009462) /  gains[i][1]).to_s,
             residual_shares.to_s, residual_value.to_s, (gains[i][2] * residual_shares).to_s ]
    
    
    end

    text += "<br>"
    text += "Residual Total Gain = #{ActiveSupport::NumberHelper.number_with_delimiter(residual_total_gain)}<br>"
    text += "Daily Total = #{ActiveSupport::NumberHelper.number_with_delimiter(daily_total_change)}<br>"
    text += "<br>"
    
    return [ text, history, residual_total_gain.to_s, daily_total_change.to_s ]
    
  end

  def current_price
    symbol, price, change = Options.repo_price(self.symbol)
    price = price.to_d
    change = change.to_d
    return price, change
  end

  def grat_stats
    quantity = self.quantity
    price, change = self.current_price
    cost = self.quantity * self.cost
    value = self.quantity * price
    gain = value - cost
    gain_p = 100 * (gain / cost)
    gain_change = quantity * change.to_f
    min_gain = (quantity * self.put_strike) - cost
    min_gain_p = 100 * (min_gain / cost)
    max_gain = (quantity * self.call_strike) - cost      
    max_gain_p = 100 * (max_gain / cost)
    return [ symbol, price, change, cost, value, gain, gain_p, min_gain, min_gain_p, max_gain, max_gain_p, gain_change ]
  end
  
  def gains
    gains = { }
    gains[:quantity] = self.quantity
    gains[:price], gains[:change] = self.current_price
    gains[:cost] = self.quantity * self.cost
    gains[:value] = self.quantity * gains[:price]
    gains[:gain] = gains[:value] - gains[:cost]
    gains[:gain_p] = 100 * (gains[:gain] / gains[:cost])
    gains[:gain_change] = gains[:quantity] * gains[:change]
    gains[:min_gain] = (gains[:quantity] * self.put_strike) - gains[:cost]
    gains[:min_gain_p] = 100 * (gains[:min_gain] / gains[:cost])
    gains[:max_gain] = (gains[:quantity] * self.call_strike) - gains[:cost]      
    gains[:max_gain_p] = 100 * (gains[:max_gain] / gains[:cost])
    return gains
  end
  
  def collars
    collars = { }
    collars[:quantity] = self.quantity
    put = Options.option_price(self.symbol, self.put_strike, self.put_exp_date,  'Put Option')
    call = Options.option_price(self.symbol, self.call_strike, self.call_exp_date, 'Call Option')
    collars[:put_bid] = put['Bid'].to_d
    collars[:put_ask] = put['Ask'].to_d
    collars[:put_buy] = collars[:put_ask] * quantity
		collars[:put_sale] = collars[:put_bid] * quantity
    collars[:call_bid] = call['Bid'].to_d
    collars[:call_ask] = call['Ask'].to_d
    collars[:call_sale] = collars[:call_bid] * quantity
    collars[:call_buy] = collars[:call_ask] * quantity
    collars[:collar_cost] = collars[:call_sale] - collars[:put_buy]
    collars[:collar_value] = collars[:put_sale] - collars[:call_buy]
    collars[:collar_net] = collars[:collar_value] - collars[:collar_cost]  
    return collars
  end
  
  def collar_stats
    quantity = self.quantity
    put = Options.option_price(self.symbol, self.put_strike, self.put_exp_date,  'Put Option')
    call = Options.option_price(self.symbol, self.call_strike, self.call_exp_date, 'Call Option')
    put_buy = put['Ask'].to_d * quantity
		put_sale = put['Bid'].to_d * quantity
    call_sale = call['Bid'].to_d * quantity
    call_buy = call['Ask'].to_d * quantity
    collar_cost = call_sale - put_buy
    collar_value = put_sale - call_buy
    collar_net = collar_value - collar_cost
    return [ put['Bid'].to_d, put['Ask'].to_d, call['Bid'].to_d, call['Ask'].to_d, collar_cost, collar_value, collar_net ]
  end
  
end
