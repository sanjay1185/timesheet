class UserMailer < ActionMailer::Base

  #----------------------------------------------------------------------------
  # Send sign up email - need to ativate
  #----------------------------------------------------------------------------
  def signup_notification(user)

    setup_email(user)
    
    @subject    = 'Welcome to ClockOff.com'
    @body[:user] = user
    @body[:url]  = "#{SITE}/activate/#{user.activation_code}"

  end

  #----------------------------------------------------------------------------
  # Send activation complete email
  #----------------------------------------------------------------------------
  def activation(user)

    setup_email(user)

    @subject    = 'ClockOff.com activation complete'
    @body[:user] = user
    @body[:url]  = "#{SITE}/"

  end

  #----------------------------------------------------------------------------
  # Send reset password email
  #----------------------------------------------------------------------------
  def forgot_password(user)

    setup_email(user)

    @subject    = 'ClockOff.com password change request'
    @body[:user] = user
    @body[:url]  = "#{SITE}/reset_password/#{user.password_reset_code}"

  end

  #----------------------------------------------------------------------------
  # Send email to say reset pwd was a success
  #----------------------------------------------------------------------------
  def reset_password(user)

    setup_email(user)

    @subject    = 'ClockOff.com password reset complete!'
    @body[:user] = user
    @body[:password] = user.password

  end

  #----------------------------------------------------------------------------
  # Send email to remind password
  #----------------------------------------------------------------------------
  def forgot_username(user)

    setup_email(user)

    @subject = 'ClockOff.com login reminder'
    @body[:user] = user
    @body[:username] = user.login

  end

  #----------------------------------------------------------------------------
  # Send invote for an approver
  #----------------------------------------------------------------------------
  def invite_approver(email, client)

    recipients email
    subject "Invitation to register as timesheet approver for " + client.name
    body[:client] = client
    body[:url] = "#{SITE}/register_approver?ref=" + client.id.to_s
    headers    "Reply-to" => "#{OUTGOING_EMAIL_ADDRESS}"
    from       "ClockOff.com <#{OUTGOING_EMAIL_ADDRESS}>"
    sent_on    Time.now
    content_type 'text/html'

  end

  #----------------------------------------------------------------------------
  # Send request for existing approver
  #----------------------------------------------------------------------------
  def request_approver(user, agency, client, code)
    
    recipients user.email
    subject "New request to become approver for #{agency.name}"
    body[:user] = user
    body[:agency] = agency
    body[:client] = client
    body[:url] = "#{SITE}/approver_request/#{code}"
    headers    "Reply-to" => "#{OUTGOING_EMAIL_ADDRESS}"
    from       "ClockOff.com <#{OUTGOING_EMAIL_ADDRESS}>"
    sent_on    Time.now
    content_type 'text/html'

  end

  #----------------------------------------------------------------------------
  # Send email to confirm account deleted
  #----------------------------------------------------------------------------
  def deleted_message(user)
    
    setup_email(user)

    subject "Your ClockOff.com account has been deleted"
   
  end

protected

  #----------------------------------------------------------------------------
  # Setup the email
  #----------------------------------------------------------------------------
  def setup_email(user)

   recipients user.email
   from       "ClockOff.com <#{OUTGOING_EMAIL_ADDRESS}>"
   headers    "Reply-to" => "#{OUTGOING_EMAIL_ADDRESS}"
   body       :user => user
   sent_on    Time.now
   content_type 'text/html'
   
  end

end