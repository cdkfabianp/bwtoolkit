require_relative 'bwoci_config_components'

class BWOci < OCIComponents

	def AuthenticationRequest
		config_hash = {
			userId: user_id
		}
	end

	def EnterprisePhoneDirectoryGetListRequest17
		config_hash = {
        	enterpriseId: nil,
        	isExtendedInfoRequested: true	
        }
    end

    def EnterprisePreAlertingAnnouncementGetRequest
        config_hash = {
        	enterpriseId: nil
        }
    end

    def GroupAnnouncementFileGetListRequest
		config_hash = {
			serviceProviderId: nil,
			groupId: nil,
			announcementFileType: 'Audio',
			includeAnnouncementTable: 'true',
			responseSizeLimit: 1000
		}		
    end

    def GroupAnnouncementFileGetRequest
    	config_hash = {
			serviceProviderId: nil,
			groupId: nil,
			announcementFileKey: nil
    	}
    end

    def GroupAnnouncementFileModifyRequest
    	config_hash = {
    		serviceProviderId: nil,
    		groupId: nil,
    		announcementFileKey: {
    			name: nil,
    			mediaFileType: "WAV",
    		},
    		newAnnouncementFileName: nil,
    	}
    end

    def GroupAutoAttendantGetInstanceListRequest(ent=nil,group=nil)
    	config_hash = {
    		serviceProviderId: ent,
    		groupId: group
    	}
    end

    def GroupAutoAttendantGetInstanceRequest20(svc_id=nil)
    	config_hash = {
    		serviceUserId: svc_id
    	}
    end

    def GroupAutoAttendantModifyInstanceRequest20(svc_id=nil,tn=nil,ext=nil,aliasList=nil,publicId=nil)
    	config_hash = {
    		serviceUserId: svc_id,
    		serviceInstanceProfile: send(:serviceInstanceProfile,tn,ext,aliasList,publicId),
				firstDigitTimeoutSeconds: nil,
				enableVideo: nil,
				businessHours: nil,
				holidaySchedule: nil,
				extensionDialingScope: nil,
				nameDialingScope: nil,
				nameDialingEntries: nil,
				businessHoursMenu: nil,
				afterHoursMenu: nil,
				holidayMenu: nil,
				networkClassOfService: nil,
			}
    end

    def GroupCallProcessingGetPolicyRequest17sp4
    	config_hash = {
			serviceProviderId: nil,
			groupId: nil,    		
    	}
    end

    def GroupAccessDeviceGetRequest16
    	config_hash = {
			serviceProviderId: nil,
			groupId: nil,       		
            deviceName: nil
    	}
    end

    def GroupAccessDeviceAddRequest14(dev_mgmt_pass)
        config_hash = {
        	serviceProviderId: nil,
        	groupId: nil,
            deviceName: nil,
            deviceType: nil,
            useCustomUserNamePassword: false
        }    	
        if dev_mgmt_pass == true
       		config_hash[:useCustomUserNamePassword] = true
       		config_hash[:accessDeviceCredentials] = {
            	userName: nil,
            	password: nil,       			
       		}
	    end
	    return config_hash
    end

    def GroupAccessDeviceGetRequest18sp1(ent=nil,group=nil,dev_name=nil)
    	config_hash = {
    		serviceProviderId: ent,
    		groupId: group,
    		deviceName: dev_name
    	}
    	return config_hash
    end

    def GroupAccessDeviceGetUserListRequest
    	config_hash = {
			serviceProviderId: nil,
			groupId: nil,       		
            deviceName: nil,
            responseSizeLimit: 5000
    	} 
    end

    def GroupAccessDeviceGetListRequest(ent=nil,group=nil,dev_type=nil)
    	config_hash = {
    		serviceProviderId: ent,
    		groupId: group,
    	}

    	if dev_type != nil
    		config_hash[:searchCriteriaExactDeviceType] = {
    			deviceType: dev_type
    		}
    	end
    	return config_hash
    end

    def GroupAdminGetListRequest(ent=nil,group=nil)
    	config_hash = {
    		serviceProviderId: ent,
    		groupId: group,
    	}
    end

#
#    NEED TO FILL IN MISSING OCI COMMANDS
#
#
	def GroupDnUnassignListRequest(ent=nil,group=nil,tn_list=nil)
		config_hash = {
			serviceProviderId: ent,
			groupId: group,
			phoneNumber: tn_list
		}
	end

	def GroupDomainGetAssignedListRequest
		config_hash = {
			serviceProviderId: nil,
			groupId: nil,
			responseSizeLimit: 1000
		}
	end

	def GroupDnGetAssignmentListRequest
		config_hash = {
			serviceProviderId: nil,
			groupId: nil,
			responseSizeLimit: 1000
		}
	end

	def GroupGetListInServiceProviderRequest(ent=nil)
		config_hash = {
			serviceProviderId: ent
		}
		return config_hash
	end

	def GroupGetListInSystemRequest
		config_hash = {
			responseSizeLimit: 1000,
			searchCriteriaGroupId: {
				mode: "Equal To",
				value: nil,
				isCaseInsensitive: true
			},
		}
	end

	def GroupGetRequest14sp7(ent,group)
		config_hash = {
			serviceProviderId: ent,
			groupId: group,			
		}
	end

	def GroupGetUserServiceAssignedUserListRequest(ent=nil,group=nil,svc=nil)
		config_hash = {
			serviceProviderId: ent,
			groupId: group,
			serviceName: svc
		}
	end

	def GroupInterceptGroupModifyRequest16(ent=nil,group=nil)
		config_hash = {
			serviceProviderId: ent,
			groupId: group,
			isActive: nil,
			announcementSelection: nil,
			audioFile: nil,
			videoFile: nil,
			playNewPhoneNumber: nil,
			newPhoneNumber: nil,
			transferOnZeroToPhoneNumber: nil,
			transferPhoneNumber: nil,
			rerouteOutboundCalls: nil,
			outboundReroutePhoneNumber: nil,
			allowOutboundLocalCalls: nil,
			inboundCallMode: nil,
			alternateBlockingAnnouncement: nil,
			routeToVoiceMail: nil
		}
	end

	def GroupHuntGroupGetInstanceListRequest(ent=nil,group=nil)
		config_hash = {
			serviceProviderId: ent,
			groupId: group,
		}
	end

	def GroupHuntGroupGetInstanceRequest20(svc_id=nil)
		config_hash = {
			serviceUserId: svc_id
		}
	end

	def GroupHuntGroupModifyInstanceRequest(svc_id=nil,tn=nil,ext=nil,aliasList=nil,publicId=nil)
    	config_hash = {
    		serviceUserId: svc_id,
    		serviceInstanceProfile: send(:serviceInstanceProfile,tn,ext,aliasList,publicId),
				policy: nil,
				huntAfterNoAnswer: nil,
				noAnswerNumberOfRings: nil,
				forwardAfterTimeout: nil,
				forwardTimeoutSeconds: nil,
				forwardToPhoneNumber: nil,
				agentUserIdList: nil,
				allowCallWaitingForAgents: nil,
				useSystemHuntGroupCLIDSetting: nil,
				includeHuntGroupNameInCLID: nil,
				enableNotReachableForwarding: nil,
				notReachableForwardToPhoneNumber: nil,
				makeBusyWhenNotReachable: nil,
				allowMembersToControlGroupBusy: nil,
				enableGroupBusy: nil,
				applyGroupBusyWhenTerminatingToAgent: nil,
				networkClassOfService: nil,
		}
    end

	def ServiceProviderAdminGetListRequest14(ent=nil)
		config_hash = {
			serviceProviderId: ent
		}
	end
	
	def ServiceProviderCallProcessingGetPolicyRequest17sp4
		config_hash = {
			serviceProviderId: ent
		}
	end

	def ServiceProviderDnGetSummaryListRequest(ent=nil)
		config_hash = {
				serviceProviderId: ent
		}
	end

	def ServiceProviderEndpointGetListRequest(ent=nil)
		config_hash = {
				serviceProviderId: ent
		}
	end

	def ServiceProviderGetListRequest
		config_hash = {
			isEnterprise: true
		}
	end

	def ServiceProviderGetRequest17sp1(ent=nil)
		config_hash = {
			serviceProviderId: ent
		}

	end

	def SystemDnGetUtilizationRequest14sp3
		config_hash = {
			phoneNumber: nil
		}
	end

	def UserAlternateNumbersGetRequest17(user=nil)
		config_hash = {
			userId: user
		}
	end

	def UserAlternateNumbersModifyRequest()
		config_hash = {
				userId: nil,
				distinctiveRing: nil,
				alternateEntry01: alternate_entry,
				alternateEntry02: alternate_entry,
				alternateEntry03: alternate_entry,
				alternateEntry04: alternate_entry,
				alternateEntry05: alternate_entry,
				alternateEntry06: alternate_entry,
				alternateEntry07: alternate_entry,
				alternateEntry08: alternate_entry,
				alternateEntry09: alternate_entry,
				alternateEntry10: alternate_entry,
		}

	end

	def UserAnnouncementFileGetListRequest
		config_hash = {
			userId: nil,
			announcementFileType: 'Audio',
			includeAnnouncementTable: true,
			responseSizeLimit: 1000
		}
	end

	def UserAnnouncementFileModifyRequest
		config_hash = {
			userId: nil,
			announcementFileKey: {
				name: nil,
				mediaFileType: "WAV",
			},
			newAnnouncementFileName: nil
		}
	end

	def UserBroadWorksReceptionistEnterpriseGetRequest(user=nil)
		config_hash = {
			userId: user
		}
	end

	def UserCallProcessingModifyPolicyRequest14sp7
		config_hash = {
			userId: nil,
			useUserCLIDSetting: nil,
			useUserMediaSetting: nil,
			useUserCallLimitsSetting: nil,
			useUserDCLIDSetting: nil,
			useMaxSimultaneousCalls: nil,
			maxSimultaneousCalls: nil,
			useMaxSimultaneousVideoCalls: nil,
			maxSimultaneousVideoCalls: nil,
			useMaxCallTimeForAnsweredCalls: nil,
			maxCallTimeForAnsweredCallsMinutes: nil,
			useMaxCallTimeForUnansweredCalls: nil,
			maxCallTimeForUnansweredCallsMinutes: nil,
			mediaPolicySelection: nil,
			supportedMediaSetName: nil,
			useMaxConcurrentRedirectedCalls: nil,
			maxConcurrentRedirectedCalls: nil,
			useMaxFindMeFollowMeDepth: nil,
			maxFindMeFollowMeDepth: nil,
			maxRedirectionDepth: nil,
			useMaxConcurrentFindMeFollowMeInvocations: nil,
			maxConcurrentFindMeFollowMeInvocations: nil,
			clidPolicy: nil,
			emergencyClidPolicy: nil,
			allowAlternateNumbersForRedirectingIdentity: nil,
			useGroupName: nil,
			enableDialableCallerID: nil,
			blockCallingNameForExternalCalls: nil,
			allowConfigurableCLIDForRedirectingIdentity: nil,
			allowDepartmentCLIDNameOverride: nil,
		}
	end

	def UserGetListInGroupRequest
		config_hash = {
			serviceProviderId: nil,
			GroupId: nil,
		}
	end

	def UserGetListInSystemRequest(ele)
		config_hash = {
			responseSizeLimit: 3000,
			searchCriteriaUserId: {
				mode: ele[:mode],
				value: ele[:value],
				isCaseInsensitive: true
			},
		}
	end

	def UserGetRegistrationListRequest(user=nil)
		config_hash = {
			userId: user
		}
	end

	def UserGetRequest20(user=nil) 
		config_hash = {
			userId: user
		}
	end

	def UserGetServiceInstanceListInServiceProviderRequest(ent=nil,search_criteria=nil,value=nil)
		config_hash = {
			serviceProviderId: ent,
			responseSizeLimit: 1000,
		}
		config_hash[search_criteria] = send(search_criteria,value) unless search_criteria == nil
		return config_hash
	end

	def UserIntegratedIMPModifyRequest(user=nil,active=nil)
		config_hash = {
			userId: user,
			isActive: active,
		}
	end

	def UserModifyRequest17sp4
		config_hash = {
			userId: nil,
			lastName: nil,
			firstName: nil,
			callingLineIdLastName: nil,
			callingLineIdFirstName: nil,
			nameDialingName: nil,
			hiraganaLastName: nil,
			hiraganaFirstName: nil,
			phoneNumber: nil,
			extension: nil,
			callingLineIdPhoneNumber: nil,
			oldPassword: nil,
			newPassword: nil,
			department: nil,
			language: nil,
			timeZone: nil,
			sipAliasList: nil,
			endpoint: {
				accessDeviceEndpoint: nil,
				trunkAddressing: nil,
			},
			title: nil,
			pagerPhoneNumber: nil,
			mobilePhoneNumber: nil,
			emailAddress: nil,
			yahooId: nil,
			addressLocation: nil,
			addressLocation: nil,
			networkClassOfService: nil,
			officeZoneName: nil,
			primaryZoneName: nil,
			impId: nil,
			impPassword: nil,
		}
	end

	def UserServiceAssignListRequest
		config_hash = {
			userId: nil,
			serviceName: Array.new,
		}
	end

	def UserServiceGetAssignmentListRequest(user=nil)
		config_hash = {
			userId: user
		}
	end

	def UserServiceUnassignListRequest(user)
		config_hash = {
			userId: user,
			serviceName: Array.new
		}
	end

	def UserSharedCallAppearanceAddEndpointRequest14sp2(user=nil,device=nil,lineport=nil)
        config_hash = {
            userId: user,
            accessDeviceEndpoint: {
                accessDevice: {
                    deviceLevel: "Group",
                    deviceName: device,
                },
                linePort: lineport
            },
            isActive: "true",
            allowOrigination: "true",
            allowTermination: "true",
        }
	end

	def UserSharedCallAppearanceModifyRequest(user=nil)
		config_hash = {
			userId: user,
	        alertAllAppearancesForClickToDialCalls: true,
	        alertAllAppearancesForGroupPagingCalls: true,
	        allowSCACallRetrieve: true,
	        multipleCallArrangementIsActive: true,
	        allowBridgingBetweenLocations: true,
	        bridgeWarningTone: "None",
	        enableCallParkNotification: true,
	    }
	end

	def UserVoiceMessagingUserGetAdvancedVoiceManagementRequest14sp3(user=nil)
		config_hash = {
			userId: user
		}
	end

	def UserVoiceMessagingUserGetVoiceManagementRequest17(user=nil)
		config_hash = {
			userId: user
		}
	end



end