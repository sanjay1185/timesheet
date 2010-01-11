class TimesheetObserver < ActiveRecord::Observer

  #----------------------------------------------------------------------------
  # Before the timesheet is saved send emails and attach to invoices etc
  #----------------------------------------------------------------------------
  def before_save(timesheet)

    # submitted timesheets need to have alerts sent
    if timesheet.status == 'SUBMITTED'
      
      #RAILS_DEFAULT_LOGGER.info "\n *** IN after_save \n"
      for approver in timesheet.contract.approver_users do

        # send email to approver
        TimesheetMailer.deliver_send_for_approval(timesheet, approver)
        
      end

    elsif timesheet.status == 'DRAFT' && timesheet.resubmit == true

      # send message to contractor as timesheet is draft again
      # this will happen when contract has been extended and
      # last timesheet was only part week!
      TimesheetMailer.deliver_resubmit_message(timesheet)

    elsif timesheet.status == 'APPROVED' 

      # first things first, calculate the timesheet
      timesheet.calc

      # look up the client
      client = Client.find(timesheet.contract.client_id)

      # get the period start day
      start_day = client.monthlyInvoicePeriodStartDay.nil? ? 1 : client.monthlyInvoicePeriodStartDay

      # get the invoice date
      invoice_date = timesheet.get_invoice_date(start_day)
      
      conditions = []
      conditions.add_condition!(['client_id = ?', timesheet.contract.client_id])
      conditions.add_condition!(['invoiceDate = ?', invoice_date])

      # search for the invoices matching this criteria
      invoices = Invoice.find(:all, :conditions => conditions)

      if invoices.empty?

        # invoice doesnt exist - so create it
        invoice = Invoice.new
        inv_number = Agency.increment_invoice_number(timesheet.contract.client.agency.id)
        invoice.ref = "CO_#{inv_number.to_s.rjust(4, '0')}"
        invoice.invoiceDate = invoice_date
        invoice.taxRate = Settings.get_setting('vat_rate', invoice_date).value.to_f
        invoice.client_id = timesheet.contract.client_id

      else

        # should only be one existing invoice - so get it
        invoice = invoices[0]

      end

      # at this point we have an invoice... add the timesheet to it
      if !invoice.timesheets.include?(timesheet)
        
        invoice.timesheets << timesheet
        
      end
      
      # save the invoice.. the calc will happen automatically
      invoice.save

    elsif timesheet.status == "REJECTED"

      # remove the timesheet from the invoice - the recalc will happen after
      Invoice.remove_timesheet(timesheet)

    end
			
    if timesheet.status == 'APPROVED' || timesheet.status == 'DENIED'

      # send email alerting to timesheet being processed
      TimesheetMailer.deliver_send_response_to_contractor(timesheet)

    elsif timesheet.status == 'REJECTED'

      # send rejection email
      TimesheetMailer.deliver_send_rejected_to_approvers(timesheet)

    end

  end

  def after_save(timesheet)
    
    #todo: change contract status here?   
 
  end


end