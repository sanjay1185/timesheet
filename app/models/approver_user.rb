class ApproverUser < User
  
  has_and_belongs_to_many :contracts
  has_and_belongs_to_many :clients
  
end
