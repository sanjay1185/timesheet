class TimeUtil
	# convert "09:30" to 9.5 or "9:45" to 9.75 etc
	def self.hours_to_numeric(hours)
    return 0 if hours.blank?
		left = hours[0,hours.index(":")].to_i
		right = hours[hours.index(":")+1,2].to_i
		return left + (((right * 5) / 3) / 100.to_f)
	end

  # convert 9.5 to 9:30 or 8.75 to 8:45 etc
  def self.numeric_to_hours(hours)
    return "0:00" if hours.nil? || hours == 0
    hrs_i = hours.to_i
    hrs_f = hours.to_f
    units = hrs_f % hrs_i  
    units = ((units / 5) * 300)
    hrs_s = "#{hours.to_i.to_s}:#{units.to_i.to_s}"
    hrs_s += "0" if hrs_s =~ /:0$/
    return hrs_s
  end
end

class PaymentUtil
  def self.get_monthly_payment_total(count)
    return case
    when count < 24 then 50
    when count < 49 then 100
    when count < 74 then 150
    when count < 99 then 200
    when count < 149 then 250
    when count < 199 then 300
    when count < 249 then 350
    when count < 299 then 400
    when count < 349 then 450
    else 500
    end
  end
end

