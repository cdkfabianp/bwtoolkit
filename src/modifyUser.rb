require 'csv'

class ModifyUser

	def initialize
	end

	def modify_user(user,sub_cmd)
		send(sub_cmd,user)

	end

	def remove_receptionist(file_name)
		rec_license = ["Client License 4"]
		user_list = Array.new
		File.exist?(file_name) ? user_list = get_users_from_file(file_name) : user_list.push(file_name)
		
		user_list.each do |user|
			
			cmd_ok,response = $bw.mod_user_svc(user,rec_license)
			puts "Deleted #{rec_license} from #{user}"
		end

	end


    def get_users_from_file(file)
        user_list = Array.new
        csv_file = CSV.read(file)
        csv_file.each {|line| user_list.push(line[2])}

        return user_list
    end

end
