class UserObserver < ActiveRecord::Observer

  #----------------------------------------------------------------------------
  # Send a notification to the user to activate
  #----------------------------------------------------------------------------
  def after_create(user)

    # only send notification if the user is not created from the demo task
    UserMailer.deliver_signup_notification(user) unless user.demo

  end

  #----------------------------------------------------------------------------
  # Send user alert depending on what has happened
  #----------------------------------------------------------------------------
  def after_save(user)

    UserMailer.deliver_activation(user) if user.recently_activated?
    UserMailer.deliver_forgot_password(user) if user.recently_forgot_password?
    UserMailer.deliver_reset_password(user) if user.recently_reset_password?
    UserMailer.deliver_forgot_username(user) if user.recently_forgot_username?

  end

  #----------------------------------------------------------------------------
  # Send a message to say account deleted
  #----------------------------------------------------------------------------
  def after_destroy

    UserMailer.deliver_deleted_message(user)

  end
  
end