class Finder
  
  def self.search_for_timesheets(criteria)
    
    criteria = "%#{criteria}%"
    timesheet_sql = "t.contractor_id = ctror.id and t.contract_id = ctrt.id and ctror.user_id = u.id "
    timesheet_sql += "and (t.userName like ? or ctrt.ref like ? or ctror.companyName like ? or u.firstName like ? or u.lastName like ?)"
    
    return Timesheet.find(:all, :conditions => [timesheet_sql, criteria, criteria, criteria, criteria, criteria], :select => "distinct t.*", :joins => "t, contracts ctrt, contractors ctror, users u")
    
  end
  
  def self.search_for_contracts(criteria)
    
    criteria = "%#{criteria}%"
    contract_sql = "c.id = cc.contract_id and cc.contractor_id = ctor.id and ctor.user_id = u.id "
    contract_sql += "and (c.ref like ? or ctor.companyName like ? or ctor.companyNumber like ? "
    contract_sql += "or ctor.vatNumber like ? or u.firstName like ? or u.lastName like ? or u.login like ?)"
    
    return Contract.find(:all, :conditions => [contract_sql, criteria, criteria, criteria, criteria, criteria, criteria, criteria], :select => "distinct c.*", :joins => "c, contractors_contracts cc, contractors ctor, users u")
    
  end
  
end