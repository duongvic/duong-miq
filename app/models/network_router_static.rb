class NetworkRouterStatic < ApplicationRecord
  include NewWithTypeStiMixin
  include SupportsFeatureMixin

  acts_as_miq_taggable
  belongs_to :ext_management_system, :foreign_key => :ems_id, :class_name => "ManageIQ::Providers::NetworkManager"
  # belongs_to :network_router
end
