#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <zombieplague>

#define PLUGIN "[ZMXP] zClass Jumper"
#define VERSION "1.0"
#define AUTHOR "CS DarK"

#define MAX_PLAYERS 32

#define XTRA_OFS_PLAYER 5
#define m_iTeam 114
#define m_afButtonPressed 246
#define m_flFallVelocity 251
  
new const zclass_name[] = "Zombie Jumper"
new const zclass_info[] = "[ MultiJump ]"
new const zclass_model[] = "zombie_source"
new const zclass_clawmodel[] = "v_knife_zombie3.mdl"
const zclass_health = 1500
const zclass_speed = 245
const Float:zclass_gravity = 0.7 // 0.7
const Float:zclass_knockback = 1.3
new gJumper
new g_iJumpCount[MAX_PLAYERS+1]
new g_pCvarMultiJumps,g_pCvarMaxFallVelocity, g_pCvarJumpVelocity
  
public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	gJumper = zp_register_zombie_class(zclass_name, zclass_info, zclass_model, zclass_clawmodel, zclass_health, zclass_speed, zclass_gravity, zclass_knockback)
	 
	g_pCvarMultiJumps = register_cvar("mp_multijumps", "1")
	g_pCvarMaxFallVelocity = register_cvar("mp_multijump_maxfallvelocity", "500")
	g_pCvarJumpVelocity = register_cvar("mp_multijumps_jumpvelocity", "268.328157")
	
	RegisterHam(Ham_Player_Jump, "player", "Ham__CbasePlayer_Jump__Pre")
}

public zp_user_infected_post(id, infector)
{
	if ((zp_get_user_zombie_class(id) == gJumper) && !zp_get_user_nemesis(id))
	{
		client_print(id, print_chat, "[ZP] Voce pode pular duas vezes no ar com esse zombie!")
	}
}

public Ham__CbasePlayer_Jump__Pre(id)
{
	if( zp_get_user_zombie_class(id) != gJumper || !is_user_alive(id) || get_pdata_int(id, m_iTeam, XTRA_OFS_PLAYER) != 1 || zp_get_user_nemesis(id) )
	{
		return HAM_IGNORED
	}
	
	new fFlags = pev(id, pev_flags)
	if(	fFlags & FL_WATERJUMP
	||	pev(id, pev_waterlevel) >= 2
	||	!(get_pdata_int(id, m_afButtonPressed, XTRA_OFS_PLAYER) & IN_JUMP)	)
	{
		return HAM_IGNORED
	}

	if(	fFlags & FL_ONGROUND	)
	{
		g_iJumpCount[id] = 0
		return HAM_IGNORED
	}

	new iMulti = get_pcvar_num(g_pCvarMultiJumps)

	if( iMulti )
	{

		if(	get_pdata_float(id, m_flFallVelocity, XTRA_OFS_PLAYER) < get_pcvar_float(g_pCvarMaxFallVelocity)
		&&	++g_iJumpCount[id] <= iMulti	)
		{
			new Float:fVelocity[3]
			pev(id, pev_velocity, fVelocity)
			fVelocity[2] = get_pcvar_float(g_pCvarJumpVelocity)
			set_pev(id, pev_velocity, fVelocity)
			return HAM_HANDLED
		}
	}

	return HAM_IGNORED
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1046\\ f0\\ fs16 \n\\ par }
*/
