class ContractorUser < User

  #############################################################################
  # Relationships
  #############################################################################

  has_many :timesheets
  has_many :contracts
  
  #############################################################################
  # Other attributes
  #############################################################################
#  accepts_nested_attributes_for :user
#  attr_accessible :user_id, :vatNumber, :companyName, :companyNumber, :user_attributes

  #############################################################################
  # Validation
  #############################################################################
#  validates_length_of :companyNumber, :maximum => 30, :message => 'Company number is too long', :allow_nil => true
#  validates_length_of :vatNumber, :maximum => 30, :message => 'VAT number is too long', :allow_nil => true
#  validates_length_of :companyName, :maximum => 100, :message => 'Company name is too long', :allow_nil => true

  #############################################################################
  # Custom Methods
  #############################################################################

  #----------------------------------------------------------------------------
  # Get the current contracts for this contractor
  #----------------------------------------------------------------------------
  def current_contracts

    self.contracts.select { |contract| contract.status != 'COMPLETE' }

  end

  #----------------------------------------------------------------------------
  # Get contractors that have active contracts
  #----------------------------------------------------------------------------
  def self.get_all_active(agency_id)

    contractors = {}
    Client.find(:all, ["agency_id = ?", agency_id]).select {|cl| cl.contracts.select { |c| contractors[c.contractors[0].user.full_name] = c.contractors[0].id } }
    return contractors

  end
end
