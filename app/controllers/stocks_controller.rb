class StocksController < ApplicationController

  before_action :set_stock, only: [:show, :edit, :update, :destroy]

  def grats
#   @stocks =       [ [ 'AMAT', '01/21/2022', 12800, 42.28, 57.5, 65 ],
#                   [ 'CRM', '01/21/2022', 24000, 134.31, 180.0, 200.0 ],
#                   [ 'CSCO', '01/21/2022', 63000, 39.06, 42.5, 47.5 ],
#                   [ 'INTC', '01/21/2022', 15365, 54.13, 60.0, 65.0 ],
#                   [ 'MSFT', '01/21/2022', 12110, 153.83, 190.0, 220.0 ] ]

    @stocks =       [ [ 'CRM', '01/21/2022', 24000, 134.31, 180.0, 200.0 ] ]

    @prices = [ ]
    @gains = [ ]
    @options = [ ]
    @total_gain = 0
    @stocks.each do |sym|
      puts sym[2]
      quantity = sym[2]
      cost_basis = quantity * sym[3]
      symbol, price, change = repo_price(sym[0])
      @prices.push [ price, change ]
      min_gain = quantity * sym[4] - cost_basis
      min_gain_p = 100 * (min_gain / cost_basis)
      gain = quantity * price.to_f - cost_basis
      gain_p = 100 * (gain / cost_basis)
      max_gain = quantity * sym[5] - cost_basis      
      max_gain_p = 100 * (max_gain / cost_basis)
      @gains.push [ min_gain, gain, max_gain, min_gain_p, gain_p, max_gain_p ]      
      @total_gain += gain
      
      put = option_price(sym[0], sym[4], sym[1], 'Put Option')
      call = option_price(sym[0], sym[5], sym[1], 'Call Option')      
      put_entry = put['Ask'].to_d * quantity
			put_exit = put['Ask'].to_d *  quantity
      put_cost = put_entry - put_exit
      @options.push [ [ put['Bid'].to_d, put['Ask'].to_d ], [ call['Bid'].to_d, call['Ask'].to_d ], [ put_entry, put_exit, put_cost ] ]
      
    end
    

  end  
  
  def last_update
    render json: Stock.order(:updated_at).limit(1).first.updated_at
  end
  
  def quote
    @stock = Stock.find_by_symbol(params[:symbol])
    if @stock
      render json: @stock
    else 
      render json: 'not found'
    end
  end

  # GET /stocks
  # GET /stocks.json
  def index
    @stocks = Stock.all.order(:symbol)
  end

  # GET /stocks/1
  # GET /stocks/1.json
  def show
  end

  # GET /stocks/new
  def new
    @stock = Stock.new
  end

  # GET /stocks/1/edit
  def edit
  end

  # POST /stocks
  # POST /stocks.json
  def create
    @stock = Stock.new(stock_params)

    respond_to do |format|
      if @stock.save
        format.html { redirect_to @stock, notice: 'Stock was successfully created.' }
        format.json { render :show, status: :created, location: @stock }
      else
        format.html { render :new }
        format.json { render json: @stock.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /stocks/1
  # PATCH/PUT /stocks/1.json
  def update
    respond_to do |format|
      if @stock.update(stock_params)
        format.html { redirect_to @stock, notice: 'Stock was successfully updated.' }
        format.json { render :show, status: :ok, location: @stock }
      else
        format.html { render :edit }
        format.json { render json: @stock.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /stocks/1
  # DELETE /stocks/1.json
  def destroy
    @stock.destroy
    respond_to do |format|
      format.html { redirect_to stocks_url, notice: 'Stock was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_stock
      @stock = Stock.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def stock_params
      params.require(:stock).permit(:symbol, :last_price, :last_change, :last_updated)
    end
    
    def repo_price(symbol)
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
   
    # Get current Option price from yahoo
      def option_price(symbol,strike,date,stock_option)
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
  
   
    
end
