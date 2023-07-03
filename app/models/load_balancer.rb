class LoadBalancer < ApplicationRecord
  include NewWithTypeStiMixin
  include SupportsFeatureMixin
  include AsyncDeleteMixin
  include ProcessTasksMixin
  include TenantIdentityMixin
  include CloudTenancyMixin
  include CustomActionsMixin
  include OwnershipMixin

  acts_as_miq_taggable

  belongs_to :ext_management_system, :foreign_key => :ems_id, :class_name => "ManageIQ::Providers::NetworkManager"
  belongs_to :cloud_tenant
  belongs_to :tenant

  has_many :load_balancer_health_checks, :dependent => :destroy
  has_many :load_balancer_listeners, :dependent => :destroy
  has_many :load_balancer_health_checks, :dependent => :destroy

  has_many :load_balancer_pools, :through => :load_balancer_listeners
  has_many :load_balancer_pool_members, :through => :load_balancer_pools

  # has_many :load_balancer_listener_pools, :through => :load_balancer_listeners
  # has_many :load_balancer_pools, :through => :load_balancer_listener_pools
  # has_many :load_balancer_pool_member_pools, :through => :load_balancer_pools
  # has_many :load_balancer_pool_members, -> { distinct }, :through => :load_balancer_pool_member_pools

  has_many :network_ports, :as => :device
  has_many :cloud_subnet_network_ports, :through => :network_ports
  has_many :cloud_subnets, :through => :cloud_subnet_network_ports
  has_many :floating_ips, :through => :network_ports, :source => :floating_ips
  has_many :security_groups, -> { distinct }, :through => :network_ports

  has_many :vms, -> { distinct }, :through => :load_balancer_pool_members
  has_many :resource_groups, -> { distinct }, :through => :load_balancer_pool_members

  has_many :service_resources, :as => :resource
  has_many :direct_services, :through => :service_resources, :source => :service

  virtual_has_one :direct_service, :class_name => 'Service'
  virtual_has_one :service, :class_name => 'Service'

  virtual_total :total_vms, :vms, :uses => :vms

  def direct_service
    direct_services.first
  end

  def self.class_by_ems(ext_management_system)
    # TODO: use a factory on ExtManagementSystem side to return correct class for each provider
    ext_management_system && ext_management_system.class::LoadBalancer
  end

  def service
    direct_service.try(:root_service)
  end

  # def self.create_load_balancer(load_balancer_manager, load_balancer_name, options = {})
  #   klass = load_balancer_class_factory(load_balancer_manager)
  #   ems_ref = klass.raw_create_load_balancer(load_balancer_manager,
  #                                            load_balancer_name,
  #                                            options)
  #   tenant = CloudTenant.find_by(:name => options[:tenant_name], :ems_id => load_balancer_manager.id)
  #
  #   klass.create(:name                  => load_balancer_name,
  #                :ems_ref               => ems_ref,
  #                :ext_management_system => load_balancer_manager,
  #                :cloud_tenant          => tenant)
  # end
  #
  # def self.load_balancer_class_factory(load_balancer_manager)
  #   "#{load_balancer_manager.class.name}::LoadBalancer".constantize
  # end

  def raw_update_load_balancer(_options = {})
    raise NotImplementedError, _("raw_update_load_balancer must be implemented in a subclass")
  end

  def update_load_balancer(options = {})
    raw_update_load_balancer(options)
  end

  def update_load_balancer_queue(userid, options = {})
    task_opts = {
      :action => "updating Load Balancer for user #{userid}",
      :userid => userid
    }
    queue_opts = {
      :class_name  => self.class.name,
      :method_name => 'update_load_balancer',
      :instance_id => id,
      :priority    => MiqQueue::NORMAL_PRIORITY,
      :role        => 'ems_operations',
      :zone        => ext_management_system.my_zone,
      :args        => [options]
    }
    MiqTask.generic_action_with_callback(task_opts, queue_opts)
  end

  def raw_delete_load_balancer
    raise NotImplementedError, _("raw_delete_load_balancer must be implemented in a subclass")
  end

  def delete_load_balancer_queue(userid)
    task_opts = {
      :action => "deleting Load Balancer for user #{userid}",
      :userid => userid
    }
    queue_opts = {
      :class_name  => self.class.name,
      :method_name => 'delete_load_balancer',
      :instance_id => id,
      :priority    => MiqQueue::NORMAL_PRIORITY,
      :role        => 'ems_operations',
      :zone        => ext_management_system.my_zone,
      :args        => []
    }
    MiqTask.generic_action_with_callback(task_opts, queue_opts)
  end

  def delete_load_balancer
    raw_delete_load_balancer
  end

  def raw_sync_load_balancer
    raise NotImplementedError, _("raw_sync_load_balancer must be implemented in a subclass")
  end

  def sync_load_balancer_queue(userid)
    task_opts = {
      :action => "sync Load Balancer for user #{userid}",
      :userid => userid
    }
    queue_opts = {
      :class_name  => self.class.name,
      :method_name => 'sync_load_balancer',
      :instance_id => id,
      :priority    => MiqQueue::NORMAL_PRIORITY,
      :role        => 'ems_operations',
      :zone        => ext_management_system.my_zone,
      :args        => []
    }
    MiqTask.generic_action_with_callback(task_opts, queue_opts)
  end

  def sync_load_balancer
    raw_sync_load_balancer
  end

  def update_load_balancer_listener(userid, key)
    task_opts = {
      :action => "Update Load Balancer Listener for user #{userid}",
      :userid => userid
    }
    queue_opts = {
      :class_name  => self.class.name,
      :method_name => 'raw_update_load_balancer_listener',
      :instance_id => id,
      :priority    => MiqQueue::HIGH_PRIORITY,
      :role        => 'ems_operations',
      :zone        => ext_management_system.my_zone,
      :args        => [key]
    }
    MiqTask.generic_action_with_callback(task_opts, queue_opts)
  end

  def update_load_balancer_pool(userid, key)
    task_opts = {
      :action => "Update Load Balancer Pool for user #{userid}",
      :userid => userid
    }
    queue_opts = {
      :class_name  => self.class.name,
      :method_name => 'raw_update_load_balancer_pool',
      :instance_id => id,
      :priority    => MiqQueue::HIGH_PRIORITY,
      :role        => 'ems_operations',
      :zone        => ext_management_system.my_zone,
      :args        => [key]
    }
    MiqTask.generic_action_with_callback(task_opts, queue_opts)
  end

  def add_load_balancer_pool_member(userid, key)
    task_opts = {
      :action => "add Load Balancer Pool Member for user #{userid}",
      :userid => userid
    }
    queue_opts = {
      :class_name  => self.class.name,
      :method_name => 'raw_add_load_balancer_pool_member',
      :instance_id => id,
      :priority    => MiqQueue::HIGH_PRIORITY,
      :role        => 'ems_operations',
      :zone        => ext_management_system.my_zone,
      :args        => [key]
    }
    MiqTask.generic_action_with_callback(task_opts, queue_opts)
  end

  def delete_load_balancer_pool_member(userid, key)
    task_opts = {
      :action => "delete Load Balancer Pool Member for user #{userid}",
      :userid => userid
    }
    queue_opts = {
      :class_name  => self.class.name,
      :method_name => 'raw_delete_load_balancer_pool_member',
      :instance_id => id,
      :priority    => MiqQueue::HIGH_PRIORITY,
      :role        => 'ems_operations',
      :zone        => ext_management_system.my_zone,
      :args        => [key]
    }
    MiqTask.generic_action_with_callback(task_opts, queue_opts)
  end

  def raw_status
    raise NotImplementedError, _("raw_status must be implemented in a subclass")
  end

  def raw_exists?
    raise NotImplementedError, _("raw_exists must be implemented in a subclass")
  end

  # query the class for the reason why something is unsupported
  def unsupported_reason(feature)
    SupportsFeatureMixin.guard_queryable_feature(feature)
    feature = feature.to_sym
    public_send("supports_#{feature}?") unless unsupported.key?(feature)
    unsupported[feature]
  end
end
