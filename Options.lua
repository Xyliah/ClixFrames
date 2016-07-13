local ClixFrames = LibStub("AceAddon-3.0"):GetAddon("ClixFrames")
local LSM = LibStub("LibSharedMedia-3.0")

ClixFrames.defaults = {
	profile = {
		frameHeight = 56,
		frameWidth = 108,
		frameScale = 1,
		alpha = 1,
		iconSize = 12,
		powerBar = false,
		foregroundTexture = "oRA3",
		backgroundTexture = "oRA3",
		nameFont = "Handel Gothic BT",
		nameHeight = 9,
		statusTextFont = "Handel Gothic BT",
		statusTextHeight = 14, 
		standardOptions = {
			["displayPowerBar"] = true,
			["displayHealPrediction"] = true,
			["displayAggroHighlight"] = true,
			["useClassColors"] = true,
			["displayPets"] = false,
			["displayMainTankAndAssist"] = false, 
			["displayBorder"] = false,
			["keepGroupsTogether"] = false,
		},
		debugOptions = {
			debugEvents = {
				unregister_UNIT_MAXHEALTH = false,
				unregister_UNIT_HEALTH = false,
				unregister_UNIT_HEALTH_FREQUENT = false,
				unregister_UNIT_MAXPOWER = false,
				unregister_UNIT_POWER = false,
			},
			debugSliders = {
				debugSliderHealth = 100,
				debugSliderPower = 100,
			},
		},

	},
}

ClixFrames.colors = {
	
	englishClass = {
		HUNTER = {r = 0.67, g = 0.83, b = 0.45},
		WARLOCK = {r = 0.58, g = 0.51, b = 0.79},
		PRIEST = {r = 1.0, g = 1.0, b = 1.0},
		PALADIN = {r = 0.96, g = 0.55, b = 0.73},
		MAGE = {r = 0.41, g = 0.8, b = 0.94},
		ROGUE = {r = 1.0, g = 0.96, b = 0.41},
		DRUID = {r = 1.0, g = 0.49, b = 0.04},
		SHAMAN = {r = 0.14, g = 0.35, b = 1.0},
		WARRIOR = {r = 0.78, g = 0.61, b = 0.43},
		DEATHKNIGHT = {r = 0.77, g = 0.12 , b = 0.23},
		MONK = {r = 0.0, g = 1.00 , b = 0.59},
		--PET = {r = 0.20, g = 0.90, b = 0.20},
		--VEHICLE = {r = 0.23, g = 0.41, b = 0.23},
	},
	powerColors = {
		MANA = {r = 0.30, g = 0.50, b = 0.85}, 
		RAGE = {r = 0.90, g = 0.20, b = 0.30},
		FOCUS = {r = 1.0, g = 0.50, b = 0.25},
		ENERGY = {r = 1.0, g = 0.85, b = 0.10}, 
	},
}

function ClixFrames:SetupOptions()

	local profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("ClixFrames", self.GenerateOptions)
	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("ClixFrames Profiles", profiles)

	local ACD3 = LibStub("AceConfigDialog-3.0")
	self.optionsFrames = {}
	self.optionsFrames.General	  = ACD3:AddToBlizOptions("ClixFrames", "ClixFrames", nil, "General")
	self.optionsFrames.Layout  	  = ACD3:AddToBlizOptions("ClixFrames", "Layout", "ClixFrames", "Layout")
	self.optionsFrames.Indicators = ACD3:AddToBlizOptions("ClixFrames", "Indicators", "ClixFrames", "Indicators")
	self.optionsFrames.Auras 	  = ACD3:AddToBlizOptions("ClixFrames", "Auras", "ClixFrames", "Auras")
	self.optionsFrames.Debug	  = ACD3:AddToBlizOptions("ClixFrames", "Debugging", "ClixFrames", "Debug")
	self.optionsFrames.Profile    = ACD3:AddToBlizOptions("ClixFrames Profiles", "Profiles", "ClixFrames")

	self.GenerateOptions = nil
	self.SetupOptions = nil
end

local function UpdateBlizzardOptions(info, value)
	SetRaidProfileOption(CompactUnitFrameProfiles.selectedProfile, info, value)
	CompactUnitFrameProfiles_ApplyCurrentSettings()
	CompactUnitFrameProfiles_UpdateCurrentPanel()
	-- save changes in blizzard profile
	SaveRaidProfileCopy(CompactUnitFrameProfiles.selectedProfile)
end

function ClixFrames:GenerateOptions()
	local db = LibStub("AceAddon-3.0"):GetAddon("ClixFrames").db.profile

	ClixFrames.Options = {
		type = "group",
		childGroups = "tab",
		name = ClixFrames.versionstring,
		args = {
			General = {
				order = 1,
				type = "group",
				name = "General",
				--desc = "Test landing page",
				args = {
					intro = {
						order = 1, 
						type = "description",
						name = "Here comes the intro!",					
					},
				},
			},
			Layout = {
				order = 2,
				type = "group",
				name = "Layout",
				desc = "Description",
				args = {
					intro = {
						order = 0,
						type = "description",
						name = "ClixFrames adds more customizability to the standard RaidFrames. It adds options to change textures, fonts, color, borders and more.",
					},
					StandardOptions = {
						order = 1,
						type = "group",
						name = "Standard Options",
						guiInline = true,
						get = function(info) return GetRaidProfileOption(CompactUnitFrameProfiles.selectedProfile, info[#info]) end,
						set = function(info, value) print(info[#info]) UpdateBlizzardOptions(info[#info], value) end,
						args = {
							displayPowerBar = {
								order = 1,
								type = "toggle",
								name = "Display Power Bars",
								desc = "Sets if units powerbars should be shown!",
								width = "normal",
							},
							displayHealPrediction = {
								order = 2,
								type = "toggle",
								name = "Display Incoming Heals",
								desc = "Sets if units powerbars should be shown!",
								width = "double",
							},
							displayAggroHighlight = {
								order = 4,
								type = "toggle",
								name = "Display Aggro Highlight",
								desc = "Sets if units powerbars should be shown!",
								width = "double",
							},
							useClassColors = {
								order = 3,
								type = "toggle",
								name = "Display Class Colors",
								desc = "Sets Class Colors",
								--width = "double",
							},
							displayPets = {
								order = 5, 
								type = "toggle",
								name = "Display Pets",
								desc = "asda",
								--width = "double",
							},
							displayMainTankAndAssist = {
								order = 6, 
								type = "toggle",
								name = "Display Main Tank and Assist",
								desc = "asda",
								width = "double",
							},
							displayBorder = {
								order = 7, 
								type = "toggle",
								name = "Display Border",
								desc = "asda",
								--width = "double",
							},
							keepGroupsTogether = {
								order = 8, 
								type = "toggle",
								name = "Keep Groups Together",
								desc = "some description",
								width = "double",
							},
							horizontalGroups = {
								order = 9,
								type = "toggle",
								name = "Horizontal Groups",
								desc = "Sorts the Raidgroups horizontally.",
								hidden = function() return not GetRaidProfileOption(CompactUnitFrameProfiles.selectedProfile, "keepGroupsTogether") end,
							},
						},
					},
					FrameSizeGroup = {
						order = 2,
						type = "group",
						name = "FrameSizeGroup",
						guiInline = true,
						args = {
							--[[
							Testmode = {
								order = 2,
								type = "execute",
								name = "execute",
								desc = "execute desc",
								func = function() print("Trolled ya!") end,
							},
							]]
							frameHeight = {
								order = 1,
								type = "range",
								name = "Frame Height",
								desc = "Height of CompactUnitFrames",
								--width = "double",
								min = 32, max = 72, step = 1,
								set = function(info, value)
									db[info[#info]] = value
									SetRaidProfileOption(CompactUnitFrameProfiles.selectedProfile, "frameHeight", value)
									CompactUnitFrameProfiles_ApplyCurrentSettings();
									CompactUnitFrameProfiles_UpdateCurrentPanel();
									CompactUnitFrameProfiles_SaveChanges(CompactUnitFrameProfiles)
								end,
							},
							frameWidth = {
								order = 2,
								type = "range",
								name = "Frame Width",
								desc = "Width of CompactUnitFrames",
								min = 72, max = 144, step = 1,
								set = function(info, value)
									db[info[#info]] = value
									CompactUnitFrameProfiles_ApplyCurrentSettings();
									CompactUnitFrameProfiles_UpdateCurrentPanel();
									SetRaidProfileOption(CompactUnitFrameProfiles.selectedProfile, "frameWidth", value)
									CompactUnitFrameProfiles_SaveChanges(CompactUnitFrameProfiles)
								end,
							},
							frameScale = {
								order = 3,
								type = "range",
								name = "Frame Scale",
								desc = "Set the scale of your frames",
								min = 0.5, max = 3, step = 0.05,
								isPercent = true,
								set = function(info, value)
									db.frameScale = value
									CompactRaidFrame1:SetScale(value)
								end,
							},
						},
					},
					Texture = {
						order = 3,
						type = "group",
						name = "Healthbar",
						guiInline = true,
						args = {
							backgroundTexture = {
								order = 1,
								type = "select",
								dialogControl = "LSM30_Statusbar",
								name = "background Texture",
								desc = "Sets the texture of background!",
								values = AceGUIWidgetLSMlists.statusbar,
								get = function(info) return db[info[#info]] end,
								set = function(info, value)
									db[info[#info]]	= value
								end,
							},
							foregroundTexture = {
								order = 2,
								type = "select",
								dialogControl = "LSM30_Statusbar",
								name = "Foreground Texture",
								--desc = "Sets the texture of background",
								values = AceGUIWidgetLSMlists.statusbar,
								get = function(info) 
									return db[info[#info]]
								end,
								set = function(info, value)
									db[info[#info]] = value
									local texture = LSM:Fetch("statusbar", value)
									CompactRaidFrameContainer_ApplyToFrames(CompactRaidFrameContainer, "all", ClixFrames.SetForegroundTexture, texture)
								end,
							},
						},
					},
					Font = {
						order = 4,
						type = "group",
						name = "Font",
						guiInline = true,
						get = function(info) return db[info[#info]] end,
						args = {
							nameFont = {
								order = 1,
								type = "select",
								dialogControl = "LSM30_Font",
								name = "Name",
								--desc = "Sets something",
								values = AceGUIWidgetLSMlists.font,
								set = function(info, value) 
									db[info[#info]] = value
									local font = LSM:Fetch("font", value)
									CompactRaidFrameContainer_ApplyToFrames(CompactRaidFrameContainer, "all", ClixFrames.SetNameFont, font)
								end,
							},
							nameHeight = {
								order = 2,
								type = "range",
								name = "Name font height",
								min = 4, max = 30, step = 1,
								set = function(info, value)
									db[info[#info]] = value
									CompactRaidFrameContainer_ApplyToFrames(CompactRaidFrameContainer, "all", ClixFrames.SetNameHeight, value)
								end,
							},
							statusTextFont = {
								order = 3,
								type = "select",
								dialogControl = "LSM30_Font",
								name = "Status Text",
								--desc = "Sets something",
								values = AceGUIWidgetLSMlists.font,
								set = function(info, value) 
									db[info[#info]] = value
									local font = LSM:Fetch("font", value)
									CompactRaidFrameContainer_ApplyToFrames(CompactRaidFrameContainer, "all", ClixFrames.SetStatusTextFont, font)
								end,
							},
							statusTextHeight = {
								order = 4,
								type = "range",
								name = "Name font height",
								min = 4, max = 30, step = 1,
								set = function(info, value)
									db[info[#info]] = value
									CompactRaidFrameContainer_ApplyToFrames(CompactRaidFrameContainer, "all", ClixFrames.SetStatusTextHeight, value)
								end,
							},
						},
					},
				},
			},
			Indicators = {
				order = 2, 
				type = "group",
				name = "Indicators",
				args = {

				},
			},
			Auras = {
				order = 3,
				type = "group",
				name = "Statuses",
				cmdInline = true,
				--desc = "Allows you to modify the Indicators which are used to display buffs and debuffs!",
				args = {
					Group1 = {
						order = 1,
						type = "group",
						name = "Group1",
						--cmdInline = true,
						args = {
							Option1 = {
								order = 1, 
								type = "input",
								name = "Adds new Buff",
								desc = "Adds new Buff",
								width = "double",
							},
							Aura_Buff = {
								type = "group",
								name = "Buff: "..math.random(0, 1000),
								args = {

								},
							},
							Aura_Debuff = {
								type = "group",
								name = "Buff: "..math.random(0, 1000),
								args = {

								},
							},
						},
					},
				},
			},
			Debug = {
				order = 4,
				type = "group",
				name = "Debugging",
				args = {
					intro = {
						order = 1,
						type = "description",
						name = "This debug mode lets you unregister certain events and allows to simulate specific actions onto the frames!",
					},
					debugOptions = {
						order = 2,
						type = "group",
						name = "UNREGISTER specific events",
						guiInline = true,
						get = function(info)
							return db.debugOptions.debugEvents[info[#info]]
						end,
						set = function(info, value)
							db.debugOptions.debugEvents[info[#info]] = value
							CompactRaidFrameContainer_ApplyToFrames(CompactRaidFrameContainer, "all", ClixFrames.UpdateUnitEvents)
						end,
						args = {
							unregister_UNIT_MAXHEALTH = {
								order = 1,
								type = "toggle",
								width = "double",
								name = "UNIT_MAXHEALTH",
							},
							unregister_UNIT_HEALTH = {
								order = 2,
								type = "toggle",
								--width = "double",
								name = "UNIT_HEALTH",
							},
							unregister_UNIT_HEALTH_FREQUENT = {
								order = 3,
								type = "toggle",
								width = "double",
								name = "UNIT_HEALTH_FREQUENT",
							},
							unregister_UNIT_MAXPOWER = {
								order = 4,
								type = "toggle",
								--width = "double",
								name = "UNIT_MAXPOWER",
							},
							unregister_UNIT_POWER = {
								order = 5,
								type = "toggle",
								--descStyle = "inline",
								width = "double",
								name = "UNIT_POWER",
							},
						},
					},
					debugSliders = {
						order = 3,
						type = "group",
						name = "SLIDER",
						guiInline = true,
						args = {
							debugSliderHealth = {
								order = 1, 
								type = "range",
								name = "Slider Health",
								min = 0, max = 100, step = 1,
								get = function(info)
									return db.debugOptions.debugSliders[info[#info]]
								end,
								set = function(info, value)
									db.debugOptions.debugSliders[info[#info]] = value
									CompactRaidFrameContainer_ApplyToFrames(CompactRaidFrameContainer, "all", ClixFrames.SetUnitHealth, value)
								end,
							},
							debugSliderPower = {
								order = 2, 
								type = "range",
								name = "Slider Power",
								min = 0, max = 100, step = 1,
								get = function(info)
									return db.debugOptions.debugSliders[info[#info]]
								end,
								set = function(info, value)
									db.debugOptions.debugSliders[info[#info]] = value
									CompactRaidFrameContainer_ApplyToFrames(CompactRaidFrameContainer, "all", ClixFrames.SetUnitPower, value)
								end,
							},
						},
					},
				},
			},
		},
	}

	return ClixFrames.Options	
end



function ClixFrames.UpdateUnitEvents(frame)
	local db = ClixFrames.db.profile.debugOptions.debugEvents
	for option, value in pairs(db) do 
		local event = option:gsub("unregister_", "")
		local unit = frame.unit
		local displayedUnit 
		if ( unit ~= frame.displayedUnit ) then
			displayedUnit = frame.displayedUnit
		end
		--print(option .. " - " .. tostring(db[option]))
		if ( db[option] and frame:IsEventRegistered(event) ) then
			frame:UnregisterEvent(event)
			print(event .. " |cFFFF0000unregistered!")
		elseif ( not db[option] and not frame:IsEventRegistered(event) ) then
			frame:RegisterUnitEvent(event, unit, displayedUnit)
			print(event .. " |cFF00FF00registered!")
		end
	end 
end

function ClixFrames.SetUnitHealth(frame, value)
	frame.healthBar:SetValue(value / 100 * UnitHealth(frame.displayedUnit))
end

function ClixFrames.SetUnitPower(frame, value)
	frame.powerBar:SetValue(value / 100 * UnitPower(frame.displayedUnit))
end