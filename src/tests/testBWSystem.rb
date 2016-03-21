require 'minitest/autorun'
require_relative '../bwcontrol/bwsystem'
require_relative '../bwhelpers/helpers'
require_relative 'mockBWSystem'

class TestBWSystem < Minitest::Test

	def setup		
		@config_data_file = File.expand_path("../../../conf/bw_sys.conf",__FILE__)	
		@helpers = Helpers.new
		@m = MockBWSystem.new
		@bw = BWSystem.new
	end

	def test_find_tn_assignment
		
	end

	def test_get_sys_ucone_device_types
		assert_kind_of Array,@bw.get_sys_ucone_device_types
	end

	def test_get_groups_in_system
		@bw.bw_login(@config_data_file)
		ent_groups = @bw.get_groups_in_system

		#Confirm Hash is returned
		assert_kind_of(Hash,ent_groups)

		#Confirm Hash Value is array
		assert_kind_of(Array,ent_groups.shift)

		#Confirm that Test ENT: peteENT exists in Hash
		assert_equal(true,ent_groups.has_key?("peteENT"))
	end

end