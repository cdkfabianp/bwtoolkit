class GetEntInfo

	def initialize
	end

	def get_ent_info(sub_cmd,ele)
		@ele = ele
		send(sub_cmd)
	end

	def get_ent_group_admin_list
		$admin_list = Hash.new(Hash.new)

		cmd_ok,ent_admins = $bw.get_ent_admin_list(@ele[:ent])
		$admin_list[@ele[:ent]] = {ent_admin: ent_admins.length > 0, groups: Array.new}

		puts "#{@ele[:ent]},#{ent_admins.join(",")}"
		@ele[:group].each do |group|
			cmd_ok,group_admins = $bw.get_group_admin_list({ent: @ele[:ent], group: group})
			$admin_list[@ele[:ent]][:groups].push({group: group, group_admin: group_admins.length > 0})
			puts "#{@ele[:ent]},#{group},#{group_admins.join(",")}"
		end

	end

end
