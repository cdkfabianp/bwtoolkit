
class BWHelpers

	def get_groups_to_query()
		ent_groups = Hash.new(Array.new)
		if $options.has_key?(:all_groups)
			ent_groups = $bw.get_groups_in_system
		elsif $options.has_key?(:group)
			ent_groups = {$options[:ent] => [$options[:group]]}
		else
			abort "Please specify -g <GROUPID> or -a ALL"
		end

		return ent_groups
	end	

	def get_license_assignment(ent,group,license_query)
		assigned_users = $helper.make_hoa
		license_query.each do |license|
			cmd_ok,user_list = $bw.get_users_assigned_to_service(ent,group,license)
			user_list.each { |user| assigned_users[user].push(license) }
		end

		return assigned_users
	end

	def valid_user_types
		return ["Hosted_User", "Trunk_User", "Virtual_User", "None"]	
	end

end
