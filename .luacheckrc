std = "lua51"
max_line_length = false
codes = true
ignore = {
	"212/self", -- (W212) unused argument self
	"542", -- (W542) empty if branch
}
globals = {
	"Ambiguate",
	"BadBoyIsFriendly",
	"BADBOY_LEVELS_DB",
	"C_BattleNet",
	"C_FriendList",
	"C_Timer",
	"Cellular",
	"ChatFrame_AddMessageEventFilter",
	"ChatFrame_MessageEventHandler",
	"ChatFrame1",
	"ERR_FRIEND_LIST_FULL",
	"GetAutoCompleteRealms",
	"geterrorhandler",
	"GetFramesRegisteredForEvent",
	"IsAddOnLoaded",
	"IsGuildMember",
	"MuteSoundFile",
	"SendChatMessage",
	"UnitInParty",
	"UnitInRaid",
	"UnitName",
	"UnmuteSoundFile",
	"WIM",

	-- Options
	"BadBoyConfig",
	"BadBoyLevelsConfigTitle",
	"CreateFrame",
	"GetLocale",
	"PlaySound",

	-- Classic
	"BNGetGameAccountInfoByGUID",
}
