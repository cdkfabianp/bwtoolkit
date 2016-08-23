require 'csv'

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

	def get_array_from_file(file_name)
		tn_list = Array.new
		File.exist?(file_name) ?  File.readlines(file_name).each {|line| tn_list.push(line.chomp)} : tn_list.push(file_name)

		return tn_list
	end

	def get_hash_from_file(file_name,std_list)
		user_list = Hash.new(Array.new)
		
		csv_file = CSV.read(file_name)
		csv_file.each do |line|
			svc_list = Array.new
			counter = 4			
			while counter <= line.length
				svc_list.push(line[counter]) if std_list.include?(line[counter])
				counter += 1
			end
			user_list[line[2]] = svc_list
		end

		return user_list
	end

	def get_svc_to_oci_map(svc)
		svc_map = {
			"Call Forwarding Always" => [:UserCallForwardingAlwaysGetRequest],
			"Call Forwarding Busy" => [:UserCallForwardingBusyGetRequest],
			"Call Forwarding No Answer" => [:UserCallForwardingNoAnswerGetRequest13mp16, :CallForwardingNoAnswerNumberOfRings],
			"Call Forwarding Not Reachable" => [:UserCallForwardingNotReachableGetRequest],
			"Alternate Numbers" => [:UserAlternateNumbersGetRequest17],
			"Call Forwarding Selective" => [:UserCallForwardingSelectiveGetRequest16,:UserCallForwardingSelectiveGetCriteriaRequest16],
			"Selective Call Acceptance" => [:UserSelectiveCallAcceptanceGetCriteriaListRequest, :UserSelectiveCallAcceptanceGetCriteriaRequest16, :UserSelectiveCallAcceptanceModifyActiveCriteriaListRequest],
			"Selective Call Rejection" => [:SelectiveCallRejectionCriteriaCallType, :UserSelectiveCallRejectionAddCriteriaRequest16, :UserSelectiveCallRejectionGetCriteriaListRequest, :UserSelectiveCallRejectionGetCriteriaRequest16sp1, :UserSelectiveCallRejectionModifyActiveCriteriaListRequest]							
		}

		return svc_map[svc]
	end

    def get_users_from_file(file_name,field_num)
        user_list = Array.new
        csv_file = CSV.read(file_name)
        csv_file.each {|line| user_list.push(line[field_num])}

        return user_list
    end

	def get_license_list
		sp_config_file = File.expand_path("../../../conf/service_pack.conf",__FILE__)
        File.exist?(sp_config_file) ? json_data = File.read(sp_config_file) : json_data =  sp_config_file	

		license_hash = JSON.parse(json_data, :symbolize_names => true)   
        return license_hash	
	end	
	
	def valid_user_types
		return ["Hosted_User", "Trunk_User", "Virtual_User", "None"]	
	end    

end
