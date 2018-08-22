class UserInput
    require 'optparse'

    def getOpts 
        options = Hash.new
        
        usage() if ARGV.empty?

        options[:cmd] = ARGV.shift.to_sym  unless ARGV.empty?

        opt_parser = OptionParser.new do |opts|
            ARGV << '-h' if ARGV.empty?
            opts,options = send(options[:cmd],opts,options)
            opts.on_tail("-h", "--help","Usage Help") do
                puts "#{opts}\n"
                exit 1
            end
        end
        opt_parser.parse!
        return options
    end

    def usage
        puts "
            Usage: #{$PROGRAM_NAME} [COMMAND] [OPTIONS]

              Valid Commands:
                find_ent_group:                 Search for all entIds and groupIds that match string value              
                find_tn:                        Search system for TN and return configured Enterprise/Group/User/Activation status
                tn_list:                        List all TNs assigned to group
                tn_port_out:                    Remove ported-out numbers from Broadworks
                reg_stats:                      Find all active devices in group based on registrations status and users assigend to device
                config_ucone:                   Configure specified users for UCOne
                audit_messaging:                Find all users assigned messaging and whether the service can be removed
                audit_rec:                      Find all users assigned receptionist users and whether they are monitoring any users
                audio_repo:                     Find all active audio files in Announcement Repository
                audit_service_pack:             Find all active users assigned to a specific service pack
                audit_site:                     Audit site for CFB and Call Waiting settings on each user
                audit_sp_to_device:             Get List of Users and their Identity / Device Profile Type and Registration Info                
                get_cc_info:                    Get CallCenter Info
                get_communicator_info:          Get User-Agent Info about UC-One Devices
                get_ent_info:                   Get Info About Ents and their Groups
                get_group_to_product_mapping:   Attempt to determine what product type the group is (Hosted, CallConnect, CTC, Small Business, etc)
                get_poly_list:                  Find all Active Polycom Device Types in System 
                get_user_list_w_alt_nums:       Print list of all users in group including first two alternate numbers assigned
                get_user_profile:               Print specified atributes of USER from User Profile
                update_trunk_cap:               Update Trunk capacity for all trunk groups and groups under specific enterprise
                mod_user_config:                Modify basic user configuration
                validate_ent:                   Validate that specified Enterprise is valid in the system (likelness that is is in use)
        "
        abort
    end

    def audit_messaging(opts,options)
        opts.banner = "Usage: #{$PROGRAM_NAME} #{options[:cmd].to_s} [-g GROUP]"
        opts.on("-g", "--group GROUP", "Specify single Group, use -a if you want all groups") { |v| options[:group] = v}
        opts.on("-a", "--all ALL_GROUPs", "Specify All Groups") { |v| options[:all_groups] = true}
        opts.on("-t", "--type USER_TYPE", "Specify User type: Hosted_User,Virtual_User,Trunk_User") { |v| options[:user_type] = v }
        opts.on("-c", "--config USER_IS_CONFIG", "Include users with advanced vm config configured") { |v| options[:vm_configed] = v }        
        opts.on("-u", "--user_filter USER", "Specify part or all of userId to filter on") { |v| options[:filter_user] = v }
        opts.on("-m", "--method AUDIT_METHOD", "[audit|recover] Audit without modifing or Recover licenses") { |v| options[:task] = v }
        opts.on("-r", "--max_remove MAX_REMOVE", "Number of users to remove license from") { |v| options[:removals] = v }        

        return opts,options
    end
    
    def audio_repo(opts,options)
        opts.banner = "Usage: #{$PROGRAM_NAME} #{options[:cmd].to_s} [-g GROUP]"
        opts.on("-g", "--group GROUP", "Specify single Group") { |v| options[:group] = v}
        opts.on("-f", "--file FILE", "[optional] Specify list of groups to audit") { |v| options[:file] = v}

        return opts,options
    end

    def audit_rec(opts,options)
        opts.banner = "Usage: #{$PROGRAM_NAME} #{options[:cmd].to_s} [-g GROUP]"
        opts.on("-g", "--group GROUP", "Specify single Group, use -a if you want all groups") { |v| options[:group] = v}
        opts.on("-a", "--all ALL_GROUPs", "Specify All Groups") { |v| options[:all_groups] = true}

        return opts,options
    end

    def audit_service_pack(opts,options)
        opts.banner = "Usage: #{$PROGRAM_NAME} #{options[:cmd].to_s} [-g GROUP]"
        opts.on("-g", "--group GROUP", "Specify single Group, use -a if you want all groups") { |v| options[:group] = v }
        opts.on("-a", "--all ALL_GROUPs", "Specify All Groups") { |v| options[:all_groups] = true }
        opts.on("-t", "--type USER_TYPE", "Specify User type: Hosted_User,Virtual_User,Trunk_User") { |v| options[:user_type] = v }
        opts.on("-s", "--sp SVC_PACK", "Specify service pack to query, examples: vupp1, standard") { |v| options[:sp] = v }        
        return opts,options        
    end

    def audit_site(opts,options)
        opts.banner = "Usage: #{$PROGRAM_NAME} #{options[:cmd].to_s} [-g GROUP]"
        opts.on("-e", "--ent ENTERPRISE", "Specify single Enterprsie,") { |v| options[:ent] = v }        
        return opts,options  
    end

    def audit_sp_to_device(opts,options)
        opts.banner = "Usage: #{$PROGRAM_NAME} #{options[:cmd].to_s} [-e ENT] [-g GROUP]"
        opts.on("-e", "--ent ENTERPRISE", "Specify single Enterprsie,") { |v| options[:ent] = v }        
        opts.on("-g", "--group GROUP", "Specify single Group") { |v| options[:group] = v }
        return opts,options  
    end

    def config_ucone(opts,options)
        opts.banner = "Usage: #{$PROGRAM_NAME} #{options[:cmd].to_s} [-g GROUP] [-u USERS_LIST] [-v VOIP_DOMAIN] [-m OK_TO_MOD]"
        opts.on("-u", "--users_list USERS_LIST", "Specify users to configure for UCOne\n\n") {|v| options[:users_list] = v}
        opts.on("-g", "--group GROUP", "Specify single Group within enterprise (Script will derive Enterprise)") { |v| options[:group] = v}
        opts.on("-d", "--domain DOMAIN", "Specify voip domain for SCA lineport domain") { |v| options[:voip_domain] = v}
        opts.on("-m", "--ok_to_mod MOD", "Enable modification of broadworks to enable UC-One") {|v| options[:ok_to_mod] = v}
        return opts,options
    end

    def find_ent_group(opts,options)
        opts.banner = "Usage: #{$PROGRAM_NAME} #{options[:cmd].to_s} [-s SEARCH_STRING]"
        opts.on("-s", "--search_string SEARCH", "Search for all groups and ent IDs that match search string") {|v| options[:search_string] = v}        
        return opts,options        
    end

    def find_tn(opts,options)
        opts.banner = "Usage: #{$PROGRAM_NAME} #{options[:cmd].to_s} [-t TELEPHONE_NUMBER]"
        opts.on("-t", "--telephone_num TN", "Specifiy single Telephone Number or File containing list of TNs.") { |v| options[:tn] = v }
        return opts,options
    end

    def get_communicator_info(opts,options)
        opts.banner = "Usage: #{$PROGRAM_NAME} #{options[:cmd].to_s}"
        opts.on("-a", "--group GROUP", "Search all groups in system") {|v| options[:all_groups] = v}              
        opts.on("-g", "--group GROUP", "[groupID|ALL] Specify single Group within enterprise, use \"ALL\" to query all groups in system") {|v| options[:group] = v}      
        opts.on("-s", "--sum", "[true|false] Print Summary of Counts (total configed / total reg) if true, Otherwise print Registration info for all registered devices") { |v| options[:counts] = v}    

        return opts,options
    end

    def get_cc_info(opts,options)
        opts.banner = "Usage: #{$PROGRAM_NAME} #{options[:cmd].to_s}"
        opts.on("-g", "--group GROUP", "[groupID|ALL] Specify single Group within enterprise, use \"ALL\" to query all groups in system") {|v| options[:group] = v}              
        opts.on("-e", "--ent ENT", "Enterprise to query in the system") {|v| options[:ent] = v}               
        return opts,options
    end
    
    def get_ent_info(opts,options)
        opts.banner = "Usage: #{$PROGRAM_NAME} #{options[:cmd].to_s} [-g GROUP|-a ALL] [options]"
        opts.on("-x", "--cmd CMD", "Audit command to run to query user") {|v| options[:sub_cmd] = v}
        opts.on("-g", "--group GROUP", "Specify single Group, use -a if you want all groups") { |v| options[:group] = v}
        opts.on("-e", "--ent ENTERPRISE", "[optional] Specify single Ent, use -a if you want all enterprises") { |v| options[:ent] = v}
        opts.on("-a", "--all ALL_GROUPs", "Specify All Groups") { |v| options[:all_groups] = true}
        opts.on("-f", "--file FILE", "Specify file with list of Enterprises to query") {|v| options[:file] = v}        
        return opts,options
    end

    def get_group_to_product_mapping(opts,options)
        opts.banner = "Usage: #{$PROGRAM_NAME} #{options[:cmd].to_s} [-g GROUP]"
        opts.on("-g", "--group GROUP", "Specify single Group, use -a if you want all groups") { |v| options[:group] = v}
        opts.on("-a", "--all ALL_GROUPs", "Specify All Groups") { |v| options[:all_groups] = true}
        opts.on("-o", "--orca ORCAWAVE INFO", "Print specific details to import into ORCAWAVE") { |v| options[:orca] = v}
        opts.on("-v", "--verbose VERBOSE INFO", "Get additional enterprise and group detail") { |v| options[:verbose] = v}
        opts.on("-s", "--snap SNAP BILLING INFO", "Print specific details to export customer data to SNAP Recordings") { |v| options[:snap] = v}
        opts.on("-t", "--timezone GROUP TIME ZONE", "Include Group Time Zone info in print out") {|v| options[:vgroup] = v}

        return opts,options
    end

    def get_poly_list(opts,options)
        opts.banner = "Usage: #{$PROGRAM_NAME} #{options[:cmd].to_s}"
        opts.on("-a", "--all", "[true|false] Get a list of all Polycom Devices or just 501/601s") { |v| options[:all_poly] = v}
        opts.on("-g", "--group GROUP", "[groupID|ALL] Specify single Group within enterprise, use \"ALL\" to query all groups in system") {|v| options[:group] = v}      
        opts.on("-s", "--sum", "[true|false] Print Summary of Counts (total configed / total reg) if true, Otherwise print Registration info for all registered devices") { |v| options[:counts] = v}
        return opts,options
    end

    def reg_stats(opts,options)
        opts.banner = "Usage: #{$PROGRAM_NAME} #{options[:cmd].to_s} [-g GROUP]"
        opts.on("-g", "--group GROUP", "Specify group to find active devices") {|v| options[:group] = v}
        return opts,options
    end

    def bwtest(opts,options)
        opts.banner = "Usage: #{$PROGRAM_NAME} #{options[:cmd].to_s}"
        opts.on("-u", "--user USER", "Specify user to find") {|v| options[:user] = v}
        return opts,options
    end

    def tn_list(opts,options)
        opts.banner = "Usage: #{$PROGRAM_NAME} #{options[:cmd].to_s} [-g GROUP]"
        opts.on("-g", "--group GROUP", "Specify group to retrieve TN List from") {|v| options[:group] = v}
        return opts,options
    end

    def tn_port_out(opts,options)
        opts.banner = "Usage: #{$PROGRAM_NAME} #{options[:cmd].to_s}"
        opts.on("-r", "--remove REMOVE", "[true|false] Set to true to remove TNs from Broadworks.  False to run audit") {|v| options[:remove] = v}
        opts.on("-f", "--file FILE", "Specify file with list of TNs to remove (One tn per line)") {|v| options[:file] = v}
        opts.on("-c", "--carrier CARRIER", "Specify if TNs were ported out of either verizon or level3.  Valid options are VZN or L3") {|v| options[:carrier] = v}

        return opts,options
    end


    def get_user_list_w_alt_nums(opts,options)
        opts.banner = "Usage: #{$PROGRAM_NAME} #{options[:cmd].to_s}"
        opts.on("-g", "--group GROUP", "[groupID|ALL] Specify single Group within enterprise, use \"ALL\" to query all groups in system") {|v| options[:group] = v}              
        opts.on("-e", "--ent ENT", "Enterprise to query in the system") {|v| options[:ent] = v}               
        return opts,options
    end

    def get_user_profile(opts,options)
        opts.banner = "Usage: #{$PROGRAM_NAME} #{options[:cmd].to_s}"
        opts.on("-f", "--file FILE", "List of Users to audit in the system") {|v| options[:file] = v}   
        opts.on("-n", "--field FIELD_NUM", "Column Number (0 index) of location of UserID in File") {|v| options[:field_num] = v}        
        opts.on("-q", "--query QUERY", "Query Fields to Return") {|v| options[:query] = v}
        opts.on("-x", "--cmd CMD", "Audit command to run to query user") {|v| options[:sub_cmd] = v}
        opts.on("-g", "--group GROUP", "Specify single Group, use -a if you want all groups") { |v| options[:group] = v}
        opts.on("-a", "--all ALL_GROUPs", "Specify All Groups") { |v| options[:all_groups] = true}
        opts.on("-u", "--user_filter USER", "Specify part or all of userId to filter on") { |v| options[:filter_user] = v }
        return opts,options        
    end

    def update_trunk_cap(opts,options)
        opts.on("-x", "--cmd CMD", "valid options are parse_btlu and reclaim_trunks") {|v| options[:sub_cmd] = v}        
        opts.on("-e", "--ent ENTERPRISE", "Required if -x reclaim_trunks.  Specify single Ent, use -a if you want all enterprises") { |v| options[:ent] = v}
        opts.on("-c", "--cap CAPACITY", "Required if -x reclaim_trunks.  Specify new trunk capacity to be assigend to all trunks and groups under enterprise -e") { |v| options[:cap] = v}
        opts.on("-f", "--file FILE", "Required if -x parse_btlu.  This is the local location of the BTLU report as copied from AS1 at: /var/broadworks/reports/btlu/") {|v| options[:file] = v}
        return opts,options
    end
    
    def mod_user_config(opts,options)
        opts.banner = "Usage: #{$PROGRAM_NAME} #{options[:cmd].to_s}"
        opts.on("-u", "--user USER", "User or List of Users to modify in the system") {|v| options[:user] = v}   
        opts.on("-x", "--cmd CMD", "Script command to run to modify user") {|v| options[:sub_cmd] = v}
        return opts,options
    end

    def validate_ent(opts,options)
        opts.banner = "Usage: #{$PROGRAM_NAME} #{options[:cmd].to_s} [-g GROUP|-a ALL] [options]"
        opts.on("-g", "--group GROUP", "Specify single Group, use -a if you want all enterprises") { |v| options[:group] = v}
        opts.on("-e", "--ent ENTERPRISE", "[optional] Specify single Ent, use -a if you want all enterprises") { |v| options[:ent] = v}
        opts.on("-f", "--file FILE", "List of Enterprises to audit in the system") {|v| options[:file] = v}
        opts.on("-a", "--all ALL_ENTS", "Specify All Enterprises") { |v| options[:all_groups] = true}
        return opts,options
    end


end