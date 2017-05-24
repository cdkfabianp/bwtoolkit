

class GetCommunicatorInfo

	def initialize(all_poly,counts_only,ent=nil,group=nil)
		@ent_groups = nil
		ent == nil ? @ent_groups = $bw.get_groups_in_system : @ent_groups = {ent => [group]}


		@device_search_list = ["Business Communicator - Mobile", "Business Communicator - Tablet", "Business Communicator - PC"]
		puts "Searching System for Registrations on the following devices:\n #{@device_search_list}\n---------------------------------------\n"
	end


	def get_device_list
		curr_date = Time.now.strftime("%-m/%-d/%y")
		puts @counts == true ? "Enterprise,Group,Configured,Registered" : "\"Date\"|\"Enterprise\"|\"Group - Group Name\"|\"ConfiguredDeviceType\"|\"App Name\"|\"App Version\"|\"App OS\""
		@ent_groups.each do |ent,groups|
			groups.each do |group|
				cmd_ok,g_profile = $bw.get_group_profile(ent,group)

				# Get Group Name (Remove surrounding quotes as I add that back in when I do the final print)
				# If Group Name doesn't exist add __NONE__
			 	group_name = g_profile.has_key?(:groupName) ? g_profile[:groupName].gsub(/\"(.*)\"/, '\1') : "__NONE__"

			 	# Get List of Devices for group
				devices_list = $bw.get_group_device_list_by_type(ent,group,@device_search_list)

				#For each device get UA (if registered), and other device info
				ua_device_list = get_reg_info(ent,group,devices_list)

				#Get count of devices both deg and configured
				configed_devices = devices_list.length
				reged_devices = ua_device_list.length

				#Print results, if $options[:counts] (IE -s true) print only summary information, otherwise print details
				@counts == true ? print_dev_reg_counts(ent,group,group_name,configed_devices,reged_devices) : print_dev_reg_list(curr_date,ent,group,group_name,ua_device_list)
			end
		end
	end

	def print_dev_reg_counts(ent,group,group_name,configed_devices,reged_devices)
		puts "#{ent}|#{group} - #{group_name}|#{configed_devices}|#{reged_devices}" if configed_devices > 0
	end

	def print_dev_reg_list(date,ent,group,group_name,ua_device_list)
		ua_device_list.each { |dev_name,dev_info| puts "\"#{date}\"|\"#{ent}\"|\"#{group} - #{group_name}\"|\"#{dev_info.join("\"|\"")}\"" }		
	end

	def get_reg_info(ent,group,devices_list)
	    ua_device_list = Hash.new(Array.new)

	    devices_list.each do |device_list|
	    	dev_name = device_list[:Device_Name]
							
	    	# UA info is cached and old, not a very accurate way to get "current" registrations
	    	# config_dev_type is the Configured Identity/Device Profile (dev_type is the actual device model from User-Agent)
	    	config_type,config_dev_type,version = get_phone_config_info(ent,group,dev_name)
	    	if version
	    		app_name,app_ver,app_os = parse_ua(version)
	    		dev_mac = device_list[:MAC_Address] unless dev_mac
	    		ua_device_list[dev_name] = [config_dev_type,app_name,app_ver,app_os,config_type]
	    	end

    		# puts "#{self.class} | #{__method__} : My device_info for #{dev_name}: #{ua_device_list[dev_name]}"

	    end

	    return ua_device_list
	end

	def get_phone_config_info(ent,group,dev_name)
		# dev_info[:version] now shows registered User-Agent
		cmd_ok,dev_info = $bw.get_user_device_info(ent,group,dev_name)
		return dev_info[:configurationMode],dev_info[:deviceType],dev_info[:version]
	end

	def parse_ua(ua)
		app_name = "UNKNOWN DEVICE USER_AGENT (#{ua})"
		app_ver = "unknown"
		app_os = "unknown"

		/^bc-uc\s-\s(.*)\s\((\d.*)\s(.*)\)/.match(ua)
			app_name = $1
			app_ver = $2
			app_os_part = $3
		if app_ver =~ /(\d.*?)\s(.*)/
			app_ver = $1
			app_os = "#{$2} #{app_os_part}"
		end
		return app_name,app_ver,app_os
	end	
end