
class GetProfileInfo

	def initialize
	end

	def get_user_info(sub_cmd)
		send(sub_cmd)

	end

	def get_large_user_list(ent,group)
		user_list = Array.new
		search_criteria = :searchCriteriaUserId
		prefix = Array (0..9)
		prefix.each do |d|
			value = "euro23#{d}"
			puts "Checking #{value}"
			cmd_ok,response_hash_ext = $bw.get_users_in_group(ent,group,search_criteria,value,mode='Starts With')
			puts "Checking #{d}"
			cmd_ok,response_hash_did = $bw.get_users_in_group(ent,group,search_criteria,d,mode='Starts With')	
			user_list.push(*response_hash_did)
			user_list.push(*response_hash_ext)
			puts "Updated User Count: #{user_list.length}"
		end

		puts "Total Users Found: #{user_list.length} AND list of users:\nSTART\n"

		return user_list
	end

	def get_profile_data
		group = $options[:group]
		ent = $options[:ent]

		user_list = get_large_user_list(ent,group)
		# cmd_ok,user_list = $bw.get_users_in_group(ent,group)
		puts "USERID|PHONE_NUMBER|EXTENSION|CLID_NUMBER|DID_MATCHES_EXT|USING_USER_CLID"
		user_list.each do |user|
			cmd_ok,data = $bw.get_user_filtered_info(user)

			phone_number = data[:phoneNumber]
			extension = data[:extension]
			clid_number = data[:callingLineIdPhoneNumber]

			# Make sure last 4 of DID match extension
			did_matches_extension = "NA"		
			did_matches_extension = "23#{phone_number.to_s.chars.last(4).join}" == extension.to_s if phone_number && extension

			# Get CLID settings
			is_using_user_clid = $bw.is_using_user_call_proc?(user)

			puts "#{user}|#{phone_number}|#{extension}|#{clid_number}|#{did_matches_extension}|#{is_using_user_clid}"
		end

	end

	def get_profile_info
		file_name = $options[:file]
		field_num = $options[:field_num]
		fields = $options[:query].split(",") if $options[:query]
		user_list = get_user_list(file_name,field_num.to_i)
		
		user_list.each do |user|
			cmd_ok,user_profile = $bw.get_user_filtered_info(user)

			#Print Data
			if fields == nil
				puts "#{user}: #{user_profile}"
			elsif user_profile.length == 0
				puts "#{user} profile not found"
			else
				user_profile.delete_if { |k| fields.include?(k.to_s) == false }
				puts "#{user},#{user_profile.values.join(",")}"
			end			
		end
	end

	def get_license_info
		file_name = $options[:file]
		field_num = $options[:field_num]
		user_list = get_user_list(file_name,field_num.to_i)		
		user_list.each do |user|
			svc_list = $bw.get_user_clean_svc_list(user)
			puts "#{user},#{svc_list}"
		end
		puts "#{user_list.length} records returned"
	end

	def get_user_list(file_name,field_num)
		user_list = Array.new
		if $options[:filter_user]
			cmd_ok,user_list = $bw.get_users_in_sys_by_id({mode: "Contains", value: $options[:filter_user]})
		elsif file_name
			File.exist?(file_name) ? user_list = $bw_helper.get_users_from_file(file_name,field_num) : user_list.push(file_name)	
		else
			abort "Unable to get list of users"
		end

		return user_list
	end

	def get_user_vm_settings
		ent = $options[:ent]
		cmd_ok,groups = $bw.get_groups(ent)
		groups.each do |group|
			cmd_ok,users = $bw.get_users_in_group(ent,group)
			users.each do |user|
				vm_is_on,vm_is_configured = $bw.get_user_vm_in_use(user)
				puts "RESULT,#{ent},#{group},#{user},#{vm_is_on}"
			end
		end
	end

	def print_users_in_group
		group = $options[:group]
		ent = $options[:ent]

		return $bw.get_user_filtered_info(ent,group)
	end

	def print_long_user_ids
		ent_groups = $bw.get_groups_in_system if $options[:ent] == nil			

		ent_groups.each do |ent,groups|
			groups.each do |group|

				cmd_ok,user_list = $bw.get_users_in_group(ent,group)
				user_list.each do |user|
					user_name = user.split("@")[0]
					if user_name.length > 16
						puts "#{user},TOO_MANY_CHARS"
					elsif user_name =~ /^(?!\d)/
						puts "#{user},NO_START_NUM"
					end
				end
			end
		end
	end
end
