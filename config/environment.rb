# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.4' unless defined? RAILS_GEM_VERSION

#ENV['RAILS_ENV'] = 'production'

require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|

  config.active_record.observers = :user_observer, :timesheet_observer, :invoice_observer, :agency_observer

  config.gem "calendar_date_select"
  config.gem "hirb"
  config.gem "prawn"
  config.gem "fastercsv"
  config.gem "will_paginate"
  config.gem "capistrano"
  
  config.action_controller.session = {
    :session_key => '_clockoff_session',
    :secret      => 'c6151242c07d298c267fdc18de36056b0a2f1ce31da43df7e873a9f7f177ee30550515c37efe5496b6c1a741ae0c51eff6866467ae8495c24c783d79d48c29d6'
  }

  config.time_zone = 'London'

  config.after_initialize do
    require "will_paginate"
    require "faster_csv"
  end

end


if "irb" == $0
  ActiveRecord::Base.logger = Logger.new(STDOUT)
end

ExceptionNotifier.exception_recipients = %w(ben.hinton@intura.co.uk ben.hinton@live.com)
ExceptionNotifier.sender_address =  %("ClockOff.com Admin" <admin@clockoff.com>)

ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
  msg = instance.error_message
  error_style = "background-color: #f2afaf"
  if html_tag =~ /<(input|textarea|select)[^>]+style=/
    style_attribute = html_tag =~ /style=['"]/
    html_tag.insert(style_attribute + 7, "#{error_style}; ")
  elsif html_tag =~ /<(input|textarea|select)/
    first_whitespace = html_tag =~ /\s/
    html_tag[first_whitespace] = " style='#{error_style}' "
  end
  html_tag
end