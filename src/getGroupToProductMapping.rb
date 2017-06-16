# TODO
# PRINT OUTPUT per Transfer Data Spreadsheet from SNAP
class GroupToProductMapping

	def initialize(verbose)
		@verbose = verbose
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

		@blanks = {a: "", b: "", c: ""}
		@switch_info = {switch: "Broadsoft", switch_ver: "R20sp1", blank: ""}
	end

	def get_product_map(ent,group_list)
		ent_name,ent_addr = get_profile_info(ent)
		ent_info = {ent_id: ent, ent_name: ent_name, ent_addr: ent_addr, contact_info: @blanks, switch_platform: @switch_info, group_info: Hash.new}

		group_list.each do |group|		

	        group_name,group_addr,product_type,group_tz = get_profile_info(ent,group)
	        if $options[:vgroup] == "true"
	      		ent_info = $helper.make_hoh
	        	ent_info[ent][group] = {group_name: group_name, product_type: product_type, time_zone: group_tz}
			else	        	
				ent_info[:group_info] = Hash.new
        		ent_info[:group_info] = {group_id: group, group_name: group_name, group_addr: group_addr, product_type: product_type}
        	end

			my_values = Array.new
			if $options[:orca] == "true"
				my_values = print_orca_info(ent_info)
			elsif $options[:snap] == "true"
				my_values = print_snap_info(ent_info)
			elsif $options[:vgroup] == "true"
				my_values = print_group_verbose_info(ent_info)
			else
				#Ugly stuff to print out CSV lines with values in quotes ""
				#Used originally to populate SNAP Customer Data Spreadsheet
				my_values = print_ent_info(ent_info)
				counter = 0
				my_values.each do |value|
					print "\"#{value}\""
					print "," unless counter == my_values.length - 1
					print "\n" if counter == my_values.length - 1
					counter += 1
				end
			end
		end
	end

	def print_orca_info(ent_info)
		ent_info.each {|k,v| puts "\"#{v[:group_id]}\"|\"#{v[:group_name]}\"|\"#{v[:product_type]}\"" if k == :group_info}
	end

	def print_snap_info(ent_info)
		counter = 0
		my_values = print_ent_info(ent_info)
		my_values.each do |value|
			next unless my_values.include?("Hosted")
			print "\"#{value}\""
			print "|" unless counter == my_values.length - 1
			print "\n" if counter == my_values.length - 1
			counter += 1
		end
	end

	def print_ent_info(ent_info,my_values=Array.new)
		ent_info.each do |k,v|
			print_ent_info(v,my_values) if v.is_a?(Hash)
			my_values << v unless v.is_a?(Hash) || k == :country
		end
		return my_values
	end

	def print_group_verbose_info(ent_info)
		@device_search_list = $bw.get_sys_poly_device_types

		ent_info.each do |ent,group_info|
			group_info.each do |group,group_detail|
				devices_list = $bw.get_group_device_list_by_type(ent,group,@device_search_list)
				puts "#{ent},#{group},#{group_detail[:product_type]},#{group_detail[:time_zone].split(/\s/)[2]},#{devices_list.length}" if devices_list.length > 0
			end
		end
	end

	def get_profile_info(ent,group=nil)
		name = nil
		product_type = "UNKNOWN"		
		addr = {addressLine1: nil, addressLine2: nil, city: nil, stateOrProvince: nil, zipOrPostalCode: nil, country: nil}

		profile_info = nil
		if group == nil
			cmd_ok,profile_info = $bw.get_ent_profile(ent)
			name = profile_info[:serviceProviderName]
		else
			cmd_ok,profile_info = $bw.get_group_profile(ent,group)
			name = profile_info[:groupName] if profile_info.has_key?(:groupName)
			group_tz = profile_info[:timeZoneDisplayName]
			product_type = get_default_domain(profile_info)
		end

		addr.merge!(profile_info[:address]) if @verbose && profile_info.has_key?(:address)

		return name,addr,product_type,group_tz
	end

	def get_default_domain(profile_info)
		default_domain = profile_info[:defaultDomain]
		product_type = @domain_map[default_domain] if @domain_map.has_key?(default_domain)
	end


end
