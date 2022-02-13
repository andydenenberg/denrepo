# namespace :cboe do
#  task :options => :environment do

module Options
  require 'csv'
  require 'open-uri'
  
  def self.refresh_prices
    Stock.all.each_with_index do |s,i|
      puts s.symbol
      q = self.yfinance_quote(s.symbol)
      if q.count(nil) == 0
        s.last_price = q[1]
        s.last_change = q[3]
        puts "#{s.symbol},%0.2f" % s.last_price
        s.save
      end
    end
  end
  
  def self.test_loop
    Stock.all.each_with_index do |s,i|
      q = self.yfinance_quote(s.symbol)
      if q[1].nil?
        puts "#{s.symbol}, nil, #{s.last_price}, nil"
      else
        puts "#{s.symbol},%0.2f" % (s.last_price.to_d-q[1].to_d).to_s + ",#{s.last_price}" + ",%0.2f" % q[1]
#        puts "#{s.symbol} - repo:#{s.last_price} yfinance:#{q[1]} diff:#{s.last_price-q[1]}"
      end
    end
  end
  
  def self.yfinance_option_quote # (symbol, option_type, expiration_date, strike)
    #    MSFT Feb 2022 145.000 call
    #    MSFT
    #   220218
    #    C
    #    00145000
    html = open("https://query2.finance.yahoo.com/v7/finance/options/MSFT220218C00145000", 'User-Agent' => 'Mozilla').read
    data = JSON.parse(html)
    bid, ask = nil, nil
    if data["option_Chain"]["result"].length > 0
      bid = data["option_Chain"]["result"].first["quote"]["bid"]
      ask = data["option_Chain"]["result"].first["quote"]["ask"]
    end
    return bid, ask, data   
  end

  def self.yfinance_quote(symbol)
    html = open("https://query2.finance.yahoo.com/v8/finance/chart/#{symbol}", 'User-Agent' => 'Mozilla').read
    data = JSON.parse(html)
    time, last, open, change = nil, nil, nil, nil
    if !data["chart"]['result'].first["timestamp"].nil? # check if there is any chart data
      time = (Time.at(data["chart"]['result'].first["timestamp"].last) - 6.hours).to_datetime.strftime("%m/%d/%Y %I:%M%p")
      last = data["chart"]['result'].first["indicators"]["quote"].last["close"].last 
      open = data["chart"]['result'].first["indicators"]["quote"].last["open"].first 
      if !(last.nil? || open.nil?)
        change = last - open 
      end
    end
#    puts "#{date} - #{close}"
    return time, last, open, change
# gather and pair the minute by minute values
#    data["chart"]['result'].first["timestamp"].each_with_index { |d,i|
#    puts "#{(Time.at(d) - 6.hours).to_datetime.strftime('%m/%d/%Y %I:%M %p')} - #{data['chart']['result'].first['indicators']['quote'].last['close'][i]}"
#    }

  end


def self.validate_ydata
  validation = ''
  starting = Time.now  
    Stock.all.each_with_index do |s,i| 
      if ![ 'VMFXX', 'SWVXX', 'SNVXX', 'SNAXX', 'OGVXX', 'AAPL210115C00520000' ].include? s.symbol
  #      puts s.symbol
        data = Options.ydata_price(s.symbol)
        repo_price = Stock.find_by_symbol(s.symbol).last_price
        repo_change = Stock.find_by_symbol(s.symbol).last_change
        et = starting - Time.now
        v = "#{i}, #{et}, #{data.first}, #{data[1]}, #{repo_price}, #{data[2]}, #{repo_change}\n"
         validation += v
         puts v
       
  #      puts "#{data.first}, #{data[1]},  #{data.last}"
      else
        puts "#{s.symbol}, 'skipped', skipped' "
      end
    end
    puts validation  
end  
  
#  def self.refresh_prices 
#    Stock.all.each_with_index do |s,i| 
#      puts "#{i} - #{s.symbol}"
#      if ![ 'VMFXX', 'SWVXX', 'SNVXX', 'SNAXX', 'OGVXX', 'AAPL210115C00520000' ].include? s.symbol
#        #data = Options.ydata_price(s.symbol)
#        data = Options.yfinance_quote(s.symbol)
#        
#        if data.length == 2 # successful retrieval from Yahoo
#          s.last_price = data[0].to_d
#          s.last_change = data[2].to_d
#        end
#      else
#        s.last_price = 1.0
#        s.last_change = 0.0
#      end
#      s.last_updated = Date.today
#      s.save
#    end        
#  end
  
  def self.ydata_price(symbol)
    data = stockquote(symbol)
    if data[1] == '0.0'
      data = fundquote(symbol)
    end
    return data
  end
  
 
  def self.fundquote(symbol = 'LQD')
    @agent = Mechanize.new { |agent|
      agent.open_timeout   = 20
      agent.read_timeout   = 20
    }
    url = "https://finance.yahoo.com/quote/#{symbol}?p=#{symbol}"
    begin
      page = @agent.get(url)
      price = page.css('[data-reactid="33"]')[2].text
      change = page.css('[data-reactid="34"]')[2].text.split('(').first.strip #gsub('+','').gsub('-','').strip
  #		puts "#{symbol} - $#{price}  #{change}"
    rescue Errno::ETIMEDOUT, Timeout::Error, Net::HTTPNotFound, Mechanize::ResponseCodeError
      puts "\n\nsymbol:#{symbol} - The request timed out...skipping.\n\n"
      return ["The request timed out...skipping."]
    rescue => e
      puts "\n\nsymbol:#{symbol} - The request returned an error - #{e.inspect}.\n\n"
      return ["The request returned an error - #{e.inspect}."]
    end     
      
    return [ symbol, price, change ]
  #    q = "#{price} #{change}"
  #    puts q
  end


  def self.stockquote(symbol='MSFT')
    @agent = Mechanize.new { |agent|
      agent.open_timeout   = 20
      agent.read_timeout   = 20
    }
    url = "https://finance.yahoo.com/quote/#{symbol}?p=#{symbol}"
    begin
      page = @agent.get(url)
      price = page.css('[data-reactid="50"]').first.text.gsub(',','').to_d.to_s
      if price == '9.0'
        puts "\n\n\n\ 9.0 \n\n\n"
        return '9.0' # unknown reason why price is sometimes returned as 9.0
      end
      change = page.css('[data-reactid="51"]')[2].text.split('(').first.gsub('+','').strip #gsub('-','').strip
  #    puts "#{symbol} - $#{price}  #{change}"
    rescue Errno::ETIMEDOUT, Timeout::Error, Net::HTTPNotFound, Mechanize::ResponseCodeError
      puts "\n\nsymbol:#{symbol} - The request timed out...skipping.\n\n"
      return ["The request timed out...skipping."]
    rescue => e
      puts "\n\nsymbol:#{symbol} - The request returned an error - #{e.inspect}.\n\n"
      return ["The request returned an error - #{e.inspect}."]
    end     
  
      return [ symbol, price, change ]
  #    q = "#{price} #{change}"
  #    puts q
  end


# HLEMX
# MSFT 
  def self.finviz_quote
  	@agent = Mechanize.new
  	Stock.all.each do |s|
     symbol = s.symbol
#symbol = 'HLEMX'
  		url = "https://finviz.com/quote.ashx?t=#{symbol}"
  	    begin
  			page = @agent.get(url)
  			price = page.xpath('//td[@class="snapshot-td2"]')
  			prev_close = price[59].text.to_d
  			current_price = price[65].text.to_d
  			change = current_price - prev_close
  			puts "#{symbol} - $#{current_price}  #{change}"
  		rescue Errno::ETIMEDOUT, Timeout::Error, Net::HTTPNotFound, Mechanize::ResponseCodeError
        puts "#{symbol} - error retrieving quote"
  		end       
  	end
  end


  def self.yp_test(n,delay=0)
  	total_count = 0
  	stocks = Stock.where(stock_option: 'Fund').collect { |s| s.symbol }
  	for i in 0..n
  		stocks.each do |s|
  		  sleep delay
  		  total_count += 1
  			puts "#{i}:#{total_count} #{s}"
			  results = Options.yahoo_price(s)
  		end
  	end
  end
  
  def self.yahoo_price(symbol)
    results = Options.y_price(symbol)
			if results.count != 4
			  iteration = 0
				loop do 
				  iteration += 1 
				  puts "#{symbol}: iteration:#{iteration}"
				  results = Options.y_price(symbol)
				  break if results.count == 4 or iteration > 5
				end
		  end
		return results
  end
  
  def self.repo_price(symbol)
    @agent = Mechanize.new { |agent|
      agent.open_timeout   = 20
      agent.read_timeout   = 20
    }
    url = "https://denrepo.herokuapp.com/quote?symbol=#{symbol}"   
    begin
      page = @agent.get(url)  
      quote = JSON.parse(page.body) 
  	  price = quote['last_price']
  	  change = quote['last_change']
    rescue Errno::ETIMEDOUT, Timeout::Error, Net::HTTPNotFound, Mechanize::ResponseCodeError
      puts "\n\nsymbol:#{symbol} - The request timed out...skipping.\n\n"
      return ["The request timed out...skipping."]
    rescue => e
      puts "\n\nsymbol:#{symbol} - The request returned an error - #{e.inspect}.\n\n"
      return ["The request returned an error - #{e.inspect}."]
    end     
    return [ symbol.upcase, price.to_s, change.to_s, Time.now.to_s ] #.strftime("%Y/%m/%d %H:%M%p") ]           
     
  end
  
  def self.y_price(symbol)     
    @agent = Mechanize.new { |agent|
      agent.open_timeout   = 20
      agent.read_timeout   = 20
    }
    url = "http://finance.yahoo.com/quote/#{symbol}?p=#{symbol}"

#    url = "http://finance.yahoo.com/quote/VITSX?p=VITSX"
#    url = "http://finance.yahoo.com/quote/SWVXX?p=SWVXX"

    begin
      page = @agent.get(url)  
      doc = Nokogiri::HTML(page.body) 
      price = page.xpath('.//span[contains(@class,"Trsdu(0.3s) Fw(b)")]//text()')
      change = page.xpath('.//span[contains(@class,"Trsdu(0.3s) Fw(500)")]//text()') # Pstart(10px) Fz(24px)
      
      change = change.empty? ? 0.to_s : change.to_s.split('(')[0]
      # added 02/08/2019 - compensates for missing change field in yahoo display of price and change 
      
    rescue Errno::ETIMEDOUT, Timeout::Error, Net::HTTPNotFound, Mechanize::ResponseCodeError
      puts "\n\nsymbol:#{symbol} - The request timed out...skipping.\n\n"
      return ["The request timed out...skipping."]
    rescue => e
      puts "\n\nsymbol:#{symbol} - The request returned an error - #{e.inspect}.\n\n"
      return ["The request returned an error - #{e.inspect}."]
    end     
    return [ symbol.upcase, price.to_s, change.to_s.split('(')[0], Time.now.to_s ] #.strftime("%Y/%m/%d %H:%M%p") ]       
  end  
  
  
  def self.yahoo_summary(symbol)     
    @agent = Mechanize.new 
    url = "http://finance.yahoo.com/quote/#{symbol}?p=#{symbol}"
    begin
      page = @agent.get(url)  
      doc = Nokogiri::HTML(page.body) 
      keys = page.xpath('.//td[contains(@class,"C(black)")]//text()')
      values = page.xpath('.//td[contains(@class,"Ta(end)")]//text()')
      data = [ ]
      keys.each_with_index do |key, i| 
        data += [ key.to_s + ': ' + values[i].to_s ]
      end
      data.each do |d|
        puts d
      end
    rescue Errno::ETIMEDOUT, Timeout::Error, Net::HTTPNotFound, Mechanize::ResponseCodeError
      return ["The request timed out...skipping."]
    rescue => e
      return ["The request returned an error - #{e.inspect}."]
    end     
    return nil         
  end  
  
  
  def self.stock_price(symbol)  
    url = "https://api.iextrading.com/1.0/stock/#{symbol.upcase}/quote" 
    @agent = Mechanize.new
    ret = [ ]
      begin
        page = @agent.get(url)
        data = JSON.parse(page.body) 
        
        #puts data
        
        last_price = data['latestPrice'].to_s
        change = data["change"].to_s
        time = data["latestTime"]
        date = Time.parse(time) - 1.hour
        puts time
        
        ret = [symbol.upcase, last_price, change, Time.now.to_s ] #date.strftime("%Y/%m/%d %H:%M%p")]
      rescue Errno::ETIMEDOUT, Timeout::Error, Net::HTTPNotFound, Mechanize::ResponseCodeError
#        puts "#{symbol} - Unknown Response"
      end       
    return ret
  end 
    
 
# Get current Option price from yahoo
  def self.option_price(symbol,strike,date,stock_option)
    require "net/http"
    require "uri"
    require 'rubygems'
    require 'mechanize'
    require 'json'
    require 'nokogiri'

    @agent = Mechanize.new 
     format_date =  date[8..9] + date[0..1] + date[3..4] 
     format_strike = "%08d" % ActionController::Base.helpers.number_with_precision(strike, precision: 3).to_s.split('.').join
     type = stock_option == 'Call Option' ? 'C' : 'P'     

     url = "https://finance.yahoo.com/quote/#{symbol.upcase}#{format_date}#{type}#{format_strike}/news?p=#{symbol.upcase}#{format_date}#{type}#{format_strike}"    
#     puts url

     doc = ''
     ask = ''
     bid = ''
     previous_close = ''
     
      loop do 
        begin
          page = @agent.get(url)
        rescue Errno::ETIMEDOUT, Timeout::Error, Net::HTTPNotFound, Mechanize::ResponseCodeError
          puts '\n\n\nRetrying...\n\n\n'
          page = @agent.get(url)
        end  
        payload = page.body    
        doc = Nokogiri::HTML(payload)
#        ask = doc.xpath('//td[@class="Ta(end) Fw(b)"]/text()')[3].to_s
#        ask = doc.xpath('//td[@class="Ta(end) Fw(b) Lh(14px)"]')[3].to_s.split('data-reactid="55">').last.split('</span>').first.split('>').last.split('><').last.split('>').last
        bid = doc.xpath("//td[@data-test='BID-value']//span").text
        ask = doc.xpath("//td[@data-test='ASK-value']//span").text
        previous_close = doc.xpath("//td[@data-test='PREV_CLOSE-value']//span").text

      break if !ask.empty?
      end
        
#        previous_close = doc.xpath('//td[@class="Ta(end) Fw(b)"]/text()')[0].to_s
#        bid = doc.xpath('//td[@class="Ta(end) Fw(b)"]/text()')[2].to_s
#        previous_close = doc.xpath('//td[@class="Ta(end) Fw(b) Lh(14px)"]')[0].to_s.split('data-reactid="40">').last.split('</span>').first.split('>').last.split('><').last.split('>').last
#        bid = doc.xpath('//td[@class="Ta(end) Fw(b) Lh(14px)"]')[2].to_s.split('data-reactid="50">').last.split('</span>').first.split('>').last
        time = doc.search("[text()*='EST']").first.to_s.split('">').last[5..-1].split('EST').first.strip
        date = Date.today.strftime("%Y/%m/%d")
        date = date + ' ' + time                
#        puts "bid: #{bid} ask: #{ask} prev: #{previous_close}"              
#        return { 'Time' => Time.parse(date).strftime("%Y/%m/%d %H:%M%p"), 'Bid' => bid, 'Ask' => ask, 'Previous_Close' => previous_close }
        return { 'Time' => Time.now.to_s, 'Bid' => bid, 'Ask' => ask, 'Previous_Close' => previous_close }
  end
  

    def self.get_dividends(symbol)
      url = "https://api.iextrading.com/1.0/stock/#{symbol.upcase}/dividends/1y" 
      @agent = Mechanize.new
      data = {}
        begin
          page = @agent.get(url)
          response = page.body
          data = JSON.parse(response).collect { |d| [ d['exDate'], d['amount'] ] }
        rescue Errno::ETIMEDOUT, Timeout::Error, Net::HTTPNotFound, Mechanize::ResponseCodeError
        end       
      return data
    end

  def self.yahoo_dividends(symbol)  
      #  https://finance.yahoo.com/quote/SPY/history?period1=1494651600&period2=1526187600&interval=div%7Csplit&filter=div&frequency=1mo
      period1 = (Time.now-1.year).to_i
      period2 = (Time.now).to_i
      interval = "div%7Csplit" # "div|split"
      filter = "div"
      frequency = "1mo"

      url = "https://finance.yahoo.com/quote/#{symbol}/history?period1=#{period1}&period2=#{period2}&interval=#{interval}" +
            "&filter=#{filter}&frequency=#{frequency}" 
            
      @agent = Mechanize.new 
#            loop do 
              begin
                page = @agent.get(url)
              rescue Errno::ETIMEDOUT, Timeout::Error, Net::HTTPNotFound, Mechanize::ResponseCodeError
                puts '\n\n\nRetrying...\n\n\n'
                page = @agent.get(url)
              end  
              payload = page.body    
              doc = Nokogiri::HTML(payload)
      #        ask = doc.xpath('//td[@class="Ta(end) Fw(b)"]/text()')[3].to_s
                dates = []
                doc.xpath('//table[@class="W(100%) M(0)"]//tr//td//span').collect { |d| d }.each do |date|
                  begin
                     d = Date.parse(date.to_s.split('>').last.split('<').first).to_s
                     dates.push(d)
                  rescue
                  end
                end
                amounts = []
                doc.xpath('//table[@class="W(100%) M(0)"]//tr//td//strong').each do |amount|
                  begin
                    v = amount.to_s.split('>').last.split('<').first
                     amounts.push(v.to_f)
                  rescue
                  end
                end
            divs = [ ]    
            dates.each_with_index do |d,i|
             divs.push [ d, amounts[i] ]
            end
            return divs
      
  end



end
