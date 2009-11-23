class AgencyInvoiceDetail < ActiveRecord::Base

  #############################################################################
  # Relationships
  #############################################################################
  belongs_to :agency_invoice
  belongs_to :contract
  
end