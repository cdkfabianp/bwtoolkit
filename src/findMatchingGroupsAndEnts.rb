
class FindEntGroups

	def initialize(search_string)
		@search_string = search_string
	end

	def find_all_matches
		ent_groups = Hash.new
		ent_groups = $bw.get_groups_in_system
		b = Hash.new
		ent_groups.each do |ent,group_list|
			group_list.each {|group| b[group] = nil}
		end	
		puts "Total Ents found: #{ent_groups.length}"
		puts "Total Groups found: #{b.length}"

	end
end
