#!/usr/bin/env ruby
#
STDOUT.sync = true

class ConfigUCOne
    def initialize(ent,group,file,voip_domain)
        @ent = ent
        @group = group
        @ucone_user_list = get_users_from_file(file)
        @voip_domain = voip_domain
        @ucone_service_list = ["Client License 18",
                       "Client License 17", 
                       "BroadTouch Business Communicator Tablet - Video",
                       "Shared Call Appearance",
                       "Shared Call Appearance 5",
                       "Integrated IMP",
                       "BroadWorks Anywhere",
                       "In-Call Service Activation",
                    ]
        @media_policy_selection = {mediaPolicySelection: "No Restrictions"}
    end

    def config_ucone_users
        # Add devices for each UCOne User
        devs_users_hash = add_devices_for_ucone(@ucone_user_list)
        
        #Configure Users
        @ucone_user_list.each do |user|
            #Get user email and add .com to the end if needed
            cmd_ok,user_email = $bw.get_user_filtered_info(user,:emailAddress)
            update_email_ok = add_domain_suffix_to_email(user,user_email) unless user_email =~ /\.com$/ || user_email == "NONE"

            #Update Media Policy Selection for User to NONE to enable p2p video
            set_media_policy_ok = set_media_policy_for_video(user)

            #Assign necessary services
            added_svc_ok = add_ucone_services(user)

            #Enable IM&P
            enabled_xmpp_ok = enable_xmpp(user)

            #Configure Shared Line Devices (mobile,tablet,desktop)
            configed_sca_params_ok = config_sca_params(user)

            #Provision SCA Appearances
            configed_sca_dev = prov_sca_dev(user)
        end
    end

    def get_users_from_file(file)
        user_list = Array.new
        f = File.new(file)
        f.readlines.each {|line| user_list.push(line.chomp!)}

        return user_list
    end

    def add_devices_for_ucone(ucone_user_list)
        devs_configured = $helper.make_hoh

        # Find highest number device from all devices in group that start with <groupId>-dev[ice]XXX
        cmd_ok,response_hash = $bw.get_group_device_list(@ent,@group)
        if response_hash.length == 0
            device_high_num = 0
        else
            device_high_num = get_max_device_num(response_hash)
        end
        puts "ADD_DEVICES: Highest device number: #{device_high_num}"

        # Start creating all required devices starting at device number device_high_num + 1
        ucone_dev_types = $bw.get_sys_ucone_device_types
        counter = 1
        puts "ADD_DEVICES: Expecting to build #{ucone_user_list.length * ucone_dev_types.length} total devices"
        ucone_user_list.each do |user|
            ucone_dev_types.each do |dev_type|
                config_hash,dev_creds = create_dev_config(dev_type,device_high_num += counter)
                config_hash[:serviceProviderId] = @ent
                config_hash[:groupId] = @group
                cmd_ok,response = $bw.mod_add_group_device(config_hash,dev_creds) if $ok_to_mod == true
                devs_configured[user][dev_type] = config_hash[:deviceName]
                puts "ADD_DEVICES: #{config_hash[:deviceName]} for TYPE: #{dev_type} for USER: #{user} with useriD: #{dev_creds[:userName]} AND password: #{dev_creds[:password]}"
            end
        end
        @devs_configured = devs_configured
        return devs_configured
    end

    def create_dev_config(dev_type,dev_counter)
        require 'securerandom'
        if dev_counter < 10
            dev_name = "#{@group}-dev00#{dev_counter}"
        elsif dev_counter < 100
            dev_name = "#{@group}-dev0#{dev_counter}"
        else
            dev_name = "#{@group}-dev#{dev_counter}"
        end

        config_hash = {
            deviceName: dev_name,
            deviceType: dev_type,
            useCustomUserNamePassword: "true"
        }
        dev_creds = {
            userName: dev_name,
            password: "#{SecureRandom.base64(10)}"
        }
        return config_hash,dev_creds
    end

    def get_max_device_num(device_list)
        clean_dev_hash = Hash.new
        device_list.each do |device|
            device_num = nil
            if device[:Device_Name] =~ /^#{@group}-dev(\d\d\d)$/
                device_num = $1.to_i
            elsif device[:Device_Name] =~ /^#{@group}-device(\d\d\d)$/
                device_num =$1.to_i
            end
            clean_dev_hash[device[:Device_Name]] = device_num unless device_num == nil
        end

        return clean_dev_hash.values.max_by {|v| v}
    end


    def add_domain_suffix_to_email(user,user_email)
        cmd_ok = false
        new_suffix = ".com"
        new_user_email = "#{user_email}#{new_suffix}"

        if $ok_to_mod == true
            config_hash = {userId: user, emailAddress: new_user_email}
            cmd_ok,result = $bw.mod_user_profile(config_hash)
            puts "FIX_USER_EMAIL: #{user}: EMAIL: #{user_email}, NEW: #{new_user_email}, RESULT: #{cmd_ok}"
        end

        return cmd_ok
    end

    def set_media_policy_for_video(user)
        oci_cmd = :UserCallProcessingModifyPolicyRequest14sp7
        cmd_ok = false

        if $ok_to_mod == true
            cmd_ok,result = $bw.mod_user_cpp({userId: user, mediaPolicySelection: "No Restrictions"})
            puts "FIX_CPP: #{user}: Updated User Media Policy: #{cmd_ok}"

        end

        return cmd_ok

    end

    def add_ucone_services(user)
        cmd_ok = false
        if $ok_to_mod == true
            cmd_ok,result = $bw.mod_user_assign_serivce(user,@ucone_service_list)
            puts "ADD_SERVICES: #{user}: Added Services: #{cmd_ok}"
        end
    
        return cmd_ok
    end

    def enable_xmpp(user)
        cmd_ok = false
        cmd_ok,result = $bw.mod_user_enable_xmpp(user,true) if $ok_to_mod == true
        puts "ENABLE_XMPP: #{user} configured with for enabling XMPP: #{cmd_ok}"

        return cmd_ok
    end
    private :get_max_device_num, :create_dev_config, :get_max_device_num

    def config_sca_params(user)
        use_default_sca = true
        cmd_ok = false
        cmd_ok,result = $bw.mod_user_sca_settings(use_default_sca,user) if $ok_to_mod == true
        puts "CONFIG_SCA: #{user} configured with basic SCA Params with result: #{cmd_ok}"

        return cmd_ok
    end

    def prov_sca_dev(user)
        oci_cmd = :UserSharedCallAppearanceAddEndpointRequest14sp2
        cmd_ok = false

        @devs_configured[user].each do |dev_type,dev_name|
            lineport = nil
            user_uri = user
            user_uri = $1 if user =~ /(.+)@\w.*/

            if dev_type =~ /^Business\sCommunicator\s-\s(\w+)$/
                dev = $1.downcase!
                lineport = "#{user_uri}-#{dev}@#{@voip_domain}"
            end
            
            if $ok_to_mod == true
                cmd_ok,result = $bw.mod_user_sca_ep(user,dev_name,lineport)
                puts "CONFIG_SCA_DEVICE: #{user} configured with SCA Endpoint: #{dev_name} and lineport: #{lineport}: #{cmd_ok}"
            end
        end
    end


end

#Get List of Users to Configure for UCONE
def config_users_for_ucone(ent,group)
    #Initialize Class to Collect Users to Configure for UCOne
    ucone = GetUsersToConfigure.new(ent,group)

    user_filter_list = ['park','cfwd']
    case_insensitive = true
    master_user_list = ucone.get_available_users_by_userId_pattern(user_filter_list,case_insensitive)    
    puts master_user_list

    user_list = master_user_list
    user_confirm = nil
    final_user_list = ucone.filter_list_with_user_input(user_list,user_confirm)

    puts "Congrats you configured:\n#{final_user_list} "
end

