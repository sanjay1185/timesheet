class AgencyObserver < ActiveRecord::Observer

  #----------------------------------------------------------------------------
  # When an agency is created send an email to let Ben know!
  #----------------------------------------------------------------------------
  def after_create(agency)

    if agency.created_at.nil?

      AgencyMailer.deliver_send_new_account_alert(agency)

    end

  end

end