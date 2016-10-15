require_relative 'bwent'

class BWSystem < BWEnt


    def find_tn_assignment(phone_number)
    	oci_cmd = :SystemDnGetUtilizationRequest14sp3
    	config_hash = SystemDnGetUtilizationRequest14sp3()
    	config_hash[:phoneNumber] = phone_number

        response_hash,cmd_ok = get_rows_response(oci_cmd,config_hash)
        return cmd_ok,response_hash
    end

    def find_device_by_mac(searchCriteria=nil,value=nil,mode='Equal To',isCaseInsensitive=true)
        oci_cmd = :SystemAccessDeviceGetAllRequest
        config_hash = send(oci_cmd,searchCriteria,value,mode,isCaseInsensitive)
        abort "#{__method__} for #{oci_cmd} Default Options: #{config_hash}" if searchCriteria == nil

        table_header = "accessDeviceTable"
        response_hash,cmd_ok = get_table_response(oci_cmd,table_header,config_hash)

        return cmd_ok,response_hash
    end

    def get_sys_poly_device_types
        search_string = [ 'Polycom Business Media VVX 1500',
                    'Polycom Business Media VVX 1501',
                    'Polycom Business Media VVX 400',
                    'Polycom Business Media VVX 410',
                    'Polycom Business Media VVX 500',
                    'Polycom Business Media VVX 600',
                    'Polycom Soundpoint IP 300',
                    'Polycom Soundpoint IP 320 330',
                    'Polycom Soundpoint IP 321 331',
                    'Polycom Soundpoint IP 4000',
                    'Polycom Soundpoint IP 430',
                    'Polycom Soundpoint IP 500',
                    'Polycom Soundpoint IP 5000',
                    'Polycom Soundpoint IP 550',
                    'Polycom Soundpoint IP 550 4X',
                    'Polycom Soundpoint IP 600',
                    'Polycom Soundpoint IP 6000',
                    'Polycom Soundpoint IP 6000 4x',
                    'Polycom Soundpoint IP 601',
                    'Polycom Soundpoint IP 650',
                    'Polycom Soundpoint IP 650 4X',
                    'Polycom Soundpoint IP 670',
                    'Polycom Soundpoint IP 670 4x',
                ]
        return search_string
    end
    
    def get_sys_ucone_device_types
        search_string = ['Business Communicator - Mobile',
                         'Business Communicator - PC',
                         'Business Communicator - Tablet',
                ]

        return search_string           
    end

    def get_groups_in_system
        oci_cmd = :GroupGetListInSystemRequest
        config_hash = send(oci_cmd)
        config_hash = {} #Empty config hash as we want to pass no search criteria
        ent_groups = Hash.new(Array.new)

        #Get all Enterprises (In case enterprise does not have any groups associated with it)
        cmd_ok,ents = get_ents
        ents.each {|ent| ent_groups[ent] = []}

        #Populate groups with Enterprises
        table_header = "groupTable"
        response_hash,cmd_ok = get_table_response(oci_cmd,table_header,config_hash)
        response_hash.each do |group_hash|
            if ent_groups.has_key?(group_hash[:Organization_Id])
                ent_groups[group_hash[:Organization_Id]].push(group_hash[:Group_Id])
            else
                ent_groups[group_hash[:Organization_Id]] = [group_hash[:Group_Id]]
            end
        end     
        return ent_groups
    end

end