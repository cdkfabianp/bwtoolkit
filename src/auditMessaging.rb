
class AuditMessaging

	def initialize
		@messaging_license = ["Voice Messaging User"]
	end

	def get_messaging_users(ent,group_list)
		group_list.each do |group|
			messaging_users = get_license_assignment(ent,group)
		end


	end



end