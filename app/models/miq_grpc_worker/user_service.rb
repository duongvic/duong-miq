require 'grpc'
require 'user_services_pb'

class UserService < GrpcUser::UserService::Service
  include Vmdb::Logging

  def verify_token(token_info, _unused_call)
    # Verify API Auth token and extract userid
    auth_token = token_info.token
    tm = TokenManager.new("api")
    userid = tm.token_get_info(auth_token, :userid)
    if userid.empty?
      msg = 'Token Unauthenticated'
      _log.error "GRPC Error: #{GRPC::Core::StatusCodes::UNAUTHENTICATED} - #{msg}"
      raise GRPC::BadStatus.new(GRPC::Core::StatusCodes::UNAUTHENTICATED, msg)
    else
      # Get user info from extracted userid
      access_user = User.find_by(:userid => userid)
      if access_user.nil?
        msg = 'User not found'
        _log.error "GRPC Error: #{GRPC::Core::StatusCodes::NOT_FOUND} - #{msg}"
        raise GRPC::BadStatus.new(GRPC::Core::StatusCodes::NOT_FOUND, msg)
      else
        response = GrpcUser::User.new(
          id: access_user.id,
          userid: access_user.userid,
          name: access_user.name,
          email: access_user.email,
          phone_number: access_user.phone_number,
          role: access_user.miq_user_role.name,
          status: access_user.status,
          password_digest: "",
          enable_two_factors: access_user.enable_two_factors
        )
        return response
      end
    end
  rescue => e
    _log.error "GRPC Error: #{e.backtrace}"
    msg = 'Something went wrong!'
    raise GRPC::BadStatus.new(GRPC::Core::StatusCodes::INTERNAL, msg)
  end

  def get_user(user_id, _unused_call)
    # Get user by CustomerID message
    access_user = User.find_by(:id => user_id)
    if access_user.nil?
      msg = 'User not found'
      _log.error "GRPC Error: #{GRPC::Core::StatusCodes::NOT_FOUND} - #{msg}"
      raise GRPC::BadStatus.new(GRPC::Core::StatusCodes::NOT_FOUND, msg)
    else
      user = GrpcUser::User.new(
        id: access_user.id,
        userid: access_user.userid,
        name: access_user.name,
        email: access_user.email,
        phone_number: access_user.phone_number,
        role: access_user.miq_user_role.name,
        status: access_user.status,
        password_digest: "",
        enable_two_factors: access_user.enable_two_factors
      )

      # Get user's profile
      access_user_profile = UserProfile.find_by(:evm_owner_id => user_id)
      if access_user_profile.nil?
        msg = 'User not found'
        _log.error "GRPC Error: #{GRPC::Core::StatusCodes::NOT_FOUND} - #{msg}"
        raise GRPC::BadStatus.new(GRPC::Core::StatusCodes::NOT_FOUND, msg)
      else
        GrpcUser::UserProfile.new(
          user: user,
          user_type: access_user_profile.user_type,
          account_type: access_user_profile.account_type,
          id_number: access_user_profile.id_number,
          id_issue_date: access_user_profile.id_issue_date.to_s,
          id_issue_location: access_user_profile.id_issue_location,
          tax_number: access_user_profile.tax_number,
          address: access_user_profile.address,
          date_of_birth: access_user_profile.date_of_birth.to_s,
          company: access_user_profile.company,
          rep_name: access_user_profile.rep_name,
          rep_phone: access_user_profile.rep_phone,
          rep_email: access_user_profile.rep_email,
          ref_name: access_user_profile.ref_name,
          ref_email: access_user_profile.ref_phone,
          ref_phone: access_user_profile.ref_email,
        )
      end
    end
  rescue => e
    _log.error "GRPC Error: #{e.backtrace}"
    msg = 'Something went wrong!'
    raise GRPC::BadStatus.new(GRPC::Core::StatusCodes::INTERNAL, msg)
  end

  def get_all_users(token_info, _unused_call)
    auth_token = token_info.token
    tm = TokenManager.new("api")
    userid = tm.token_get_info(auth_token, :userid)
    if userid.empty?
      msg = 'Token Unauthenticated'
      _log.error "GRPC Error: #{GRPC::Core::StatusCodes::UNAUTHENTICATED} - #{msg}"
      raise GRPC::BadStatus.new(GRPC::Core::StatusCodes::UNAUTHENTICATED, msg)
    else
      all_profiles = []
      User.all.each do |u|
        all_profiles << get_user(u.id, nil)
      end
      GrpcUser::UserProfiles.new(user_profiles: all_profiles)
    end
  rescue => e
    _log.error "GRPC Error: #{e.backtrace}"
    msg = 'Something went wrong!'
    raise GRPC::BadStatus.new(GRPC::Core::StatusCodes::INTERNAL, msg)
  end
end
