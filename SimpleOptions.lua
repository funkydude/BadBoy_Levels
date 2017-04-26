
local L_reqlevels = "Required Levels"
local L_others = "Others"
local L_deathknight = "Death Knight"
local L_demonhunter = "Demon Hunter"
local L_blockall = "Block All Whispers"
local L_allowfriends = "Allow Friends"
local L_allowguild = "Allow Guild"
local L_allowgroup = "Allow Group"
do
	local L = GetLocale()
	if L == "esES" or L == "esMX" then
		--L_reqlevels = "Required Levels"
		--L_others = "Others"
		--L_deathknight = "Death Knight"
		--L_demonhunter = "Demon Hunter"
		--L_blockall = "Block All Whispers"
		--L_allowfriends = "Allow Friends"
		--L_allowguild = "Allow Guild"
		--L_allowgroup = "Allow Group"
	elseif L == "ptBR" then
		--L_reqlevels = "Required Levels"
		--L_others = "Others"
		--L_deathknight = "Death Knight"
		--L_demonhunter = "Demon Hunter"
		--L_blockall = "Block All Whispers"
		--L_allowfriends = "Allow Friends"
		--L_allowguild = "Allow Guild"
		--L_allowgroup = "Allow Group"
	elseif L == "deDE" then
		--L_reqlevels = "Required Levels"
		--L_others = "Others"
		--L_deathknight = "Death Knight"
		--L_demonhunter = "Demon Hunter"
		--L_blockall = "Block All Whispers"
		--L_allowfriends = "Allow Friends"
		--L_allowguild = "Allow Guild"
		--L_allowgroup = "Allow Group"
	elseif L == "frFR" then
		--L_reqlevels = "Required Levels"
		--L_others = "Others"
		--L_deathknight = "Death Knight"
		--L_demonhunter = "Demon Hunter"
		--L_blockall = "Block All Whispers"
		--L_allowfriends = "Allow Friends"
		--L_allowguild = "Allow Guild"
		--L_allowgroup = "Allow Group"
	elseif L == "ruRU" then
		--L_reqlevels = "Required Levels"
		--L_others = "Others"
		--L_deathknight = "Death Knight"
		--L_demonhunter = "Demon Hunter"
		--L_blockall = "Block All Whispers"
		--L_allowfriends = "Allow Friends"
		--L_allowguild = "Allow Guild"
		--L_allowgroup = "Allow Group"
	elseif L == "koKR" then
		--L_reqlevels = "Required Levels"
		--L_others = "Others"
		--L_deathknight = "Death Knight"
		--L_demonhunter = "Demon Hunter"
		--L_blockall = "Block All Whispers"
		--L_allowfriends = "Allow Friends"
		--L_allowguild = "Allow Guild"
		--L_allowgroup = "Allow Group"
	elseif L == "zhTW" then
		--L_reqlevels = "Required Levels"
		--L_others = "Others"
		--L_deathknight = "Death Knight"
		--L_demonhunter = "Demon Hunter"
		--L_blockall = "Block All Whispers"
		--L_allowfriends = "Allow Friends"
		--L_allowguild = "Allow Guild"
		--L_allowgroup = "Allow Group"
	elseif L == "zhCN" then
		--L_reqlevels = "Required Levels"
		--L_others = "Others"
		--L_deathknight = "Death Knight"
		--L_demonhunter = "Demon Hunter"
		--L_blockall = "Block All Whispers"
		--L_allowfriends = "Allow Friends"
		--L_allowguild = "Allow Guild"
		--L_allowgroup = "Allow Group"
	elseif L == "itIT" then
		--L_reqlevels = "Required Levels"
		--L_others = "Others"
		--L_deathknight = "Death Knight"
		--L_demonhunter = "Demon Hunter"
		--L_blockall = "Block All Whispers"
		--L_allowfriends = "Allow Friends"
		--L_allowguild = "Allow Guild"
		--L_allowgroup = "Allow Group"
	end
end

--[[ DH input box ]]--
local levelsBoxDH = CreateFrame("EditBox", nil, BadBoyConfig, "InputBoxTemplate")
levelsBoxDH:SetPoint("TOPLEFT", BadBoyLevelsConfigTitle, "BOTTOMLEFT", 5, -3)
levelsBoxDH:SetAutoFocus(false)
levelsBoxDH:SetNumeric(true)
levelsBoxDH:SetWidth(30)
levelsBoxDH:SetHeight(20)
levelsBoxDH:SetMaxLetters(3)
levelsBoxDH:Show()

levelsBoxDH:SetScript("OnEnter", function(self)
	GameTooltip:SetOwner(self, "ANCHOR_TOP")
	GameTooltip:AddLine(L_demonhunter, 0.5, 0.5, 0)
	GameTooltip:Show()
end)
levelsBoxDH:SetScript("OnLeave", GameTooltip_Hide)
levelsBoxDH:SetScript("OnHide", function(frame)
	local n = tonumber(frame:GetText())
	if not n or n < 1 then
		return
	else
		BADBOY_LEVELS.dhlevel = n
	end
end)
levelsBoxDH:SetScript("OnShow", function(frame)
	frame:SetText(BADBOY_LEVELS.dhlevel)
	if BADBOY_LEVELS.blockall then
		frame:Disable()
		frame:SetTextColor(0.5, 0.5, 0.5)
	end
end)

--[[ DK input box ]]--
local levelsBoxDK = CreateFrame("EditBox", nil, BadBoyConfig, "InputBoxTemplate")
levelsBoxDK:SetPoint("LEFT", levelsBoxDH, "RIGHT", 10, 0)
levelsBoxDK:SetAutoFocus(false)
levelsBoxDK:SetNumeric(true)
levelsBoxDK:SetWidth(30)
levelsBoxDK:SetHeight(20)
levelsBoxDK:SetMaxLetters(3)
levelsBoxDK:Show()

levelsBoxDK:SetScript("OnEnter", function(self)
	GameTooltip:SetOwner(self, "ANCHOR_TOP")
	GameTooltip:AddLine(L_deathknight, 0.5, 0.5, 0)
	GameTooltip:Show()
end)
levelsBoxDK:SetScript("OnLeave", GameTooltip_Hide)
levelsBoxDK:SetScript("OnHide", function(frame)
	local n = tonumber(frame:GetText())
	if not n or n < 1 then
		return
	else
		BADBOY_LEVELS.dklevel = n
	end
end)
levelsBoxDK:SetScript("OnShow", function(frame)
	frame:SetText(BADBOY_LEVELS.dklevel)
	if BADBOY_LEVELS.blockall then
		frame:Disable()
		frame:SetTextColor(0.5, 0.5, 0.5)
	end
end)

--[[ Other input box ]]--
local levelsBoxOther = CreateFrame("EditBox", nil, BadBoyConfig, "InputBoxTemplate")
levelsBoxOther:SetPoint("LEFT", levelsBoxDK, "RIGHT", 10, 0)
levelsBoxOther:SetAutoFocus(false)
levelsBoxOther:SetNumeric(true)
levelsBoxOther:SetWidth(30)
levelsBoxOther:SetHeight(20)
levelsBoxOther:SetMaxLetters(3)
levelsBoxOther:Show()

levelsBoxOther:SetScript("OnEnter", function(self)
	GameTooltip:SetOwner(self, "ANCHOR_TOP")
	GameTooltip:AddLine(L_others, 0.5, 0.5, 0)
	GameTooltip:Show()
end)
levelsBoxOther:SetScript("OnLeave", GameTooltip_Hide)
levelsBoxOther:SetScript("OnHide", function(frame)
	local n = tonumber(frame:GetText())
	if not n or n < 1 then
		return
	else
		BADBOY_LEVELS.level = n
	end
end)
levelsBoxOther:SetScript("OnShow", function(frame)
	frame:SetText(BADBOY_LEVELS.level)
	if BADBOY_LEVELS.blockall then
		frame:Disable()
		frame:SetTextColor(0.5, 0.5, 0.5)
	end
end)

--[[ Input box text ]]--
local reqLevelsTextBox = levelsBoxOther:CreateFontString(nil, nil, "GameFontHighlight")
reqLevelsTextBox:SetPoint("LEFT", levelsBoxOther, "RIGHT", 10, 0)
reqLevelsTextBox:SetText(L_reqlevels)

--[[ Block all whispers checkbox 1/2 ]]--
local blockAllBtn = CreateFrame("CheckButton", nil, BadBoyConfig, "OptionsBaseCheckButtonTemplate")
blockAllBtn:SetPoint("TOPLEFT", levelsBoxDH, "BOTTOMLEFT", -5, 0)
blockAllBtn:SetScript("OnShow", function(frame)
	frame:SetChecked(BADBOY_LEVELS.blockall)
	if BADBOY_LEVELS.blockall then
		reqLevelsTextBox:SetTextColor(0.5, 0.5, 0.5)
	end
end)

local blockAllBtnText = blockAllBtn:CreateFontString(nil, nil, "GameFontHighlight")
blockAllBtnText:SetPoint("LEFT", blockAllBtn, "RIGHT", 0, 1)
blockAllBtnText:SetText(L_blockall)

--[[ Allow friends checkbox ]]--
local allowFriendsBtn = CreateFrame("CheckButton", nil, BadBoyConfig, "OptionsBaseCheckButtonTemplate")
allowFriendsBtn:SetPoint("TOPLEFT", blockAllBtn, "BOTTOMLEFT", 30, 5)
allowFriendsBtn:SetScript("OnClick", function(frame)
	local tick = frame:GetChecked()
	BADBOY_LEVELS.allowfriends = tick
	PlaySound(tick and "igMainMenuOptionCheckBoxOn" or "igMainMenuOptionCheckBoxOff")
end)

local allowFriendsBtnText = allowFriendsBtn:CreateFontString(nil, nil, "GameFontHighlight")
allowFriendsBtnText:SetPoint("LEFT", allowFriendsBtn, "RIGHT", 0, 1)
allowFriendsBtnText:SetText(L_allowfriends)

allowFriendsBtn:SetScript("OnShow", function(frame)
	frame:SetChecked(BADBOY_LEVELS.allowfriends)
	if not BADBOY_LEVELS.blockall then
		frame:Disable()
		allowFriendsBtnText:SetTextColor(0.5, 0.5, 0.5)
	end
end)

--[[ Allow guild checkbox ]]--
local allowGuildBtn = CreateFrame("CheckButton", nil, BadBoyConfig, "OptionsBaseCheckButtonTemplate")
allowGuildBtn:SetPoint("LEFT", allowFriendsBtn, "RIGHT", 110, 0)
allowGuildBtn:SetScript("OnClick", function(frame)
	local tick = frame:GetChecked()
	BADBOY_LEVELS.allowguild = tick
	PlaySound(tick and "igMainMenuOptionCheckBoxOn" or "igMainMenuOptionCheckBoxOff")
end)

local allowGuildBtnText = allowGuildBtn:CreateFontString(nil, nil, "GameFontHighlight")
allowGuildBtnText:SetPoint("LEFT", allowGuildBtn, "RIGHT", 0, 1)
allowGuildBtnText:SetText(L_allowguild)

allowGuildBtn:SetScript("OnShow", function(frame)
	frame:SetChecked(BADBOY_LEVELS.allowguild)
	if not BADBOY_LEVELS.blockall then
		frame:Disable()
		allowGuildBtnText:SetTextColor(0.5, 0.5, 0.5)
	end
end)

--[[ Allow group checkbox ]]--
local allowGroupBtn = CreateFrame("CheckButton", nil, BadBoyConfig, "OptionsBaseCheckButtonTemplate")
allowGroupBtn:SetPoint("LEFT", allowGuildBtn, "RIGHT", 110, 0)
allowGroupBtn:SetScript("OnClick", function(frame)
	local tick = frame:GetChecked()
	BADBOY_LEVELS.allowgroup = tick
	PlaySound(tick and "igMainMenuOptionCheckBoxOn" or "igMainMenuOptionCheckBoxOff")
end)

local allowGroupBtnText = allowGroupBtn:CreateFontString(nil, nil, "GameFontHighlight")
allowGroupBtnText:SetPoint("LEFT", allowGroupBtn, "RIGHT", 0, 1)
allowGroupBtnText:SetText(L_allowgroup)

allowGroupBtn:SetScript("OnShow", function(frame)
	frame:SetChecked(BADBOY_LEVELS.allowgroup)
	if not BADBOY_LEVELS.blockall then
		frame:Disable()
		allowGroupBtnText:SetTextColor(0.5, 0.5, 0.5)
	end
end)

--[[ Block all whispers checkbox 2/2 ]]--
blockAllBtn:SetScript("OnClick", function(frame)
	local tick = frame:GetChecked()
	BADBOY_LEVELS.blockall = tick
	if tick then
		levelsBoxDH:Disable()
		levelsBoxDH:SetTextColor(0.5, 0.5, 0.5)
		levelsBoxDK:Disable()
		levelsBoxDK:SetTextColor(0.5, 0.5, 0.5)
		levelsBoxOther:Disable()
		levelsBoxOther:SetTextColor(0.5, 0.5, 0.5)
		reqLevelsTextBox:SetTextColor(0.5, 0.5, 0.5)

		allowFriendsBtn:Enable()
		allowFriendsBtnText:SetTextColor(1, 1, 1)

		allowGuildBtn:Enable()
		allowGuildBtnText:SetTextColor(1, 1, 1)

		allowGroupBtn:Enable()
		allowGroupBtnText:SetTextColor(1, 1, 1)

		PlaySound("igMainMenuOptionCheckBoxOn")
	else
		levelsBoxDH:Enable()
		levelsBoxDH:SetTextColor(1, 1, 1)
		levelsBoxDK:Enable()
		levelsBoxDK:SetTextColor(1, 1, 1)
		levelsBoxOther:Enable()
		levelsBoxOther:SetTextColor(1, 1, 1)
		reqLevelsTextBox:SetTextColor(1, 1, 1)

		BADBOY_LEVELS.allowfriends = false
		allowFriendsBtn:Hide() allowFriendsBtn:Show()
		allowFriendsBtn:Disable()
		allowFriendsBtnText:SetTextColor(0.5, 0.5, 0.5)

		BADBOY_LEVELS.allowguild = false
		allowGuildBtn:Hide() allowGuildBtn:Show()
		allowGuildBtn:Disable()
		allowGuildBtnText:SetTextColor(0.5, 0.5, 0.5)

		BADBOY_LEVELS.allowgroup = false
		allowGroupBtn:Hide() allowGroupBtn:Show()
		allowGroupBtn:Disable()
		allowGroupBtnText:SetTextColor(0.5, 0.5, 0.5)

		PlaySound("igMainMenuOptionCheckBoxOff")
	end
end)

BadBoyLevelsConfigTitle:SetText("BadBoy_Levels @project-version@") -- Packager magic, replaced with tag version

