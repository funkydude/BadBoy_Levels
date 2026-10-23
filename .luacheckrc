std = "lua51"
max_line_length = false
codes = true
ignore = {
	"212/self", -- (W212) unused argument self
	"542", -- (W542) empty if branch
	"121/BADBOY_LEVELS_DB", -- (W121) Our global SV table
	"122/BADBOY_LEVELS_DB", -- (W122) Our global SV table
}
read_globals = {
	"Ambiguate",
	"BadBoyIsFriendly",
	"BADBOY_LEVELS_DB",
	"C_AddOns",
	"C_BattleNet",
	"C_ChatInfo",
	"C_FriendList",
	"C_PartyInfo",
	"C_Timer",
	"Cellular",
	"ChatFrameUtil",
	"ChatFrame1",
	"ERR_FRIEND_LIST_FULL",
	"GetAutoCompleteRealms",
	"geterrorhandler",
	"GetFramesRegisteredForEvent",
	"IsGuildMember",
	"issecretvalue",
	"MuteSoundFile",
	"RegionalUniqueNamesEnabled",
	"UnitNameUnmodified",
	"UnmuteSoundFile",
	"WIM",

	-- Options
	"BadBoyConfig",
	"BadBoyLevelsConfigTitle",
	"CreateFrame",
	"GetLocale",
	"PlaySound",
}
