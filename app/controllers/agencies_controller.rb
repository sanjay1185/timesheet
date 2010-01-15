class AgenciesController < ApplicationController
  
  #----------------------------------------------------------------------------
  # Set the layout
  #----------------------------------------------------------------------------
  layout 'new_agency'
  
  #----------------------------------------------------------------------------
  # Callback events - authenticate & various permissions....
  #----------------------------------------------------------------------------
  before_filter :authenticate, :except => [:new, :create]
  
  before_filter :except => [:new, :create] do |controller|
    controller.check_type('agency')
  end
  
  before_filter :only => [:users, :user_add] do |controller|
    controller.check_role('Users')
    controller.can_edit?('Users')
  end
  
  before_filter :only => [:settings] do |controller|
    controller.check_role('Settings')
    controller.can_edit?('Settings')
  end
  
  before_filter :only => [:reports, :report] do |controller|
    controller.check_role('Reports')
  end
  
  #----------------------------------------------------------------------------
  # Denied page
  #----------------------------------------------------------------------------
  def denied
      
  end
  
  #----------------------------------------------------------------------------
  # Tools dashboard page
  #----------------------------------------------------------------------------
  def tools
    
    @selected = 'dashboard'
    
    @criteria = params[:criteria]
    
    # define how we're sorting the data
    @selected_column = params[:c].blank? ? 'end_date' : params[:c]
    
    if @criteria
      
      if session[:tools_criteria] == @criteria
      
        if session[:tools_results] && session[:tools_results].length > 0
          
          @results = SearchResult.sort(session[:tools_results], sort_order('end_date'))
        
        else
        
          @results = perform_search(@criteria, sort_order('end_date'))
          session[:tools_results] = @results
          
        end
      
      else
      
        @results = perform_search(@criteria, sort_order('end_date'))
        session[:tools_results] = @results
        session[:tools_criteria] = @criteria
          
      end
      
    end
    
    # get active contract list
    @active_contracts = Contract.get_by_agency_and_status(session[:agencyId], 'ACTIVE')
    @active_workers = Contractor.get_all_active(session[:agencyId])
    
    # get outstanding timesheets
    #@timesheets = Timesheet.get_all_requiring_action(session[:agencyId], 1, 10)
    
    # client list for drop down
    @client_list = Client.find(:all, :conditions => ["agency_id = ?", session[:agencyId]], :select => "id, name", :order => "name asc")
    
    render :layout => 'agencydashboard'
    
  end
  
  #----------------------------------------------------------------------------
  # View statistics
  #----------------------------------------------------------------------------
  def stats
    
    @selected = 'dashboard'
    
    # get basic statistics
    @no_of_clients = Agency.find(session[:agencyId]).clients.length
    @no_of_active_clients = Client.get_all_active(session[:agencyId], nil, nil, 'id').length
    #@active_clients_percent = ((@no_of_active_clients / @no_of_clients.to_f) * 100).round(2)
    #@no_of_active_contracts = Contract.get_all_active(session[:agencyId], nil, nil, 'id').length
    @clients_by_timesheets = Client.get_by_timesheets(session[:agencyId])
    @clients_with_approvers = Client.get_all_with_approvers(session[:agencyId])
    
  end
  
  #----------------------------------------------------------------------------
  # View timesheet history
  #----------------------------------------------------------------------------
  def view_history
    
    @current = Timesheet.find(params[:original_id])
    @histories = TimesheetHistory.find(:all, :conditions => "original_timesheet_id = #{@current.id.to_s}", :order => "updated_at desc")
    
    if params[:selected_id]
      @selected = @histories.select {|t| t.id == params[:selected_id].to_i}[0]
    else
      @selected = @current  
    end
    
  end

  #----------------------------------------------------------------------------
  # Alert for rejecting timesheet
  #----------------------------------------------------------------------------
  def reject_timesheet_alert
    
    render :layout => 'none' 
    
  end
  
  #----------------------------------------------------------------------------
  # Send invites to contractors by email
  #----------------------------------------------------------------------------
  def send_invites
    
    # get the email list
    emails = params[:emails]
    
    # separate into array
    emails = emails.split(',')
    @list = {}
    
    # iterate through the list
    for email in emails
      
      # does the user exist?
      if !User.exists?(:email => email.strip)
        
        # send email to user
        AgencyMailer.deliver_invite_worker(email.strip, current_user.agency)
        @list[email] = "<img src=\"/images/circle_green.png\" class=\"small_icon\" alt=\"\" />"
        
      else
        
        # user exists - no email sent
        @list[email] = "<img src=\"/images/circle_red.png\" class=\"small_icon\" alt=\"\" />"
        
      end
      
    end
    
  end
  
  #----------------------------------------------------------------------------
  # Update user from agency | users screen
  #----------------------------------------------------------------------------
  def user_update
    
    # get the agency
    @agency = Agency.find(session[:agencyId])
    
    # get the user
    @user = User.find(params[:id])
    
    # update the users attributes
    @user.attributes = params[:user]
    
    # compare the roles they've selected
    clients_role = !params[:Clients_granted].nil?
    clients_readonly = !params[:Clients_readonly].nil?
    contracts_role = !params[:Contracts_granted].nil?
    contracts_readonly = !params[:Contracts_readonly].nil?
    settings_role = !params[:Settings_granted].nil?
    settings_readonly = !params[:Settings_readonly].nil?
    users_role = !params[:Users_granted].nil?
    users_readonly = !params[:Users_readonly].nil?
    rates_role = !params[:Rates_granted].nil?
    rates_readonly = !params[:Rates_readonly].nil?
    invoicing_role = !params[:Invoicing_granted].nil?
    invoicing_readonly = !params[:Invoicing_readonly].nil?
    
    # set email confirmation to satisfy validation
    @user.email_confirmation = @user.email
    @user.only_basic_validation = true
    
    result = true
    users_removed = false
    
    # start a transaction for saving permissions when the user is saved
    User.transaction do
      
      # check each role
      manage_role?('Clients', clients_role, clients_readonly)
      manage_role?('Contracts', contracts_role, contracts_readonly)
      manage_role?('Settings', settings_role, settings_readonly)
      manage_role?('Rates', rates_role, rates_readonly)
      users_removed = manage_role?('Users', users_role, users_readonly)
      manage_role?('Invoicing', invoicing_role, invoicing_readonly)
      
      # now save the user
      result = @user.save
      
    end
    
    # save the user
    if result
      
      flash[:notice] = "User saved succesfully" unless !flash[:notice].nil?
      
      if @current_user.id == @user.id && users_removed == true
        flash[:notice] = "You no longer have permission to manage users."
        redirect_to clients_path
      else
        redirect_to users_agency_path(:user_id => @user.id)
      end
    else
      
      # errors
      @users = @agency.users.paginate(:page => params[:page], :per_page => 21)
      
      render :action => 'users'
      
    end
    
  end
  
  #----------------------------------------------------------------------------
  # view the settings
  #----------------------------------------------------------------------------
  def settings
    
    @agency = Agency.find(session[:agencyId])
    session[:selected] = 'settings'
    @user = current_user
    @days = {'Monday' => 1, 'Tuesday' => 2, 'Wednesday' => 3, 'Thursday' => 4, 'Friday' => 5, 'Saturday' => 6, 'Sunday' => 0}.sort {|a,b| a[1] <=> b[1] }
    @title = @readonly == true ? "You do not have permission to save this data" : "Save"
    @uploaded_image = @agency.has_agency_logo? ? "<img src=\"#{@agency.rel_agency_logo_filename}\" alt=\"Agency Logo\" />" : '&nbsp;No Image Uploaded&nbsp;'
    
  end
  
  def remove_logo
  
    @agency = Agency.find(session[:agencyId])
    if @agency.has_agency_logo?
      
      # remove it
      @agency.remove_logo
      
    end
    
    redirect_to settings_agency_path(@agency)
    
  end
  
  #----------------------------------------------------------------------------
  # Logout
  #----------------------------------------------------------------------------
  def logout
    
    session[:selected] = 'logout'
    
  end
  
  #----------------------------------------------------------------------------
  # Reject the timesheet
  #----------------------------------------------------------------------------
  def reject_timesheet
    
    # find the timesheet
    @timesheet = Timesheet.find(params[:timesheet_id])
    
    # set the status to rejected
    @timesheet.status = "REJECTED"
    # set the name
    @timesheet.userName = current_user.full_name
    
    # set the notes
    @timesheet.note = params[:notes]
    
    # set the search criteria
    @client_id = params[:client_id]
    @contractor_id = params[:contractor_id]
    @from_date = params[:from_date]
    @to_date = params[:to_date]
    @status = params[:status]
    @page = params[:page]
    
    # save, dont validate
    @timesheet.save(false)
    
    # set the values and re-render
    @contract = @timesheet.contract
    @source = 'history'
    @can_reject = false
    
    # get the notes
    @notes = TimesheetHistory.get_all_notes(@timesheet.id)
    
    flash[:notice] = "Timesheet rejected" 
    render :action => 'view_timesheet'
    
  end
  
  #----------------------------------------------------------------------------
  # View a timesheet
  #----------------------------------------------------------------------------
  def view_timesheet
    
    # get the agency
    @agency = Agency.find(session[:agencyId])
    
    # get the timesheet
    @timesheet = Timesheet.find(params[:timesheet_id])
    
    # set the contract
    @contract = @timesheet.contract
    
    # get the notes
    @notes = TimesheetHistory.get_all_notes(@timesheet.id)
    
    # set the source page
    @source = params[:source]
    
    # set variables depending on where we're viewing the timesheet from
    if @source != 'history'
      
      @list_url = url_for(:action => 'outstanding', :controller => 'agencies', :id => session[:agencyId])
      
    else
      
      @client_id = params[:client_id]
      @contractor_id = params[:contractor_id]
      @from_date = params[:from_date]
      @to_date = params[:to_date]
      @status = params[:status]
      @page = params[:page]
      @list_url = url_for(:action => 'timesheet_history', :controller => 'agencies', :id => session[:agencyId], :client_id => @client_id, :contractor_id => @contractor_id, :page => @page, :from_date => @from_date, :to_date => @to_date, :status => @status)
      
    end
    
  end
  
  #----------------------------------------------------------------------------
  # Get the timesheets by status (outstanding)
  #----------------------------------------------------------------------------
  def outstanding
    
    session[:selected] = 'dashboard'
    
    # get the agency
    @agency = Agency.find(session[:agencyId])
    
    # set the status to search
    @status = params[:status]
    
    # set the sort order
    @selected_column = params[:c].blank? ? 'startDate' : params[:c]
    
    # go go go
    @timesheets = Timesheet.find_all_by_agency(params[:page], 26, @agency, @status ||= 'ANY', sort_order('startDate'))
    
    render :layout => 'new_agencydashboard'
    
  end
  
  #----------------------------------------------------------------------------
  # Get all active clients
  #----------------------------------------------------------------------------
  def active_clients
    
    @selected = 'dashboard'
    
    @selected_column = params[:c].blank? ? 'name' : params[:c]
    
    @clients = Client.get_all_active(session[:agencyId], params[:page], 20, sort_order('name'))
    
    render :layout => 'agencydashboard'
    
  end
  
  #----------------------------------------------------------------------------
  # Get all active contracts
  #----------------------------------------------------------------------------
  def active_contracts
    
    @selected = 'dashboard'
    
    @selected_column = params[:c].blank? ? 'endDate' : params[:c]
    
    @contracts = Contract.get_all_active(session[:agencyId], params[:page], 20, sort_order('endDate'))
    
    render :layout => 'agencydashboard'
    
  end
  
  #----------------------------------------------------------------------------
  # Send a reminder to all approvers
  #----------------------------------------------------------------------------
  def send_reminder_to_approvers
    # NOT USED YET
    # todo: need to add a param for getting the return_url
    @timesheet = Timesheet.find(params[:timesheet_id])
    @timesheet.note << "\r[" + Time.now.to_formatted_s(:uk_date_time_24) +"] Reminder send to approvers.]\r";
    @timesheet.save(false)
    render :action => 'view_timesheet'
  end
  
  #----------------------------------------------------------------------------
  # Search for timesheet history
  #----------------------------------------------------------------------------
  def timesheet_history
    
    session[:selected] = 'timesheet_history'
    
    # set the params
    @from_date = params[:from_date]
    @to_date = params[:to_date]
    @status = params[:status]
    @contractor_id = params[:contractor_id]
    @client_id = params[:client_id]
    @formats = ['CSV']
    
    # set the sort order
    @selected_column = params[:c].blank? ? 'timesheets.startDate' : params[:c]
    
    # get the timesheets
    @timesheets = Timesheet.run_report(params[:page], 21, @from_date, @to_date, @status, nil, @client_id, @contractor_id, sort_order('timesheets.startDate'), session[:agencyId])
    
    # get the agency
    @agency = Agency.find(session[:agencyId])
    
    # get the clients
    @client_list = @agency.clients
    @client_list.insert(0, Client.new)
    
    # set the status'
    @status_list = ['ANY', 'APPROVED', 'DENIED', 'SUBMITTED', 'DRAFT']
    
    # get the contractors for this agency
    @users = User.find_contractor_users_by_agency(session[:agencyId])
    @users.insert(0, User.new({'contractor_id' => 0, 'firstName' => "", 'lastName' => ""}))
    
    # set the disabled flag
    @disabled = (@timesheets.length == 0)
    
    # did the user click export??
    if params[:commit] == "Export"
      
      if params[:exportFormat] == "CSV"
        
        export_to_csv(@timesheets, "export")
        
      end
      
      @selectedFormat = params[:exportFormat]
      
    else
      
      render :action => 'timesheet_history'
      
    end
    
  end
  
  #----------------------------------------------------------------------------
  # Get the agency users
  #----------------------------------------------------------------------------
  def users
    
    session[:selected] = 'users'
    
    # get the agency
    @agency = Agency.find(session[:agencyId])
    
    # paginate the users
    @users = @agency.users.paginate(:page => params[:page], :per_page => 21) #User.find_by_agency(params[:page], session[:agencyId], 21)
    
    # do we have a user id? if so, need to get the user
    if params[:user_id]
      
      # get the user
      @user = User.find(params[:user_id])
      @roles_list = Role.find(:all, :order => 'name asc')
      
      # show a warning about user manager role if needed
      @show_warning = @user.id == current_user.id && @user.has_role?('Users')
      
    end
    
  end
  
  #----------------------------------------------------------------------------
  # Save a new user for the agency
  #----------------------------------------------------------------------------
  def save_new_user
    
    # get the agency
    @agency = Agency.find(session[:agencyId])
    
    # create a new user
    @user = User.new(params[:user])
    
    # set the agency id & type
    @user.agency_id = session[:agencyId]
    @user.type = 'AgencyUser'
    
    # set the title & pwd & email
    @user.title = params[:selected_title]
    @user.password = @user.generatepassword(8)
    @user.password_confirmation = @user.password
    @user.email_confirmation = params[:email_confirmation]
    @user.only_basic_validation = true
    
    # save
    if @user.save
      
      redirect_to users_agency_path(@agency)
      
    else
      
      render :user_add
      
    end
    
  end
  
  #----------------------------------------------------------------------------
  # Add new user for agency
  #----------------------------------------------------------------------------
  def user_add
    
    @user = User.new
    
  end
  
  #----------------------------------------------------------------------------
  # Change the password for the current user
  #----------------------------------------------------------------------------
  def change_password
    
    # get the current user
    @user = current_user
    
    # get the pwd
    @user.password = params[:user][:password]
    @user.password_confirmation = params[:user][:password_confirmation]
    
    if !@user.password.blank? && !@user.password_confirmation.blank?
      
      # set email confirmation for validation
      @user.email_confirmation = @user.email
      @user.only_basic_validation = true
      
      # set reset_password flag
      @user.reset_password
      
      # save... (email will be sent on saving)
      if @user.save
        
        flash[:notice] =  "Password reset successful"
        
      else
        
        flash[:alert] = "Password reset failed"
        
      end
      
    else
      
      flash[:alert] = "You must enter a new password"
      
    end
    
    redirect_to users_agency_path(:id => session[:agencyId], :user_id => @user.id)
    
  end
  
  #----------------------------------------------------------------------------
  # View all the contractors working through the agency
  #----------------------------------------------------------------------------
  def contractors
    
    session[:selected] = 'workers'
    
    # get the agency
    @agency = Agency.find(session[:agencyId])
    
    # manage the column sorting
    @selected_column = params[:c].blank? ? 'users.lastName' : params[:c]
    
    # set the status'
    @statuses =  ['With Active Contracts', 'With Active or Future Contracts', 'With Completed Contracts', 'All']
    
    # get the contractors
    @users = User.find_by_agency_by_status(@agency.id, params[:page], 26, params[:query_status], sort_order('lastName'))
    
    # get selected status
    if params[:query_status].nil?
      
      @selected_status = 'With Active Contracts'
      
    else
      
      @selected_status = params[:query_status]
      
    end
    
  end
  
  #----------------------------------------------------------------------------
  # Create a new agency - hooray
  #----------------------------------------------------------------------------
  def new
    
    @agency = Agency.new
    @user = User.new
    @statement = "Join us for free for 30 days and see how your business can benefit"
    @sub_statement = "Registration will just take a minute and we won't take any payment details from you"
    @header_link = ""
    @arrow_position = 608
    render :layout => 'clockoff'
    
  end
  
  #----------------------------------------------------------------------------
  # View reports screen
  #----------------------------------------------------------------------------
  def reports
    
    session[:selected] = 'reports'
    
    # get the agency
    @agency = Agency.find(session[:agencyId])
    
    # set the report trypes
    @reportTypes = ['Client Revenue Report', 'Contract Revenue Report', 'Timesheet Report']
    
    # get the clients
    @client_list = @agency.clients
    client = Client.new
    @client_list.insert(0, client)
    
    # get the users
    @users = User.find_contractor_users_by_agency(session[:agencyId])
    @users.insert(0, User.new({'contractor_id' => 0, 'firstName' => "", 'lastName' => ""}))
    
    # set the last month date
    last_month_date = Date.today - 1.month
    
    # set the default reports
    @client_revenue_this_year_link = "report?reportName=Client+Revenue+Report&from_date=January+1%2C+#{Date.today.year}&client_id=&to_date=December+31%2C+#{Date.today.year}&contractor_id=0&commit=Run+Report"
    @client_revenue_this_year_text = "This year (01/01/#{Date.today.year} - 31/12/#{Date.today.year})"
    @client_revenue_this_month_link = "report?reportName=Client+Revenue+Report&from_date=#{Date.today.strftime("%B")}+1%2C+#{Date.today.year}&client_id=&to_date=#{Date.today.strftime("%B")}+#{Date.new(Date.today.year, Date.today.month, -1).day}%2C+#{Date.today.year}&contractor_id=0&commit=Run+Report"
    @client_revenue_this_month_text = "This month (#{Date.today.strftime("%B")})"
    @client_revenue_last_month_link = "report?reportName=Client+Revenue+Report&from_date=#{last_month_date.strftime("%B")}+1%2C+#{last_month_date.year}&client_id=&to_date=#{last_month_date.strftime("%B")}+#{Date.new(last_month_date.year, last_month_date.month, -1).day}%2C+#{last_month_date.year}&contractor_id=0&commit=Run+Report"
    @client_revenue_last_month_text = "Last month (#{last_month_date.strftime("%B")})"
    
    @contract_revenue_this_year_link = "report?reportName=Contract+Revenue+Report&from_date=January+1%2C+#{Date.today.year}&client_id=&to_date=December+31%2C+#{Date.today.year}&contractor_id=0&commit=Run+Report"
    @contract_revenue_this_year_text = "This year (01/01/#{Date.today.year} - 31/12/#{Date.today.year})"
    @contract_revenue_this_month_link = "report?reportName=Contract+Revenue+Report&from_date=#{Date.today.strftime("%B")}+1%2C+#{Date.today.year}&client_id=&to_date=#{Date.today.strftime("%B")}+#{Date.new(Date.today.year, Date.today.month, -1).day}%2C+#{Date.today.year}&contractor_id=0&commit=Run+Report"
    @contract_revenue_this_month_text = "This month (#{Date.today.strftime("%B")})"
    @contract_revenue_last_month_link = "report?reportName=Contract+Revenue+Report&from_date=#{last_month_date.strftime("%B")}+1%2C+#{last_month_date.year}&client_id=&to_date=#{last_month_date.strftime("%B")}+#{Date.new(last_month_date.year, last_month_date.month, -1).day}%2C+#{last_month_date.year}&contractor_id=0&commit=Run+Report"
    @contract_revenue_last_month_text = "Last month (#{last_month_date.strftime("%B")})"
    
    @timesheet_this_year_link = "report?reportName=Timesheet+Report&from_date=January+1%2C+#{Date.today.year}&client_id=&to_date=December+31%2C+#{Date.today.year}&contractor_id=0&commit=Run+Report"
    @timesheet_this_year_text = "This year (01/01/#{Date.today.year} - 31/12/#{Date.today.year})"
    @timesheet_this_month_link = "report?reportName=Timesheet+Report&from_date=#{Date.today.strftime("%B")}+1%2C+#{Date.today.year}&client_id=&to_date=#{Date.today.strftime("%B")}+#{Date.new(Date.today.year, Date.today.month, -1).day}%2C+#{Date.today.year}&contractor_id=0&commit=Run+Report"
    @timesheet_this_month_text = "This month (#{Date.today.strftime("%B")})"
    @timesheet_last_month_link = "report?reportName=Timesheet+Report&from_date=#{last_month_date.strftime("%B")}+1%2C+#{last_month_date.year}&client_id=&to_date=#{last_month_date.strftime("%B")}+#{Date.new(last_month_date.year, last_month_date.month, -1).day}%2C+#{last_month_date.year}&contractor_id=0&commit=Run+Report"
    @timesheet_last_month_text = "Last month (#{last_month_date.strftime("%B")})"
    
  end
  
  #----------------------------------------------------------------------------
  # Execute a report
  #----------------------------------------------------------------------------
  def report
    
    # set the params
    @client_id = params[:client_id]
    @selected_report = params[:reportName]
    @from_date = params[:from_date]
    @to_date = params[:to_date]
    @contractor_id = params[:contractor_id]
    @selected_column = params[:c].blank? ? 'invoiceDate' : params[:c]
    
    # run the report
    if @selected_report == 'Client Revenue Report'
      
      client_revenue_report
      
    elsif @selected_report == 'Contract Revenue Report'
      
      contract_revenue_report
      
    elsif @selected_report == 'Timesheet Report'
      
      timesheet_report
      
    end
    
  end
  
  #----------------------------------------------------------------------------
  # Run the timesheet report
  #----------------------------------------------------------------------------
  def timesheet_report
    
    # get the date range
    @to_date = Date.strptime(@to_date, "%B %d, %Y")
    @from_date = Date.strptime(@from_date, "%B %d, %Y")
    
    # set the header text
    @sub_header = set_report_header(@from_date, @to_date, @client_id, @contractor_id)
    
    # default query!
    sql = "select t.*, DATE_SUB(t.startDate, INTERVAL 6 DAY) as endDate, cl.*, u.* from timesheets t"
    
    # default where
    where_clause = " where (DATE_SUB(t.startDate, INTERVAL 6 DAY) <= '#{@to_date}' and t.startDate >= '#{@from_date}') and (t.status in ('APPROVED', 'MANUALAPPROVED'))"
    
    # client info sql
    sql += " inner join timesheet_entries e on e.timesheet_id = t.id
            inner join contracts ctc on ctc.id = t.contract_id
            inner join clients cl on cl.id = ctc.client_id"
    
    # adjust where clause for client id
    where_clause += " and (ctc.client_id = #{@client_id.to_s})" if !@client_id.blank?
    
    # contractor info sql
    sql += " inner join contractors ctrs on ctrs.id = t.contractor_id
            inner join users u on u.id = ctrs.user_id"
    
    # filter by contractor?
    where_clause += " and t.contractor_id = #{@contractor_id.to_s}" if @contractor_id.to_i > 0
    
    # set the whole query
    query = "#{sql}#{where_clause} group by (t.id) order by #{sort_order('t.startDate')}"
    
    # get the timesheets
    @timesheets = Timesheet.find_by_sql(query)
    
    # set the total hours & days for total summary
    @totalHrs = 0
    @totalDays = 0
    
    for t in @timesheets
      
      @totalHrs += TimeUtil.hours_to_numeric(t.totalHours) unless t.totalHours.blank?
      @totalDays += t.totalDays unless t.totalDays.blank?
      
    end
    
    respond_to do |format|
      
      format.html { render 'timesheet_report', :layout => 'reports' }
      # todo: format PDF!!
      format.pdf { send_data(render_pdf('PORTRAIT', { :action => 'contract_report.html', :layout => 'reports' }), :filename => "client_revenue_report.pdf" ) }
      
    end
    
  end
  
  #----------------------------------------------------------------------------
  # Run the contract revenue report
  #----------------------------------------------------------------------------
  def contract_revenue_report
    
    @to_date = Date.strptime(@to_date, "%B %d, %Y")
    @from_date = Date.strptime(@from_date, "%B %d, %Y")
    
    @sub_header = set_report_header(@from_date, @to_date, @client_id, @contractor_id)
    
    # default query!
    sql = "select c.*, cl.*, CONCAT(u.firstName, ' ', u.lastName) as worker, sum(t.netAmount) as netAmt from contracts c"
    
    # default where clause
    where_clause = " where (c.endDate <= '#{@to_date}' and c.startDate >= '#{@from_date}')"
    
    # client info sql
    sql += " inner join clients cl on cl.id = c.client_id"
    # adjust where clause
    where_clause += " and (c.client_id = #{@client_id.to_s})" if !@client_id.blank?
    
    # contractor info sql
    sql += " left outer join contractors_contracts cc on cc.contract_id = c.id
            left outer join contractors cs on cs.id = cc.contractor_id
            left outer join users u on u.id = cs.user_id"
    
    # filter by contractor?
    where_clause += " and cs.id = #{@contractor_id.to_s}" if @contractor_id.to_i > 0
    
    # add join for contract
    sql += " inner join timesheets t on t.contract_id = c.id"
    
    # put the query together
    query = "#{sql}#{where_clause} group by (c.id) order by #{sort_order('c.endDate')}"
    
    # get the contracts
    @contracts = Contract.find_by_sql(query)
    @netTotal = 0
    
    # do some sums
    for c in @contracts
      
      @netTotal += c.netAmt.to_f unless c.netAmt.nil?
      
    end
    
    respond_to do |format|
      
      format.html { render 'contract_revenue_report', :layout => 'reports' }
      # todo: format PDF!!
      format.pdf { send_data(render_pdf('PORTRAIT', { :action => 'contract_report.html', :layout => 'reports' }), :filename => "client_revenue_report.pdf" ) }
      
    end
    
  end
  
  #----------------------------------------------------------------------------
  # Run the client revenue report
  #----------------------------------------------------------------------------
  def client_revenue_report
    
    @to_date = Date.strptime(@to_date, "%B %d, %Y")
    @from_date = Date.strptime(@from_date, "%B %d, %Y")
    
    @sub_header = set_report_header(@from_date, @to_date, @client_id, @contractor_id)
    
    # default query!
    sql = "select i.*, CONCAT(u.firstName, ' ', u.lastName) as worker, c.margin as contractMargin from invoices i"
    
    # defaule where clause
    where_clause = " where (i.invoiceDate <= '#{@to_date}' and i.invoiceDate >= '#{@from_date}')"
    
    # client info sql
    sql += " inner join clients clt on clt.id = i.client_id"
    
    # adjust where clause
    where_clause += " and (i.client_id = #{@client_id.to_s})" if !@client_id.blank?
    
    # contractor info sql
    sql += " inner join contracts c on c.client_id = i.client_id
            inner join contractors_contracts cc on cc.contract_id = c.id
            inner join contractors cs on cs.id = cc.contractor_id
            inner join users u on u.id = cs.user_id"
    
    # filter by contractor?
    where_clause += " and cs.id = #{@contractor_id.to_s}" if @contractor_id.to_i > 0
    
    # put the query together
    query = "#{sql}#{where_clause} order by #{sort_order('i.invoiceDate')}"
    
    # go go go
    @invoices = Invoice.find_by_sql(query)
    @netTotal, @grossTotal = 0, 0
    
    # sum it up
    for i in @invoices
      
      @netTotal += i.netAmount unless i.netAmount.nil?
      @grossTotal += i.grossAmount unless i.grossAmount.nil?
      
    end
    
    respond_to do |format|
      
      format.html { render 'client_revenue_report', :layout => 'reports' }
      # todo: format PDF!!
      format.pdf { send_data(render_pdf('PORTRAIT', { :action => 'revenue_report.html', :layout => 'reports' }), :filename => "client_revenue_report.pdf" ) }
      
    end
    
  end
  
  #----------------------------------------------------------------------------
  # View a contractor
  #----------------------------------------------------------------------------
  def view_contractor
    
    @contractor = Contractor.find(params[:contractor_id])
    @contracts = @contractor.contracts.paginate(:page => params[:page], :per_page => 25, :order => 'endDate')
    
  end
  
  #----------------------------------------------------------------------------
  # Create an agency
  #----------------------------------------------------------------------------
  def create
    
    # get the agency
    @agency = Agency.new(params[:agency])
    
    # get the user
    @user = User.new(params[:user])
    
    # get t & c status
    @t_and_c = params[:t_and_c]
    
    if @t_and_c != 'on'
      
      # havent viewed the Ts & Cs
      flash[:error] = "You must read the terms and conditions before registering"
      render :action => "new", :layout => 'clockoff'
      
    else
      
      # everything is good... save!
      Agency.transaction do
        
        # save the agency
        if @agency.save
          
          # setup the user
          @user.title = params[:selected_title]
          @user.agency_id = @agency.id
          @user.type = 'AgencyUser'
          @user.only_basic_validation = true
          
          # save the user
          if @user.save
            
            flash[:notice] = "An activation email has been sent to #{@user.email}"
            redirect_to('/')
            
          else
            
            render :action => "new", :layout => 'clockoff'
            
          end
          
        else
          
          render :action => "new", :layout => 'clockoff'
          
        end
        
      end
      
    end
    
  end
  
  
  #----------------------------------------------------------------------------
  # Update the agency settings
  #----------------------------------------------------------------------------
  def update
    
    # get the agency
    @agency = Agency.find(session[:agencyId])
    
    # set the attributes
    @agency.attributes = params[:agency]
    
    # save the agency
    begin
      if @agency.save
        flash[:notice] = "Settings saved successfully"
        redirect_to settings_agency_path(@agency)
        session[:useInvoicing] = @agency.useInvoicing?
      else
        render :action => "settings"
      end
    rescue Exception => ex
      flash[:notice] = ex.message
      redirect_to settings_agency_path(@agency)
      session[:useInvoicing] = @agency.useInvoicing?
    end        
  end
  
  private
  
  def perform_search(criteria, order)
  
    results_timesheets = Finder.search_for_timesheets(criteria)
    results_contracts = Finder.search_for_contracts(criteria)
    
    return SearchResult.merge_results(results_timesheets, results_contracts, session[:agencyId], order)
    
  end
  
  def manage_role?(role_name, grant_role, read_only)
    
    removed = false
    
    if !@user.has_role?(role_name)  
        
        # user doesnt have Clients role
        if grant_role == true
          
          # get the role id
          r_id = Role.find(:first, :conditions => "name = '#{role_name}'").id
          
          # add the permission
          @user.permissions.build(:role_id => r_id, :readOnly => read_only) 
          
        end
        
      else
        
        # user has the Clients role
        if grant_role == true
          
          # find the permission for Clients
          perm = @user.permissions.select {|p| p.role.name == role_name }[0]
          
          # update if needed
          perm.update_attribute(:readOnly, read_only) if perm.readOnly != read_only
          
        else
        
          # the Clients checkbox was unticked so we need to remove the permission
          @user.permissions.select {|p| p.role.name == role_name }[0].destroy
        
          removed = true
          
        end
      
    end
    
    return removed
    
  end
  
  def set_report_header(from_date, to_date, client_id, contractor_id)
    
    header = ''
    
    # if we have a client id, its for a specific client
    if !client_id.blank?
      
      client = Client.find(client_id.to_i)
      header = "For #{client.name}"
      
    else
      
      header = "For all clients"
      
    end
    
    # do we have a contractor id?
    if contractor_id.to_i > 0
      
      contractor = Contractor.find(contractor_id.to_i)
      header += " and #{contractor.user.full_name}"
      
    end
    
    # add the date to the header
    header += " (#{from_date.to_formatted_s(:uk_date)} - #{to_date.to_formatted_s(:uk_date)})"
    
    return header
    
  end
  
  def export_to_csv(timesheets, filename)
    csv_string = FasterCSV.generate do |csv|
      csv << ["StartDate", "EndDate", "TotalDays", "TotalHours", "ContractorName", "ContractorCompany", "ContractRef", "ApproverName", "ApprovalDateTime"]
      
      for ts in timesheets do
        if ts.startDate.wday != 1
          endDate = (ts.startDate + 7) - (ts.startDate.wday - 1)
        else
          endDate = ts.startDate + 7
        end
        csv << [ts.startDate.to_formatted_s(:uk_date), endDate.to_formatted_s(:uk_date), sprintf("%.2f", ts.totalDays), ts.totalHours, ts.contractor.user.full_name, ts.contractor.companyName, ts.contract.ref, 
        ts.approverName.blank? ? "" : ts.approverName, ts.approvalDateTime.nil? ? "" : ts.approvalDateTime.to_formatted_s(:uk_date_time_24)]
      end
    end
    
    filename << ".csv"
    send_data(csv_string, :type => 'text/csv; charset=utf-8; header=present', :filename => filename)
  end
end
