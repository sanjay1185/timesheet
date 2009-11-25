class Contract < ActiveRecord::Base

  #############################################################################
  # Relationships
  #############################################################################
  belongs_to :client
  has_and_belongs_to_many :users
  has_many :timesheets, :dependent => :destroy
  has_and_belongs_to_many :contractors

  #----------------------------------------------------------------------------
  # Custom finder for fetching rates so that Unpaid and Sickness are included
  #----------------------------------------------------------------------------
  has_many :rates, :dependent => :destroy, :finder_sql => 'select * from rates where contract_id = 0 or contract_id = #{id}',
                   :counter_sql => 'SELECT COUNT(*) FROM rates WHERE contract_id = 0 or contract_id = #{id}' do

      def find(*args)
          options = args.extract_options!
          sql = @finder_sql
          sql += " ORDER BY #{options[:order]}" if options[:order]
          sql += sanitize_sql [" LIMIT ?", options[:limit]] if options[:limit]
          sql += sanitize_sql [" OFFSET ?", options[:offset]] if options[:offset]

          Rate.find_by_sql(sql)
      end
      
    end

  #############################################################################
  # Call back events
  #############################################################################

  #----------------------------------------------------------------------------
  # Remove rates manually as we don't want to delete Unpaid and Sickness etc
  #----------------------------------------------------------------------------
  after_destroy :remove_rates

  #----------------------------------------------------------------------------
  # When saving a rate we need to check if contract.allowOvertime is set
  #----------------------------------------------------------------------------
  after_save :check_allow_overtime

  #############################################################################
  # Other attributes
  #############################################################################
  accepts_nested_attributes_for :rates
  named_scope :descending, :order => "startDate DESC"
  attr_accessible :status, :rateType, :dayRate, :startDate, :ref, :position, :client_id, :client,
                  :endDate, :margin, :rates_attributes, :calcChargeRateAsPAYE,
                  :requireTimes, :requireFullWeek, :allowOvertime, :allowBankHolidays

  #############################################################################
  # Validation
  #############################################################################
  validates_presence_of :ref, :message => 'Ref must be supplied'
  validates_presence_of :startDate, :message => 'Start Date must be supplied'
  validates_presence_of :endDate, :message => 'End Date must be supplied'
  validates_presence_of :position, :message => 'Position must be supplied'
  validates_length_of :position, :maximum => 75, :message => 'Position must be 75 characters or less'
  validates_uniqueness_of :ref, :scope => [:client_id], :message => 'Ref must be unique for this client'
  validates_length_of :ref, :maximum => 15

  #############################################################################
  # Overridden methods
  #############################################################################
  def validate

    # start date can't be nil, and must be a monday
    if !startDate.nil? && startDate.wday != 1
      errors.add(:startDate, 'Start date must be on a Monday')
    end

    # check the start date is not less then the end date
    if !startDate.nil? && startDate > endDate
      errors.add(:startDate, 'Start date must be before end date')
    end

    # if allowOvertime is set, is there an Overtime rate?
    if allowOvertime == true

      has_overtime = false

      rates.each {|r|

        if r.category == 'Overtime' && r.active?

          has_overtime = true
          break

        end

      }

      # display error if no overtime rate
      errors.add(:allowOvertime, "There is no (active) overtime rate. Create/activate an overtime rate before allowing overtime on the contract") if !has_overtime
      
    end

    # *** Code below handles extending a contract ***
   
    # get the last timesheet
    last_ts = last_timesheet

    # don't continue validation if there are no timesheets
    return if last_timesheet.nil?

    # set the next available end date to the last timesheet end date
    next_available_end_date = last_ts.startDate + 6

    # if the end date was mid week, then the last timesheet will have
    # disabled entried that could be used as an extended end date
    last_ts.timesheet_entries.each {|te|

      if te.disabled?

        next_available_end_date = te.dateValue - 1
        break
        
      end

    }

    # if the end date is less than the next available date, error
    if endDate < next_available_end_date

      errors.add(:endDate, "Invalid end date. Please select an end date on or after #{next_available_end_date.to_formatted_s(:uk_date)}")
    
    else
      
      # re-enable any days on last timesheet that are less than or equal to end date
      # this is only allowed if the date is a disabled timsheet entry
      modified = false

      # need to re-enable disabled entries that are less than new end date
      last_ts.timesheet_entries.each {|e|

        if e.dateValue <= endDate && e.disabled?

          e.disabled = false
          modified = true

        end
        
      }

      # if we have modified the last timesheet, we need to set it as draft
      if modified == true
       
        if last_ts.status != 'DRAFT'

          Contract.transaction do

            last_ts.resubmit = true 
            last_ts.status = 'DRAFT'
            last_ts.userName = current_user.full_name
            Invoice.remove_timesheet(last_ts)
            last_ts.save(false)

          end

        end

        # set the contract status to ACTIVE if not already set
        self.status = 'ACTIVE' if self.status != 'ACTIVE'

      end
      
    end
    
  end

  #############################################################################
  # Custom Methods
  #############################################################################
  def self.get_active_contracts_for_month(date)

    sql = "select count(distinct c.id) as total, a.Name as agencyName, a.id as agencyId from contracts c "
    sql << "inner join clients cl on cl.id = c.client_id "
    sql << "inner join agencies a on a.id = cl.agency_id "
    sql << "inner join timesheets t on t.contract_id = c.id "
    sql << "right outer join agency_invoices ai on ai.agency_id = a.id "
    sql << "where c.startDate <= '#{date}' and c.endDate >= '#{date}' and t.status != 'DRAFT' "
    sql << "and a.trial = 0"
    sql << "and ai.invoiceDate = '#{date}' and ai.id is null group by a.id having total > 0"

    return self.find_by_sql(sql)
    
  end
  
  #----------------------------------------------------------------------------
  # get all active contracts for a agency
  #----------------------------------------------------------------------------
  def self.get_all_active(agency_id, page, per_page, order)

    conditions = []
    conditions.add_condition!("c.client_id = cl.id")
    conditions.add_condition!("t.contract_id = c.id")
    conditions.add_condition!("c.status != 'COMPLETE'")
    conditions.add_condition!("t.status != 'DRAFT'")
    conditions.add_condition!(["cl.agency_id = ?", agency_id])
    
    paginate(:page => page, :per_page => per_page, :conditions => conditions, :select => "c.*, count(t.id) as timesheet_count", :joins => "c, clients cl, timesheets t", :order => order)
    
  end
  
  #----------------------------------------------------------------------------
  # get all the contract ids that were active for a month
  #----------------------------------------------------------------------------
  def self.get_ids_for_month(date, agency_id)
    
    conditions = []
    conditions.add_condition!(["contracts.startDate <= ?", date])
    conditions.add_condition!(["contracts.endDate >= ?", date])
    conditions.add_condition!("cl.id = contracts.client_id")
    conditions.add_condition!("a.id = cl.agency_id")
    conditions.add_condition!("t.status != 'DRAFT'")
    conditions.add_condition!(["a.id >= ?", agency_id])
    records = self.find(:all, :conditions => conditions, :select => " distinct contracts.id", :joins => ", clients cl, agencies a, timesheets t")
    
    ids = []
    records.select {|c| ids << c.id}

    return ids
    
  end

  #----------------------------------------------------------------------------
  # get the last timesheet for this contract
  #----------------------------------------------------------------------------
  def last_timesheet
    sheets = Timesheet.find_by_sql ["select * from timesheets where contract_id = ? order by id desc LIMIT 1;", self.id]
    if sheets.length > 0
      return sheets[0]
    else
      return nil
    end
  end

  #----------------------------------------------------------------------------
  # check whether the user is already an approver
  #----------------------------------------------------------------------------
  def is_approver?(user)
    self.users.include?(user)
  end

  #----------------------------------------------------------------------------
  # check whether the user is already a worker
  #----------------------------------------------------------------------------
  def is_contractor?(user)
    self.contractors.include?(user)
  end

  #----------------------------------------------------------------------------
  # get contracts by status
  #----------------------------------------------------------------------------
  def self.get_by_agency_and_status(agency_id, status)
    
    conditions = []

    conditions.add_condition!('c.client_id = cl.id')
    conditions.add_condition!(['cl.agency_id = ?', agency_id])
    conditions.add_condition!(["c.status = ?", status])
    
    return Contract.find(:all, :conditions => conditions, :joins => "c, clients cl", :select => "c.*")
    
  end
  
  #----------------------------------------------------------------------------
  # create the next draft timesheet for this contract
  #----------------------------------------------------------------------------
  def create_next_timesheet
  
    # only proceed if the contract is active
    return if !["INACTIVE", "ACTIVE"].include?(self.status)
      
    # get the last date, and add 7 days!
    last_ts = last_timesheet
    
    # only create the timesheet if we don't already have one for next week
    if !last_ts.nil? && last_ts.startDate > Date.today
      
      return
      
    end
    
    # create the timesheet and save in a transaction
    Contract.transaction do
      
      new_ts = self.timesheets.build
      new_ts.startDate = last_ts.nil? ? self.startDate : last_ts.startDate + 7
      new_ts.status = "DRAFT"
      new_ts.contractor_id = self.contractors[0].id
      new_ts.rateType = self.rateType
      new_ts.userName = "System"
      rates_manager = RatesManager.new(self.id)
      unpaid_rate = rates_manager.get_unpaid_rate
      std_rate = rates_manager.get_default_standard_rate
      
      # set up the entries
      for d in 0..6
      
        # create it
        ts_entry = new_ts.timesheet_entries.build
        # set the date
        ts_entry.dateValue = new_ts.startDate + d
        # set the rate type
        ts_entry.rateType = self.rateType
        # set the requirements
        ts_entry.requireFullWeek = self.requireFullWeek
        ts_entry.requireTimes = self.requireTimes

        # set rate to standard
        ts_entry.rate_id = std_rate.id

        # if it's a weekend - set the rate to unpaid
        if ts_entry.dateValue.wday == 0 || ts_entry.dateValue.wday == 6
          ts_entry.rate_id = unpaid_rate.id
        end

        # if it's a bank holiday, set the rate to unpaid
        if BankHoliday.is_holiday(ts_entry.dateValue, 'UK')
          ts_entry.is_bank_hol = true
          ts_entry.rate_id = unpaid_rate.id
        else
          ts_entry.is_bank_hol = false
        end

        # check for date after contract end date and disable
        ts_entry.disabled = true if ts_entry.dateValue > self.endDate
        
      end
      
      # set the contract status to complete if this is the last timesheet
      if new_ts.startDate + 7 >= self.endDate
      
        self.update_attribute(:status, "COMPLETE")
      
      end
      
      # save, no validation
      new_ts.save(false)
      
      return new_ts
      
    end

    return 

  end
  
protected

  #----------------------------------------------------------------------------
  # set contract.allowOvertime based on whether there are Overtime rates
  #----------------------------------------------------------------------------
  def check_allow_overtime

    @overtime_rate_count = Rate.count(:conditions => ["category = 'Overtime' and active = ? and contract_id = ?", true, id])

    if @overtime_rate_count == 0 && allowOvertime?

      self.allowOvertime = false
      save(false)
      
    end
    
  end

  #----------------------------------------------------------------------------
  # manually remove the rates, skipping the default Unpaid/Sickness
  #----------------------------------------------------------------------------
  def remove_rates

    Contract.transaction do

      for rate in self.rates

        # dont remove the the default 'unpaid' rate
        rate.destroy unless rate.contract_id == 0

      end

    end
    
  end

end
