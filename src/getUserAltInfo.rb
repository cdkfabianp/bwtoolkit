
class GetAltNumberInfo
    def initialize(ent,group)
        @ent = ent
        @group = group
        @users_info = Hash.new
    end

	def get_users_and_alt_nums

		cmd_ok,user_list = $bw.get_users_in_group(@ent,@group)
		user_list.each do |user|
			@users_info[user] = Array.new
			puts "Checking user; #{user}"
			cmd_ok,config_hash = $bw.get_user_filtered_info(user)
			[:lastName,:firstName,:phoneNumber,:extension].each { |ele| @users_info[user].push(config_hash[ele]) }

			cmd_ok,svc_list = $bw.get_user_svc_list(user)
			@users_info[user].push(get_alt_assignment(svc_list,user))
		end
		print_users_info
	end

	def get_alt_assignment(svc_list,user)
        alt_nums_list = Array.new

		svc_list.each do |svc_hash|
			if svc_hash[:Service_Name] == "Alternate Numbers" and svc_hash[:Assigned] == "true"
				cmd_ok,config_hash = $bw.get_user_alternate_numbers(user)
		        
		        counter = 1
		        while counter < 11
		            alt_num_string = "alternateEntry" + counter.to_s.rjust(2,"0")
		            altNum = alt_num_string.to_sym
		            if config_hash.has_key?(altNum)
		            	if config_hash[altNum].has_key?(:phoneNumber)
		            		alt_nums_list.push(config_hash[altNum][:phoneNumber])
		            	elsif config_hash[altNum].has_key?(:extension)
		            		alt_nums_list.push(config_hash[altNum][:extension])
		            	else
		            		alt_nums_list.push("EMPTY")
		        		end
					else
			           alt_nums_list.push("EMPTY")	 		            		
		            end
		            counter += 1
		        end		
	        end		
		end		

        return alt_nums_list
	end
	
    def print_users_info
    	puts "made it here"
    	# puts @users_info
    	@users_info.each do |user,user_list|
    		# puts "#{user},#{user_list.join(",")}"
    		print user
    		user_list.each do |ele|
    			if ele.is_a?(Array)
    				print ",#{ele.join(",")}"
    			else
    				print ",#{ele}"
    			end
    		end
    		print "\n"
    	end
    end

end
