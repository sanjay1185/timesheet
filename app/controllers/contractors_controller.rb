class ContractorsController < ApplicationController

  #----------------------------------------------------------------------------
  # Set the layout
  #----------------------------------------------------------------------------
  layout 'contractordashboard'

  #----------------------------------------------------------------------------
  # Callback events - authenticate & only let contractors see this page
  #----------------------------------------------------------------------------
  before_filter :authenticate

  before_filter do |controller|
    controller.check_type('contractor')
  end

  #----------------------------------------------------------------------------
  # Edit contractor details 
  #----------------------------------------------------------------------------
  def edit

    session[:selected] = 'my_details'
    @contractor = Contractor.find(params[:id])
    
  end

  #----------------------------------------------------------------------------
  # Update contractor details
  #----------------------------------------------------------------------------
  def update

    # get the contractor
    @contractor = Contractor.find(params[:contractor][:user_attributes][:contractor_id])

    # update attributes
    @contractor.attributes = params[:contractor]

    # set title
    @contractor.user.title = params[:selected_title]

    # set email confirmation
    @contractor.user.email_confirmation = @contractor.user.email

    # save
    if @contractor.save

      flash[:notice] = "Details saved successfully"

    end

    redirect_to edit_contractor_path(@contractor)

  end

  #----------------------------------------------------------------------------
  # Get current contracts for contractor
  #----------------------------------------------------------------------------
  def contracts

    @contractor = Contractor.find(params[:id])
    @contracts = @contractor.contracts.select {|c| c.status == 'INACTIVE' || c.status == 'ACTIVE'}
    
  end

  #----------------------------------------------------------------------------
  # Not allowed to view this page
  #----------------------------------------------------------------------------
  def denied
  end

  #----------------------------------------------------------------------------
  # Log out!
  #----------------------------------------------------------------------------
  def logout

    session[:selected] = 'exit'
    
  end
  
end
