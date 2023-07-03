module MiqGrpcServerRunnerMixin
  extend ActiveSupport::Concern

  def do_work
  end

  def do_before_work_loop
    @worker.release_db_connection
  end

  def run
    Dir.entries('app/grpc/').each do |dir|
      unless %w(. .. proto).include?(dir)
        $LOAD_PATH.unshift(File.expand_path("app/grpc/#{dir}")) unless $LOAD_PATH.include?(File.join(Rails.root, "app/grpc/#{dir}"))
      end
    end

    require_relative '../miq_grpc_worker/user_service'
    require_relative '../miq_grpc_worker/order_service'
    require 'grpc'

    worker_thread = Thread.new { super }

    start_grpc_server

    # when puma exits allow the heartbeat thread to exit cleanly using #do_exit
    worker_thread.join

  end

  def start_grpc_server
    warn_about_heartbeat_skipping if skip_heartbeat?

    grpc_addr = MiqGrpcWorker.build_uri
    @grpc_server = GRPC::RpcServer.new(:pool_size => 5)

    @grpc_server.add_http2_port(grpc_addr, :this_port_is_insecure)
    puts "GRPC Server Starting..."
    @grpc_server.handle(UserService)
    @grpc_server.handle(OrderService)
    puts "Listening on #{grpc_addr}"

    @grpc_server.run_till_terminated_or_interrupted([1, 'int', 'SIGTERM', 'SIGINT', 'SIGQUIT', 'SIGHUP'])
  rescue => err
    @grpc_server.stop
    _log.error("#{log_prefix} GRPC Thread aborted because [#{err.message}]")
    _log.log_backtrace(err) unless err.kind_of?(Errno::ECONNREFUSED)
    Thread.exit
  ensure
    @worker_should_exit = true
  end

end
