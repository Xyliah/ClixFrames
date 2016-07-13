local ClixFrames = LibStub("AceAddon-3.0"):GetAddon("ClixFrames")
local LSM = LibStub("LibSharedMedia-3.0")

--------------------------------------------
------- Adjust unitname to not show server name -----
--[[
function ClixFrames.UpdateName(frame)
	local name, realm = UnitName(frame.displayedUnit)
	if ( realm ) then
		frame.name:SetFormattedText("%s*", name)
	else
		frame.name:SetText(name)
	end
end

hooksecurefunc("CompactUnitFrame_UpdateName", ClixFrames.UpdateName)
]]


local function buildHexString(...)
	local hexString = ""
	for i=1,3 do 
		if select(i, ...) < 16 then
			hexString = string.format("%s%s%s", hexString, 0, format("%X", select(i, ...)))
		else
			hexString = string.format("%s%s", hexString, format("%X", select(i, ...)))
		end
	end
	return hexString
end

local function print(...)

end


--------------------------------------------
------- Adjust CompactRaidFrame Fonts! -----

----------------
-- STATUSTEXT --

function ClixFrames.SetStatusTextFont(frame, font)
	local _, fontHeight, flags = frame.statusText:GetFont()

	frame.statusText:SetFont(font, fontHeight, flags)
	frame.statusText:SetTextColor(1, 1, 1)
end

function ClixFrames.SetStatusTextHeight(frame, fontHeight)
	local font, _, flags = frame.statusText:GetFont()

	frame.statusText:SetFont(font, fontHeight, flags)
end

function ClixFrames.SetStatusTextColor(frame, r, g, b)
	frame.statusText:SetTextColor(1, 1, 1)
end

--------------
-- UNITTEXT --

function ClixFrames.SetNameFont(frame, font)
	local _, fontHeight, flags = frame.name:GetFont()

	frame.name:SetFont(font, fontHeight, flags)
end

function ClixFrames.SetNameHeight(frame, fontHeight)
	local font, _, flags = frame.name:GetFont()

	frame.name:SetFont(font, fontHeight, flags)
end

function ClixFrames.SetNameColor(frame, r, g, b)
	frame.name:SetTextColor(r, g, b)
end


------------------------
-- FOREGROUND TEXTURE --

function ClixFrames.SetForegroundTexture(frame, texture)
	frame.healthBar:SetStatusBarTexture(texture)
end

-----------------------------------------------
----- Adjust CompactRaidFrame backgrounds -----

function ClixFrames.UpdateHealthColor(frame)
	local r, g, b

	-- colorize healthBar
	local _, englishClass = UnitClass(frame.displayedUnit)
	local classColor = RAID_CLASS_COLORS[englishClass] or { r = 0.5, g = 0.5, b = 0.5 }
	--local classColor = ClixFrames.colors[englishClass] or { r = 0.5, g = 0.5, b = 0.5 }
	if ( frame.optionTable.useClassColors ) then
		r, g, b = classColor.r, classColor.g, classColor.b
	else
		if ( UnitIsFriend("player", frame.unit) ) then
			r, g, b = 0.0, 1.0, 0.0
		else
			r, g, b = 1.0, 0.0, 0.0
		end
	end

	if ( r ~= frame.healthBar.background.r or g ~= frame.healthBar.background.g or b ~= frame.healthBar.background.b ) then
		-- first two not necessary, we can update the texture in DefaultCompactUnitFrameSetup hook
		--frame.healthBar:SetStatusBarTexture("Interface\\AddOns\\ClixFrames\\media\\statusbar.tga")
		
		-- XXX does this need to be implemented somewhere?! ANSWER: yes, otherwise you can't set a color 
		frame.healthBar.background:SetTexture("Interface\\AddOns\\ClixFrames\\media\\statusbar.tga")
		--
		frame.healthBar.background:SetVertexColor(r, g, b, 0.2)
		frame.healthBar.background.r, frame.healthBar.background.g, frame.healthBar.background.b = r, g, b

		ChatFrame1:AddMessage(string.format("%s (class - %s) changed bg to: |cFF%s%s", frame:GetName(), select(2, UnitClass(frame.displayedUnit)) or "no class", buildHexString(r*255, g*255, b*255), buildHexString(r*255, g*255, b*255)))
	end
	--ClixFrames:print(frame.healthBar.background:GetVertexColor())
end

function ClixFrames.UpdatePowerColor(frame)
	local r, g, b

	if ( not UnitIsConnected(frame.unit) ) then
		r, g, b = 0.5, 0.5, 0.5
	else
		local _, _, _, _, _, _, showOnRaid = UnitAlternatePowerInfo(frame.unit)
		if ( showOnRaid ) then
			r, g, b = 0.7, 0.7, 0.6
		else
			local powerType, powerToken, altR, altG, altB = UnitPowerType(frame.displayedUnit)
			--ClixFrames:print("UnitPowerType:"..powerToken)
			--local info = PowerBarColor[powerToken]
			local info = ClixFrames.colors.powerColors[powerToken]
			if ( info ) then
				r, g, b = info.r, info.g, info.b
				--ClixFrames:print(r,g,b)
			else
				if ( not altR ) then
					--info = PowerBarColor[powerType] or PowerBarColor["MANA"]
					info = ClixFrames.colors.powerColors[powerType] or ClixFrames.colors.powerColors["MANA"]
					r, g, b = info.r, info.g, info.b
				else
					r, g, b = altR, altG, altB
				end
			end
		end
	end

	-- first two necessary?! ANSWER: yes, but not here. better do it on frameSetup/defaultsetup instead
	--frame.powerBar:SetStatusBarTexture("Interface\\AddOns\\ClixFrames\\media\\statusbar.tga")
	--frame.powerBar.background:SetTexture("Interface\\AddOns\\ClixFrames\\media\\statusbar.tga")
	-- adjust background
	frame.powerBar.background:SetVertexColor(r, g, b, 0.2)
	-- adjust foreground
	frame.powerBar:SetStatusBarColor(r, g, b)
end


function ClixFrames.SecureHookDefaultCompactUnitFrameSetUp(frame)
	print("DefaultCompactUnitFrameSetup called!")

	frame.background:Hide()

	local db = ClixFrames.db.profile
	local texture = LSM:Fetch("statusbar", db.foregroundTexture)

	-- healthBar
	frame.healthBar:SetStatusBarTexture(texture, "BORDER")

	-- powerBar
	frame.powerBar:SetStatusBarTexture(texture, "BORDER")
	frame.powerBar.background:SetTexture(texture)

	ClixFrames.SetStatusTextFont(frame, LSM:Fetch("font", db.statusTextFont))
	ClixFrames.SetNameFont(frame, LSM:Fetch("font", db.nameFont))
	ClixFrames.SetStatusTextHeight(frame, db.statusTextHeight)
	ClixFrames.SetNameHeight(frame, db.nameHeight)

	frame.powerBar:ClearAllPoints()
	frame.powerBar:SetPoint("Topleft", frame.healthBar, "Bottomleft", 0, -1)
	frame.powerBar:SetPoint("Bottomright", frame, "Bottomright", -1, 1) 
	frame.powerBar:SetStatusBarTexture("Interface\\AddOns\\ClixFrames\\media\\statusbar.tga")
	frame.powerBar.background:SetTexture("Interface\\AddOns\\ClixFrames\\media\\statusbar.tga")

end


function ClixFrames.SecureHookSetUpFrame(frame, updateAll)
	local db = ClixFrames.db.profile
	-- XXX not sure if it's called in CompactUnitFrameSetUp
	-- debug:
	print("ClixFrames.HookSetUpFrame called on frame: |cFFFF0000"..tostring(frame:GetName()).." - "..tostring(updateAll))
	print("CompactUnitFrame_SetUpFrame called")

	local texture = LSM:Fetch("statusbar", db.foregroundTexture)

	frame.background:Hide()

	--frame.healthBar:SetStatusBarTexture(texture, "BORDER")
	ClixFrames.SetForegroundTexture(frame, texture)

	ClixFrames.SetStatusTextFont(frame, LSM:Fetch("font", db.statusTextFont))
	ClixFrames.SetStatusTextHeight(frame, db.statusTextHeight)

	ClixFrames.SetNameFont(frame, LSM:Fetch("font", db.nameFont))
	ClixFrames.SetNameHeight(frame, db.nameHeight)
	--[[
	ClixFrames.SetPowerBarBackgroundColor()
	ClixFrames.SetPowerBarStatusBarColor()
	ClixFrames.SetHealthBarBackgroundColor()
	]]
	--frame.healthBar.background:SetTexture("Interface\\AddOns\\ClixFrames\\media\\statusbar.tga", "BORDER")

	frame.powerBar:SetStatusBarTexture(texture, "BORDER")
	frame.powerBar.background:SetTexture("Interface\\AddOns\\ClixFrames\\media\\statusbar.tga", "BORDER")

	local manualBackdrop = {
		bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
		edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
		tile = true, edgeSize = 1, tileSize = 5,
	}

	frame:SetBackdrop(manualBackdrop)
	frame:SetBackdropColor(0, 0, 0, 0.8)
	frame:SetBackdropBorderColor(0, 0, 0, 1)

	if ( not frame.powerBar.borderTop ) then
		local powerBarBorder = frame.powerBar:CreateTexture(nil, "Artwork")
		--powerBarBorder:SetParent(frame.powerBar)
		frame.powerBar.borderTop = powerBarBorder
		powerBarBorder:SetTexture(0, 0, 0, 1)
		powerBarBorder:SetPoint("Bottomleft", frame.powerBar, "Topleft")
		powerBarBorder:SetPoint("Bottomright", frame.powerBar, "Topright")
		powerBarBorder:SetHeight(1)
	end
end


-- CompactUnitFrame_SetUpFrame gets only called once per frame

--hooksecurefunc("CompactUnitFrame_SetUpFrame", ClixFrames.changeBackground)
--hooksecurefunc("DefaultCompactUnitFrameSetup", ClixFrames.changeBackground)
--hooksecurefunc("DefaultCompactMiniFrameSetup", ClixFrames.changeBackground)
