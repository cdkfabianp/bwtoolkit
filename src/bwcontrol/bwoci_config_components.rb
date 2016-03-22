

class OCIComponents


	def searchCriteriaUserId(value=nil)
		config_hash = {
			mode: "Starts With",
			value: value,
			isCaseInsensitive: true
		}
	end

	def searchCriteriaGroupId(value=nil)
		config_hash = {
			mode: "Starts With",
			value: value,
			isCaseInsensitive: true
		}		
	end

	def SearchCriteriaExactServiceType(type=nil)
		config_hash = {
			serviceType: type
		}
	end

end
