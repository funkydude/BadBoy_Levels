
--good players(guildies/friends), maybe(for processing)
local good, maybe, badboy, filterName = {}, {}, CreateFrame("Frame", "BadBoy_Levels"), nil
local whisp = "You need to be level %d to whisper me."
local err_one = "You should have a maximum of 48 friends for this addon to work properly."
local err_two = "You have more than 48, remove %d friends."

do
	local L = GetLocale()
	if L == "esES" or L == "esMX" then
		whisp = "Necesitas ser nivel %d para susurrarme."
	elseif L == "deDE" then
		whisp = "Du musst Level %d sein, um mir etwas flüstern zu können."
	elseif L == "frFR" then
		whisp = "Vous devez être au moins de niveau %d pour me chuchoter."
	elseif L == "ruRU" then
		whisp = "Вы должны быть уровнем не ниже %d, что бы шептать мне."
	end
end

ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", function(_,_,msg)
	--this is a filter to remove the player added/removed from friends messages when we use it, otherwise they are left alone
	if not filterName then return end
	if msg == (ERR_FRIEND_ADDED_S):format(filterName) or msg == (ERR_FRIEND_REMOVED_S):format(filterName) then
		return true
	end
end)

badboy:Hide() --hide, don't run the onupdate
badboy:RegisterEvent("PLAYER_LOGIN")
badboy:RegisterEvent("FRIENDLIST_UPDATE")
badboy:RegisterEvent("GUILD_ROSTER_UPDATE")
badboy:SetScript("OnEvent", function(_, evt, update)
	if evt == "PLAYER_LOGIN" then
		--update our safe list on login with guild/friends
		if IsInGuild() then
			GuildRoster()
		end
		ShowFriends()
		--do a friends check to see if we need to warn the user to free up some slots
		local num = GetNumFriends()
		if num and num > 48 then
			print("|cFF33FF99BadBoy_Levels|r: "..err_one)
			print("|cFF33FF99BadBoy_Levels|r: "..err_two:format(num-48))
		end
		good[UnitName("player")] = true --add ourself
	elseif evt == "FRIENDLIST_UPDATE" then
		local num = GetNumFriends() --get total friends
		for i = 1, num do
			local player, level = GetFriendInfo(i)
			--sometimes a friend will return nil, I have no idea why, so force another update and return on the spot
			if not player then
				ShowFriends()
				return
			end
			if maybe[player] then --do we need to process this person?
				RemoveFriend(i) --Remove player from friends list
				if level <= (tonumber(BADBOY_LEVEL) or 1) then
					--lower than or equal to level 1, or a level defined by the user = bad
					--so whisper the bad player what level they must be to whisper us
					SendChatMessage(whisp:format(BADBOY_LEVEL and tonumber(BADBOY_LEVEL)+1 or 2), "WHISPER", nil, player)
					for _, v in pairs(maybe[player]) do
						for _, p in pairs(v) do
							wipe(p) --remove player data table
						end
						wipe(v) --remove player data table
					end
				else
					good[player] = true --higher = good
					--get all the frames, incase whispers are being recieved in more that one chat frame
					for _, v in pairs(maybe[player]) do
						--get all the chat lines (queued if multiple) for restoration back to the chat frame
						for _, p in pairs(v) do
							local f = unpack(p)
							--this player is good, we must restore the whisper(s) back to chat
							f:GetScript("OnEvent")(unpack(p))
							wipe(p) --remove player data table
						end
						wipe(v) --remove player data table
					end
				end
				wipe(maybe[player]) --remove player data table
				maybe[player] = nil --remove remaining empty table
			else
				--if they are not in the maybe list, the friend already existed or was added manually
				--to the friends list, so we should add them to the safe list too
				good[player] = true
			end
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

--main whisper filtering cuntion
ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", function(...)
	--don't filter if good or GM
	local player = select(4, ...)
	if good[player] then return end
	local flag = select(8, ...)
	if flag == "GM" then return end

	filterName = player --add name to filter to remove player added/removed from friends messages
	--not good or GM, added to maybe
	if not maybe[player] then maybe[player] = {} end
	local f = tostring(...)
	--one table per chatframe, incase we got whispers on 2+ chatframes
	if not maybe[player][f] then maybe[player][f] = {} end
	--one table per id, incase we got more than one whisper from a player whilst still processing
	local id = select(13, ...)
	maybe[player][f][id] = {}
	for i = 1, select("#", ...) do
		--store all the chat arguments incase we need to add it back (if it's a new good guy)
		maybe[player][f][id][i] = select(i, ...)
	end
	AddFriend(player) --add player to friends
	return true --filter everything not good (maybe) and not GM
end)

--outgoing whisper filtering function
ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", function(_,_,msg,player)
	local sent = whisp:format(BADBOY_LEVEL and tonumber(BADBOY_LEVEL)+1 or 2)
	if msg == sent then return true end --filter out the reply whisper
	good[player] = true --If we want to whisper someone, they're good
end)

