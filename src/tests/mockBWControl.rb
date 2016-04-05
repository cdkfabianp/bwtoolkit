class MockBWControl

	def mock_get_app_config
		expected_hash = {
			application_server: 'oci_server',
			my_bw_user: 'test-user',
			my_bw_pass: 'abcd1234!',
			debug: false,
			debug_oci: false,
			ok_to_mod: false
		}		

		return expected_hash
	end

	def mock_build_request(user)
		test_hash = {
			userId: user,
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

		return test_hash,expected_string		
	end

	def mock_oci_table_to_array
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

		return test_response,expected_responses
	end

	def mock_oci_rows_to_nested_hash
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

		return test_response,expected_response
	end

	def mock_oci_rows_to_nested_hash_2
		test_response = '
			<?xml version="1.0" encoding="ISO-8859-1"?>
			<BroadsoftDocument protocol="OCI" xmlns="C" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><sessionId xmlns="">localhost,1535442458,1393632344857</sessionId><command echo="" xsi:type="UserAlternateNumbersGetResponse17" xmlns=""><distinctiveRing>true</distinctiveRing><alternateEntry01><phoneNumber>1234567891</phoneNumber><extension>1987</extension><ringPattern>Normal</ringPattern></alternateEntry01><alternateEntry02><phoneNumber>1234567892</phoneNumber><extension>1567</extension><ringPattern>Normal</ringPattern></alternateEntry02><alternateEntry08><phoneNumber>1234567898</phoneNumber><ringPattern>Normal</ringPattern></alternateEntry08><alternateEntry10><extension>1115</extension><ringPattern>Normal</ringPattern></alternateEntry10></command></BroadsoftDocument>'

		expected_response = {
			distinctiveRing: "true",
			alternateEntry01: {
				phoneNumber: "1234567891",
				extension: "1987",
				ringPattern: "Normal"
			},
			alternateEntry02: {
				phoneNumber: "1234567892",
				extension: "1567",				
				ringPattern: "Normal"
			},
			alternateEntry08: {
				phoneNumber: "1234567898",
				ringPattern: "Normal"				
			},
			alternateEntry10: {
				extension: "1115",
				ringPattern: "Normal"
			}
		}
		return test_response,expected_response
	end

end
