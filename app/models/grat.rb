class Grat < ApplicationRecord

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
