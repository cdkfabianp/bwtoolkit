require_relative 'bwgroup'

class BWEnt < BWGroup
    def get_ents
        ents = Array.new
        table_header = "serviceProviderTable"
    
        table_of_ents,cmd_ok = get_table_response(:ServiceProviderGetListRequest,table_header)
        table_of_ents.each { |ent_hash| ents << ent_hash[:Service_Provider_Id] }

        return cmd_ok,ents
    end

	def get_ent_by_group_id(group)
		oci_cmd = :GroupGetListInSystemRequest
		config_hash = GroupGetListInSystemRequest()
		config_hash[:searchCriteriaGroupId][:value] = group
        table_header = 'groupTable'
        
        ents = Array.new
        response_hash,cmd_ok = get_table_response(oci_cmd,table_header,config_hash)

        ent = "Could not find group: #{group} in system.  Group must be exact match (case INsensitive) for existing group in system"
        if response_hash.length > 0
            if response_hash[0].has_key?(:Organization_Id)
                ent = response_hash[0][:Organization_Id]
            else
                ent = "Could not get Enterprise ID from: #{group}"
            end
        end

        return ent
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
end