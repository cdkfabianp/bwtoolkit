#!/usr/bin/env ruby
#
STDOUT.sync = true
class BwDeviceAudit
    def initialize(ent,group)
        @ent = ent
        @group = group
    end

    def get_reg_info(config_hash)
        #Query devices in group
        cmd_ok,devices_list = $bw.get_group_device_list(@ent,@group)

        ua_device_list = $helper.make_hoh
        devices_list.each do |device_list|
            device_info = {   
                            dev_type: device_list[:Device_Type],
                            dev_mac: device_list[:MAC_Address],
                            dev_configed_users: 0,
                            dev_reg_users: 0,
                        }
            cmd_ok, user_ids = $bw.get_users_assigned_to_device(config_hash['serviceProviderId'],config_hash['groupId'],device_list[:Device_Name])
            device_info[:dev_configed_users] = user_ids.length

            user_ids.each do |user|
                cmd_ok,user_reg = $bw.get_user_register_status(user)
                user_reg.each do |line_reg|
                    next unless device_list[:Device_Name] == line_reg[:Device_Name]
                    device_info[:dev_reg_users] += 1
                end
            end
            ua_device_list[device_list[:Device_Name]] = device_info
        end

        return ua_device_list
    end

    def get_reg_info_by_group
        puts "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
        puts "INFO FOR #{@ent} > #{@group}"
        puts "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"

        #Print Table Headers
        puts "DeviceName,DeviceType,MAC,Num_Configured Users, Num_Registered Users"

        config_hash = {'serviceProviderId' => @ent, 'groupId' => @group}
        ua_device_list = get_reg_info(config_hash)
        ua_device_list.each do |dev_name,dev_info|
            status = "UNKNOWN"
            if dev_info[:dev_reg_users] > 0
                status = "ACTIVE"
            elsif dev_info[:dev_configed_users] > 0
                status = "CONFIGURED"
            elsif dev_info[:dev_configed_users] == 0
                status = "NOT_IN_USE"
            end
            puts "#{dev_name},#{dev_info.values.join(",")},#{status}"
        end
    end
end

