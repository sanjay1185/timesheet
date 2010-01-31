class Client < ActiveRecord::Base

  #############################################################################
  # Relationships
  #############################################################################
  belongs_to :agency
  has_many :contracts, :dependent => :destroy
  has_and_belongs_to_many :approver_users
  has_many :invoices, :dependent => :destroy
  has_many :approver_requests, :dependent => :destroy
  
  #############################################################################
  # Validation
  #############################################################################
  validates_presence_of :name, :message => 'Name cannot be blank'
  validates_presence_of :addr1, :message => 'Addr1 cannot be blank'
  validates_presence_of :city, :message => 'City cannot be blank'
  validates_presence_of :margin, :message => 'Margin cannot be blank'
  validates_uniqueness_of :externalClientRef, :scope => [:agency_id], :message => 'External Ref must be unique', :allow_nil => true
  
  attr_accessor :total
  
  #############################################################################
  # Custom Methods
  #############################################################################
  
  #----------------------------------------------------------------------------
  # Get all clients
  #----------------------------------------------------------------------------
  def self.get_by_name_filter(agencyId,letter,page,per_page, order)

    # get all, or get by letter
    if letter == '*'

      # get everything
      conditions = ["clients.agency_id = ?", agencyId]

    else

      # get by matching first letter
      conditions = ['agency_id = ? and name like ?', agencyId, letter + '%']

    end
    
    paginate :per_page => per_page, :page => page, :conditions => conditions, :order => order

  end

  #----------------------------------------------------------------------------
  # Get all clients with active contracts
  #----------------------------------------------------------------------------
  def self.get_all_active(agency_id, page, per_page, order)
          
    conditions = []
    conditions.add_condition!("c.id = ct.client_id")
    conditions.add_condition!("ct.status != 'COMPLETE'")
    conditions.add_condition!(["c.agency_id = ?", agency_id])
    
    paginate(:page => page, :per_page => per_page, :conditions => conditions, :select => "c.*, count(ct.id) as contract_count", :joins => "c, contracts ct", :order => order)
    
  end
  
  #----------------------------------------------------------------------------
  # Get all clients that have approvers
  #----------------------------------------------------------------------------
  def self.get_all_with_approvers(agency_id)
    
    conditions = []
    conditions.add_condition!("clients.id = clients_users.client_id")
    conditions.add_condition!(["clients.agency_id = ?", agency_id])
    
    return Client.find(:all, :conditions => conditions, :joins => "clients, clients_users")
    
  end

  #----------------------------------------------------------------------------
  # Get client names with totals of timesheets
  #----------------------------------------------------------------------------
  def self.get_by_timesheets(agency_id)
    
    
    clients =self.select_all("select c.name, count(t.id) as total
                            from clients c
                            inner join contracts ct
                              on c.id = ct.client_id
                            inner join timesheets t
                              on ct.id = t.contract_id
                            where c.agency_id = " + agency_id.to_s +
                            " and t.status != 'DRAFT'
                            group by c.name")

    data = []
    clients.each {|o| data << [o.name, o.total]}
    
    return data
    
  end
  
  #----------------------------------------------------------------------------
  # Get all the approvers for a client that are not already an approver
  # for the supplied contract
  #----------------------------------------------------------------------------
  def unassigned_approvers_for_contract(contract)

    # todo: shouldnt have to use select here... theres a better way
    user_ids = contract.approver_users.map {|user| user.id}
    self.approver_users.select {|user| !user_ids.include?(user.id)}

  end
  
  #----------------------------------------------------------------------------
  # Is the user already an approver for this client?
  #----------------------------------------------------------------------------
  def is_approver?(user)

    self.users.include?(user)

  end

  #----------------------------------------------------------------------------
  # When an approver is removed from a client the also need to be removed
  # from all the contracts they were assigned to for this client.
  #----------------------------------------------------------------------------
  def remove_approver_from_contracts(user)

    self.connection.execute("delete users from users \
      inner join contracts on contracts.id = users.contract_id \
      where contracts.client_id = #{id.to_s} and users.id = #{user.id.to_s}")

  end

  #----------------------------------------------------------------------------
  # Get all the contracts by their status
  #----------------------------------------------------------------------------
  def paginate_contracts(page, per_page, status, order)

    if order.downcase.starts_with?('contractor')

      order_by = order.split(' ')[1]
      sql = "select distinct contracts.* from contracts
             left outer join contractors_contracts on contractors_contracts.contract_id = contracts.id
             left outer join contractors on contractors_contracts.contractor_id = contractors.id
             left outer join users on users.id = contractors.user_id
             where contracts.client_id = " + id.to_s + " and contracts.status = '"+ status + "' order by users.firstName " + order_by

      data = Contract.find_by_sql(sql)
      data.paginate(:per_page => per_page, :page => (page || 1))

    else

      if status.nil? or status == 'ALL'

        self.contracts.paginate :per_page => per_page, :page => (page || 1), :order => order

      else

        self.contracts.paginate :per_page => per_page, :page => (page || 1), :conditions => ["status = ?", status], :order => order

      end

    end

  end

end