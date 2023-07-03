class FloatingIp < ApplicationRecord
  include NewWithTypeStiMixin
  include SupportsFeatureMixin
  include CloudTenancyMixin

  acts_as_miq_taggable
  default_value_for :status, "reserved"


  belongs_to :ext_management_system, :foreign_key => :ems_id, :class_name => "ManageIQ::Providers::NetworkManager"

  belongs_to :user, :foreign_key => :evm_owner_id
  belongs_to :vm
  belongs_to :cloud_tenant
  belongs_to :cloud_network
  alias_attribute :name, :address

  def self.available
    self.status != "active"
  end

  def self.class_by_ems(ext_management_system)
    ext_management_system
  end

  def self.display_name(number = 1)
    n_('Public IP', 'Public IPs', number)
  end
end
