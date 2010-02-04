require 'digest/sha1'
class User < ActiveRecord::Base

  #############################################################################
  # Relationships
  #############################################################################
  belongs_to :agency
  has_many :approver_requests, :dependent => :destroy
  has_and_belongs_to_many :clients
  has_many :permissions
  has_many :roles, :through => :permissions

  #############################################################################
  # Other attributes
  #############################################################################
  attr_accessor :password, :email_confirmation, :only_basic_validation, :setup
  attr_accessible :login, :email, :password, :password_confirmation, :password_reset_code,
                  :only_basic_validation, :contractor, :agency_id, :contractor_id,
                  :type, :admin, :allowEmailApproval, :addr1, :city,
                  :title, :lastName, :addr2, :region, :postCode, :addr3, :firstName,
                  :mobile, :phone, :email_confirmation

  #############################################################################
  # Call back events
  #############################################################################

  #----------------------------------------------------------------------------
  # When saving, encrypt password
  #----------------------------------------------------------------------------
  before_save :encrypt_password

  #----------------------------------------------------------------------------
  # When creating making the activation and password reset code
  #----------------------------------------------------------------------------
  before_create :make_activation_code, :make_password_reset_code

  #############################################################################
  # Validation
  #############################################################################
  validates_presence_of     :login, :message => 'Login cannot be blank'
  validates_presence_of     :email, :message => 'Email cannot be blank'
  validates_format_of       :email, :with => /^([a-zA-Z0-9]+[a-zA-Z0-9._%-]*@(?:[a-zA-Z0-9-]+\.)+[a-zA-Z]{2,4})$/i, :message => "Email not in the correct format"
  validates_presence_of     :firstName, :message => 'First name cannot be blank'
  validates_presence_of     :lastName, :message => 'Last name cannot be blank'
  validates_presence_of     :title, :message => 'Title must be present'
  validates_presence_of     :password,                   :if => :password_required?, :message => 'Password cannot be blank'
  validates_presence_of     :password_confirmation,      :if => :password_required?, :message => 'You must confirm the password'
  validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?, :message => 'Passwords do not match'
  validates_length_of       :login,    :within => 3..15, :message => 'Login must be between 3 and 15 characters'
  validates_length_of       :email,    :within => 3..100, :message => 'Email is invalid'
  validates_uniqueness_of   :email, :case_sensitive => false, :message => 'The supplied email address is already in use'
  validates_uniqueness_of   :login, :case_sensitive => false, :message => 'The supplied login is already in use'
  validates_format_of       :login, :with => /^\w+$/, :on => :create, :message => 'Login is not in the correct format'
  validates_presence_of     :addr1, :message => 'Addr1 cannot be blank', :if => Proc.new {|u| u.only_basic_validation == false }
  validates_presence_of     :city, :message => 'City cannot be blank', :if => Proc.new {|u| u.only_basic_validation == false }
  validates_presence_of     :postCode, :message => 'Post Code cannot be blank', :if => Proc.new {|u| u.only_basic_validation == false }
  validates_length_of       :firstName, :maximum => 25, :message => 'Firstname is too long'
  validates_length_of       :lastName, :maximum => 25, :message => 'Lastname is too long'
  validates_length_of       :addr1, :maximum => 75, :message => 'Addr1 is too long', :allow_nil => true, :if => Proc.new {|u| u.only_basic_validation == false }
  validates_length_of       :addr2, :maximum => 75, :message => 'Addr2 is too long', :allow_nil => true, :if => Proc.new {|u| u.only_basic_validation == false }
  validates_length_of       :addr3, :maximum => 75, :message => 'Addr3 is too long', :allow_nil => true, :if => Proc.new {|u| u.only_basic_validation == false }
  validates_length_of       :city, :maximum => 75, :message => 'City is too long', :allow_nil => true, :if => Proc.new {|u| u.only_basic_validation == false }
  validates_length_of       :region, :maximum => 75, :message => 'Region is too long', :allow_nil => true, :if => Proc.new {|u| u.only_basic_validation == false }
  validates_length_of       :postCode, :maximum => 15, :message => 'Postcode is too long', :allow_nil => true, :if => Proc.new {|u| u.only_basic_validation == false }
  validates_length_of       :email, :maximum => 100, :message => 'Email is too long'
  validates_length_of       :phone, :maximum => 30, :message => 'Phone number is too long', :allow_nil => true, :if => Proc.new {|u| u.only_basic_validation == false }
  validates_length_of       :mobile, :maximum => 30, :message => 'Mobile number is too long', :allow_nil => true, :if => Proc.new {|u| u.only_basic_validation == false }

  #############################################################################
  # Overridden methods
  #############################################################################
  def validate

    if self.email != @email_confirmation

      errors.add(:email_confirmation, "Email addresses do not match")

    end
    
  end

  #############################################################################
  # Custom Methods
  #############################################################################

  
  def activate

    @activated = true
    self.activated_at = Time.now.utc
    self.activation_code = nil
    self.state = 'active'

    save(false)
    
  end

  #----------------------------------------------------------------------------
  # is the user active? if theres an activation code they're not activated yet
  #----------------------------------------------------------------------------
  def active?

    activation_code.nil?
    
  end

  #----------------------------------------------------------------------------
  # create the next draft timesheet for the user
  #----------------------------------------------------------------------------
  def create_draft_timesheets
    
    conditions = []
    conditions.add_condition!(["ctor.id = ?", self.contractor_id])
    conditions.add_condition!("c.status in ('ACTIVE', 'INACTIVE')")
    
    active_contracts = Contract.find(:all, :conditions => conditions, :joins => "c, contractors ctor", :select => "c.*")
    
    for contract in active_contracts
      
      contract.create_next_timesheet
      
    end
    
  end
  
  #----------------------------------------------------------------------------
  # does the user belong to the supplied role?
  #----------------------------------------------------------------------------
  def has_role?(role)

    return false if self.roles.nil? 
    
    for r in self.roles do
      
      if r.name == role
        
        return true
        break
      
      end
      
    end
    
    return false
    
  end
  
  #----------------------------------------------------------------------------
  # See if access to the role is readonly
  #----------------------------------------------------------------------------
  def is_role_read_only?(role)
    
    roles = self.roles.select {|r| r.name == role }
    
    if roles.length == 0
      
      return false
    
    else
      
      return permissions.select {|p| p.role.name == role}[0].readOnly?
        
    end
  
  end
  
  #----------------------------------------------------------------------------
  # find all the approvers needing alerts for oustanding timesheets
  #----------------------------------------------------------------------------
  def self.get_approvers_with_outstanding_timesheets(agency_id, cut_off_date)

    conditions = []
    conditions.add_condition!("cu.user_id = u.id")
    conditions.add_condition!("t.contract_id = cu.contract_id")
    conditions.add_condition!("c.id = cu.contract_id")
    conditions.add_condition!("cl.id = c.client_id")
    conditions.add_condition!("t.status in ('SUBMITTED', 'REJECTED')")
    conditions.add_condition!(["cl.agency_id = ?", agency_id])
    conditions.add_condition!(["ADDDATE(t.startDate, 6) < ?", cut_off_date])
        
    find(:all, :conditions => conditions, :joins => "u, contracts_users cu, timesheets t, contracts c, clients cl", :select => "distinct u.*")
    
  end
  
  #----------------------------------------------------------------------------
  # find all the contractors needing alerts for oustanding timesheets
  #----------------------------------------------------------------------------
  def self.get_contractors_with_outstanding_timesheets(agency_id, cut_off_date)

    conditions = []
    conditions.add_condition!("ctr.user_id = u.id")
    conditions.add_condition!("cc.contractor_id = ctr.id")
    conditions.add_condition!("c.id = cc.contract_id")
    conditions.add_condition!("cl.id = c.client_id")
    conditions.add_condition!("t.contract_id = c.id")
    conditions.add_condition!("t.status in ('DENIED', 'DRAFT')")
    conditions.add_condition!(["cl.agency_id = ?", agency_id])
    conditions.add_condition!(["ADDDATE(t.startDate, 6) < ?", cut_off_date])
    
    find(:all, :conditions => conditions, :joins => "u, contractors ctr, contractors_contracts cc, contracts c, clients cl, timesheets t", :select => "distinct u.*")
    
  end
  
  #----------------------------------------------------------------------------
  # Get the workers related to the approver
  #----------------------------------------------------------------------------
  def self.get_workers_for_approver(approver_id, page, per_page)

		conditions = []
#		conditions.add_condition!('cc.contractor_id = users.contractor_id')
#		conditions.add_condition!('cu.contract_id = cc.contract_id')
#		conditions.add_condition!('ct.id = cc.contract_id')
#		conditions.add_condition!("ct.status != 'COMPLETE'")
#		conditions.add_condition!(['cu.user_id = ?', approver_id])
    
    conditions.add_condition!(["auc.approver_user_id = ?",approver_id])
#    conditions.add_condition!('auc.contract_id = users.contract_id')
    conditions.add_condition!('ct.contractor_user_id=users.id')
    conditions.add_condition!("ct.status != 'COMPLETE'")
		User.paginate(:page => page, :per_page => per_page, :conditions => conditions, :joins => ', contracts ct, approver_users_contracts auc', :order => 'users.lastName')

  end

  #----------------------------------------------------------------------------
  # generate a new password
  #----------------------------------------------------------------------------
  def generatepassword( len )
    
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    newpass = ""
    1.upto(len) { newpass << chars[rand(chars.size-1)] }
    self.password = newpass
    
    return newpass
  
  end

  #----------------------------------------------------------------------------
  # Authenticates a user by their login name and unencrypted password.
  # Returns the user or nil.
  #----------------------------------------------------------------------------
  def self.authenticate(login, password)

    if login.index('@').nil?

      u = find :first, :conditions => ['login = ? and activated_at IS NOT NULL', login] # need to get the salt

    else

      u = find :first, :conditions => ['email = ? and activated_at IS NOT NULL', login] # need to get the salt

    end

    u && u.authenticated?(password) ? u : nil
    
  end

  #----------------------------------------------------------------------------
  # Encrypts some data with the salt
  #----------------------------------------------------------------------------
  def self.encrypt(password, salt)

    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
    
  end

  #----------------------------------------------------------------------------
  # Encrypts the password with the user salt
  #----------------------------------------------------------------------------
  def encrypt(password)

    self.class.encrypt(password, salt)
    
  end

  #----------------------------------------------------------------------------
  # Is the user authenticated?
  #----------------------------------------------------------------------------
  def authenticated?(password)

    crypted_password == encrypt(password)
    
  end

  #----------------------------------------------------------------------------
  # Is there a remember_token?
  #----------------------------------------------------------------------------
  def remember_token?

    remember_token_expires_at && Time.now.utc < remember_token_expires_at
    
  end

  #----------------------------------------------------------------------------
  # Set remember me
  #----------------------------------------------------------------------------
  def remember_me
    remember_me_for 2.weeks
  end

  #----------------------------------------------------------------------------
  # Set remember me for a time period
  #----------------------------------------------------------------------------
  def remember_me_for(time)

    remember_me_until time.from_now.utc
    
  end

  #----------------------------------------------------------------------------
  # Set remember with a specific expiry
  #----------------------------------------------------------------------------
  def remember_me_until(time)

    self.remember_token_expires_at = time
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")

    save(false)

  end

  #----------------------------------------------------------------------------
  # Get rid of the remember tokens
  #----------------------------------------------------------------------------
  def forget_me

    self.remember_token_expires_at = nil
    self.remember_token            = nil

    save(false)

  end

  #----------------------------------------------------------------------------
  # Creates a new password reset code
  #----------------------------------------------------------------------------
  def forgot_password

    @forgotten_password = true
    self.make_password_reset_code
    
  end

  #----------------------------------------------------------------------------
  # Prepare the user for a password reset
  #----------------------------------------------------------------------------
  def reset_password

    # First update the password_reset_code before setting the
    # reset_password flag to avoid duplicate email notifications.
    #update_attributes(:password_reset_code => nil)
    @reset_password = true

  end

  #----------------------------------------------------------------------------
  # Set forgot username flag
  #----------------------------------------------------------------------------
  def forgot_username

    @forgotten_username = true

  end

  #----------------------------------------------------------------------------
  # Has the user forgotten thir password?
  #----------------------------------------------------------------------------
  def recently_forgot_password?

    @forgotten_password

  end

  #----------------------------------------------------------------------------
  # Has the user reset the password?
  #----------------------------------------------------------------------------
  def recently_reset_password?

    @reset_password

  end

  #----------------------------------------------------------------------------
  # has the user forgotten their password?
  #----------------------------------------------------------------------------
  def recently_forgot_username?

    @forgotten_username
    
  end

  #----------------------------------------------------------------------------
  # Has the user been activated?
  #----------------------------------------------------------------------------
  def recently_activated?

    @activated

  end

  #----------------------------------------------------------------------------
  # Get the full name of the user, i.e. Mary Smith
  #----------------------------------------------------------------------------
  def full_name

    return "#{self.firstName} #{self.lastName}"
    
  end

  #----------------------------------------------------------------------------
  # Get the users last name and title, i.e. Mr Johnson
  #----------------------------------------------------------------------------
  def last_name_with_title

    return "#{self.title} #{self.lastName}"

  end

  #----------------------------------------------------------------------------
  # Find the user by their remember token
  #----------------------------------------------------------------------------
  def self.find_by_remember_token(token)

    conditions_string = 'remember_token=?'
    User.find(:first, :conditions => [ conditions_string, token])
    
  end

  #----------------------------------------------------------------------------
  # Find all contractors for an agency
  #----------------------------------------------------------------------------
  def self.find_contractor_users_by_agency(agencyId)
#    conditions = []
#    conditions.add_condition!(["contractors_contracts.contractor_id = users.contractor_id and contracts.id = contractors_contracts.contract_id and clients.id = contracts.client_id and clients.agency_id = ?", agencyId])
#    User.find(:all, :conditions => conditions, :order => 'lastName asc', :joins => ', contractors_contracts, contracts, clients').uniq
  User.find(:all, :conditions =>["agency_id =?",agencyId], :order => 'lastName asc').uniq
  end

  #----------------------------------------------------------------------------
  # Find all contractors for an agency by status of contract
  #----------------------------------------------------------------------------
  def self.find_by_agency_by_status(agencyId, page, per_page, status, order)

    sql = "SELECT distinct u.*  FROM `users` u
            INNER JOIN contracts ON contracts.id = u.contract_id
            INNER JOIN clients ON clients.id = contracts.client_id
            WHERE clients.agency_id = #{agencyId.to_s} and u.type = 'ContractorUser'"

    if status.nil?

      status = 'ACTIVE'

    else

      status = case

      when status.downcase == "with active or future contracts"

        "FUTURE"

      when status.downcase == "with active contracts"

        "ACTIVE"

      when status.downcase == "with completed contracts"

        "INACTIVE"

      else

        "ALL"

      end

    end

    if status != 'ALL'

      if status == 'FUTURE'

        sql += " AND contracts.status = 'ACTIVE' OR (contracts.status = 'INACTIVE' AND contracts.startDate > now())"

      else

        if status == 'INACTIVE'

          sql += " AND contracts.status IN ('INACTIVE', 'COMPLETE')"

        else

          sql += " AND contracts.status = '#{status}'"

        end

      end

    end

    sql += " ORDER BY #{order}"
    users = self.find_by_sql(sql)

    return users.paginate(:page => page, :per_page => per_page)

  end

protected

  #----------------------------------------------------------------------------
  # Encrypt the pwd
  #----------------------------------------------------------------------------
  def encrypt_password

    return if password.blank?
    
    self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
    self.crypted_password = encrypt(password)

  end

  #----------------------------------------------------------------------------
  # Is the pwd required?
  #----------------------------------------------------------------------------
  def password_required?

    crypted_password.blank? || !password.blank?

  end

  #----------------------------------------------------------------------------
  # Create an activation code
  #----------------------------------------------------------------------------
  def make_activation_code

    self.activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
    
  end

  #----------------------------------------------------------------------------
  # Make a pwd reset code
  #----------------------------------------------------------------------------
  def make_password_reset_code

    self.password_reset_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )

  end

end