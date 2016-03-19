require 'minitest/autorun'
require_relative '../bwcontrol/bwcontrol'
require_relative '../bwhelpers/helpers'
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

		expected_hash = {
			application_server: 'oci_server',
			my_bw_user: 'test-user',
			my_bw_pass: 'abcd1234!',
			debug: false,
			debug_oci: false,
			ok_to_mod: false
		}
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
		config_hash = {
			userId: @config_data["my_bw_user"],
			oci_ele1: "ele1",
			oci_ele2: {
				oci_sub_ele1: "sub_ele1",
				oci_sub_ele2: ["arr_ele2", "arr_ele3", "arr_ele4"]
			},
			oci_ele3: "ele3"
		}
		expected_string = 
		'<?xml version="1.0" encoding="ISO-8859-1"?>
			<BroadsoftDocument protocol="OCI" xmlns="C" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
			  <sessionId xmlns=""/>
			  <command xsi:type="testocicmd" xmlns="">
			    <userId>my_bw_user</userId>
			    <oci_ele1>ele1</oci_ele1>
			    <oci_ele2>
			      <oci_sub_ele1>sub_ele1</oci_sub_ele1>
			      <oci_sub_ele2>arr_ele2</oci_sub_ele2>
			      <oci_sub_ele2>arr_ele3</oci_sub_ele2>
			      <oci_sub_ele2>arr_ele4</oci_sub_ele2>
			    </oci_ele2>
			    <oci_ele3>ele3</oci_ele3>
			  </command>
		    </BroadsoftDocument>
		'
		xml = @bw.build_request("testocicmd",config_hash)
		assert_equal xml.gsub(/\s+/,''),expected_string.gsub(/\s+/,'')

	end

	def test_oci_table_to_array
		test_response ='
		<?xml version="1.0" encoding="ISO-8859-1"?>
		<BroadsoftDocument protocol="OCI" xmlns="C" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
		<sessionId xmlns="">localhost,1535442458,1393632344857</sessionId>
		<command echo="" xsi:type="GroupDnGetAssignmentListResponse" xmlns=""><dnTable>
		<colHeading>Phone Numbers</colHeading><colHeading>Assigned To</colHeading><colHeading>Department</colHeading><colHeading>Activated</colHeading>
		<row><col>+1-5551234567</col><col>Hungus,Karl</col><col/><col>true</col></row>
		<row><col>+1-5551234206</col><col>Lebowski,Bunny</col><col/><col>true</col></row>
		<row><col>+1-5551236109</col><col/><col/><col>true</col></row>
		<row><col>+1-5551231207 - +1-5551231210</col><col/><col/><col>true</col></row>
		</dnTable></command></BroadsoftDocument>'
		expected_responses = [
			{:Phone_Numbers=>"+1-5551234567", :Assigned_To=>"Hungus,Karl", :Department=>"__NIL__", :Activated=>"true"},
			{:Phone_Numbers=>"+1-5551234206", :Assigned_To=>"Lebowski,Bunny", :Department=>"__NIL__", :Activated=>"true"},
			{:Phone_Numbers=>"+1-5551236109", :Assigned_To=>"__NIL__", :Department=>"__NIL__", :Activated=>"true"},
			{:Phone_Numbers=>"+1-5551231207 - +1-5551231210", :Assigned_To=>"__NIL__", :Department=>"__NIL__", :Activated=>"true"}
		]
		response_list = @bw.oci_table_to_array(test_response,'dnTable')
		assert_kind_of(Array,response_list,"#{__method__}: Did not return array")
		assert_equal response_list,expected_responses,"#{__method__}: Returned Response did not match expected response"
	end

	def test_oci_rows_to_nested_hash
		test_response = '
			<?xml version="1.0" encoding="ISO-8859-1"?>
			<BroadsoftDocument protocol="OCI" xmlns="C" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><sessionId xmlns="">localhost,1535442458,1393632344857</sessionId><command echo="" xsi:type="UserGetResponse20" xmlns=""><serviceProviderId>ENT</serviceProviderId><groupId>GROUP</groupId><lastName>Lebowski</lastName><firstName>Jeffrey</firstName><callingLineIdLastName>Lebowski</callingLineIdLastName><callingLineIdFirstName>Jeffrey</callingLineIdFirstName><hiraganaLastName>Lebowski</hiraganaLastName><hiraganaFirstName>Jeffrey</hiraganaFirstName><phoneNumber>5551239860</phoneNumber><extension>1208</extension><callingLineIdPhoneNumber>5551231900</callingLineIdPhoneNumber><language>English</language><timeZone>America/Los_Angeles</timeZone><timeZoneDisplayName>(GMT-07:00) (US) Pacific Time</timeZoneDisplayName><defaultAlias>GROUP-user002@myAS.com</defaultAlias><accessDeviceEndpoint><accessDevice><deviceLevel>Group</deviceLevel><deviceName>poly-3823</deviceName></accessDevice><linePort>GROUP-user002@myAS.com</linePort><staticRegistrationCapable>false</staticRegistrationCapable><useDomain>true</useDomain><supportVisualDeviceManagement>false</supportVisualDeviceManagement></accessDeviceEndpoint><title>Tanner</title><emailAddress>GROUP-user002@1002.com</emailAddress><countryCode>1</countryCode><networkClassOfService>AUTH_CALL_5MIN</networkClassOfService><impId>GROUP-user002@ENT.ums.com</impId></command></BroadsoftDocument>'

		expected_response = {
			:serviceProviderId=>"ENT",
			:groupId=>"GROUP",
			:lastName=>"Lebowski",
			:firstName=>"Jeffrey",
			:callingLineIdLastName=>"Lebowski",
			:callingLineIdFirstName=>"Jeffrey",
			:hiraganaLastName=>"Lebowski",
			:hiraganaFirstName=>"Jeffrey",
			:phoneNumber=>"5551239860",
			:extension=>"1208",
			:callingLineIdPhoneNumber=>"5551231900",
			:language=>"English",
			:timeZone=>"America/Los_Angeles",
			:timeZoneDisplayName=>"(GMT-07:00) (US) Pacific Time",
			:defaultAlias=>"GROUP-user002@myAS.com",
			:accessDeviceEndpoint=>{
				:accessDevice=>{
					:deviceLevel=>"Group",
					:deviceName=>"poly-3823"
				},
				:linePort=>"GROUP-user002@myAS.com",
				:staticRegistrationCapable=>"false",
				:useDomain=>"true",
				:supportVisualDeviceManagement=>"false"
			},
			:title=>"Tanner",
			:emailAddress=>"GROUP-user002@1002.com",
			:countryCode=>"1",
			:networkClassOfService=>"AUTH_CALL_5MIN",
			:impId=>"GROUP-user002@ENT.ums.com"
		}
		response_hash = @bw.oci_build_nested_rows_hash(test_response)
		assert_kind_of(Hash,response_hash,"#{__method__}: Did not return Hash")
		assert_equal response_hash,expected_response,"Returned Hash did not match expected Hash"
	end

end
