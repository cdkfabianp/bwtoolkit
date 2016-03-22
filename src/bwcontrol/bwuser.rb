require_relative 'bwcontrol'

class BWUser < BWControl

	def get_user_announcement_list(user=nil)
		oci_cmd = :UserAnnouncementFileGetListRequest
		config_hash = send(oci_cmd)
		config_hash[:userId] = user
		abort "#{__method__} for #{oci_cmd} Default Options: #{config_hash}" if user == nil

		response_hash, cmd_ok = get_rows_response(oci_cmd,config_hash)
		return cmd_ok,response_hash
	end

    def get_users_assigned_to_device(ent,group,dev_name)
        cmd_ok = false
        user_ids = Array.new
        cmd_ok,user_config = get_group_device_users(ent,group,dev_name)

        user_config.each { |usr_info| user_ids << usr_info[:User_Id] }
        return cmd_ok, user_ids
    end

    def get_user_filtered_info(user,filter=nil)
    	oci_call=:UserGetRequest20
        response_hash,cmd_ok = get_nested_rows_response(oci_call,{userId: user})

        user_filtered_info = "NONE"
        if filter == nil
        	user_filtered_info = response_hash
        else
            user_filtered_info = response_hash[filter] if response_hash.has_key?(filter)
        end

        return cmd_ok,user_filtered_info
    end

    def get_users_in_group(ent=nil,group=nil)
    	oci_cmd = :UserGetListInGroupRequest
    	config_hash = send(oci_cmd)
    	config_hash[:serviceProviderId] = ent
    	config_hash[:GroupId] = group
    	abort "#{__method__} for #{oci_cmd} Default Options: #{config_hash}" if ent == nil

        users = Array.new
        table_header = "userTable"

        table_of_users,cmd_ok = get_table_response(oci_cmd,table_header,config_hash)
        table_of_users.each { |user_hash| users << user_hash[:User_Id] }

        return cmd_ok,users
    end    

    def get_service_users_in_group(ent,group)
        cmd_ok,response_hash = get_ent_service_list(ent)

        users = Array.new
        response_hash.each { |user_info| users.push(user_info[:User_ID]) if user_info[:Group_ID] == group}

        return cmd_ok,users

    end
        

    def get_user_svc_list(user=nil)
    	oci_cmd = :UserServiceGetAssignmentListRequest
    	config_hash = send(oci_cmd,user)
    	abort "#{__method__} for #{oci_cmd} Default Options: #{config_hash}" if user == nil

        table_header = 'userServicesAssignmentTable'
        response_hash,cmd_ok = get_table_response(oci_cmd,table_header,config_hash)

        return cmd_ok,response_hash

    end

    def mod_user_announcement_file(user=nil,file=nil,new_file=nil,type=nil)
        oci_cmd = :UserAnnouncementFileModifyRequest
        config_hash = send(oci_cmd)
        config_hash[:userId] = user
        config_hash[:announcementFileKey][:name] = file
        config_hash[:mediaFileType] = type unless type == nil
        config_hash[:newAnnouncementFileName] = new_file

        abort "#{__method__} for #{oci_cmd} Default Options: #{config_hash}" if user == nil

        response,cmd_ok = send_request(oci_cmd,config_hash)

        return cmd_ok,response
    end

    def mod_user_assign_serivce(user=nil,service_list=nil)
    	oci_cmd = :UserServiceAssignListRequest
    	config_hash = send(oci_cmd)
    	abort "#{oci_cmd} Config Options: #{config_hash}" if user == nil

    	svc_list = Array.new
    	if service_list.is_a?(String)
    		svc_list.push(service_list)
    	else
    		svc_list = service_list
    	end

    	config_hash[:userId] = user
    	config_hash[:serviceName] = svc_list
    	response,cmd_ok = send_request(oci_cmd,config_hash)

    	return cmd_ok,response
    	# return final_cmd_ok,final_response
    end

    def mod_user_cpp(user_mod_hash=nil)
    	oci_cmd = :UserCallProcessingModifyPolicyRequest14sp7
    	config_hash = send(oci_cmd)
    	abort "UserCallProcessingModifyPolicyRequest14sp7 Config Options: #{config_hash}" if user_mod_hash == nil

		config_hash.keep_if do |k|
			is_true = false
			if user_mod_hash.has_key?(k)
				config_hash[k] = user_mod_hash[k]
				is_true = true
			end
			is_true
		end
	 	response,cmd_ok = send_request(oci_cmd,config_hash)

	 	return cmd_ok,response
    end

    def mod_user_enable_xmpp(user=nil,is_active=nil)
    	oci_cmd = :UserIntegratedIMPModifyRequest
    	config_hash = send(oci_cmd)
    	abort "#{__method__} for #{oci_cmd} Default Options: #{config_hash}" if user == nil

    	config_hash[:userId] = user
    	config_hash[:isActive] = is_active
    	response,cmd_ok = send_request(oci_cmd,config_hash)

    	return cmd_ok,response
    end


	def mod_user_profile(user_mod_hash=nil)
		oci_cmd = :UserModifyRequest17sp4
		config_hash = send(oci_cmd)
		abort "#{__method__} for #{oci_cmd} Default Options: #{config_hash}" if user_mod_hash[:userId] == nil
		
		config_hash.keep_if do |k|
			is_true = false
			if user_mod_hash.has_key?(k)
				config_hash[k] = user_mod_hash[k]
				is_true = true
			end
			is_true
		end
	 	response,cmd_ok = send_request(oci_cmd,config_hash)

	 	return cmd_ok,response
	end

    def get_user_register_status(user=nil)
        oci_cmd = :UserGetRegistrationListRequest
        config_hash = send(oci_cmd,user)
        abort "#{__method__} for #{oci_cmd} Default Options: #{config_hash}" if user == nil

        table_header = 'registrationTable'
        response_hash,cmd_ok = get_table_response(oci_cmd,table_header,config_hash)

        return cmd_ok,response_hash
    end

	def mod_user_sca_ep(user=nil,device=nil,lineport=nil)
		oci_cmd = :UserSharedCallAppearanceAddEndpointRequest14sp2
		config_hash = send(oci_cmd)
		abort "#{__method__} for #{oci_cmd} Default Options: #{config_hash}" if user == nil

		config_hash[:userId] = user
        config_hash[:accessDeviceEndpoint][:accessDevice][:deviceName] = device
        config_hash[:accessDeviceEndpoint][:linePort] = lineport

        response,cmd_ok = send_request(oci_cmd,config_hash)

		return cmd_ok,response
	end

	def mod_user_sca_settings(use_defaults,user=nil,user_mod_hash=nil)
		oci_cmd = :UserSharedCallAppearanceModifyRequest
		config_hash = send(oci_cmd)
		abort "#{__method__} for #{oci_cmd} Default Options #{config_hash}" if user == nil

		config_hash[:userId] = user
		if use_defaults == false
			config_hash.keep_if do |k|
				is_true = false
				if user_mod_hash.has_key?(k)
					config_hash[k] = user_mod_hash[k]
					is_true = true
				end
				is_true
			end
		end
	 	response,cmd_ok = send_request(oci_cmd,config_hash)

	 	return cmd_ok,response		
 	end

end
