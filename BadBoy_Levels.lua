
--good players(guildies/friends), maybe(for processing)
local badboy = CreateFrame("Frame")
local good, maybe, filterTable = {}, {}, {}
local login = nil
local whisp = "BadBoy_Levels: You need to be level %d to whisper me."
local err = "You have reached the maximum amount of friends, remove 2 for this addon to function properly!"

do
	local L = GetLocale()
	if L == "esES" or L == "esMX" then
		whisp = "BadBoy_Levels: Necesitas ser nivel %d para susurrarme."
		err = "Has llegado a la cantidad máxima de amigos, quita 2 amigos para que este addon funcione propiamente."
	elseif L == "ptBR" then
		whisp = "BadBoy_Levels: Você precisa ter nível %d para me sussurrar."
		err = "Você atingiu o numero máximo de amigos, remova 2 para este addon funcionar corretamente!"
	elseif L == "deDE" then
		whisp = "BadBoy_Levels: Du musst Level %d sein, um mir etwas flüstern zu können."
		err = "Du hast die maximale Anzahl an Freunden erreicht, bitte entferne 2, damit dieses Addon richtig funktioniert!"
	elseif L == "frFR" then
		whisp = "BadBoy_Levels: Vous devez être au moins de niveau %d pour me chuchoter."
		err = "Vous avez atteint la limite de contenu de votre liste d'amis. Enlevez-en 2 pour que cet addon fonctionne correctement !"
	elseif L == "ruRU" then
		whisp = "BadBoy_Levels: Вы должны быть уровнем не ниже %d, что бы шептать мне."
		err = "Вы достигли максимального количества друзей, удалите двоих для нормальной работы аддона!"
	elseif L == "koKR" then
		whisp = "BadBoy_Levels: 저에게 귓속말을 보내기 위해서는 레벨 %d이 필요합니다."
		err = "친구 목록이 최대한도에 도달했습니다. 제대로 애드온이 작업을 하기 위해서는 2명을 제거해야 합니다!"
	elseif L == "zhTW" then
		whisp = "BadBoy_Levels: 你起碼要達到 %d 級才能密我。"
		err = "你的好友列表滿了，此插件需要你騰出2個好友空位!"
	elseif L == "zhCN" then
		whisp = "BadBoy_Levels: 你起码要达到 %d 级才能和我讲话"
		err = "你的好友列表满了，此插件模块需要你腾出2个好友空位!"
	elseif L == "itIT" then
		whisp = "BadBoy_Levels: E' necessario che tu sia di livello %d per sussurrarmi."
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
badboy:RegisterEvent("FRIENDLIST_UPDATE")
badboy:RegisterEvent("CHAT_MSG_SYSTEM")
badboy:SetScript("OnEvent", function(_, evt, msg)
	if evt == "PLAYER_LOGIN" then
		ShowFriends() --force a friends list update on login
		good[UnitName("player")] = true --add ourself to safe list
		if type(BADBOY_LEVEL) ~= "number" or BADBOY_LEVEL < 1 then
			BADBOY_LEVEL = nil
		end
	elseif evt == "CHAT_MSG_SYSTEM" then
		if msg == ERR_FRIEND_LIST_FULL then
			print("|cFF33FF99BadBoy_Levels|r: ", err) --print a warning if we see a friends full message
			return
		end
	else
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
					if type(level) ~= "number" then
						print("|cFF33FF99BadBoy_Levels|r: Level wasn't a number, tell BadBoy author! It was:", level)
						error("|cFF33FF99BadBoy_Levels|r: Level wasn't a number, tell BadBoy author! It was: ".. tostring(level))
					end
					if level < filterTable[player] then
						--lower than level 2, or a level defined by the user = bad,
						--or lower than 58 and class is a Death Knight,
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

--incoming whisper filtering function
ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", function(...)
	local f, _, _, player, _, _, _, flag, _, _, _, _, id, guid = ...
	--don't filter if good, GM, guild member, or x-server
	if good[player] or player:find("%-") or UnitIsInMyGuild(player) then return end
	if flag == "GM" or flag == "DEV" then return end

	--RealID support, don't scan people that whisper us via their character instead of RealID
	--that aren't on our friends list, but are on our RealID list.
	local _, num = BNGetNumFriends()
	for i=1, num do
		local toon = BNGetNumFriendToons(i)
		for j=1, toon do
			local _, rName, rGame, rServer = BNGetFriendToonInfo(i, j)
			if rName == player and rGame == "WoW" and rServer == GetRealmName() then
				good[player] = true
				return
			end
		end
	end

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
	if not maybe[player] then maybe[player] = {} end --added to maybe
	--one table per chatframe, incase we got whispers on 2+ chatframes
	if not maybe[player][f] then maybe[player][f] = {} end
	--one table per id, incase we got more than one whisper from a player whilst still processing
	maybe[player][f][id] = {}
	for i = 1, select("#", ...) do
		--store all the chat arguments incase we need to add it back (if it's a new good guy)
		maybe[player][f][id][i] = select(i, ...)
	end
	--Decide the level to be filtered
	local _, englishClass = GetPlayerInfoByGUID(guid)
	local level = BADBOY_LEVEL and tonumber(BADBOY_LEVEL)+1 or 2
	if englishClass == "DEATHKNIGHT" and level < 58 then level = 58 end
	--Don't try to add a player to friends several times for 1 whisper (registered to more than 1 chat frame)
	if not filterTable[player] or filterTable[player] ~= level then
		filterTable[player] = level
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

