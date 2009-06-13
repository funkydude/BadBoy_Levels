
--good players(guildies/friends), maybe(for processing)
local good, maybe, count, badboy, t, wholib = {}, {}, {}, CreateFrame("Frame", "BadBoy_Levels"), 1, nil
local whisp = "You need to be level %d to whisper me."

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

badboy:Hide() --hide, don't run the onupdate
badboy:RegisterEvent("WHO_LIST_UPDATE")
badboy:RegisterEvent("PLAYER_LOGIN")
badboy:RegisterEvent("FRIENDLIST_UPDATE")
badboy:RegisterEvent("GUILD_ROSTER_UPDATE")
badboy:SetScript("OnEvent", function(_, evt, update)
	if evt == "WHO_LIST_UPDATE" then
		if not wholib then --Only if WhoLib isn't running
			badboy:Hide() --stop the onupdate
			t = 1 --reset counter
			FriendsFrame:RegisterEvent("WHO_LIST_UPDATE") --restore friends frame
			SetWhoToUI(0) --restore friends frame
		end
		--we get all who results to prevent any strange situation where the player we want might be 2nd in
		--the list, if we only scanned first in the list, we would create an infinite loop
		local num = GetNumWhoResults()
		local found = nil
		for i = 1, num do
			local player, _, level = GetWhoInfo(i)
			if maybe[player] then --do we need to process this person?
				count[player] = nil --remove counter entry
				found = true --we found someone in this who
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
			end
		end
		if not found then -- we didn't find anyone in this who, should really never happen
			for k,v in pairs(count) do --cycle through players in counter
				count[k] = v + 1 --add 1 to every player
				--if player has been who'd 10 times (1 minute, reasonable relog time), give up and remove the whisper,
				--it was probably a quick log on/off gold spammer
				if v > 9 then
					for _, n in pairs(maybe[k]) do
						for _, p in pairs(n) do
							wipe(p) --remove player data table
						end
						wipe(n) --remove player data table
					end
					wipe(maybe[k]) --remove player data table
					maybe[k] = nil --remove remaining empty table
					count[k] = nil --remove player counter
				end
			end
		end
		--turn on the onupdate if we still have players for processing
		for k in pairs(maybe) do
			if wholib then
				wholib:Who(k) --We have to use wholib if it's installed, it doesn't like others using who
			else
				badboy:Show() --start the onupdate data request
			end
			return
		end
	elseif evt == "PLAYER_LOGIN" then
		--update our safe list on login with guild/friends
		if IsInGuild() then
			GuildRoster()
		end
		ShowFriends()
		good[UnitName("player")] = true --add ourself
		wholib = _G.LibStub and _G.LibStub:GetLibrary("LibWho-2.0", true) or nil --I really dislike this lib
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

badboy:SetScript("OnUpdate", function(_, e)
	t = t + e
	if t > 1 then --throttle, request data once a second until we get it, it might be on cooldown
		t = 0 --reset counter
		FriendsFrame:UnregisterEvent("WHO_LIST_UPDATE") --don't show the who popup
		SetWhoToUI(1) --don't show results in chat
		for k in pairs(maybe) do
			SendWho(k) --sendwho any players needing processing
			return
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
 
	--not good or GM, added to maybe
	if not maybe[player] then maybe[player] = {} end
	local f = tostring(...)
	--one table per chatframe, incase we got whispers on 2+ chatframes
	if not maybe[player][f] then maybe[player][f] = {} end
	--one table per id, incase we got more than one whisper from a player whilst still processing
	local id = select(13, ...)
	maybe[player][f][id] = {}
	for i = 1, 13 do
		--store all the chat arguments incase we need to add it back (if it's a new good guy)
		maybe[player][f][id][i] = select(i, ...)
	end
	if wholib then
		wholib:Who(player) --We have to use wholib if it's installed, it doesn't like others using who
	else
		badboy:Show() --start the onupdate data request
	end
	count[player] = 0 --add to who counter entry
	return true --filter everything not good (maybe) and not GM
end)

--outgoing whisper filtering function
ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", function(_,_,msg,player)
	local sent = whisp:format(BADBOY_LEVEL and tonumber(BADBOY_LEVEL)+1 or 2)
	if msg == sent then return true end --filter out the reply whisper
	good[player] = true --If we want to whisper someone, they're good
end)

