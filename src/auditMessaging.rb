
class AuditMessaging

	def initialize
		@licenses = ["Voice Messaging User"]
	end

	def get_assigned_users(ent,group_list)
		group_list.each do |group|
			assigned_users = $bw_helper.get_license_assignment(ent,group,@licenses)
			puts messaging_users
		end


	end



end