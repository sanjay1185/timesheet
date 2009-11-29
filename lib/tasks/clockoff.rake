namespace :clockoff do
  
  @the_date = nil
  @last_month = nil
  @last_quarter = nil
  @six_months_ago = nil
  
  task :setup => :insert do 
    
  end
  
  task :insert => :cleardown do
    
    puts "*** Creating settings ***"
    puts "...ni_rate"
    ni_rate = Settings.new({:name => 'ni_rate', :effectiveDate => @six_months_ago, :value => '12.8'})
    ni_rate.save
    
    puts "...hol_accrual_rate"
    hol_accrual_rate = Settings.new({:name => 'hol_accrual_rate', :effectiveDate => @six_months_ago, :value => '12.07'})
    hol_accrual_rate.save

    puts "...next_invoice_number"
    next_invoice_number = Settings.new({:name => 'next_invoice_number', :value => '1'})
    next_invoice_number.save
    
    puts "...vat_rate"
    vat_rate = Settings.new({:name => 'vat_rate', :effectiveDate => @six_months_ago, :value => '15'})
    vat_rate.save

    puts "...invoice_address"
    invoice_address = Settings.new({:name => 'invoice_address', :value => '2nd Floor,145-157 St John St,London,EC1V 4PY'})
    invoice_address.save
    
    puts "...vat_number"
    vat_number = Settings.new({:name => 'vat_number', :value => '906 1781 27'})
    vat_number.save

    puts "...company_number"
    company_number = Settings.new({:name => 'company_number', :value => '06132404'})
    company_number.save
    
    puts "*** Creating default rates ***"
    puts "...sickness"
    sickness_rate = Rate.new({:contract_id => 0, :name => 'Sickness', :payRate => 0, :chargeRate => 0, :comment => 'Default Sickness Rate', :default => true, :active => true, :category => 'Sickness'})
    sickness_rate.save(false)
    
    puts "...unpaid"
    unpaid_rate = Rate.new({:contract_id => 0, :name => 'Unpaid', :payRate => 0, :chargeRate => 0, :comment => 'Default Unpaid Rate', :default => true, :active => true, :category => 'Unpaid'})
    unpaid_rate.save(false)
    
    puts "*** Creating roles ***"
    puts "...Clients"
    clients_role = Role.new({:name => 'Clients', :description => 'Client management role'})
    clients_role.save
    
    puts "...Contracts"
    contracts_role = Role.new({:name => 'Contracts', :description => 'Contract management role'})
    contracts_role.save
    
    puts "...Rates"
    rates_role = Role.new({:name => 'Rates', :description => 'Rates management role'})
    rates_role.save
    
    puts "...Invoicing"
    invoicing_role = Role.new({:name => 'Invoicing', :description => 'Invoicing role'})
    invoicing_role.save
    
    puts "...Settings"
    settings_role = Role.new({:name => 'Settings', :description => 'Settings role'})
    settings_role.save
    
    puts "...Users"
    users_role = Role.new({:name => 'Users', :description => 'Users role'})
    users_role.save
    
    puts "*** Creating agency 247 Recruitment Ltd ***"
    
    agency = Agency.new(
      { :name => '247 Recruitment Ltd',
        :addr1 => '185 Lombard Street',
        :city => 'London',
        :postCode => 'EC1M 9YD',
        :phone => '020 7827 9322',
        :fax => '020 7827 9333',
        :email => '247solutions@intura.co.uk',
        :active => true,
        :sageNominalCode => '4011',
        :trial => 0,
        :cutOffDay => 2,
        :cutOffTime => "10:30",
        :autoReminder => 1,
        :calculatePAYE => 1,
        :useInvoicing => 1,
        :defaultMargin => 10.5,
        :nextInvoiceNumber => 251
      })
    agency.save
    
    puts "*** Creating agency user jamesbrand ***"
    james_brand = User.new(
      { :login => 'jamesbrand',
        :email => 'james.brand@intura.co.uk',
        :title => 'Mr',
        :firstName => 'James',
        :lastName => 'Brand',
        :password => '123456',
        :agency_id => agency.id,
        :state => 'active',
        :userType => 'agency',
        :phone => '020 7827 9323',
        :setup => true
      })

    james_brand.method(:encrypt_password)
    james_brand.method(:make_password_reset_code)
    james_brand.activate
    
    # add permissions for james brand
    james_brand.permissions << Permission.new(:role => users_role)
    james_brand.permissions << Permission.new(:role => clients_role)
    james_brand.permissions << Permission.new(:role => contracts_role)
    james_brand.permissions << Permission.new(:role => invoicing_role)
    james_brand.permissions << Permission.new(:role => settings_role)
    james_brand.permissions << Permission.new(:role => rates_role)

    puts "*** Creating agency user alanbraine ***"
    alan_braine = User.new(
      { :login => 'alanbraine',
        :email => 'alan.braine@intura.co.uk',
        :title => 'Mr',
        :firstName => 'Alan',
        :lastName => 'Braine',
        :password => '123456',
        :agency_id => agency.id,
        :state => 'active',
        :userType => 'agency',
        :phone => '020 7827 9324',
        :setup => true
      })

    alan_braine.method(:encrypt_password)
    alan_braine.method(:make_password_reset_code)
    alan_braine.activate
    
    # add permissions for alan braine
    alan_braine.permissions << Permission.new(:role => clients_role)
    alan_braine.permissions << Permission.new(:role => contracts_role, :readOnly => true)
    alan_braine.permissions << Permission.new(:role => rates_role, :readOnly => true)
    
    puts "*** Creating clients ***"
    puts "...ABN Amro"
    abn = Client.new(:agency => agency, :name => 'ABN Amro', :addr1 => "250 Bishopsgate", :city => 'London', :region => 'London', :postCode => 'EC1M 2TF', :externalClientRef => 'ABN250', :margin => 9.25, :invoicePeriod => 'WEEKLY')
    abn.save
    puts "......adding approver Mark Norris for ABN Amro"
    mark_norris = User.new(
      { :login => 'marknorris',
        :email => 'mark.norris@intura.co.uk',
        :title => 'Mr',
        :firstName => 'Mark',
        :lastName => 'Norris',
        :password => '123456',
        :state => 'active',
        :userType => 'approver',
        :phone => '020 7719 7366',
        :setup => true
      })
    mark_norris.method(:encrypt_password)
    mark_norris.method(:make_password_reset_code)
    mark_norris.activate
    abn.users << mark_norris
    
    puts "......adding approver Owen Peters for ABN Amro"
    owen_peters = User.new(
      { :login => 'owenpeters',
        :email => 'owen.peters@intura.co.uk',
        :title => 'Mr',
        :firstName => 'Owen',
        :lastName => 'Peters',
        :password => '123456',
        :state => 'active',
        :userType => 'approver',
        :phone => '020 7719 7398',
        :setup => true
      })
    owen_peters.method(:encrypt_password)
    owen_peters.method(:make_password_reset_code)
    owen_peters.activate
    abn.users << owen_peters
    
    puts "...ARX Media Ltd"
    arx = Client.new(:agency => agency, :name => 'ARX Media Ltd', :addr1 => "405 Chancery Lane", :city => 'London', :region => 'London', :postCode => 'WC2 8ND', :externalClientRef => 'ARX01', :margin => 12.5, :invoicePeriod => 'MONTHLY', :monthlyInvoicePeriodStartDay => 1)
    arx.save
    puts "...Bortex Industries Ltd"
    bortex = Client.new(:agency => agency, :name => 'Bortex Industries Ltd', :addr1 => "UNIT 12B", :addr2 => 'Castleton Industrial Estate', :addr3 => 'Bramingham' , :city => 'Luton', :region => 'Bedfordshire', :postCode => 'LU2 7SD', :externalClientRef => 'BORTEX', :margin => 11, :invoicePeriod => 'WEEKLY')
    bortex.save
    
    puts "......adding approver Graham Bennett for Bortex Industries Ltd"
    graham_bennett = User.new(
      { :login => 'grahambennett',
        :email => 'graham.bennett@intura.co.uk',
        :title => 'Mr',
        :firstName => 'Graham',
        :lastName => 'Bennett',
        :password => '123456',
        :state => 'active',
        :userType => 'approver',
        :phone => '01523 736 288',
        :setup => true
      })
    graham_bennett.method(:encrypt_password)
    graham_bennett.method(:make_password_reset_code)
    graham_bennett.activate
    bortex.users << graham_bennett
    
    puts "...Coral Trade Bathrooms"
    coral = Client.new(:agency => agency, :name => 'Coral Trade Bathrooms', :addr1 => "120 High Street", :city => 'Uxbridge', :region => 'Middlesex', :postCode => 'UB4 8SP', :externalClientRef => 'CORAL', :margin => 10, :invoicePeriod => 'WEEKLY')
    coral.save
    puts "...C-DEX Software Ltd"
    cdex = Client.new(:agency => agency, :name => 'C-DEX Software Ltd', :addr1 => "7a Warpole Street", :city => 'Harrow', :region => 'Middlesex', :postCode => 'HA2 3YS', :externalClientRef => 'CDEX', :margin => 9.75, :invoicePeriod => 'MONTHLY', :monthlyInvoicePeriodStartDay => 15)
    cdex.save
    puts "...Dynamic Technology Ltd"
    dyntech = Client.new(:agency => agency, :name => 'Dynamic Technology Ltd', :addr1 => "100 Gershon Road", :city => 'Harrow', :region => 'Middlesex', :postCode => 'HA1 4PE', :externalClientRef => 'DYNTECH', :margin => 9.75, :invoicePeriod => 'WEEKLY')
    dyntech.save
    puts "...Dorian & Co Solicitors"
    dorian = Client.new(:agency => agency, :name => 'Dorian & Co Solicitors', :addr1 => "22 Station Road", :city => 'Harrow', :region => 'Middlesex', :postCode => 'HA2 5PR', :externalClientRef => 'DORIAN', :margin => 10, :invoicePeriod => 'WEEKLY')
    dorian.save
    puts "...Exxon Oil (UK) Ltd"
    exxon = Client.new(:agency => agency, :name => 'Exxon Oil (UK) Ltd', :addr1 => "16 Broadgate", :city => 'London', :region => 'London', :postCode => 'EC2M 4YE', :externalClientRef => 'EXXON', :margin => 9.75, :invoicePeriod => 'WEEKLY')
    exxon.save
    puts "...Finchley Investing Ltd"
    finchley = Client.new(:agency => agency, :name => 'Finchley Investing Ltd', :addr1 => "75 Fielding Road", :city => 'North Finchley', :region => 'London', :postCode => 'N17 8TG', :externalClientRef => 'CDEX', :margin => 12, :invoicePeriod => 'MONTHLY', :monthlyInvoicePeriodStartDay => 1)
    finchley.save
    puts "...Goldman Sachs"
    goldman = Client.new(:agency => agency, :name => 'Goldman Sachs', :addr1 => "100 London Wall", :city => 'London', :region => 'London', :postCode => 'EC1V 1SS', :externalClientRef => 'GOLDMAN', :margin => 12.5, :invoicePeriod => 'MONTHLY', :monthlyInvoicePeriodStartDay => 1)
    goldman.save
    puts "...Hirst Management Ltd"
    hirst = Client.new(:agency => agency, :name => 'Hirst Management Ltd', :addr1 => "54 Liverpool Street", :city => 'London', :region => 'London', :postCode => 'EC2M 8RH', :externalClientRef => 'HIRST', :margin => 10, :invoicePeriod => 'WEEKLY')
    hirst.save
    puts "...HSBC"
    hsbc = Client.new(:agency => agency, :name => 'HSBC', :addr1 => "HSBC Tower", :addr2 => '3rd Floor', :addr3 => 'Canada Water', :city => 'Canary Wharf', :region => 'London', :postCode => 'E14 7DO', :externalClientRef => 'HSBC', :margin => 14, :invoicePeriod => 'MONTHLY', :monthlyInvoicePeriodStartDay => 1)
    hsbc.save
    puts "...Indigo Media Ltd"
    indigo = Client.new(:agency => agency, :name => 'Indigo Media Ltd', :addr1 => "7 Carnaby Street", :city => 'London', :region => 'London', :postCode => 'W3 7CS', :externalClientRef => 'INDIGO', :margin => 9, :invoicePeriod => 'WEEKLY')
    indigo.save
    puts "...Kirby Cleaning Contracts Ltd"
    kirby = Client.new(:agency => agency, :name => 'Kirby Cleaning Contracts Ltd', :addr1 => "77 Ruislip Road", :city => 'Greeenford', :region => 'Middlesex', :postCode => 'UB1 2YY', :externalClientRef => 'KIRBY', :margin => 8.25, :invoicePeriod => 'WEEKLY')
    kirby.save
    puts "...Leamington Capital Ltd"
    leamington = Client.new(:agency => agency, :name => 'Leamington Capital Ltd', :addr1 => "89 Prince Street", :city => 'London', :region => 'London', :postCode => 'EC1M 9HD', :externalClientRef => 'LEAMINGTON', :margin => 12, :invoicePeriod => 'WEEKLY')
    leamington.save
    puts "...Merill Lynch"
    merill = Client.new(:agency => agency, :name => 'Merill Lynch', :addr1 => "120 The Strand", :city => 'London', :region => 'London', :postCode => 'WC1D 7FG', :externalClientRef => 'MERILL', :margin => 11.75, :invoicePeriod => 'MONTHLY', :monthlyInvoicePeriodStartDay => 10)
    merill.save
    puts "...Norris Hill Ltd"
    norris = Client.new(:agency => agency, :name => 'Norris Hill Ltd', :addr1 => "69 Boundary Road", :city => 'Pinner', :region => 'Middlesex', :postCode => 'HA4 1PP', :externalClientRef => 'NORRIS', :margin => 8, :invoicePeriod => 'WEEKLY')
    norris.save
    puts "...Pear Tree Solutions Ltd"
    pear = Client.new(:agency => agency, :name => 'Pear Tree Solutions Ltd', :addr1 => "1 Bridge Street", :city => 'Pinner', :region => 'Middlesex', :postCode => 'HA5 4AW', :externalClientRef => 'PEAR', :margin => 9, :invoicePeriod => 'WEEKLY')
    pear.save
    puts "...Rustok Importers Ltd"
    rustok = Client.new(:agency => agency, :name => 'Rustock Imports Ltd', :addr1 => "Unit 4F", :addr2 => 'Greenway Industial Estate', :city => 'Edgware', :region => 'Middlesex', :postCode => 'HA9 6LG', :externalClientRef => 'RUSTOK', :margin => 8.75, :invoicePeriod => 'WEEKLY')
    rustok.save
    puts "...Stevenson Fund Management Ltd"
    steve = Client.new(:agency => agency, :name => 'Steveson Fund Management Ltd', :addr1 => "135 Pirelli Street", :city => 'London', :region => 'London', :postCode => 'WC4A 7RD', :externalClientRef => 'STEVENSON', :margin => 10, :invoicePeriod => 'WEEKLY')
    steve.save
    puts "...Trustware Ltd"
    trustware = Client.new(:agency => agency, :name => 'Trustware Ltd', :addr1 => "12 High Street", :city => 'Twickenham', :region => 'Surrey', :postCode => 'TW4 8EJ', :externalClientRef => 'TRUST', :margin => 10.5, :invoicePeriod => 'WEEKLY')
    trustware.save
    puts "...Vector Industries Ltd"
    vector = Client.new(:agency => agency, :name => 'Vector Industries Ltd', :addr1 => "80 Cannon Lane", :city => 'Pinner', :region => 'Middlesex', :postCode => 'HA5 6TR', :externalClientRef => 'VECTOR', :margin => 8.25, :invoicePeriod => 'WEEKLY')
    vector.save
    puts "...Wheeler Software Ltd"
    wheeler = Client.new(:agency => agency, :name => 'Wheeler Software Ltd', :addr1 => "96 Bishopsgate", :city => 'London', :region => 'London', :postCode => 'EC8A 8DV', :externalClientRef => 'WHEELER', :margin => 7.75, :invoicePeriod => 'WEEKLY')
    wheeler.save
    
    puts '*** Creating contractors ***'
    puts '...Charles Daly'
    charles_daly = User.new(
      { :login => 'charlesdaly',
        :email => 'charles.daly@intura.co.uk',
        :title => 'Mr',
        :firstName => 'Charles',
        :lastName => 'Daly',
        :password => '123456',
        :state => 'active',
        :userType => 'contractor',
        :phone => '020 8876 2233',
        :addr1 => '70 Frensham Close',
        :city => 'Southall',
        :region => 'Middlesex',
        :postCode => 'UB1 2YQ',
        :setup => true
      })

    charles_daly.method(:encrypt_password)
    charles_daly.method(:make_password_reset_code)
    
    charles_daly_contractor = Contractor.new()
    charles_daly_contractor.user = charles_daly
    charles_daly_contractor.companyName = 'BlueBox Software Ltd'
    charles_daly_contractor.vatNumber = '977 6534 187'
    charles_daly_contractor.companyNumber = '086548277'
    charles_daly_contractor.save(false)
 
    charles_daly.contractor_id = charles_daly_contractor.id
    charles_daly.activate
    
    puts '...Mary Smith'
    mary_smith = User.new(
      { :login => 'marysmith',
        :email => 'mary.smith@intura.co.uk',
        :title => 'Miss',
        :firstName => 'Mary',
        :lastName => 'Smith',
        :password => '123456',
        :state => 'active',
        :userType => 'contractor',
        :phone => '01628 132 967',
        :addr1 => '100 Whitton Road',
        :city => 'Maidenhead',
        :region => 'Berkshire',
        :postCode => 'MD2 3KD',
        :setup => true
      })

    mary_smith.method(:encrypt_password)
    mary_smith.method(:make_password_reset_code)
    
    mary_smith_contractor = Contractor.new()
    mary_smith_contractor.user = mary_smith
    mary_smith_contractor.save(false)
    
    mary_smith.contractor_id = mary_smith_contractor.id
    mary_smith.activate
    
    puts '...Terry Vance'
    terry_vance = User.new(
      { :login => 'terryvance',
        :email => 'terry.vance@intura.co.uk',
        :title => 'Mr',
        :firstName => 'Terry',
        :lastName => 'Vance',
        :password => '123456',
        :state => 'active',
        :userType => 'contractor',
        :phone => '020 8866 1112',
        :addr1 => '12a Diamond Road',
        :city => 'Harrow',
        :region => 'Middlesex',
        :postCode => 'HA1 3CF',
        :setup => true
      })

    terry_vance.method(:encrypt_password)
    terry_vance.method(:make_password_reset_code)
    
    terry_vance_contractor = Contractor.new()
    terry_vance_contractor.user = terry_vance
    terry_vance_contractor.save(false)
    
    terry_vance.contractor_id = terry_vance_contractor.id
    terry_vance.activate
    
    puts "*** Creating contract (ABN17872) for ABN Amro ***"
    puts "...Terry Vance, 8 Weeks, Daily Paid, 420"
    abn_contract1 = Contract.new(
      { :startDate => @the_date - 6.weeks,
        :endDate => @the_date + 2.weeks,
        :ref => 'ABN17872',
        :position => 'Technical Documentation Specialist',
        :client => abn,
        :margin => abn.margin,
        :rateType => 'Day',
      })
    abn_contract1_std = Rate.new({:name => 'Standard Rate', :payRate => 420, :chargeRate => 460.95, :comment => 'Standard rate', :default => true, :active => true, :rateType => 'Day', :category => 'Standard' })
    abn_contract1.contractors << terry_vance_contractor
    abn_contract1.rates << abn_contract1_std
    abn_contract1.save(false)
    
    puts "*** Creating timesheets for Terry Vance (ABM17872) ***"
    abn_c1_ts1 = abn_contract1.create_next_timesheet
    abn_c1_ts1.timesheet_entries[0].dayValue = 1
    abn_c1_ts1.timesheet_entries[0].rate = abn_contract1_std
    abn_c1_ts1.timesheet_entries[1].dayValue = 1
    abn_c1_ts1.timesheet_entries[1].rate = abn_contract1_std
    abn_c1_ts1.timesheet_entries[2].dayValue = 1
    abn_c1_ts1.timesheet_entries[2].rate = abn_contract1_std
    abn_c1_ts1.timesheet_entries[3].dayValue = 1
    abn_c1_ts1.timesheet_entries[3].rate = abn_contract1_std
    abn_c1_ts1.timesheet_entries[4].dayValue = 1
    abn_c1_ts1.timesheet_entries[4].rate = abn_contract1_std
    abn_c1_ts1.status = 'SUBMITTED'
    abn_c1_ts1.save(false)
    
    puts "...#{abn_c1_ts1.startDate} (SUBMITTED)"
    
    abn_c1_ts1.note = "Job well done!"
    abn_c1_ts1.status = 'APPROVED'
    abn_c1_ts1.save(false)
    
    puts "...#{abn_c1_ts1.startDate} (APPROVED)"
    
    abn_c1_ts2 = abn_contract1.create_next_timesheet
    abn_c1_ts2.timesheet_entries[0].dayValue = 1
    abn_c1_ts2.timesheet_entries[0].rate = abn_contract1_std
    abn_c1_ts2.timesheet_entries[1].dayValue = 1
    abn_c1_ts2.timesheet_entries[1].rate = abn_contract1_std
    abn_c1_ts2.timesheet_entries[2].dayValue = 1
    abn_c1_ts2.timesheet_entries[2].rate = abn_contract1_std
    abn_c1_ts2.timesheet_entries[3].dayValue = 1
    abn_c1_ts2.timesheet_entries[3].rate = abn_contract1_std
    abn_c1_ts2.timesheet_entries[4].dayValue = 1
    abn_c1_ts2.timesheet_entries[4].rate = abn_contract1_std
    abn_c1_ts2.status = 'SUBMITTED'
    abn_c1_ts2.save(false)
    
    puts "...#{abn_c1_ts2.startDate} (SUBMITTED)"
    
    abn_c1_ts2.status = 'APPROVED'
    abn_c1_ts2.save(false)
    
    puts "...#{abn_c1_ts2.startDate} (APPROVED)"
    
    abn_c1_ts3 = abn_contract1.create_next_timesheet
    abn_c1_ts3.timesheet_entries[0].dayValue = 1
    abn_c1_ts3.timesheet_entries[0].rate = abn_contract1_std
    abn_c1_ts3.timesheet_entries[1].dayValue = 1
    abn_c1_ts3.timesheet_entries[1].rate = abn_contract1_std
    abn_c1_ts3.timesheet_entries[2].dayValue = 1
    abn_c1_ts3.timesheet_entries[2].rate = abn_contract1_std
    abn_c1_ts3.timesheet_entries[3].dayValue = 1
    abn_c1_ts3.timesheet_entries[3].rate = abn_contract1_std
    abn_c1_ts3.timesheet_entries[4].dayValue = 1
    abn_c1_ts3.timesheet_entries[4].rate = unpaid_rate
    abn_c1_ts3.status = 'SUBMITTED'
    abn_c1_ts3.save(false)
    
    puts "...#{abn_c1_ts3.startDate} (SUBMITTED)"
    
    abn_c1_ts3.status = 'APPROVED'
    abn_c1_ts3.save(false)
    
    puts "...#{abn_c1_ts3.startDate} (APPROVED)"
    
  end
  
  task :cleardown => :configure do
    
    puts "*** Clearing down existing data ***"
    
    puts "Deleting clients..."
    Client.delete_all
    puts "Deleting contracts..."
    Contract.delete_all
    puts "Deleting timesheets..."
    Timesheet.delete_all
    puts "Deleting timesheet history"
    TimesheetHistory.delete_all
    puts "Deleting timesheet entries..."
    TimesheetEntry.delete_all
    puts "Deleting timesheet entries history"
    TimesheetEntryHistory.delete_all
    puts "Deleting invoices..."
    Invoice.delete_all
    puts "Deleting rates..."
    Rate.delete_all
    puts "Deleting agency invoices..."
    AgencyInvoice.delete_all
    AgencyInvoiceDetail.delete_all
    puts "Deleting approver requests..."
    ApproverRequest.delete_all
    puts "Deleting Agencies"
    Agency.delete_all
    puts "Deleting users"
    User.delete_all
    puts "Deleting permissions..."
    Permission.delete_all
    puts "Deleting roles..."
    Role.delete_all
    puts "Deleting settings"
    Settings.delete_all
    puts "Deleting additional join tables..."
    ActiveRecord::Base.connection.execute("delete from invoices_timesheets")
    ActiveRecord::Base.connection.execute("delete from contracts_users")
    ActiveRecord::Base.connection.execute("delete from clients_users")
    ActiveRecord::Base.connection.execute("delete from contractors_contracts")

    puts "*** Setting AUTO_INCREMENT for tables back to 1 ***"
    ActiveRecord::Base.connection.execute("ALTER TABLE `agencies` AUTO_INCREMENT = 1;")
    ActiveRecord::Base.connection.execute("ALTER TABLE `users` AUTO_INCREMENT = 1;")
    ActiveRecord::Base.connection.execute("ALTER TABLE `clients` AUTO_INCREMENT = 1;")
    ActiveRecord::Base.connection.execute("ALTER TABLE `contracts` AUTO_INCREMENT = 1;")
    ActiveRecord::Base.connection.execute("ALTER TABLE `timesheets` AUTO_INCREMENT = 1;")
    ActiveRecord::Base.connection.execute("ALTER TABLE `timesheet_entries` AUTO_INCREMENT = 1;")
    ActiveRecord::Base.connection.execute("ALTER TABLE `timesheet_histories` AUTO_INCREMENT = 1;")
    ActiveRecord::Base.connection.execute("ALTER TABLE `timesheet_entry_histories` AUTO_INCREMENT = 1;")
    ActiveRecord::Base.connection.execute("ALTER TABLE `roles` AUTO_INCREMENT = 1;")
    ActiveRecord::Base.connection.execute("ALTER TABLE `permissions` AUTO_INCREMENT = 1;")
    ActiveRecord::Base.connection.execute("ALTER TABLE `approver_requests` AUTO_INCREMENT = 1;")
    ActiveRecord::Base.connection.execute("ALTER TABLE `bank_holidays` AUTO_INCREMENT = 1;")
    ActiveRecord::Base.connection.execute("ALTER TABLE `invoices` AUTO_INCREMENT = 1;")
    ActiveRecord::Base.connection.execute("ALTER TABLE `rates` AUTO_INCREMENT = 1;")
    ActiveRecord::Base.connection.execute("ALTER TABLE `settings` AUTO_INCREMENT = 1;")
    ActiveRecord::Base.connection.execute("ALTER TABLE `tasks` AUTO_INCREMENT = 1;")
    
  end
  
  task :configure, [:from_date] => :environment do |t, args|
  
    puts "Setting up some basic data..."
    
    if args.RAILS_ENV == 'production'
      abort("Aborted: Can't run clockoff:setup in production environment")
    end
    
    args.with_defaults(:from_date => Date.today)
    
    puts "*** #{args.from_date} is the supplied date ***"
    
    if args.from_date.class != Date
      d = Date.parse(args.from_date)
    else
      d = args.from_date
    end
    
    # get the monday on or after this date
    if d.wday == 0
      @the_date = d - 6.days
    elsif d.wday != 1
      @the_date = d - (d.wday - 1).days
    else
      @the_date = d
    end
    
    # set some dates in the past.
    @last_month = @the_date - 1.month
    @last_quarter = @the_date - 3.months
    @six_months_ago = @the_date - 6.months
  
    puts "*** #{@the_date} is the starting point for the data ***"
    
  end

end