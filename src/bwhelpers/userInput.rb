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
                find_ent_group:             Search for all entIds and groupIds that match string value              
                find_tn:                    Search system for TN and return configured Enterprise/Group/User/Activation status
                tn_list:                    List all TNs assigned to group
                reg_stats:                  Find all active devices in group based on registrations status and users assigend to device
                config_ucone:               Configure specified users for UCOne
                audit_rec:                  Find all users assigned receptionist users and whether they are monitoring any users
                audio_repo:                 Find all active audio files in Announcement Repository
                get_poly_list:              Find all Active Polycom Device Types in System 
                get_user_list_w_alt_nums:   Print list of all users in group including first two alternate numbers assigned
        "
        abort
    end

    def audio_repo(opts,options)
        opts.banner = "Usage: #{$PROGRAM_NAME} #{options[:cmd].to_s} [-g GROUP]"
        opts.on("-g", "--group GROUP", "Specify single Group") { |v| options[:group] = v}

        return opts,options
    end

    def audit_rec(opts,options)
        opts.banner = "Usage: #{$PROGRAM_NAME} #{options[:cmd].to_s} [-g GROUP]"
        opts.on("-g", "--group GROUP", "Specify single Group, use -a if you want all groups") { |v| options[:group] = v}
        opts.on("-a", "--all ALL_GROUPs", "Specify All Groups") { |v| options[:all_groups] = true}

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

    def get_user_list_w_alt_nums(opts,options)
        opts.banner = "Usage: #{$PROGRAM_NAME} #{options[:cmd].to_s}"
        opts.on("-g", "--group GROUP", "[groupID|ALL] Specify single Group within enterprise, use \"ALL\" to query all groups in system") {|v| options[:group] = v}              
        opts.on("-e", "--ent ENT", "Enterprise to query in the system") {|v| options[:ent] = v}               
        return opts,options
    end


end