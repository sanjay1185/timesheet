# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.3' unless defined? RAILS_GEM_VERSION

#ENV['RAILS_ENV'] = 'production'

# 
# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|

  config.active_record.observers = :user_observer, :timesheet_observer, :invoice_observer, :agency_observer
  
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.

  # Add additional load paths for your own custom dirs
  #config.load_paths += %W( #{RAILS_ROOT}/app/reports )

  # Specify gems that this application depends on and have them installed with rake gems:install
  # config.gem "bj"
  # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
  # config.gem "sqlite3-ruby", :lib => "sqlite3"
  # config.gem "aws-s3", :lib => "aws/s3"
  config.gem "calendar_date_select"
  config.gem "hirb"
  #config.gem "thoughtbot-factory_girl", :lib => "factory_girl", :source => "http://gems.github.com"
               
  #config.gem 'fiveruns_tuneup'
  
  # Only load the plugins named here, in the order given (default is alphabetical).
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Skip frameworks you're not going to use. To use Rails without a database,
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

  # Your secret key for verifying cookie session data integrity.
  # If you change this key, all old sessions will become invalid!
  # Make sure the secret is at least 30 characters and all random,
  # no regular words or you'll be exposed to dictionary attacks.
  config.action_controller.session = {
    :session_key => '_clockoff_session',
    :secret      => 'c6151242c07d298c267fdc18de36056b0a2f1ce31da43df7e873a9f7f177ee30550515c37efe5496b6c1a741ae0c51eff6866467ae8495c24c783d79d48c29d6'
  }

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.time_zone = 'London'

  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  # config.i18n.default_locale = :de

  config.after_initialize do
    require "will_paginate"
    require "faster_csv"
  end

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