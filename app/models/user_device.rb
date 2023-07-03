class UserDevice < ApplicationRecord
  include RelationshipMixin
  acts_as_miq_taggable

  default_value_for :authorized, false
  default_value_for :created_at, Time.now.utc

  belongs_to :user
end

