
class UpdateTrunkCapacity

	def initialize()
		@new_trunk_cap = $options[:cap]
		@ent = $options[:ent]
		@service = "Trunk Group"
		if ENV["IS_PROD"] == "true"
			@tg_search_string = Regexp.new('^\d{8}_ATC_TG')
		else
			@tg_search_string = Regexp.new('.*')
		end
	end

	def reclaim_trunk_licenses
		@update_trunks = $helper.make_hohoh
		cmd_ok,ent_cap = $bw.get_ent_trunk_cap(@ent)

		cmd_ok,groups = $bw.get_groups(@ent)
		groups.each do |group|
			next unless $bw.is_service_authorized?(@ent,group,@service)
			get_group_trunk_group_list(group).each do |tg|

				# Only get trunks we care about in production		
				next unless @tg_search_string.match(tg)
				trunks_to_mod = get_trunks_to_mod(group,tg)	

				# Update Individual Trunk Group Capacity (Group > Services > Trunk Group > {TG_Name} > Profile > Maximum Active Calls Allowed)
				cmd_ok,response = mod_group_trunk_group(trunks_to_mod)		
			end

			# Update Group Trunk Capacity (Group > Resources > Trunking Call Capacity > Maximum Capacity for any Trunk Group)
			cmd_ok,group_cap = $bw.get_group_trunk_cap(@ent,group)
			cmd_ok,response = $bw.mod_group_trunk_cap(@ent,group,@new_trunk_cap) if group_cap > @new_trunk_cap
			print_result("Group Trunk Capacity for #{group}",cmd_ok,response)
		end		

		# Update Enterprise Trunk Capacity (Enterprise > Resources > Trunking Call Capacity)
		cmd_ok,ent_cap = $bw.get_ent_trunk_cap(@ent)
		cmd_ok,response = $bw.mod_ent_trunk_cap(@ent,@new_trunk_cap) if ent_cap > @new_trunk_cap
		print_result("Enterprise Trunk Capacity for #{@ent}",cmd_ok,response)

		# Print original trunk configs
		puts "Original Trunk Configs"
		puts @update_trunks

	end

	def print_result(obj,cmd_ok,response)
		if cmd_ok
			puts "Successfully updated #{obj} to #{@new_trunk_cap}"
		else
			puts "Failed to update #{obj} with error:\n---#{response}\n---"
		end
	end


	def mod_group_trunk_group(trunks_to_mod)
		if trunks_to_mod
			@update_trunks.each do |ent,groups|
				groups.each do |group,tgs|
					tgs.each do |tg,mod_config|
						cmd_ok,response = $bw.mod_group_tg_trunk_cap(ent,group,tg,mod_config)						
						print_result("Trunk Group Trunk Capcity for #{tg}",cmd_ok,response)
					end
				end
			end
		end
	end

	# Look at each trunk group in a group
	# Add to update list if maxActive calls is higher than proposed new max capacity (IE we can reclaim licenses)
	def get_trunks_to_mod(group,tg)
		trunks_to_mod = false
		cmd_ok,tg_trunk_config = $bw.get_trunk_group_trunk_config(@ent,group,tg)
		# puts "EXISTING_CONFIG,#{@ent},#{group},#{tg},#{tg_trunk_config[:maxActiveCalls]},#{tg_trunk_config[:maxIncomingCalls]},#{tg_trunk_config[:maxOutgoingCalls]}"
		
		# If maxActiveCalls is greater than the new_trunk_capacity update with the new, lower trunk capacity
		# Propose setting maxIncomingCalls and maxOutgoingCalls to nil (as this is the expected config)
		if tg_trunk_config[:maxActiveCalls] > @new_trunk_cap
			trunks_to_mod = true
			@update_trunks[@ent][group][tg] = {
				maxActiveCalls: @new_trunk_cap,
				maxIncomingCalls: {
					attr: {:"xsi:nil" => true,}
				},
				maxOutgoingCalls: {
					attr: {:"xsi:nil" => true,}
				}						
			}

			# If maxIncomingCalls or maxOutgoingCalls is not nil, update value to new trunk capacity
			# This is not a normal configuration
			@update_trunks[@ent][group][tg][:maxIncomingCalls] = @new_trunk_cap if tg_trunk_config[:maxIncomingCalls] != nil
			@update_trunks[@ent][group][tg][:maxOutgoingCalls] = @new_trunk_cap if tg_trunk_config[:maxOutgoingCalls] != nil
		end		

		return trunks_to_mod
	end


	def get_group_trunk_group_list(group)
		group_list = Array.new
		cmd_ok,trunk_list = $bw.get_trunk_group_trunk_list(@ent,group)

		return trunk_list
	end

end