require 'grpc'
require 'order_services_pb'

class OrderService < Order::OrderService::Service
  include Vmdb::Logging

  # Map Common Names to MIQ Quotas for proper allocation
  CN_TO_QUOTA = { "vcpu"      => "cpu_allocated",
                  "ram"       => "mem_allocated",
                  "disk"      => "storage_allocated",
                  "ip"        => "ip_allocated",
                  "backup"    => "backups_allocated",
                  "snapshot"  => "snapshots_allocated",
                  "lb"        => "load_balancers_allocated" }.freeze

  def approve_order(approve_req, _unused_call)
    # Get User from CustomerID
    access_user = User.find_by(:id => approve_req.user_id)
    if access_user.nil?
      msg = 'User not found'
      raise GRPC::BadStatus.new(GRPC::Core::StatusCodes::NOT_FOUND, msg)
    else
      user_profile = UserProfile.find_by(:evm_owner_id => access_user.id)
      unless user_profile.contract_codes.include?(approve_req.contract_code)
        user_profile.contract_codes << approve_req.contract_code
        user_profile.save
      end
      # Find Tenant by Userid
      tenant = Tenant.find_by(:name => access_user.userid)
      if tenant.nil?
        msg = 'Tenant not found'
        raise GRPC::BadStatus.new(GRPC::Core::StatusCodes::NOT_FOUND, msg)
      else
        quota_list = []
        approve_req.computes.each do |item|
          item.products.each do |product|
            quota_name = CN_TO_QUOTA[product.cn]
            next product if quota_name.nil?
            tenant_quota = TenantQuota.find_by(:tenant_id => tenant.id, :name => quota_name)
            if tenant_quota.nil?
              tenant_quota = TenantQuota.new
              tenant_quota.tenant_id = tenant.id
              tenant_quota.name = quota_name
            end
            case product.cn
            when "ram", "disk", "backup", "snapshot" # Memory and Storage in GB
              if tenant_quota.unit.nil?
                # TenantQuota.create(:tenant_id => tenant.id, :name => quota_name, :unit => "bytes", :value => product.quantity.gigabytes)
                tenant_quota.unit = "bytes"
                tenant_quota.value = product.quantity.gigabytes
              else
                tenant_quota.value += product.quantity.gigabytes
              end
            else # Everything else by count
              if tenant_quota.unit.nil?
                tenant_quota.unit = "fixnum"
                tenant_quota.value = product.quantity
              else
                tenant_quota.value += product.quantity
              end
            end
            quota_list << tenant_quota # Save new quotas
          end
        end
        TenantQuota.transaction do
          begin
            quota_list.each do |quota|
              quota.save
              _log.info("Updating Quota #{quota.name} value to: #{quota.value} for Contract #{approve_req.contract_code}")
            end
          rescue ActiveRecord::StatementInvalid => e
            _log.error "GRPC Error: #{e.backtrace}"
            raise ActiveRecord::Rollback
          end
        end
        # Create Approval message
        approval_resp = Order::Approval.new(
          approved: true
        )
        # Create new netbox tenant if doesn't exist
        create_netbox_tenant(access_user.userid)

        # Return Approval message
        return approval_resp
      end
    end
  rescue => e
    _log.error "GRPC Error: #{e.backtrace}"
    msg = 'Something went wrong!'
    raise GRPC::BadStatus.new(GRPC::Core::StatusCodes::INTERNAL, msg)
  end

  def create_netbox_tenant(tenant_name)
    tenant = NetboxClientRuby.tenancy.tenants.find_by(name: tenant_name)
    if tenant.nil?
      NetboxClientRuby::Tenancy::Tenant.new(name: tenant_name, slug: tenant_name).save
    end
  end
end
