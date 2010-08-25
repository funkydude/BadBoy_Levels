
do
	local levelsBox = CreateFrame("EditBox", "BadBoyLevelsEditBox", BadBoyConfig, "InputBoxTemplate")
	levelsBox:SetPoint("TOPLEFT", BadBoyConfigNoArtButton, "BOTTOMLEFT", 10, -25)
	levelsBox:SetAutoFocus(false)
	levelsBox:SetNumeric(true)
	levelsBox:EnableMouse(true)
	levelsBox:SetWidth(30)
	levelsBox:SetHeight(20)
	levelsBox:SetMaxLetters(2)
	levelsBox:Show()
	local dkText = levelsBox:CreateFontString("BadBoyLevelsDKText", "ARTWORK", "GameFontHighlight")
	dkText:SetPoint("LEFT", levelsBox, "RIGHT", 40, 1)
	dkText:SetText(NOTE_COLON.." "..LOCALIZED_CLASS_NAMES_MALE["DEATHKNIGHT"].." < "..(LEVEL_GAINED):format(58).." = "..ACTION_SPELL_MISSED_BLOCK)
	dkText:SetTextColor(0.5, 0.5, 0.5)
	BadBoyLevelsConfigTitle:SetText("BadBoy_Levels @project-version@") --wowace magic, replaced with tag version
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
end

