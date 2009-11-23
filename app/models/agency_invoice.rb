class AgencyInvoice < ActiveRecord::Base

  #############################################################################
  # Relationships
  #############################################################################
  belongs_to :agency
  has_many :agency_invoice_details, :dependent => :destroy

  #############################################################################
  # Custom Methods
  #############################################################################

  #----------------------------------------------------------------------------
  # Create invoices for the agency according to their usage
  #----------------------------------------------------------------------------
  def self.create_for_month(ids, payments, date, vat_rate, next_invoice_number)

    # wrap in transaction
    AgencyInvoice.transaction do

      # iterate through the ids from the page
      for id in ids

        # get the payment from the payment data passed in
        payment = payments.select {|p| p.agency_id == id.to_i}[0]

        # create a new agency invoice
        invoice = AgencyInvoice.new
        invoice.agency_id = id.to_i
        invoice.invoiceDate = date
        invoice.netAmount = PaymentUtil.get_monthly_payment_total(payment.total.to_i)
        invoice.taxAmount = invoice.netAmount * (vat_rate/100)
        invoice.grossAmount = invoice.netAmount + invoice.taxAmount
        invoice.invoiceNumber = next_invoice_number

        # get the contract ids related to this invoice
        contract_ids = Contract.get_ids_for_month(date, id.to_i)

        # add an invoice_detail for each contract
        for c_id in contract_ids

          detail = invoice.agency_invoice_details.build
          detail.contract_id = c_id

        end

        # save the invoice
        invoice.save

        # increment the invoice number
        next_invoice_number += 1

      end

      # update the invoice number in the database
      inv_num = Settings.find_by_name('next_invoice_number')
      inv_num.value = next_invoice_number.to_i
      inv_num.save
      
    end

  end
  
end