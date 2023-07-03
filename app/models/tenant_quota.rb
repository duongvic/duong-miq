class TenantQuota < ApplicationRecord
  belongs_to :tenant

  QUOTA_BASE = {
    :cpu_allocated       => {
      :unit          => :fixnum,
      :format        => :general_number_precision_0,
      :text_modifier => "Count".freeze
    },
    :mem_allocated       => {
      :unit          => :bytes,
      :format        => :gigabytes_human,
      :text_modifier => "GB".freeze
    },
    :storage_allocated   => {
      :unit          => :bytes,
      :format        => :gigabytes_human,
      :text_modifier => "GB".freeze
    },
    :vms_allocated       => {
      :unit          => :fixnum,
      :format        => :general_number_precision_0,
      :text_modifier => "Count".freeze
    },
    :templates_allocated => {
      :unit          => :fixnum,
      :format        => :general_number_precision_0,
      :text_modifier => "Count".freeze
    },
    :networks_allocated => {
      :unit          => :fixnum,
      :format        => :general_number_precision_0,
      :text_modifier => "Count".freeze
    },
    :ip_allocated => {
      :unit           => :fixnum,
      :format         => :general_number_precision_0,
      :text_modifier  => "Count".freeze
    },
    :subnets_allocated => {
      :unit          => :fixnum,
      :format        => :general_number_precision_0,
      :text_modifier => "Count".freeze
    },
    :load_balancers_allocated => {
      :unit          => :fixnum,
      :format        => :general_number_precision_0,
      :text_modifier => "Count".freeze
    },
    :security_groups_allocated => {
      :unit          => :fixnum,
      :format        => :general_number_precision_0,
      :text_modifier => "Count".freeze
    },
    :firewall_rules_allocated => {
      :unit          => :fixnum,
      :format        => :general_number_precision_0,
      :text_modifier => "Count".freeze
    },
    :network_routers_allocated => {
      :unit          => :fixnum,
      :format        => :general_number_precision_0,
      :text_modifier => "Count".freeze
    },
    :backups_allocated => {
      :unit          => :bytes,
      :format        => :gigabytes_human,
      :text_modifier => "GB".freeze
    },
    :snapshots_allocated => {
      :unit          => :bytes,
      :format        => :gigabytes_human,
      :text_modifier => "GB".freeze
    },
    :keypairs_allocated => {
      :unit          => :fixnum,
      :format        => :general_number_precision_0,
      :text_modifier => "Count".freeze
    }
  }

  DEFAULT_TEXT_FOR_ZERO_VALUES = {
    :available => "N/A".freeze
  }

  DEFAULT_TEXT_FOR_NULL_VALUES = {
    :total     => "N/A".freeze,
    :available => "N/A".freeze
  }

  NAMES = QUOTA_BASE.keys.map(&:to_s)

  validates :name,
            :inclusion               => {:in => NAMES},
            :uniqueness_when_changed => {:scope => :tenant_id, :message => "should be unique per tenant"}
  validates :unit, :value, :presence => true
  validates :value, :numericality => {:greater_than_or_equal_to => 0}
  validates :warn_value, :numericality => {:greater_than => 0}, :if => -> { warn_value.present? }

  validate :check_for_over_allocation

  scope :cpu_allocated,             -> { where(:name => :cpu_allocated) }
  scope :mem_allocated,             -> { where(:name => :mem_allocated) }
  scope :storage_allocated,         -> { where(:name => :storage_allocated) }
  scope :vms_allocated,             -> { where(:name => :vms_allocated) }
  scope :templates_allocated,       -> { where(:name => :templates_allocated) }
  scope :networks_allocated,        -> { where(:name => :networks_allocated) }
  scope :ip_allocated,              -> { where(:name => :ip_allocated)}
  scope :subnets_allocated,         -> { where(:name => :subnets_allocated) }
  scope :load_balancers_allocated,  -> { where(:name => :load_balancers_allocated) }
  scope :security_groups_allocated, -> { where(:name => :security_groups_allocated) }
  scope :firewall_rules_allocated,  -> { where(:name => :firewall_rules_allocated) }
  scope :network_routers_allocated, -> { where(:name => :network_routers_allocated) }
  scope :backups_allocated,         -> { where(:name => :backups_allocated) }
  scope :snapshots_allocated,       -> { where(:name => :snapshots_allocated) }
  scope :keypairs_allocated,        -> { where(:name => :keypairs_allocated) }

  virtual_column :name, :type => :string
  virtual_column :total, :type => :integer
  virtual_column :used, :type => :float
  virtual_column :allocated, :type => :float
  virtual_column :available, :type => :float
  virtual_column :description, :type => :string

  alias_attribute :total, :value

  before_validation(:on => :create) do
    self.unit = default_unit unless unit.present?
  end

  def description
    TenantQuota.tenant_quota_description(name.to_sym)
  end

  def self.format_quota_value(field, field_value, tenant_quota_name)
    if %w[tenant_quotas.name tenant_quotas.description].include?(field)
      TenantQuota.tenant_quota_description(tenant_quota_name.to_sym)
    else
      row = QUOTA_BASE[tenant_quota_name.to_sym]
      OpsHelper::TextualSummary.convert_to_format(row[:format], row[:text_modifier], field_value)
    end
  end

  def self.can_format_field?(field, tenant_quota_name)
    table_field, = field.split(".")
    to_s.tableize == table_field ? NAMES.include?(tenant_quota_name) : false
  end

  def self.default_text_for_zero(metric)
    DEFAULT_TEXT_FOR_ZERO_VALUES[metric]
  end

  def self.default_text_for_null(metric)
    DEFAULT_TEXT_FOR_NULL_VALUES[metric]
  end

  def self.quota_definitions
    @quota_definitions ||= QUOTA_BASE.each_with_object({}) do |(name, value), h|
      h[name] = value.merge(:description => tenant_quota_description(name), :value => nil, :warn_value => nil)
    end
  end

  def self.tenant_quota_description(name)
    case name
    when :cpu_allocated
      _("Allocated Virtual CPUs")
    when :mem_allocated
      _("Allocated Memory in GB")
    when :storage_allocated
      _("Allocated Storage in GB")
    when :vms_allocated
      _("Allocated Number of Virtual Machines")
    when :templates_allocated
      _("Allocated Number of Templates")
    when :networks_allocated
      _("Allocated Number of Networks")
    when :ip_allocated
      _("Allocated Number of IP Addresses")
    when :subnets_allocated
      _("Allocated Number of Subnets")
    when :load_balancers_allocated
      _("Allocated Number of Load Balancers")
    when :security_groups_allocated
      _("Allocated Number of Security Groups")
    when :firewall_rules_allocated
      _("Allocated Number of Firewall Rules")
    when :network_routers_allocated
      _("Allocated Number of Network Routers")
    when :backups_allocated
      _("Allocated Backups in GB")
    when :snapshots_allocated
      _("Allocated Snapshots in GB")
    when :keypairs_allocated
      _("Allocated Number of Keypairs")
    end
  end

  def self.create_default_quotas(tenant)
    QUOTA_BASE.each do |quota_key, quota_attr|
      new_quota = TenantQuota.new(:tenant => tenant, :name => quota_key.to_s, :unit => quota_attr[:unit].to_s)
      new_quota.value = case quota_key
                        when :cpu_allocated
                          0
                        when :mem_allocated
                          0.gigabytes
                        when :storage_allocated
                          0.gigabytes
                        when :ips_allocated, :security_groups_allocated
                          0
                        else
                          0
                        end
      new_quota.save!
    rescue
      raise 'Cannot allocate quotas for this tenant'
    end
  end

  def allocated
    tenant.children.includes(:tenant_quotas).map do |c|
      cq = c.tenant_quotas.send(name).take
      cq.value if cq
    end.compact.sum
  end

  def available
    value - tenant.children.includes(:tenant_quotas).map do |c|
      cq = c.tenant_quotas.send(name).take
      cq.value if cq
    end.compact.sum - used
  end

  def used
    method = "#{name.delete_suffix('_allocated')}_used"
    @used ||= send(method)
  end

  def cpu_used
    tenant.allocated_vcpu
  end

  def mem_used
    tenant.allocated_memory
  end

  def ip_used
    tenant.allocated_ip_addresses
  end

  def storage_used
    tenant.cloud_volumes.sum(:size)
  end

  def vms_used
    tenant.active_vms.count
  end

  def templates_used
    tenant.miq_templates.count
  end

  def networks_used
    tenant.cloud_networks.count
  end

  def subnets_used
    tenant.cloud_subnets.count
  end

  def load_balancers_used
    tenant.load_balancers.count
  end

  def security_groups_used
    tenant.security_groups.count
  end

  def firewall_rules_used
    tenant.firewall_rules.count
  end

  def network_routers_used
    tenant.network_routers.count
  end

  def backups_used
    ManageIQ::Providers::Openstack::CloudManager::CloudVolumeBackup.get_storage_usage(tenant.name)
  rescue => err
    0
  end

  def snapshots_used
    tenant.cloud_volume_snapshots.sum(:size)
  end

  def keypairs_used
    tenant.authentications.where(:type => 'ManageIQ::Providers::Openstack::CloudManager::AuthKeyPair').count
  end

  # remove all quotas that are not listed in the keys to keep
  # e.g.: tenant.tenant_quotas.destroy_missing_quotas(include_keys)
  # NOTE: these are already local, no need to hit db to find them
  def self.destroy_missing(keep)
    keep = keep.map(&:to_s)
    deletes = all.select { |tq| !keep.include?(tq.name) }
    delete(deletes)
  end

  def quota_hash
    self.class.quota_definitions[name.to_sym].merge(:unit => unit, :value => value, :warn_value => warn_value, :format => format) # attributes
  end

  def format
    self.class.quota_definitions.fetch_path(name.to_sym, :format).to_s
  end

  def default_unit
    self.class.quota_definitions.fetch_path(name.to_sym, :unit).to_s
  end

  def check_for_over_allocation
    return unless value_changed?

    # Root tenant has no (unlimited) quota
    return if tenant.root?

    oval, nval = changes["value"]

    # Check that the new value is >= the amount that was already allocated to child tenants
    if nval < allocated
      errors.add(name, "quota is over allocated, #{nval} was requested but only #{nval - allocated} is available")
      return
    end

    # Check that new quota is a least as much as was already used
    if nval < used
      errors.add(name, "quota is under allocated, #{nval} was requested but #{used} has already been used")
      return
    end

    diff = (nval || 0) - (oval || 0)

    # Check if the parent has enough quota available to give to the child
    parent_quota = tenant.parent.tenant_quotas.send(name).take
    unless parent_quota.nil?
      if parent_quota.available < diff
        errors.add(name, "quota is over allocated, parent tenant does not have enough quota")
      end
    end
  end
end
