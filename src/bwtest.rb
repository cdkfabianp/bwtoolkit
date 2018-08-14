class BWTest

    def test_dnd
      $bw.get_user_dnd_status("4803857059")
    end

    def find_groups_by_name
      cmd_ok,groups = $bw.get_groups_by_name("Massage Envy",'Contains')
      puts "Found Groups:\n#{groups}"
      puts "Found Total Groups: #{groups.length}"
    end

    def print_group_list_of_ents(ent_list)
      ents = $bw_helper.get_array_from_file(ent_list)
      ents.each do |ent|
        # puts "ENT: #{ent}"
        cmd_ok,group_list = $bw.get_groups(ent)
        puts group_list
      end
    end

    def get_recording_customers(tn_list)
      require_relative 'tn_search'
      t = TnSearch.new

      ent_groups = Hash.new(Array.new)
      groups_counter = 0
      tn_list = $bw_helper.get_array_from_file(tn_list)
      tn_list.each do |tn|
        tn_info = t.tn_search([tn])
        ent = tn_info[tn][:serviceProviderId]
        group = tn_info[tn][:groupId]
        puts "#{ent},#{group}"

        if ent_groups.has_key?(ent)        
          if ent_groups[ent].include?(group)
          else
            ent_groups[ent].push(group)
            groups_counter += 1
          end
        else
          ent_groups[ent] = Array.new
        end
      end
      
      puts "=========================================="
      puts "Total Enterprises: #{ent_groups.keys.length}"
      puts "Total Groups: #{groups_counter}"


    end

  	def get_svc_list
  		user = '7079352501'
  		cmd_ok,response = $bw.get_user_svc_pack_list(user)
      puts "My login level: #{$login_type}"
      response.each do |sp|
          puts sp if sp[:Assigned] == "true"
      end
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
      
      #Initialize TN Search Tool
      require_relative 'tn_search'
      t = TnSearch.new


      ftpusers = File.open(ftp_user_list) or die "Unable to find file: #{ftp_user_list}"
      ftpusers.each_line do |ftp_user|
        ftp_user.strip!
        ftp_cmf = nil

        if ftp_user =~ /(\d{10})/
          ftp_tn  = $1
        elsif ftp_user =~ /^ftp?(\d{2,})/i
          ftp_cmf = $1 
        elsif ftp_user =~ /(76\d{6})/
          ftp_cmf = $1
        end

        # puts "FTP_CMF: #{ftp_cmf}, TN: #{ftp_tn}"
        group_exists = false
        result = {
          ftp_user: ftp_user,
          ftp_cmf: nil,
          ftp_tn: nil,
          group_exists: nil,
          ent_exists: nil,
          tn_exists: nil
        }
        result[:ftp_cmf] = ftp_cmf
        result[:ftp_tn] = ftp_tn
        if ftp_cmf
          cmd_ok,group_exists,ent_id,response = $bw.group_exists?(ftp_cmf)
          result[:group_exists] = group_exists
        end

        if ftp_cmf && group_exists == false
          cmd_ok,ent_exists,ent_name,response_hash = $bw.ent_exists?(ftp_cmf)
          result[:ent_exists] = ent_exists
        end

        if ftp_tn
          tn_info = t.tn_search([ftp_tn])
          if tn_info[ftp_tn][:serviceProviderId]
            result[:tn_exists] = true 
          else
            result[:tn_exists] = false
          end
        end

        puts result.values.join(",")
      end
    end

    def test_get_ents
      response = $bw.get_ents

      puts response
    end

end
