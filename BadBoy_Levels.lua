
--good players(guildies/friends), maybe(for processing)
local good, maybe, badboy, filterTable, login = {}, {}, CreateFrame("Frame", "BadBoy_Levels"), {}, nil
local whisp = "BadBoy_Levels: You need to be level %d to whisper me."
local err = "You have reached the maximum amount of friends, remove 2 for this addon to function properly!"

do
	local L = GetLocale()
	if L == "esES" or L == "esMX" then
		whisp = "BadBoy_Levels: Necesitas ser nivel %d para susurrarme."
		err = "Has llegado a la cantidad máxima de amigos, quita 2 amigos para que este addon funcione propiamente. "
	elseif L == "deDE" then
		whisp = "BadBoy_Levels: Du musst Level %d sein, um mir etwas flüstern zu können."
		err = "Du hast die maximale Anzahl an Freunden erreicht, bitte entferne 2, damit dieses Addon richtig funktioniert!"
	elseif L == "frFR" then
		whisp = "BadBoy_Levels: Vous devez être au moins de niveau %d pour me chuchoter."
		err = "Vous avez atteint la limite de contenu de votre liste d'amis. Enlevez-en 2 pour que cet addon fonctionne correctement !"
	elseif L == "ruRU" then
		whisp = "BadBoy_Levels: Вы должны быть уровнем не ниже %d, что бы шептать мне."
	end
end

ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", function(_,_,msg)
	if msg == ERR_FRIEND_LIST_FULL then
		print("|cFF33FF99BadBoy_Levels|r: ", err) --print a warning if we see a friends full message
		return
	end
	--this is a filter to remove the player added/removed from friends messages when we use it, otherwise they are left alone
	for k in pairs(filterTable) do
		if msg == (ERR_FRIEND_ADDED_S):format(k) or msg == (ERR_FRIEND_REMOVED_S):format(k) then
			return true
		end
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
		--variable health check
		if BADBOY_LEVEL and type(BADBOY_LEVEL) ~= "number" then BADBOY_LEVEL = nil end
		if BADBOY_LEVEL and (BADBOY_LEVEL<1 or BADBOY_LEVEL>79) then BADBOY_LEVEL = nil end
		BadBoyLevelsEditBox:SetText(BADBOY_LEVEL or 1)
	elseif evt == "FRIENDLIST_UPDATE" then
		if not login then --run on login only
			login = true
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
			local player, level = GetFriendInfo(i)
			--sometimes a friend will return nil, I have no idea why, so force another update
			if not player then
				ShowFriends()
			else
				if maybe[player] then --do we need to process this person?
					RemoveFriend(player, true) --Remove player from friends list, the 2nd arg "true" is a fake arg added by request of tekkub, author of FriendsWithBenefits
					if level < filterTable[player] then
						--lower than level 2, or a level defined by the user = bad,
						--or lower than 57 and class is a Death Knight,
						--so whisper the bad player what level they must be to whisper us
						SendChatMessage(whisp:format(filterTable[player]), "WHISPER", nil, player)
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
								--this player is good, we must restore the whisper(s) back to chat
								ChatFrame_MessageEventHandler(unpack(p))
								wipe(p) --remove player data table
							end
							wipe(v) --remove player data table
						end
					end
					wipe(maybe[player]) --remove player data table
					maybe[player] = nil --remove remaining empty table
				end
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

--incoming whisper filtering funtion
ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", function(...)
	--don't filter if good, GM, or x-server
	local player = select(4, ...)
	if good[player] or player:find("%-") then return end
	local flag = select(8, ...)
	if flag == "GM" then return end

	if not maybe[player] then maybe[player] = {} end --added to maybe
	local f = ...
	f = f:GetName()
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
	if not filterTable[player] then
		--Decide the level to be filtered
		local guid = select(14, ...)
		local _, englishClass = GetPlayerInfoByGUID(guid)
		if englishClass == "DEATHKNIGHT" then
			filterTable[player] = 58
		else
			filterTable[player] = BADBOY_LEVEL and tonumber(BADBOY_LEVEL)+1 or 2
		end
		AddFriend(player, true) --add player to friends, the 2nd arg "true" is a fake arg added by request of tekkub, author of FriendsWithBenefits
	end
	return true --filter everything not good (maybe) and not GM
end)

--outgoing whisper filtering function
ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", function(_,_,msg,player)
	if good[player] then return end --Do nothing if on safe list
	if filterTable[player] and msg:find("^BadBoy.*"..filterTable[player]) then return true end --Filter auto-response
	good[player] = true --If we want to whisper someone, they're good
end)

