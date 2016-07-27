class AuditServicePack

	def initialize(user_type,sp_name) 
		puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
		puts "!!THIS SCRIPT IS ATTEMPTING TO AUDITING #{sp_name} Service PACK!!"
		puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
		service_pack_name = sp_name.downcase.to_sym
		@license_packs = $bw_helper.get_license_list()
		@user_type,service_pack_name,response = validate_input(user_type,service_pack_name)

		abort "Invalid input\n  #{response}" if response != nil

		@service_pack = $bw_helper.get_license_list[service_pack_name]


	end

	def get_assigned_users(ent,group_list)
		group_list.each do |group|
			sp_users = $bw_helper.get_license_assignment(ent,group,@service_pack)
			sp_users.each do |user,svc_list|
				cmd_ok,user_addr_type = $bw.get_user_addr_type(user)
				puts "AUDIT: #{ent},#{group},#{user},#{user_addr_type},#{svc_list}" if @user_type == nil || @user_type == user_addr_type
			end
		end
	end

	def validate_input(user_type,service_pack)
		response = nil

		#Validate User Type	
		response = "Invalid User Type: (#{user_type})\n  Valid options are #{$bw_helper.valid_user_types}" unless user_type || $bw_helper.valid_user_types.include?(user_type) == false

		#Validate Service Pack Type
		response = "Invalid Service Pack (#{service_pack})\n  Valid options are #{@license_packs.keys}" if response == nil && @license_packs.keys.include?(service_pack) == false

		return user_type,service_pack,response

	end
end
