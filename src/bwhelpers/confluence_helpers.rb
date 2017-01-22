require 'net/http'
require 'uri'

class CDKConfluence
	def initialize(config_data)
	    c = $bw.get_app_config(config_data)
	    @url = c[:confluence_url]
	    @user = c[:confluence_user]
	    @pass = c[:confluence_pass]
	end

	def fetch(uri_part, limit=10)
		raise ArgumentError, 'too many HTTP redirects' if limit == 0

		response = get_confluence_response(uri_part)
		case response
		when Net::HTTPSuccess then
			response
		when Net::HTTPRedirection then
			# puts "#{response.code}: #{response.message} to #{response['location']}"	
			location = response['location']
			warn "redirected to #{location}"
			fetch(location, limit - 1)
		else
			response.body
		end

		return response
	end

	def get_confluence_response(uri_part)
		response = nil
		uri = URI(uri_part)
		puts "URI HOSTNAME: #{uri.hostname}"
		Net::HTTP.start(uri.hostname,use_ssl: uri.scheme == 'https') do |http|
			request = Net::HTTP::Get.new(uri.request_uri)
			request.basic_auth $user,$pass
			response = http.request request

			# puts response
			# puts "MY BODY:\n #{response.body}"
		end

		return response
	end

	def create_new_child_page_w_content(post_body)
		response = nil
		uri = URI(@url+"content/")
		header = {'Content-Type' => 'application/json'}
		Net::HTTP.start(uri.hostname,use_ssl: uri.scheme == 'https') do |http|
			request = Net::HTTP::Post.new(uri.request_uri, header)
			request.body = post_body.to_json
			request.basic_auth @user,@pass
			response = http.request request
		end
		return response
	end

	# Take Array of Hashes and create an HTML formatted table
	def create_confluence_table_html(data)
		xm = Builder::XmlMarkup.new(:indent => 2)
		xm.table {
		  xm.tr { data[0].keys.each { |key| xm.th(key)}}
		  data.each { |row| xm.tr { row.values.each { |value| xm.td(value)}}}
		}

		return "#{xm}"		
	end

end
