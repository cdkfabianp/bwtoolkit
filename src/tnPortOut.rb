
class TNPortOut
	require_relative 'tn_search'

	def initialize
		@t = TnSearch.new
		@ok_to_mod = false
	end

	def remove(tns)
		tns_status = $helper.make_hohoa
		sort_tn_list(tns).each do |ent,group_hash|
			group_hash.each do |group,group_tns_hash|
				puts "#{ent}/#{group}"
				group_tns_hash.each do |tn,tn_attrs|
					validate_tn_for_removal(group,tn,tn_attrs)
				end
			end
		end
	end

	def validate_tn_for_removal(group,tn,tn_attrs)
		tn_info = ""
		alt_num_info = Hash.new
		if tn_attrs[:isGroupCallingLineId] == "true"
			#tn cannot be deleted from group until new tn is assigned as gCLID, so skip for now
			tn_info = "IS GROUP CLID"
		elsif group == "__NO_GROUP__"
			#tn is assigned to enterprise but not group - ok to delete
			tn_info = "IS ONLY ASSIGNED TO ENT"
		elsif tn_attrs.has_key?(:userId)
			#tn is assigned to user, find out where (address, alt_num, etc)
			tn_location = $bw.get_user_tn_assignment(tn,tn_attrs[:userId])
			tn_info = "IS #{tn_attrs[:userType]} and tn is at: #{tn_location}"
		else
			#tn is assigned to group but not user
			tn_info = "IS ONLY ASSIGNED TO GROUP"
		end

		puts "  #{tn} #{tn_info}"
	end


	# def remove_from_user(tn_list)
	# 	#tn_list includes TNs assigned to user via alternate numbers and address, but removes only from address (IE alt numbers would cause address to be removed)
	# 	tns = Array.new
	# 	tn_list.each do |tn_info|
	# 		tn_info.each do |tn,tn_data|
	# 			if tn_data[:isGroupCallingLineId] == "true"
	# 				puts "#{tn} - Skipping is Group Calling Line ID"
	# 			elsif tn_data.has_key?(:userId)
	# 				cmd_ok,response = $bw.mod_user_remove_tn(tn_data[:userId]) 
	# 				puts "REMOVED TN = CMD_OK: #{cmd_ok} with response #{response}"
	# 				tns.push(tn)					
	# 			else
	# 				puts "#{tn} - Assigned to Group but not user"
	# 				tns.push(tn)
	# 			end
	# 		end
	# 	end
	# 	return tns
	# end

	def remove_from_group(ent,group,tns)
		cmd_ok,response = $bw.mod_group_unassign_dn(ent,group,tns,@ok_to_mod)
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

end




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