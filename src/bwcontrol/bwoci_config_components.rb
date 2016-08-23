

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

	def serviceInstanceProfile(tn=nil,ext=nil,aliasList=nil,publicId=nil)
		config_hash = {
			phoneNumber: tn,
			extension: ext,
			sipAliasList: aliasList,
			publicUserIdentity: publicId
		}
	end

end
