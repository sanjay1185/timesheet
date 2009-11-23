class SageInvoiceRecord
  attr_accessor :sales_acc, :txn_date, :txn_ref, :txn_details, :net_amt, :tax_rate, :tax_code, :nominal_code
  
  @tax_rate = 15
  @tax_code = "T1"
  @nominal_code = 4000

  def initialize(sales_acc, txn_date, txn_ref, net_amt)
    @sales_acc = sales_acc
    @txn_date = txn_date
    @txn_ref = txn_ref
    @net_amt = net_amt
  end

  def tax_amt
    if @net_amt > 0 && @tax_rate > 0
      return @net_amt / @tax_rate
    end
    return 0
  end

end
