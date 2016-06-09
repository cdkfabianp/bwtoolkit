#!/usr/bin/env ruby
#
STDOUT.sync = true
require_relative 'src/bwcontrol/bwsystem'
require_relative 'src/bwhelpers/userInput'
require_relative 'src/bwhelpers/helpers'
require_relative 'src/bwhelpers/bwhelpers'
require_relative 'src/bwhelpers/string'


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

def find_ent_group
	require_relative 'src/findMatchingGroupsAndEnts'
	s = FindEntGroups.new($options[:search_string])
	s.find_all_matches
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

def audit_messaging
	require_relative 'src/auditMessaging'
	svc_list = ["Voice Messaging User"]
	a = AuditMessaging.new(svc_list,$options[:user_type],$options[:vm_configed],$options[:filter_user])

	ent_groups = $bw_helper.get_groups_to_query
	ent_groups.each do |ent,group_list|
		a.get_assigned_users(ent,group_list)
	end

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
		ent_groups = $bw.get_groups_in_system
	elsif $options.has_key?(:group)
		ent_groups = {$options[:ent] => [$options[:group]]}
	else
		abort "Please specify -g <GROUPID> or -a ALL"
	end
	ent_groups.each do |ent,group_list|
	    group_list.each {|group| r.get_receptionist_users(ent,group)}
	end

end

def audit_standard
	require_relative 'src/auditStandard'
	r = AuditStandard.new($options[:task],$options[:user_type],$options[:removals])

	ent_groups = $bw_helper.get_groups_to_query
	ent_groups.each do |ent,group_list|
		r.get_standard_users(ent,group_list)
	end

end

def get_group_to_product_mapping
	require_relative 'src/getGroupToProductMapping'
	verbose = false
	if $options.has_key?(:verbose)
		if $options[:verbose] == "true"
			verbose = true
		end
	end

	z = GroupToProductMapping.new(verbose)
	ent_groups = $bw_helper.get_groups_to_query
	ent_groups.each do |ent,group_list|
		z.get_product_map(ent,group_list)
	end
end	

def get_poly_list
	require_relative 'src/getRegistrationByDeviceType'
	z = nil
	if $options.has_key?(:ent)
		z = GetRegByDeviceType.new($options[:all_poly],$options[:counts],$options[:ent],$options[:group])
	else
		z = GetRegByDeviceType.new($options[:all_poly],$options[:counts])
	end
	z.get_poly_list

end

def get_user_license
	require_relative 'src/getUserLicense'
	a = GetUserLicense.new
	a.get_license_info($options[:file],$options[:field_num])
end

def get_user_list_w_alt_nums
	require_relative 'src/getUserAltInfo'
	a = GetAltNumberInfo.new($options[:ent],$options[:group])
	a.get_users_and_alt_nums
end

def get_user_profile
	require_relative 'src/getUserProfile'
	a = GetProfileInfo.new($options[:user],$options[:fields])
	a.get_profile_info
end

def mod_user_config
	require_relative 'src/modifyUser'
	u = ModifyUser.new
	u.modify_user($options[:user],$options[:sub_cmd])
end



# Initialize Global Variables
$options = (UserInput.new.getOpts)
$helper = Helpers.new
$bw_helper = BWHelpers.new
$bw = BWSystem.new
$bw.bw_login(File.expand_path("../conf/bw_sys.conf",__FILE__))

# Get Enterprise if not provided by User BUT group is specified
if $options.has_key?(:group)
	$options[:ent] = $bw.get_ent_by_group_id($options[:group]) unless $options.has_key?(:ent)
	if $options[:ent] =~ /Could not find group:/
		puts "Could not find group: #{$options[:group]} in system"
		abort
	end
else
	$options[:ent] = nil
	$options[:group] = nil
end

# Send to specific method to process command
send($options[:cmd])




