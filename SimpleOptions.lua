
local levelsBox = CreateFrame("EditBox", nil, BadBoyConfig, "InputBoxTemplate")
levelsBox:SetPoint("TOPLEFT", BadBoyLevelsConfigTitle, "BOTTOMLEFT", 5, 0)
levelsBox:SetAutoFocus(false)
levelsBox:SetNumeric(true)
levelsBox:SetWidth(30)
levelsBox:SetHeight(20)
levelsBox:SetMaxLetters(3)
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

local note = "Note: Death Knights lower than level 58 are blocked."
do
	local L = GetLocale()
	if L == "esES" or L == "esMX" then

	elseif L == "ptBR" then
		note = "Nota: Cavaleiros da Morte com nível menor que 58 serão bloqueados."
	elseif L == "deDE" then
		note = "Hinweis: Todesritter unter Stufe 58 werden blockiert."
	elseif L == "frFR" then

	elseif L == "ruRU" then
		note = "Примечание: блокируются рыцари смерти, уровень которых ниже 58."
	elseif L == "koKR" then

	elseif L == "zhTW" then

	elseif L == "zhCN" then
		note = "备注：低于58级的死亡骑士会被屏蔽。"
	elseif L == "itIT" then

	end
end

local dkText = levelsBox:CreateFontString(nil, nil, "GameFontHighlight")
dkText:SetPoint("LEFT", levelsBox, "RIGHT", 10, 0)
dkText:SetText(note)
dkText:SetTextColor(0.5, 0.5, 0.5)

BadBoyLevelsConfigTitle:SetText("BadBoy_Levels @project-version@") -- Packager magic, replaced with tag version

