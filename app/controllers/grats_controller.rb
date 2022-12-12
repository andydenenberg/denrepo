class GratsController < ApplicationController
  before_action :set_grat, only: [:show, :edit, :update, :destroy]

  def status
    @grats = Grat.all
    @remaining = [ 10724, 16271, 40213, 7770, 8245 ]
    @fvm_funding = [ 582976.00, 3457800.00, 2565990.00, 882642.43, 1962304.40 ] 
    @gains = [ ]
    @options = [ ]
    @total_gain = 0
    @total_loss = 0
    @data = { }
    @grats.each do |stock|
      current = stock.grat_stats
      @gains.push current
      
      @data[stock.symbol] = stock.gains
#      puts @data.inspect
      
      
      if current[5] > 0 # losses don't offset
        @total_gain += current[5]
      else
        @total_loss += current[5]
      end
#      puts stock.symbol
#      @options.push stock.collar_stats

    end    
    
    h = Grat.history
    puts h
       
  end
  
  # GET /grats
  # GET /grats.json
  def index
    @grats = Grat.all
  end

  # GET /grats/1
  # GET /grats/1.json
  def show
  end

  # GET /grats/new
  def new
    @grat = Grat.new
  end

  # GET /grats/1/edit
  def edit
  end

  # POST /grats
  # POST /grats.json
  def create
    @grat = Grat.new(grat_params)

    respond_to do |format|
      if @grat.save
        format.html { redirect_to @grat, notice: 'Grat was successfully created.' }
        format.json { render :show, status: :created, location: @grat }
      else
        format.html { render :new }
        format.json { render json: @grat.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /grats/1
  # PATCH/PUT /grats/1.json
  def update
    respond_to do |format|
      if @grat.update(grat_params)
        format.html { redirect_to @grat, notice: 'Grat was successfully updated.' }
        format.json { render :show, status: :ok, location: @grat }
      else
        format.html { render :edit }
        format.json { render json: @grat.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /grats/1
  # DELETE /grats/1.json
  def destroy
    @grat.destroy
    respond_to do |format|
      format.html { redirect_to grats_url, notice: 'Grat was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_grat
      @grat = Grat.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def grat_params
      params.require(:grat).permit(:close_date, :symbol, :quantity, :cost, :current_price, :call_exp_date, :call_strike, :call_bid, :call_ask, :put_exp_date, :note, :put_strike, :put_bid, :put_ask)
    end
        
end
