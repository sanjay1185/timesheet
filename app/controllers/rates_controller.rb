class RatesController < ApplicationController
  
  #----------------------------------------------------------------------------
  # Set the layout
  #----------------------------------------------------------------------------
  layout 'agency'

  #----------------------------------------------------------------------------
  # Callback events - authenticate & only let agencies see this page
  #----------------------------------------------------------------------------
  before_filter :authenticate

  before_filter do |controller|
    controller.check_type('agency')
    controller.check_role('Rates')
    controller.can_edit?('Rates')
  end

  #----------------------------------------------------------------------------
  # View a list of all rates for a particular contract
  #----------------------------------------------------------------------------
  def index
    
    # set the query order
    @selected_column = params[:c].blank? ? '`default`' : params[:c]

    # get the client & contract
    @client, @contract = get_client_and_contract(params[:client_id],params[:contract_id])

    # paginate the rates
    @rates = @contract.rates.paginate(:page => params[:page], :per_page => 25, :order => sort_order('`default`'))

    logger.info("Rates readonly = #{@readonly}")
    
  end

  #----------------------------------------------------------------------------
  # Create a new rate for a contract
  #----------------------------------------------------------------------------
  def new

    # get the client & contract
    @client, @contract = get_client_and_contract(params[:client_id],params[:contract_id])

    # create the new rate
    @rate = Rate.new

    # set the default ni_rate and hol_accrual_rate
    @ni_rate = Settings.get_setting('ni_rate', Date.today).value
    @hol_accrual_rate = Settings.get_setting('hol_accrual_rate', Date.today).value

    # define a list of rates for the drop down
    @rates_list = {'Overtime' => 'Overtime', 'Bank Holiday' => 'Bank Holiday', 'Sickness' => 'Sickness', 'Other' => 'Other'}

  end

  #----------------------------------------------------------------------------
  # Edit a rate
  #----------------------------------------------------------------------------
  def edit

    # get the client & contract
    @client, @contract = get_client_and_contract(params[:client_id],params[:contract_id])

    # get the rate
    @rate = Rate.find(params[:id])

    # set the default ni_rate and hol_accrual_rate
    @ni_rate = Settings.get_setting('ni_rate', Date.today).value
    @hol_accrual_rate = Settings.get_setting('hol_accrual_rate', Date.today).value

    # define a list of rates for the drop down
    @rates_list = {'Standard' => 'Standard', 'Overtime' => 'Overtime', 'Bank Holiday' => 'Bank Holiday', 'Sickness' => 'Sickness', 'Other' => 'Other'}
    
  end


  #----------------------------------------------------------------------------
  # Create a new rate
  #----------------------------------------------------------------------------
  def create

    # get the client & contract
    @client, @contract = get_client_and_contract(params[:client_id],params[:contract_id])

    # build the rate
    @rate = @contract.rates.build(params[:rate])

    # parse the dates
    @rate.effectiveDate = Date.parse(params[:effective_date]) unless params[:effective_date].blank?
    @rate.endDate = Date.parse(params[:end_date]) unless params[:end_date].blank?

    if @rate.save

      redirect_to(client_contract_rates_path(@client))

    else

      # define the list of rates
      @rates_list = {'Overtime' => 'Overtime', 'Bank Holiday' => 'Bank Holiday', 'Sickness' => 'Sickness', 'Other' => 'Other'}

      render :action => "new"
      
    end
    
  end

  #----------------------------------------------------------------------------
  # Update a rate
  #----------------------------------------------------------------------------
  def update

    # get the client & contract
    @client, @contract = get_client_and_contract(params[:client_id],params[:contract_id])

    # get the rate
    @rate = Rate.find(params[:id])

    # update the attributes
    @rate.attributes = params[:rate]

    # set the rate type
    @rate.rateType = params[:rate_type] unless params[:rate_type].blank?

    # parse the dates
    @rate.effectiveDate = Date.parse(params[:effective_date]) unless params[:effective_date].blank?
    @rate.endDate = Date.parse(params[:end_date]) unless params[:end_date].blank?
        
    if @rate.save

      redirect_to(client_contract_rates_path(@client))

    else

      @rates_list = {'Standard' => 'Standard', 'Overtime' => 'Overtime', 'Bank Holiday' => 'Bank Holiday', 'Sickness' => 'Sickness', 'Other' => 'Other'}

      # remove Standard rate if not a default rate
      @rate_list.delete_if {|k,v| k == 'Standard' && !@rate.default?}

      render :action => "edit"
      
    end

  end

  #----------------------------------------------------------------------------
  # Delete a rate
  #----------------------------------------------------------------------------
  def delete_rate

    # get the rate
    @rate = Rate.find(params[:id])

    # get the client & contract
    @client, @contract = get_client_and_contract(params[:client_id],params[:contract_id])

    # bye bye rate
    @rate.destroy
    
    redirect_to(client_contract_rates_path(@client, @contract))

  end

private

  #----------------------------------------------------------------------------
  # Get the client and contract
  #----------------------------------------------------------------------------
  def get_client_and_contract(client_id, contract_id)

    # get the contract
    @contract = Contract.find(contract_id)

    # get the client
    @client = Client.find(client_id)

    return @client, @contract

  end
  
end