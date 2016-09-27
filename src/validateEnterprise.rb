class ValidateEnterprise

  def validate_ent(ent_list)
    puts "#{__method__}: Get info to determine if enterprise is active or not"

    status_hash = Hash.new(Hash.new)
    ent_list.each do |ent|
      ent_status = get_ent_status(ent)
      puts "#{ent}: #{ent_status}"
      status_hash[:ent] = ent_status
    end
    return status_hash
  end

  def get_ent_status(ent)
    groups,group_count = get_group_count(ent)
    active_tn_count = 0
    phy_device_count = 0
    if group_count > 0
      active_tn_count = get_active_tns(ent)
      phy_device_count = get_device_list(ent,groups)
      reg_user_count = get_reg_users(ent)
    end

    # Store results in Hash
    status = {
        groups: group_count,
        active_tns: active_tn_count,
        phy_devices: phy_device_count,
        reg_users: reg_user_count
    }
    # Print output
    # puts "#{ent},group_count=#{group_count},active_tn_count=#{tn_count},phy_device_count=#{phy_device_count},reg_user_count=#{reg_device_count}"

    return status
  end

  def get_group_count(ent)
    # Get Total Groups Configured
    group_count = 0
    cmd_ok,groups = $bw.get_groups(ent)

    return groups,groups.length
  end

  def get_active_tns(ent)
    # Get total TNs assigned to Groups
    cmd_ok,ent_dns = $bw.get_ent_dn_info(ent)

    tn_count = 0
    ent_dns.each do |dn_hash|
      tn_count += 1 if dn_hash[:Can_Delete] == "false"
    end
    return tn_count
  end

  def get_device_list(ent,groups)
    # Get Total Device Count
    phy_device_count = 0
    groups.each do |group|
      # devices_list = Array.new
      devices_list = $bw.get_group_device_list(ent,group)
      phy_device_count += devices_list.length
    end
  return phy_device_count
  end

  def get_reg_users(ent)
    # Get Total Registered Line-Ports
    user_tracker = Hash.new(0)
    cmd_ok,ep_list = $bw.get_ent_endpoint_info(ent)
    ep_list.each do |ep_config|
      cmd_ok,reg_status = $bw.get_user_register_status(ep_config[:User_Id]) unless user_tracker.has_key?(ep_config[:User_Id])
      user_tracker[ep_config[:User_Id]] = reg_status.length unless reg_status == nil
    end

    reg_device_count = 0
    user_tracker.each { |user,count| reg_device_count += count }

    return reg_device_count
  end

end
