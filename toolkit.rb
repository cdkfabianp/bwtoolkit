#!/usr/bin/env ruby
#
STDOUT.sync = true
require_relative 'src/bwcontrol/bwsystem'
require_relative 'src/bwhelpers/userInput'
require_relative 'src/bwhelpers/helpers'


# Test Method for Playing with BW OCI Calls
def bwtest
	require_relative 'src/bwtest'

	t = BWTest.new
	t.get_user_profile
end

# Configure specified users in group for UCOne
def config_ucone
	require_relative 'src/configUCOne'

	#Get specific config variables from file 
	# file = File.expand_path("../conf/configUCOne.conf", __FILE__)
	# app_config = $bw.get_app_config(file)
	$ok_to_mod = false
	$ok_to_mod = true if $options.has_key?(:ok_to_mod) && $options[:ok_to_mod] == "true"

	#Configure UCOne 
	uc1 = ConfigUCOne.new($options[:ent],$options[:group],$options[:users_list],$options[:voip_domain])
	uc1.config_ucone_users
end

# Find TN in system
def find_tn
	require_relative 'src/tn_search'

	t = TnSearch.new
	t.tn_search($options[:tn])
end

# Find all active devices in group based on active registrations and configured users
def reg_stats
	require_relative 'src/bwDeviceAudit'

    d = BwDeviceAudit.new($options[:ent],$options[:group])
    d.get_reg_info_by_group
end


# List all TNs in a group
def tn_list
	require_relative 'src/tn_search'

	#List TNs in Group
	t = TnSearch.new
    t.group_tn_list($options[:ent],$options[:group])
end

def audio_repo
	require_relative 'src/auditAnnouncementRepo'

	a = AuditAnnouncementRepo.new
	a.update_name_with_slash($options[:ent],$options[:group])

end

def audit_rec
	require_relative 'src/auditReceptionist'
	r = AuditReceptionist.new
	r.print_header()

	ent_groups = Hash.new(Array.new)
	if $options.has_key?(:all_groups)
		cmd_ok,ent_groups = $bw.get_group_list
	elsif $options.has_key?(:group)
		ent_groups = {$options[:ent] => [$options[:group]]}
	else
		abort "Please specify -g <GROUPID> or -a ALL"
	end
	ent_groups.each do |ent,group_list|
	    group_list.each {|group| r.get_receptionist_users(ent,group)}
	end

end

# def get_501_list
# 	require_relative 'src/getRegistrationByDeviceType'
# 	z = GetRegByDeviceType.new($options[:all_poly])
# 	z.get_poly_list

# end

def get_poly_list
	require_relative 'src/getRegistrationByDeviceType'
	z = GetRegByDeviceType.new($options[:all_poly],$options[:counts])
	z.get_poly_list

end

# Initialize Global Variables
$options = (UserInput.new.getOpts)
$helper = Helpers.new
$bw = BWSystem.new
$bw.bw_login(File.expand_path("../conf/bw_sys.conf",__FILE__))

# Get Enterprise if not provided by User BUT group is specified
if $options.has_key?(:group)
	$options[:ent] = $bw.get_ent_by_group_id($options[:group]) unless $options.has_key?(:ent)
	if $options[:ent] =~ /Could not find group:/
		puts "Could not find group: #{$options[:group]} in system"
		abort
	end
end

# Send to specific method to process command
send($options[:cmd])




