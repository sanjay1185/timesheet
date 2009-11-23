namespace :testing do

task :setup => :agency do

  end

  desc "Cleardown all client, timesheet, invoice data for testing"
  task :cleardown => :environment do

    if @environment == 'production'
      puts "Cant run this task in production environment"
      return
    end
    
    puts "Deleting clients..."
    Client.delete_all
    puts "Deleting contracts..."
    Contract.delete_all
    puts "Deleting timesheets..."
    Timesheet.delete_all
    puts "Deleting timesheet history"
    TimesheetHistroy.delete_all
    puts "Deleting timesheet entries..."
    TimesheetEntry.delete_all
    puts "Deleting timesheet entries history"
    TimesheetEntryHistory.delete_all
    puts "Deleting invoices..."
    Invoice.delete_all
    puts "Deleting rates..."
    Rate.delete_all("contract_id != 0")
    puts "Deleting agency invoices..."
    AgencyInvoice.delete_all()
    AgencyInvoiceDetail.delete_all()
    puts "Deleting approver requests..."
    ApproverRequest.delete_all()
    puts "Deleting Agencies"
    Agency.delete_all()
    puts "Deleting users"
    User.delete_all()
    puts "Deleting permissions..."
    Permission.delete_all
    puts "Deleting roles..."
    Role.delete_all
    puts "Deleting settings"
    Settings.delete_all()
    puts "Deleting additional join tables..."
    ActiveRecord::Base.connection.execute("delete from invoices_timesheets")
    ActiveRecord::Base.connection.execute("delete from contracts_users")
    ActiveRecord::Base.connection.execute("delete from clients_users")
    ActiveRecord::Base.connection.execute("delete from contractors_contracts")

    puts "Setting auto increment for users back to 1"
    ActiveRecord::Base.connection.execute("ALTER TABLE `users` AUTO_INCREMENT = 1;")
  end

  desc "Inserting setup data"
  task :data => :controller do

    ni_rate = Settings.new({:name => 'ni_rate', :effectiveDate => '2009-04-05', :value => '12.8'})
    ni_rate.save
    puts "Inserted ni_rate"

    hol_accrual_rate = Settings.new({:name => 'hol_accrual_rate', :effectiveDate => '2009-04-05', :value => '12.07'})
    hol_accrual_rate.save
    puts "Inserted hol_accrual_rate"

    next_invoice_number = Settings.new({:name => 'next_invoice_number', :value => '1'})
    next_invoice_number.save
    puts "Inserted next_invoice_number"

    vat_rate = Settings.new({:name => 'vat_rate', :effectiveDate => '2009-04-05', :value => '15'})
    vat_rate.save
    puts "Inserted vat_rate"

    invoice_address = Settings.new({:name => 'invoice_address', :value => '2nd Floor,145-157 St John St,London,EC1V 4PY'})
    invoice_address.save
    puts "Inserted invoice address"

    vat_number = Settings.new({:name => 'vat_number', :value => '906 1781 27'})
    vat_number.save
    puts "Inserted vat_number"

    company_number = Settings.new({:name => 'company_number', :value => '06132404'})
    company_number.save
    puts "Inserted company_number"

  end

  desc "Inserting controller user"
  task :controller => :cleardown do

    controller = User.new(
      { :id => 1,
        :login => 'controller',
        :email => 'ben.hinton@intura.co.uk',
        :title => 'Mr',
        :firstName => 'Ben',
        :lastName => 'Hinton',
        :password => '123456',
        :admin => false,
        :state => 'active',
        :userType => ''
      })
    controller.method(:encrypt_password)
    controller.method(:make_password_reset_code)
    controller.save(false)
    puts "Inserted controller user"
    controller.activate
    puts "Controller user activated"

  end

  desc "Inserting default agency and user..."
  task :agency => :data do

    agency = Agency.new(
      { :name => '247 Solutions Ltd',
        :addr1 => '185 Lombard Street',
        :city => 'London',
        :postCode => 'EC1M 9YD',
        :phone => '020 7827 9322',
        :fax => '020 7827 9333',
        :email => '247solutions@intura.co.uk',
        :active => true,
        :sageNominalCode => '4011',
        :trial => 1
      })
    agency.save
    puts "Agency inserted"

    agency_user = User.new(
      { :login => 'jamesbrand',
        :email => 'james.brand@intura.co.uk',
        :title => 'Mr',
        :firstName => 'James',
        :lastName => 'Brand',
        :password => '123456',
        :agency_id => agency.id,
        :admin => true,
        :state => 'active',
        :userType => 'agency',
        :phone => '020 7827 9323'
      })

    agency_user.method(:encrypt_password)
    agency_user.method(:make_password_reset_code)
    agency_user.save(false)
    puts "Agency user inserted"
    agency_user.activate
    puts "Agency user activated"

  end

end