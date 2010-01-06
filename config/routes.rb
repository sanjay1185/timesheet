ActionController::Routing::Routes.draw do |map|

  map.resources :agency_invoices do |agency_invoice|
    agency_invoice.resources :agency_invoice_details
  end

  map.resources :clients,
    :member => { :new_approver => :get,
                 :remove_approver => :get,
                 :invite_approver => :post,
                 :add_approver => :post,
                 :delete_client => :get}

  map.resources :timesheets do |timesheet|
    timesheet.resources :timesheet_entries
  end

  map.resources :timesheets,
    :member => { :view => :get,
                 :reject_timesheet => :post,
                 :manual_approval => :get,
                 :approve => :post}

  map.resources :contractors,
    :has_many => [ :contracts ],
    :member => { :contracts => :get,
                 :denied => :get,
                 :logout => :get }

  map.resources :clients do |client|
     client.resources :contracts, 
       :has_many => [ :users, :contractors, :rates ],
       :member => { :add_approver => :get,
                    :remove_approver => :get,
                    :save_added_approver => :get,
                    :contractor_search => :post,
                    :delete_contract => :get,
                    :contractor_add => :get,
                    :contractor_remove => :get }
  end

  map.resource :rates, 
    :member => { :delete_rate => :get }

  map.resources :contracts do |contract|
    contract.resources :timesheets
  end

  map.invoice_search 'invoices/search', :controller => 'invoices', :action => 'search'

  map.resources :invoices

  map.view_timesheet 'approverdashboard/view_timesheet', :controller => 'approverdashboard', :action => 'view_timesheet', :method => :get
  map.approve_deny_timesheets 'approverdashboard/approve_deny_timesheets', :controller => 'approverdashboard', :action => 'approve_deny_timesheets', :method => :post
  map.approver_edit 'approverdashboard/edit_approver', :controller => 'approverdashboard', :action => 'edit_approver'
	map.approver_workers 'approverdashboard/workers', :controller => 'approverdashboard', :action => 'workers'
  map.approver_update 'approverdashboard/update_approver', :controller => 'approverdashboard', :action => 'update_approver', :method => :post
  map.approver_logout 'approverdashboard/logout', :controller => 'approverdashboard', :action => 'logout'

  map.resources :contractors do |contractor|
    contractor.resources :timesheets, :member => { :emailapproval => :post, :cancel_timesheet_alert => :get, :generate_pdf => :get }
  end

  map.resources :users, :member => { :suspend => :put, :unsuspend => :put, :delete_user => :get }

  map.resource :session, :controller => 'session'

  map.resources :agencies,
    :member => {:users => :get, :user_add => :get, :save_new_user => :post, :view_contractor => :get,
    :timesheet_history => :get, :outstanding => :get, :view_timesheet => :get, :settings => :get, :logout => :get,
    :send_reminder_to_approvers => :post, :reports => :get, :report => :get, :denied => :get,  
    :invite_workers => :get, :send_invites => :post, :reject_timesheet => :post, :user_update => :post, 
    :view_history => :get, :reject_timesheet_alert => :get, :active_clients => :get, 
    :active_contracts => :get, :tools => :get, :stats => :get, :remove_logo => :get
    }

  map.process_request '/process_request', :controller => 'users', :action => 'process_request'
  map.register_approver '/register_approver/:id', :controller => 'users', :action => 'register_approver'
  map.approver_request '/approver_request/:code', :controller => 'users', :action => 'approver_request'
  map.activate '/activate/:activation_code', :controller => 'users', :action => 'activate'
  map.approverdashboard '/approverdashboard', :controller => 'approverdashboard', :action => 'index'
  map.currenttimesheets '/currenttimesheets', :controller => 'timesheets', :action => 'list_current_for_contractor'
  map.preparetimesheet '/preparetimesheet', :controller => 'timesheets', :action => 'prepare', :method => :get
  map.register '/register', :controller => 'agencies', :action => 'new'
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.login '/login', :controller => 'session', :action => 'new'
  map.logout '/logout', :controller => 'session', :action => 'destroy'
  map.loggedout '/loggedout', :controller => 'session', :action => 'loggedout'
  map.forgot_password '/forgot_password', :controller => 'users', :action => 'forgot_password'
  map.reset_password '/reset_password/:id', :controller => 'users', :action => 'reset_password'
  map.forgot_username '/forgot_username', :controller => 'users', :action => 'forgot_username'
  map.connect 'agencies/:id/contractors', :controller => 'agencies', :action => 'contractors'
  map.timesheetreport 'timesheetreport', :controller => 'timesheets', :action => 'report'
  map.runreport '/runreport', :controller => 'timesheets', :action => 'runreport', :method => :get
  map.import_clients '/import_clients', :controller => 'clients', :action => 'import_clients', :method => :get

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller

  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => "session", :action => "new"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
  map.connect 'help/:action', :controller => 'help'
end
