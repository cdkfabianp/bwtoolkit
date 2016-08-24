
class TNPortOut
	require_relative 'tn_search'

	def initialize
		@t = TnSearch.new
		@ok_to_mod = false
		@tn_action = get_tn_hash
	end

	def remove(tns)
		tns_status = $helper.make_hohoa
		sort_tn_list(tns).each do |ent,group_hash|
			group_hash.each do |group,group_tns_hash|
				puts "#{ent}/#{group}"
				group_tns_hash.each do |tn,tn_attrs|
					level,slot = validate_tn_info(group,tn,tn_attrs) 
					puts "tn: #{tn} #{@tn_action[level][:result]}"
					if $options[:remove] == "true" && level != :gclid
						send(@tn_action[level][:oci_cmd],{ent: ent, group: group, tn_attrs: tn_attrs, slot: slot}) 
					end
				end
			end
		end
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
		userType = tn_attrs[:userType]
		slot = $bw.get_user_tn_assignment(tn,tn_attrs[:userId])
		if userType == "Auto Attendant"
			level = :aa
			level = :aa_alt unless slot == "address"
		elsif userType == "Hunt Group"
			level = :hg
			level = :hg_alt unless slot == "address"
		else
			level = :user
			level = :user_alt unless slot == "address"
		end
		return level,slot
	end


	def remove_from_user(config_hash)
		puts "removing tn from #{config_hash[:tn_attrs][:userId]}"
	end

	def remove_from_alt_user(config_hash)
		puts "removing tn from #{config_hash[:tn_attrs][:userId]} at slot: #{config_hash[:slot]}"
	end

	def remove_from_hg(config_hash)
		puts "removing tn from #{config_hash[:tn_attrs][:userId]}"

	end

	def remove_from_alt_hg(config_hash)
		puts "removing tn from #{config_hash[:tn_attrs][:userId]} at slot: #{config_hash[:slot]}"		
	end

	def remove_from_aa(config_hash)
		puts "removing tn from #{config_hash[:tn_attrs][:userId]}"		
	end

	def remove_from_alt_aa(config_hash)
		puts "removing tn from #{config_hash[:tn_attrs][:userId]} at slot: #{config_hash[:slot]}"		
	end

	def remove_from_group(config_hash)
		puts "removing tn from group: #{config_hash[:group]}"
		# cmd_ok,response = $bw.mod_group_unassign_dn(ent,group,tns,@ok_to_mod)
	end

	def remove_from_ent(config_hash)
		puts "removing from ent: #{config_hash[:ent]}"
	end


	def sort_tn_list(tns)
		tn_hash = $helper.make_hohoh
		tn_info = @t.tn_search(tns)
		tn_info.each do |tn,i|
			# puts "My TN: #{tn}   i: #{i}"
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
				oci_cmd: :remove_from_ent, 
				result: "IS ONLY ASSIGNED TO ENT"
			},
			group: {
				oci_cmd: :remove_from_group, 
				result: "IS ONLY ASSIGNED TO GROUP"
			},
			aa: {
				oci_cmd: :remove_from_aa, 
				result: "IS AN AutoAttendant"
			},
			aa_alt: {
				oci_cmd: :remove_from_alt_aa, 
				result: "IS AN AutoAttendant - Alternate Number"
			},
			hg: {
				oci_cmd: :remove_from_hg, 
				result: "IS A HUNT GROUP"
			},
			hg_alt: {
				oci_cmd: :remove_from_alt_hg, 
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
				result: "IS GROUP CLID, SKIPPING"
			}
		}
	end

end

	# def validate_tn_for_removal(group,tn,tn_attrs)
	# 	alt_num_info = Hash.new
	# 	print "#{tn}"
	# 	if tn_attrs[:isGroupCallingLineId] == "true"
	# 		#tn cannot be deleted from group until new tn is assigned as gCLID, so skip for now
	# 		puts "IS GROUP CLID"
	# 	elsif group == "__NO_GROUP__"
	# 		#tn is assigned to enterprise but not group - ok to delete
	# 		puts "IS ONLY ASSIGNED TO ENT"
	# 	elsif tn_attrs.has_key?(:userId)
	# 		#tn is assigned to user, find out where (address, alt_num, etc)
			
	# 		puts "IS #{tn_attrs[:userType]} and tn is at: #{tn_location}"
	# 	else
	# 		#tn is assigned to group but not user
	# 		puts "IS ONLY ASSIGNED TO GROUP"
	# 	end
	# end

# REMOVE FROM HG USER
# 2016.08.24 13:44:01:522 PDT | Audit | write77059 | pfabian | System | GroupHuntGroupModifyInstanceRequest
# 	<?xml version="1.0" encoding="ISO-8859-1"?>
# <BroadsoftDocument protocol="OCI" xmlns="C">
#   <userId xmlns="">pfabian</userId>
#   <command xsi:type="GroupHuntGroupModifyInstanceRequest" xmlns="" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
#     <serviceUserId>callParkHG-3001@as.lab1.adpvoice.com</serviceUserId>
#     <serviceInstanceProfile>
#       <phoneNumber xsi:nil="true"/>
#       <extension>0569</extension>
#       <sipAliasList xsi:nil="true"/>
#       <publicUserIdentity xsi:nil="true"/>
#     </serviceInstanceProfile>
#   </command>
# </BroadsoftDocument>

# IF TN IS ASSIGNED TO USER
# 2016.08.17 10:24:16:228 PDT | Audit | write75194 | pfabian | System | UserModifyRequest17Sp4
# 	<?xml version="1.0" encoding="ISO-8859-1"?>
# <BroadsoftDocument protocol="OCI" xmlns="C">
#   <userId xmlns="">pfabian</userId>
#   <command xsi:type="UserModifyRequest17sp4" xmlns="" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
#     <userId>faxbackuser@as.lab1.adpvoice.com</userId>
#     <phoneNumber xsi:nil="true"/>
#     <extension>1319</extension>
#     <sipAliasList xsi:nil="true"/>
#     <endpoint>
#       <trunkAddressing>
#         <trunkGroupDeviceEndpoint>
#           <name>12345678_FaxConnect_TG</name>
#           <linePort>5032051207@as.lab1.adpvoice.com</linePort>
#           <contactList xsi:nil="true"/>
#         </trunkGroupDeviceEndpoint>
#         <enterpriseTrunkName xsi:nil="true"/>
#         <alternateTrunkIdentity xsi:nil="true"/>
#       </trunkAddressing>
#     </endpoint>
#   </command>
# </BroadsoftDocument>


# IF TN IS GROUP CLID
# 2016.08.17 10:30:43:029 PDT | Audit | write75198 | pfabian | System | GroupModifyRequest
# 	<?xml version="1.0" encoding="ISO-8859-1"?>
# <BroadsoftDocument protocol="OCI" xmlns="C">
#   <userId xmlns="">pfabian</userId>
#   <command xsi:type="GroupModifyRequest" xmlns="" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
#     <serviceProviderId>peteENT</serviceProviderId>
#     <groupId>peteGRP</groupId>
#     <defaultDomain>as.lab1.adpvoice.com</defaultDomain>
#     <userLimit>25</userLimit>
#     <groupName>Petes Test Group</groupName>
#     <callingLineIdName>Pete's Group</callingLineIdName>
#     <callingLineIdPhoneNumber>2763284206</callingLineIdPhoneNumber>
#     <timeZone>America/Los_Angeles</timeZone>
#     <locationDialingCode xsi:nil="true"/>
#     <contact>
#       <contactName xsi:nil="true"/>
#       <contactNumber xsi:nil="true"/>
#       <contactEmail xsi:nil="true"/>
#     </contact>
#     <address>
#       <addressLine1>2525 SW 1st Ave</addressLine1>
#       <addressLine2>Suite 450</addressLine2>
#       <city>Portland</city>
#       <stateOrProvince>Oregon</stateOrProvince>
#       <zipOrPostalCode>97201</zipOrPostalCode>
#       <country>USA</country>
#     </address>
#   </command>
# </BroadsoftDocument>

# UNASSIGN A SINGLE NUMBER
# 2016.08.17 10:31:51:849 PDT | Audit | write75199 | pfabian | System | GroupDnUnassignListRequest
# 	<?xml version="1.0" encoding="ISO-8859-1"?>
# <BroadsoftDocument protocol="OCI" xmlns="C">
#   <userId xmlns="">pfabian</userId>
#   <command xsi:type="GroupDnUnassignListRequest" xmlns="" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
#     <serviceProviderId>peteENT</serviceProviderId>
#     <groupId>peteGRP</groupId>
#     <phoneNumber>+1-5032051319</phoneNumber>
#   </command>
# </BroadsoftDocument>

# UNASSIGN FROM GROUP MULTIPLE NUMBERS
# 2016.08.17 10:33:02:426 PDT | Audit | write75200 | pfabian | System | GroupDnUnassignListRequest
# 	<?xml version="1.0" encoding="ISO-8859-1"?>
# <BroadsoftDocument protocol="OCI" xmlns="C">
#   <userId xmlns="">pfabian</userId>
#   <command xsi:type="GroupDnUnassignListRequest" xmlns="" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
#     <serviceProviderId>peteENT</serviceProviderId>
#     <groupId>peteGRP</groupId>
#     <phoneNumber>+1-8552079136</phoneNumber>
#     <phoneNumber>+1-8882761040</phoneNumber>
#   </command>
# </BroadsoftDocument>

# REMOVE FROM ENTERPRISE
# 2016.08.17 10:34:17:437 PDT | Audit | write75201 | pfabian | System | ServiceProviderDnDeleteListRequest
# 	<?xml version="1.0" encoding="ISO-8859-1"?>
# <BroadsoftDocument protocol="OCI" xmlns="C">
#   <userId xmlns="">pfabian</userId>
#   <command xsi:type="ServiceProviderDnDeleteListRequest" xmlns="" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
#     <serviceProviderId>peteENT</serviceProviderId>
#     <phoneNumber>+1-5032051319</phoneNumber>
#   </command>
# </BroadsoftDocument>