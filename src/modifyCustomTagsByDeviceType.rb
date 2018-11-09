
class ModifyCustomTagsByDeviceType

	def initialize
		@device_search_list = 'Panasonic KX-TGP600'
	end

	def get_tags_by_device_type(ent)
		cmd_ok,groups = $bw.get_groups(ent)
		groups.each do |group|
			cmd_ok,custom_tags = $bw.get_group_custom_tags_for_device(ent,group,@device_search_list)
			found_tag = false
			custom_tags.each do |rule|
				if rule[:Tag_Name] == '%SERVER-TRANSPORT-1%'
					puts "#{ent},#{group},#{rule[:Tag_Name]},#{rule[:Tag_Value]},GOOD"
					found_tag = true
				elsif rule[:Tag_Name] == '%SERVER-TRANSPORT- 1%'
					print "#{ent},#{group},Extra_Space"
					found_tag = true
					cmd_ok,response = $bw.delete_group_custom_tag_for_device(ent,group,@device_search_list,rule[:Tag_Name])
					print ",DELETED"
					cmd_ok,response = $bw.add_group_custom_tag_for_device(ent,group,@device_search_list,'%SERVER-TRANSPORT-1%','1')
					print ",ADDED_GOOD\n"
				elsif rule[:Tag_Name] == '%SERVER-TRANSPORT%'
					print "#{ent},#{group},Missing_Line"
					found_tag = true
					cmd_ok,response = $bw.delete_group_custom_tag_for_device(ent,group,@device_search_list,rule[:Tag_Name])
					print ",DELETED"
					cmd_ok,response = $bw.add_group_custom_tag_for_device(ent,group,@device_search_list,'%SERVER-TRANSPORT-1%','1')
					print ",ADDED_GOOD\n"
				elsif custom_tags.length > 0
					print "#{ent},#{group},Missing_Rule"
					found_tag = true
					cmd_ok,response = $bw.add_group_custom_tag_for_device(ent,group,@device_search_list,'%SERVER-TRANSPORT-1%','1')
					print ",ADDED_GOOD\n"
				end
			end
			puts "#{ent},#{group},#{custom_tags.length},BAD" unless found_tag
		end
	end

end