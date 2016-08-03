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

    def get_admin_list
      puts $bw.get_group_admin_list({ent: "peteENT", group: "peteGRP"})
    end

    def get_aa_config
      group = "76150432"
      ent = "25124801"

      group = "peteGRP"
      ent = "peteENT"

      cmd_ok,response = $bw.get_group_aa_list(ent,group)
      puts response
      response.each do |aa|
        aa_name = aa[:Service_User_Id]
        cmd_ok,svc_list = $bw.get_user_clean_svc_list(aa_name)
        cmd_ok,aa_config = $bw.get_group_aa_config(aa_name)
        puts ">>>>>>>>>> #{aa_name} <<<<<<<<<<<<<<<<<<<<"
        puts "AA CONFIG"
        puts aa_config
        puts "------------------------------------------"
        puts "AA SVC LIST"
        puts svc_list
        puts "------------------------------------------"
        puts "=========================================="
      end
    end

    def get_hg_config
      # require 'json'

      group = "76150432"
      ent = "25124801"

      group = "peteGRP"
      ent = "peteENT"

      cmd_ok,response = $bw.get_group_hg_list(ent,group)
      puts response

      response.each do |hg|
        hg_id = hg[:Service_User_Id]
        cmd_ok,svc_list = $bw.get_user_clean_svc_list(hg_id)
        cmd_ok,hg_config = $bw.get_group_hg_svc_config(hg_id)
        puts ">>>>>>>>>> #{hg_id} <<<<<<<<<<<<<<<<<<<<"
        puts "HG CONFIG IN JSON"
        puts hg_config.to_json
        puts "------------------------------------------"
        puts "HG AGENT LIST"
        puts hg_config[:agentUserTable]
        puts "------------------------------------------"        
        puts "HG SVC LIST"
        puts svc_list
        puts "------------------------------------------"
        puts "=========================================="
      end
    end



end
