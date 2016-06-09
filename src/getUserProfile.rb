
class GetProfileInfo

	def initialize(user,field_list)
		@file_name = user
		@field_list = field_list.split(",") if field_list

	end

	def get_profile_info
		field_num = 2
		user_list = Array.new
		File.exist?(@file_name) ? user_list = $bw_helper.get_users_from_file(@file_name,field_num) : user_list.push(@file_name)
		
		user_list.each do |user|
			cmd_ok,user_profile = $bw.get_user_filtered_info(user)
			print_fields(user,user_profile)
		end
	end

	def print_fields(user,profile)
		if @field_list == nil
			puts "#{user}: #{profile}"
		elsif profile.length == 0
			puts "#{user} profile not found"
		else
			profile.delete_if { |k| @field_list.include?(k.to_s) == false }
			puts "#{user},#{profile.values.join(",")}"
		end
	end

end
