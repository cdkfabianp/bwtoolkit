
class AuditStandard

	def initialize(audit_type,user_type,removals)
		@standard_list = [
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

		@removal_count = 0
		@audit_type,@user_type,@removals,response = validate_input(audit_type,user_type,removals)
		abort "Invalid input\n  #{response}" if response != nil

		puts "TYPE: #{@audit_type}: USER_TYPE: #{@user_type}: REMOVALS: #{@removals}"
	end

	def get_standard_users(ent,group_list)
		group_list.each do |group|
			standard_users = get_license_assignment(ent,group)
			standard_users.each do |user,svc_list|
				cmd_ok,user_addr_type = $bw.get_user_addr_type(user)
				puts "AUDIT: #{ent},#{group},#{user},#{user_addr_type},#{svc_list}"

				#Reclaim Licenses if Task = recover
				if @removal_count <= @removals
					reclaim_licenses(user,svc_list) if @ok_to_delete == true && user_addr_type == @user_type
				else
					abort "Reached Maximum number of Removals: #{@removal_count}"
				end
			end
		end
	end

	def get_license_assignment(ent,group)
		standard_users = $helper.make_hoa
		@standard_list.each do |license|
			cmd_ok,user_list = $bw.get_users_assigned_to_service(ent,group,license)
			user_list.each { |user| standard_users[user].push(license) }
		end

		return standard_users
	end

	def reclaim_licenses(user,svc_list)
		cmd_ok,response = $bw.mod_user_svc(user,svc_list)
		puts "REMOVED: #{user}, #{svc_list}, OK: #{cmd_ok}"
		@removal_count += 1

	end

	def validate_input(audit_type,user_type,removals)
		response = nil

		#Validate Audit Type (Will Default to audit)
		audit_type = "audit" unless audit_type == "recover"
		
		#Validate User Type
		valid_user_types = ["Hosted_User", "Trunk_User", "Virtual_User", "None"]		
		response = "Invalid User Type: (#{user_type})\n  Valid options are #{valid_user_types}" if audit_type == "recover" && valid_user_types.include?(user_type) == false

		#Convert Removals to Integer
		new_removals = 0
		new_removals = removals.to_i if removals != nil

		return audit_type,user_type,new_removals,response

	end
end
