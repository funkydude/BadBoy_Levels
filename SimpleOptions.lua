
local levelsBox = CreateFrame("EditBox", nil, BadBoyConfig, "InputBoxTemplate")
levelsBox:SetPoint("TOPLEFT", BadBoyConfigPopupButton, "BOTTOMLEFT", 10, -25)
levelsBox:SetAutoFocus(false)
levelsBox:SetNumeric(true)
levelsBox:EnableMouse(true)
levelsBox:SetWidth(30)
levelsBox:SetHeight(20)
levelsBox:SetMaxLetters(2)
levelsBox:Show()

levelsBox:SetScript("OnHide", function(frame)
	local n = tonumber(frame:GetText())
	if not n or n == "" then frame:SetText(BADBOY_LEVEL or 1) print("|cFF33FF99BadBoy_Levels|r == "..(BADBOY_LEVEL or 1)) return end
	if n < 1 then
		frame:SetText(BADBOY_LEVEL or 1)
		print("|cFF33FF99BadBoy_Levels|r == "..(BADBOY_LEVEL or 1))
	else
		BADBOY_LEVEL = n
		print("|cFF33FF99BadBoy_Levels|r == "..n)
	end
end)
levelsBox:SetScript("OnShow", function(frame)
	frame:SetText(BADBOY_LEVEL or 1)
end)

local note = "Note: Death Knights lower than level 58 are blocked"
do
	local L = GetLocale()
	if L == "esES" or L == "esMX" then

	elseif L == "ptBR" then

	elseif L == "deDE" then

	elseif L == "frFR" then

	elseif L == "ruRU" then

	elseif L == "koKR" then

	elseif L == "zhTW" then

	elseif L == "zhCN" then

	elseif L == "itIT" then

	end
end

local dkText = levelsBox:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
dkText:SetPoint("LEFT", levelsBox, "RIGHT", 40, 1)
dkText:SetText(note)
dkText:SetTextColor(0.5, 0.5, 0.5)

BadBoyLevelsConfigTitle:SetText("BadBoy_Levels @project-version@") --wowace magic, replaced with tag version

