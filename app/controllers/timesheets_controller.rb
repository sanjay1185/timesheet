class TimesheetsController < ApplicationController
  
  #----------------------------------------------------------------------------
  # Set the layout
  #----------------------------------------------------------------------------
  layout :timesheet_layout
  
  #----------------------------------------------------------------------------
  # Callback events - authenticate & various permissions
  #----------------------------------------------------------------------------
  before_filter :authenticate
  
  before_filter :except => [:index, :view, :reject_timesheet, :manual_approval, :approve] do |controller|
    controller.check_type('contractor')
  end
  
  before_filter :only => [:index, :view, :reject_timesheet, :manual_approval, :approve] do |controller|
    controller.check_type('agency')
  end
  
  #----------------------------------------------------------------------------
  # Get timesheets for a contract (Edit Contract | View Timesheets)
  #----------------------------------------------------------------------------
  def index
    
    # get the contract
    @contract = Contract.find(params[:contract_id])
    
    # get the client
    @client = Client.find(@contract.client_id)
    
    # column sorting
    @selected_column = params[:c].blank? ? 'startDate' : params[:c]
    
    # get the timesheets
    @timesheets = @contract.timesheets.paginate(:page => params[:page], :per_page => 20, :order => sort_order('startDate'))
    
    # set the navigator
    Navigator.set_position(session, :timesheet_list, params[:page])
    
    render :layout => 'agency'
    
  end
  
  #----------------------------------------------------------------------------
  # Show dialog for manual approval
  #----------------------------------------------------------------------------
  def manual_approval
    
    @id = params[:id]
    @back_url = params[:back_url]
 
    render :layout => 'none'
    
  end
  
  #----------------------------------------------------------------------------
  # Perform manual approval
  #----------------------------------------------------------------------------
  def approve
  
    timesheet = Timesheet.find(params[:id])
    timesheet.userName = params[:approver]
    timesheet.status = 'APPROVED'
    timesheet.note = "Manually approved. Updated by " + current_user.full_name
    timesheet.save(false)
    redirect_to params[:back_url]
    
  end
  
  #----------------------------------------------------------------------------
  # Agency is rejecting a contract
  #----------------------------------------------------------------------------
  def reject_timesheet
    
    # get the agency
    @agency = Agency.find(session[:agencyId])
    
    # get the timesheet
    @timesheet = Timesheet.find(params[:id])
    
    # get the contract
    @contract = @timesheet.contract
    
    # get the contract
    @client = @contract.client
    
    # set the status
    @timesheet.status = "REJECTED"
    @timesheet.note = params[:notes]
    
    # save it
    @timesheet.save(false)
    
    render :action => 'view', :layout => 'agencydashboard'
    
  end
  
  #----------------------------------------------------------------------------
  # Prepare a new timesheet!
  #----------------------------------------------------------------------------
  def prepare
    
    # set the contractor
    @contractor = current_user.contractor
    
    # get the contracts
    contracts = @contractor.current_contracts
    
    # set the contract id (from list of contracts or from single valid contract)
    @contractId = contracts.length == 1 ? contracts[0].id : params['contract_obj']['contract_id']
    
    # create the rates manager & set contract & get approvers
    rates_manager = RatesManager.new(@contractId)
    @contract = rates_manager.contract
    @approvers = @contract.users
    
    # get the agency
    @agency = @contract.client.agency
    
    # define the colspan
    @input_section_colspan = @contract.rateType == 'Day' ? 7 : 6
    
    # disable submit?
    set_submit_button(@contract.users.length)
    
    # create a timesheet
    @timesheet = @contractor.timesheets.build
    # set the contract id
    @timesheet.contract_id = @contractId
    # set the rate type from the contract
    @timesheet.rateType = @contract.rateType
    # set the contract
    @timesheet.contract = rates_manager.contract
    # set the status
    @timesheet.status = 'DRAFT'
    
    # get the last timesheet for this contract so we can set the date!
    last_timesheet = @contract.last_timesheet
    
    # set the start date
    @timesheet.startDate = last_timesheet.nil? ? @contract.startDate : last_timesheet.startDate + 7
    
    # identify the unpaid rate
    unpaid_rate = rates_manager.get_unpaid_rate
    std_rate = rates_manager.get_default_standard_rate
    
    # setup the entries
    for d in 0..6
      
      # create it
      @ts_entry = @timesheet.timesheet_entries.build
      # set the date
      @ts_entry.dateValue = @timesheet.startDate + d
      # set the rate type
      @ts_entry.rateType = @contract.rateType
      # set the requirements
      @ts_entry.requireFullWeek = @contract.requireFullWeek
      @ts_entry.requireTimes = @contract.requireTimes
      
      # set rate to standard
      @ts_entry.rate_id = std_rate.id
      
      # if it's a weekend - set the rate to unpaid
      if @ts_entry.dateValue.wday == 0 || @ts_entry.dateValue.wday == 6
        @ts_entry.rate_id = unpaid_rate.id
      end
      
      # if it's a bank holiday, set the rate to unpaid
      if BankHoliday.is_holiday(@ts_entry.dateValue, 'UK')
        @ts_entry.is_bank_hol = true
        @ts_entry.rate_id = unpaid_rate.id
      else
        @ts_entry.is_bank_hol = false
      end
      
      # check for date after contract end date and disable
      @ts_entry.disabled = true if @ts_entry.dateValue > @contract.endDate
      
      # get the rates for Day and Hour
      @day_rates = rates_manager.get_valid_rates_by_type(@timesheet.startDate, @timesheet.startDate + 6, 'Day').collect {|r| [ r.name, r.id ] }
      @hour_rates = rates_manager.get_valid_rates_by_type(@timesheet.startDate, @timesheet.startDate + 6, 'Hour', @timesheet.rateType == 'Day').collect {|r| [ r.name, r.id ] }
      
    end
    
  end
  
  #----------------------------------------------------------------------------
  # View a timesheet (For agency - from contract | view timesheets!)
  #----------------------------------------------------------------------------
  def view
    
    # get the timesheet
    @timesheet = Timesheet.find(params[:id])
    
    # get the contract
    @contract = @timesheet.contract
    
    # get the client
    @client = @contract.client
    
    # get the url we came from
    @list_url = contract_timesheets_path(@contract, :page => Navigator.get_position(session, :timesheet_list))
    
    # are we allowed to reject it?
    @can_reject = @timesheet.status == 'APPROVED' || @timesheet.status == 'MANUAL'
    
    render :layout => 'agencydashboard'
    
  end
  
  #----------------------------------------------------------------------------
  # Get the list of timesheets for the contractor
  #----------------------------------------------------------------------------
  def list_current_for_contractor
    
    # get the contractor
    @contractor = current_user.contractor
    
    # get the date period
    @selected_date_period = params[:date_period].nil? ? '1' : params[:date_period]
    
    # get the status
    @selected_timesheet_status = params[:timesheet_status].nil? ? 'Outstanding' : params[:timesheet_status]
    
    # set the navigator
    Navigator.set_position(session, :contractor_timesheets, @selected_date_period, @selected_timesheet_status, params[:page])
    
    # get the timesheets
    @timesheets = Timesheet.current_for_contractor(@contractor, @selected_timesheet_status, @selected_date_period, params[:page], 10)
    
    # get the current contracts (so we know whether to add a 'create timesheet' button or not)
    @contracts = @contractor.current_contracts
    @contractID = nil
    
  end
  
  #----------------------------------------------------------------------------
  # Edit a timesheet
  #----------------------------------------------------------------------------
  def edit
    
    # get the timesheet
    @timesheet = Timesheet.find(params[:id])
    
    # get the contractor
    @contractor = Contractor.find(@timesheet.contractor_id)
    
    # create the rates manager & set contract & get approvers
    rates_manager = RatesManager.new(@timesheet.contract.id)
    @contract = rates_manager.contract
    @approvers = @contract.users
    
    #disable submit?
    set_submit_button(@contract.users.length)
    
    # define the colspan
    @total_colspan = @contract.rateType == 'Day' ? 12 : 11
    @input_section_colspan = @total_colspan - 4
    
    # get the rates for Day and Hour
    @day_rates = rates_manager.get_valid_rates_by_type(@timesheet.startDate, @timesheet.startDate + 6, 'Day').collect {|r| [ r.name, r.id ] }
    @hour_rates = rates_manager.get_valid_rates_by_type(@timesheet.startDate, @timesheet.startDate + 6, 'Hour').collect {|r| [ r.name, r.id ] }
    
    @notes = TimesheetHistory.get_all_notes(@timesheet.id)
    
    @timesheet.timesheet_entries.each {|te|
      
      # Set the requirements...
      te.requireTimes = @contract.requireTimes
      te.requireFullWeek = @contract.requireFullWeek
      
      # set bank hol
      if BankHoliday.is_holiday(te.dateValue, 'UK')
        
        te.is_bank_hol = true
        
      else
        
        te.is_bank_hol = false
        
      end
    }
    
    respond_to do |format|
      
      format.html
      
      format.pdf {
        
        if session[:theme].nil?
          site = SITE + "/images/"
        else
          site = SITE + "/images/#{session[:theme]}/"
        end
        
        if File::exists?(site + @contract.client.agency.id.to_s + '/logo.gif')
          
          @img_tag = "<img src=\" + img + \" alt=\"\"/>"
          
        else
          
          @img_tag = "<img src=\"" + site + "timesheets_logo.gif\" alt=\"\"/>"
          
        end
        
        send_data(render_pdf('LANDSCAPE', { :action => 'timesheet.rpdf', :layout => 'pdf_timesheet' }), :filename => "timesheet.pdf" )
      }
      #format.test { render :action => 'timesheet.rpdf', :layout => 'pdf_timesheet.html' }
      
    end
    
  end
  
  #----------------------------------------------------------------------------
  # Create the timesheet
  #----------------------------------------------------------------------------
  def create
    
    # are we adding/removing entries?
    removed = false
    selected_date = nil
    
    # set the selected_date if we have had an 'add' button clicked
    if !params['add_d.x'].nil? || !params['add_h.x'].nil?
      
      selected_date = params[:selected_date]
      
    else
      
      # remove?
      for param in params do
        
        if param[0].ends_with?('_remove.x')
          
          # get the ID from the button
          id = param[0].split('_')[0]
          
          # delete it from the attribs (as its unsaved)
          params[:timesheet][:timesheet_entries_attributes].delete(id)
          
          removed = true
          
        end
        
      end
      
    end
    
    # get the contractor
    @contractor = current_user.contractor
    
    # build the timesheet
    @timesheet = @contractor.timesheets.build(params[:timesheet])
    
    # get the rates
    rates_manager = RatesManager.new(@timesheet.contract_id)
    
    # get the contract
    @contract = rates_manager.contract

    # get the agency
    @agency = @contract.client.agency
    
    # get the approvers
    @approvers = @contract.users
    
    # set the col span
    @total_colspan = @contract.rateType == 'Day' ? 11 : 10
    @input_section_colspan = @total_colspan - 4
    
    # disable submit?
    set_submit_button(@contract.users.length)
    
    # set the rates up
    @day_rates = rates_manager.get_valid_rates_by_type(@timesheet.startDate, @timesheet.startDate + 6, 'Day').collect {|r| [ r.name, r.id ] }
    @hour_rates = rates_manager.get_valid_rates_by_type(@timesheet.startDate, @timesheet.startDate + 6, 'Hour', @timesheet.rateType == 'Day').collect {|r| [ r.name, r.id ] }
    
    # if selected_date set then we're just adding a row
    if !selected_date.nil?
      
      # create new entry
      new_entry = TimesheetEntry.new
      new_entry.dateValue = Date.parse(selected_date)
      new_entry.manual = true
      new_entry.rateType = params['add_d.x'].nil? ? 'Hour' : 'Day'
      # set values for validation
      new_entry.requireTimes = @contract.requireTimes
      new_entry.requireFullWeek = @contract.requireFullWeek 
      new_entry.is_bank_hol = BankHoliday.is_holiday(new_entry.dateValue, 'UK')
      @timesheet.timesheet_entries << new_entry
      
      render :action => 'prepare'
      
      return
      
    elsif removed
      
      # just return if we removed an entry earlier
      render :action => 'prepare'
      return
      
    end
    
    # set the timesheet status
    @timesheet.status =
    case params[:commit]
      
      when "Submit" then
            "SUBMITTED"
      when "Submit as Manual" then
            "MANUAL"
    else
            "DRAFT"
    end
    
    total_hours = 0
    total_days = 0
    
    contract_complete = false
    
    # iterate through the entries
    for entry in @timesheet.timesheet_entries
      
      # calc hours
      total_hours += TimeUtil.hours_to_numeric(entry.hours)
      
      # calc days
      total_days += entry.dayValue unless entry.dayValue.nil?
      
      # calc charge rate
      entry.chargeRate = entry.rate.chargeRate unless entry.disabled? || (entry.is_bank_hol == true && !@contract.allowBankHoildays?)
      
      # convert extra validation variables to bools
      entry.requireTimes = Boolean.parse(entry.requireTimes)
      entry.requireFullWeek = Boolean.parse(entry.requireFullWeek) 
      entry.is_bank_hol = Boolean.parse(entry.is_bank_hol)
      
      # is the contract finishing?
      if entry.dateValue == @contract.endDate
        
        # set contract complete!!
        contract_complete = true
        
      end
      
    end
    
    # set the totals
    @timesheet.totalHours = TimeUtil.numeric_to_hours(total_hours)
    @timesheet.totalDays = total_days
    @timesheet.userName = current_user.full_name
    
    respond_to do |format|
      
      # save it!
      Timesheet.transaction do
        
        if @timesheet.status == 'DRAFT'
          
          # don't validate
          result = @timesheet.save(false)
          
        else
          
          result = @timesheet.save
          
        end
        
        if result
          
          @contract.update_attribute(:status, 'COMPLETE') if contract_complete
          @contract.update_attribute(:status, 'ACTIVE') if @contract.status == 'INACTIVE'
          format.html { redirect_to currenttimesheets_path }
          
        else
          
          format.html { render :action => "prepare" }
          
        end
        
      end
      
    end
    
  end
  
  #----------------------------------------------------------------------------
  # Update a draft timesheet
  #----------------------------------------------------------------------------
  def update
    
    # get the contractor
    @contractor = current_user.contractor
    
    # get the timesheet
    @timesheet = Timesheet.find(params[:id])
    
    # update the atrribs
    @timesheet.attributes = params[:timesheet]
    
    # get the contract
    @contract = @timesheet.contract
    rates_manager = RatesManager.new(@contract.id)
    
    # get the approvers
    @approvers = @contract.users
    
    @notes = TimesheetHistory.get_all_notes(@timesheet.id)
    
    # set the rates
    @day_rates = rates_manager.get_valid_rates_by_type(@timesheet.startDate, @timesheet.startDate + 6, 'Day').collect {|r| [ r.name, r.id ] }
    @hour_rates = rates_manager.get_valid_rates_by_type(@timesheet.startDate, @timesheet.startDate + 6, 'Hour', @timesheet.rateType == 'Day').collect {|r| [ r.name, r.id ] }
    
    total_hours = 0
    total_days = 0
    
    # disable submit?
    set_submit_button(@contract.users.length)
    
    contract_complete = false
    
    # calc totals & hrs
    for entry in @timesheet.timesheet_entries
      next if entry.deleted?
      entry.format_hours
      total_hours += TimeUtil.hours_to_numeric(entry.hours)
      total_days += entry.dayValue unless entry.dayValue.nil?
      entry.chargeRate = entry.rate.chargeRate unless entry.disabled?
      contract_complete = entry.dateValue == @contract.endDate
      # set values for validation
      entry.requireTimes = Boolean.parse(entry.requireTimes)
      entry.requireFullWeek = Boolean.parse(entry.requireFullWeek) 
      entry.is_bank_hol = Boolean.parse(entry.is_bank_hol)
    end
    
    # set the totals
    @timesheet.totalDays = total_days
    @timesheet.totalHours = TimeUtil.numeric_to_hours(total_hours)
    
    # set the colspan
    @total_colspan = @contract.rateType == 'Day' ? 11 : 10
    @input_section_colspan = @total_colspan - 4
    
    selected_date = nil
    
    # are adding/removing an entry?
    if !params['add_d.x'].nil? || !params['add_h.x'].nil?
      
      selected_date = params[:selected_date]
      
    else
      
      # remove?
      for param in params do
        
        if param[0].ends_with?('remove.x')
          
          # get the id from the button
          id = param[0].split('_')[0]
          
          # delete from DB
          #e = TimesheetEntry.find(id.to_i) unless id.blank?
          #@timesheet.timesheet_entries.delete(e) unless e.nil?
          entries = @timesheet.timesheet_entries.select {|e| e.id == id.to_i}
          entries[0].deleted = true
          #e.destroy unless e.nil?
          
          render :action => 'edit'
          return
          
        end
        
      end
      
    end
    
    # if selected_date is set we've added an entry
    unless selected_date.nil?
      
      # create new entry
      new_entry = TimesheetEntry.new
      new_entry.dateValue = Date.parse(selected_date)
      new_entry.timesheet_id = @timesheet.id
      new_entry.rateType = params['add_d.x'].nil? ? 'Hour' : 'Day'
      new_entry.manual = true
      new_entry.requireTimes = @contract.requireTimes
      new_entry.requireFullWeek = @contract.requireFullWeek 
      new_entry.is_bank_hol = BankHoliday.is_holiday(new_entry.dateValue, 'UK')
      position = -1
      
      # need to insert new entry in right position.. find it!
      @timesheet.timesheet_entries.reverse_each {|e|
        
        position = @timesheet.timesheet_entries.index(e) if e.dateValue == Date.parse(selected_date)
        break if position > -1
        
      }
      
      # add the new entry into a specific position
      @timesheet.timesheet_entries[position + 1,0] = new_entry
      
      # save it - no validation
      new_entry.save(false)
      
      render :action => 'edit'
      return
      
    end
    
    invalid_state = false
    
    status =
    case params[:commit]
      when "Submit" then
					"SUBMITTED"
      when "Cancel" then
      invalid_state = true if (@timesheet.status != "SUBMITTED" && @timesheet.status != "MANUAL")
          "DRAFT"
      when "Submit as Manual" then
					"MANUAL"
    else
					"DRAFT"
    end
    
    # cant cancel if the timesheet is not in SUBMITTED or MANUAL state
    if invalid_state == true
      
      @timesheet.errors.add(:status, "This timesheet has already been processed and cannot be cancelled")
      render :action => "edit"
      return
      
    end
    
    # set status & rate type
    @timesheet.status = status
    @timesheet.timesheet_entries.each {|e| e.rateType = @contract.rateType}
    
    # update!!
    Timesheet.transaction do
      
      @contract.update_attribute(:status, 'COMPLETE') if contract_complete
      @contract.update_attribute(:status, 'ACTIVE') if @contract.status == 'INACTIVE'
      
      if @timesheet.status == 'DRAFT'
        
        result = @timesheet.save(false)
        
      else
        
        @timesheet.note = params[:notes]
        @timesheet.userName = current_user.full_name
        result = @timesheet.save
        
      end
      
      if result
        
        redirect_to currenttimesheets_path(:date_period => Navigator.get_position(session, :contractor_timesheets)[0], :timesheet_status => Navigator.get_position(session, :contractor_timesheets)[1], :page => Navigator.get_position(session, :contractor_timesheets)[3])
        
      else
        
        @timesheet.status = 'DRAFT'
        render :action => "edit"
        
      end
      
    end
    
  end
  
  #----------------------------------------------------------------------------
  # Alert for cancelling timesheet
  #----------------------------------------------------------------------------
  def cancel_timesheet_alert
    
    render :layout => 'none' 
    
  end
  
  private
  
  #----------------------------------------------------------------------------
  # Synamic timesheet layout
  #----------------------------------------------------------------------------
  def timesheet_layout
    
    if current_user.nil?
      
      "approval"
      
    else
      
      if current_user.userType == 'agency'
        
        "agencydashboard"
        
      elsif current_user.userType == 'contractor'
        
        "contractordashboard"
        
      else
        
        "application"
        
      end
      
    end
    
  end
  
  #----------------------------------------------------------------------------
  # define atrribs of the submit button
  #----------------------------------------------------------------------------
  def set_submit_button(no_of_users)
    
    @disable_submit = (no_of_users == 0)
    @submit_button_title = @disable_submit.blank? ? "Submit this timesheet to your approver(s)" : "You have no approvers assigned so you must submit the timesheet manually"
    @submit_button_class = @disable_submit.blank? ? "generalButton" : "disabledButton"
    
  end
  
end