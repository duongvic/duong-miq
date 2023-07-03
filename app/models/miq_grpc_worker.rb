class MiqGrpcWorker < MiqWorker
  require_nested :Runner

  self.required_roles = ['web_services']

  def friendly_name
    @friendly_name ||= "Grpc Worker"
  end

  include MiqGrpcServerWorkerMixin

  def self.kill_priority
    MiqWorkerType::KILL_PRIORITY_GRPC_WORKERS
  end
end
