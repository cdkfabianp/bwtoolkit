#!/usr/bin/env ruby
#

class TnSearch

    def usage(error)
        puts <<-PARAGRAPH
#{error}

usage #{$PROGRAM_NAME} <search_tn>

    options:
        <search_tn>           [required] specify the TN you wish to find in broadsoft.
                                         TN must be either 10 digits, 11 digits, or e164

    examples:
        #{0} +14805551234
        #{$0} 16025551234
        #{$0} 6235551234
PARAGRAPH
    abort

    end

    def normalize_tn(tn)
        e164_number = false
        invalid_input = false
        extra_digits = ""
        # puts "searching for (#{tn})"
        if tn =~ /(^[2-9]\d{9})(\d*)/ #|| tn =~ /^1([2-9]\d{9})(\d*)/
            e164_number = "+1#{$1}"
            extra_digits = $2
        elsif /^\+1([2-9]\d{9})(\d*)/ =~ tn
            # puts "Matched +1"
            e164_number = "+1#{$1}"
            extra_digits = $2
        end
        # puts "found e164: #{e164_number}"
        return e164_number
    end

    def tn_search(tns)
        # tns = Array.new
        # tns << tn_number
        tn_info = Hash.new(Hash.new)
        tns.each do |tn|  
            e164_number = normalize_tn(tn)
            if e164_number
                cmd_ok,response_hash = $bw.find_tn_assignment(e164_number)
                # response_hash = {} if cmd_ok == false || e164_number == false
            else
                response_hash =  {result: "invalid number format"}
            end
            tn_info[tn] = response_hash
        end
        
        return tn_info
    end

    def print_info(tns)
        puts tn_search(tns)
    end

    def print_marchex_info(tns)
        tn_info = tn_search(tns)
        print_string = "#{t},"
        if t.length > 0
            print_string += "#{info[:serviceProviderId]},#{info[:groupId]},#{info[:isActivated]}"
        else
            print_string += "NOT_FOUND"
        end

        return print_string
    end



    def group_tn_list(ent,group)
        cmd_ok,response_hash = $bw.get_group_dn_list(ent,group)
        puts response_hash
    end
end