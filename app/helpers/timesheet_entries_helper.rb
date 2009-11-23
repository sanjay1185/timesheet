module TimesheetEntriesHelper
	def DayValueAsText(value)
		text = case value
			when 1 then "Full"
			when 0.5 then "Half"
			when 0.25 then "Quarter"
			when 0 then "None"
		end
		return text
	end
end
