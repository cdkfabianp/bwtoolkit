class GetEntInfo

	def initialize
		@query_list = Hash.new(Array.new)
		@query_list = get_query_list

		@domain_map = Hash.new
		if ENV['IS_PROD'] == "true"
			@domain_map = {
				'as.s1.networkphoneasp.com' => 'Hosted',
				's1.networkphoneasp.com' => 'Hosted',
				'atc.networkphoneasp.com' => 'CTC',
				'callconnect.s1.networkphoneasp.com' => 'CallConnect',
				'ciscospa.s1.networkphoneasp.com' => 'SmallBusiness',
			}
		else
			@domain_map = {
				'as.lab1.adpvoice.com' => 'Hosted',
				'as1' => 'Hosted',
				'callconnect.lab1.adpvoice.com' => 'CallConnect',
				'cisco.lab1.adpvoice.com' => 'CTC',
				'cube.adpvoice.com' => 'CTC'
			}
		end			
	end

	def get_query_list
		#Check if query is file
		query_data = Hash.new
		if $options.has_key?(:file)
			result = $bw_helper.get_array_from_file($options[:file])
			result.each do |ent|
				query_data[ent] = [nil]
			end
		else 
			query_data = $bw_helper.get_groups_to_query
		end
		return query_data
	end

	def get_ent_info(sub_cmd)
		@query_list.each do |ent,groups|
			@ele = {ent: ent, group: groups}
			send(sub_cmd,ent)
		end
	end

	def get_basic_info(ent)
		name,product_type = get_profile_info(ent)
		puts "#{ent},#{name}"

	end

	def get_admin_tracker(ent)
		admin_list = get_ent_group_admin_list
		admin_list.each do |ent,info|
			# puts "\"ENT\",\"#{ent}\",\"#{info[:ent_name]}\",\"\",\"\",\"\",\"#{info[:ent_admin]}\""
			info[:groups].each do |group|
				puts "\"GROUP\",\"#{ent}\",\"\",\"#{group[:group]}\",\"#{group[:group_name]}\",\"#{group[:product]}\",\"#{group[:group_admin]}\""
			end
		end
	end

	def get_ent_group_admin_list
		cmd_ok,ent_admins = $bw.get_ent_admin_list(@ele[:ent])
		name,product_type = get_profile_info(@ele[:ent])

		admin_list = Hash.new
		admin_list[@ele[:ent]] = {ent_name: name, ent_admin: ent_admins.length > 0, groups: Array.new}

		puts "#{@ele[:ent]},#{ent_admins.join(",")}"
		@ele[:group].each do |group|
			name,product_type = get_profile_info(@ele[:ent],group)			
			if product_type == "Hosted"
				cmd_ok,group_admins = $bw.get_group_admin_list({ent: @ele[:ent], group: group}) 
				admin_list[@ele[:ent]][:groups].push({group: group, group_name: name, product: product_type, group_admin: group_admins.length > 0})
				puts "#{@ele[:ent]},#{group},#{group_admins.join(",")}"
			end
		end
		return admin_list
	end

	def get_profile_info(ent,group=nil)
		name = nil
		product_type = "UNKNOWN"		

		profile_info = nil
		if group == nil
			cmd_ok,profile_info = $bw.get_ent_profile(ent)
			name = profile_info[:serviceProviderName]
		else
			cmd_ok,profile_info = $bw.get_group_profile(ent,group)
			name = profile_info[:groupName] if profile_info.has_key?(:groupName)
			product_type = get_default_domain(profile_info)
		end

		return name,product_type
	end

	def get_default_domain(profile_info)
		default_domain = profile_info[:defaultDomain]
		product_type = @domain_map[default_domain] if @domain_map.has_key?(default_domain)
	end


end
