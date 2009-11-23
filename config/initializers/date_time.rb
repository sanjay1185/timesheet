class DateTime
  
  def self.get_day(n)
    
    return case
      when n == 0 then "Sunday"
      when n == 1 then "Monday"
      when n == 2 then "Tuesday"
      when n == 3 then "Wednesday"
      when n == 4 then "Thursday"
      when n == 5 then "Friday"
      when n == 6 then "Saturday"
    end
      
  end
  
end