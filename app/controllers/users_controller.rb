class UsersController < ApplicationController

  #----------------------------------------------------------------------------
  # Set the layout
  #----------------------------------------------------------------------------
  layout 'login'

  #----------------------------------------------------------------------------
  # Activate the user
  #----------------------------------------------------------------------------
  def activate

    # use the activation code to load the user
    user = params[:activation_code].blank? ? false : User.find_by_activation_code(params[:activation_code])

    if !user.nil? && !user.active?

      # activate
      user.activate

      # if its a contractor, set the user_id on the contractor
      if user.type == 'ContractorUser'

        contractor = Contractor.find(user.contractor_id)
        contractor.user_id = user.id
        contractor.save(false)

      end

      flash[:notice] = 'Your account has been activated'

    else

      flash[:error] = 'Activation code invalid'

    end
        
    redirect_back_or_default('/')
    
  end

  #----------------------------------------------------------------------------
  # Register an approver
  #----------------------------------------------------------------------------
  def register_approver

    @user = User.new
    @client_id = params[:ref]

    render :layout => 'blank'
    
  end

  #----------------------------------------------------------------------------
  # Create an approver
  #----------------------------------------------------------------------------
  def create_approver

    # get the user
    @user = User.new(params[:user])

    # get the client
    @client = Client.find(params[:client_id].to_i)

    # set the details
    @client_id = @client.id
    @user.title = params[:selected_title]
    @user.type = 'ApproverUser'
    @confirmed = @user.email

    # save
    if @user.save
      
      # add to approvers for client
      @client.users << @user
      render :action => 'create_approver_complete', :layout => 'blank'

    else

      render :action => 'register_approver', :layout => 'blank'

    end
    
  end

  #----------------------------------------------------------------------------
  # AJAX call for checking if login exists
  #----------------------------------------------------------------------------
  def check_login

    login = params[:login]
    @result = true
    @result = User.exists?(:login => login) unless login.blank?
    
    render :partial => 'show'
    
  end

  #----------------------------------------------------------------------------
  # Create new contractor
  #----------------------------------------------------------------------------
  def new

#    @user = User.new
    @contractor = ContractorUser.new
    @statement = "Join us for free and start submitting your timesheets electronically today!"
    @sub_statement = "Registration will just take a minute. You'll only ever need one login to submit timesheets for any registered recruitment agency"
    @header_link = ""
    @arrow_position = -2000
    render :layout => 'clockoff'

  end

  #----------------------------------------------------------------------------
  # Create the contractor
  #----------------------------------------------------------------------------
  def create

    # delete any previous cookies
    cookies.delete :auth_token

    # protects against session fixation attacks, wreaks havoc with 
    # request forgery protection.
    # uncomment at your own risk
    # reset_session

    # get contractor
    @contractor = ContractorUser.new(params[:contractor_user])
    @contractor.title = params[:selected_title]
#    @contractor.user.type = 'ContractorUser'

    # Ts & Cs?
    @t_and_c = params[:t_and_c]

    if @t_and_c != 'on'

      flash[:error] = "You must read the terms and conditions before registering"
      render :action => 'new', :layout => 'clockoff'

    else

      # save
      success = @contractor.save

      if success

        render :action => 'signup_complete', :layout => 'clockoff'

      else

        render :action => 'new', :layout => 'clockoff'

      end

    end

  end

  #----------------------------------------------------------------------------
  # Signup done!!!
  #----------------------------------------------------------------------------
  def signup_complete

  end

  #----------------------------------------------------------------------------
  # Delete an agency worker
  #----------------------------------------------------------------------------
  def delete_user

    user = User.find(params[:id])
    user.destroy
    redirect_to :controller => 'agencies', :action => 'users'
    
  end
  
  def edit
    @user = User.find(params[:id])
  end

  #----------------------------------------------------------------------------
  # Update an agency user
  #----------------------------------------------------------------------------
  def update

    # find the user
    @user = User.find(params[:id])

    # update the attribs
    @user.attributes = params[:user]

    # get the roles
    @user.roles = params[:user_manager] if !params[:user_manager].blank?
    @user.roles += "," + params[:settings] if !params[:settings].blank?
    @user.roles += "," + params[:invoicing] if !params[:invoicing].blank?
    @user.roles += "," + params[:reports] if !params[:reports].blank?

    @user.roles.slice!(0,1) if !@user.roles =~ /^,.+/.nil?

    @user.roles = @user.roles if current_user.id == @user.id
    @user.only_basic_validation = true

    # save the user
    @user.save

    redirect_to users_agency_path
    
  end

  #----------------------------------------------------------------------------
  # process request for approver
  #----------------------------------------------------------------------------
  def process_request

    # find the request
    approver_request = ApproverRequest.find_by_code(params[:code])
    approver_request.status = params[:commit].upcase

    success = false

    # find the client
    client = Client.find(approver_request.client_id)

    # find the user
    user = User.find(approver_request.user_id)

    # GO
    User.transaction do

      # if not already added... add
      if !client.users.include?(user)

        client.users << user

      end

      # did we save ok?
      success = approver_request.save

    end
    
    if success

      flash[:notice] = "Thank you. You have been added as an approver for #{client.name}."

    else

      flash[:alert] = "We were unable to add you as an approver at this time"
      
    end

    render :approver_request, :layout => 'login'

  end

  #----------------------------------------------------------------------------
  # View the approver reuqest
  #----------------------------------------------------------------------------
  def approver_request

    # get the code
    code = params[:code]

    if !code.nil?

      # find the request
      @approver_request = ApproverRequest.find_by_code(code)

    else

      flash[:alert] = "Invalid Request"

    end

    render :layout => 'login'

  end

  #----------------------------------------------------------------------------
  # Handle forgotten pwd
  #----------------------------------------------------------------------------
  def forgot_password

    flash[:notice] = nil
    flash[:alert] = nil

    return unless request.post?

    # find the user by email
    if @user = User.find_by_email(params[:user][:email])

      @user.forgot_password

      # save user - they will get email
      if @user.save(false)

        flash[:notice] = "An email has been sent to your address"

      end

    else

      flash[:alert] = "Could not find a user with that email address!"

    end

    redirect_back_or_default('/login')

  end

  #----------------------------------------------------------------------------
  # Handle forgotten username (NOT USED)
  #----------------------------------------------------------------------------
  def forgot_username

#    return unless request.post?
#
#    if @user = User.find_by_email(params[:user][:email])
#      @user.forgot_username
#      @user.save
#      flash[:notice] = "An email has been sent containing your username"
#      redirect_back_or_default('/login')
#    else
#      flash[:alert] = "Could not find a user with that email address"
#    end

  end

  #----------------------------------------------------------------------------
  # Change password
  #----------------------------------------------------------------------------
  def change_password

    # find the user
    @user = User.find(params[:user][:id])

    # set the passwords
    @user.password = params[:user][:password]
    @user.password_confirmation = params[:user][:password_confirmation]

    if !@user.password.blank? && !@user.password_confirmation.blank?

      if @user.password != @user.password_confirmation

        flash[:alert] = 'Passwords do not match'

      else

        # reset password
        @user.reset_password
        @user.email_confirmation = @user.email
        @user.only_basic_validation = true

        # save
        if @user.save

          flash[:notice] = "Password reset successful"

        else

          flash[:alert] = "Password reset failed"

        end

      end

    else

      flash[:alert] = "You must enter a new password"

    end
    
    redirect_to edit_contractor_path(@user.contractor)

  end

  #----------------------------------------------------------------------------
  # Handle resetting password
  #----------------------------------------------------------------------------
  def reset_password

    # find by reset code
    @user = User.find_by_password_reset_code(params[:id])
    
    if @user

      render :layout => "login"
      return

    end unless params[:user]

    # perform reset
    if ((params[:user][:password] && params[:user][:password_confirmation]) &&
                            !params[:user][:password_confirmation].blank?)
      self.current_user = @user #for the next two lines to work
      current_user.password_confirmation = params[:user][:password_confirmation]
      current_user.password = params[:user][:password]
      current_user.only_basic_validation = true
      current_user.email_confirmation = current_user.email
      current_user.reset_password
      flash[:notice] = current_user.save ? "Password reset successful." : "Password reset failed."
      redirect_back_or_default('/login')

    else

      flash[:alert] = "Password mismatch"

    end
    
  end
    
end