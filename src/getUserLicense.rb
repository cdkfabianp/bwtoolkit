
class GetUserLicense

	def initialize
	end

	def get_license_info(file_name,field_num)
		user_list = get_user_list(file_name,field_num.to_i)		
		user_list.each do |user|
			svc_list = $bw.get_user_clean_svc_list(user)
			puts "#{user},#{svc_list}"
		end
	end

	def get_user_list(file_name,field_num)
		user_list = Array.new
		File.exist?(file_name) ? user_list = $bw_helper.get_users_from_file(file_name,field_num) : user_list.push(file_name)	

		return user_list
	end




end
