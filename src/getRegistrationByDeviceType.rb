
class GetRegByDeviceType

	def initialize(all_poly,counts_only)
		@ent_groups = $bw.get_groups_in_system
		@device_search_list = ['Polycom Soundpoint IP 500', 'Polycom Soundpoint IP 601'] 
		@device_search_list = $bw.get_sys_poly_device_types if all_poly == "true"
		@counts = counts_only
	end

	def get_poly_list
		puts @counts == "true" ? "Enterprise,Group,Configured,Registered" : "Enterprise,Group,DeviceType,DeviceVersion,DeviceMac"
		@ent_groups.each do |ent,groups|
			groups.each do |group|
				devices_list = $bw.get_group_device_list_by_type(ent,group,@device_search_list)
				ua_device_list = get_reg_info(ent,group,devices_list)
				configed_devices = devices_list.length
				reged_devices = ua_device_list.length
				@counts == "true" ? print_poly_reg_counts(ent,group,configed_devices,reged_devices) : print_poly_reg_list(ent,group,ua_device_list)
			end
		end


	end

	def print_poly_reg_counts(ent,group,configed_devices,reged_devices)
		puts "#{ent},#{group},#{configed_devices},#{reged_devices}"	 if configed_devices > 0
	end

	def print_poly_reg_list(ent,group,ua_device_list)
		ua_device_list.each { |dev_mac,dev_info| puts "#{ent},#{group},#{dev_info.join(",")},#{dev_mac}" }		
	end

	def get_reg_info(ent,group,devices_list)
	    ua_device_list = Hash.new(Array.new)

	    devices_list.each do |device_list|
	    	next if device_list[:MAC_Address] == "__NIL__"
	    	dev_name = device_list[:Device_Name]

			cmd_ok, user_ids = $bw.get_users_assigned_to_device(ent,group,dev_name)
	        user_ids.each do |user|
	        	#Skip User Reg Lookup if we have already found the Device Info
	    		next if ua_device_list.has_key?(device_list[:MAC_Address])

	            cmd_ok,user_reg = $bw.get_user_register_status(user)
	            user_reg.each do |line_reg|
	                dev_type,dev_ver,dev_mac = parse_ua(line_reg[:User_Agent])

	                #Insert configured MAC if MAC doesn't exist within User-Agent string
	               	dev_mac = device_list[:MAC_Address] unless dev_mac
	                ua_device_list[dev_mac] = [dev_type,dev_ver]
	            end
	        end
	    end

	    return ua_device_list
	end

	def parse_ua(ua)
		dev_type = "UNKNOWN DEVICE USER_AGENT (#{ua})"
		dev_ver = "unknown"
		dev_mac = "unknown"
		/^(Polycom.*)-UA\/([\.\d]+)/.match(ua)
			dev_type = $1
			dev_ver = $2
		/_(\w{12})$/.match(ua)		
			dev_mac = $3

		return dev_type,dev_ver,dev_mac
	end	

end
