class Rate < ActiveRecord::Base

  #############################################################################
  # Relationships
  #############################################################################
  belongs_to :contract

  #############################################################################
  # Validation
  #############################################################################
  validates_presence_of :name, :message => 'Name must be supplied'
  validates_presence_of :rateType, :message => 'Rate Type must be supplied'
  validates_presence_of :category, :message => 'Category must be supplied'
  validates_presence_of :chargeRate, :message => 'Charge Rate must be supplied'

  attr_accessible :category, :rateType, :name, :payRate, :contract_id, :comment,
                  :chargeRate, :default, :endDate, :effectiveDate, :active

  #############################################################################
  # Call back events
  #############################################################################

  #----------------------------------------------------------------------------
  # When deleting a rate, see if we need to disable overtime
  #----------------------------------------------------------------------------
  after_destroy :check_allow_overtime

  #############################################################################
  # Custom Methods
  #############################################################################

  #----------------------------------------------------------------------------
  # check if we are able to delete the rate (only can if it's not in use)
  #----------------------------------------------------------------------------
  def can_delete?

    entries = TimesheetEntry.count_by_sql("select count(*) from timesheet_entries where rate_id = #{id}")
    
    return entries == 0
    
  end

  #----------------------------------------------------------------------------
  # check to see if the rate is used in a draft
  #----------------------------------------------------------------------------
  def is_used_by_draft_timesheet?

    return Timesheet.is_draft_using_rate?(self.id, self.contract_id)
    
  end
  
  protected

  #----------------------------------------------------------------------------
  # check to see if there are overtime rates
  #----------------------------------------------------------------------------
  def check_allow_overtime

    return if self.contract.nil?

    @overtime_rate_count = Rate.count(:conditions => ["category = 'Overtime' and active = ? and contract_id = ?", true, contract_id])
    
    if @overtime_rate_count == 0 && self.contract.allowOvertime?

      self.contract.allowOvertime = false
      self.contract.save(false)

    end
    
  end
  
end
