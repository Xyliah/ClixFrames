local ClixFrames = LibStub("AceAddon-3.0"):GetAddon("ClixFrames")

local dataTable = {
	-- [spell] = { show }
	[774]	 = {false}, -- rejuvenation
	[114250] = {true}, -- selfless healer
	[155777] = {false}, -- rejuvenation (germination)
}

function ClixFrames.ShouldDisplayAura(unit, index, filter, isDebuff)
	local auraName, _, _, _, debuffType, auraDuration, _, caster, canStealOrPurge, _, spellID, canApply, auraIsBoss = (isDebuff and UnitDebuff or UnitBuff)(unit, index, filter)
	if not auraName then return nil end

	if dataTable[spellID] then
		return dataTable[1]
	end
	
	-- fallback to blizz defaults
	if isDebuff then
		return CompactUnitFrame_UtilShouldDisplayDebuff(unit, index, filter)
	else
		return CompactUnitFrame_UtilShouldDisplayBuff(unit, index, filter)
	end
end

function ClixFrames.UpdateBuffs(frame)
	if not frame.optionTable.displayBuffs then return end
	local unit = frame.displayedUnit
	if not unit then return end

	local index, frameNum, filter = 1, 1, nil
	while frameNum <= frame.maxBuffs do
		local buffName = UnitBuff(unit, index, filter)
		if ( buffName ) then
			if ( ClixFrames.ShouldDisplayAura(unit, index, filter) ) then
				local buffFrame = frame.buffFrames[frameNum]
				CompactUnitFrame_UtilSetBuff(buffFrame, unit, index, filter)
				frameNum = frameNum + 1
			end
		else 
			break
		end
		index = index + 1
	end
	for i = frameNum, frame.maxBuffs do
		frame.buffFrames[i]:Hide()
	end
end

hooksecurefunc("CompactUnitFrame_UpdateBuffs", ClixFrames.UpdateBuffs)

-- growing buffs - prototype

local auras = {
	-- ["spell"] = { filter }
	-- possible options: mine (filter = "PLAYER")
	[1] = {
		-- custom stuff
		-- Paladin
		["Selfless Healer"] = { filter = "PLAYER" },
		["Supplication"] = { filter = "PLAYER" },
		["Illuminated Healing"] = { filter = "PLAYER" },
		-- Druid
		["Rejuvenation"] = { filter = "PLAYER" },
		["Rejuvenation (Germination)"] = { filter = "PLAYER" },
		-- Rogue
		["Burst of Speed"] = { },
		["Feint"] = {},
	},
	[2] = {
		-- self cd's
		-- paladin
		["Divine Protection"] = { },
		["Divine Shield"] = { },
		["Guardian of Ancient Kings"] = { },
		["Holy Avenger"] = { },
		-- dk
		["Anti-Magic Shell"] = { },
		["Dancing Rune Weapon"] = { },
		["Icebound Foritude"] = { },
		["Vampiric Blood"] = { },
		-- druid
		["Barkskin"] = { },
		["Heart of the Wild"] = { },
		["Survival Instincts"] = { },
		-- hunter
		["Deterrence"] = { },
		-- mage
		["Ice Block"] = { },
		["Greater Invisibility"] = { },
		-- monk
		["Fortifying Brew"] = { },
		-- priest
		["Dispersion"] = { },
		-- rogue
		["Evasion"] = { },
		["Cloak of Shadows"] = { },
		-- shaman
		["Shamanistic Rage"] = { },
		-- warlock
		["Dark Bargain"] = { },
		["Dark Regeneration"] = { },
		-- warrior
		["Last Stand"] = { },
		["Shield Wall"] = { },
	},
	[3] = {
		-- paladin
		["Hand of Sacrifice"] = { },
		["Hand of Freedom"] = { },
		["Hand of Protection"] = { },
		["Devotion Aura"] = { },
		-- dk
		["Anti-Magic Zone"] = { },
		-- druid
		["Stampeding Roar"] = { },
		["Ironbark"] = { },
		-- hunter
		["Aspect of the Fox"] = { },
		-- mage
		["Amplify Magic"] = { },
		-- monk
		["Life Cocoon"] = { },
		-- priest
		["Guardian Spirit"] = { },
		["Pain Suppression"] = { },
		["Power Word Barrier"] = { },
		["Vampiric Embrace"] = { },
		["Spirit Shell"] = { },
		-- rogue
		["Smoke Bomb"] = { },
		-- shaman
		["Ancestral Guidance"] = { },
		["Spirit Link Totem"] = { },
		-- warrior
		["Rallyinc Cry"] = { },
		["Vigilance"] = { },
		["Safeguard"] = { },
	},
}

local indicators = {
	-- { numAuras, pos, relPos, xOffset, yOffset, growPos, growRelPos, growXOffset, growYOffset }
	[1] = { 2, "Topright", "Topright", -2, -2, "Topright", "Topleft", 0, 0 },
	[2] = { 2, "Topleft", "Top", -20, -2, "Topleft", "Topright", 0, 0 },
	[3] = { 2, "Topleft", "Topleft", 2, -2, "Topleft", "Topright", 0, 0 },
}

-- growLeft|frame2 { "Topright", frame1, "Topleft" }
-- growRight|frame2 { "Topleft", frame1, "Topright" }
-- growUp|frame2 { "Bottomright", frame1, "Topright" }
-- growDown|frame2 { "Topright", frame1, "Bottomright" }


-- more or less the same as ClixFramesAuraTemplate but written in lua
function ClixFrames.Constructor(self, name)
	local frame = CreateFrame("Button", name, self, "CompactAuraTemplate")
	frame:RegisterForClicks("LeftButtonDown", "RightButtonUp")

	frame.text = frame:CreateFontString(nil, "Overlay")
	frame.text:SetFont("Interface\\AddOns\\ClixFrames\\media\\HandelGothicBT.ttf", 8, "Outline")
	frame.text:SetPoint("Bottomright", frame, "Bottomright")

	frame:SetScript("OnUpdate", function(self, elapsed)
		-- either use OnUpdate or animation to calculate timeLeft
		if ( GameTooltip:IsOwned(self) ) then
			GameTooltip:SetUnitBuff(self:GetParent().displayedUnit, self:GetID())
		end
	end)
	frame:SetScript("OnEnter", function(self, motion)
		GameTooltip:SetOwner(self, "Anchor_Right", 0, 0)
		GameTooltip:SetUnitBuff(self:GetParent().displayedUnit, self:GetID())
	end)
	frame:SetScript("OnLeave", function(self, motion)
		GameTooltip:Hide()
	end)

	return frame
end


function ClixFrames.SetupCustomFrames(frame)
	ClixFrames.AuraFrames = ClixFrames.AuraFrames or {}
	-- in case the table isn't created yet
	if not frame.auraFrames then frame.auraFrames = {} end
	-- create frames
	if not frame.auraFrames[1] then
		for i=1, #indicators do
			frame.auraFrames[i] = frame.auraFrames[i] or {}
			for k=1, indicators[i][1] do
				-- name it something like: "ClixFramesIndicator1CompactRaidFrame1AuraFrame1"
				-- local auraFrame = CreateFrame("Frame", "ClixFramesIndicator"..index..frame:GetName().."AuraFrame"..i)
				--local auraFrame = CreateFrame("Frame", frame:GetName().."Indicator"..i.."AuraFrame"..k, frame, "ClixFramesAuraTemplate")
				local auraFrame = ClixFrames.Constructor(frame, frame:GetName().."Indicator"..i.."AuraFrame"..k)
				--print(auraFrame:GetName())
				auraFrame:SetSize(16,16)
				frame.auraFrames[i][k] = auraFrame
				ClixFrames.AuraFrames[#ClixFrames.AuraFrames+1] = auraFrame

				-- position the frames
				if ( k == 1 ) then
					frame.auraFrames[i][1]:SetPoint(indicators[i][2], frame, indicators[i][3], indicators[i][4], indicators[i][5])
				else
					frame.auraFrames[i][k]:SetPoint(indicators[i][6], frame.auraFrames[i][k-1], indicators[i][7], indicators[i][8], indicators[i][9])
				end
			end
			frame.auraFrames[i].maxAuras = indicators[i][1]
		end
	end
	
end

function ClixFrames:UpdateText(frame, expirationTime)
	local now = GetTime()
	local timeLeft = expirationTime - now - 0.5

	if ( timeLeft > 0 ) then
		frame.text:SetFormattedText("%.0f", timeLeft)
		-- recursive
		self:ScheduleTimer("UpdateText", 1, frame, expirationTime)
	end
end

function ClixFrames.UtilSetAura(auraFrame, unit, index, filter, showCooldownText)
	local name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, shouldConsolidate, spellId, canApplyAura = UnitBuff(unit, index, filter)
	--print(tostring(filter) .. " - " .. tostring(name) .. " unitcaster: " .. tostring(unitCaster))
	auraFrame.icon:SetTexture(icon)

	if ( type(count) == "number" and count > 1 ) then
		local countText = count;
		auraFrame.count:Show()
		auraFrame.count:SetText(countText)
	else
		auraFrame.count:Hide()
	end
	auraFrame:SetID(index) -- needed for tooltip
	if ( expirationTime and expirationTime ~= 0 and not ClixFrames.HideCooldown ) then
		local startTime = expirationTime - duration
		auraFrame.cooldown:SetCooldown(startTime, duration)
		auraFrame.cooldown:Show()
	else
		auraFrame.cooldown:Hide()
	end

	if ( showCooldownText ) then
		auraFrame.text:SetFormattedText("%.0f", expirationTime - GetTime())
	end

	auraFrame:Show()
end

ClixFrames.ShowCooldownText = false
ClixFrames.HideCooldown = false

function ClixFrames.UpdateCustomAuras(frame)
	-- if there is no frame, there is no reason to continue
	if not frame.auraFrames or not frame.auraFrames[1].maxAuras then return end

	for i=1, #indicators do
		local index, frameNum, filter = 1, 1, nil
		while ( frameNum <= frame.auraFrames[i].maxAuras ) do
			local buffName = UnitBuff(frame.displayedUnit, index, filter)
			if ( buffName ) then
				local data = auras[i][buffName]
				if ( data ) then
					local auraFrame = frame.auraFrames[i][frameNum]
					--print(auraFrame:GetName())
					local player = "PLAYER"
					ClixFrames.UtilSetAura(auraFrame, frame.displayedUnit, index, data.filter, false)
					frameNum = frameNum + 1
				end
			else
				break
			end
			index = index + 1
		end

		-- hide everything which shouldn't be there!
		for k=frameNum, frame.auraFrames[i].maxAuras do
			local auraFrame = frame.auraFrames[i][k]
			auraFrame:Hide()
		end

	end
end

-- make an option to create icons onlny on UnitFrames instead of UnitFrames + MiniFrames (petframes)
--hooksecurefunc("DefaultCompactUnitFrameSetup", ClixFrames.SetupCustomFrames)
hooksecurefunc("CompactUnitFrame_SetUpFrame", ClixFrames.SetupCustomFrames)
hooksecurefunc("CompactUnitFrame_UpdateAuras", ClixFrames.UpdateCustomAuras)
