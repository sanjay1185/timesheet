class Invoice < ActiveRecord::Base

  #############################################################################
  # Relationships
  #############################################################################
  belongs_to :client
  has_and_belongs_to_many :timesheets, :order => 'timesheets.startDate'

  #############################################################################
  # Custom Methods
  #############################################################################
  
  #----------------------------------------------------------------------------
  # search for invoices for clients
  #----------------------------------------------------------------------------
  def self.search(from, to, inactive, signed_off, client_id)

    conditions = []
    conditions.add_condition!(['invoiceDate >= ?', Date.strptime(from, "%B %d, %Y")]) unless from.nil?
    conditions.add_condition!(['invoiceDate <= ?', Date.strptime(to, "%B %d, %Y")]) unless to.nil?
    conditions.add_condition!('lastExportDate is NULL') unless signed_off == "on"
    conditions.add_condition!(['client_id = ?', client_id.to_i]) unless client_id.blank?
    conditions.add_condition!('inactive = 0') unless inactive == "on"
    
    Invoice.find(:all, :conditions => conditions, :order => 'invoiceDate ASC')
    
  end

  #----------------------------------------------------------------------------
  # remove a timesheet from an invoice and recalc
  #----------------------------------------------------------------------------
  def self.remove_timesheet(timesheet)

    inv = Invoice.find(:first, :conditions => ["its.timesheet_id = ?", timesheet.id], :joins => ", invoices_timesheets its", :readonly => false)
    
    return if inv.nil?
    
    inv.timesheets.delete(timesheet)
    inv.save
    
  end

  #----------------------------------------------------------------------------
  # calculate the invoice value
  #----------------------------------------------------------------------------
  def calc

    # iterate through the timesheets and recalc
    self.netAmount = 0

    for timesheet in timesheets

      self.netAmount += timesheet.netAmount unless timesheet.netAmount.blank?
         
    end

    # calculate the tax and gross amounts
    self.taxAmount = self.netAmount * (self.taxRate/100)
    self.grossAmount = self.netAmount + self.taxAmount

  end

end