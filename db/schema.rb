# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100111045819) do

  create_table "agencies", :force => true do |t|
    t.string   "name",              :limit => 100,                                                  :null => false
    t.string   "addr1",             :limit => 75,                                                   :null => false
    t.string   "addr2",             :limit => 75
    t.string   "addr3",             :limit => 75
    t.string   "city",              :limit => 75,                                                   :null => false
    t.string   "region"
    t.string   "postCode",          :limit => 15,                                                   :null => false
    t.string   "phone",             :limit => 30,                                                   :null => false
    t.string   "fax",               :limit => 30,                                                   :null => false
    t.string   "email",             :limit => 100,                                                  :null => false
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "sageNominalCode",   :limit => 15
    t.boolean  "trial",                                                          :default => true,  :null => false
    t.boolean  "invoicing",                                                      :default => false, :null => false
    t.integer  "nextInvoiceNumber",                                              :default => 1,     :null => false
    t.decimal  "defaultMargin",                    :precision => 8, :scale => 2, :default => 0.0
    t.boolean  "useInvoicing",                                                   :default => true,  :null => false
    t.boolean  "calculatePAYE",                                                  :default => true,  :null => false
    t.boolean  "autoReminder",                                                   :default => false, :null => false
    t.integer  "cutOffDay"
    t.time     "cutOffTime"
  end

  create_table "agency_invoice_details", :force => true do |t|
    t.integer  "agency_invoice_id", :null => false
    t.integer  "contract_id",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "agency_invoice_details", ["agency_invoice_id"], :name => "index_agency_invoice_detail_on_agency_id"
  add_index "agency_invoice_details", ["contract_id"], :name => "index_agency_invoice_detail_on_contract_id"

  create_table "agency_invoices", :force => true do |t|
    t.date     "invoiceDate",                                 :null => false
    t.integer  "agency_id",                                   :null => false
    t.decimal  "netAmount",     :precision => 8, :scale => 2, :null => false
    t.decimal  "taxAmount",     :precision => 8, :scale => 2, :null => false
    t.decimal  "grossAmount",   :precision => 8, :scale => 2, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "invoiceNumber",                               :null => false
  end

  add_index "agency_invoices", ["agency_id"], :name => "index_agency_invoice_on_agency_id"

  create_table "approver_requests", :force => true do |t|
    t.integer  "user_id",                  :null => false
    t.integer  "client_id",                :null => false
    t.string   "code",       :limit => 40
    t.string   "status",     :limit => 15
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "approver_requests", ["user_id", "client_id"], :name => "index_approver_requests_on_user_id_and_client_id", :unique => true

  create_table "approvers", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bank_holidays", :force => true do |t|
    t.date     "holidayDate",              :null => false
    t.string   "countryCode", :limit => 2, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "clients", :force => true do |t|
    t.string   "name",                         :limit => 100,                                                      :null => false
    t.string   "addr1",                        :limit => 75,                                                       :null => false
    t.string   "addr2",                        :limit => 75
    t.string   "addr3",                        :limit => 75
    t.string   "city",                         :limit => 75,                                                       :null => false
    t.string   "region",                       :limit => 75
    t.string   "postCode",                     :limit => 15
    t.integer  "agency_id",                                                                                        :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "externalClientRef",            :limit => 20
    t.decimal  "margin",                                      :precision => 8, :scale => 2,                        :null => false
    t.integer  "monthlyInvoicePeriodStartDay",                                              :default => 1,         :null => false
    t.string   "invoicePeriod",                :limit => 10,                                :default => "Monthly", :null => false
    t.boolean  "invoiceTimesheetsSeparately",                                               :default => false,     :null => false
  end

  add_index "clients", ["agency_id"], :name => "index_clients_on_agency_id"
  add_index "clients", ["city"], :name => "index_clients_on_city"
  add_index "clients", ["name"], :name => "index_clients_on_name"

  create_table "clients_users", :id => false, :force => true do |t|
    t.integer "client_id", :null => false
    t.integer "user_id",   :null => false
  end

  add_index "clients_users", ["client_id", "user_id"], :name => "index_clients_users_on_client_id_and_user_id", :unique => true

  create_table "contractors", :force => true do |t|
    t.string   "companyName",   :limit => 100
    t.string   "vatNumber",     :limit => 30
    t.string   "companyNumber", :limit => 30
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "contractors", ["companyName"], :name => "index_contractors_on_companyName"
  add_index "contractors", ["user_id"], :name => "index_contractors_on_user_id"

  create_table "contractors_contracts", :id => false, :force => true do |t|
    t.integer "contractor_id",   :null => false
    t.integer "contract_id",     :null => false
    t.date    "terminationDate"
  end

  add_index "contractors_contracts", ["contractor_id", "contract_id"], :name => "index_contractors_contracts_on_contractor_id_and_contract_id", :unique => true

  create_table "contracts", :force => true do |t|
    t.date     "startDate",                                                                                :null => false
    t.date     "endDate",                                                                                  :null => false
    t.string   "position",             :limit => 75,                                                       :null => false
    t.string   "rateType",             :limit => 10,                               :default => "Hour",     :null => false
    t.string   "ref",                  :limit => 15,                                                       :null => false
    t.integer  "client_id",                                                                                :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status",               :limit => 15,                               :default => "INACTIVE", :null => false
    t.decimal  "margin",                             :precision => 8, :scale => 2
    t.boolean  "requireTimes",                                                     :default => false,      :null => false
    t.boolean  "requireFullWeek",                                                  :default => false,      :null => false
    t.boolean  "calcChargeRateAsPAYE",                                             :default => true,       :null => false
    t.boolean  "allowOvertime",                                                    :default => false,      :null => false
    t.boolean  "allowBankHolidays",                                                :default => false,      :null => false
  end

  add_index "contracts", ["client_id"], :name => "index_contracts_on_client_id"
  add_index "contracts", ["endDate"], :name => "index_contracts_on_endDate"
  add_index "contracts", ["ref"], :name => "index_contracts_on_ref"
  add_index "contracts", ["startDate"], :name => "index_contracts_on_startDate"

  create_table "contracts_users", :id => false, :force => true do |t|
    t.integer "contract_id",                    :null => false
    t.integer "user_id",                        :null => false
    t.boolean "isDefault",   :default => false, :null => false
  end

  add_index "contracts_users", ["contract_id", "user_id"], :name => "index_contracts_users_on_contract_id_and_user_id", :unique => true

  create_table "invoices", :force => true do |t|
    t.float    "netAmount",                                                                      :null => false
    t.decimal  "taxAmount",                    :precision => 10, :scale => 2
    t.decimal  "grossAmount",                  :precision => 10, :scale => 2,                    :null => false
    t.string   "ref",            :limit => 20
    t.integer  "client_id",                                                                      :null => false
    t.string   "txnDetails"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "invoiceDate",                                                                    :null => false
    t.datetime "lastExportDate"
    t.float    "margin",                                                      :default => 0.0,   :null => false
    t.boolean  "inactive",                                                    :default => false, :null => false
    t.decimal  "taxRate",                      :precision => 8,  :scale => 2,                    :null => false
  end

  add_index "invoices", ["client_id"], :name => "index_invoices_on_client_id"

  create_table "invoices_timesheets", :id => false, :force => true do |t|
    t.integer "invoice_id",   :null => false
    t.integer "timesheet_id", :null => false
  end

  add_index "invoices_timesheets", ["invoice_id", "timesheet_id"], :name => "index_invoices_timesheets_on_invoice_id_and_timesheet_id", :unique => true

  create_table "permissions", :force => true do |t|
    t.integer "role_id"
    t.integer "user_id"
    t.boolean "readOnly", :default => false, :null => false
  end

  create_table "rates", :force => true do |t|
    t.string   "name",          :limit => 30,                      :null => false
    t.float    "payRate"
    t.float    "chargeRate"
    t.string   "comment",       :limit => 100
    t.date     "effectiveDate"
    t.integer  "contract_id",                                      :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "default",                      :default => false,  :null => false
    t.date     "endDate"
    t.boolean  "active",                       :default => true,   :null => false
    t.string   "rateType",      :limit => 10,  :default => "Hour", :null => false
    t.string   "category",      :limit => 25,                      :null => false
  end

  add_index "rates", ["contract_id"], :name => "index_rates_on_contract_id"

  create_table "roles", :force => true do |t|
    t.string "name",        :limit => 30
    t.string "description"
  end

  create_table "scheduled_task_logs", :force => true do |t|
    t.integer  "scheduled_task_id"
    t.datetime "start"
    t.datetime "end"
    t.boolean  "success"
    t.string   "info"
  end

  create_table "scheduled_tasks", :force => true do |t|
    t.integer "task_id"
    t.integer "frequency_id"
    t.integer "time_of_day",  :default => 0, :null => false
  end

  create_table "settings", :force => true do |t|
    t.string   "name",          :null => false
    t.date     "effectiveDate"
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "settings", ["name"], :name => "index_settings_on_name"

  create_table "tasks", :force => true do |t|
    t.string  "name"
    t.string  "class_name"
    t.string  "method_name"
    t.boolean "is_running",  :default => false
  end

  add_index "tasks", ["name"], :name => "uq_tasks_name", :unique => true

  create_table "timesheet_entries", :force => true do |t|
    t.date     "dateValue",                                                                    :null => false
    t.integer  "timesheet_id",                                                                 :null => false
    t.string   "hours",        :limit => 5
    t.boolean  "disabled",                                                 :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "netAmount"
    t.string   "startTime",    :limit => 5
    t.string   "finishTime",   :limit => 5
    t.string   "breakHours",   :limit => 5
    t.boolean  "manual",                                                   :default => false,  :null => false
    t.decimal  "chargeRate",                 :precision => 8, :scale => 2
    t.integer  "rate_id"
    t.string   "rateType",     :limit => 10,                               :default => "Hour", :null => false
    t.decimal  "dayValue",                   :precision => 8, :scale => 2
    t.integer  "deleted",      :limit => 1,                                :default => 0,      :null => false
  end

  add_index "timesheet_entries", ["timesheet_id"], :name => "index_timesheet_entries_on_timesheet_id"

  create_table "timesheet_entry_histories", :force => true do |t|
    t.date     "dateValue",                                                                             :null => false
    t.integer  "timesheet_history_id",                                                                  :null => false
    t.string   "hours",                 :limit => 5
    t.boolean  "disabled",                                                          :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "netAmount"
    t.string   "startTime",             :limit => 5
    t.string   "finishTime",            :limit => 5
    t.string   "breakHours",            :limit => 5
    t.boolean  "manual",                                                            :default => false,  :null => false
    t.decimal  "chargeRate",                          :precision => 8, :scale => 2
    t.integer  "rate_id"
    t.string   "rateType",              :limit => 10,                               :default => "Hour", :null => false
    t.decimal  "dayValue",                            :precision => 8, :scale => 2
    t.integer  "original_timesheet_id"
  end

  add_index "timesheet_entry_histories", ["original_timesheet_id"], :name => "index_timesheet_entry_histories_on_original_timesheet_id"

  create_table "timesheet_histories", :force => true do |t|
    t.date     "startDate",                                                                              :null => false
    t.decimal  "totalDays",                           :precision => 8, :scale => 2
    t.string   "totalHours",            :limit => 6
    t.boolean  "invoiced",                                                          :default => false
    t.string   "status",                :limit => 20,                               :default => "DRAFT", :null => false
    t.string   "userName",              :limit => 75
    t.string   "note"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "lastExportedDateTime"
    t.float    "netAmount"
    t.float    "taxAmount"
    t.integer  "original_timesheet_id"
  end

  add_index "timesheet_histories", ["original_timesheet_id"], :name => "index_timesheet_histories_on_original_timesheet_id"

  create_table "timesheets", :force => true do |t|
    t.date     "startDate",                                                                             :null => false
    t.decimal  "totalDays",                          :precision => 8, :scale => 2
    t.string   "totalHours",           :limit => 6
    t.boolean  "invoiced",                                                         :default => false
    t.string   "status",               :limit => 20,                               :default => "DRAFT", :null => false
    t.integer  "contractor_id",                                                                         :null => false
    t.integer  "contract_id",                                                                           :null => false
    t.string   "note"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "lastExportedDateTime"
    t.float    "netAmount"
    t.float    "taxAmount"
    t.string   "rateType",             :limit => 10,                               :default => "Hour",  :null => false
    t.string   "userName",             :limit => 75
  end

  add_index "timesheets", ["contract_id"], :name => "index_timesheets_on_contract_id"
  add_index "timesheets", ["contractor_id"], :name => "index_timesheets_on_contractor_id"
  add_index "timesheets", ["startDate"], :name => "index_timesheets_on_startDate"

  create_table "users", :force => true do |t|
    t.string   "login",                     :limit => 15,                         :null => false
    t.string   "remember_token"
    t.string   "email",                     :limit => 100,                        :null => false
    t.string   "firstName",                 :limit => 25,                         :null => false
    t.string   "lastName",                  :limit => 25,                         :null => false
    t.string   "crypted_password",          :limit => 40,                         :null => false
    t.string   "password_reset_code",       :limit => 40,                         :null => false
    t.string   "salt",                      :limit => 40
    t.string   "activation_code",           :limit => 40
    t.datetime "remember_token_expires_at"
    t.datetime "activated_at"
    t.datetime "deleted_at"
    t.string   "state",                                    :default => "pending"
    t.string   "phone",                     :limit => 30
    t.string   "mobile",                    :limit => 30
    t.string   "addr1",                     :limit => 75
    t.string   "addr2",                     :limit => 75
    t.string   "addr3",                     :limit => 75
    t.string   "city",                      :limit => 75
    t.string   "region",                    :limit => 75
    t.string   "postCode",                  :limit => 15
    t.string   "userType"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "contractor_id"
    t.integer  "agency_id"
    t.string   "title",                     :limit => 5
    t.string   "type"
    t.integer  "contract_id",                                                     :null => false
  end

  add_index "users", ["agency_id"], :name => "index_users_on_agency_id"
  add_index "users", ["contractor_id"], :name => "index_users_on_contractor_id"
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["firstName"], :name => "index_users_on_firstName"
  add_index "users", ["lastName"], :name => "index_users_on_lastName"
  add_index "users", ["login"], :name => "index_users_on_login", :unique => true

end
