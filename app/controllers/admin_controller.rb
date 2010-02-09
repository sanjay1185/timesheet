class AdminController < ApplicationController

  layout "new_admin"

  def index
    @title="Contractors"
    if params[:search].blank?
      @users=ContractorUser.paginate(:all,:page=>params[:page],:per_page=>10)
    else
      @users=ContractorUser.paginate(:all,:conditions=>["firstName = ? or lastName = ? or email =? or login = ?",params[:search],params[:search],params[:search],params[:search]],:page=>params[:page],:per_page=>10)
    end
    render :action=>"search"
  end

  def approvers
    @title="Approvers"
    if params[:search].blank?
      @users=ApproverUser.paginate(:all,:page=>params[:page],:per_page=>10)
    else
      @users=ApproverUser.paginate(:all,:conditions=>["firstName = ? or lastName = ? or email =? or login = ?",params[:search],params[:search],params[:search],params[:search]],:page=>params[:page],:per_page=>10)
    end
    render :action=>"search"
  end

  def agencies
    @title="Agencies"
    @agencies=Agency.paginate(:all,:page=>params[:page],:per_page=>10)
  end


  def payments
    @selected_month = Date.today - 1.month
    @selected_year = Date.today

    if params[:commit] == 'Go'
      to_date = Date.new(params[:date][:year].to_i, params[:date][:month].to_i, -1)
      @payments = Contract.get_active_contracts_for_month(to_date)
      @selected_month = params[:date][:month].to_i
      @selected_year = params[:date][:year].to_i
    elsif params[:commit] == 'Generate Invoices'
      to_date = Date.new(params[:date][:year].to_i, params[:date][:month].to_i, -1)
      payments = Contract.get_active_contracts_for_month(to_date)
      @selected_month = params[:date][:month].to_i
      @selected_year = params[:date][:year].to_i
      ids = params["ids"]

      vat_rate = session[:settings]['vat_rate'].value.to_f
      next_invoice_number = session[:settings]['next_invoice_number'].value.to_i
      AgencyInvoice.create_for_month(ids, payments, to_date, vat_rate, next_invoice_number)
    end
  end

  def logout
    session[:selected] = 'logout'
  end

  def search
    @title="Search"
    if params[:search].blank?
      @users=User.paginate(:all,:conditions=>["type = ?",params[:type]],:page=>params[:page],:per_page=>10)
    else
      @users=User.paginate(:all,:conditions=>["firstName = ? or lastName = ? or email =? or login = ? and  type =? ",params[:search],params[:search],params[:search],params[:search],params[:type]],:page=>params[:page],:per_page=>10)
      end
  end


  def user
    @user = User.find(params[:id])
    @roles_list = Role.find(:all, :order => 'name asc')

    # show a warning about user manager role if needed
    @show_warning = @user.id == current_user.id && @user.has_role?('Users')
  end

  def user_update
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

      flash[:notice] = "User saved succesfully" #unless !flash[:notice].nil?

      redirect_to :action=>"user",:id=>@user.id
    else
      # errors
      @users = User.paginate(:page => params[:page], :per_page => 21)
      render :action => 'search'

    end
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
end
