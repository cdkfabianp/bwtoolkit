
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
		@orig_trunk_config = $helper.make_hohoh
		cmd_ok,ent_cap = $bw.get_ent_trunk_cap(@ent)

		cmd_ok,groups = $bw.get_groups(@ent)
		trunks_to_mod = false
		groups.each do |group|
			update_trunks = $helper.make_hohoh
			next unless $bw.is_service_authorized?(@ent,group,@service)
			get_group_trunk_group_list(group).each do |tg|
				# Only get trunks we care about in production		
				next unless @tg_search_string.match(tg)
				update_trunks,trunks_to_mod = get_trunks_to_mod(update_trunks,group,tg)		
			end

			# Update Individual Trunk Group Capacity (Group > Services > Trunk Group > {TG_Name} > Profile > Maximum Active Calls Allowed)
			cmd_ok,response = mod_group_trunk_group(trunks_to_mod,update_trunks)	

			# Update Group Trunk Capacity (Group > Resources > Trunking Call Capacity > Maximum Capacity for any Trunk Group)
			cmd_ok,group_profile = $bw.get_group_profile(@ent,group)
			group_name = group_profile[:groupName].delete(?,) if group_profile.has_key?(:groupName)

			cmd_ok,group_cap = $bw.get_group_trunk_cap(@ent,group)
			cmd_ok,response = $bw.mod_group_trunk_cap(@ent,group,@new_trunk_cap) if group_cap > @new_trunk_cap
			print_result("Group Trunk Capacity for \"#{group} - #{group_name}\"",cmd_ok,response)
		end		

		# Update Enterprise Trunk Capacity (Enterprise > Resources > Trunking Call Capacity)
		cmd_ok,ent_cap = $bw.get_ent_trunk_cap(@ent)
		cmd_ok,response = $bw.mod_ent_trunk_cap(@ent,@new_trunk_cap) if ent_cap > @new_trunk_cap
		print_result("Enterprise Trunk Capacity for #{@ent}",cmd_ok,response)

		# Print original trunk configs
		puts "Original Trunk Configs"
		puts @orig_trunk_config

	end

	def print_result(obj,cmd_ok,response)
		if cmd_ok
			puts "Successfully updated #{obj} to #{@new_trunk_cap}"
		else
			puts "Failed to update #{obj} with error:\n---#{response}\n---"
		end
	end


	def mod_group_trunk_group(trunks_to_mod,update_trunks)
		if trunks_to_mod
			update_trunks.each do |ent,groups|
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
	def get_trunks_to_mod(update_trunks,group,tg)
		trunks_to_mod = false
		cmd_ok,tg_trunk_config = $bw.get_trunk_group_trunk_config(@ent,group,tg)
		# puts "EXISTING_CONFIG,#{@ent},#{group},#{tg},#{tg_trunk_config[:maxActiveCalls]},#{tg_trunk_config[:maxIncomingCalls]},#{tg_trunk_config[:maxOutgoingCalls]}"
		
		# If maxActiveCalls is greater than the new_trunk_capacity update with the new, lower trunk capacity
		# Propose setting maxIncomingCalls and maxOutgoingCalls to nil (as this is the expected config)
		if tg_trunk_config[:maxActiveCalls] > @new_trunk_cap
			trunks_to_mod = true
			update_trunks[@ent][group][tg] = {
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
			update_trunks[@ent][group][tg][:maxIncomingCalls] = @new_trunk_cap if tg_trunk_config[:maxIncomingCalls] != nil
			update_trunks[@ent][group][tg][:maxOutgoingCalls] = @new_trunk_cap if tg_trunk_config[:maxOutgoingCalls] != nil

			@orig_trunk_config.merge!(update_trunks)
		end		

		return update_trunks,trunks_to_mod
	end


	def get_group_trunk_group_list(group)
		group_list = Array.new
		cmd_ok,trunk_list = $bw.get_trunk_group_trunk_list(@ent,group)

		return trunk_list
	end
end

class BTLUParser
	require 'csv'

	def get_max_calls_from_btlu(btlu_report)

		parsed_hash = Hash.new(Hash.new(0))
		csv_file = CSV.read(btlu_report)
		csv_file.each do |line|
			if line[0] =~ /^\d{8}/
				ent_id = line[0]
				high_water_mark = line[3].to_i
				assigned_trunks = line[2].to_i
				if parsed_hash.has_key?(ent_id)
					if high_water_mark > parsed_hash[ent_id][:hwm]
						parsed_hash[ent_id][:cap] = assigned_trunks						
						parsed_hash[ent_id][:hwm] = high_water_mark
						parsed_hash[ent_id][:rec] = assigned_trunks - high_water_mark
						parsed_hash[ent_id][:prop_rec] = (parsed_hash[ent_id][:rec] * @recover_buffer).to_i
						parsed_hash[ent_id][:set_val] = parsed_hash[ent_id][:cap] - parsed_hash[ent_id][:prop_rec]
					end
				else
					parsed_hash[ent_id] = {
						hwm: 0,
						cap: 0,
						rec: 0,
						prop_rec: 0,
						set_val: 0,
					}
				end
			end
		end

		return parsed_hash
	end


	def parse_btlu
		@recover_buffer = 0.75

		# file_path = '/Users/fabianp/logs_scripts/'
		#file_path = '/Users/fabianp/Downloads/'
		abort("File not specified with -f") unless $options[:file]
		btluReport = File.exist?($options[:file]) ?  $options[:file] : abort("could not locate file: #{$options[:file]}\nPlease download from AS1 at /var/broadworks/reports/btlu/")

		max_calls = get_max_calls_from_btlu(btluReport)

		#Sort HASH by proposed recoverable
		max_calls_sorted = max_calls.sort_by {|k,v| v[:prop_rec]}

		puts "status,entId,ent_name,capacity,high_water_mark,max_recoverable,proposed_recoverable,update_capacity_to"
		max_calls_sorted.each do |ent,btlu_info| btlu_info[:prop_rec]
			# Get Enterprise Name and remove comma's from name
			cmd_ok,ent_profile = $bw.get_ent_profile(ent)
			ent_name = ent_profile[:serviceProviderName].delete(?,) if ent_profile.has_key?(:serviceProviderName)

			if btlu_info[:rec] == 0 && btlu_info[:cap] > 0
				puts "NEED_TO_UP,#{ent},#{ent_name},#{btlu_info[:cap]},#{btlu_info[:hwm]},#{btlu_info[:rec]},#{btlu_info[:prop_rec]},#{btlu_info[:cap] + 10}"
			elsif btlu_info[:rec] > 10
				puts "RECOVER_FROM,#{ent},#{ent_name},#{btlu_info[:cap]},#{btlu_info[:hwm]},#{btlu_info[:rec]},#{btlu_info[:prop_rec]},#{btlu_info[:set_val]}"
			end
		end

		max_rec_sum = 0
		prop_rec_sum = 0
		curr_cap = 0
		max_calls.each do |entID,data|
			max_rec_sum = max_rec_sum += data[:rec]
			prop_rec_sum = prop_rec_sum += data[:prop_rec]
			curr_cap = curr_cap += data[:cap]			
		end

		puts "Current Provisioned Capacity: #{curr_cap}"
		puts "Max Recoverable Trunks: #{max_rec_sum}"
		puts "Proposed Recoverable Trunks: #{prop_rec_sum}"
	end
end

