class ContractsController < ApplicationController

  #----------------------------------------------------------------------------
  # Set the layout
  #----------------------------------------------------------------------------
  layout 'new_agencydashboard'

  #----------------------------------------------------------------------------
  # Callback events - authenticate & only let agencies see this page
  #----------------------------------------------------------------------------
  before_filter :authenticate

  before_filter do |controller|
    controller.check_type('agency')
    controller.can_edit?('Contracts')
  end

  #----------------------------------------------------------------------------
  # View contract list
  #----------------------------------------------------------------------------
  def index

    # get the status
    @status = params[:status]

    # set it if nil
    @status = 'ACTIVE' if @status.nil?

    # set the criteria on the Navigator
    Navigator.set_position(session, :contract_list,  @status, params[:page])

    # set the solumn sorting
    @selected_column = params[:c].blank? ? 'endDate' : params[:c]

    # get the client
    @client = Client.find(params[:client_id])

    # paginate the contracts
    @contracts = @client.paginate_contracts params[:page], 25, @status, sort_order('endDate')
    
  end

  #----------------------------------------------------------------------------
  # Add the approver to the contract (after green button clicked in list)
  #----------------------------------------------------------------------------
  def save_added_approver

    # get the client
    @client = Client.find(params[:client_id])

    # get the contract
    @contract = Contract.find(params[:id])

    # get the approver
    @approver = User.find(params[:user_id])

    # add the approver to the list
    @contract.approver_users << @approver

    # save
    if @contract.save

      redirect_to edit_client_contract_path(@client, @contract)

    else

      render :action => 'add_approver'
      
    end
    
  end

  #----------------------------------------------------------------------------
  # Add an approver, from the ones available on the client to the contract
  #----------------------------------------------------------------------------
  def add_approver

    # get the client
    @client = Client.find(params[:client_id])

    # get the contract
    @contract = Contract.find(params[:id])

    # get approvers not already assigned to the contract
    @approvers = @client.unassigned_approvers_for_contract(@contract)

  end

  #----------------------------------------------------------------------------
  # Remove an approver from the contract
  #----------------------------------------------------------------------------
  def remove_approver

    # get the client
    @client = Client.find(params[:client_id])

    # get the contract
    @contract = Contract.find(params[:id])

    # find the approver
    @approver = User.find(params[:user_id])

    # double check use is an approver
    if @contract.is_approver?(@approver)

      # delete them from the list
      @contract.approver_users.delete(@approver)
      
    end
    
    redirect_to edit_client_contract_path(@client, @contract)
    
  end

  #----------------------------------------------------------------------------
  # Search for a contractor
  #----------------------------------------------------------------------------
  def contractor_search

    # get the contract
    @contract = Contract.find(params[:id])

    # get the client
    @client = @contract.client

    # double check the query
    query = params[:q]
    if query.blank? || query[0].blank?

      flash[:notice] = "You must specify a last name or email address"
      @contractors = []
      
    else

      @contractors = User.paginate :per_page => 26, :page => params[:page], :conditions => ["(lastName like ? or email = ?) and type = 'ContractorUser'", '%'+query.to_s+'%', '%'+query.to_s+'%'], :order => 'lastName'
      
    end
    
  end

  #----------------------------------------------------------------------------
  # Add a contractor to the contract
  #----------------------------------------------------------------------------
  def contractor_add

    # get the cliebt
    @client = Client.find(params[:client_id])

    # get the contract
    @contract = Contract.find(params[:id])

    # get the contractor
    @contractor = ContractorUser.find(params[:contractor_id])

    # if the contractor is not already added, add!

      @contract.contractor_user=@contractor
      @contract.save!
    redirect_to edit_client_contract_path(@client, @contract, :contracts_page => @contracts_page, :status => @status)

  end

  #----------------------------------------------------------------------------
  # Remove the contractor from the contract
  #----------------------------------------------------------------------------
  def contractor_remove

    # get the client
    @client = Client.find(params[:client_id])

    # get the contract
    @contract = Contract.find(params[:id])

    # get the contractor
    @contractor = ContractorUser.find(params[:contractor_id])

    # remove the contractor
    if @contract.is_contractor?(@contractor)

      @contract.contractor_user=nil
      @contract.save
      
    end
    
    redirect_to edit_client_contract_path(@client, @contract, :contracts_page => @contracts_page, :status => @status)
    
  end
  
  #----------------------------------------------------------------------------
  # Get ready to add a new contract
  #----------------------------------------------------------------------------
  def new

    # get the client
    @client = Client.find(params[:client_id])
 
    # get the contract
    @contract = @client.contracts.build

    # set the default margin
    @contract.margin = @client.margin

    # get the default ni_rate and hol_accrual_rate
    @ni_rate = Settings.get_setting('ni_rate', Date.today).value
    @hol_accrual_rate = Settings.get_setting('hol_accrual_rate', Date.today).value

    # create default rates
    @contract.rates.build(:name => 'Standard', :default => true, :comment => 'Default Standard Hourly Rate', :category => 'Standard', :payRate => 0.00, :chargeRate => 0.00, :contract_id => @contract.id)
    @contract.rates.build(:name => 'Overtime', :comment => 'Default Overtime Hourly Rate', :category => 'Overtime', :payRate => 0.00, :chargeRate => 0.00, :contract_id => @contract.id)
    @contract.rates.build(:name => 'Standard', :default => true, :comment => 'Default Standard Daily Rate', :category => 'Standard', :payRate => 0.00, :chargeRate => 0.00, :rateType => 'Day', :contract_id => @contract.id)

    # get the daily rate
    @daily_rate = @contract.rates.select {|r| r.rateType == 'Day'}[0]
   
    agency = Agency.find(session[:agencyId])
    @contract.calcChargeRateAsPAYE = agency.calculatePAYE?
    
  end

  #----------------------------------------------------------------------------
  # Edit the contract
  #----------------------------------------------------------------------------
  def edit

    # get the client
    @client = Client.find(params[:client_id])

    # get the contract
    @contract = Contract.find(params[:id])

    # are we allowed to delete it?
    @canDelete = @contract.timesheets.length == 0

    # set the disabled flag
    @disabled = @contract.status == 'COMPLETE'

    # set the ni_rate and hol_accrual_rate
    @ni_rate = Settings.get_setting('ni_rate', Date.today).value
    @hol_accrual_rate = Settings.get_setting('hol_accrual_rate', Date.today).value

  end

  #----------------------------------------------------------------------------
  # Search for a contractor
  #----------------------------------------------------------------------------
  def create

    # get the client
    @client = Client.find(params[:client_id])

    # build the contract
    @contract = @client.contracts.build(params[:contract])

    # remove overtime if not allowed
    if !@contract.allowOvertime?

      @contract.rates.delete_if {|r| r.category.downcase == "overtime"}

    end

    # if its a day rate the remove hourly std rate, if day remove daily std rate
    if @contract.rateType == 'Day'

      @contract.rates.delete_if {|r| r.category.downcase == "standard" && r.rateType.downcase == "hour"}
      @daily_rate = @contract.rates.select {|r| r.rateType == 'Day'}[0]
      
    else

      @contract.rates.delete_if {|r| r.category.downcase == "standard" && r.rateType.downcase == "day"}
      
    end

    # save it
    if @contract.save

      flash[:notice] = "Contract saved successfully"
      redirect_to edit_client_contract_path(@client, @contract)

    else

      # errors - get the ni_rate & hol_rate etc
      @ni_rate = Settings.get_setting('ni_rate', Date.today).value
      @hol_accrual_rate = Settings.get_setting('hol_accrual_rate', Date.today).value

      if @daily_rate.nil?

        # re add the std rate if it's nill
        @contract.rates.build(:name => 'Standard', :default => true, :comment => 'Default Standard Daily Rate', :category => 'Standard', :payRate => 0.00, :chargeRate => 0.00, :rateType => 'Day')
        @daily_rate = @contract.rates.select {|r| r.rateType == 'Day'}[0]
        
      end

      render :action => "new"
      
    end
    
  end

  #----------------------------------------------------------------------------
  # Update the contract
  #----------------------------------------------------------------------------
  def update

    # get the client
    @client = Client.find(params[:client_id])

    # get the contract
    @contract = Contract.find(params[:id])

    # upadate the attributes on the contract
    @contract.attributes = params[:contract]

    # get the timesheets
    sheets = @contract.timesheets

    if sheets.length > 0

      # update the status of the contract if necessary
      if (@contract.endDate == (sheets.maximum('startDate') + 6))

        @contract.status = "COMPLETE"

      else

        @contract.status = "ACTIVE"
        
      end

    end

    # save it
    if @contract.save

      flash[:notice] = "Contract saved successfully"
      redirect_to edit_client_contract_path(@client, @contract)

    else

      render :action => "edit"

    end

  end

  #----------------------------------------------------------------------------
  # Delete the contract
  #----------------------------------------------------------------------------
  def delete_contract

    # get the contract
    @contract = Contract.find(params[:id])

    # get the client
    @client = Client.find(@contract.client_id)

    # bye bye
    @contract.destroy

    redirect_to(client_contracts_path(@client))

  end
  
end
