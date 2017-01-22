require_relative 'bwgroup'

class BWEnt < BWGroup
    def get_ents
        oci_cmd = :ServiceProviderGetListRequest
        ents = Array.new
        config_hash = send(oci_cmd)

        table_header = "serviceProviderTable"
        table_of_ents,cmd_ok = get_table_response(oci_cmd,table_header,config_hash)
        table_of_ents.each { |ent_hash| ents << ent_hash[:Service_Provider_Id] }

        return cmd_ok,ents
    end

    def get_ent_admin_list(ent=nil)
        oci_cmd = :ServiceProviderAdminGetListRequest14
        config_hash = send(oci_cmd,ent)
        abort "#{__method__} for #{oci_cmd} Default Options: #{config_hash}" if ent == nil

        admins = Array.new
        table_header = "serviceProviderAdminTable"
        response_hash,cmd_ok = get_table_response(oci_cmd,table_header,config_hash)
        response_hash.each { |admin_hash| admins.push(admin_hash[:Administrator_ID])}

        return cmd_ok,admins
    end

	def get_ent_by_group_id(group)
		oci_cmd = :GroupGetListInSystemRequest
		config_hash = GroupGetListInSystemRequest()
		config_hash[:searchCriteriaGroupId][:value] = group
        table_header = 'groupTable'

        # ents = Array.new
        response_hash,cmd_ok = get_table_response(oci_cmd,table_header,config_hash)

        ent = "Could not find group: #{group} in system.  Group must be exact match (case INsensitive) for existing group in system"
        if response_hash.is_a?(Array)
            if response_hash[0].has_key?(:Organization_Id)
                ent = response_hash[0][:Organization_Id]
            else
                ent = "Could not get Enterprise ID from: #{group}"
            end
        end

        return ent
    end

    def get_ent_dn_info(ent=nil)
        oci_cmd = :ServiceProviderDnGetSummaryListRequest
        config_hash = send(oci_cmd,ent)
        abort "#{__method__} for #{oci_cmd} Default Options: #{config_hash}" if ent == nil

        table_header = "dnSummaryTable"
        response_hash,cmd_ok = get_table_response(oci_cmd,table_header,config_hash)

        return cmd_ok,response_hash
    end

    def get_ent_endpoint_info(ent=nil)
        oci_cmd = :ServiceProviderEndpointGetListRequest
        config_hash = send(oci_cmd,ent)
        abort "#{__method__} for #{oci_cmd} Default Options: #{config_hash}" if ent == nil

        table_header = "endpointTable"
        response_hash,cmd_ok = get_table_response(oci_cmd,table_header,config_hash)

        return cmd_ok,response_hash
    end

    def get_ent_profile(ent=nil)
        oci_cmd = :ServiceProviderGetRequest17sp1
        config_hash = send(oci_cmd,ent)
        abort "#{__method__} for #{oci_cmd} Default Options: #{config_hash}" if ent == nil

        response_hash,cmd_ok = get_nested_rows_response(oci_cmd,config_hash)

        return cmd_ok,response_hash
    end

    def get_ent_service_list(ent=nil,search_criteria=nil,value=nil)
        oci_cmd = :UserGetServiceInstanceListInServiceProviderRequest
        sc = search_criteria.to_sym if search_criteria != nil
        config_hash = UserGetServiceInstanceListInServiceProviderRequest(ent,sc,value)
        abort "#{__method__} for #{oci_cmd} Default Options: #{config_hash}" if ent == nil

        table_header = 'serviceInstanceTable'
        response_hash,cmd_ok = get_table_response(oci_cmd,table_header,config_hash)

        return cmd_ok,response_hash
    end

    def get_service_users_in_ent(ent)
        cmd_ok,response_hash = get_ent_service_list(ent)

        users = Array.new
        response_hash.each { |user_info| users.push(user_info[:User_ID]) }

        return cmd_ok,users

    end

    def get_sys_callp_clid_settings(ent)
    	oci_cmd = :ServiceProviderCallProcessingGetPolicyRequest17sp4
    	config_hash = ServiceProviderCallProcessingGetPolicyRequest17sp4()
        spCppCLIDSettings = Hash.new
        response_hash,cmd_ok = get_rows_response(oci_cmd,ent)
        spCppCLIDSettings = {
            clidPolicy: response_hash[:clidPolicy],
            emergencyClidPolicy: response_hash[:emergencyClidPolicy],
            allowAlternateNumbersForRedirectingIdentity: response_hash[:allowAlternateNumbersForRedirectingIdentity],
            blockCallingNameForExternalCalls: response_hash[:blockCallingNameForExternalCalls],
            allowConfigurableCLIDForRedirectingIdentity: response_hash[:allowConfigurableCLIDForRedirectingIdentity]
        }      
        return cmd_ok,spCppCLIDSettings
    end

    def mod_ent_delete_dn(ent=nil,tn_list=nil,ok_to_mod=true)
        oci_cmd = :ServiceProviderDnDeleteListRequest
        config_hash = send(oci_cmd,ent,tn_list)
        abort "#{__method__} for #{oci_cmd} Default Options: #{config_hash}" if ent == nil 

        response,cmd_ok = send_request(oci_cmd,config_hash,ok_to_mod)

        return cmd_ok,response
    end


end