# This controller handles the login/logout function of the site.  
class SessionController < ApplicationController

  #----------------------------------------------------------------------------
  # Set the layout
  #----------------------------------------------------------------------------
  layout 'login'
  
  #----------------------------------------------------------------------------
  # Login screen
  #----------------------------------------------------------------------------
  def new

    set_theme(params[:t])
    
    # load the user from the db from the auth token
    if !cookies[:auth_token].nil?

      @user = User.find_by_remember_token(cookies[:auth_token])

      if !@user.nil?

        self.current_user = @user

        do_redirection

      end

    end
    
  end

  #----------------------------------------------------------------------------
  # Create a session
  #----------------------------------------------------------------------------
  def create

    # authenticate the user/pwd
    self.current_user = User.authenticate(params[:login], params[:password])

    # is the user suspended (through non-payment)
    if !current_user.nil? && current_user.state.downcase == 'suspended'

      flash[:alert] = "Your account is currently suspended due to your trial period expiring"
      flash[:notice] = "To continue using ClockOff.com please download and fax the direct debit mandate"
      render :action => 'new'
      return
      
    end

    # is the user authenticated?
    if logged_in?

      # set remember token?
      if params[:remember_me] == "1"

        current_user.remember_me unless current_user.remember_token?
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }

      else

        if !cookies[:auth_token].nil?

          cookies.delete :auth_token

        end

      end

      do_redirection

    else

      flash[:alert] = 'Username/email or password incorrect.'
      render :action => 'new'

    end

  end

  #----------------------------------------------------------------------------
  # Logged out!
  #----------------------------------------------------------------------------
  def loggedout

  end

  #----------------------------------------------------------------------------
  # Delete the session
  #----------------------------------------------------------------------------
  def destroy

    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    theme = session[:theme]
    theme = "default" if theme.blank?
    reset_session
    
    redirect_back_or_default('/loggedout?t=' + theme)

  end

private

  def do_redirection

    # where should each user be directed?
    if self.current_user.userType.blank? && self.current_user.login == 'controller'

      # admin person
      redirect_to('/admin')

    elsif self.current_user.userType == "agency"

      session[:agencyId] = self.current_user.agency_id
      agency = Agency.find(self.current_user.agency_id)
      session[:useInvoicing] = agency.useInvoicing?

      if current_user.agency.trial?
        new_date = Date.new(current_user.agency.created_at.year, current_user.agency.created_at.month, current_user.agency.created_at.day)
        end_date = new_date + 30
        days = (((end_date - Date.today).days / 60) / 60) / 24
        session[:days_left] = days
      end

      redirect_to(outstanding_agency_path(:id => self.current_user.agency_id))

    elsif self.current_user.userType == "contractor"

      session[:contractorId] = self.current_user.contractor_id
      redirect_to(currenttimesheets_path)

    elsif self.current_user.userType == "approver"

      redirect_to(approverdashboard_path)

    end

  end

end