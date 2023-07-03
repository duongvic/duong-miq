Vmdb::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  config.eager_load_paths = []

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false
  config.eager_load = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Raise exception on mass assignment protection for Active Record models
  # TODO: Fix our code to abide by Rails mass_assignment protection:
  # http://jonathanleighton.com/articles/2011/mass-assignment-security-shouldnt-happen-in-the-model/
  # config.active_record.mass_assignment_sanitizer = :strict

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true

  config.assets.quiet = true

  # Include miq_debug in the list of assets here because it is only used in development
  config.assets.precompile << 'miq_debug.js'
  config.assets.precompile << 'miq_debug.css'
  # Include totally (https://khan.github.io/tota11y/) here for dev-mode only to help working
  # on accessibility issues.
  config.assets.precompile << 'tota11y.js'

  # Customize any additional options below...

  # Do not include all helpers for all views
  config.action_controller.include_all_helpers = false

  config.colorize_logging = true

  config.action_controller.allow_forgery_protection = true

  config.default_miq_group = 4
  config.default_miq_tenant = 1
  config.default_miq_role = 3
  config.default_key = 'eyJhbGciOiJub25lIn0'

  # Benji Client for backup
  config.backup_url = 'http://172.16.1.251:5000/api/v1/benji'

  config.backup_grpc = '172.16.1.252:55051'

  config.ceph_url = 'http://172.16.0.113:8443/api'
  config.ceph_credentials = {:username => 'admin',
                             :password => 'WujN3oc7iVImR0UP'}

  # Mailer development config
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.delivery_method = :smtp
  host = 'localhost:3000'
  config.action_mailer.default_url_options = {:host => host, :protocol => 'http'}
  config.support_mail = 'ftel.fti.cas.support@fpt.com.vn'
  config.vnc_host = 'https://webconsole-hn.fptvds.vn/vnc_auto.html'

  # Netbox
  config.netbox = {
    :url => 'http://172.16.0.240/api/',
    :token => '74a08603348cc10a9814bc0c5654a41815aa793e',
    :timeout => 5
  }

  config.load_balancer = {
    :flavor => {
      :cpus => 2,
      :mem => 4.gigabytes,
      :disk => 80.gigabytes
    },
    :public_net => "VLAN1010"
  }
end
