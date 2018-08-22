class CallCenterInfo

# GroupCallCenterGetAgentListRequest
# GroupCallCenterGetInstanceListRequest

    def initialize(ent,group)
        @ent = ent
        @group = group
    end

	def get_cc_list
		cmd_ok,response_hash = $bw.get_group_cc_list(@ent,@group)
		return response_hash
	end
	
	def get_cc_assigned_agents
		get_cc_list.each do |cc_info|
			cmd_ok,agent_list = $bw.get_group_cc_agents(cc_info[:Service_User_Id])
			agent_list.each do |agent_info|				
				puts "#{cc_info[:Service_User_Id]},#{cc_info[:Name]},#{agent_info[:User_Id]},#{agent_info[:First_Name]} #{agent_info[:Last_Name]}"
			end
		end
	end


end
