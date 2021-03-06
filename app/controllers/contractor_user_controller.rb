class ContractorUserController < ApplicationController

  #----------------------------------------------------------------------------
  # Set the layout
  #----------------------------------------------------------------------------
  layout 'new_contractor_dashboard'

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
    @contractor = current_user
    
  end

  #----------------------------------------------------------------------------
  # Update contractor details
  #----------------------------------------------------------------------------
  def update

    # get the contractor
    @contractor = ContractorUser.find(params[:contractor_user][:user][:contractor_id])

    # update attributes
    @contractor.attributes = params[:contractor]

    # set title
    @contractor.title = params[:selected_title]

    # set email confirmation
    @contractor.email_confirmation = @contractor.email

    # save
    if @contractor.save!

      flash[:notice] = "Details saved successfully"

    end

    redirect_to edit_contractor_user_path(@contractor)

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
