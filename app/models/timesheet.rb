require 'digest/sha1'

class Timesheet < ActiveRecord::Base

  #############################################################################
  # Relationships
  #############################################################################
  belongs_to :contract
  belongs_to :contractor
  has_and_belongs_to_many :invoices
  has_many :timesheet_entries, :dependent => :destroy, :order => "dateValue asc, manual"

  #############################################################################
  # Call back events
  #############################################################################
 
  #----------------------------------------------------------------------------
  # When saving, get the current model and after save success, save history
  #----------------------------------------------------------------------------
  before_save :prepare_to_save

  #############################################################################
  # Other attributes
  #############################################################################
  accepts_nested_attributes_for :timesheet_entries
  attr_accessible :rateType, :startDate, :contract_id, :note, :contractor_id,
                  :timesheet_entries_attributes, :status, :userName
  attr_accessor :resubmit

  #############################################################################
  # Validation
  #############################################################################
  validates_length_of :note, :maximum => 255, :message => 'Note cannot be more than 255 characters', :allow_nil => true
  validates_length_of :userName, :maximum => 75, :message => 'User name must be 75 characters or less', :allow_nil => true
  
  #############################################################################
  # Overridden methods
  #############################################################################
  def validate

    # need to check that all entries for a single day only add up to 1
    if rateType == 'Day'

      # get all the entries that have rateType of 'Day'
      day_entries = timesheet_entries.select {|te| te.rateType == 'Day'}

      # if there are 7 then just return as there is nothing to check
      return if day_entries.length == 7

      for i in 0..6 do
        
        single_day_entries = timesheet_entries.select {|te| !te.deleted? && te.dateValue == startDate + i}

        next if single_day_entries.length == 1

        total = 0

        single_day_entries.each {|te| total += te.dayValue unless te.dayValue.nil?}
        
        if total > 1

          errors.add(:dayValue, "#{single_day_entries[0].dateValue.to_formatted_s(:uk_date)} cannot total more that one <i>Full</i> Day")
          next

        end

      end

    end

  end

  #############################################################################
  # Custom methods
  #############################################################################
  
  #----------------------------------------------------------------------------
  # End date for contract
  #----------------------------------------------------------------------------
  def end_date
    
    if !startDate.nil?
      
      return startDate + 7
    
    end
    
    return nil
    
  end
  
  #----------------------------------------------------------------------------
  # Expose the timesheet_entries as 'entries'
  #----------------------------------------------------------------------------
  def entries
  
    return self.timesheet_entries
  
  end

  #----------------------------------------------------------------------------
  # Can this timesheet be rejected?
  #----------------------------------------------------------------------------
  def can_reject?
  
    if self.status != 'APPROVED'
      
      return false
    
    elsif self.note.starts_with?("Manually approved. Updated by")
      
      return false
      
    else
    
      conditions = []
      conditions.add_condition!("note like 'Manually approved. Updated by%'")
      conditions.add_condition!(:original_timesheet_id => self.id)
      sheets = TimesheetHistory.find(:all, :conditions => conditions)
      return sheets.length == 0
    
    end
  
  end
  
  #----------------------------------------------------------------------------
  # Is there any history to show?
  #----------------------------------------------------------------------------
  def can_show_history?
    
    return TimesheetHistory.exists?(["(status = 'SUBMITTED' or status = 'MANUAL')", "original_timesheet_id = #{self.id.to_s}"])
    
  end
  
  #----------------------------------------------------------------------------
  # When was this timesheet submitted
  #----------------------------------------------------------------------------
  def submitted_on
  
    if status == 'SUBMITTED' || status == 'MANUAL'
      
      return updated_at
    
    end
    
    record = TimesheetHistory.find(:first, :conditions => "original_timesheet_id = #{self.id.to_s} and status in ('SUBMITTED', 'MANUAL')", :order => "updated_at desc")
    
    if record.nil?
      
      return nil
      
    else
      
      return record.updated_at
      
    end
    
  end
  
  #----------------------------------------------------------------------------
  # When was this timesheet approved
  #----------------------------------------------------------------------------
  def approved_on
  
    record = TimesheetHistory.find(:first, :conditions => "original_timesheet_id = #{self.id.to_s} and status = 'APPROVED'", :order => "updated_at desc")
    
    if record.nil?
      
      return nil
      
    else
      
      return record.updated_at
      
    end
    
  end
  
  #----------------------------------------------------------------------------
  # When was this timesheet denied
  #----------------------------------------------------------------------------
  def denied_on
  
    record = TimesheetHistory.find(:first, :conditions => "original_timesheet_id = #{self.id.to_s} and status = 'DENIED'", :order => "updated_at desc")
    
    if record.nil?
      
      return nil
      
    else
      
      return record.updated_at
      
    end
    
  end
  
  #----------------------------------------------------------------------------
  # When was this timesheet rejected
  #----------------------------------------------------------------------------
  def rejected_on
  
    record = TimesheetHistory.find(:first, :conditions => "original_timesheet_id = #{self.id.to_s} and status = 'REJECTED'", :order => "updated_at desc")
    
    if record.nil?
      
      return nil
      
    else
      
      return record.updated_at
      
    end
    
  end
  
  #----------------------------------------------------------------------------
  # Backup the current record before saving
  #----------------------------------------------------------------------------
  def prepare_to_save
           
    if !self.new_record?
      
      record = Timesheet.find(self.id)
      @current_record = TimesheetHistory.new
      @current_record.startDate = record.startDate
      @current_record.totalDays = record.totalDays
      @current_record.totalHours = record.totalHours
      @current_record.invoiced = record.invoiced
      @current_record.status = record.status
      @current_record.userName = record.userName
      @current_record.note = record.note
      @current_record.created_at = record.created_at
      @current_record.updated_at = record.updated_at
      @current_record.netAmount = record.netAmount
      @current_record.taxAmount = record.taxAmount
      @current_record.lastExportedDateTime = record.lastExportedDateTime
      
      @current_record.timesheet_entry_histories.clear
      @current_record.original_timesheet_id = record.id
      ents = TimesheetEntry.find(:all, :conditions => "timesheet_id = " + record.id.to_s)
      @current_record.update_entries_history(ents)
    
      ids = []
      
      # has anything been deleted?
      for entry in self.timesheet_entries do
        
        ids << entry.id if entry.deleted?
        
      end
      
      TimesheetEntry.destroy(ids) unless ids.blank?
      
      unless @current_record.nil? 

        @current_record.save
        
      end
      
    end

  end
    
  
  #----------------------------------------------------------------------------
  # Get the invoice date to use for this timesheet
  #----------------------------------------------------------------------------
  def get_invoice_date(monthly_start_day)
    # note: could add a rule for putting timesheet in invoice according to
    # how it's split over the week
    
    if self.contract.client.invoicePeriod.downcase == 'monthly'

      get_monthly_invoice_date(monthly_start_day, startDate)

    else

      return startDate + 6
    
    end

  end

  #----------------------------------------------------------------------------
  # calculate the values for this timesheet
  #----------------------------------------------------------------------------
  def calc

    sub_total = 0
    
    timesheet_entries.each {|entry|
      entry.chargeRate = entry.rate.chargeRate unless entry.disabled? || (entry.is_bank_hol == true && !contract.allowBankHoildays?)
      sub_total += entry.calc 
    }

    self.netAmount = sub_total
    
  end

  #----------------------------------------------------------------------------
  # See if there is a draft using this rate
  #----------------------------------------------------------------------------
  def self.is_draft_using_rate?(rate_id, contract_id)

    return self.find_by_sql("select ts.id from timesheets ts inner join timesheet_entries te on te.timesheet_id = ts.id where te.rate_id = #{rate_id} and ts.status = 'DRAFT' and ts.contract_id = #{contract_id}").length > 0

  end

  #----------------------------------------------------------------------------
  # run a timesheet report
  #----------------------------------------------------------------------------
  def self.run_report(page, per_page, from, to, status, approvalDate, client_id, contractor_id, sort_by, agency_id)

    conditions = []
    conditions.add_condition!(['timesheets.startDate >= ?', Date.strptime(from, "%B %d, %Y")]) unless from.nil?
    conditions.add_condition!(['timesheets.startDate <= ?', Date.strptime(to, "%B %d, %Y")]) unless to.nil?
    conditions.add_condition!(['timesheets.status = ?', status]) unless status == 'ANY'
    conditions.add_condition!(['CAST(timesheets.approvalDateTime AS DATE) = ?', Date.strptime(approvalDate, "%B %d, %Y")]) unless approvalDate.blank? 
    conditions.add_condition!(:contractor_id => contractor_id) unless contractor_id == '0'
    conditions.add_condition!(["timesheets.contract_id = contracts.id and contracts.client_id = ?", client_id]) unless client_id.blank? || client_id == "0"
    conditions.add_condition!(["clients.agency_id = ?", agency_id])

    paginate(:per_page => per_page, :page => page, :conditions => conditions, :select => 'distinct timesheets.*', :joins => ', contracts, clients', :order => sort_by)
    
  end

  #----------------------------------------------------------------------------
  # get all timesheets that require some action
  #----------------------------------------------------------------------------
  def self.get_all_requiring_action(agency_id, page, per_page)
    
    conditions = []
    conditions.add_condition!("t.contract_id = c.id")
    conditions.add_condition!(["cl.agency_id = ?", agency_id])
    conditions.add_condition!(["t.status in ('DRAFT', 'MANUAL', 'REJECTED', 'SUBMITTED', 'DENIED')"])
    paginate(:page => page, :per_page => per_page, :conditions => conditions, :joins => "t, contracts c, clients cl", :select => "distinct t.*")
    
  end
  
  #----------------------------------------------------------------------------
  # find all the timesheets for an agency
  #----------------------------------------------------------------------------
  def self.find_all_by_agency(page, per_page, agency, status, order)

    conditions = []
    conditions.add_condition!(["contracts.id = timesheets.contract_id and timesheets.contractor_id = contractors.id and contractors.user_id = users.id and clients.id = contracts.client_id and clients.agency_id = ?", agency.id])
    
    if status != 'ALL'

      if status == 'ANY'

        conditions.add_condition!(["timesheets.status IN ('DENIED', 'DRAFT', 'SUBMITTED', 'MANUAL', 'REJECTED')"])

      else

        conditions.add_condition!(["timesheets.status = ?", status])

      end

    end

    # rename the order columns
    # todo: this could change - we can put these in the erb
    o = order.split(' ')
    ordr = case o[0]
    when 'startDate' then 'timesheets.startDate'
    when 'endDate' then '(timesheets.startDate+7)'
    when 'status' then 'timesheets.status'
    when 'totalDays' then 'timesheets.totalDays'
    when 'totalHours' then 'timesheets.totalHours'
    when 'ref' then 'contracts.ref'
    when 'contractor' then 'users.firstName'
    end

    ordr += ' ' + o[1]

    paginate(:per_page => per_page, :page => page, :conditions => conditions, :joins => ", contracts, clients, agencies, contractors, users", :order => ordr).uniq
    
  end

  #----------------------------------------------------------------------------
  # find all the timesheets for requiring approval for an approver
  #----------------------------------------------------------------------------
  def self.requiring_approval(approver, page, per_page)

    conditions_string = "contracts_users.contract_id=timesheets.contract_id and contracts_users.user_id=? and timesheets.status in ('SUBMITTED', 'REJECTED')"

    paginate :page => page, :per_page => per_page, :conditions => [ conditions_string, approver.id ], :joins => ', contracts_users', :order => 'startDate ASC'

  end

  #----------------------------------------------------------------------------
  # get the timesheets for a contractor
  #----------------------------------------------------------------------------
  def self.get_all_for_contractor(contractor_id, page, per_page, order)
    
    paginate(:page => page, :per_page => per_page, :conditions => ["contractor_id = ?", contractor_id], :order => order)
    
  end
  
  #----------------------------------------------------------------------------
  # get the timesheets for a contractor by status
  #----------------------------------------------------------------------------
  def self.current_for_contractor(contractor, filter, date_period, page, per_page)

    if !filter.nil?

      if filter == 'Submitted'

        filter = " in ('SUBMITTED', 'MANUAL') "

      elsif filter == 'Outstanding'

        filter = " in ('DRAFT', 'DENIED') "

      else

        filter = " = '" + filter.upcase + "' "

      end

    else

      filter = " in ('DRAFT', 'DENIED') "

    end

    conditions_string = "status" + filter + "and contractor_id = ? and timesheets.startDate >= ?"
    
    paginate(:per_page => per_page, :page => page, :conditions => [conditions_string, contractor.id,  Date.today - date_period.to_i.months], :order => 'timesheets.startDate').uniq

  end

  protected

    ##----------------------------------------------------------------------------
    ## make a new approval code
    ##----------------------------------------------------------------------------
    #def make_approval_code
    #
    #  self.approveCode = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
    #  
    #end

  private

    #----------------------------------------------------------------------------
    # Get the invoice date to use for this timesheet
    #----------------------------------------------------------------------------
    def get_monthly_invoice_date(monthly_start_day, ts_start_date)

      ts_end_date = ts_start_date + 6

      monthly_end_day = case monthly_start_day

      when 2..31

        monthly_start_day - 1

      when 1

        31

      end

      invoice_date = nil

      if monthly_end_day >= 29 && monthly_end_day <= 31

        # check the end day is valid for the month of the timesheet
        invoice_date = Date.new(ts_end_date.year, ts_end_date.month, Date.new(ts_end_date.year, ts_end_date.month, -1).day)

      else

        invoice_date = Date.new(ts_end_date.year, ts_end_date.month, monthly_end_day)

        if ts_end_date > invoice_date

          invoice_date = invoice_date + 1.month
        
        end

      end

      return invoice_date

    end

private

  @current_record
  
end