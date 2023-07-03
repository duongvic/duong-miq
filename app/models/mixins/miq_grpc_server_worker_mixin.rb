class NoFreePortError < StandardError; end

module MiqGrpcServerWorkerMixin
  extend ActiveSupport::Concern

  BINDING_ADDRESS = ENV['BINDING_ADDRESS'] || (Rails.env.production? ? "127.0.0.1" : "0.0.0.0")
  BINDING_PORT = "50052".freeze

  included do
    class << self
      attr_accessor :registered_ports
    end

    try(:maximum_workers_count=, 10)
  end

  module ClassMethods
    def binding_address
      BINDING_ADDRESS
    end

    def binding_port
      BINDING_PORT
    end

    def build_uri
      "#{binding_address}:#{binding_port}"
    end

    def preload_for_worker_role
      raise "Expected database to be seeded via `rake db:seed`." unless EvmDatabase.seeded_primordially?
    end
  end

  def release_db_connection
    self.update_spid!(nil)
    self.class.release_db_connection
  end

end
