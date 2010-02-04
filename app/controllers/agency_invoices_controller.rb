class AgencyInvoicesController < ApplicationController

  #----------------------------------------------------------------------------
  # Set the layout
  #----------------------------------------------------------------------------
  layout 'new_agencydashboard'

  #----------------------------------------------------------------------------
  # Callback events - authenticate. need to be agency user with 'settings'
  #----------------------------------------------------------------------------
  before_filter :authenticate

  before_filter do |controller|
    controller.check_type('agency')
  end
  
  before_filter do |controller|
    controller.check_role('settings')
  end

  #----------------------------------------------------------------------------
  # View all invoices (Intura Invoices!!!) for an agency
  #----------------------------------------------------------------------------
  def index

    # get the agency
    @agency = Agency.find(session[:agencyId])

    # get the invoices
    @invoices = @agency.agency_invoices

    if !params[:invoice_id].nil?

      # if an invoice is selected, view it
      @invoice = @invoices.select {|i| i.id == params[:invoice_id].to_i}[0]
      @details = @invoice.agency_invoice_details.paginate(:page => params[:page], :per_page => 16)

    end

    respond_to do |format|

      format.html

      format.pdf { send_data(render_pdf('PORTRAIT', { :action => 'invoice.rpdf', :layout => 'pdf_invoice' }), :filename => "invoice.pdf" ) }
      #format.test { render :action => 'invoice.rpdf', :layout => 'pdf_invoice.html' }

    end

  end

  def denied
  end

end