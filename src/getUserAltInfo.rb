
class GetAltNumberInfo
    def initialize(ent,group)
        @ent = ent
        @group = group
        @users_info = Hash.new
    end

	def get_users_and_alt_nums

		cmd_ok,user_list = $bw.get_users_in_group(@ent,@group)
		counter = 0
		user_list.each do |user|
			@users_info[user] = Array.new
			puts "Checking user; #{user}"
			cmd_ok,config_hash = $bw.get_user_filtered_info(user)
			[:lastName,:firstName,:phoneNumber,:extension].each { |ele| @users_info[user].push(config_hash[ele]) }

			cmd_ok,svc_list = $bw.get_user_svc_list(user)
			get_alt_assignment(svc_list,user)
			counter += 1
		end
		print_users_info
	end

	def get_alt_assignment(svc_list,user)
		svc_list.each do |svc_hash|
			if svc_hash[:Service_Name] == "Alternate Numbers" and svc_hash[:Assigned] == "true"
				cmd_ok,config_hash = $bw.get_user_alternate_numbers(user)
		        
		        counter = 1
		        while counter < 11
		            alt_num_string = "alternateEntry" + counter.to_s.rjust(2,"0")
		            altNum = alt_num_string.to_sym
		            if config_hash.has_key?(altNum)
		            	if config_hash[altNum].has_key?(:phoneNumber)
		            		@users_info[user].push(config_hash[altNum][:phoneNumber])
		            	elsif config_hash[altNum].has_key?(:extension)
		            		@users_info[user].push(config_hash[altNum][:extension])
		            	else
		            		@users_info[user].push("EMPTY")
		        		end
					else
	            		@users_info[user].push("EMPTY")

		            end
		            counter += 1
		        end		
	        end		
		end		
	end

    def print_users_info
    	puts "======================================================================================================"
    	puts " notes: printing all alternate number slots, if altnum slot has phone number print, or else print extension, or print none if neither phone number or extension is available"
    	puts "        print nothing if user is not assigned Alternate Numbers"
    	puts "------------------------------------------------------------------------------------------------------"
    	puts "Print User info for #{@ent}/#{@group}"
    	puts "======================================================================================================"


    	puts "UserId,LastName,FirstName,PhoneNumber,Extension,Alt1,Alt2,Alt3,Alt4,Alt5,Alt6,Alt7,Alt8,Alt9,Alt10"

    	@users_info.each { |user,user_list| puts "#{user},#{user_list.join(",")}" }
    end

end
