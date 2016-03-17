class AuditAnnouncementRepo

	def update_name_with_slash(ent,group)

		#Check Group Audio Repository for files with Name that contains backslashes "\"
		cmd_ok,response_hash = $bw.get_group_annoucement_list(ent,group)
		print_output(ent,group,get_files(response_hash),"group")

		#Check all Users (within a group) Audio Repository for files with Name that contains backslashes "\"
		cmd_ok,users = $bw.get_users_in_group(ent,group)
		print_output(ent,group,get_user_announcement_list(users),"users")

		
	end

	def print_output(ent,group,file_names,entity)
		if file_names != nil #&& file_names.length > 0
			puts "Need to update files for #{entity}"			
			file_names.each do |user_info|
				if user_info.is_a?(String)
					result,new_name = mod_file_name(user_info,group,ent)
					puts "Updated file info for #{ent}/#{group},#{user_info},#{new_name},#{result}"
				else
					user_info[:files].each do |file| 
						result,new_name = mod_file_name(file,user_info[:user])
						puts "Updated file info for #{user_info[:user]},#{file},#{new_name},#{result}"
					end
				end
			end
		else
			puts "No files need to be updated for #{entity}"
		end
	end

	def mod_file_name(file,id,ent=nil)
		new_name = file.gsub("\\","_")
		# print "#{id}: Old Name: #{file} => New Name: #{new_name} "
		cmd_ok,response = nil
		if ent==nil
			cmd_ok,response = $bw.mod_user_announcement_file(id,file,new_name) 
		else
			cmd_ok,response = $bw.mod_group_announcement_file(ent,id,file,new_name)
		end

		return cmd_ok,new_name
	end

	def get_files(response_hash)
		file_names = Array.new
		response_hash[:announcementTable].each do |file_info| 
			file_names.push(file_info[:Name]) if file_info[:Name] =~ /\\/
		end
		file_names = nil if file_names.length == 0
		return file_names
	end

	def get_user_announcement_list(users)
		user_files_to_mod = Array.new
		users.each do |user|
			cmd_ok,response_hash = $bw.get_user_announcement_list(user)			
			files = get_files(response_hash) unless response_hash[:announcementTable] == nil
			user_files_to_mod.push(user: user, files: files) unless files == nil
		end		
		return user_files_to_mod
	end




end