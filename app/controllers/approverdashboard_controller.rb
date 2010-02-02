class ApproverdashboardController < ApplicationController

  #----------------------------------------------------------------------------
  # Callback events - authenticate. need to be approver user
  #----------------------------------------------------------------------------
  before_filter :authenticate
  layout "new_approverdashboard"
  before_filter do |controller|
    controller.check_type('approver')
  end

  #----------------------------------------------------------------------------
  # Default view... see timesheets in need of approval
  #----------------------------------------------------------------------------
  def index

    session[:selected] = 'timesheets'

    # get the timesheets requiring approval for current user
    @timesheets = Timesheet.requiring_approval(current_user, params[:page], 10)

    # are timesheets selected
    @none_selected = params[:none_selected]
    
  end

  #----------------------------------------------------------------------------
  # Denied screen
  #----------------------------------------------------------------------------
  def denied
  end

  #----------------------------------------------------------------------------
  # View workers that the approver approves
  #----------------------------------------------------------------------------
	def workers

    session[:selected] = 'workers'
		@workers = User.get_workers_for_approver(current_user.id, params[:page], 20)
    
	end

  #----------------------------------------------------------------------------
  # View a timesheet to approve
  #----------------------------------------------------------------------------
  def view_timesheet

    @timesheet = Timesheet.find(params[:timesheet_id])
    @contract = Contract.find(@timesheet.contract_id)
    @agency = @contract.client.agency
	  @rates = @contract.rates.collect {|r| [ r.name, r.id ] unless !r.active? }
    @notes = TimesheetHistory.get_all_notes(@timesheet.id)
    
  end

  #----------------------------------------------------------------------------
  # Approve or deny timesheets in a list
  #----------------------------------------------------------------------------
  def approve_deny_timesheets

    # set the default status
    status = 'DENIED'

    # set status to approve if button clicked!
    if params[:commit] == 'Approve'

      status = 'APPROVED'
      
    end

    # get the ids of the selected timesheets
    ids = params[:ids]

    # set the date and time once!
    now = DateTime.now

    # are the ids valid?
    if !ids.nil? && ids.length > 0

      # create transaction and iterate through ids
      Timesheet.transaction do

        for id in ids

          # get the timesheet
          @timesheet = Timesheet.find(id)
          
          # only proceed if status is submitted or rejected
          if @timesheet.status == 'SUBMITTED' || @timesheet.status == 'REJECTED'

            # set the new status
            @timesheet.status = status
            @timesheet.userName = current_user.full_name
            @timesheet.note = nil
            
            # save
            @timesheet.save(false)

          end

        end

      end

    else

      flash[:alert] = 'Please select a timesheet to approve/deny'
      
    end

    redirect_to approverdashboard_path + '?none_selected=true'
    
  end

  #----------------------------------------------------------------------------
  # Approve or deny a timesheet
  #----------------------------------------------------------------------------
  def save_timesheet

    # get the timesheet
    @timesheet = Timesheet.find(params[:timesheet_id])

    # approved or denied
    if params[:commit] == 'Approve'

      @timesheet.status = 'APPROVED'

    else

      @timesheet.status = 'DENIED'
      
    end

    # set the requirements to false... for validation
    @timesheet.timesheet_entries.each {|entry|

      entry.requireTimes = false
      entry.requireFullWeek = false
      
    }

    @timesheet.userName = current_user.full_name
    @timesheet.note = params[:notes]
    
    # save it
    if @timesheet.save(false)

      redirect_to approverdashboard_path

    else

      render :view_timesheet
      
    end

  end

  #----------------------------------------------------------------------------
  # Logout
  #----------------------------------------------------------------------------
  def logout

    session[:selected] = 'exit'
    
  end

  #----------------------------------------------------------------------------
  # Update approver details
  #----------------------------------------------------------------------------
  def update_approver

    # find the user
    @approver = User.find(params[:approver_id])

    # set the attributes
    @approver.attributes = params[:user]

    # set the title and email conf
    @approver.title = params[:selected_title]
    @approver.email_confirmation = @approver.email
    @titles = ['Mr', 'Mrs', 'Miss']

    # save
    if @approver.save

      flash[:notice] = "Details saved"

    end

    render :action => "edit_approver", :controller => "approverdashboard"
    
  end

  #----------------------------------------------------------------------------
  # Prepare to edit the user
  #----------------------------------------------------------------------------
  def edit_approver

    session[:selected] = 'edit'
    @approver = User.find(params[:approver_id])
    @titles = ['Mr', 'Mrs', 'Miss']
    
  end

  #----------------------------------------------------------------------------
  # Change the users password
  #----------------------------------------------------------------------------
  def change_password

    # get the approver
    @approver = User.find(params[:user][:id])

    # set the passwords
    @approver.password = params[:user][:password]
    @approver.password_confirmation = params[:user][:password_confirmation]

    @titles = ['Mr', 'Mrs', 'Miss']
    
    if !@approver.password.blank? && !@approver.password_confirmation.blank?

      # set email confirmation
      @approver.email_confirmation = @approver.email
      @approver.only_basic_validation = true
      
      if @approver.password != @approver.password_confirmation

        flash[:alert] = 'Passwords do not match. Reset failed.'

      else

        # set reset pwd flag
        @approver.reset_password

        # save it
        if !@approver.save

          flash[:alert] = "Password reset failed"

        else

          flash[:notice] = "Password reset successfully"

        end

      end

    else

      flash[:alert] = "You must enter a new password"

    end

    render 'edit_approver', :approver_id => @approver.id

  end
  
end