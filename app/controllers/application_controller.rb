# Likewise, all the methods added will be available for all controllers.
# Filters added to this controller apply to all controllers in the application.
class ApplicationController < ActionController::Base

  # use the authentication system
  include AuthenticatedSystem

  # use the exception alert system
  include ExceptionNotifiable
  # make sure the local ip is considered local

  consider_local "174.143.27.147"
  
  helper :all # include all helpers, all the time
  helper :errors

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '0a854d3d6c219d463038184fd461d018'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password

#  before_filter :login_from_cookie
#  def login_from_cookie
#    return unless cookies[:auth_token] && self.current_user.nil?
#    user = User.find_by_remember_token(cookies[:auth_token])
#    if user && !user.remember_token_expires.nil? && Time.now < user.remember_token_expires
#      self.current_user = user
#      if !user.agency_id.nil? && user.agency_id > 0
#        session[:agencyId] = user.agency_id
#      end
#    end
#  end

  attr_accessor :readonly

  #----------------------------------------------------------------------------
  # Render as a pdf instead of erb (NOT USED!)
  #----------------------------------------------------------------------------
  def render_to_pdf(options = nil)

    data = render_to_string(options)

    pdf = PDF::HTMLDoc.new

    pdf.set_option :bodycolor, :white
    pdf.set_option :toc, false
    pdf.set_option :landscape, true
    pdf.set_option :links, false
    pdf.set_option :webpage, true
    pdf.set_option :left, '2cm'
    pdf.set_option :right, '2cm'

    pdf << data
    
    pdf.generate
    
  end

  #----------------------------------------------------------------------------
  # Render as a pdf using PD4ML
  #----------------------------------------------------------------------------
  def render_pdf(orientation, options = nil)

    data = render_to_string(options)

    pdf = PD4ML.new(

      :allow_annotate             => false,
      :page_orientation           => orientation,
      :allow_copy                 => true,
      :allow_modify               => true,
      :allow_print                => true

    )

    pdf << data

    pdf.generate
    
  end

  #----------------------------------------------------------------------------
  # Defines default sort order for sorting columns
  #----------------------------------------------------------------------------
  def sort_order(default)

    "#{(params[:c] || default.to_s).gsub(/[\s;'\"]/,'')} #{params[:d] == 'down' ? 'DESC' : 'ASC'}"

  end

  #----------------------------------------------------------------------------
  # Helper to redirect to login
  #----------------------------------------------------------------------------
  def redirect_to_login

    redirect_to('/login')

  end

  #----------------------------------------------------------------------------
  # Check the current user belongs to the specified role
  #----------------------------------------------------------------------------
  def check_role(role_required)

    logger.debug("check_role(#{role_required})")
    
    if (!current_user.has_role?(role_required))
      
      logger.debug("user #{current_user.full_name} does not have the #{role_required} role")
      
      session[:denied_url] = "#{SITE}#{request.request_uri}"
      redirect_to("/agencies/#{session[:agencyId]}/denied") if current_user.userType == 'agency'
      redirect_to("/approverdashboard/denied") if current_user.userType == 'approver'

    end
    
    logger.debug("user #{current_user.full_name} has the #{role_required} role")
    
  end
  
  #----------------------------------------------------------------------------
  # Check the current user belongs to the specified role
  #----------------------------------------------------------------------------
  def can_edit?(required_role)
    
    perm = current_user.permissions.select { |p| p.role.name == required_role}[0]
  
    @readonly= perm.nil? ? false : perm.readOnly?
    
  end
  
  #----------------------------------------------------------------------------
  # Check the userType field of the current user
  #----------------------------------------------------------------------------
  def check_type(required_user_type)

    if current_user.userType != required_user_type

      session[:denied_url] = "#{SITE}#{request.request_uri}"
      redirect_to("/agencies/#{session[:agencyId]}/denied") if current_user.userType == 'agency'
      redirect_to("/approverdashboard/denied") if current_user.userType == 'approver'
      redirect_to("/contractors/#{current_user.id}/denied") if current_user.userType == 'contractor'

    end

  end

  #----------------------------------------------------------------------------
  # If there is no current_user, we're not authenticated
  #----------------------------------------------------------------------------
  def authenticate

    redirect_to_login if current_user.nil?
    
  end
  
  def set_theme(name)

    if !name.blank?

      session[:theme] = name

    else

      session[:theme] = 'default'

    end

  end

end