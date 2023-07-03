module ManageIQ::Providers::CloudManager::Provision::OptionsHelper
  AZ_WHITELIST = %w(HN-FORNIX-IHA-SCALEOUT).freeze
  def dest_availability_zone
    # @dest_availability_zone ||= AvailabilityZone.find_by(:id => get_option(:dest_availability_zone))
    # if @dest_availability_zone.kind_of?(ManageIQ::Providers::Openstack::CloudManager::AvailabilityZoneNull) or @dest_availability_zone.nil?
    #   @dest_availability_zone = AvailabilityZone.select{|zone| AZ_WHITELIST.include?(zone.name)}.min_by{|zone| zone.vms.count}
    # end
    @dest_availability_zone = AvailabilityZone.select{|zone| AZ_WHITELIST.include?(zone.name)}.min_by{|zone| zone.vms.count}
  end

  def guest_access_key_pair
    @guest_access_key_pair ||= ManageIQ::Providers::CloudManager::AuthKeyPair.find_by(:id => get_option(:guest_access_key_pair))
  end

  def security_groups
    @security_groups ||= SecurityGroup.where(:id => options[:security_groups])
  end

  def instance_type
    @instance_type ||= Flavor.find_by(:id => get_option(:instance_type))
  end

  def floating_ip
    @floating_ip ||= FloatingIp.find_by(:id => get_option(:floating_ip_address))
  end

  def cloud_network
    @cloud_network ||= CloudNetwork.find_by(:id => get_option(:cloud_network))
  end

  # Add for private net methods
  def private_cloud_network
    @private_cloud_network ||= CloudNetwork.where(:id => options[:private_cloud_network])
  end

  # Add this to make sure we can select public networks
  def public_cloud_network
    @public_cloud_network ||= CloudNetwork.find_by(:id => get_option(:public_cloud_network))
  end

  def cloud_subnet
    @cloud_subnet ||= CloudSubnet.find_by(:id => get_option(:cloud_subnet))
  end

  # Get volume selected from the list in the Volumes section
  def selected_volumes
    @selected_volumes ||= CloudVolume.where(:id => options[:select_volumes])
  end

end