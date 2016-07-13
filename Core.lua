local ClixFrames = LibStub("AceAddon-3.0"):NewAddon("ClixFrames", "AceConsole-3.0", "AceTimer-3.0")

local LSM = LibStub("LibSharedMedia-3.0")

local title = GetAddOnMetadata("ClixFrames", "Title")
local version = GetAddOnMetadata("ClixFrames", "Version")
ClixFrames.versionstring =  string.format("%s v%s", title, tostring(version))
ClixFrames.title = GetAddOnMetadata("ClixFrames", "Title")

-- register some media
LSM:Register("font", "Forte",					[[Interface\Addons\ClixFrames\media\FORTE.TTF]])
LSM:Register("font", "Handel Gothic BT",		[[Interface\Addons\ClixFrames\media\HandelGothicBT.TTF]])
LSM:Register("font", "Century Gothic",		[[Interface\Addons\ClixFrames\media\GOTHIC.TTF]])
LSM:Register("font", "Century Gothic Bold",	[[Interface\AddOns\ClixFrames\media\GOTHICB.TTF]])

LSM:Register("statusbar", "oRA3", 			[[Interface\AddOns\ClixFrames\media\statusbar]])

LSM:Register("border", "ForteXorcist", 		[[Interface\Addons\ClixFrames\media\Border]])

-----------------------------------------------------------------------------------------------------------

local db
function ClixFrames:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("ClixFramesDB", self.defaults, true)
	self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")
	self.db.RegisterCallback(self, "OnProfileCopied", "OnProfileChanged")
	self.db.RegisterCallback(self, "OnProfileReset", "OnProfileChanged")
	print("OnInitialize called!")

	db = self.db.profile

	self:SetupOptions()

	-- GC
	self.OnInitialize = nil
end

function ClixFrames.DefaultCompactUnitFrameSetup(frame)
	print("DefaultCompactUnitFrameSetup: "..frame:GetName())
end

function ClixFrames.SecureHookOnUpdate(frame)
	frame:HookScript("OnUpdate", function(self, elapsed)
		--print(frame.displayedUnit)
		frame.extraFont:SetText(frame.displayedUnit)
	end)
end

function ClixFrames:OnEnable()
	print("OnEnable called!")
	--hooksecurefunc("CompactUnitFrame_SetUpFrame", ClixFrames.changeBackground)
	-- setting up hooks here
	hooksecurefunc("CompactUnitFrame_SetUpFrame", ClixFrames.SecureHookSetUpFrame)
	hooksecurefunc("DefaultCompactUnitFrameSetup", ClixFrames.SecureHookDefaultCompactUnitFrameSetUp)
	hooksecurefunc("DefaultCompactMiniFrameSetup", ClixFrames.SecureHookDefaultCompactUnitFrameSetUp)
	
	hooksecurefunc("CompactUnitFrame_UpdateHealthColor", ClixFrames.UpdateHealthColor)
	hooksecurefunc("CompactUnitFrame_UpdatePowerColor", ClixFrames.UpdatePowerColor)

	--hooksecurefunc("CompactUnitFrame_UpdateName", ClixFrames.UpdateName)

	CompactRaidFrameContainer_ApplyToFrames(CompactRaidFrameContainer, "all", ClixFrames.SecureHookSetUpFrame, true)


	-- debug: 
	hooksecurefunc("CompactUnitFrame_UpdateUnitEvents", ClixFrames.UpdateUnitEvents)
	CompactRaidFrameContainer_ApplyToFrames(CompactRaidFrameContainer, "all", ClixFrames.UpdateUnitEvents)


	hooksecurefunc("CompactUnitFrame_SetUnit", function(frame)
			--print(frame.displayedUnit)
		end)

	CompactRaidFrameContainer_ApplyToFrames(CompactRaidFrameContainer, "all", ClixFrames.SecureHookOnUpdate)

	local Dialog = LibStub("AceConfigDialog-3.0")
	Dialog:SetDefaultSize("ClixFrames", 720, 540)

	ClixFrames:RegisterChatCommand("clix", ClixFrames.ToggleOptions)

end

function ClixFrames:OnDisable()
	
end


function ClixFrames:OnProfileChanged(event, database, newProfileKey)
	db = database.profile
end

function ClixFrames.ToggleOptions()
	local Dialog = LibStub("AceConfigDialog-3.0")
	if Dialog.OpenFrames["ClixFrames"] then
		Dialog:Close("ClixFrames")
	else
		Dialog:Open("ClixFrames")
		local a, b, c, d, e = Dialog.OpenFrames["ClixFrames"]:GetPoint()
		--print(b:GetName())
		for key, values in pairs(Dialog.OpenFrames["ClixFrames"]) do
			print(key)
		end

		ClixFrames.CreateAddInfo(Dialog.OpenFrames["ClixFrames"].frame)
	end
end

-- Remove the cancel button
InterfaceOptionsFrameCancel:Hide()
InterfaceOptionsFrameOkay:SetAllPoints(InterfaceOptionsFrameCancel)

-- Make clicking cancel the same as clicking okay
InterfaceOptionsFrameCancel:SetScript("OnClick", function()
	InterfaceOptionsFrameOkay:Click()
end)

--[[
local function AddExtraTextIndicator(frame)
	frame.extraFont = frame:CreateFontString(nil, "Overlay", "GameFontNormalSmall")
	frame.extraFont:SetPoint("Bottom", frame, "Bottom", 0, 0)
end
]]



local cluster_frame = CreateFrame("Frame")

function ClixFrames.UpdateUnitId(frame)
	if ( not frame.extraFont ) then
		frame.extraFont = frame:CreateFontString(nil, "Overlay", "GameFontNormalSmall")
		frame.extraFont:SetPoint("Bottom", frame, "Bottom", 0, 0)
	end

--[[
	local unit_positions = {}

	local function getDistanceBetweenPoints(vectorA, vectorB)
		local a = vectorB[1] - vectorA[1]
		local b = vectorB[2] - vectorA[2]

		local dist_AB = math.abs(math.sqrt(a^2 + b^2))
		return dist_AB
	end


	local time_elapsed = 10

	frame:SetScript("OnUpdate", function(self, elapsed)
			--print(time_elapsed)
			local raidsize = GetNumGroupMembers()
			local counter = 0

			--loop through raid to find unitID for player
			for i=1, raidsize do 
				if UnitName("raid"..i) == UnitName("player") then
					unit_positions.player = "raid"..i
					break
				end
			end

			--print("UNITID for player is", unit_positions.player)

			for i=1, raidsize do 
				posX, posY = UnitPosition("raid"..i)
				--print(string.format("raid%s set to %s %s", i, posX, posY))
				unit_positions["raid"..i] = { ["vector"] = {posX, posY} }
			end

			if ( time_elapsed >= 0.1 ) then
				
				local raidsize = GetNumGroupMembers()

				for i=1, raidsize do 
					posX, posY = UnitPosition("raid"..i)
					--print(string.format("raid%s set to %s %s", i, posX, posY))
					unit_positions["raid"..i] = { ["vector"] = {posX, posY} }
				end

				for i=1, raidsize-1 do
					for j=i+1, raidsize do
						--print(unit_positions["raid"..i-1])
						local dist = getDistanceBetweenPoints(unit_positions["raid"..i].vector, unit_positions["raid"..j].vector)
						print(string.format("Distance from raid%s to raid%s: %s", i, j, dist))
						--print(j)

						unit_positions["raid"..i]["raid"..j] = dist
						counter = counter + 1
					end
					
				end
				time_elapsed = 0 
				print("Counter", counter)

				local player_number = (unit_positions.player):gsub("%D", "")
				local unit_number = (frame.displayedUnit):gsub("%D", "")

				print(unit_positions.player)
				print(frame.displayedUnit)

				print(unit_positions["raid1"]["raid2"])
				if ( not (frame.displayedUnit):find("pet") ) then 
					if ( frame.displayedUnit ~= unit_positions.player) then
	 					frame.extraFont:SetFormattedText("%.1f", player_number < unit_number and unit_positions[unit_positions.player][frame.displayedUnit] or unit_positions[frame.displayedUnit][unit_positions.player] or 0)
	 				else
	 					frame.extraFont:SetText(frame.displayedUnit)
					end
				end

			end

			time_elapsed = time_elapsed + elapsed
		end)

	print("Counter", counter)
]]
	--frame.extraFont:SetText(frame.displayedUnit)
end

hooksecurefunc("CompactUnitFrame_UpdateName", ClixFrames.UpdateUnitId)
--hooksecurefunc("CompactUnitFrame_SetUpFrame", AddExtraTextIndicator)






function shit()
	--CompactRaidFrame1:SetBackdropColor(0, 0, 0, 0)
	CompactRaidFrame1.healthBar:SetValue(0)
	CompactRaidFrame1.powerBar:SetValue(0)
end

function shit2()
	for i=1,3 do
		local color = { 
			{1, 0.5, 0},
			{0, 1, 0},
			{0, 0, 1},
		}

		for k=1,2 do
			CompactRaidFrame1.auraFrames[i][k].icon:SetTexture(color[i][1], color[i][2], color[i][3], 1)
			CompactRaidFrame1.auraFrames[i][k]:Show()
		end
	end

	-- /run CompactRaidFrame1.auraFrames[1][1].icon:SetTexture(1,0,1)
end



function shit3()
	for i=1,2 do
		_G["CompactRaidFrame1Indicator1AuraFrame"..i].cooldown:Hide()
	end
end



do
	function ClixFrames.CreateAddInfo(parentFrame)
		--local point, relativeTo, relativePoint, xOffset, yOffset = aceOptions:GetPoint()
		--print(aceOptions:GetPoint())
		local backdrop = {
			bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
			edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
			tile = true, edgeSize = 2, tileSize = 5,
		}

		local frame = CreateFrame("Frame", "ClixFramesConfigWindow", parentFrame)
		frame:SetSize(300, 120)
		frame:SetPoint("Topleft", parentFrame, "Topright", 0, 0)
		frame:SetBackdrop(backdrop)
		frame:SetBackdropColor(0.2, 0.2, 0.2, 0.8)
		frame:SetBackdropBorderColor(1, 1, 1)

		frame:Show()


	end
end