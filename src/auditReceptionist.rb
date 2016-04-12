
class AuditReceptionist

	def print_header
		puts "Enterprise,Group,User,Monitoring Users"
	end

	def get_receptionist_users(ent,group)
		puts "#{ent},#{group}"
                cmd_ok,rec_list = $bw.get_users_assigned_to_service(ent,group,'Client License 4')
                # next unless rec_list.length > 0		

                rec_list.each do |user|
                	cmd_ok,response_hash = $bw.get_user_rec_config(user)
                	is_monitoring_users = true
                	is_monitoring_users = false if response_hash.empty?
                	puts "#{ent},#{group},#{user},#{is_monitoring_users}"
                end
        end
end
