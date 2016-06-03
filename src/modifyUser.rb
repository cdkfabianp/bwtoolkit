require 'csv'

class ModifyUser

	def initialize
	end

	def modify_user(user,sub_cmd)
		send(sub_cmd,user)

	end

	def remove_receptionist(file_name)
		rec_license = ["Client License 4"]
		field_num = 2
		user_list = Array.new
		File.exist?(file_name) ? user_list = get_users_from_file(file_name,field_num) : user_list.push(file_name)
		
		user_list.each do |user|
			
			cmd_ok,response = $bw.mod_user_svc(user,rec_license)
			puts "Deleted #{rec_license} from #{user}"
		end

	end

	def remove_messaging(file_name)
		vm_license = ['Voice Messaging User']
		field_num = 2
		user_list = Array.new
		File.exist?(file_name) ? user_list = get_users_from_file(file_name,field_num) : user_list.push(file_name)
		
		user_list.each do |user|
			puts "My user: #{user}"
			
			cmd_ok,response = $bw.mod_user_svc(user,vm_license)
			puts "Deleted #{vm_license} from #{user}"
		end

	end

	def remove_standard(file_name)
		user_list = Hash.new(Array.new)
		standard_list = [
			"Anonymous Call Rejection",
			"Automatic Callback",
			"Call Me Now",
			"Diversion Inhibitor",
			"Do Not Disturb",
			"Flexible Seating Guest",
			"Group Night Forwarding", 
			"Hoteling Guest",
			"Security Classification",
			"Speed Dial 100",
			"Speed Dial 8"
		]		
		if File.exist?(file_name)
			user_list = get_hash_from_file(file_name,standard_list)
		else
			abort "unable to find file: #{file_name}"
		end

		user_list.each do |user,svc_list|
			cmd_ok,response = $bw.mod_user_svc(user,svc_list)
			puts "User: #{user}, REMOVED: #{svc_list}" if cmd_ok = true
		end

	end


	def del_user_email(file_name)
		user_list = Array.new		
		if File.exist?(file_name)
			user_list = get_users_from_file(file_name)
			user_list.each do |user|
				cmd_ok,response = $bw.mod_user_config(user,config)
				puts "Deleted #{config} from User: #{user}"
			end
		else
			ent_groups = $bw.get_groups_in_system
			ent_groups.each do |ent,groups|
				groups.each do |group| 
					cmd_ok, user_list = $bw.get_users_in_group(ent,group)
					user_list.each do |user|
						cmd_ok,user_email = $bw.get_user_filtered_info(user,:emailAddress)
						puts "#{ent},#{group},#{user},#{user_email}"
					end
				end
			end
		end
	end

	def get_hash_from_file(file_name,std_list)
		user_list = Hash.new(Array.new)
		
		csv_file = CSV.read(file_name)
		csv_file.each do |line|
			svc_list = Array.new
			counter = 4			
			while counter <= line.length
				svc_list.push(line[counter]) if std_list.include?(line[counter])
				counter += 1
			end
			user_list[line[2]] = svc_list
		end

		return user_list
	end


    def get_users_from_file(file_name,field_num)
        user_list = Array.new
        csv_file = CSV.read(file_name)
        csv_file.each {|line| user_list.push(line[field_num])}

        return user_list
    end

end
