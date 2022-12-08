#include < amxmodx >
#include < fakemeta >
#include < zombieplague >
#include < play_global >

#define PLUGIN "[ZMXP] 50-50 Plague Mode"
#define VERSION "2.0"

new g_maxplayers, cvar_plaguenemhpmulti, cvar_plaguesurvhpmulti

public plugin_init(){
	register_plugin( PLUGIN, VERSION, AUTHOR );
	
	g_maxplayers = get_maxplayers()
}

public plugin_cfg()
{
	cvar_plaguenemhpmulti = get_cvar_pointer("zp_plague_nem_hp_multi")
	cvar_plaguesurvhpmulti = get_cvar_pointer("zp_plague_surv_hp_multi")
}

public zp_round_started(gamemode)
{
	// Plague mode only
	if (gamemode != MODE_PLAGUE)
		return;
	
	static id
	for (id = 1; id <= g_maxplayers; id++)
	{
		// Dead or already a nemesis/survivor
		if (!is_user_alive(id) || zp_get_user_nemesis(id) || zp_get_user_survivor(id))
			continue;
		
		if (zp_get_user_zombie(id))
		{
			// Turn zombies into Nemesis
			zp_make_user_nemesis(id)
			
			// Apply nemesis health multiplier
			set_pev(id, pev_health, float(pev(id, pev_health))*get_pcvar_float(cvar_plaguenemhpmulti))
		}
		else
		{
			// Turn humans into Survivors
			zp_make_user_survivor(id)
			
			// Apply survivor health multiplier
			set_pev(id, pev_health, float(pev(id, pev_health))*get_pcvar_float(cvar_plaguesurvhpmulti))
		}
	}
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1046\\ f0\\ fs16 \n\\ par }
*/
