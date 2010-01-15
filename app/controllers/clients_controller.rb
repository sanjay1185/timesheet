class ClientsController < ApplicationController

  #----------------------------------------------------------------------------
  # Set the layout
  #----------------------------------------------------------------------------
  layout 'new_agency'

  #----------------------------------------------------------------------------
  # Callback events - authenticate & only let agencies see this page
  #----------------------------------------------------------------------------
  before_filter :authenticate

  before_filter do |controller|
    controller.check_type('agency')
    controller.can_edit?('Clients')
  end

  #----------------------------------------------------------------------------
  # View all the clients for an agency
  #----------------------------------------------------------------------------
  def index

    # get the agency
    @agency = Agency.find(session[:agencyId])

    # see if we are filtering by letter
    @filterLetter = params[:filter]
    @filterLetter = "*" if @filterLetter.nil?
    
    # define how we're sorting the data
    @selected_column = params[:c].blank? ? 'name' : params[:c]

    # store the current filter view in the Navigator
    Navigator.set_position(session, :client_list, @filterLetter, params[:page])

    # get the clients
    @clients = Client.get_by_name_filter(@agency.id, @filterLetter, params[:page], 20, sort_order('name'))

  end

  #----------------------------------------------------------------------------
  # Get ready to create a new approver (Edit Client | Add Approver)
  #----------------------------------------------------------------------------
  def new_approver

    @client = Client.find(params[:id])
    @user = ApproverUser.new(params[:user])
    
  end

  #----------------------------------------------------------------------------
  # Save new approver (Add Approver | Save button)
  #----------------------------------------------------------------------------
  def save_approver

    # get the client
    @client = Client.find(params[:client_id])

    # create a user
    @user = ApproverUser.new(params[:user])

    # set the user type
#    @user.type = 'ApproverUser'

    # automatically confirm the pwd
    @user.password_confirmation = @user.generatepassword(8)

    # set the title
    @user.title = params[:selected_title]

    # automatically confirm the email
    @user.email_confirmation = params[:email_confirmation]

    # set simple validation
    @user.only_basic_validation = true

    # save it
    if @user.save

      # success! add to client list of approvers
      @client.approver_users << @user
      redirect_to edit_client_path(@client)

    else

      # error
      render :action => "new_approver", :id => @client.id

    end

  end

  #----------------------------------------------------------------------------
  # Invite approver by email (Add Approver | Email button)
  #----------------------------------------------------------------------------
  def invite_approver

    # get the client
    @client = Client.find(params[:id])

    # get the email address
    @email = params[:email]

    if @email.blank?

      flash[:alert] = 'Email cannot be blank'
    
    else
        
      # see if the user exists
      @usr = User.find_by_email(@email)

      # check if the user is already an approver
      if @client.approver_users.include?(@usr)

        # doest matter if the @usr is nil!
        flash[:alert] = "This user is already set as an approver"

      else

        # is the registered user an approver or not?
        if !@usr.nil? && @usr.type != 'ApproverUser'

          flash[:alert] = "This address is already in use by someone who is not an approver"

        elsif @usr.nil?

          # user doesnt exist - send the invite
          UserMailer.deliver_invite_approver(@email, @client)
          flash[:notice] = "New approver invitation sent to #{@email}"

        else

          # user is a registered approver already

          # get the agency
          @agency = Agency.find(session[:agencyId])

          # check we havent already sent a request
          request = ApproverRequest.get_existing_request(@client.id, @usr.id)

          # if not, go ahead!
          if request.nil?

            request = ApproverRequest.new
            request.user_id = @usr.id
            request.client_id = @client.id
            request.save

          else

            # request already created - reset it
            request.status = nil

            # auth code will be regenerated on saving
            request.save

          end

          # now, deliver the request!
          UserMailer.deliver_request_approver(@usr, @agency, @client, request.code)

          flash[:notice] = "Request sent to existing user: #{@email}"

        end

      end

    end    
    
    render :action => "new_approver", :controller => "clients"
    
  end

  #----------------------------------------------------------------------------
  # remove an approver from this client (Edit Client | Delete user button)
  #----------------------------------------------------------------------------
  def remove_approver

    # get the client
    @client = Client.find(params[:id])

    # get the user
    @user = User.find(params[:user_id])

    # create a transaction to remove all the relevant info
    Client.transaction do

      # delete the user
      @client.approver_users.delete(@user)
    
      # delete any requests for this user and client
      ApproverRequest.delete_by_client(@client.id, @user.id)
    
      # remove approver from all contracts
      @client.remove_approver_from_contracts(@user)
      
    end

    # get the list of approvers again
    @approvers = @client.approver_users.paginate(:page => params[:page], :per_page => 20)
    
    render :action => "edit"
    
  end

  #----------------------------------------------------------------------------
  # create a new client
  #----------------------------------------------------------------------------
  def new

    @agency = Agency.find(session[:agencyId])
    @client = @agency.clients.build
    
  end

  #----------------------------------------------------------------------------
  # edit a client
  #----------------------------------------------------------------------------
  def edit

    # get the agency and client
    @agency = Agency.find(session[:agencyId])
    @client = Client.find(params[:id])

    # are we allowed to delete the client?
    # the rule is that if we have contracts defined or approvers added then NO
    @can_delete = @client.contracts.length == 0 && @client.approver_users.length == 0
    
    # fetch the approver
    @approvers = @client.approver_users.paginate(:page => params[:page], :per_page => 13)

  end

  #----------------------------------------------------------------------------
  # Delete the client
  #----------------------------------------------------------------------------
  def delete_client

    # find the client
    client = Client.find(params[:id])

    # bye bye
    client.destroy

    redirect_to clients_path\

  end

  #----------------------------------------------------------------------------
  # create a new client
  #----------------------------------------------------------------------------
  def create

    # get the agency
    @agency = Agency.find(session[:agencyId])

    # build the new client
    @client = @agency.clients.build(params[:client])

    # set the invoice period
    @client.invoicePeriod = params[:period]

    # save it
    if @client.save

      # success
      flash[:notice] = "Client successfully created"

      redirect_to edit_client_path(@client)

    else

      # error
      render :action => "new"
      
    end

  end
  
  #----------------------------------------------------------------------------
  # update a client
  #----------------------------------------------------------------------------
  def update

    # get the agency
    @agency = Agency.find(session[:agencyId])

    # get the client
    @client = Client.find(params[:id])

    # update the clients attributes
    @client.attributes = params[:client]

    # set the invoice period
    @client.invoicePeriod = params[:period]

    # get the approvers
    @approvers = @client.approver_users.paginate(:page => params[:page], :per_page => 20)
    
    # save it
    if @client.save

      flash[:notice] = "Client saved"

    end

    # just render the edit screen... errors or not
    render :action => "edit"
   
  end

  #----------------------------------------------------------------------------
  # import clients from external file
  #----------------------------------------------------------------------------
  def import_clients

    @agency = Agency.find(session[:agencyId])

    # get the file
    file_data = params[:upload]
    has_header = params[:has_header]
    allow_dups = params[:allow_duplicates]
    errs = []
    
    if !file_data.nil?

      path = save_file(file_data)

      count = 0

      if path.downcase.ends_with?("csv")

        begin

          Client.transaction do

            FasterCSV.foreach(path, {:skip_blanks => true}) do |row|

              if has_header
                has_header = nil
                next
              end

              name, addr1, addr2, addr3, town, region, postcode, ref = row

              client = Client.new(:name => name, :addr1 => addr1, :addr2 => addr2, :addr3 => addr3, :city => town, :region => region, :postCode => postcode, :externalClientRef => ref, :margin => @agency.defaultMargin, :agency_id => @agency.id)
              
              if allow_dups

                count += 1 if client.save

              else

                if !Client.exists?(["name = ? and city = ?", client.name, client.city])

                  count += 1 if client.save

                end

              end

            end

          end

          File.delete(path) unless path.blank?

          flash[:notice] = "#{count} clients imported from #{file_data.original_filename}<p>If you were expecting more than this please check the import requirements below.</p>"

        rescue => ex

          flash[:alert] = ex.message

        end

      else
        
        flash[:alert] = "The file you have selected is not a CSV file. Please make sure the file ends with <span class=\"bold\">.csv</span>"
        
      end

    else

      if request.method == :post

        flash[:alert] = 'Please select a CSV file to import'

      end
      
    end

  end

  private

  def save_file(file)

    path = ''

    if file

      path = File.join RAILS_ROOT, 'public', 'files', "#{Time.now.to_f.to_s}~#{file.original_filename}"

      File.open(path, 'wb') do |f|
        f.write(file.read)
      end

      file = nil

    end

    return path

  end
  
end