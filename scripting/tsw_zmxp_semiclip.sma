#include < amxmodx >
#include < engine >
#include < fakemeta >
#include < xs >

#include < play_global >

#define PLUGIN "[ZMXP] Semiclip"
#define VERSION "2.1"

#if AMXX_VERSION_NUM < 180
	#assert AMX Mod X v1.8.0 or later library required!
#endif

#include <hamsandwich>

/*================================================================================
 [Zombie Plague 4.3 Constants]
=================================================================================*/

/* Game modes for zp_round_started() */
enum
{
	MODE_INFECTION = 1,
	MODE_NEMESIS,
	MODE_SURVIVOR,
	MODE_SWARM,
	MODE_MULTI,
	MODE_PLAGUE
}

/*================================================================================
 [Constants, Offsets, Macros]
=================================================================================*/

const MAX_RENDER_AMOUNT = 255 // do not change this
const SEMI_RENDER_AMOUNT = 200
const Float:SPEC_INTERVAL = 0.2 // do not change this
const Float:RANGE_INTERVAL = 0.1 // do not change this

const PEV_SPEC_TARGET = pev_iuser2

enum (+= 35)
{
	TASK_SPECTATOR = 3000,
	TASK_RANGE,
	TASK_DURATION
}
#define ID_SPECTATOR	(taskid - TASK_SPECTATOR)
#define ID_RANGE		(taskid - TASK_RANGE)

const PDATA_SAFE = 2

new const WEAPON_ENTITY_NAMES[][] = { "", "weapon_p228", "", "weapon_scout", "weapon_hegrenade", "weapon_xm1014",
"weapon_c4", "weapon_mac10", "weapon_aug", "weapon_smokegrenade", "weapon_elite", "weapon_fiveseven",
"weapon_ump45", "weapon_sg550", "weapon_galil", "weapon_famas", "weapon_usp", "weapon_glock18", "weapon_awp",
"weapon_mp5navy", "weapon_m249", "weapon_m3", "weapon_m4a1", "weapon_tmp", "weapon_g3sg1", "weapon_flashbang",
"weapon_deagle", "weapon_sg552", "weapon_ak47", "weapon_knife", "weapon_p90" }

new const HUMAN_SPAWN_ENTITY_NAME[] = "info_player_start"
new const ZOMBIE_SPAWN_ENTITY_NAME[] = "info_player_deathmatch"

new const Float:random_own_place[][3] =
{
	{ 0.0, 0.0, 0.0 },
	{ -32.5, 0.0, 0.0 },
	{ 32.5, 0.0, 0.0 },
	{ 0.0, -32.5, 0.0 },
	{ 0.0, 32.5, 0.0 },
	{ -32.5, -32.5, 0.0 },
	{ -32.5, 32.5, 0.0 },
	{ 32.5, 32.5, 0.0 },
	{ 32.5, -32.5, 0.0 }
}

/*================================================================================
 [Global Variables]
=================================================================================*/

new cvar_iSemiClipRenderRadius, cvar_iSemiClipEnemies, cvar_iSemiClipButton,
cvar_flSemiClipUnstuckDelay, cvar_iSemiClipBlockTeams, cvar_iSemiClipUnstuck,
cvar_iSemiClipRenderMode, cvar_iSemiClipRenderAmt, cvar_iSemiClipRenderFade,
cvar_iSemiClipRenderFadeMin, cvar_iSemiClipRenderFadeSpec, cvar_iSemiClip,
cvar_iSemiClipRenderFx, cvar_iSemiClipKnifeTrace, cvar_flSemiClipDuration,
cvar_iSemiClipColorZombie[3], cvar_iSemiClipColorHuman[3], cvar_iSemiClipRender,
cvar_iSemiClipColorAdmin[3], cvar_szSemiClipColorFlag, cvar_iBotQuota

new bool:g_bHamCzBots, g_iMaxPlayers, bool:g_bPreparation,
g_iAddToFullPack, g_iTraceLine, g_iCmdStart

new cvar_iDisableInfection, cvar_iDisableMultiple, cvar_iDisableNemesis,
cvar_iDisableSurvivor, cvar_iDisableSwarm, cvar_iDisablePlague

new g_iSpawnCountHuman, Float:g_flSpawnsHuman[32][3],
g_iSpawnCountZombie, Float:g_flSpawnsZombie[32][3],
g_iSpawnCountCSDM, Float:g_flSpawnsCSDM[128][3]

new g_iCachedSemiClip, g_iCachedEnemies, g_iCachedBlockTeams, g_iCachedUnstuck,
Float:g_flCachedUnstuckDelay, g_iCachedFadeMin, g_iCachedFadeSpec,
g_iCachedMode, g_iCachedRadius, g_iCachedAmt, g_iCachedFx, g_iCachedRender,
g_iCachedFade, g_iCachedButton, g_iCachedKnifeTrace, g_iCachedColorZombie[3],
g_iCachedColorHuman[3], g_iCachedColorAdmin[3], g_iCachedColorFlag

new bs_IsAlive, bs_IsConnected, bs_IsBot, bs_IsSolid, bs_InSemiClip, bs_InButton, bs_IsAdmin

new g_iTeam[33], g_iSpectating[33], g_iSpectatingTeam[33], g_iCurrentWeapon[33], g_iRange[33][33]

new g_iZombieMod

#define add_bitsum(%1,%2)	(%1 |= (1<<(%2-1)))
#define del_bitsum(%1,%2)	(%1 &= ~(1<<(%2-1)))
#define get_bitsum(%1,%2)	(%1 & (1<<(%2-1)))

#define is_user_valid_alive(%1)		(1 <= %1 <= g_iMaxPlayers && get_bitsum(bs_IsAlive, %1))
#define is_same_team(%1,%2)			(g_iTeam[%1] == g_iTeam[%2])

// tsc_set_user_rendering
enum
{
	SPECIAL_MODE = 0,
	SPECIAL_AMT,
	SPECIAL_FX,
	MAX_SPECIAL
}
new bs_IsSpecial
new g_iRenderSpecial[33][MAX_SPECIAL]
new g_iRenderSpecialColor[33][MAX_SPECIAL]

/*================================================================================
 [Natives, Init and Cfg]
=================================================================================*/

public plugin_natives()
{
	register_native("tsc_set_user_rendering", "native_set_rendering", 1)
}

public plugin_init()
{
	register_plugin( PLUGIN, VERSION, AUTHOR );
	
	register_event("HLTV", "event_round_start", "a", "1=0", "2=0")
	
	RegisterHam(Ham_Spawn, "player", "fwd_PlayerSpawn_Post", 1)
	RegisterHam(Ham_Killed, "player", "fwd_PlayerKilled")
	RegisterHam(Ham_Player_PreThink, "player", "fwd_Player_PreThink_Post", 1)
	RegisterHam(Ham_Player_PostThink, "player", "fwd_Player_PostThink")
	
	g_iAddToFullPack = register_forward(FM_AddToFullPack, "fwd_AddToFullPack_Post", 1)
	g_iTraceLine = register_forward(FM_TraceLine, "fwd_TraceLine_Post", 1)
	g_iCmdStart = register_forward(FM_CmdStart, "fwd_CmdStart")
	
	register_message(get_user_msgid("TeamInfo"), "message_TeamInfo")
	for (new i = 1; i < sizeof WEAPON_ENTITY_NAMES; i++)
		if (WEAPON_ENTITY_NAMES[i][0]) RegisterHam(Ham_Item_Deploy, WEAPON_ENTITY_NAMES[i], "fwd_Item_Deploy_Post", 1)
	
	cvar_iSemiClip = register_cvar("semiclip", "1")
	cvar_iSemiClipBlockTeams = register_cvar("semiclip_blockteam", "0")
	cvar_iSemiClipEnemies = register_cvar("semiclip_enemies", "0")
	cvar_iSemiClipUnstuck = register_cvar("semiclip_unstuck", "1")
	cvar_flSemiClipUnstuckDelay = register_cvar("semiclip_unstuckdelay", "0.1")
	cvar_iSemiClipButton = register_cvar("semiclip_button", "0")
	cvar_iSemiClipKnifeTrace = register_cvar("semiclip_knife_trace", "0")
	cvar_flSemiClipDuration = register_cvar("semiclip_duration", "0")
	
	cvar_iSemiClipRender = register_cvar("semiclip_render", "1")
	cvar_iSemiClipRenderMode = register_cvar("semiclip_rendermode", "2")
	cvar_iSemiClipRenderAmt = register_cvar("semiclip_renderamt", "129")
	cvar_iSemiClipRenderFx = register_cvar("semiclip_renderfx", "0")
	cvar_iSemiClipRenderRadius = register_cvar("semiclip_renderradius", "250")
	cvar_iSemiClipRenderFade = register_cvar("semiclip_renderfade", "0")
	cvar_iSemiClipRenderFadeMin = register_cvar("semiclip_renderfademin", "25")
	cvar_iSemiClipRenderFadeSpec = register_cvar("semiclip_renderfadespec", "1")
	
	cvar_szSemiClipColorFlag = register_cvar("semiclip_color_admin_flag", "b")
	cvar_iSemiClipColorAdmin[0] = register_cvar("semiclip_color_admin_R", "0")
	cvar_iSemiClipColorAdmin[1] = register_cvar("semiclip_color_admin_G", "0")
	cvar_iSemiClipColorAdmin[2] = register_cvar("semiclip_color_admin_B", "0")
	cvar_iSemiClipColorZombie[0] = register_cvar("semiclip_color_zombie_R", "0")
	cvar_iSemiClipColorZombie[1] = register_cvar("semiclip_color_zombie_G", "0")
	cvar_iSemiClipColorZombie[2] = register_cvar("semiclip_color_zombie_B", "0")
	cvar_iSemiClipColorHuman[0] = register_cvar("semiclip_color_human_R", "0")
	cvar_iSemiClipColorHuman[1] = register_cvar("semiclip_color_human_G", "0")
	cvar_iSemiClipColorHuman[2] = register_cvar("semiclip_color_human_B", "0")
	
	cvar_iDisableInfection = register_cvar("semiclip_disable_on_infection", "0")
	cvar_iDisableMultiple = register_cvar("semiclip_disable_on_multiple", "0")
	cvar_iDisableNemesis = register_cvar("semiclip_disable_on_nemesis", "0")
	cvar_iDisableSurvivor = register_cvar("semiclip_disable_on_survivor", "0")
	cvar_iDisableSwarm = register_cvar("semiclip_disable_on_swarm", "0")
	cvar_iDisablePlague = register_cvar("semiclip_disable_on_plague", "0")
	
	register_cvar("Team_Semiclip_version", VERSION, FCVAR_SERVER|FCVAR_SPONLY)
	set_cvar_string("Team_Semiclip_version", VERSION)
	
	cvar_iBotQuota = get_cvar_pointer("bot_quota")
	
	new iZombiePlague = get_cvar_pointer("zp_on")
	if (iZombiePlague != 0) g_iZombieMod = get_pcvar_num(iZombiePlague);
	
	g_iMaxPlayers = get_maxplayers()
}

public plugin_cfg()
{
	new configsdir[32]
	get_configsdir(configsdir, charsmax(configsdir))
	server_cmd("exec %s/team_semiclip.cfg", configsdir)
	
	new ent
	ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
	
	if (pev_valid(ent))
	{
		register_think("ent_cache_cvars", "cache_cvars_think")
		
		set_pev(ent, pev_classname, "ent_cache_cvars")
		set_pev(ent, pev_nextthink, get_gametime() + 1.0)
	}
	else
	{
		set_task(1.0, "cache_cvars")
		set_task(12.0, "cache_cvars", _, _, _, "b")
	}
	
	set_task(1.5, "load_spawns")
}

public plugin_pause()
{
	unregister_forward(FM_AddToFullPack, g_iAddToFullPack, 1)
	unregister_forward(FM_TraceLine, g_iTraceLine, 1)
	unregister_forward(FM_CmdStart, g_iCmdStart)
	
	static id
	for (id = 1; id <= g_iMaxPlayers; id++)
	{
		if (!get_bitsum(bs_IsConnected, id) || !get_bitsum(bs_IsAlive, id)) continue
		
		if (get_bitsum(bs_InSemiClip, id))
		{
			set_pev(id, pev_solid, SOLID_SLIDEBOX)
			del_bitsum(bs_InSemiClip, id);
		}
	}
}

public plugin_unpause()
{
	g_iAddToFullPack = register_forward(FM_AddToFullPack, "fwd_AddToFullPack_Post", 1)
	g_iTraceLine = register_forward(FM_TraceLine, "fwd_TraceLine_Post", 1)
	g_iCmdStart = register_forward(FM_CmdStart, "fwd_CmdStart")
}

public client_putinserver(id)
{
	add_bitsum(bs_IsConnected, id);
	set_cvars(id)
	
	set_task(RANGE_INTERVAL, "range_check", id+TASK_RANGE, _, _, "b")
	
	if (is_user_bot(id))
	{
		add_bitsum(bs_IsBot, id);
		add_bitsum(bs_InButton, id);
		
		if (!g_bHamCzBots && cvar_iBotQuota)
			set_task(0.1, "register_ham_czbots", id)
	}
	else
	{
		set_task(SPEC_INTERVAL, "spec_check", id+TASK_SPECTATOR, _, _, "b")
	}
}

public client_disconnect(id)
{
	del_bitsum(bs_IsConnected, id);
	set_cvars(id)
	remove_task(id+TASK_RANGE)
	remove_task(id+TASK_SPECTATOR)
}

/*================================================================================
 [Main Events]
=================================================================================*/

public event_round_start()
{
	if (g_iZombieMod) g_bPreparation = true;
	
	remove_task(TASK_DURATION)
	
	if (get_pcvar_float(cvar_flSemiClipDuration) > 0.0)
	{
		set_pcvar_num(cvar_iSemiClip, 1)
		g_iCachedSemiClip = 1
		g_bPreparation = true
		
		set_task(get_pcvar_float(cvar_flSemiClipDuration), "disable_plugin", TASK_DURATION)
	}
}

public zp_round_started(gamemode, id)
{
	if (!task_exists(TASK_DURATION)) g_bPreparation = false;
	
	switch (gamemode)
	{
		case MODE_INFECTION: if (get_pcvar_num(cvar_iDisableInfection)) disable_plugin();
		case MODE_NEMESIS: if (get_pcvar_num(cvar_iDisableNemesis)) disable_plugin();
		case MODE_SURVIVOR: if (get_pcvar_num(cvar_iDisableSurvivor)) disable_plugin();
		case MODE_SWARM: if (get_pcvar_num(cvar_iDisableSwarm)) disable_plugin();
		case MODE_MULTI: if (get_pcvar_num(cvar_iDisableMultiple)) disable_plugin();
		case MODE_PLAGUE: if (get_pcvar_num(cvar_iDisablePlague)) disable_plugin();
	}
}

/*================================================================================
 [Main Forwards]
=================================================================================*/

public fwd_PlayerSpawn_Post(id)
{
	if (!is_user_alive(id) || !g_iTeam[id])
		return
	
	add_bitsum(bs_IsAlive, id);
	remove_task(id+TASK_SPECTATOR)
}

public fwd_PlayerKilled(id)
{
	del_bitsum(bs_IsAlive, id);
	del_bitsum(bs_InSemiClip, id);
	g_iTeam[id] = 3
	
	if (!get_bitsum(bs_IsBot, id))
		set_task(SPEC_INTERVAL, "spec_check", id+TASK_SPECTATOR, _, _, "b")
}

public fwd_Player_PreThink_Post(id)
{
	if (!g_iCachedSemiClip || !get_bitsum(bs_IsAlive, id))
		return FMRES_IGNORED
	
	static i
	for (i = 1; i <= g_iMaxPlayers; i++)
	{
		if (!get_bitsum(bs_IsConnected, i) || !get_bitsum(bs_IsAlive, i)) continue
		
		if (!get_bitsum(bs_InSemiClip, i)) add_bitsum(bs_IsSolid, i);
		else del_bitsum(bs_IsSolid, i);
	}
	
	if (get_bitsum(bs_IsSolid, id))
		for (i = 1; i <= g_iMaxPlayers; i++)
		{
			if (!get_bitsum(bs_IsConnected, i) || !get_bitsum(bs_IsAlive, i) || !get_bitsum(bs_IsSolid, i)) continue
			if (g_iRange[id][i] == MAX_RENDER_AMOUNT || i == id) continue
			if (g_bPreparation)
			{
				set_pev(i, pev_solid, SOLID_NOT)
				add_bitsum(bs_InSemiClip, i);
			}
			else
			{
				switch (g_iCachedButton)
				{
					case 3: // BOTH
					{
						if (get_bitsum(bs_InButton, id))
						{
							if (!g_iCachedEnemies && !is_same_team(i, id)) continue
						}
						else if (query_enemies(id, i)) continue
					}
					case 1, 2: // HUMAN or ZOMBIE
					{
						if (get_bitsum(bs_InButton, id) && g_iCachedButton == g_iTeam[id] && g_iCachedButton == g_iTeam[i])
						{
							if (g_iCachedEnemies && !is_same_team(i, id)) continue
						}
						else if (query_enemies(id, i)) continue
					}
					default: if (query_enemies(id, i)) continue;
				}
				
				set_pev(i, pev_solid, SOLID_NOT)
				add_bitsum(bs_InSemiClip, i);
			}
		}
	
	return FMRES_IGNORED
}

public fwd_Player_PostThink(id)
{
	if (!g_iCachedSemiClip || !get_bitsum(bs_IsAlive, id))
		return FMRES_IGNORED
	
	static i
	for (i = 1; i <= g_iMaxPlayers; i++)
	{
		if (!get_bitsum(bs_IsConnected, i) || !get_bitsum(bs_IsAlive, i)) continue
		
		if (get_bitsum(bs_InSemiClip, i))
		{
			set_pev(i, pev_solid, SOLID_SLIDEBOX)
			del_bitsum(bs_InSemiClip, i);
		}
	}
	
	return FMRES_IGNORED
}

public fwd_AddToFullPack_Post(es_handle, e, ent, host, flags, player, pSet)
{
	if (!g_iCachedSemiClip || !player) return FMRES_IGNORED
	
	if (g_iTeam[host] == 3)
	{
		if (!g_iCachedRender || get_bitsum(bs_IsBot, host) || !get_bitsum(bs_IsAlive, g_iSpectating[host]) || !get_bitsum(bs_IsAlive, ent)) return FMRES_IGNORED
		if (g_iRange[g_iSpectating[host]][ent] == MAX_RENDER_AMOUNT) return FMRES_IGNORED
		if (!g_iCachedFadeSpec && g_iSpectating[host] == ent) return FMRES_IGNORED
		if (g_bPreparation)
		{
			if (get_bitsum(bs_IsSpecial, ent))
			{
				set_es(es_handle, ES_RenderMode, g_iRenderSpecial[ent][SPECIAL_MODE])
				set_es(es_handle, ES_RenderAmt, g_iRenderSpecial[ent][SPECIAL_AMT])
				set_es(es_handle, ES_RenderFx, g_iRenderSpecial[ent][SPECIAL_FX])
				set_es(es_handle, ES_RenderColor, g_iRenderSpecialColor[ent])
			}
			else
			{
				set_es(es_handle, ES_RenderMode, g_iCachedMode)
				set_es(es_handle, ES_RenderAmt, g_iRange[g_iSpectating[host]][ent])
				set_es(es_handle, ES_RenderFx, g_iCachedFx)
				get_bitsum(bs_IsAdmin, ent) ? set_es(es_handle, ES_RenderColor, g_iCachedColorAdmin) : set_es(es_handle, ES_RenderColor, g_iCachedColorHuman);
			}
			
			return FMRES_IGNORED
		}
		else
		{
			switch (g_iCachedButton)
			{
				case 3: // BOTH
				{
					if (get_bitsum(bs_InButton, g_iSpectating[host]))
					{
						if (!g_iCachedEnemies && !is_same_team(ent, g_iSpectating[host])) return FMRES_IGNORED
					}
					else if (query_enemies(g_iSpectating[host], ent)) return FMRES_IGNORED
				}
				case 1, 2: // HUMAN or ZOMBIE
				{
					if (get_bitsum(bs_InButton, g_iSpectating[host]) && g_iCachedButton == g_iTeam[g_iSpectating[host]] && g_iCachedButton == g_iTeam[ent])
					{
						if (g_iCachedEnemies && !is_same_team(ent, g_iSpectating[host])) return FMRES_IGNORED
					}
					else if (query_enemies(g_iSpectating[host], ent)) return FMRES_IGNORED
				}
				default: if (query_enemies(g_iSpectating[host], ent)) return FMRES_IGNORED;
			}
			
			if (get_bitsum(bs_IsSpecial, ent))
			{
				set_es(es_handle, ES_RenderMode, g_iRenderSpecial[ent][SPECIAL_MODE])
				set_es(es_handle, ES_RenderAmt, g_iRenderSpecial[ent][SPECIAL_AMT])
				set_es(es_handle, ES_RenderFx, g_iRenderSpecial[ent][SPECIAL_FX])
				set_es(es_handle, ES_RenderColor, g_iRenderSpecialColor[ent])
			}
			else
			{
				set_es(es_handle, ES_RenderMode, g_iCachedMode)
				set_es(es_handle, ES_RenderAmt, g_iRange[g_iSpectating[host]][ent])
				set_es(es_handle, ES_RenderFx, g_iCachedFx)
				switch (g_iTeam[ent])
				{
					case 1: get_bitsum(bs_IsAdmin, ent) ? set_es(es_handle, ES_RenderColor, g_iCachedColorAdmin) : set_es(es_handle, ES_RenderColor, g_iCachedColorZombie);
					case 2: get_bitsum(bs_IsAdmin, ent) ? set_es(es_handle, ES_RenderColor, g_iCachedColorAdmin) : set_es(es_handle, ES_RenderColor, g_iCachedColorHuman);
				}
			}
			
			return FMRES_IGNORED
		}
	}
	
	if (!get_bitsum(bs_IsAlive, host) || !get_bitsum(bs_IsAlive, ent) || !get_bitsum(bs_IsSolid, host) || !get_bitsum(bs_IsSolid, ent)) return FMRES_IGNORED
	if (g_iRange[host][ent] == MAX_RENDER_AMOUNT) return FMRES_IGNORED
	if (g_bPreparation)
	{
		set_es(es_handle, ES_Solid, SOLID_NOT)
		
		if (!g_iCachedRender) return FMRES_IGNORED
		
		if (get_bitsum(bs_IsSpecial, ent))
		{
			set_es(es_handle, ES_RenderMode, g_iRenderSpecial[ent][SPECIAL_MODE])
			set_es(es_handle, ES_RenderAmt, g_iRenderSpecial[ent][SPECIAL_AMT])
			set_es(es_handle, ES_RenderFx, g_iRenderSpecial[ent][SPECIAL_FX])
			set_es(es_handle, ES_RenderColor, g_iRenderSpecialColor[ent])
		}
		else
		{
			set_es(es_handle, ES_RenderMode, g_iCachedMode)
			set_es(es_handle, ES_RenderAmt, g_iRange[host][ent])
			set_es(es_handle, ES_RenderFx, g_iCachedFx)
			get_bitsum(bs_IsAdmin, ent) ? set_es(es_handle, ES_RenderColor, g_iCachedColorAdmin) : set_es(es_handle, ES_RenderColor, g_iCachedColorHuman);
		}
		
		return FMRES_IGNORED
	}
	else
	{
		switch (g_iCachedButton)
		{
			case 3: // BOTH
			{
				if (get_bitsum(bs_InButton, host))
				{
					if (!g_iCachedEnemies && !is_same_team(ent, host)) return FMRES_IGNORED
				}
				else if (query_enemies(host, ent)) return FMRES_IGNORED
			}
			case 1, 2: // HUMAN or ZOMBIE
			{
				if (get_bitsum(bs_InButton, host) && g_iCachedButton == g_iTeam[host] && g_iCachedButton == g_iTeam[ent])
				{
					if (g_iCachedEnemies && !is_same_team(ent, host)) return FMRES_IGNORED
				}
				else if (query_enemies(host, ent)) return FMRES_IGNORED
			}
			default: if (query_enemies(host, ent)) return FMRES_IGNORED;
		}
		
		set_es(es_handle, ES_Solid, SOLID_NOT)
		
		if (!g_iCachedRender) return FMRES_IGNORED
		
		if (get_bitsum(bs_IsSpecial, ent))
		{
			set_es(es_handle, ES_RenderMode, g_iRenderSpecial[ent][SPECIAL_MODE])
			set_es(es_handle, ES_RenderAmt, g_iRenderSpecial[ent][SPECIAL_AMT])
			set_es(es_handle, ES_RenderFx, g_iRenderSpecial[ent][SPECIAL_FX])
			set_es(es_handle, ES_RenderColor, g_iRenderSpecialColor[ent])
		}
		else
		{
			set_es(es_handle, ES_RenderMode, g_iCachedMode)
			set_es(es_handle, ES_RenderAmt, g_iRange[host][ent])
			set_es(es_handle, ES_RenderFx, g_iCachedFx)
			switch (g_iTeam[ent])
			{
				case 1: get_bitsum(bs_IsAdmin, ent) ? set_es(es_handle, ES_RenderColor, g_iCachedColorAdmin) : set_es(es_handle, ES_RenderColor, g_iCachedColorZombie);
				case 2: get_bitsum(bs_IsAdmin, ent) ? set_es(es_handle, ES_RenderColor, g_iCachedColorAdmin) : set_es(es_handle, ES_RenderColor, g_iCachedColorHuman);
			}
		}
	}
	
	return FMRES_IGNORED
}

public fwd_TraceLine_Post(Float:vStart[3], Float:vEnd[3], noMonsters, id, trace)
{
	if (!g_iCachedSemiClip || !g_iCachedKnifeTrace || !is_user_valid_alive(id) || g_iCurrentWeapon[id] != CSW_KNIFE)
		return FMRES_IGNORED
	
	new Float:flFraction
	get_tr2(trace, TR_flFraction, flFraction)
	if (flFraction >= 1.0)
		return FMRES_IGNORED
	
	new pHit = get_tr2(trace, TR_pHit)
	if (!is_user_valid_alive(pHit) || !is_same_team(id, pHit) || entity_range(id, pHit) > 48.0)
		return FMRES_IGNORED
	
	new	Float:start[3], Float:view_ofs[3], Float:direction[3], Float:tlStart[3], Float:tlEnd[3]
	
	pev(id, pev_origin, start)
	pev(id, pev_view_ofs, view_ofs)
	xs_vec_add(start, view_ofs, start)
	
	velocity_by_aim(id, 22, direction)
	xs_vec_add(direction, start, tlStart)
	velocity_by_aim(id, 48, direction)
	xs_vec_add(direction, start, tlEnd)
	
	engfunc(EngFunc_TraceLine, tlStart, tlEnd, noMonsters|DONT_IGNORE_MONSTERS, pHit, 0)
	
	new tHit = get_tr2(0, TR_pHit)
	if (!is_user_valid_alive(tHit) || is_same_team(id, tHit))
		return FMRES_IGNORED
	
	set_tr2(trace, TR_AllSolid, get_tr2(0, TR_AllSolid))
	set_tr2(trace, TR_StartSolid, get_tr2(0, TR_StartSolid))
	set_tr2(trace, TR_InOpen, get_tr2(0, TR_InOpen))
	set_tr2(trace, TR_InWater, get_tr2(0, TR_InWater))
	set_tr2(trace, TR_iHitgroup, get_tr2(0, TR_iHitgroup))
	set_tr2(trace, TR_pHit, tHit)
	
	return FMRES_IGNORED
}

public fwd_CmdStart(id, handle)
{
	if (!g_iCachedSemiClip || !g_iCachedButton || !get_bitsum(bs_IsAlive, id) || get_bitsum(bs_IsBot, id))
		return
	
	(get_uc(handle, UC_Buttons) & IN_USE) ? add_bitsum(bs_InButton, id) : del_bitsum(bs_InButton, id);
}

public fwd_Item_Deploy_Post(ent)
{
	static owner ; owner = ham_cs_get_weapon_ent_owner(ent)
	
	if (!is_user_valid_alive(owner))
		return HAM_IGNORED
	
	g_iCurrentWeapon[owner] = fm_cs_get_weapon_id(ent)
	
	return HAM_IGNORED
}

/*================================================================================
 [Other Functions and Tasks]
=================================================================================*/

// credits to MeRcyLeZZ
public register_ham_czbots(id)
{
	if (g_bHamCzBots || !is_user_connected(id) || !get_pcvar_num(cvar_iBotQuota))
		return
	
	RegisterHamFromEntity(Ham_Spawn, id, "fwd_PlayerSpawn_Post", 1)
	RegisterHamFromEntity(Ham_Killed, id, "fwd_PlayerKilled")
	RegisterHamFromEntity(Ham_Player_PreThink, id, "fwd_Player_PreThink_Post", 1)
	RegisterHamFromEntity(Ham_Player_PostThink, id, "fwd_Player_PostThink")
	
	g_bHamCzBots = true
	
	if (is_user_alive(id))
		fwd_PlayerSpawn_Post(id)
}

public cache_cvars()
{
	g_iCachedSemiClip = !!get_pcvar_num(cvar_iSemiClip)
	g_iCachedEnemies = !!get_pcvar_num(cvar_iSemiClipEnemies)
	g_iCachedBlockTeams = clamp(get_pcvar_num(cvar_iSemiClipBlockTeams), 0, 3)
	g_iCachedUnstuck = clamp(get_pcvar_num(cvar_iSemiClipUnstuck), 0, 3)
	g_flCachedUnstuckDelay = floatclamp(get_pcvar_float(cvar_flSemiClipUnstuckDelay), 0.0, 3.0)
	g_iCachedButton = clamp(get_pcvar_num(cvar_iSemiClipButton), 0, 3)
	g_iCachedKnifeTrace = !!get_pcvar_num(cvar_iSemiClipKnifeTrace)
	
	g_iCachedRender = !!get_pcvar_num(cvar_iSemiClipRender)
	g_iCachedMode = clamp(get_pcvar_num(cvar_iSemiClipRenderMode), 0, 5)
	g_iCachedAmt = clamp(get_pcvar_num(cvar_iSemiClipRenderAmt), 0, 255)
	g_iCachedFx = clamp(get_pcvar_num(cvar_iSemiClipRenderFx), 0, 20)
	g_iCachedFade = !!get_pcvar_num(cvar_iSemiClipRenderFade)
	g_iCachedFadeMin = clamp(get_pcvar_num(cvar_iSemiClipRenderFadeMin), 0, SEMI_RENDER_AMOUNT)
	g_iCachedFadeSpec = !!get_pcvar_num(cvar_iSemiClipRenderFadeSpec)
	g_iCachedRadius = clamp(get_pcvar_num(cvar_iSemiClipRenderRadius), SEMI_RENDER_AMOUNT - g_iCachedFadeMin, 4095)
	
	static szFlags[24] ; get_pcvar_string(cvar_szSemiClipColorFlag, szFlags, charsmax(szFlags))	
	g_iCachedColorFlag = read_flags(szFlags)
	g_iCachedColorZombie[0] = clamp(get_pcvar_num(cvar_iSemiClipColorZombie[0]), 0, 255)
	g_iCachedColorZombie[1] = clamp(get_pcvar_num(cvar_iSemiClipColorZombie[1]), 0, 255)
	g_iCachedColorZombie[2] = clamp(get_pcvar_num(cvar_iSemiClipColorZombie[2]), 0, 255)
	g_iCachedColorHuman[0] = clamp(get_pcvar_num(cvar_iSemiClipColorHuman[0]), 0, 255)
	g_iCachedColorHuman[1] = clamp(get_pcvar_num(cvar_iSemiClipColorHuman[1]), 0, 255)
	g_iCachedColorHuman[2] = clamp(get_pcvar_num(cvar_iSemiClipColorHuman[2]), 0, 255)
	g_iCachedColorAdmin[0] = clamp(get_pcvar_num(cvar_iSemiClipColorAdmin[0]), 0, 255)
	g_iCachedColorAdmin[1] = clamp(get_pcvar_num(cvar_iSemiClipColorAdmin[1]), 0, 255)
	g_iCachedColorAdmin[2] = clamp(get_pcvar_num(cvar_iSemiClipColorAdmin[2]), 0, 255)
	
	static id
	for (id = 1; id <= g_iMaxPlayers; id++)
	{
		if (!get_bitsum(bs_IsConnected, id)) continue
		
		(get_user_flags(id) & g_iCachedColorFlag) ? add_bitsum(bs_IsAdmin, id) : del_bitsum(bs_IsAdmin, id);
	}
}

public cache_cvars_think(ent)
{
	if (!pev_valid(ent)) return;
	
	g_iCachedSemiClip = !!get_pcvar_num(cvar_iSemiClip)
	g_iCachedEnemies = !!get_pcvar_num(cvar_iSemiClipEnemies)
	g_iCachedBlockTeams = clamp(get_pcvar_num(cvar_iSemiClipBlockTeams), 0, 3)
	g_iCachedUnstuck = clamp(get_pcvar_num(cvar_iSemiClipUnstuck), 0, 3)
	g_flCachedUnstuckDelay = floatclamp(get_pcvar_float(cvar_flSemiClipUnstuckDelay), 0.0, 3.0)
	g_iCachedButton = clamp(get_pcvar_num(cvar_iSemiClipButton), 0, 3)
	g_iCachedKnifeTrace = !!get_pcvar_num(cvar_iSemiClipKnifeTrace)
	
	g_iCachedRender = !!get_pcvar_num(cvar_iSemiClipRender)
	g_iCachedMode = clamp(get_pcvar_num(cvar_iSemiClipRenderMode), 0, 5)
	g_iCachedAmt = clamp(get_pcvar_num(cvar_iSemiClipRenderAmt), 0, 255)
	g_iCachedFx = clamp(get_pcvar_num(cvar_iSemiClipRenderFx), 0, 20)
	g_iCachedFade = !!get_pcvar_num(cvar_iSemiClipRenderFade)
	g_iCachedFadeMin = clamp(get_pcvar_num(cvar_iSemiClipRenderFadeMin), 0, SEMI_RENDER_AMOUNT)
	g_iCachedFadeSpec = !!get_pcvar_num(cvar_iSemiClipRenderFadeSpec)
	g_iCachedRadius = clamp(get_pcvar_num(cvar_iSemiClipRenderRadius), SEMI_RENDER_AMOUNT - g_iCachedFadeMin, 4095)
	
	static szFlags[24] ; get_pcvar_string(cvar_szSemiClipColorFlag, szFlags, charsmax(szFlags))	
	g_iCachedColorFlag = read_flags(szFlags)
	g_iCachedColorZombie[0] = clamp(get_pcvar_num(cvar_iSemiClipColorZombie[0]), 0, 255)
	g_iCachedColorZombie[1] = clamp(get_pcvar_num(cvar_iSemiClipColorZombie[1]), 0, 255)
	g_iCachedColorZombie[2] = clamp(get_pcvar_num(cvar_iSemiClipColorZombie[2]), 0, 255)
	g_iCachedColorHuman[0] = clamp(get_pcvar_num(cvar_iSemiClipColorHuman[0]), 0, 255)
	g_iCachedColorHuman[1] = clamp(get_pcvar_num(cvar_iSemiClipColorHuman[1]), 0, 255)
	g_iCachedColorHuman[2] = clamp(get_pcvar_num(cvar_iSemiClipColorHuman[2]), 0, 255)
	g_iCachedColorAdmin[0] = clamp(get_pcvar_num(cvar_iSemiClipColorAdmin[0]), 0, 255)
	g_iCachedColorAdmin[1] = clamp(get_pcvar_num(cvar_iSemiClipColorAdmin[1]), 0, 255)
	g_iCachedColorAdmin[2] = clamp(get_pcvar_num(cvar_iSemiClipColorAdmin[2]), 0, 255)
	
	static id
	for (id = 1; id <= g_iMaxPlayers; id++)
	{
		if (!get_bitsum(bs_IsConnected, id)) continue
		
		(get_user_flags(id) & g_iCachedColorFlag) ? add_bitsum(bs_IsAdmin, id) : del_bitsum(bs_IsAdmin, id);
	}
	
	set_pev(ent, pev_nextthink, get_gametime() + 12.0)
}

public load_spawns()
{
	new cfgdir[32], mapname[32], filepath[100], linedata[64]
	
	get_configsdir(cfgdir, charsmax(cfgdir))
	get_mapname(mapname, charsmax(mapname))
	formatex(filepath, charsmax(filepath), "%s/csdm/%s.spawns.cfg", cfgdir, mapname)
	
	if (file_exists(filepath))
	{
		new csdmdata[10][6], file
		if ((file = fopen(filepath,"rt")) != 0)
		{
			while (!feof(file))
			{
				fgets(file, linedata, charsmax(linedata))
				
				if (!linedata[0] || str_count(linedata,' ') < 2) continue;
				
				parse(linedata,csdmdata[0],5,csdmdata[1],5,csdmdata[2],5,csdmdata[3],5,csdmdata[4],5,csdmdata[5],5,csdmdata[6],5,csdmdata[7],5,csdmdata[8],5,csdmdata[9],5)
				
				g_flSpawnsCSDM[g_iSpawnCountCSDM][0] = floatstr(csdmdata[0])
				g_flSpawnsCSDM[g_iSpawnCountCSDM][1] = floatstr(csdmdata[1])
				g_flSpawnsCSDM[g_iSpawnCountCSDM][2] = floatstr(csdmdata[2])
				
				g_iSpawnCountCSDM++
				if (g_iSpawnCountCSDM >= sizeof g_flSpawnsCSDM) break;
			}
			fclose(file)
		}
	}
	else if (g_iCachedUnstuck == 2)
	{
		set_pcvar_num(cvar_iSemiClipUnstuck, 1)
		g_iCachedUnstuck = 1
	}
	
	cs_collect_spawns_ents()
}

public random_spawn_delay(id)
{
	do_random_spawn(id, g_iCachedUnstuck)
}

// credits to MeRcyLeZZ
do_random_spawn(id, mode)
{
	if (!get_bitsum(bs_IsConnected, id) || !get_bitsum(bs_IsAlive, id))
		return
	
	static hull, sp_index, i
	hull = (pev(id, pev_flags) & FL_DUCKING) ? HULL_HEAD : HULL_HUMAN
	
	switch (mode)
	{
		case 1: // Specified team
		{
			switch (g_iTeam[id])
			{
				case 1: // ZOMBIE
				{
					if (!g_iSpawnCountZombie)
						return
					
					sp_index = random_num(0, g_iSpawnCountZombie - 1)
					for (i = sp_index + 1; /*no condition*/; i++)
					{
						if (i >= g_iSpawnCountZombie) i = 0
						
						if (is_hull_vacant(g_flSpawnsZombie[i], hull))
						{
							engfunc(EngFunc_SetOrigin, id, g_flSpawnsZombie[i])
							break
						}
						
						if (i == sp_index)
							break
					}
				}
				case 2: // HUMAN
				{
					if (!g_iSpawnCountHuman)
						return
					
					sp_index = random_num(0, g_iSpawnCountHuman - 1)
					for (i = sp_index + 1; /*no condition*/; i++)
					{
						if (i >= g_iSpawnCountHuman) i = 0
						
						if (is_hull_vacant(g_flSpawnsHuman[i], hull))
						{
							engfunc(EngFunc_SetOrigin, id, g_flSpawnsHuman[i])
							break
						}
						
						if (i == sp_index)
							break
					}
				}
			}
		}
		case 2: // CSDM
		{
			if (!g_iSpawnCountCSDM)
				return
			
			sp_index = random_num(0, g_iSpawnCountCSDM - 1)
			for (i = sp_index + 1; /*no condition*/; i++)
			{
				if (i >= g_iSpawnCountCSDM) i = 0
				
				if (is_hull_vacant(g_flSpawnsCSDM[i], hull))
				{
					engfunc(EngFunc_SetOrigin, id, g_flSpawnsCSDM[i])
					break
				}
				
				if (i == sp_index)
					break
			}
		}
		case 3: // Random around own place
		{
			new Float:origin[3], Float:new_origin[3], Float:final[3]
			pev(id, pev_origin, origin)
			
			for (new test = 0; test < sizeof random_own_place; test++)
			{
				final[0] = new_origin[0] = (origin[0] + random_own_place[test][0])
				final[1] = new_origin[1] = (origin[1] + random_own_place[test][1])
				final[2] = new_origin[2] = (origin[2] + random_own_place[test][2])
				
				new z = 0
				do
				{
					if (is_hull_vacant(final, hull))
					{
						test = sizeof random_own_place
						engfunc(EngFunc_SetOrigin, id, final)
						break
					}
					
					final[2] = new_origin[2] + (++z*20)
				}
				while (z < 5)
			}
		}
	}
}

// credits to MeRcyLeZZ (I rewritten it.)
cs_collect_spawns_ents()
{
	// HUMAN
	new ent = -1
	
	while ((ent = engfunc(EngFunc_FindEntityByString, ent, "classname", HUMAN_SPAWN_ENTITY_NAME)) != 0)
	{
		new Float:originF[3]
		pev(ent, pev_origin, originF)
		g_flSpawnsHuman[g_iSpawnCountHuman][0] = originF[0]
		g_flSpawnsHuman[g_iSpawnCountHuman][1] = originF[1]
		g_flSpawnsHuman[g_iSpawnCountHuman][2] = originF[2]
		
		g_iSpawnCountHuman++
		if (g_iSpawnCountHuman >= sizeof g_flSpawnsHuman) break
	}
	
	// ZOMBIE
	ent = -1
	
	while ((ent = engfunc(EngFunc_FindEntityByString, ent, "classname", ZOMBIE_SPAWN_ENTITY_NAME)) != 0)
	{
		new Float:originF[3]
		pev(ent, pev_origin, originF)
		g_flSpawnsZombie[g_iSpawnCountZombie][0] = originF[0]
		g_flSpawnsZombie[g_iSpawnCountZombie][1] = originF[1]
		g_flSpawnsZombie[g_iSpawnCountZombie][2] = originF[2]
		
		g_iSpawnCountZombie++
		if (g_iSpawnCountZombie >= sizeof g_flSpawnsZombie) break
	}
}

public range_check(taskid)
{
	if (!g_iCachedSemiClip)
		return
	
	static id
	for (id = 1; id <= g_iMaxPlayers; id++)
	{
		if (!get_bitsum(bs_IsConnected, id) || !get_bitsum(bs_IsAlive, id)) continue
		
		g_iRange[ID_RANGE][id] = calc_fade(ID_RANGE, id, g_iCachedFade)
	}
}

public spec_check(taskid)
{
	if (!g_iCachedSemiClip || get_bitsum(bs_IsAlive, ID_SPECTATOR))
		return
	
	static spec
	spec = pev(ID_SPECTATOR, PEV_SPEC_TARGET)
	
	if (get_bitsum(bs_IsAlive, spec))
	{
		g_iSpectating[ID_SPECTATOR] = spec
		g_iSpectatingTeam[ID_SPECTATOR] = g_iTeam[spec]
	}
}

public disable_plugin()
{
	set_pcvar_num(cvar_iSemiClip, 0)
	g_iCachedSemiClip = 0
	g_bPreparation = false
	
	for (new id = 1; id <= g_iMaxPlayers; id++)
	{
		if (!get_bitsum(bs_IsConnected, id) || !get_bitsum(bs_IsAlive, id)) continue
		
		if (get_bitsum(bs_InSemiClip, id))
		{
			set_pev(id, pev_solid, SOLID_SLIDEBOX)
			del_bitsum(bs_InSemiClip, id);
		}
		
		if (g_iCachedUnstuck && is_player_stuck(id))
			do_random_spawn(id, g_iCachedUnstuck)
	}
}

calc_fade(host, ent, mode)
{
	if (mode)
	{
		if (g_iCachedFadeMin > g_iCachedRadius)
			return MAX_RENDER_AMOUNT;
		
		static range ; range = floatround(entity_range(host, ent))
		
		if (range >= g_iCachedRadius)
			return MAX_RENDER_AMOUNT;
		
		static amount
		amount = SEMI_RENDER_AMOUNT - g_iCachedFadeMin
		amount = g_iCachedRadius / amount
		amount = range / amount + g_iCachedFadeMin
		
		return amount;
	}
	else
	{
		static range ; range = floatround(entity_range(host, ent))
		
		if (range < g_iCachedRadius)
			return g_iCachedAmt;
	}
	
	return MAX_RENDER_AMOUNT;
}

query_enemies(host, ent)
{
	if (g_iCachedBlockTeams == 3) return 1;
	
	switch (g_iCachedEnemies)
	{
		case 0: if (!is_same_team(ent, host) || g_iCachedBlockTeams == g_iTeam[ent]) return 1;
		case 1: if (g_iCachedBlockTeams == g_iTeam[ent] && is_same_team(ent, host)) return 1;
	}
	
	return 0;
}

set_cvars(id)
{
	del_bitsum(bs_IsAlive, id);
	del_bitsum(bs_IsBot, id);
	del_bitsum(bs_IsSolid, id);
	del_bitsum(bs_InSemiClip, id);
	del_bitsum(bs_IsSpecial, id);
	g_iTeam[id] = 0
}

/*================================================================================
 [Message Hooks]
=================================================================================*/

/*
	TeamInfo:
	read_data(1)	byte	EventEntity
	read_data(2)	string	TeamName
	
	type |                   name |      calls | time     / min      / max
	   p |       message_TeamInfo |        629 | 0.000116 / 0.000000 / 0.000002
	
	fast enough!
*/
public message_TeamInfo(msg_id, msg_dest)
{
	if (msg_dest != MSG_ALL && msg_dest != MSG_BROADCAST)
		return
	
	static id, team[2]
	id = get_msg_arg_int(1)
	get_msg_arg_string(2, team, charsmax(team))
	
	switch (team[0])
	{
		case 'T': g_iTeam[id] = 1; // ZOMBIE
		case 'C': g_iTeam[id] = 2; // HUMAN
		case 'S': g_iTeam[id] = 3; // SPECTATOR
		default: g_iTeam[id] = 0;
	}
	
	if (g_iCachedUnstuck && get_bitsum(bs_IsAlive, id) && g_iCachedBlockTeams == g_iTeam[id])
	{
		if (!is_player_stuck(id))
			return
		
		if (g_flCachedUnstuckDelay > 0.0)
			set_task(g_flCachedUnstuckDelay, "random_spawn_delay", id)
		else
			do_random_spawn(id, g_iCachedUnstuck)
	}
}

/*================================================================================
 [Custom Natives]
=================================================================================*/

// tsc_set_rendering(id, special = 0, fx = kRenderFxNone, r = 255, g = 255, b = 255, render = kRenderNormal, amount = 16)
public native_set_rendering(id, special, fx, r, g, b, render, amount)
{
	if (!is_user_connected(id))
	{
		log_error(AMX_ERR_NATIVE, "[Team Semiclip] Player is not in game (%d)", id)
		return 0;
	}
	
	switch (special)
	{
		case 0:
		{
			del_bitsum(bs_IsSpecial, id);
			
			return 1;
		}
		case 1:
		{
			add_bitsum(bs_IsSpecial, id);
			
			g_iRenderSpecial[id][SPECIAL_MODE] = clamp(render, 0, 5)
			g_iRenderSpecial[id][SPECIAL_AMT] = clamp(amount, 0, 255)
			g_iRenderSpecial[id][SPECIAL_FX] = clamp(fx, 0, 20)
			
			g_iRenderSpecialColor[id][0] = clamp(r, 0, 255)
			g_iRenderSpecialColor[id][1] = clamp(g, 0, 255)
			g_iRenderSpecialColor[id][2] = clamp(b, 0, 255)
			
			return 1;
		}
	}
	
	return 0;
}

/*================================================================================
 [Stocks]
=================================================================================*/

// credits to VEN
stock is_player_stuck(id)
{
	static Float:originF[3]
	pev(id, pev_origin, originF)
	
	engfunc(EngFunc_TraceHull, originF, originF, 0, (pev(id, pev_flags) & FL_DUCKING) ? HULL_HEAD : HULL_HUMAN, id, 0)
	
	if (get_tr2(0, TR_StartSolid) || get_tr2(0, TR_AllSolid) || !get_tr2(0, TR_InOpen))
		return true;
	
	return false;
}

// credits to VEN
stock is_hull_vacant(Float:origin[3], hull)
{
	engfunc(EngFunc_TraceHull, origin, origin, 0, hull, 0, 0)
	
	if (!get_tr2(0, TR_StartSolid) && !get_tr2(0, TR_AllSolid) && get_tr2(0, TR_InOpen))
		return true;
	
	return false;
}

// Stock by (probably) Twilight Suzuka -counts number of chars in a string
stock str_count(str[], searchchar)
{
	new count, i, len = strlen(str)
	
	for (i = 0; i <= len; i++)
	{
		if (str[i] == searchchar)
			count++
	}
	
	return count;
}

// credits to Exolent[jNr]
/*
stock fm_cs_get_weapon_id(ent)
{
	if (pev_valid(ent) != PDATA_SAFE)
		return 0;
	
	return get_pdata_int(ent, OFFSET_WEAPONID, OFFSET_LINUX_WEAPONS);
}
*/

// credits to MeRcyLeZZ
stock ham_cs_get_weapon_ent_owner(ent)
{
	if (pev_valid(ent) != PDATA_SAFE)
		return 0;
	
	return get_pdata_cbase(ent, OFFSET_WEAPONOWNER, OFFSET_WPN_LINUX );
}

// amxmisc.inc
stock get_configsdir(name[], len)
{
	return get_localinfo("amxx_configsdir", name, len);
}
