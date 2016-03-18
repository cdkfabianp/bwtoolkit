require_relative 'bwent'

class BWSystem < BWEnt


    def find_tn_assignment(phone_number)
    	oci_cmd = :SystemDnGetUtilizationRequest14sp3
    	config_hash = SystemDnGetUtilizationRequest14sp3()
    	config_hash[:phoneNumber] = phone_number

        response_hash,cmd_ok = get_rows_response(oci_cmd,config_hash)
        return cmd_ok,response_hash
    end

    def get_sys_ucone_device_types
        search_string = ['Business Communicator - Mobile',
                         'Business Communicator - PC',
                         'Business Communicator - Tablet',
                ]

        return search_string           
    end


end