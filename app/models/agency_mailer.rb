class AgencyMailer < ActionMailer::Base

  #----------------------------------------------------------------------------
  # Send email to warn of impending trial expiry
  #----------------------------------------------------------------------------
  def send_expiry_alert(email, days_left)
    setup_email
    txt = days_left > 1 ? "days" : "day"
    subject "ClockOff.com trial expiring in #{days_left} #{txt}"
    recipients email
  end

  #----------------------------------------------------------------------------
  # Send email to let users know that the trial has exired
  #----------------------------------------------------------------------------
  def send_expired_alert(agency)
    setup_email
    for u in agency.users
      recipients << u.email
    end
    subject "Your ClockOff.com trial period has expired"
    body[:agency] = agency
  end

  #----------------------------------------------------------------------------
  # Send email to user to invite them to be an approver
  #----------------------------------------------------------------------------
  def invite_worker(email, agency)
    setup_email
    body[:agency] = agency
    recipients email
    subject "Invite from #{agency.name} to use on-line timesheets at ClockOff.com"
  end

  #----------------------------------------------------------------------------
  # Send email to myself to alert of new agency signup
  #----------------------------------------------------------------------------
  def send_new_account_alert(agency)
    setup_email
    body[:agency] = agency
    recipients 'ben.hinton@intura.co.uk'
    subject "New Agency #{agency.name} has registered on ClockOff.com"
  end
  
  #----------------------------------------------------------------------------
  # Send email to approver for approving outstanding timesheets
  #----------------------------------------------------------------------------
  def send_outstanding_alert_to_approver(agency, user)
    setup_email
    body[:agency] = agency
    body[:user] = user
    recipients user.email
    subject "Timesheet Approval Reminder"
  end
  
  #----------------------------------------------------------------------------
  # Send email to contractor for submitting outstanding timesheets
  #----------------------------------------------------------------------------
  def send_outstanding_alert_to_contractor(agency, user)
    setup_email
    body[:agency] = agency
    body[:user] = user
    recipients user.email
    subject "Timesheet Submission Reminder"
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