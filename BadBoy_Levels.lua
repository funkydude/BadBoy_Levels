
local chatMessageIDsToFilter = {}
local goodPlayersNeverFiltered, playersAlreadyWarned = {}, {}
local L_whisper_toolow = "BadBoy_Levels: You need to be level %d to whisper me."
local L_whisper_notallowed = "BadBoy_Levels: You do not meet the requirements to whisper me."

do
	local L = GetLocale()
	if L == "esES" or L == "esMX" then
		L_whisper_toolow = "BadBoy_Levels: Necesitas ser nivel %d para susurrarme."
		L_whisper_notallowed = "BadBoy_Levels: No cumples los requisitos para susurrarme."
	elseif L == "ptBR" then
		L_whisper_toolow = "BadBoy_Levels: Você precisa ter nível %d para me sussurrar."
		L_whisper_notallowed = "BadBoy_Levels: Você não atende aos requisitos para me sussurrar."
	elseif L == "deDE" then
		L_whisper_toolow = "BadBoy_Levels: Du musst Level %d sein, um mir etwas flüstern zu können."
		L_whisper_notallowed = "BadBoy_Levels: Du erfüllst nicht die Voraussetzungen, um mir etwas flüstern zu können."
	elseif L == "frFR" then
		L_whisper_toolow = "BadBoy_Levels: Vous devez être au moins de niveau %d pour me chuchoter."
		L_whisper_notallowed = "BadBoy_Levels: Vous ne remplissez pas les conditions requises pour me chuchoter."
	elseif L == "ruRU" then
		L_whisper_toolow = "BadBoy_Levels: Вы должны быть уровнем не ниже %d, чтобы шептать мне."
		L_whisper_notallowed = "BadBoy_Levels: Вы не соответствуете требованиям, чтобы шептать мне."
	elseif L == "koKR" then
		L_whisper_toolow = "BadBoy_Levels: 저에게 귓속말을 보내기 위해서는 레벨 %d이 필요합니다."
		L_whisper_notallowed = "BadBoy_Levels: 저에게 귓속말을 보내기 위한 요구 조건을 충족하지 못했습니다."
	elseif L == "zhTW" then
		L_whisper_toolow = "BadBoy_Levels: 你起碼要達到 %d 級才能密我。"
		L_whisper_notallowed = "BadBoy_Levels: 你未達到密我的要求。"
	elseif L == "zhCN" then
		L_whisper_toolow = "BadBoy_Levels: 你起码要达到 %d 级才能密我。"
		L_whisper_notallowed = "BadBoy_Levels: 你的角色等级未达到密语要求。"
	elseif L == "itIT" then
		L_whisper_toolow = "BadBoy_Levels: E' necessario che tu sia di livello %d per sussurrarmi."
		L_whisper_notallowed = "BadBoy_Levels: Non soddisfi i requisiti per sussurrarmi."
	end
end

goodPlayersNeverFiltered[UnitGUID("player")] = true --add ourself to safe list
if type(BADBOY_LEVELS_DB) ~= "table" then
	BADBOY_LEVELS_DB = {level = 3, blockall = false, allowfriends = false, allowguild = false, allowgroup = false}
else
	if type(BADBOY_LEVELS_DB.blockall) ~= "boolean" then BADBOY_LEVELS_DB.blockall = false end
	if type(BADBOY_LEVELS_DB.allowfriends) ~= "boolean" then BADBOY_LEVELS_DB.allowfriends = false end
	if type(BADBOY_LEVELS_DB.allowguild) ~= "boolean" then BADBOY_LEVELS_DB.allowguild = false end
	if type(BADBOY_LEVELS_DB.allowgroup) ~= "boolean" then BADBOY_LEVELS_DB.allowgroup = false end
	if type(BADBOY_LEVELS_DB.level) ~= "number" then BADBOY_LEVELS_DB.level = 3 end
end

local issecretvalue = issecretvalue
local GetPlayerInfoByGUID = GetPlayerInfoByGUID
local badboy = CreateFrame("Frame")
badboy:SetScript("OnEvent", function(_, event, msg, player, _, _, _, flag, _, _, _, _, id, guid)
	if event == "CHAT_MSG_WHISPER" then
		if issecretvalue(guid) then return end
		if goodPlayersNeverFiltered[guid] or flag == "GM" or flag == "DEV" then return end -- don't filter if good or GM

		--[[ Start functionality for blocking all whispers regardless of level ]]--
		if BADBOY_LEVELS_DB.blockall then
			local allow = false

			if BADBOY_LEVELS_DB.allowfriends then
				local isBnetFriend = C_BattleNet.GetGameAccountInfoByGUID(guid)
				if isBnetFriend or C_FriendList.IsFriend(guid) then
					allow = true
				end
			end
			if BADBOY_LEVELS_DB.allowguild and IsGuildMember(guid) then
				allow = true
			end
			if BADBOY_LEVELS_DB.allowgroup and C_PartyInfo.IsGUIDInGroup(guid) then
				allow = true
			end

			if not allow then
				if not playersAlreadyWarned[guid] then
					playersAlreadyWarned[guid] = true
					local trimmedPlayer = Ambiguate(player, "none")
					C_ChatInfo.SendChatMessage(L_whisper_notallowed, "WHISPER", nil, trimmedPlayer)
					C_Timer.After(60, function() playersAlreadyWarned[guid] = nil end)
				end
				chatMessageIDsToFilter[id] = true
			end

			return
		end
		--[[ End functionality for blocking all whispers regardless of level ]]--

		--don't filter if guild member, character friend, bnet friend, or in our group
		if BadBoyIsFriendly(guid, flag) then return end

		local _, _, _, _, _, _, _, level = GetPlayerInfoByGUID(guid)
		if type(level) ~= "number" then return end

		if level < BADBOY_LEVELS_DB.level then
			if not playersAlreadyWarned[guid] then
				playersAlreadyWarned[guid] = true
				local trimmedPlayer = Ambiguate(player, "none")
				C_ChatInfo.SendChatMessage(L_whisper_toolow:format(BADBOY_LEVELS_DB.level), "WHISPER", nil, trimmedPlayer)
				C_Timer.After(60, function() playersAlreadyWarned[guid] = nil end)
			end
			chatMessageIDsToFilter[id] = true
		else
			goodPlayersNeverFiltered[guid] = true
		end
	elseif event == "CHAT_MSG_WHISPER_INFORM" then
		if issecretvalue(msg) or issecretvalue(guid) or issecretvalue(id) then return end
		if goodPlayersNeverFiltered[guid] then return end --Do nothing if on safe list
		if msg:find("^BadBoy_Levels: ") then
			chatMessageIDsToFilter[id] = true --Filter auto-response
			return
		end
		goodPlayersNeverFiltered[guid] = true --If we want to whisper someone, they're good
	end
end)
badboy:RegisterEvent("CHAT_MSG_WHISPER")
badboy:RegisterEvent("CHAT_MSG_WHISPER_INFORM")

-- whisper filtering function
local function filter(_, _, _, _, _, _, _, _, _, _, _, _, id)
	if not issecretvalue(id) and type(id) == "number" and chatMessageIDsToFilter[id] then
		return true
	end
end
ChatFrameUtil.AddMessageEventFilter("CHAT_MSG_WHISPER", filter)
ChatFrameUtil.AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", filter)
