class NetworkRouter < ApplicationRecord
  include NewWithTypeStiMixin
  include SupportsFeatureMixin
  include CloudTenancyMixin
  include CustomActionsMixin
  include OwnershipMixin

  acts_as_miq_taggable

  belongs_to :ext_management_system, :foreign_key => :ems_id, :class_name => "ManageIQ::Providers::NetworkManager"
  belongs_to :cloud_tenant
  belongs_to :network_group
  belongs_to :cloud_network
  belongs_to :tenant

  has_many :cloud_subnets
  has_many :network_ports, -> { distinct }, :through => :cloud_subnets
  has_many :vms, -> { distinct }, :through => :cloud_subnets

  has_many :floating_ips, :through => :cloud_network
  has_many :cloud_networks, -> { distinct }, :through => :cloud_subnets
  has_many :security_groups, :dependent => :nullify
  # has_many :network_router_statics, :dependent => :destroy

  alias private_networks cloud_networks
  alias public_network cloud_network

  # Use for virtual columns, mainly for modeling array and hash types, we get from the API
  serialize :extra_attributes

  virtual_column :external_gateway_info, :type => :string # :hash
  virtual_column :distributed          , :type => :boolean
  virtual_column :routes               , :type => :string # :array
  virtual_column :propagating_vgws     , :type => :string # :array
  virtual_column :main_route_table     , :type => :boolean # :array
  virtual_column :high_availability    , :type => :boolean

  # Define all getters and setters for extra_attributes related virtual columns
  %i(external_gateway_info distributed routes propagating_vgws main_route_table high_availability).each do |action|
    define_method("#{action}=") do |value|
      extra_attributes_save(action, value)
    end

    define_method(action) do
      extra_attributes_load(action)
    end
  end

  virtual_total :total_vms, :vms

  def self.class_by_ems(ext_management_system)
    # TODO: use a factory on ExtManagementSystem side to return correct class for each provider
    ext_management_system && ext_management_system.class::NetworkRouter
  end

  def raw_sync_load_network_router
    raise NotImplementedError, _("raw_sync_load_balancer must be implemented in a subclass")
  end

  def sync_load_network_router_queue(userid)
    task_opts = {
      :action => "sync Load router for user #{userid}",
      :userid => userid
    }
    queue_opts = {
      :class_name  => self.class.name,
      :method_name => 'sync_load_network_router',
      :instance_id => id,
      :priority    => MiqQueue::HIGH_PRIORITY,
      :role        => 'ems_operations',
      :zone        => ext_management_system.my_zone,
      :args        => []
    }
    MiqTask.generic_action_with_callback(task_opts, queue_opts)
  end

  def sync_load_network_router
    raw_sync_load_network_router
  end

  private

  def extra_attributes_save(key, value)
    self.extra_attributes = {} if extra_attributes.blank?
    self.extra_attributes[key] = value
  end

  def extra_attributes_load(key)
    self.extra_attributes[key] unless extra_attributes.blank?
  end
end
