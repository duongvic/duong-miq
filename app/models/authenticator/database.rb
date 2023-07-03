module Authenticator
  class Database < Base
    def self.proper_name
      'VDS'
    end

    def uses_stored_password?
      true
    end

    private

    def _authenticate(username, password, _request, otp)
      user = case_insensitive_find_by_userid(username)

      return [false, _('Your account has been locked due to too many failed login attempts. Please contact the administrator.')] if user&.locked?

      return [false, _('Your account is either locked or not activated. Please activate your account or contact the administrator.')] unless user&.status

      # CAS(lamps) Refactored from last_password_change
      if user.password_expiration <= Time.now.utc
        return [false, _('Your password has expired. Please reset your password to access the dashboard.')]
      end

      if user.enable_two_factors && !otp.nil?
        two_factors = TwoFactors.lookup_by_userid(user.id)
        return [false, _('Invalid OTP')] unless two_factors.verify_otp_token(otp.to_s)
      end

      if user&.authenticate_bcrypt(password) # Authenticate if the username matches
        user.unlock! # Reset the number of failed logins
        return true
      end

      user&.fail_login! # Increase the number of failed login attempts
      [false, _("Username or Password incorrect.")]
    end

    def authorize?
      false
    end
  end
end
