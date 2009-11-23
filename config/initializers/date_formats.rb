ActiveSupport::CoreExtensions::Date::Conversions::DATE_FORMATS.merge!(
	:uk_date => "%d/%m/%Y",
	:uk_date_with_day => "%d/%m/%Y %a",
  :uk_date_time_24 => "%d/%m/%Y %H:%M",
	:date_time12  => "%m/%d/%Y %I:%M%p",
	:date_time24  => "%m/%d/%Y %H:%M"
)

ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS.merge!(
	:uk_date => "%d/%m/%Y",
	:uk_date_with_day => "%d/%m/%Y %a",
  :uk_date_time_24 => "%d/%m/%Y %H:%M",
	:date_time12  => "%m/%d/%Y %I:%M%p",
	:date_time24  => "%m/%d/%Y %H:%M"
)