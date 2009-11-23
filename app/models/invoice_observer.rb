class InvoiceObserver < ActiveRecord::Observer

  #----------------------------------------------------------------------------
  # Every time an invoice is created or saved, recalc it
  #----------------------------------------------------------------------------
  def before_save(invoice)

    invoice.calc

  end
  
end