class BWTest

	def get_svc_list
		user = 'peteGRP-user002'
		cmd_ok,response = $bw.get_user_svc_list(user)
		puts response
	end

    def add_ucone_services
    	user = 'peteGRP-user002'
        cmd_ok = false
		ucone_service_list = [
					   "Client License 18",
                       "Client License 17", 
                       "BroadTouch Business Communicator Tablet - Video",
                       "Shared Call Appearance",
                       "Shared Call Appearance 5",
                       "Integrated IMP",
                       "BroadWorks Anywhere",
                       "In-Call Service Activation",
                    ]
		ucone_service_list = 'Client License 17'                    
        cmd_ok,result = $bw.mod_user_assign_serivce(user,ucone_service_list)
        puts "ADD_SERVICES: #{user}: Added Services: #{cmd_ok}"
    
        return cmd_ok
    end

    def get_user_profile
    	user = 'peteGRP-user002'
    	cmd_ok,response = $bw.get_user_filtered_info(user)
    	puts "CMD_OK: #{cmd_ok} and result: #{response}"

    end
end
