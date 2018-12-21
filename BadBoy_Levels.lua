
--good players(guildies/friends), maybe(for processing)
local badboy = CreateFrame("Frame")
local good, maybe, filterTable, whispered = {}, {}, {}, {}
local login = false
local whisp = "BadBoy_Levels: You need to be level %d to whisper me."
local whisp_notallowed = "BadBoy_Levels: You do not meet the requirements to whisper me."
local err = "You have reached the maximum amount of friends, remove 2 for this addon to function properly!"

do
	local L = GetLocale()
	if L == "esES" or L == "esMX" then
		whisp = "BadBoy_Levels: Necesitas ser nivel %d para susurrarme."
		--whisp_notallowed = "BadBoy_Levels: You do not meet the requirements to whisper me."
		err = "Has llegado a la cantidad máxima de amigos, quita 2 amigos para que este addon funcione propiamente."
	elseif L == "ptBR" then
		whisp = "BadBoy_Levels: Você precisa ter nível %d para me sussurrar."
		--whisp_notallowed = "BadBoy_Levels: You do not meet the requirements to whisper me."
		err = "Você atingiu o numero máximo de amigos, remova 2 para este addon funcionar corretamente!"
	elseif L == "deDE" then
		whisp = "BadBoy_Levels: Du musst Level %d sein, um mir etwas flüstern zu können."
		--whisp_notallowed = "BadBoy_Levels: You do not meet the requirements to whisper me."
		err = "Du hast die maximale Anzahl an Freunden erreicht, bitte entferne 2, damit dieses Addon richtig funktioniert!"
	elseif L == "frFR" then
		whisp = "BadBoy_Levels: Vous devez être au moins de niveau %d pour me chuchoter."
		--whisp_notallowed = "BadBoy_Levels: You do not meet the requirements to whisper me."
		err = "Vous avez atteint la limite de contenu de votre liste d'amis. Enlevez-en 2 pour que cet addon fonctionne correctement !"
	elseif L == "ruRU" then
		whisp = "BadBoy_Levels: Вы должны быть уровнем не ниже %d, что бы шептать мне."
		--whisp_notallowed = "BadBoy_Levels: You do not meet the requirements to whisper me."
		err = "Вы достигли максимального количества друзей, удалите двоих для нормальной работы модификации!"
	elseif L == "koKR" then
		whisp = "BadBoy_Levels: 저에게 귓속말을 보내기 위해서는 레벨 %d이 필요합니다."
		--whisp_notallowed = "BadBoy_Levels: You do not meet the requirements to whisper me."
		err = "친구 목록이 최대한도에 도달했습니다. 제대로 애드온이 작업을 하기 위해서는 2명을 제거해야 합니다!"
	elseif L == "zhTW" then
		whisp = "BadBoy_Levels: 你起碼要達到 %d 級才能密我。"
		--whisp_notallowed = "BadBoy_Levels: You do not meet the requirements to whisper me."
		err = "你的好友列表滿了，此插件需要你騰出2個好友空位!"
	elseif L == "zhCN" then
		whisp = "BadBoy_Levels: 你起码要达到 %d 级才能和我讲话。"
		--whisp_notallowed = "BadBoy_Levels: You do not meet the requirements to whisper me."
		err = "你的好友列表已满，此模块需要你腾出2个好友空位！"
	elseif L == "itIT" then
		whisp = "BadBoy_Levels: E' necessario che tu sia di livello %d per sussurrarmi."
		--whisp_notallowed = "BadBoy_Levels: You do not meet the requirements to whisper me."
		err = "Hai raggiunto il limite massimo di amici, rimuovine 2 per permettere a questo addon di funzionare correttamente!"
	end
end

local addMsg, hookFunc
do
	-- For some reason any form of CHAT_MSG_SYSTEM filter causes nonsense world map taints, so use the next best thing
	local addFrnd = ERR_FRIEND_ADDED_S:gsub("%%s", "([^ ]+)")
	local rmvFrnd = ERR_FRIEND_REMOVED_S:gsub("%%s", "([^ ]+)")
	local info = ChatTypeInfo.SYSTEM
	hookFunc = function(f, msg, r, g, b, ...)
		-- This is a filter to remove the player added/removed from friends messages when we use it, otherwise they are left alone
		if r == info.r and g == info.g and b == info.b then
			local _, _, player = msg:find(addFrnd)
			if not player then
				_, _, player = msg:find(rmvFrnd)
			end
			if player and filterTable[player] then
				return
			end
		end
		return addMsg(f, msg, r, g, b, ...)
	end
end

badboy:RegisterEvent("PLAYER_LOGIN")
badboy:SetScript("OnEvent", function(frame, evt, msg)
	frame:UnregisterEvent("PLAYER_LOGIN")
	frame:RegisterEvent("FRIENDLIST_UPDATE")
	frame:RegisterEvent("CHAT_MSG_SYSTEM")

	good[UnitName("player")] = true --add ourself to safe list
	if type(BADBOY_LEVELS) ~= "table" then
		BADBOY_LEVELS = {level = 3, dklevel = 58, dhlevel = 100, blockall = false, allowfriends = false, allowguild = false, allowgroup = false}
	end

	frame:SetScript("OnEvent", function(frame, evt, msg)
		if evt == "CHAT_MSG_SYSTEM" then
			if msg == ERR_FRIEND_LIST_FULL then
				print("|cFF33FF99BadBoy_Levels|r: ", err) --print a warning if we see a friends full message
				return
			end
		else
			if not login then --run on login only
				login = true
				local num = C_FriendList.GetNumFriends()
				for i = num, 1, -1 do
					local tbl = C_FriendList.GetFriendInfoByIndex(i)
					--add friends to safe list
					if tbl.notes == "badboy_temp" then
						C_FriendList.RemoveFriendByIndex(i)
					elseif type(tbl.name) == "string" then
						good[tbl.name] = true
					end
				end
				return
			end

			local num = C_FriendList.GetNumFriends() --get total friends
			for i = num, 1, -1 do
				local tbl = C_FriendList.GetFriendInfoByIndex(i)
				local player, level = tbl.name, tbl.level
				--sometimes a friend will return nil, I have no idea why, so force another update
				if not player then
					C_FriendList.ShowFriends()
				else
					if maybe[player] then --do we need to process this person?
						C_FriendList.RemoveFriendByIndex(i)
						if type(level) ~= "number" then
							print("|cFF33FF99BadBoy_Levels|r: Level wasn't a number, tell BadBoy author! It was:", level)
							error("|cFF33FF99BadBoy_Levels|r: Level wasn't a number, tell BadBoy author! It was: ".. tostring(level))
						end
						if level < filterTable[player] then
							--Whisper the bad player what level they must be to whisper us
							if not whispered[player] then
								whispered[player] = true
								SendChatMessage(whisp:format(filterTable[player]), "WHISPER", nil, player)
								C_Timer.After(60, function() whispered[player] = nil end)
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
									--this player is good, we must restore the whisper(s) back to chat
									if IsAddOnLoaded("WIM") then --WIM compat
										WIM.modules.WhisperEngine:CHAT_MSG_WHISPER(select(3, unpack(p)))
									elseif IsAddOnLoaded("Cellular") then --Cellular compat
										local _,_,a1,a2,_,_,_,a6,_,_,_,_,a11,a12 = unpack(p)
										Cellular:IncomingMessage(a2, a1, a6, nil, a11, a12)
									else
										ChatFrame_MessageEventHandler(unpack(p))
									end
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
		end
	end)

	C_FriendList.ShowFriends() --force a friends list update on login
end)

--incoming whisper filtering function
ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", function(...)
	local f, _, _, player, _, _, _, flag, _, _, _, _, id, guid = ...
	local trimmedPlayer = Ambiguate(player, "none")
	if good[trimmedPlayer] or flag == "GM" or flag == "DEV" then return end -- don't filter if good or GM

	--[[ Start functionality for blocking all whispers regardless of level ]]--
	if BADBOY_LEVELS.blockall then
		local allow = false

		if BADBOY_LEVELS.allowfriends then
			local _, characterName = BNGetGameAccountInfoByGUID(guid)
			if characterName or C_FriendList.IsFriend(guid) then
				allow = true
			end
		end
		if BADBOY_LEVELS.allowguild and IsGuildMember(guid) then
			allow = true
		end
		if BADBOY_LEVELS.allowgroup and (UnitInRaid(trimmedPlayer) or UnitInParty(trimmedPlayer)) then
			allow = true
		end

		if not allow then
			if not whispered[trimmedPlayer] then
				whispered[trimmedPlayer] = true
				SendChatMessage(whisp_notallowed, "WHISPER", nil, trimmedPlayer)
				C_Timer.After(60, function() whispered[trimmedPlayer] = nil end)
			end
			return true
		else
			return
		end
	end
	--[[ End functionality for blocking all whispers regardless of level ]]--

	--don't filter if guild member, friend, in group, or x-server
	if trimmedPlayer:find("-", nil, true) then return end
	if BadBoyIsFriendly(trimmedPlayer, flag, id, guid) then return end

	if not addMsg then -- On-demand hook for chat filtering
		addMsg = ChatFrame1.AddMessage
		ChatFrame1.AddMessage = hookFunc
	end

	f = f:GetName()
	if not f then f = "?" end
	if f == "WIM3_HistoryChatFrame" then return end -- Ignore WIM history frame
	if not f:find("^ChatFrame%d+$") and f ~= "WIM_workerFrame" and f ~= "Cellular" then
		print("|cFF33FF99BadBoy_Levels|r: ERROR, tell BadBoy author, new frame found:", f)
		error("|cFF33FF99BadBoy_Levels|r: Tell BadBoy author, new frame found: ".. f)
		return
	end
	if IsAddOnLoaded("WIM") and f ~= "WIM_workerFrame" then return true end --WIM compat
	if IsAddOnLoaded("Cellular") and f ~= "Cellular" then return true end --Cellular compat
	if not maybe[trimmedPlayer] then maybe[trimmedPlayer] = {} end --added to maybe
	--one table per chatframe, incase we got whispers on 2+ chatframes
	if not maybe[trimmedPlayer][f] then maybe[trimmedPlayer][f] = {} end
	--one table per id, incase we got more than one whisper from a player whilst still processing
	maybe[trimmedPlayer][f][id] = {}
	for i = 1, select("#", ...) do
		--store all the chat arguments incase we need to add it back (if it's a new good guy)
		maybe[trimmedPlayer][f][id][i] = select(i, ...)
	end
	--Decide the level to be filtered
	local _, englishClass = GetPlayerInfoByGUID(guid)
	local level = BADBOY_LEVELS.level
	if englishClass == "DEATHKNIGHT" then
		level = BADBOY_LEVELS.dklevel
	elseif englishClass == "DEMONHUNTER" then
		level = BADBOY_LEVELS.dhlevel
	end
	--Don't try to add a player to friends several times for 1 whisper (registered to more than 1 chat frame)
	if not filterTable[trimmedPlayer] or filterTable[trimmedPlayer] ~= level then
		filterTable[trimmedPlayer] = level
		C_FriendList.AddFriend(trimmedPlayer, "badboy_temp")
	end
	return true --filter everything not good (maybe) and not GM
end)

--outgoing whisper filtering function
ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", function(_,_,msg,player)
	local trimmedPlayer = Ambiguate(player, "none")
	if good[trimmedPlayer] then return end --Do nothing if on safe list
	if msg:find("^BadBoy_Levels: ") then return true end --Filter auto-response
	good[trimmedPlayer] = true --If we want to whisper someone, they're good
end)

