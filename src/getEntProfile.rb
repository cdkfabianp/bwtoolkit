class GetEntInfo

	def initialize
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

	def get_ent_info(sub_cmd,ele)
		@ele = ele
		puts "My @ele: #{@ele}"
		send(sub_cmd)
	end

	def get_ent_group_admin_list
		cmd_ok,ent_admins = $bw.get_ent_admin_list(@ele[:ent])
		name,product_type = get_profile_info(@ele[:ent])

		$admin_list[@ele[:ent]] = {ent_name: name, ent_admin: ent_admins.length > 0, groups: Array.new}

		puts "#{@ele[:ent]},#{ent_admins.join(",")}"
		@ele[:group].each do |group|
			name,product_type = get_profile_info(@ele[:ent],group)			
			if product_type == "Hosted"
				cmd_ok,group_admins = $bw.get_group_admin_list({ent: @ele[:ent], group: group}) 
				$admin_list[@ele[:ent]][:groups].push({group: group, group_name: name, product: product_type, group_admin: group_admins.length > 0})
				puts "#{@ele[:ent]},#{group},#{group_admins.join(",")}"
			end
		end

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
