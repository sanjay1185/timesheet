class Finder
  
  def self.search_for_timesheets(criteria)
    
    criteria = "%#{criteria}%"
    timesheet_sql = "ctrt.contractor_user_id = u.id and t.contract_id = ctrt.id "
    timesheet_sql += "and (t.userName like ? or ctrt.ref like ? or u.companyName like ? or u.firstName like ? or u.lastName like ?)"
    
    return Timesheet.find(:all, :conditions => [timesheet_sql, criteria, criteria, criteria, criteria, criteria], :select => "distinct t.*", :joins => "t, contracts ctrt, users u")
    
  end
  
  def self.search_for_contracts(criteria)
    
    criteria = "%#{criteria}%"
    contract_sql = "c.id = u.contract_id and c.contractor_user_id = u.id "
    contract_sql += "and (c.ref like ? or u.companyName like ? or u.companyNumber like ? "
    contract_sql += "or u.vatNumber like ? or u.firstName like ? or u.lastName like ? or u.login like ?)"
    
    return Contract.find(:all, :conditions => [contract_sql, criteria, criteria, criteria, criteria, criteria, criteria, criteria], :select => "distinct c.*", :joins => "c, users u")
    
  end
  
end