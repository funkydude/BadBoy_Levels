
--good players(guildies/friends), maybe(for processing)
local badboy = CreateFrame("Frame")
local mod, idsToFilter = {}, {}
local good, maybe, filterTable, whispered = {}, {}, {}, {}
local whisp = "BadBoy_Levels: You need to be level %d to whisper me."
local whisp_notallowed = "BadBoy_Levels: You do not meet the requirements to whisper me."
local err = "You have reached the maximum amount of friends, remove 2 for this addon to function properly!"
local connectedRealms = {}

badboy:SetScript("OnEvent", function(frame, event, ...)
	mod[event](mod, frame, event, ...)
end)

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
		whisp = "BadBoy_Levels: Вы должны быть уровнем не ниже %d, чтобы шептать мне."
		--whisp_notallowed = "BadBoy_Levels: Вы не соответствуете требованиям, чтобы шептать мне."
		err = "Вы достигли максимального количества друзей. Удалите хотя бы двоих, чтобы этот аддон работал правильно!"
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

function mod:PLAYER_LOGIN(frame, event)
	frame:UnregisterEvent(event)
	frame:RegisterEvent("FRIENDLIST_UPDATE")
	frame:RegisterEvent("CHAT_MSG_SYSTEM")

	local realms = GetAutoCompleteRealms()
	for i = 1, #realms do
		local entry = realms[i]
		connectedRealms[entry] = true
	end

	local eventList = {
		"CHAT_MSG_WHISPER",
		"CHAT_MSG_WHISPER_INFORM",
	}
	for i = 1, #eventList do
		local wEvent = eventList[i]
		local frames = {GetFramesRegisteredForEvent(wEvent)}
		for j = 1, #frames do
			local f = frames[j]
			f:UnregisterEvent(wEvent)
		end
		frame:RegisterEvent(wEvent)
		for j = 1, #frames do
			local f = frames[j]
			f:RegisterEvent(wEvent)
		end
	end

	good[UnitName("player")] = true --add ourself to safe list
	if type(BADBOY_LEVELS_DB) ~= "table" then
		BADBOY_LEVELS_DB = {level = 3, blockall = false, allowfriends = false, allowguild = false, allowgroup = false}
	end

	C_FriendList.ShowFriends() --force a friends list update on login
end
badboy:RegisterEvent("PLAYER_LOGIN")

function mod:CHAT_MSG_SYSTEM(_, _, msg)
	if msg == ERR_FRIEND_LIST_FULL then
		print("|cFF33FF99BadBoy_Levels|r: ", err) --print a warning if we see a friends full message
	end
end

function mod:FRIENDLIST_UPDATE()
	-- first run only (player login)
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
	-- end first run (player login)

	self.FRIENDLIST_UPDATE = function()
		local numFriends = C_FriendList.GetNumFriends() --get total friends
		for i = numFriends, 1, -1 do
			local tbl = C_FriendList.GetFriendInfoByIndex(i)
			local player, level = tbl.name, tbl.level
			--sometimes a friend will return nil, I have no idea why, so force another update
			if not player then
				C_FriendList.ShowFriends()
			else
				if maybe[player] then --do we need to process this person?
					if level == 0 then return end -- FRIENDLIST_UPDATE fires 2 times per addition (WoW v9.0.1) we need to wait for the 2nd firing to get good data

					C_FriendList.RemoveFriendByIndex(i)
					if type(level) ~= "number" then
						local msg = "|cFF33FF99BadBoy_Levels|r: Level wasn't a number, tell BadBoy author! It was: ".. tostring(level)
						print(msg)
						geterrorhandler()(msg)
						level = 1000
					end
					if level < filterTable[player] then
						--Whisper the bad player what level they must be to whisper us
						if not whispered[player] then
							whispered[player] = true
							SendChatMessage(whisp:format(filterTable[player]), "WHISPER", nil, player)
							C_Timer.After(60, function() whispered[player] = nil end)
						end
					else
						good[player] = true --higher = good
						for id, argsTable in next, maybe[player] do
							--this player is good, we must restore the whisper(s) back to chat
							idsToFilter[id] = nil
							local argsCount = argsTable[1]
							if IsAddOnLoaded("WIM") then --WIM compat
								WIM.modules.WhisperEngine:CHAT_MSG_WHISPER(unpack(argsTable, 2, argsCount+1))
							elseif IsAddOnLoaded("Cellular") then --Cellular compat
								local a1,a2,_,_,_,a6,_,_,_,_,a11,a12 = unpack(argsTable, 2, argsCount+1)
								Cellular:IncomingMessage(a2, a1, a6, nil, a11, a12)
							else
								local frames = {GetFramesRegisteredForEvent("CHAT_MSG_WHISPER")}
								for j = 1, #frames do
									local f = frames[j]
									local name = f.GetName and f:GetName()
									if type(name) == "string" and name:find("^ChatFrame") then
										ChatFrame_MessageEventHandler(f, "CHAT_MSG_WHISPER", unpack(argsTable, 2, argsCount+1))
									end
								end
							end
						end
					end
					maybe[player] = nil --remove player entry
					if not next(maybe) then
						-- No more players left so unmute the new "player has come online" sound that plays when a new friend is added.
						-- Hopefully no one is actually muting this, because this will break it
						C_Timer.After(0, function()
							UnmuteSoundFile(567518)
							ChatFrame1:RegisterEvent("CHAT_MSG_SYSTEM") -- Re-enable the system message prints "player has come online"
						end)
					end
				end
			end
		end
	end
end

function mod:CHAT_MSG_WHISPER(_, _, ...)
	local _, player, _, _, _, flag, _, _, _, _, id, guid = ...
	local trimmedPlayer = Ambiguate(player, "none")
	if good[trimmedPlayer] or flag == "GM" or flag == "DEV" then return end -- don't filter if good or GM

	--[[ Start functionality for blocking all whispers regardless of level ]]--
	if BADBOY_LEVELS_DB.blockall then
		local allow = false

		if BADBOY_LEVELS_DB.allowfriends then
			if C_BattleNet then -- Retail
				local isBnetFriend = C_BattleNet.GetGameAccountInfoByGUID(guid)
				if isBnetFriend or C_FriendList.IsFriend(guid) then
					allow = true
				end
			else -- XXX classic compat
				local _, isBnetFriend = BNGetGameAccountInfoByGUID(guid)
				if isBnetFriend or C_FriendList.IsFriend(guid) then
					allow = true
				end
			end
		end
		if BADBOY_LEVELS_DB.allowguild and IsGuildMember(guid) then
			allow = true
		end
		if BADBOY_LEVELS_DB.allowgroup and (UnitInRaid(trimmedPlayer) or UnitInParty(trimmedPlayer)) then
			allow = true
		end

		if not allow then
			if not whispered[trimmedPlayer] then
				whispered[trimmedPlayer] = true
				SendChatMessage(whisp_notallowed, "WHISPER", nil, trimmedPlayer)
				C_Timer.After(60, function() whispered[trimmedPlayer] = nil end)
			end
			idsToFilter[id] = true
		end

		return
	end
	--[[ End functionality for blocking all whispers regardless of level ]]--

	--we can only filter whispers from realms connected to ours
	if trimmedPlayer:find("-", nil, true) then
		local whisperRealm = trimmedPlayer:gsub("^[^%-]+%-(.+)", "%1")
		if not connectedRealms[whisperRealm] then
			return
		end
	end
	--don't filter if guild member, character friend, bnet friend, or in our group
	if BadBoyIsFriendly(trimmedPlayer, flag, id, guid) then return end

	if not maybe[trimmedPlayer] then maybe[trimmedPlayer] = {} end --added to maybe
	--store all the chat arguments incase we need to add it back (if it's a new good guy)
	if not maybe[trimmedPlayer][id] then maybe[trimmedPlayer][id] = {select("#", ...), ...} end

	local level = BADBOY_LEVELS_DB.level
	--Don't try to add a player to friends several times for 1 whisper (registered to more than 1 chat frame)
	if not filterTable[trimmedPlayer] or filterTable[trimmedPlayer] ~= level then
		filterTable[trimmedPlayer] = level
		idsToFilter[id] = true
		-- Mute the new "player has come online" sound that plays when a friend is added.
		-- Hopefully no one is actually muting this, because this will break it when it's unmuted above
		MuteSoundFile(567518)
		ChatFrame1:UnregisterEvent("CHAT_MSG_SYSTEM") -- Block system messages "player has come online" and "player added to friends"
		C_FriendList.AddFriend(trimmedPlayer, "badboy_temp")
	else
		idsToFilter[id] = true
	end
end

function mod:CHAT_MSG_WHISPER_INFORM(_,_,msg,player, _, _, _, _, _, _, _, _, id)
	local trimmedPlayer = Ambiguate(player, "none")
	if good[trimmedPlayer] then return end --Do nothing if on safe list
	if msg:find("^BadBoy_Levels: ") then
		idsToFilter[id] = true --Filter auto-response
		return
	end
	good[trimmedPlayer] = true --If we want to whisper someone, they're good
end

-- whisper filtering function
local function filter(_, _, _, _, _, _, _, _, _, _, _, _, id)
	if type(id) == "number" and idsToFilter[id] then
		return true --filter everything not good (maybe)
	end
end
ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", filter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", filter)
