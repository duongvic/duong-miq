require 'rotp'
class TwoFactors < ApplicationRecord
  include RelationshipMixin
  acts_as_miq_taggable

  before_create :create_tfa_token
  default_value_for :status, "pending"

  belongs_to :user

  def self.regenerate_otp_token
    ROTP::Base32.random_base32
  end

  def self.lookup_by_userid(userid)
    in_my_region.find_by(:user_id => userid)
  end

  def format_otp_token
    otp_format = "otpauth://totp/GOOGLE:%s?secret=%s&digits=6&issuer=GOOGLE" % [user.email, otp_token]
    otp_format
  end

  def verify_otp_token(otp_token)
    hotp = ROTP::TOTP.new(self.otp_token)
    hotp.verify(otp_token)
  end

  private

  def create_tfa_token
    self.otp_token = TwoFactors.regenerate_otp_token
  end
end
