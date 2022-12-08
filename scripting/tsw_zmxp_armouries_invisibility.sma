/* AMX Mod X
*   Map Armouries Invisibility
*
* (c) Copyright 2007 by VEN
*
* This file is provided as is (no warranties)
*
*	DESCRIPTION
*		Plugin allow to control map armouries (ground weapons) visibility.
*		Once map ground weapon/armoury is hidden it can't be collected.
*		It's possible to restore map ground weapon/armoury visibility.
*
*	COMMANDS
*		set_invisible_armouries [?|flags|A] - sets invisible only given armouries
*		All armouries that isn't specified will become visible (if it was invisible).
*		Default access flag is "h" (ADMIN_CFG), can be changed in the *.sma.
*		Use ? command argument to view the list of armoury flags/names.
*		Use "A" command argument to set all armouries as invisible (hide all).
*		Use "", i.e. empty command argument to set all armouries as visible.
*
*	VERSIONS
*		0.2
*			- added "A" command argument to hide all armouries on the map
*			- improved "rehide on new round" method
*			- added non-32bit processors check/protection
*		0.1
*			- initial version
*/

// plugin's main information
#define PLUGIN_NAME "[ZMXP] Map Armouries Invisibility"
#define PLUGIN_VERSION "0.2"
#define PLUGIN_AUTHOR "VEN"

#include <amxmodx>
#include <amxmisc>
#include <fakemeta>

// you can set any ADMIN_* level from amxconst.inc
#define CMD_ACCESS_LEVEL ADMIN_CFG

#define OFFSET_ARMOURY_TYPE_WIN32 34
#define OFFSET_ARMOURY_TYPE_LINUXDIFF 4

#define GET_ARMOURY_TYPE(%1) get_pdata_int(%1, OFFSET_ARMOURY_TYPE_WIN32, OFFSET_ARMOURY_TYPE_LINUXDIFF)

new g_invisible_armouries = -1

new g_fw_id

public plugin_init() {
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR)

#if cellbits != 32
	new const msg_template[] = "%d-bit processors isn't supported. Contact the author for details."
	new msg_reason[sizeof msg_template + 1]
	formatex(msg_reason, sizeof msg_reason - 1, msg_template, cellbits)
	set_fail_state(msg_reason)
#endif

	register_event("HLTV", "event_new_round", "a", "1=0", "2=0")
	register_concmd("set_invisible_armouries", "cmd_set_invisible_armouries", CMD_ACCESS_LEVEL, "[?|A|flags] - hides only given armouries (? - flags list; A - ^"all^")")
}

public event_new_round() {
	if (g_invisible_armouries != -1)
		g_fw_id = register_forward(FM_StartFrame, "fwStartFrame")
}

public fwStartFrame() {
	unregister_forward(FM_StartFrame, g_fw_id)
	set_invisible_armouries()
}

public cmd_set_invisible_armouries(id, level, cid) {
	if (!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED

	static szflags[32]
	read_argv(1, szflags, sizeof szflags - 1)
	if (szflags[0] == '?') {
		static const armoury_names[][] = {"mp5navy", "tmp", "p90", "mac10", "ak47", "sg552", "m4a1", "aug", "scout", "g3sg1", "awp", "m3", "xm1014", "m249", "flashbang", "hegrenade", "vest", "vesthelm", "smokegrenade"}
		static const armoury_flags[sizeof armoury_names][] = {"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s"}
		static i
		for (i = 0; i < sizeof armoury_names; ++i)
			console_print(id, "%s - %s", armoury_flags[i], armoury_names[i])

		return PLUGIN_HANDLED
	}
	else if (szflags[0] == 'A')
		g_invisible_armouries = (1<<sizeof armoury_flags) - 1
	else
		g_invisible_armouries = read_flags(szflags)

	set_invisible_armouries()

	return PLUGIN_HANDLED
}

set_invisible_armouries() {
	static const armoury_entity[] = "armoury_entity"
	static const classname[] = "classname"
	static ent; ent = FM_NULLENT
	while ((ent = engfunc(EngFunc_FindEntityByString, ent, classname, armoury_entity))) {
		if (g_invisible_armouries & (1<<GET_ARMOURY_TYPE(ent))) {
			set_pev(ent, pev_effects, pev(ent, pev_effects) | EF_NODRAW)
			set_pev(ent, pev_solid, SOLID_NOT)
		}
		else {
			set_pev(ent, pev_effects, pev(ent, pev_effects) & ~EF_NODRAW)
			set_pev(ent, pev_solid, SOLID_TRIGGER)
		}
	}
}
