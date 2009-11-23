class AdminController < ApplicationController
  
  def index
  end

  def payments
    @selected_month = Date.today - 1.month
    @selected_year = Date.today

    if params[:commit] == 'Go'
      to_date = Date.new(params[:date][:year].to_i, params[:date][:month].to_i, -1)
      @payments = Contract.get_active_contracts_for_month(to_date)
      @selected_month = params[:date][:month].to_i
      @selected_year = params[:date][:year].to_i
    elsif params[:commit] == 'Generate Invoices'
      to_date = Date.new(params[:date][:year].to_i, params[:date][:month].to_i, -1)
      payments = Contract.get_active_contracts_for_month(to_date)
      @selected_month = params[:date][:month].to_i
      @selected_year = params[:date][:year].to_i
      ids = params["ids"]

      vat_rate = session[:settings]['vat_rate'].value.to_f
      next_invoice_number = session[:settings]['next_invoice_number'].value.to_i

      AgencyInvoice.create_for_month(ids, payments, to_date, vat_rate, next_invoice_number)

    end
  end


end
