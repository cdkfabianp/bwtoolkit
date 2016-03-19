require 'digest/sha1'
require 'digest/md5'
require 'socket'
require 'builder'
require 'rexml/document'
require 'json'
require_relative 'bwoci_config'
include REXML

class BWControl < BWOci
    def initialize
    end

    def bw_login(config_data,server=nil,user=nil,pass=nil,debug=false,debug_oci=false,debug_time=false)
        c = get_app_config(config_data)
        if server == nil
            server = c[:application_server]
            user = c[:my_bw_user]
            pass = c[:my_bw_pass]
            debug = c[:debug]
            debug_oci = c[:debug_oci]
            debug_time = c[:debug_time]
        end

        @debug_verbose = debug_oci
        @tcp_client = openTcpSocket(server)
        @debug_time = debug_time
        @helpers = Helpers.new
        @session_id = get_session_id
        get_logged_in(user,pass)

    end

    def send_request(oci_cmd, config_hash)
        request = build_request(oci_cmd,config_hash)
        print_response(request) if @debug_verbose

        start_time = Time.now

        @tcp_client.send( "#{request}",0 )
        response,cmd_ok = get_response
        
        end_time = Time.now
        puts "OCI: #{args} #{end_time - start_time}" if @debug_time == true

        return response,cmd_ok
    end

    def get_response
        response = ""
        while line = @tcp_client.gets
            response += line
            break if line.include? "/BroadsoftDocument>"
        end
        print_response(response) if @debug_verbose
        parse_response = REXML::Document.new(response)
        error_check,cmd_ok = check_response(parse_response)
        response = error_check if cmd_ok == false
        puts "#{self.class} : #{__method__} | response --(#{response})--" if cmd_ok == false && @debug_verbose == true
        return response,cmd_ok
    end

    def check_response(parse_response)
        cmd_ok = true
        error_check = "No Error"
        if parse_response.elements["//command"].attributes["type"] == "Error" || parse_response.elements["//command"].attributes["type"] == "Warning"
            error_check = parse_response.elements["//command/summaryEnglish"].text
            cmd_ok = false
        end    
        return error_check,cmd_ok
    end

    def print_response(response)
        puts "==============="
        puts response
        puts "==============="
    end

    def openTcpSocket(server)
        begin
            @tcp_client = TCPSocket.new( server, 2208)
        rescue
            puts "Unable to connect to server: #{server}"
            exit
        end
    end

    def closeTcpSocket(tcp_client)
        @tcp_client.close
    end

    #If Response is a list (same element name with different values)
    def oci_list_to_array(response,ele_name)
        response_array = Array.new
        parse_response = REXML::Document.new(response)
        parse_response.elements.each("//command/"+ele_name) do |ele|
            parse_line = REXML::Document.new("#{ele}")

            #If list is nested within elements pull values from the last element in ele_name
            if ele_name =~ /\/(\w+)$/
                sub_ele_name = $1
                response_array << parse_line.elements["//#{sub_ele_name}"].text
            else
                response_array << parse_line.elements["//#{ele_name}"].text
            end
        end

        return response_array
    end

    #If Response is a collection of unique attributes, this will return a hash of <attribute>: <value>
    def oci_rows_to_hash(response)
        response_hash = Hash.new
        table_array = Array.new
        table_name = ""
        parse_response = REXML::Document.new(response)

        response_hash = Hash.new
        parse_response.elements["//command/"].each do |ele|
            name = ele.name
            value = parse_response.elements['//'+name].text
            if name =~ /\w+Table/
                table_array =  oci_table_to_array(response,name)
                table_name = name
            end
            response_hash[name.to_sym] = value

            #If response contained table elements add array of these elements into hash with key == <tableName>
            response_hash[table_name.to_sym] = table_array unless table_array.empty?
        end
        return response_hash

    end
    #WARNING THE BELOW def is UGGGLY
    #Believe this now works for both nested and non-nested elements (at least up to two nest).  Need more testing to confirm
    # This has been replaced with oci_build_nested_rows_hash
    # def old_oci_rows_to_nested_hash(response)
    #     # response_hash = @helpers.make_hoh
    #     response_hash = Hash.new(Hash.new)
    #     parse_response = REXML::Document.new(response)
    #     response_hash = Hash.new
    #     parse_response.elements['//command'].each do |ele|
    #         name = ele.name
    #         if parse_response.elements['//'+name+'/'].text == nil
    #             sub_hash = Hash.new
    #             parse_response.elements['//'+name+'/'].each do |sub_ele|
    #                 sub_name = sub_ele.name
    #                 if parse_response.elements['//'+sub_name+'/'].text == nil
    #                     response_hash[sub_name.to_sym]= Hash.new
    #                     parse_response.elements['//'+sub_name+'/'].each do |sub_ele2|
    #                         sub_name2 = sub_ele2.name
    #                         response_hash[sub_name.to_sym][sub_name2.to_sym] = parse_response.elements['//'+sub_name+'/'+sub_name2].text
    #                     end
    #                 else
    #                     sub_hash[sub_name.to_sym] = parse_response.elements['//'+name+'/'+sub_name].text
    #                     response_hash[name.to_sym] = sub_hash
    #                 end
    #             end

    #         else
    #             value = parse_response.elements['//'+name].text
    #             response_hash[name.to_sym] = value

    #         end
    #     end
    #     return response_hash

    # end

    def oci_build_nested_rows_hash(response)
        response_hash = Hash.new(Hash.new)
        array_of_hashes = Array.new
        ele_name = 'command' 
        parse_response = REXML::Document.new(response)
        response_hash = oci_rows_to_nested_hash(parse_response,ele_name,response_hash)

        return response_hash
    end

    def oci_rows_to_nested_hash(parse_response,name,hash_key=nil)
        response_hash = Hash.new
        parse_response.elements['//'+name+'/'].each do |ele|
            name = ele.name             
            if parse_response.elements['//'+name+'/'].text == nil
                hash_key = name.to_sym
                response_hash[hash_key] = oci_rows_to_nested_hash(ele,name)
            else
                value = parse_response.elements['//'+name].text
                response_hash[name.to_sym] = value
            end
        end

        return response_hash
    end

    #If Response is a table return array of hashes
    def oci_table_to_array(response,table_header)
        response_hash = Hash.new
        list_of_responses = Array.new
        values = Array.new

        ##Get Column Headings
        parse_response = REXML::Document.new(response)
        parse_response.elements.each("//command/#{table_header}/colHeading") do |ele|
            parse_line = REXML::Document.new("#{ele}")
            n = parse_line.elements["//colHeading"].text
            name = n.to_s
            name.tr!(" ","_")
            name.tr!("/","-")
            response_hash[name.to_sym] = 0
        end

        ##Get Each Set of Values
        ##ADDED table_header to account for responses with multiple table headers 
        ##  (for example:GroupServiceGetAuthorizationListRequest"
        #   parse_response.elements.each("//row/col") do |col| <-old parse
        #
        parse_response.elements.each("//#{table_header}/row/col") do |col|
            parse_line = REXML::Document.new("#{col}")
            v = parse_line.elements["//col"].text
            ##Added text value for empty columns 
            v = '__NIL__' if v == nil
            values << v.to_s
        end

        ##Assign each set of values to the matching colHeader and assign this hash to an array
        until values.empty? == true
            final_response = Hash.new
            response_hash.each do |k,v|
                final_response[k] = values.shift
            end
            list_of_responses << final_response
        end
        return list_of_responses
    end

    def get_list_response(*args)
        response_list = Array.new
        oci_cmd = args.shift
        ele_name = args.shift

        response,cmd_ok = send_request(oci_cmd,*args)
        if cmd_ok == true
            response_list = oci_list_to_array(response,ele_name)
        end

        return response_list,cmd_ok
    end

    def get_table_response(*args)
        list_of_response = Array.new
        oci_cmd = args.shift
        table_header = args.shift
        response,cmd_ok = send_request(oci_cmd,*args)
        if cmd_ok == true
            list_of_responses = oci_table_to_array(response,table_header)
        else
            puts "-->#{response}" if @debug == true
        end
        return list_of_responses,cmd_ok
    end

    def get_rows_response(*args)
        response_hash = Hash.new
        oci_cmd = args.shift
        response,cmd_ok = send_request(oci_cmd,*args)
        if cmd_ok == true
            response_hash = oci_rows_to_hash(response)
        else
            puts "-->#{response}" if @debug == true
        end
        return response_hash,cmd_ok
    end

    def get_nested_rows_response(*args)
        response_hash = Hash.new
        oci_cmd = args.shift
        response,cmd_ok = send_request(oci_cmd,*args)
        if cmd_ok == true
            response_hash = oci_build_nested_rows_hash(response)
        else
            puts "-->#{response}" if @debug == true
        end
        
        return response_hash,cmd_ok
    end

    # Get Logged in
    def get_logged_in(user,pass)
        is_logged_in = login(user,pass)
        abort "Login Failed" if is_logged_in == false
        puts "Login Successful"

    end

    def get_app_config(file_name)
        json_data = nil
        File.exist?(file_name) ? json_data = File.read(file_name) : json_data =  file_name

        return JSON.parse(json_data, :symbolize_names => true)
    end    

    def login(user,pass)
        is_logged_in = false

        ##Phase 1 Authentication

        response,cmd_ok = send_request(:AuthenticationRequest,{userId: user})
        parse_response = REXML::Document.new(response)

        nonce = parse_response.elements["//command/nonce"].text

        ##Phase 2 Authentication
        digest = getSignedPass(pass,nonce)
        puts "Error creating encrypted password" unless digest.length == 32

        response,cmd_ok = send_request(:LoginRequest14sp4,{userId: user,signedPassword: digest})
        is_logged_in = true if cmd_ok == true

        return is_logged_in
    end

    def getSignedPass(pass,nonce)
        sha1_pass = Digest::SHA1.hexdigest(pass)
        md5 = Digest::MD5.new
        md5.update nonce
        md5.update ":"
        md5.update sha1_pass
        digest = md5.hexdigest

        return digest
    end

    def get_session_id
        session_id = "localhost,1535442458,1393632344857"
    end

	# Create XML 
	def build_request(oci_cmd,config_hash)
		xml = Builder::XmlMarkup.new( :indent => 2)
		xml.instruct! :xml, :encoding => "ISO-8859-1"
	 	xml.BroadsoftDocument :protocol => "OCI", :xmlns => "C", :'xmlns:xsi' => "http://www.w3.org/2001/XMLSchema-instance" do |a|
	 		a.sessionId(@session_id , :xmlns => "")
	 		a.command :'xsi:type' => "#{oci_cmd}" , :xmlns => "" do |b|
	 		    b = build_xml(b,config_hash)
            end
	 	end
	end

	def build_xml(x,hash)
		hash.each do |key,val|
			if val.is_a?(Hash)
				x.tag! key do |y|
					build_xml(y,val)
				end
            elsif val.is_a?(Array)
                val.each {|ele| x.tag! key,ele}
			else
		 		x.tag! key,val
		 	end
		end
		return x
	end				


end
