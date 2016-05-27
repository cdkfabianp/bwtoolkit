
class BWHelpers

	def get_groups_to_query()
		ent_groups = Hash.new(Array.new)
		if $options.has_key?(:all_groups)
			ent_groups = $bw.get_groups_in_system
		elsif $options.has_key?(:group)
			ent_groups = {$options[:ent] => [$options[:group]]}
		else
			abort "Please specify -g <GROUPID> or -a ALL"
		end

		return ent_groups
	end	


end
