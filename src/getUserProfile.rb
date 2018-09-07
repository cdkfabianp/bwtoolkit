
class GetProfileInfo

	def initialize
	end

	def get_user_info(sub_cmd)
		send(sub_cmd)

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

		puts $bw.get_users_in_group(ent,group)
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
