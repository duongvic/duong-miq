class UserProfile < ApplicationRecord
  include RelationshipMixin
  acts_as_miq_taggable
  include OwnershipMixin

  belongs_to :user, :foreign_key => :evm_owner_id

  validates :ref_email, :format => {:with => MoreCoreExtensions::StringFormats::RE_EMAIL,
                                :allow_nil => true, :message => "must be a valid email address"}
end
