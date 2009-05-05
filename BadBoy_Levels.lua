
--good players(guildies/friends), maybe(for processing)
local good, maybe, badboy = {}, {}, CreateFrame("Frame", "BadBoy_Levels")
local whisp = "You need to be level %d to whisper me."

--[[local L = GetLocale()
if L == "frFR" then
	whisp = ""
end]]

badboy:Hide() --hide, don't run the onupdate
badboy:RegisterEvent("WHO_LIST_UPDATE")
badboy:RegisterEvent("PLAYER_LOGIN")
badboy:RegisterEvent("FRIENDLIST_UPDATE")
badboy:RegisterEvent("GUILD_ROSTER_UPDATE")
badboy:SetScript("OnEvent", function(_, evt, update)
	if evt == "WHO_LIST_UPDATE" then
		badboy:Hide() --stop the onupdate
		FriendsFrame:RegisterEvent("WHO_LIST_UPDATE") --restore friends frame
		SetWhoToUI(0) --restore friends frame
		--we get all who results to prevent any strange situation where the player we want might be 2nd in
		--the list, if we only scanned first in the list, we would create an infinite loop
		local num = GetNumWhoResults()
		for i = 1, num do
			local player, _, level = GetWhoInfo(i)
			if maybe[player] then --do we need to process this person?
				if level <= (tonumber(BADBOY_LEVEL) or 1) then
					--lower than level 1, or a level defined by the user = bad
					--so whisper the bad player what level they must be to whisper us
					SendChatMessage(whisp:format(BADBOY_LEVEL and tonumber(BADBOY_LEVEL)+1 or 2), "WHISPER", nil, player)
				else
					good[player] = true --higher = good
					--get all the frames, incase whispers are being recieved in more that one chat frame
					for _, v in pairs(maybe[player]) do
						--get all the chat lines (queued if multiple) for restoration back to the chat frame
						for _, p in pairs(v) do
							local f = unpack(p)
							--this player is good, we must restore the whisper(s) back to chat
							f:GetScript("OnEvent")(unpack(p))
						end
					end
				end
				wipe(maybe[player]) --remove player data table
				maybe[player] = nil --remove remaining empty table
			end
		end
		--turn on the onupdate if we still have players for processing
		for k in pairs(maybe) do
			badboy:Show()
		end
	elseif evt == "PLAYER_LOGIN" then
		--update our safe list on login with guild/friends
		if IsInGuild() then
			GuildRoster()
		end
		ShowFriends()
		good[UnitName("player")] = true --add ourself
	elseif evt == "FRIENDLIST_UPDATE" then
		--get all online and offline friends
		local num = GetNumFriends()
		for i = 1, num do
			local n = GetFriendInfo(i)
			--add friend to good list
			if n then good[n] = true end
		end
	else
		--back down if not in a guild
		if not IsInGuild() then return end
		--when people join/leave the guild, the roster doesn't update, but we're told it needs updated
		--so just force an update when we're told, we don't update the good list until the roster is updated
		if update then GuildRoster() return end
		--get all online and offline guild members
		local num = GetNumGuildMembers(true)
		for i = 1, num do
			local n = GetGuildRosterInfo(i)
			--add guild member to good list
			if n then good[n] = true end
		end
	end
end)

local t = 0
badboy:SetScript("OnUpdate", function(_, e)
	t = t + e
	if t > 1 then --throttle, request data once a second until we get it, it might be on cooldown
		t = 0
		FriendsFrame:UnregisterEvent("WHO_LIST_UPDATE") --don't show the who popup
		SetWhoToUI(1) --don't show results in chat
		for k in pairs(maybe) do
			SendWho(k) --sendwho any players needing processing
		end
	end
end)

--main whisper filtering cuntion
ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", function(...)
	local flag, player = select(8, ...), select(4, ...)
	--don't filter if good or GM
	if good[player] or flag == "GM" then return end

	--not good or GM, added to maybe
	if not maybe[player] then maybe[player] = {} end
	local f = ...
	--one table per chatframe, incase we got whispers on 2+ chatframes
	if not maybe[player][f] then maybe[player][f] = {} end
	--one table per id, incase we got more than one whisper from a player whilst still processing
	local id = select(13, ...)
	maybe[player][f][id] = {}
	for i = 1, 13 do
		--store all the chat arguments incase we need to add it back (if it's a new good guy)
		maybe[player][f][id][i] = select(i, ...)
	end
	badboy:Show() --start the onupdate data request
	return true --filter everything not good (maybe) and not GM
end)

--outgoing whisper filtering function
ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", function(_,_,msg)
	local sent = whisp:format(BADBOY_LEVEL and tonumber(BADBOY_LEVEL)+1 or 2)
	if msg == sent then return true end
end)

