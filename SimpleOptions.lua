
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
	BadBoyLevelsConfigTitle:SetText("BadBoy_Levels @project-version@") --wowace magic, replaced with tag version
	levelsBox:SetScript("OnHide", function(frame)
		local n = tonumber(frame:GetText())
		if not n or n == "" then frame:SetText(BADBOY_LEVEL or 1) print("|cFF33FF99BadBoy_Levels|r == "..(BADBOY_LEVEL or 1)) return end
		if n <1 or n>79 then
			frame:SetText(BADBOY_LEVEL or 1)
			print("|cFF33FF99BadBoy_Levels|r == "..(BADBOY_LEVEL or 1))
		else
			BADBOY_LEVEL = n
			print("|cFF33FF99BadBoy_Levels|r == "..n)
		end
	end)
end

