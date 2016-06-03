
class AuditMessaging

	def initialize
		@licenses = ["Voice Messaging User"]
	end

	def get_messaging_users(ent,group_list)
		group_list.each do |group|
			messaging_users = $bw_helper.get_license_assignment(ent,group,@licenses)
			puts messaging_users
		end


	end



end