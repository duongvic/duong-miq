# Initialize Netbox client

NetboxClientRuby.configure do |config|
  config.netbox.auth.token = Rails.application.config.netbox[:token]
  config.netbox.api_base_url = Rails.application.config.netbox[:url]
  config.faraday.request_options = { open_timeout: 1, timeout: Rails.application.config.netbox[:timeout] }
end