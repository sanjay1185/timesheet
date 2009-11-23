class ApproverRequest < ActiveRecord::Base

  #############################################################################
  # Relationships
  #############################################################################
  belongs_to :user
  belongs_to :client

  #############################################################################
  # Events
  #############################################################################
  before_create :generate_code
  before_save :regenerate_code

  #############################################################################
  # Custom Methods
  #############################################################################

  #----------------------------------------------------------------------------
  # Fetch a request for a user, for a client. There should be only one!
  #----------------------------------------------------------------------------
  def self.get_existing_request(client_id, user_id)

    conditions = []
    conditions.add_condition!(:client_id => client_id)
    conditions.add_condition!(:user_id => user_id)
        
    return self.find(:first, :conditions => conditions)
    
  end

  #----------------------------------------------------------------------------
  # Delete requests for a specific user and client
  #----------------------------------------------------------------------------
  def self.delete_by_client(client_id, user_id)

    conditions = []
    conditions.add_condition!(:client_id => client_id)
    conditions.add_condition!(:user_id => user_id)
    
    self.delete_all(conditions)

  end

  protected

  #----------------------------------------------------------------------------
  # Generate a new code for the request
  #----------------------------------------------------------------------------
  def generate_code

    self.code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )

  end

  #----------------------------------------------------------------------------
  # Regenerate the code for the request
  #----------------------------------------------------------------------------
  def regenerate_code

    if self.status.blank?

      generate_code

    else

      self.code = nil
      
    end
    
  end

end
