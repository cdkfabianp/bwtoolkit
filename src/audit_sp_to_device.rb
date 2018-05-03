
class AuditSPtoDeviceConfig

	def initialize(ent,group=nil)
		puts "my ent from audit: #{ent}"
		@ent = ent
		@group = group
		puts "my group: #{@group}"
	end

	def audit_users_in_ent

		group_list = get_groups

		group_list.each do |group|
			cmd_ok,user_list = $bw.get_users_in_group(@ent,group)
			user_list.each do |user_id|
				user_name = get_profile_info(user_id)
				assigned_sp = get_svc_list(user_id)
				dev_type = get_dev_info(user_id)
				reg_info = get_reg_info(user_id) if dev_type == "Hosted_User" && assigned_sp.join == "Call Forward Always Seat 1.1"

				puts "#{@ent},#{group},#{user_id},#{user_name},#{dev_type},#{reg_info},#{assigned_sp.join(" ")}"
			end
		end
	end

	def get_groups
		group_list = Array.new

		if @group == nil
			cmd_ok,group_list = $bw.get_groups(@ent)
		else
			group_list.push(@group)
		end
		return group_list
	end

	def get_reg_info(user_id)
		reg_info = nil
		cmd_ok,user_reg = $bw.get_user_register_status(user_id)

		reg_info = user_reg[0][:Expiration] unless user_reg == []
		return reg_info
	end

	def get_dev_info(user_id)
		dev_type = nil
		cmd_ok,dev_type = $bw.get_user_addr_type(user_id)

		return dev_type
	end

	def get_svc_list(user_id)
		assigned_sp = Array.new
		cmd_ok,response = $bw.get_user_svc_pack_list(user_id)
		response.each do |sp|
	       assigned_sp.push(sp[:Service_Pack_Name]) if sp[:Assigned] == "true"
	  	end

	  	return assigned_sp
	end

	def get_profile_info(user_id)
		user_name = nil

		cmd_ok,profile_info = $bw.get_user_filtered_info(user_id)
		user_name = "#{profile_info[:firstName]} #{profile_info[:lastName]}"

		return user_name
	end

end