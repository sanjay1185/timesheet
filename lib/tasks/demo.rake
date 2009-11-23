namespace :demo do
  
  @monday = nil
  
  task :setup => :create do
    
    puts "Setting up new demo environment!"
    
  end
  
  task :init => :cleardown do
    
    today = Date.today
    if today.wday == 1
      @monday = today
    else
      if today.wday == 0
        @monday = today - 6.days
      else
        @monday = today - (today.wday - (today.wday - 1)).days
      end
    end
    
  end
  
  task :cleardown => :environment do
    
    @abn = Client.find_by_name('ABN Amro')
   
    puts "Deleting manual joins..."
    ActiveRecord::Base.connection.execute("delete t from invoices_timesheets t inner join invoices i on i.id = t.invoice_id where i.client_id = " + @abn.id.to_s)
    ActiveRecord::Base.connection.execute("delete cu from contracts_users cu inner join contracts c on c.id = cu.contract_id where c.client_id = " + @abn.id.to_s)
    ActiveRecord::Base.connection.execute("delete from clients_users where client_id = " + @abn.id.to_s)
    ActiveRecord::Base.connection.execute("delete cc from contractors_contracts cc inner join contracts c on c.id = cc.contract_id where c.client_id = " + @abn.id.to_s)
    puts "Deleting contracts..."
    Contract.delete_all("client_id = " + @abn.id.to_s)
    puts "Deleting invoices..."
    Invoice.delete_all("client_id = " + @abn.id.to_s)
    puts "Deleting agency invoices..."
    AgencyInvoice.delete_all("agency_id = 5")
    puts "Deleting approver requests..."
    ApproverRequest.delete_all("client_id = " + @abn.id.to_s)
    puts "Deleting additional join tables..."
   
    
  end
  
  task :create => :init do
    
    puts "Creating new demo data..."
    
    puts "Setting up contracts for ABN Amro"
    @abn = Client.find_by_name('ABN Amro')

    puts "Contract Saved (REF: ABN100)"
    @abn_contract1 = Contract.new({:startDate => @monday, :endDate => @monday + 1.month, :ref => 'ABN100', :rateType => 'Hour', :status => 'INACTIVE', :position => 'C# Developer', :client_id => @abn.id, :margin => 18.5, :calcChargeRateAsPAYE => false})
    @std_rate = Rate.new({:name => 'Default Standard', :rateType => 'Hour', :default => true, :payRate => 14.57, :chargeRate => 16.87, :comment => 'Default Standard Rate', :active => true})
    @abn_contract1.rates << @std_rate
    @abn_contract1.save

  end
  
end