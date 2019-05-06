require_relative 'bwcontrol'

class BWUser < BWControl

    def get_user_addr_type(user)
        oci_cmd = :UserGetRequest20
        config_hash = send(oci_cmd,user)
        abort "#{__method__} for #{oci_cmd} Default Options: #{config_hash}" if user == nil

        response_hash,cmd_ok = get_nested_rows_response(oci_cmd,config_hash)
  
        user_addr_type = "None"
        user_addr_type = "Virtual_User" if response_hash.empty?
        user_addr_type = "Trunk_User" if response_hash.has_key?(:trunkAddressing)
        user_addr_type = "Hosted_User" if response_hash.has_key?(:accessDeviceEndpoint)

        #Command Errors out if querying AA/HG/CC Virtual User
        cmd_ok = true if user_addr_type == "Virtual_User"

        return cmd_ok,user_addr_type
    end

    def get_user_alternate_numbers(user=nil)
        oci_cmd = :UserAlternateNumbersGetRequest17
        config_hash = send(oci_cmd,user)
        abort "#{__method__} for #{oci_cmd} Default Options: #{config_hash}" if user == nil

        table_header = 'userServicesAssignmentTable'
        response_hash,cmd_ok = get_nested_rows_response(oci_cmd,config_hash)

        return cmd_ok,response_hash        
    end

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

    def get_user_call_proc_settings(user=nil)
        oci_cmd = :UserCallProcessingGetPolicyRequest19sp1
        config_hash = send(oci_cmd)
        config_hash[:userId] = user
        abort "#{__method__} for #{oci_cmd} Default Options: #{config_hash}" if user == nil

        response_hash, cmd_ok = get_rows_response(oci_cmd,config_hash)
        return cmd_ok,response_hash
    end

    def is_using_user_call_proc?(user)
        cmd_ok,response_hash = get_user_call_proc_settings(user)

        result = false
        result = true if response_hash[:useUserCLIDSetting] == "true"

        return result
    end

    def get_user_cfb_settings(user=nil)
        oci_cmd = :UserCallForwardingBusyGetRequest
        config_hash = send(oci_cmd)
        config_hash[:userId] = user
        abort "#{__method__} for #{oci_cmd} Default Options: #{config_hash}" if user == nil

        response_hash, cmd_ok = get_rows_response(oci_cmd,config_hash)
        return cmd_ok,response_hash
    end

    def get_user_cw_setting(user=nil)
        oci_cmd = :UserCallWaitingGetRequest17sp4
        config_hash = send(oci_cmd)
        config_hash[:userId] = user
        abort "#{__method__} for #{oci_cmd} Default Options: #{config_hash}" if user == nil

        response_hash, cmd_ok = get_rows_response(oci_cmd,config_hash)
        return cmd_ok,response_hash
    end

    def get_user_device_info(ent=nil,group=nil,dev_name=nil)
        oci_cmd = :GroupAccessDeviceGetRequest18sp1
        config_hash = send(oci_cmd,ent,group,dev_name)
        abort "#{__method__} for #{oci_cmd} Default Options: #{config_hash}" if ent == nil

        response_hash,cmd_ok = get_nested_rows_response(oci_cmd,config_hash)

        return cmd_ok,response_hash
    end

    def get_user_dnd_status(user)
        oci_cmd = :UserDoNotDisturbGetRequest
        config_hash = send(oci_cmd,user)
        abort "#{__method__} for #{oci_cmd} Default Options: #{config_hash}" if user == nil

        response_hash,cmd_ok = get_rows_response(oci_cmd,config_hash)
        puts "#{__method__}: response:\n#{response_hash}\n"

        return response_hash[:isActive]
    end

    def get_user_filtered_info(user,filter=nil)
    	oci_call = :UserGetRequest20
        response_hash,cmd_ok = get_nested_rows_response(oci_call,{userId: user})

        user_filtered_info = "NONE"
        if filter == nil
        	user_filtered_info = response_hash
        else
            user_filtered_info = response_hash[filter] if response_hash.has_key?(filter)
        end

        return cmd_ok,user_filtered_info
    end

    def get_users_in_group(ent=nil,group=nil,search_criteria=nil,value=nil,mode='Equal To',isCaseInsensitive=nil)
    	oci_cmd = :UserGetListInGroupRequest
    	config_hash = send(oci_cmd,ent,group,search_criteria,value,mode,isCaseInsensitive)
    	abort "#{__method__} for #{oci_cmd} Default Options: #{config_hash}" if ent == nil
        users = Array.new
        table_header = "userTable"

        table_of_users,cmd_ok = get_table_response(oci_cmd,table_header,config_hash)
        if table_of_users.is_a?(Array)
          table_of_users.each { |user_hash| users << user_hash[:User_Id] }
        end


        return cmd_ok,users
    end   

    def get_users_in_sys_by_id(ele)
        oci_cmd = :UserGetListInSystemRequest
        config_hash = send(oci_cmd,ele)
        abort "#{__method__} for #{oci_cmd} Default Options: #{config_hash}" if ele == nil

        users = Array.new
        table_header = "userTable"

        table_of_users,cmd_ok = get_table_response(oci_cmd,table_header,config_hash)
        table_of_users.each { |user_hash| users << user_hash[:User_Id] }

        return cmd_ok,users        
    end     

    def get_service_users_in_group(ent,group)
        cmd_ok,response_hash = get_ent_service_list(ent)

        users = Array.new
        if response_hash.is_a?(Array)
          response_hash.each { |user_info| users.push(user_info[:User_ID]) if user_info[:Group_ID] == group}
        end
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

    def get_user_svc_pack_list(user=nil)
        oci_cmd = :UserServiceGetAssignmentListRequest
        config_hash = send(oci_cmd,user)
        abort "#{__method__} for #{oci_cmd} Default Options: #{config_hash}" if user == nil

        table_header = 'servicePacksAssignmentTable'
        response_hash,cmd_ok = get_table_response(oci_cmd,table_header,config_hash)

        return cmd_ok,response_hash

    end

    def get_user_tn_assignment(tn,user)
        cmd_ok,alt_num_info = get_user_alternate_numbers(user)
        entrys = alt_num_info.keys
        found_tn = "address"
        entrys.each do |e|
            if e.to_s =~ /alternateEntry\d\d/
                if alt_num_info[e].has_key?(:phoneNumber)
                    found_tn = e if alt_num_info[e][:phoneNumber] == tn
                end
            end
        end
        return found_tn
    end


    def get_user_clean_svc_list(user=nil)
        svc_list = Array.new
        cmd_ok,response_hash = $bw.get_user_svc_list(user)
        response_hash.each do |svc_info|
            svc_list.push(svc_info[:Service_Name]) if svc_info[:Assigned] == "true"
        end

        return svc_list
    end


    def get_user_svc_pack_list(user=nil)
        oci_cmd = :UserServiceGetAssignmentListRequest
        config_hash = send(oci_cmd,user)
        abort "#{__method__} for #{oci_cmd} Default Options: #{config_hash}" if user == nil

        table_header = 'servicePacksAssignmentTable'
        response_hash,cmd_ok = get_table_response(oci_cmd,table_header,config_hash)

        return cmd_ok,response_hash

    end

    def get_user_vm_advanced_config(user=nil)
        oci_cmd = :UserVoiceMessagingUserGetAdvancedVoiceManagementRequest14sp3
        config_hash = send(oci_cmd,user)
        abort "#{__method__} for #{oci_cmd} Default Options: #{config_hash}" if user == nil

        response_hash,cmd_ok = get_nested_rows_response(oci_cmd,config_hash)

        return cmd_ok,response_hash
    end

    def get_user_vm_config(user=nil)
        oci_cmd = :UserVoiceMessagingUserGetVoiceManagementRequest17
        config_hash = send(oci_cmd,user)
        abort "#{__method__} for #{oci_cmd} Default Options: #{config_hash}" if user == nil

        response_hash,cmd_ok = get_rows_response(oci_cmd,config_hash)

        return cmd_ok,response_hash
    end

    def get_user_vm_in_use(user)
        vm_is_configured = false
        vm_is_on = false

        cmd_ok,response_hash = get_user_vm_config(user)
        vm_is_on = true if response_hash[:isActive] == "true"

        vm_is_configured = true if response_hash[:processing] == "Deliver To Email Address Only"

        unless vm_is_configured
            cmd_ok,response_hash = get_user_vm_advanced_config(user)
            vm_is_configured = true if (response_hash.has_key?(:groupMailServerEmailAddress) || response_hash.has_key?(:personalMailServerEmailAddress))
        end

        return vm_is_on,vm_is_configured
    end

    def mod_user_alt_num(user_mod_hash=nil,ok_to_send=true)
      oci_cmd = :UserAlternateNumbersModifyRequest
      config_template = send(oci_cmd)
      config_hash = mod_user_config(config_template,user_mod_hash)

      response,cmd_ok = send_request(oci_cmd,config_hash,ok_to_send)
      return cmd_ok,response

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

    def mod_user_cfb(user,is_active,fwd_to)
        oci_cmd = :UserCallForwardingBusyModifyRequest
        config_hash = send(oci_cmd,user,is_active,fwd_to)
        abort "#{__method__} for #{oci_cmd} Default Options: #{config_hash}" if user == nil

        response,cmd_ok = send_request(oci_cmd,config_hash)
        return cmd_ok,response        
    end

    def mod_user_config(config_hash,user_mod_hash)
      config_hash.keep_if do |k|
        is_true = false
        if user_mod_hash.has_key?(k)
          config_hash[k] = user_mod_hash[k]
          is_true = true
        end
        is_true
      end

      return config_hash
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

    def mod_user_cw(user,is_active)
        oci_cmd = :UserCallWaitingModifyRequest
        config_hash = send(oci_cmd,user,is_active)
        abort "#{__method__} for #{oci_cmd} Default Options: #{config_hash}" if user == nil

        response,cmd_ok = send_request(oci_cmd,config_hash)
        return cmd_ok,response
    end

    def mod_user_dnd_status(user=nil,set_dnd)
        oci_cmd = :UserDoNotDisturbModifyRequest
        config_hash = send(oci_cmd,user,set_dnd)
        abort "#{__method__} for #{oci_cmd} Default Options: #{config_hash}" if user == nil

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

    def mod_user_profile(user_mod_hash=nil,ok_to_send=true)
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


    # def mod_user_remove_tn(user=nil,ok_to_send=true)
    #     oci_cmd = :UserModifyRequest17sp4
    #     config_hash = {
    #         userId: user,
    #         phoneNumber: {attr: {'xsi:nil' => "true"}}
    #     }
    #
    #     abort "#{__method__} for #{oci_cmd} Default Options: #{config_hash}" if user == nil
    #     response,cmd_ok = send_request(oci_cmd,config_hash,ok_to_send)
    #
    #     return cmd_ok,response
    # end

    def get_user_rec_config(user)
        oci_cmd = :UserBroadWorksReceptionistEnterpriseGetRequest
        config_hash = send(oci_cmd,user)
        abort "#{__method__} for #{oci_cmd} Default Options: #{config_hash}" if user == nil

        table_header = 'monitoredUserTable'
        response_hash,cmd_ok = get_table_response(oci_cmd,table_header,config_hash)

        return cmd_ok,response_hash
    end

    def get_user_register_status(user=nil)
        oci_cmd = :UserGetRegistrationListRequest
        config_hash = send(oci_cmd,user)
        abort "#{__method__} for #{oci_cmd} Default Options: #{config_hash}" if user == nil

        table_header = 'registrationTable'
        response_hash,cmd_ok = get_table_response(oci_cmd,table_header,config_hash)

        return cmd_ok,response_hash
    end

    def mod_user_svc(user=nil,svc_list=nil)
        oci_cmd = :UserServiceUnassignListRequest
        config_hash = send(oci_cmd,user)
        config_hash[:serviceName] = svc_list
        abort "#{__method__} for #{oci_cmd} Default Options: #{config_hash}" if user == nil

        response,cmd_ok = send_request(oci_cmd,config_hash)

        return cmd_ok,response
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
