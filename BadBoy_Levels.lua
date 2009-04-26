
BADBOY_LEVEL = BADBOY_LEVEL or 3
local good, bad, maybe, badboy = {}, {}, {}, CreateFrame("Frame", "BadBoy_Levels")

badboy:Hide()
badboy:RegisterEvent("WHO_LIST_UPDATE")
badboy:RegisterEvent("PLAYER_LOGIN")
badboy:RegisterEvent("FRIENDLIST_UPDATE")
badboy:RegisterEvent("GUILD_ROSTER_UPDATE")
badboy:SetScript("OnEvent", function(_, evt)
	if evt == "WHO_LIST_UPDATE" then
		badboy:Hide()
		FriendsFrame:RegisterEvent("WHO_LIST_UPDATE")
		SetWhoToUI(0)
		local player, _, level = GetWhoInfo(1)
		if maybe[player] then
			if level <= tonumber(BADBOY_LEVEL) then
				bad[player] = true
			else
				good[player] = true
				for _, v in pairs(maybe[player]) do
					for _, p in pairs(v) do
						local f = unpack(p)
						f:GetScript("OnEvent")(unpack(p))
					end
				end
			end
			wipe(maybe[player])
			maybe[player] = nil
		end
		for k in pairs(maybe) do
			badboy:Show()
		end
	elseif evt == "PLAYER_LOGIN" then
		GuildRoster()
		ShowFriends()
	else
		local num = GetNumFriends()
		for i = 1, num do
			good[GetFriendInfo(i)] = true
		end
		num = GetNumGuildMembers(true)
		for i = 1, num do
			good[GetGuildRosterInfo(i)] = true
		end
	end
end)

local t = 0
badboy:SetScript("OnUpdate", function(_, e)
	t = t + e
	if t > 1 then
		t = 0
		FriendsFrame:UnregisterEvent("WHO_LIST_UPDATE")
		SetWhoToUI(1)
		for k in pairs(maybe) do
			SendWho(k)
		end
	end
end)

local function filter(...)
	local flag = select(8, ...)
	local player = select(4, ...)
	if flag == "GM" or good[player] then return end
	if not bad[player] then
		if not maybe[player] then maybe[player] = {} end
		local f = ...
		if not maybe[player][f] then maybe[player][f] = {} end
		local id = select(13, ...)
		maybe[player][f][id] = {}
		for i = 1, 13 do
			maybe[player][f][id][i] = select(i, ...)
		end
		badboy:Show()
	end
	return true
end

ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", filter)

