#!/usr/bin/env ruby
#
STDOUT.sync = true
require 'pathname'
require_relative 'src/bwcontrol/bwsystem'
require_relative 'src/bwhelpers/userInput'
require_relative 'src/bwhelpers/helpers'
require_relative 'src/bwhelpers/bwhelpers'
require_relative 'src/bwhelpers/string'


# Test Method for Playing with BW OCI Calls
def bwtest
	require_relative 'src/bwtest'

	t = BWTest.new
	# t.print_group_list_of_ents($options[:user])
	t.get_user_by_ext($options[:user])
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
	tn_list = Array.new
	if File.exists?($options[:tn])
		tn_list = $bw_helper.get_users_from_file($options[:tn],0)
	else
		tn_list.push($options[:tn])
	end
	t.print_info(tn_list)
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

def tn_port_out
	require_relative 'src/tnPortOut'
	port = TNPortOut.new

	tn_list = $bw_helper.get_array_from_file($options[:file])
	if $options[:remove] == "true"
		# Remove TNs
		port.get_values(tn_list) {|cmd,config_hash| port.send(cmd, config_hash)}
	else
		# Print list of results of which tns will be removed
		port.get_values(tn_list) {|cmd,config_hash| puts "#{config_hash}" }

	end
end


def audit_service_pack
	require_relative 'src/auditLicensePack'
	a = AuditServicePack.new($options[:user_type],$options[:sp])

	ent_groups = $bw_helper.get_groups_to_query
	ent_groups.each do |ent,group_list|
		a.get_assigned_users(ent,group_list)
	end
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
	if $options.has_key?(:file) && File.exists?($options[:file])
		a.bulk_update_groups
	else
		a.update_name_with_slash($options[:ent],$options[:group])
	end


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

def get_ent_info
	require_relative 'src/getEntProfile'
	$admin_list = Hash.new(Hash.new)

	a = GetEntInfo.new

	# query = {ent: nil, group: Array.new}
 #  	ent_groups = $bw_helper.get_groups_to_query
 #  	ent_groups.each do |ent,group_list|
 #    	query = {ent: ent, group: group_list}
 #  	end

	a.get_ent_info($options[:sub_cmd])


end


#Run SNAP Report -s true -v true -a ALL
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

def get_user_list_w_alt_nums
	require_relative 'src/getUserAltInfo'
	a = GetAltNumberInfo.new($options[:ent],$options[:group])
	a.get_users_and_alt_nums
end

def get_user_profile
	require_relative 'src/getUserProfile'
	a = GetProfileInfo.new
	a.get_user_info($options[:sub_cmd])
end

def mod_user_config
	require_relative 'src/modifyUser'
	u = ModifyUser.new
	u.modify_user($options[:user],$options[:sub_cmd])
end

def validate_ent
	require_relative 'src/validateEnterprise'
	e = ValidateEnterprise.new

	ent_list = Array.new
	if $options.has_key?(:file) &&
		ent_list = $bw_helper.get_array_from_file($options[:file])
	elsif $options.has_key?(:ent)
		ent_list.push($options[:ent])
	end
	e.validate_ent(ent_list)

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
# Set group to nil if not provided
elsif
  $options.has_key?(:ent)
  $options[:group] = nil

# Set both ent and group to nil if neither provided
else
	$options[:ent] = nil
	$options[:group] = nil
end

# Send to specific method to process command
send($options[:cmd])




