
class AuditMessaging

	def initialize(svc_list,filter_addr_type,filter_svc_configured,filter_user)
		@licenses = svc_list
		@filter_addr_type, @filter_svc_configured, @filter_user,response = validate_input(filter_addr_type,filter_svc_configured,filter_user)
		abort "Invalid input\n  #{response}" if response != nil

	end

	def get_assigned_users(ent,group_list)
		group_list.each do |group|
			assigned_users = $bw_helper.get_license_assignment(ent,group,@licenses)
			assigned_users.each do |user,svc_list|
				cmd_ok,user_addr_type = $bw.get_user_addr_type(user)

				print "#{ent},#{group},#{user},#{user_addr_type},"
				is_ok_to_delete = ok_to_delete?(user,user_addr_type)
				puts "DEL?#{is_ok_to_delete}"
			end
		end
	end

	def ok_to_delete?(user,user_addr_type)
		is_ok_to_delete = false
		if @filter_addr_type == nil || user_addr_type == @filter_addr_type
			if @filter_user == nil || user.match(Regexp.new(filter_user,Regexp::IGNORECASE))
				is_ok_to_delete = true unless is_messaging_in_use?(user)
			end
		end
		return is_ok_to_delete
	end

	def is_messaging_in_use?(user)
		svc_is_active = false
		svc_is_on,svc_is_configured = $bw.get_user_vm_in_use(user)

        print "IS_ON=#{svc_is_on},IS_CONFIG=#{svc_is_configured},"
		
        if svc_is_on == true
        	svc_is_active = true
        else
        	svc_is_active = true if svc_is_configured == true && @filter_svc_configured == true
        end

		return svc_is_active
	end

	def validate_input(filter_addr_type,filter_svc_configured,filter_user)
		# Validate addr type
		unless filter_addr_type == nil	
			response = "Invalid User Type: (#{filter_addr_type})\n  Valid options are #{$bw_helper.valid_user_types}" if $bw_helper.valid_user_types.include?(filter_addr_type) == false
		end

		# Validate for Boolean for filter_svc_configured
		unless filter_svc_configured == nil
			if filter_svc_configured == "true" || filter_svc_configured == "false"
				filter_svc_configured = filter_svc_configured.to_bool
			else
				response = "Invalid boolean value (#{filter_svc_configured})\n  Valid options are [true|false]"
			end
		end

		# Validate UserId Search String
		# No Validation

		return filter_addr_type,filter_svc_configured,filter_user,response
	end

end