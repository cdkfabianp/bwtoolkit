
class GetProfileInfo

	def initialize(user,field_list)
		@file_name = user
		@field_list = get_field_list(field_list)

	end

	def get_profile_info
		field_num = 2
		user_list = Array.new
		File.exist?(@file_name) ? user_list = $bw_helper.get_users_from_file(@file_name,field_num) : user_list.push(@file_name)
		
		user_list.each do |user|
			puts "My user: #{user}"
		end
	end


	def get_field_list(field_list)
	end
end
