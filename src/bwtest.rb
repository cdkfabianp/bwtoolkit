class BWTest

    def print_group_list_of_ents(ent_list)
      ents = $bw_helper.get_array_from_file(ent_list)
      ents.each do |ent|
        # puts "ENT: #{ent}"
        cmd_ok,group_list = $bw.get_groups(ent)
        puts group_list
      end
    end

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

    def active_group_intercept
        cmd_ok,response = $bw.mod_group_intercept("peteENT","peteGRP",true)
        puts "My response: \n#{response}"
        puts "\nCMD OK? #{cmd_ok}"
    end

    def get_mac_in_sys(mac)
      cmd_ok,response = $bw.find_device_by_mac(:searchCriteriaDeviceMACAddress,mac)
      puts "Got mac info:\n#{response}"    
      return response
    end

    def get_user_by_ext(mac)
      response = get_mac_in_sys(mac)
      ext = '6109'
      cmd_ok,users = $bw.get_users_in_group(response[0][:Service_Provider_Id],response[0][:Group_Id],:searchCriteriaExtension,ext)
      puts "found user: #{users[0]} for extension: #{ext}"
    end

    def audit_bwdevice_macs(bwdevice_list)
      bwdevices = File.open(bwdevice_list) or die "Unable to find file: #{bwdevice_list}"
      bwdevices.each_line do |bwdevice|
        bwdevice.strip!
        mac = nil
        mac = $1 if bwdevice =~ /^BWDEVICE_(\w*)\.cfg/          
        cmd_ok,response = $bw.find_device_by_mac(:searchCriteriaDeviceMACAddress,mac) unless mac == nil
        print "#{bwdevice},#{mac},"
        if cmd_ok == false
          puts "ERROR: #{response}"
        elsif response == []
          puts "DEVICE_NOT_FOUND"         
        elsif response.length > 1
          puts "MULTIPLE_RESPONSES"                              
        else
          puts "#{response[0][:Service_Provider_Id]},#{response[0][:Group_Id]}"
        end
      end
    end

    def audit_ftp_users(ftp_user_list)
      ftpusers = File.open(ftp_user_list) or die "Unable to find file: #{ftp_user_list}"
      ftpusers.each_line do |ftp_user|
        ftp_user.strip!
        group_cmf = $1 if ftp_user =~ /^ftp?(\d*)/i
        cmd_ok,group_exists,ent_id,response = $bw.group_exists?(group_cmf)
        puts "#{ftp_user},#{group_cmf},#{group_exists},#{ent_id}"
      end
    end

end
