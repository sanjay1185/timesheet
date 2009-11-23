class Agency < ActiveRecord::Base
  
  #############################################################################
  # Relationships
  #############################################################################
  has_many :clients, :order => 'name'
  has_many :users
  has_many :agency_invoices, :dependent => :destroy, :order => 'invoiceDate DESC',:limit => 18

  #############################################################################
  # Validation
  #############################################################################
  validates_presence_of :name, :message => 'Name cannot be blank'
  validates_length_of :name, :within => 3..100, :message => 'Name must be between 3 and 100 characters'
  validates_presence_of :addr1, :message => 'Addr1 cannot be blank'
  validates_length_of :addr1, :maximum => 75, :message => 'Addr1 must be 75 characters or less'
  validates_presence_of :city, :message => 'City cannot be blank'
  validates_length_of :city, :maximum => 75, :message => 'City must be 75 characters or less'
  validates_presence_of :postCode, :message => 'Post Code cannot be blank'
  validates_length_of :postCode, :maximum => 15, :message => 'Post Code must be 15 characters or less'
  validates_presence_of :phone, :message => 'Phone cannot be blank'
  validates_length_of :phone, :maximum => 30, :message => 'Phone must be 30 characters or less'
  validates_presence_of :fax, :message => 'Fax cannot be blank'
  validates_length_of :fax, :maximum => 30, :message => 'Fax must be 30 characters or less'
  validates_presence_of :email, :message => 'Email cannot be blank'
  validates_length_of :email, :maximum => 100, :message => 'Email must be 100 characters or less'
  
  #############################################################################
  # Custom Methods
  #############################################################################

  #----------------------------------------------------------------------------
  # Calculate how many days there are left on a client trial. Use the
  # created_at date and the current date to get the days.
  #----------------------------------------------------------------------------
  def days_left_of_trial
    
    # get the date without the time
    created_date = Date.new(created_at.year, created_at.month, created_at.day)

    # add 30 days to it
    end_date = created_date + 30

    # return the difference
    return (((end_date - Date.today).days / 60) / 60) / 24

  end

  #----------------------------------------------------------------------------
  # Increment the invoice number for an agency
  #----------------------------------------------------------------------------
  def self.increment_invoice_number(agency_id)

    # find the agency
    agency = Agency.find(agency_id)

    # get the next invoice number
    invoice_number = agency.nextInvoiceNumber

    # increment it
    agency.nextInvoiceNumber += 1

    # save it
    agency.save

    # return it
    return invoice_number

  end
  
  #----------------------------------------------------------------------------
  # Disable all users for the current agency. This is used for when the trial
  # period has expired.
  #----------------------------------------------------------------------------
  def disable_users

    # start a transaction
    Agency.transaction do

      # iterate through the users
      for u in self.users

        # update the user.state
        u.update_attribute(:state, 'suspended')

      end

    end

  end
  
end