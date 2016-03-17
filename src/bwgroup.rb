require_relative 'bwuser'
class BWGroup < BWUser

    def get_group_annoucement_list(ent=nil,group=nil)
        oci_cmd = :GroupAnnouncementFileGetListRequest
        config_hash = send(oci_cmd)
        config_hash[:serviceProviderId] = ent
        config_hash[:groupId] = group
        abort "#{__method__} for #{oci_cmd} Default Options: #{config_hash}" if ent == nil

        response_hash, cmd_ok = get_rows_response(oci_cmd,config_hash)
        return cmd_ok,response_hash
    end

    def get_group_device_list(ent,group,dev_type=nil)
        oci_cmd = :GroupAccessDeviceGetListRequest
        config_hash = GroupAccessDeviceGetListRequest(ent,group,dev_type)
        table_header = 'accessDeviceTable'
        response_hash,cmd_ok = get_table_response(oci_cmd,table_header,config_hash)

        return cmd_ok,response_hash
    end

    def get_group_dn_list(ent,group)
    	oci_cmd = :GroupDnGetAssignmentListRequest
        table_header = "dnTable"
    	config_hash = GroupDnGetAssignmentListRequest()
    	config_hash[:serviceProviderId] = ent
    	config_hash[:groupId] = group

        #group_dn_list = @helpers.make_hoa
        expanded_tn_list = Array.new

        table_of_dns,cmd_ok = get_table_response(oci_cmd,table_header,config_hash)
        table_of_dns.each do |line|
            if line[:Phone_Numbers] =~ /\+1-(\d{10})\s-\s\+1-(\d{10})/
                start_tn = $1.to_i
                end_tn = $2.to_i
                while start_tn <= end_tn
                    tmp_hash = {
                        :Phone_Numbers => "+1-#{start_tn.to_s}", 
                        :Assigned_To => line[:Assigned_To],
                        :Department => line[:Department],
                        :Activated => line[:Activated],
                    }
                    expanded_tn_list.push(tmp_hash)
                    start_tn += 1
                end
            else
                expanded_tn_list.push(line)
            end
        end


        return cmd_ok,expanded_tn_list
    end

    def mod_add_group_device(dev_hash,dev_mgmt_creds=nil)
        oci_cmd = :GroupAccessDeviceAddRequest14
        if dev_mgmt_creds == nil
            config_hash = GroupAccessDeviceAddRequest14(false)
            config_hash.merge!(dev_hash)
        else
            config_hash = GroupAccessDeviceAddRequest14(true)
            config_hash.merge!(dev_hash)
            config_hash[:accessDeviceCredentials].merge!(dev_mgmt_creds)
        end
        response,cmd_ok = send_request(oci_cmd,config_hash)

        return cmd_ok,response
    end    

    def mod_group_announcement_file(ent=nil,group=nil,file=nil,new_file=nil,type=nil)
        oci_cmd = :GroupAnnouncementFileModifyRequest
        config_hash = send(oci_cmd)
        config_hash[:serviceProviderId] = ent
        config_hash[:groupId] = group
        config_hash[:announcementFileKey][:name] = file
        config_hash[:mediaFileType] = type unless type == nil
        config_hash[:newAnnouncementFileName] = new_file

        abort "#{__method__} for #{oci_cmd} Default Options: #{config_hash}" if group == nil

        response,cmd_ok = send_request(oci_cmd,config_hash)

        return cmd_ok,response
    end

end