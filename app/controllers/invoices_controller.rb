class InvoicesController < ApplicationController

  #----------------------------------------------------------------------------
  # Set the layout
  #----------------------------------------------------------------------------
  layout 'new_agency'

  #----------------------------------------------------------------------------
  # Callback events - authenticate... agency user with invoicing role
  #----------------------------------------------------------------------------
  before_filter :authenticate
  
  before_filter do |controller|
    controller.check_type('agency')
    controller.check_role('Invoicing')
    controller.can_edit?('Invoicing')
  end

  #----------------------------------------------------------------------------
  # Search for invoices
  #----------------------------------------------------------------------------
  def index

    session[:selected] = 'invoicing'

    # define formats
    @formats = ['CSV', 'CSV for Sage']

    # get agency
    @agency = Agency.find(session[:agencyId])

    # get clients
    @client_list = @agency.clients
    new_client = Client.new
    new_client.name = "[All Clients]"
    @client_list.insert(0, new_client)

    # set params
    @from_date = params[:from_date]
    @to_date = params[:to_date]
    @client_id = params[:client_id]
    @inactive = params[:inactive]
    @signed_off = params[:signed_off]
    @disabled = true

    # search if we have dates set
    if !@from_date.nil? && !@to_date.nil?

      @invoices = Invoice.search(@from_date, @to_date, @inactive, @signed_off, @client_id)
      @disabled = (@invoices.length == 0)
      
    end

  end

  #----------------------------------------------------------------------------
  # Perform search (and export)
  #----------------------------------------------------------------------------
  def search

    # get formats
    @formats = ['CSV', 'CSV for Sage']
    
    # get agency
    @agency = Agency.find(session[:agencyId])

    # get params
    @from_date = params[:from_date] 
    @to_date = params[:to_date]
    @client_id = params[:client_id]
    @inactive = params[:inactive]
    @signed_off = params[:signed_off]
    
    # get the invoices
    @invoices = Invoice.search(@from_date, @to_date, @inactive, @signed_off, @client_id)

    # disable export?
    @disabled = (@invoices.length == 0)

    if params[:commit] == "Export"

      # which invoices are we exporting?
      ids = params[:ids]

      # get them...
      selected_invoices = @invoices.select {|i| ids.include?(i.id.to_s) }

      # which format?
      if params[:exportFormat] == "CSV"

        export_to_csv(selected_invoices, "export")

      elsif params[:exportFormat] == "CSV for Sage"

          export_to_sage(selected_invoices, "sageexport", @agency)

      end

      return

      # set selected format
      @selectedFormat = params[:exportFormat]
      
    else

      # are we signing off invoices
      if params[:commit] == "Sign-Off"

        # get the invoice ids
        ids = params[:ids]

        # start transaction
        Invoice.transaction do

          # iterate through the invoices
          for id in ids

            # get the invoice
            invoice = @invoices.select { |i| id == i.id.to_s }

            # update the attributes
            invoice[0].update_attribute(:lastExportDate, Time.now) if invoice.length == 1

            # remove it from the collection
            @invoices.delete(invoice[0])

          end unless ids.nil?

        end

      end

    end

    # get the client list
    @client_list = @agency.clients
    new_client = Client.new
    new_client.name = "[All Clients]"
    @client_list.insert(0, new_client)

    render :action => 'index'
    
  end

  #----------------------------------------------------------------------------
  # Edit an invoice
  #----------------------------------------------------------------------------
  def edit

    # get the agency
    @agency = Agency.find(session[:agencyId])

    # get the invoice
    @invoice = Invoice.find(params[:id])

    # get thr params
    @from_date = params['from']
    @to_date = params['to']
    @inactive = params[:inactive]
    @signed_off = params[:signed_off]
    @client_id = params[:client_id]

  end

  #----------------------------------------------------------------------------
  # Update the invoice
  #----------------------------------------------------------------------------
  def update

    # find the invoice
    @invoice = Invoice.find(params[:id])

    # update the atrribs
    @invoice.update_attributes(params[:invoice])

    redirect_to edit_invoice_path(@invoice)

  end

private

  #----------------------------------------------------------------------------
  # Export to csv
  #----------------------------------------------------------------------------
  def export_to_csv(invoices, filename)

    # use FasterCSV
    csv_string = FasterCSV.generate do |csv|

      # define the headers
      csv << ["InvoiceDate", "NetAmount", "TaxRate", "TaxAmount", "GrossAmount", "Ref", "ClientName", "ExternalClientRef", "ContractRef"]

      # iterate through and write out
      for invoice in invoices do

        taxAmt = (invoice.netAmount * (invoice.taxRate/100)).to_f
        csv << [invoice.invoiceDate, sprintf("%.2f", invoice.netAmount), sprintf("%.2f", invoice.taxRate),
          sprintf("%.2f", taxAmt), sprintf("%.2f", invoice.netAmount + taxAmt), invoice.ref, invoice.client.name, invoice.client.externalClientRef, invoice.ref]

      end
    end

    filename << ".csv"
    send_data(csv_string, :type => 'text/csv; charset=utf-8; header=present', :filename => filename)
    
  end

  #----------------------------------------------------------------------------
  # Export to sage
  #----------------------------------------------------------------------------
  def export_to_sage(invoices, filename, agency)

    # use :force_quotes => true to use double quotes
    csv_string = FasterCSV.generate(:force_quotes => true) do |csv|
    nominal_code = agency.sageNominalCode.blank? ? "4000" : agency.sageNominalCode
    csv << ["TXN", "SALESACC", "NOMINALCODE", "TXNDATE", "TXNREF", "TXNDETAILS", "NETAMT", "TAXCODE", "TAXAMT"]

    for invoice in invoices do
      for timesheet in invoice.timesheets do
        taxAmt = (timesheet.netAmount * (invoice.taxRate/100)).to_f

        csv << ["SI", invoice.client.externalClientRef, nominal_code, (timesheet.startDate + 6).to_formatted_s(:uk_date), invoice.ref,
          "#{timesheet.contractor.user.full_name} (Contract Ref: #{timesheet.contract.ref})", sprintf("%.2f", timesheet.netAmount), "T1", sprintf("%.2f", taxAmt)]
      end
    end
  end

  filename << ".csv"
  send_data(csv_string, :type => 'text/csv; charset=utf-8;', :filename => filename)
  end

end
