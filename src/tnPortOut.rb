
class TNPortOut
	require_relative 'tn_search'

	def initialize
    # Confluence PageId for TN_Port_Out_Tracker
    # URL for page: https://confluence.cdk.com/display/IPNS/TN_Port_Out_Tracker
    @pageId = "124192824"

    # setup connection to confluence.cdk.com
    config_data = File.expand_path("../../conf/bw_sys.conf",__FILE__)
    @confluence = CDKConfluence.new(config_data)

    # Used to get TN info
		@t = TnSearch.new

    # Associate what OCI commands to run based on User Type and Location (AA/HG/User, Address/Alternate_Number)
		@tn_action = get_tn_hash

    # Keep track of TNs successfully removed from Users, Groups and Enterprises
    $tns_removed_ok = {
      ents: 0,
      groups: 0,
      users: 0
    }

    # Keep track of TNs successfully removed to update Confluence with
    @tn_config = Array.new

	end

  def update_confluence(body)
    curr_time = Time.now.strftime("%Y%m%d_%H-%M")
    uniq_page_name = "portout_cleanup_#{$options[:carrier]}_#{curr_time}"
    post_body = {
      type: "page",
      title: uniq_page_name,
      ancestors: [
        {id: @pageId}
      ],
      space: {
        key: "IPNS"
      },
      body: {
        storage: {
          value: @confluence.create_confluence_table_html(body),
          representation: "storage"
        }
      }
    }
    return @confluence.create_new_child_page_w_content(post_body)
  end

  def remove_tns(tns)
    # Associate TNs with Ent/Group information in Array of Hashs hash[ent][group] = tn_attrs_hash
    sort_tn_list(tns).each do |ent,group_hash|

      # Skip TN if it is not found in Broadworks
      next if ent == nil
      @ent_tns_removed = Array.new  
 
      group_hash.each do |group,group_tns_hash|
        @group_tns_removed = Array.new
        group_tns_hash.each do |tn,tn_attrs|

          # Determine where TN is configured (Level = AA/HG/User, Slot = Address/AltNum)
          level,slot = validate_tn_info(group,tn,tn_attrs)

          # config_hash contains info required to remove TN from Broadworks
          config_hash = {tn: tn, ent: ent, group: group, tn_attrs: tn_attrs, slot: slot}

          # dn_config is a reformated version of config_hash used to populate confluence
          # Keys are Strings instead of Symbols because Net/HTTP forces symbols as attributes instead of values in HTML
          # Yes, probably better ways of doing this...
          dn_config = create_dn_config({tn: tn, ent: ent, group: group, tn_attrs: tn_attrs, slot: slot})

          # Update Master List of TNs with DN specific results
          @tn_config.push(dn_config)  

          # Remove TN from User/AA/HG
          send(@tn_action[level][:oci_cmd], config_hash, dn_config) if $options[:remove] == "true"                 

          # Print TN info
          puts dn_config             
        end
        remove_from_group(ent,group) if $options[:remove] == "true"
      end
      remove_from_ent(ent) if $options[:remove] == "true"
    end
    
    # Clear tn_config so we don't push configs to confluence if we are only running audit (IE -r false)
    @tn_config = Array.new unless $options[:remove] == "true"

    # Update confluence with TNs removed from System.  Note - if TNs fail to removed from group/ent they will still populate in this list
    # TNs failed to be removed from users WILL NOT be populated in this list
    # So...needs some more work to validate Group/Ent TNs were actually removed
    confluence_update_response = update_confluence(@tn_config) if @tn_config.length > 1   

  end

  def create_dn_config(c)
    dn_config = Hash.new
    dn_config = {
      "tn" => c[:tn],
      "ent" => c[:ent],
      "group" => c[:group],
      "slot" => c[:slot].to_s,
      "userId" => "Unassigned",
      "userType" => "NA",
      "isGroupCallingLineId" => "NA",
      "isActivated" => "NA",
      # "removed" => "false"
    }
    if c[:tn_attrs] != {}
      dn_config["userId"] = c[:tn_attrs][:userId] if c[:tn_attrs].has_key?(:userId)
      dn_config["userType"] = c[:tn_attrs][:userType] if c[:tn_attrs].has_key?(:userType)
      dn_config["isGroupCallingLineId"] =  c[:tn_attrs][:isGroupCallingLineId] if c[:tn_attrs].has_key?(:isGroupCallingLineId)
      dn_config["isActivated"] = c[:tn_attrs][:isActivated] if c[:tn_attrs].has_key?(:isActivated)
    end
    
    return dn_config
  end

	def validate_tn_info(group,tn,tn_attrs)
		level = ""
		slot = ""
		if tn_attrs[:isGroupCallingLineId] == "true"
			#tn cannot be deleted from group until new tn is assigned as gCLID, so skip for now
			level = :gclid
		elsif group == "__NO_GROUP__"
			#tn is assigned to enterprise but not group - ok to delete
			level = :ent
		elsif tn_attrs.has_key?(:userId)
			#tn is assigned to user, find out where (address, alt_num, etc)
			level,slot = validate_user_info(tn,tn_attrs)
		else
			#tn is assigned to group but not user
			level = :group
		end
		return level,slot
	end

	def validate_user_info(tn,tn_attrs)
		level = ""
		user_type = tn_attrs[:userType]
		slot = $bw.get_user_tn_assignment(tn,tn_attrs[:userId])
		if user_type == 'Auto Attendant'
			level = :aa
			level = :aa_alt unless slot == 'address'
		elsif user_type == 'Hunt Group'
			level = :hg
			level = :hg_alt unless slot == 'address'
		else
			level = :user
			level = :user_alt unless slot == 'address'
		end
		return level,slot
	end

  def sort_tn_list(tns)
    tn_hash = $helper.make_hohoh
    tn_info = @t.tn_search(tns)
    tn_info.each do |tn,i|
      puts "My TN: #{tn}   i: #{i}"
      if i.has_key?(:groupId)
        tn_hash[i.delete(:serviceProviderId)][i.delete(:groupId)][tn] = i
      else
        tn_hash[i.delete(:serviceProviderId)]["__NO_GROUP__"][tn] = i
      end
    end

    return tn_hash
  end

  def get_tn_hash
    {
        ent: {
            oci_cmd: :collect_from_ent,
            result: "IS ONLY ASSIGNED TO ENT"
        },
        group: {
            oci_cmd: :collect_group_tns,
            result: "IS ONLY ASSIGNED TO GROUP"
        },
        aa: {
            oci_cmd: :remove_from_aa,
            result: "IS AN AutoAttendant"
        },
        aa_alt: {
            oci_cmd: :remove_from_alt_user,
            result: "IS AN AutoAttendant - Alternate Number"
        },
        hg: {
            oci_cmd: :remove_from_hg,
            result: "IS A HUNT GROUP"
        },
        hg_alt: {
            oci_cmd: :remove_from_alt_user,
            result: "IS A HUNT GROUP - Alternate Number"
        },
        user: {
            oci_cmd: :remove_from_user,
            result: "IS A USER"
        },
        user_alt: {
            oci_cmd: :remove_from_alt_user,
            result: "IS A USER - AlternateNumber"
        },
        gclid: {
            oci_cmd: :is_group_clid,
            result: "IS GROUP CLID, SKIPPING"
        }
    }
  end

  def is_group_clid(config_hash,dn_config)
    puts "Removed #{@tn_config.pop} because it is group CLID, skipping"
    return "is group CLID, skipping"
  end

	def remove_from_user(config_hash,dn_config)
		userId, nil_tn_config = remove_from(config_hash)
    cmd_ok, response = $bw.mod_user_profile({userId: userId, phoneNumber: nil_tn_config})
    cleanup_remove(config_hash,cmd_ok,dn_config)

    return cmd_ok
	end

	def remove_from_hg(config_hash,dn_config)
    svc_id,nil_tn_config = remove_from(config_hash)
    cmd_ok, response = $bw.mod_group_hg_profile({serviceUserId: svc_id, serviceInstanceProfile: {phoneNumber: nil_tn_config}})
    cleanup_remove(config_hash,cmd_ok,dn_config)

    return cmd_ok
  end

	def remove_from_aa(config_hash,dn_config)
    svc_id,nil_tn_config = remove_from(config_hash)
    cmd_ok, response = $bw.mod_group_aa_profile({serviceUserId: svc_id, serviceInstanceProfile: {phoneNumber: nil_tn_config}})
    cleanup_remove(config_hash,cmd_ok,dn_config)

    return cmd_ok
  end

  def remove_from_alt_user(config_hash,dn_config)
    id,nil_tn_config = remove_from(config_hash)
    cmd_ok,response = $bw.mod_user_alt_num({userId: id, config_hash[:slot].to_sym => {phoneNumber: nil_tn_config}})
    cleanup_remove(config_hash,cmd_ok,dn_config)

    return cmd_ok
  end

  def remove_from(config_hash)
    id = config_hash[:tn_attrs][:userId]
    nil_tn_config = {attr: {'xsi:nil' => "true"}}

    # print "#{config_hash[:ent]},#{config_hash[:group]},#{config_hash[:tn]},REMOVING from #{id},"
    return id,nil_tn_config
  end

  def cleanup_remove(config_hash,cmd_ok,dn_config)
    puts "#{__method__} : CONFIG_HAHS: #{config_hash} | DN_CONFIG: #{dn_config}"
    if cmd_ok == true
      @group_tns_removed.push(config_hash[:tn])
      $tns_removed_ok[:users] += 1
    else
      puts "Failed to remove TN from user: #{config_hash[:ent]}/#{config_hash[:group]}/#{config_hash[:tn]}}"

      #If removing TN from User/AA/HG failed, remove it from the master list so it doesn't get pushed to confluence
      puts "Removing #{@tn_config.pop} from List"
    end
  end

	def collect_group_tns(config_hash,dn_config)
		# puts "removing #{config_hash[:tn]} from group: #{config_hash[:group]}"
    @group_tns_removed.push(config_hash[:tn])
  end

  def remove_from_group(ent,group)
    # puts "#{__method__}, GROUP TN LIST:\n#{@group_tns_removed}"
    cmd_ok,response = $bw.mod_group_unassign_dn(ent,group,@group_tns_removed)
    if cmd_ok == true
      @ent_tns_removed += @group_tns_removed
      $tns_removed_ok[:groups] += @group_tns_removed.length
    else
      puts "Failed to remove TNs from group: #{ent}/#{group} - #{response}" 
    end
  end

  def collect_from_ent(config_hash,dn_config)
    # puts "removing #{config_hash[:tn]} from ent: #{config_hash[:ent]}"
    @ent_tns_removed.push(config_hash[:tn])
  end

	def remove_from_ent(ent)
    # puts "#{__method__}, ENT TN LIST:\n#{@ent_tns_removed}"
    cmd_ok,response = $bw.mod_ent_delete_dn(ent,@ent_tns_removed)
    if cmd_ok == true
      $tns_removed_ok[:ents] += @ent_tns_removed.length
    else
      puts "Failed to remove TNs from #{ent} - #{response}\n"
    end
	end
end
