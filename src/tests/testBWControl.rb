require 'minitest/autorun'
require_relative '../bwcontrol/bwcontrol'
require_relative '../bwhelpers/helpers'
require_relative 'mockBWControl'
class TestBWControl < Minitest::Test

	def setup
		@bw = BWControl.new()
		@config_data_file = File.expand_path("../../../conf/bw_sys.conf",__FILE__)
		@config_data = '{
				"application_server": "oci_server",
				"my_bw_user": "test-user",
				"my_bw_pass": "abcd1234!",
				"debug": false,
				"debug_oci": false,
				"ok_to_mod": false
			}'		
		@helpers = Helpers.new
		@m = MockBWControl.new
	end

	def test_open_tcp_socket
		@json = @bw.get_app_config(@config_data_file)
		oci_server = @json[:application_server]
		assert_silent do 
			@bw.openTcpSocket(oci_server)
		end

		# Try testing failed connections to invalid application_server
		# oci_server = JSON.parse(@config_data, symbolize_names: true)
		# out,err = capture_io { @bw.openTcpSocket(oci_server[:application_server]) }
		# assert_match %r%Unable to connect to server:%, out
	end

	def test_bw_login
		out, err = capture_io {@bw.bw_login(@config_data_file)}
		assert_match %r%Login Successful%, out

		# out, err = capture_io {@bw.bw_login(@config_data)}
		# assert_match %r%.Unable to connect to server: oci_server%,out
	end

	def test_get_app_config

		expected_hash = @m.mock_get_app_config
		json = @bw.get_app_config(@config_data)
		assert_equal json,expected_hash,"#{__method__}: Failed to import json data into mathcing hash"


		json = @bw.get_app_config(@config_data_file)
		assert_equal json[:debug],expected_hash[:debug],"#{__method__}: Failed to read json from file and convert to json"
	end

	def test_getSignedPass
		pass = 'abcd1234!'
		nonce = "1458331757389"
		signed_pass = '6ceb0eba821c81c4135e04644d6481e8'
		digest = @bw.getSignedPass(pass,nonce)
		assert_equal digest,signed_pass

	end

	def test_build_request
		config_hash,expected_string = @m.mock_build_request(@config_data["my_bw_user"])

		xml = @bw.build_request("testocicmd",config_hash)
		assert_equal xml.gsub(/\s+/,''),expected_string.gsub(/\s+/,'')

	end

	def test_oci_table_to_array
		test_response,expected_responses = @m.mock_oci_table_to_array
		response_list = @bw.oci_table_to_array(test_response,'dnTable')
		assert_kind_of(Array,response_list,"#{__method__}: Did not return array")
		assert_equal response_list,expected_responses,"#{__method__}: Returned Response did not match expected response"
	end

	# def test_get_table_response
	# 	oci_cmd = :GroupDnGetAssignmentListRequest
	# 	config_hash = {serviceProviderId: "peteENT", groupId: "peteGRP"}
	# 	table_header = "dnTable"

	# 	@bw.bw_login(@config_data_file)
	# 	response_list,cmd_ok = @bw.get_table_response(oci_cmd,table_header,config_hash)

	# end

	def test_oci_rows_to_nested_hash
		test_response,expected_response = @m.mock_oci_rows_to_nested_hash
		response_hash = @bw.oci_build_nested_rows_hash(test_response)
		assert_kind_of(Hash,response_hash,"#{__method__}: Did not return Hash")
		assert_equal response_hash,expected_response,"Returned Hash did not match expected Hash"

		test_response,expected_response = @m.mock_oci_rows_to_nested_hash_2
		response_hash = @bw.oci_build_nested_rows_hash(test_response)
		assert_kind_of(Hash,response_hash,"#{__method__}: Did not return Hash")
		assert_equal response_hash,expected_response,"Returned Hash did not match expected Hash"		
	end

end
