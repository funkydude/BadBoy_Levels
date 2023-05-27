
local L_reqlevel = "Required Level"
local L_blockall = "Block All Whispers"
local L_allowfriends = "Allow Friends"
local L_allowguild = "Allow Guild"
local L_allowgroup = "Allow Group"
do
	local L = GetLocale()
	if L == "esES" or L == "esMX" then
		--L_reqlevel = "Required Level"
		--L_blockall = "Block All Whispers"
		--L_allowfriends = "Allow Friends"
		--L_allowguild = "Allow Guild"
		--L_allowgroup = "Allow Group"
	elseif L == "ptBR" then
		--L_reqlevel = "Required Level"
		--L_blockall = "Block All Whispers"
		--L_allowfriends = "Allow Friends"
		--L_allowguild = "Allow Guild"
		--L_allowgroup = "Allow Group"
	elseif L == "deDE" then
		--L_reqlevel = "Required Level"
		--L_blockall = "Block All Whispers"
		--L_allowfriends = "Allow Friends"
		--L_allowguild = "Allow Guild"
		--L_allowgroup = "Allow Group"
	elseif L == "frFR" then
		--L_reqlevel = "Required Level"
		--L_blockall = "Block All Whispers"
		--L_allowfriends = "Allow Friends"
		--L_allowguild = "Allow Guild"
		--L_allowgroup = "Allow Group"
	elseif L == "ruRU" then
		L_reqlevel = "Требуемый уровень"
		L_blockall = "Блокировать все шепоты"
		L_allowfriends = "Разрешить друзей"
		L_allowguild = "Разрешить гильдию"
		L_allowgroup = "Разрешить группу"
	elseif L == "koKR" then
		--L_reqlevel = "Required Level"
		--L_blockall = "Block All Whispers"
		--L_allowfriends = "Allow Friends"
		--L_allowguild = "Allow Guild"
		--L_allowgroup = "Allow Group"
	elseif L == "zhTW" then
		--L_reqlevel = "Required Level"
		--L_blockall = "Block All Whispers"
		--L_allowfriends = "Allow Friends"
		--L_allowguild = "Allow Guild"
		--L_allowgroup = "Allow Group"
	elseif L == "zhCN" then
		--L_reqlevel = "Required Level"
		--L_blockall = "Block All Whispers"
		--L_allowfriends = "Allow Friends"
		--L_allowguild = "Allow Guild"
		--L_allowgroup = "Allow Group"
	elseif L == "itIT" then
		--L_reqlevel = "Required Level"
		--L_blockall = "Block All Whispers"
		--L_allowfriends = "Allow Friends"
		--L_allowguild = "Allow Guild"
		--L_allowgroup = "Allow Group"
	end
end

--[[ Level input box ]]--
local levelInputBox = CreateFrame("EditBox", nil, BadBoyConfig, "InputBoxTemplate")
levelInputBox:SetPoint("TOPLEFT", BadBoyLevelsConfigTitle, "BOTTOMLEFT", 10, -3)
levelInputBox:SetAutoFocus(false)
levelInputBox:SetNumeric(true)
levelInputBox:SetWidth(20)
levelInputBox:SetHeight(20)
levelInputBox:SetMaxLetters(2)
levelInputBox:Show()

levelInputBox:SetScript("OnHide", function(frame)
	local n = tonumber(frame:GetText())
	if not n or n < 1 then
		return
	else
		BADBOY_LEVELS_DB.level = n
	end
end)
levelInputBox:SetScript("OnShow", function(frame)
	frame:SetText(BADBOY_LEVELS_DB.level)
	if BADBOY_LEVELS_DB.blockall then
		frame:Disable()
		frame:SetTextColor(0.5, 0.5, 0.5)
	end
end)

--[[ Input box text ]]--
local reqLevelsTextBox = levelInputBox:CreateFontString(nil, nil, "GameFontHighlight")
reqLevelsTextBox:SetPoint("LEFT", levelInputBox, "RIGHT", 10, 0)
reqLevelsTextBox:SetText(L_reqlevel)

--[[ Block all whispers checkbox 1/2 ]]--
local blockAllBtn = CreateFrame("CheckButton", nil, BadBoyConfig, "OptionsBaseCheckButtonTemplate")
blockAllBtn:SetPoint("TOPLEFT", levelInputBox, "BOTTOMLEFT", -5, 0)
blockAllBtn:SetScript("OnShow", function(frame)
	frame:SetChecked(BADBOY_LEVELS_DB.blockall)
	if BADBOY_LEVELS_DB.blockall then
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
	BADBOY_LEVELS_DB.allowfriends = tick
	if tick then
		PlaySound(856) -- SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON
	else
		PlaySound(857) -- SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF
	end
end)

local allowFriendsBtnText = allowFriendsBtn:CreateFontString(nil, nil, "GameFontHighlight")
allowFriendsBtnText:SetPoint("LEFT", allowFriendsBtn, "RIGHT", 0, 1)
allowFriendsBtnText:SetText(L_allowfriends)

allowFriendsBtn:SetScript("OnShow", function(frame)
	frame:SetChecked(BADBOY_LEVELS_DB.allowfriends)
	if not BADBOY_LEVELS_DB.blockall then
		frame:Disable()
		allowFriendsBtnText:SetTextColor(0.5, 0.5, 0.5)
	end
end)

--[[ Allow guild checkbox ]]--
local allowGuildBtn = CreateFrame("CheckButton", nil, BadBoyConfig, "OptionsBaseCheckButtonTemplate")
allowGuildBtn:SetPoint("LEFT", allowFriendsBtn, "RIGHT", 110, 0)
allowGuildBtn:SetScript("OnClick", function(frame)
	local tick = frame:GetChecked()
	BADBOY_LEVELS_DB.allowguild = tick
	if tick then
		PlaySound(856) -- SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON
	else
		PlaySound(857) -- SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF
	end
end)

local allowGuildBtnText = allowGuildBtn:CreateFontString(nil, nil, "GameFontHighlight")
allowGuildBtnText:SetPoint("LEFT", allowGuildBtn, "RIGHT", 0, 1)
allowGuildBtnText:SetText(L_allowguild)

allowGuildBtn:SetScript("OnShow", function(frame)
	frame:SetChecked(BADBOY_LEVELS_DB.allowguild)
	if not BADBOY_LEVELS_DB.blockall then
		frame:Disable()
		allowGuildBtnText:SetTextColor(0.5, 0.5, 0.5)
	end
end)

--[[ Allow group checkbox ]]--
local allowGroupBtn = CreateFrame("CheckButton", nil, BadBoyConfig, "OptionsBaseCheckButtonTemplate")
allowGroupBtn:SetPoint("LEFT", allowGuildBtn, "RIGHT", 110, 0)
allowGroupBtn:SetScript("OnClick", function(frame)
	local tick = frame:GetChecked()
	BADBOY_LEVELS_DB.allowgroup = tick
	if tick then
		PlaySound(856) -- SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON
	else
		PlaySound(857) -- SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF
	end
end)

local allowGroupBtnText = allowGroupBtn:CreateFontString(nil, nil, "GameFontHighlight")
allowGroupBtnText:SetPoint("LEFT", allowGroupBtn, "RIGHT", 0, 1)
allowGroupBtnText:SetText(L_allowgroup)

allowGroupBtn:SetScript("OnShow", function(frame)
	frame:SetChecked(BADBOY_LEVELS_DB.allowgroup)
	if not BADBOY_LEVELS_DB.blockall then
		frame:Disable()
		allowGroupBtnText:SetTextColor(0.5, 0.5, 0.5)
	end
end)

--[[ Block all whispers checkbox 2/2 ]]--
blockAllBtn:SetScript("OnClick", function(frame)
	local tick = frame:GetChecked()
	BADBOY_LEVELS_DB.blockall = tick
	if tick then
		levelInputBox:Disable()
		levelInputBox:SetTextColor(0.5, 0.5, 0.5)
		reqLevelsTextBox:SetTextColor(0.5, 0.5, 0.5)

		allowFriendsBtn:Enable()
		allowFriendsBtnText:SetTextColor(1, 1, 1)

		allowGuildBtn:Enable()
		allowGuildBtnText:SetTextColor(1, 1, 1)

		allowGroupBtn:Enable()
		allowGroupBtnText:SetTextColor(1, 1, 1)

		PlaySound(856) -- SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON
	else
		levelInputBox:Enable()
		levelInputBox:SetTextColor(1, 1, 1)
		reqLevelsTextBox:SetTextColor(1, 1, 1)

		BADBOY_LEVELS_DB.allowfriends = false
		allowFriendsBtn:Hide() allowFriendsBtn:Show()
		allowFriendsBtn:Disable()
		allowFriendsBtnText:SetTextColor(0.5, 0.5, 0.5)

		BADBOY_LEVELS_DB.allowguild = false
		allowGuildBtn:Hide() allowGuildBtn:Show()
		allowGuildBtn:Disable()
		allowGuildBtnText:SetTextColor(0.5, 0.5, 0.5)

		BADBOY_LEVELS_DB.allowgroup = false
		allowGroupBtn:Hide() allowGroupBtn:Show()
		allowGroupBtn:Disable()
		allowGroupBtnText:SetTextColor(0.5, 0.5, 0.5)

		PlaySound(857) -- SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF
	end
end)

BadBoyLevelsConfigTitle:SetText("BadBoy_Levels")
