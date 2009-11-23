class Contractor < ActiveRecord::Base

  #############################################################################
  # Relationships
  #############################################################################
  has_and_belongs_to_many :contracts
  has_one :user
  has_many :timesheets

  #############################################################################
  # Other attributes
  #############################################################################
  accepts_nested_attributes_for :user
  attr_accessible :user_id, :vatNumber, :companyName, :companyNumber, :user_attributes
  
  #############################################################################
  # Validation
  #############################################################################
  validates_length_of :companyNumber, :maximum => 30, :message => 'Company number is too long', :allow_nil => true
  validates_length_of :vatNumber, :maximum => 30, :message => 'VAT number is too long', :allow_nil => true
  validates_length_of :companyName, :maximum => 100, :message => 'Company name is too long', :allow_nil => true

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
  def self.get_all_active
    
    conditions = []
    conditions.add_condition!("c.id = cc.contractor_id")
    conditions.add_condition!("cc.contract_id = ct.id")
    conditions.add_condition!("u.id = c.user_id")
    conditions.add_condition!("ct.status != 'COMPLETE'")
    
    self.find(:all, :conditions => conditions, :select => "c.id, CONCAT(u.firstName, ' ', u.lastName) as name", :joins => "c, contractors_contracts cc, contracts ct, users u", :order => "u.lastName asc")
    
  end
  
end