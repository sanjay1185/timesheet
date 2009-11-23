class TimesheetMailer < ActionMailer::Base

  #----------------------------------------------------------------------------
  # Send email to approver for approving timesheet
  #----------------------------------------------------------------------------
  def send_for_approval(timesheet, approver)
    setup_email
    subject 'Timesheet Approval Required for ' + timesheet.contractor.user.full_name
    recipients approver.email
    body[:timesheet] = timesheet
    body[:approver] = approver
  end

  #----------------------------------------------------------------------------
  # Send email to resubmit timesheet
  #----------------------------------------------------------------------------
  def resubmit_message(timesheet)
    setup_email
    subject "Please resubmit your timesheet for the week #{timesheet.startDate.to_formatted_s(:uk_date)} - #{(timesheet.startDate + 6).to_formatted_s(:uk_date)}"
    recipients timesheet.contractor.user.email
    body[:timesheet] = timesheet
    body[:user] = timesheet.contractor.user
  end

  #----------------------------------------------------------------------------
  # Send email to tell worker timesheet has been processed
  #----------------------------------------------------------------------------
  def send_response_to_contractor(timesheet)
    setup_email
    subject 'Your timesheet has been ' + timesheet.status.downcase
    recipients timesheet.contractor.user.email
    body[:url] = "#{SITE}"
    body[:timesheet] = timesheet
  end

  #----------------------------------------------------------------------------
  # Send email to alert approver timesheet was rejected
  #----------------------------------------------------------------------------
  def send_rejected_to_approvers(timesheet)
    setup_email
    subject "Timesheet for #{timesheet.contractor.user.full_name} has been rejected"

    approvers = []
    for approver in timesheet.contract.users
       approvers << approver.email
    end

    recipients approvers

    body[:url] = "#{SITE}"
    body[:timesheet] = timesheet
  end

  #----------------------------------------------------------------------------
  # Setup the email
  #----------------------------------------------------------------------------
  def setup_email
   from       "ClockOff.com <#{OUTGOING_EMAIL_ADDRESS}>"
   headers    "Reply-to" => "#{OUTGOING_EMAIL_ADDRESS}"
   sent_on    Time.now
   content_type 'text/html'
  end
  
end