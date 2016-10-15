

class OCIComponents

	def alternate_entry
		config_hash = {
				phoneNumber: nil,
				extension: nil,
				ringPattern: nil
		}
	end

	def huntPolicy
		config_hash = {
		}
	end

	def networkClassOfService
		config_hash = {

		}
	end

	def searchCriteriaDeviceMACAddress(value=nil,mode='Equal To',isCaseInsensitive=true)
		config_hash = {
			mode: mode,
			value: value,
			isCaseInsensitive: isCaseInsensitive
		}
	end

	def searchCriteriaExtension(value=nil,mode='Equal To',isCaseInsensitive=true)
		config_hash = {
			mode: mode,
			value: value,
			isCaseInsensitive: true
		}
	end

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

	def serviceInstanceProfile(tn=nil,ext=nil,aliasList=nil,publicId=nil)
		config_hash = {
			phoneNumber: tn,
			extension: ext,
			sipAliasList: aliasList,
			publicUserIdentity: publicId
		}
	end

end
