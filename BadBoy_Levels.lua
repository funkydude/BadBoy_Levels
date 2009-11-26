
--good players(guildies/friends), maybe(for processing)
local good, maybe, badboy, filterName, login = {}, {}, CreateFrame("Frame", "BadBoy_Levels"), nil, nil
local whisp = "You need to be level %d to whisper me."
local err = "You have reached the maximum amount of friends, remove 2 for this addon to function properly!"

do
	local L = GetLocale()
	if L == "esES" or L == "esMX" then
		whisp = "Necesitas ser nivel %d para susurrarme."
	elseif L == "deDE" then
		whisp = "Du musst Level %d sein, um mir etwas flüstern zu können."
		err = "Du hast die maximale Anzahl an Freunden erreicht, bitte entferne 2, damit dieses Addon richtig funktioniert!"
	elseif L == "frFR" then
		whisp = "Vous devez être au moins de niveau %d pour me chuchoter."
		err = "Vous avez atteint la limite de contenu de votre liste d'amis. Enlevez-en 2 pour que cet addon fonctionne correctement !"
	elseif L == "ruRU" then
		whisp = "Вы должны быть уровнем не ниже %d, что бы шептать мне."
	end
end

ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", function(_,_,msg)
	if msg == ERR_FRIEND_LIST_FULL then
		print("|cFF33FF99BadBoy_Levels|r: ", err)
		return
	end
	--this is a filter to remove the player added/removed from friends messages when we use it, otherwise they are left alone
	if not filterName then return end
	if msg == (ERR_FRIEND_ADDED_S):format(filterName) or msg == (ERR_FRIEND_REMOVED_S):format(filterName) then
		return true
	end
end)

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
		good[UnitName("player")] = true --add ourself
	elseif evt == "FRIENDLIST_UPDATE" then
		if not login then --run on login only
			login = true
			--do a friends check to see if we need to warn the user to free up some slots
			local num = GetNumFriends()
			for i = 1, num do
				local n = GetFriendInfo(i)
				--add friends to safe list
				if n then good[n] = true end
			end
			return
		end

		local num = GetNumFriends() --get total friends
		for i = 1, num do
			local player, level, class = GetFriendInfo(i)
			--sometimes a friend will return nil, I have no idea why, so force another update and return on the spot
			if not player then
				ShowFriends()
				return
			end
			if maybe[player] then --do we need to process this person?
				RemoveFriend(player, true) --Remove player from friends list, the 2nd arg "true" is a fake arg added by request of tekkub, author of FriendsWithBenefits
				--begin code for filtering Death Knights, we need to get the English class name from the return
				local result
				for k,v in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do
					if v == class then
						result = k
					end
				end
				if not result then
					for k,v in pairs(LOCALIZED_CLASS_NAMES_MALE) do
						if v == class then
							result = k
						end
					end
				end
				if level <= (tonumber(BADBOY_LEVEL) or 1) or (level < 57 and result == "DEATHKNIGHT") then
					--lower than or equal to level 1, or a level defined by the user = bad
					--or lower than 57 and class is a Death Knight
					--so whisper the bad player what level they must be to whisper us
					if result == "DEATHKNIGHT" then
						SendChatMessage(whisp:format(57), "WHISPER", nil, player)
					else
						SendChatMessage(whisp:format(BADBOY_LEVEL and tonumber(BADBOY_LEVEL)+1 or 2), "WHISPER", nil, player)
					end
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
local lastId = 0
ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", function(...)
	--don't filter if good or GM
	local player = select(4, ...)
	if good[player] or player:find("%-") then return end
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
	--Don't try to add a player to friends several times for 1 whisper (registered to more than 1 chat frame)
	if lastId ~= id then
		lastId = id
		AddFriend(player, true) --add player to friends, the 2nd arg "true" is a fake arg added by request of tekkub, author of FriendsWithBenefits
	end
	return true --filter everything not good (maybe) and not GM
end)

--outgoing whisper filtering function
ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", function(_,_,_,player)
	if good[player] then return end --Do nothing if on safe list
	if filterName and player == filterName then return true end --Filter auto-response
	good[player] = true --If we want to whisper someone, they're good
end)

