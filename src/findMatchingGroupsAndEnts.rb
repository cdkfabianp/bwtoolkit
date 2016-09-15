
class FindEntGroups

	def initialize(search_string)
		@search_string = search_string
	end

	def find_all_matches
		ent_groups = Hash.new
		ent_groups = $bw.get_groups_in_system

		name = nil
		type = nil
		if ent_groups.has_key?(@search_string)
			cmd_ok,response_hash = $bw.get_ent_profile(@search_string)
			response_hash[:group_list] = ent_groups[@search_string]
			puts response_hash
			name = response_hash[:serviceProviderName]
			type = 'EnterpriseId'
		else
			ent_groups.each do |ent,group_list|
				if group_list.include?(@search_string)
					cmd_ok,response_hash = $bw.get_group_profile(ent,@search_string)
					puts response_hash
					name = response_hash[:groupName]
					type = 'GroupId'
				end
			end
		end
		puts "#{@search_string} is a #{type} with name: #{name}"
	end
end
