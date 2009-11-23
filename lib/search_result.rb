class SearchResult

  attr_accessor :type, :start_date, :end_date, :status, :contractor_name, :ref, :url, :icon, :tooltip
  
  def self.merge_results(timesheets, contracts, agency_id, order)
    
    results = []
    
    for ts in timesheets
      
      result = SearchResult.new
      result.start_date = ts.startDate
      result.end_date = ts.end_date
      result.status = ts.status
      result.contractor_name = ts.contractor.user.full_name
      result.ref = ts.contract.ref
      result.url = "/agencies/#{agency_id}/view_timsheet?timesheet_id=#{ts.id}" 
      result.icon = "/images/alarm.gif"
      result.tooltip = "Timesheet"
      result.type = "Timesheet"
      results << result
      
    end
    
    for c in contracts
      
      result = SearchResult.new
      result.start_date = c.startDate
      result.end_date = c.endDate
      result.status = c.status
      result.contractor_name = c.contractors[0].user.full_name
      result.ref = c.ref
      result.url = "/agencies/#{agency_id}/clients/#{c.client_id}/contracts/#{c.id}" 
      result.icon = "/images/calendar.gif"
      result.tooltip = "Contract"
      result.type = "Contract"
      results << result
      
    end
       
    return sort(results, order)
    
  end
  
  def self.sort(results, order)
    
     # get sort order
    sort_order = order.split(' ')
    
    ordered_results = nil
    
    if sort_order[0] == 'type'
      if sort_order[1] == 'ASC'
        ordered_results = results.sort {|x, y| x.type <=> y.type}
      else
        ordered_results = results.sort {|x, y| y.type <=> x.type}
      end
    elsif sort_order[0] == 'start_date'
      if sort_order[1] == 'ASC'
        ordered_results = results.sort {|x, y| x.start_date <=> y.start_date}
      else
        ordered_results = results.sort {|x, y| y.start_date <=> x.start_date}
      end
    elsif sort_order[0] == 'end_date'
      if sort_order[1] == 'ASC'
        ordered_results = results.sort {|x, y| x.end_date <=> y.end_date}
      else
        ordered_results = results.sort {|x, y| y.end_date <=> x.end_date}
      end
    elsif sort_order[0] == 'ref'
      if sort_order[1] == 'ASC'
        ordered_results = results.sort {|x, y| x.ref <=> y.ref}
      else
        ordered_results = results.sort {|x, y| y.ref <=> x.ref}
      end
    elsif sort_order[0] == 'contractor_name'
      if sort_order[1] == 'ASC'
        ordered_results = results.sort {|x, y| x.contractor_name <=> y.contractor_name}
      else
        ordered_results = results.sort {|x, y| y.contractor_name <=> x.contractor_name}
      end
    elsif sort_order[0] == 'status'
      if sort_order[1] == 'ASC'
        ordered_results = results.sort {|x, y| x.status <=> y.status}
      else
        ordered_results = results.sort {|x, y| y.status <=> x.status}
      end
    end
    
    return ordered_results
  end

end