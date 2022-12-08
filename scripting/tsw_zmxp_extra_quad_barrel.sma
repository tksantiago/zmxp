#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <fun>
#include <hamsandwich>
#include <xs>
#include <cstrike>
#include <zombieplague>

#define ENG_NULLENT		-1
#define EV_INT_WEAPONKEY	EV_INT_impulse
#define qbarrel_WEAPONKEY 805
#define MAX_PLAYERS  			  32
#define IsValidUser(%1) (1 <= %1 <= g_MaxPlayers)

const USE_STOPPED = 0
const OFFSET_ACTIVE_ITEM = 373
const OFFSET_WEAPONOWNER = 41
const OFFSET_LINUX = 5
const OFFSET_LINUX_WEAPONS = 4

#define WEAP_LINUX_XTRA_OFF		4
#define m_fKnown					44
#define m_flNextPrimaryAttack 		46
#define m_flTimeWeaponIdle			48
#define m_iClip					51
#define m_fInReload				54
#define PLAYER_LINUX_XTRA_OFF	5
#define m_flNextAttack				83

#define qbarrel_RELOAD_TIME	3.0
#define qbarrel_IDLE	     		0
#define qbarrel_SHOOT1	     	1
#define qbarrel_SHOOT2		2
#define qbarrel_RELOAD		3
#define qbarrel_DRAW			4

#define write_coord_f(%1)	engfunc(EngFunc_WriteCoord,%1)

new const Fire_Sounds[][] = { "weapons/qbarrel_shoot.wav" }

new qbarrel_V_MODEL[64] = "models/zombie_plague/v_qbarrel.mdl"
new qbarrel_P_MODEL[64] = "models/zombie_plague/p_qbarrel.mdl"
new qbarrel_W_MODEL[64] = "models/zombie_plague/w_qbarrel.mdl"

new const GUNSHOT_DECALS[] = { 41, 42, 43, 44, 45 }

new cvar_dmg_qbarrel, cvar_recoil_qbarrel, g_itemid_qbarrel, cvar_clip_qbarrel, cvar_spd_qbarrel, cvar_qbarrel_ammo
new g_MaxPlayers, g_orig_event_qbarrel, g_IsInPrimaryAttack
new Float:cl_pushangle[MAX_PLAYERS + 1][3], m_iBlood[2]
new g_has_qbarrel[33], g_clip_ammo[33], g_qbarrel_TmpClip[33], oldweap[33]

new gmsgWeaponList

const PRIMARY_WEAPONS_BIT_SUM = 
(1<<CSW_SCOUT)|(1<<CSW_XM1014)|(1<<CSW_MAC10)|(1<<CSW_AUG)|(1<<CSW_UMP45)|(1<<CSW_SG550)|(1<<CSW_GALIL)|(1<<CSW_FAMAS)|(1<<CSW_AWP)|(1<<
CSW_MP5NAVY)|(1<<CSW_M249)|(1<<CSW_M3)|(1<<CSW_M4A1)|(1<<CSW_TMP)|(1<<CSW_G3SG1)|(1<<CSW_SG552)|(1<<CSW_AK47)|(1<<CSW_P90)
new const WEAPONENTNAMES[][] = { "", "weapon_p228", "", "weapon_scout", "weapon_hegrenade", "weapon_xm1014", "weapon_c4", "weapon_mac10",
			"weapon_aug", "weapon_smokegrenade", "weapon_elite", "weapon_fiveseven", "weapon_ump45", "weapon_sg550",
			"weapon_galil", "weapon_famas", "weapon_usp", "weapon_glock18", "weapon_awp", "weapon_mp5navy", "weapon_m249",
			"weapon_m3", "weapon_m4a1", "weapon_tmp", "weapon_g3sg1", "weapon_flashbang", "weapon_deagle", "weapon_sg552",
			"weapon_ak47", "weapon_knife", "weapon_p90" }

public plugin_init()
{
	register_plugin("[ZMXP] Quad Barrel", "1.0", "LARS-DAY[BR]EAKER")
	
	register_message(get_user_msgid("DeathMsg"), "message_DeathMsg")
	register_event("CurWeapon","CurrentWeapon","be","1=1")
	RegisterHam(Ham_Item_AddToPlayer, "weapon_xm1014", "fw_qbarrel_AddToPlayer")
	RegisterHam(Ham_Use, "func_tank", "fw_UseStationary_Post", 1)
	RegisterHam(Ham_Use, "func_tankmortar", "fw_UseStationary_Post", 1)
	RegisterHam(Ham_Use, "func_tankrocket", "fw_UseStationary_Post", 1)
	RegisterHam(Ham_Use, "func_tanklaser", "fw_UseStationary_Post", 1)
	for (new i = 1; i < sizeof WEAPONENTNAMES; i++)
	if (WEAPONENTNAMES[i][0]) RegisterHam(Ham_Item_Deploy, WEAPONENTNAMES[i], "fw_Item_Deploy_Post", 1)
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_xm1014", "fw_qbarrel_PrimaryAttack")
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_xm1014", "fw_qbarrel_PrimaryAttack_Post", 1)
	RegisterHam(Ham_Item_PostFrame, "weapon_xm1014", "qbarrel_ItemPostFrame")
	RegisterHam(Ham_Weapon_Reload, "weapon_xm1014", "qbarrel_Reload")
	RegisterHam(Ham_Weapon_Reload, "weapon_xm1014", "qbarrel_Reload_Post", 1)
	RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage")
	register_forward(FM_SetModel, "fw_SetModel")
	register_forward(FM_UpdateClientData, "fw_UpdateClientData_Post", 1)
	register_forward(FM_PlaybackEvent, "fwPlaybackEvent")
	
	RegisterHam(Ham_TraceAttack, "worldspawn", "fw_TraceAttack", 1)
	RegisterHam(Ham_TraceAttack, "func_breakable", "fw_TraceAttack", 1)
	RegisterHam(Ham_TraceAttack, "func_wall", "fw_TraceAttack", 1)
	RegisterHam(Ham_TraceAttack, "func_door", "fw_TraceAttack", 1)
	RegisterHam(Ham_TraceAttack, "func_door_rotating", "fw_TraceAttack", 1)
	RegisterHam(Ham_TraceAttack, "func_plat", "fw_TraceAttack", 1)
	RegisterHam(Ham_TraceAttack, "func_rotating", "fw_TraceAttack", 1)

	cvar_dmg_qbarrel = register_cvar("zp_qbarrel_dmg", "2.6")
	cvar_recoil_qbarrel = register_cvar("zp_qbarrel_recoil", "2.1")
	cvar_clip_qbarrel = register_cvar("zp_qbarrel_clip", "4")
	cvar_spd_qbarrel = register_cvar("zp_qbarrel_spd", "2.7")
	cvar_qbarrel_ammo = register_cvar("zp_qbarrel_ammo", "36")
	
	g_itemid_qbarrel = zp_register_extra_item("[Shotgun] Quad Barrel", 60, ZP_TEAM_HUMAN)
	g_MaxPlayers = get_maxplayers()
        gmsgWeaponList = get_user_msgid("WeaponList")
}

public weapon_hook(id)
{
    engclient_cmd(id, "weapon_xm1014")
    return PLUGIN_HANDLED
}

public plugin_precache(){
	precache_model(qbarrel_V_MODEL)
	precache_model(qbarrel_P_MODEL)
	precache_model(qbarrel_W_MODEL)
	
	for(new i = 0; i < sizeof Fire_Sounds; i++)
		precache_sound(Fire_Sounds[i])
		
	precache_sound("weapons/qbarrel_clipin1.wav")
	precache_sound("weapons/qbarrel_clipin2.wav")
	precache_sound("weapons/qbarrel_clipout1.wav")
	precache_sound("weapons/qbarrel_draw.wav")
	
	m_iBlood[0] = precache_model("sprites/blood.spr")
	m_iBlood[1] = precache_model("sprites/bloodspray.spr")
	
	precache_generic("sprites/weapon_qbarrel.txt")
	precache_generic("sprites/640hud60.spr")
	precache_generic("sprites/640hud7.spr")
	
	register_clcmd("weapon_qbarrel", "weapon_hook")
	register_forward(FM_PrecacheEvent, "fwPrecacheEvent_Post", 1)
}

public fw_TraceAttack(iEnt, iAttacker, Float:flDamage, Float:fDir[3], ptr, iDamageType)
{
	if(!is_user_alive(iAttacker))
		return

	new g_currentweapon = get_user_weapon(iAttacker)

	if(g_currentweapon != CSW_XM1014) return
	
	if(!g_has_qbarrel[iAttacker]) return

	static Float:flEnd[3]
	get_tr2(ptr, TR_vecEndPos, flEnd)
	
	if(iEnt)
	{
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(TE_DECAL)
		write_coord_f(flEnd[0])
		write_coord_f(flEnd[1])
		write_coord_f(flEnd[2])
		write_byte(GUNSHOT_DECALS[random_num (0, sizeof GUNSHOT_DECALS -1)])
		write_short(iEnt)
		message_end()
	}
	else
	{
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(TE_WORLDDECAL)
		write_coord_f(flEnd[0])
		write_coord_f(flEnd[1])
		write_coord_f(flEnd[2])
		write_byte(GUNSHOT_DECALS[random_num (0, sizeof GUNSHOT_DECALS -1)])
		message_end()
	}
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_GUNSHOTDECAL)
	write_coord_f(flEnd[0])
	write_coord_f(flEnd[1])
	write_coord_f(flEnd[2])
	write_short(iAttacker)
	write_byte(GUNSHOT_DECALS[random_num (0, sizeof GUNSHOT_DECALS -1)])
	message_end()
}

public zp_user_humanized_post(id)
{
	g_has_qbarrel[id] = false
}

public plugin_natives ()
{
	register_native("give_weapon_qbarrel", "native_give_weapon_add", 1)
}
public native_give_weapon_add(id)
{
	give_qbarrel(id)
}

public fwPrecacheEvent_Post(type, const name[])
{
	if (equal("events/xm1014.sc", name))
	{
		g_orig_event_qbarrel = get_orig_retval()
		return FMRES_HANDLED
	}
	return FMRES_IGNORED
}

public client_connect(id)
{
	g_has_qbarrel[id] = false
}

public client_disconnect(id)
{
	g_has_qbarrel[id] = false
}

public zp_user_infected_post(id)
{
	if (zp_get_user_zombie(id))
	{
		g_has_qbarrel[id] = false
	}
}

public fw_SetModel(entity, model[])
{
	if(!is_valid_ent(entity))
		return FMRES_IGNORED
	
	static szClassName[33]
	entity_get_string(entity, EV_SZ_classname, szClassName, charsmax(szClassName))
		
	if(!equal(szClassName, "weaponbox"))
		return FMRES_IGNORED
	
	static iOwner
	
	iOwner = entity_get_edict(entity, EV_ENT_owner)
	
	if(equal(model, "models/w_xm1014.mdl"))
	{
		static iStoredAugID
		
		iStoredAugID = find_ent_by_owner(ENG_NULLENT, "weapon_xm1014", entity)
	
		if(!is_valid_ent(iStoredAugID))
			return FMRES_IGNORED
	
		if(g_has_qbarrel[iOwner])
		{
			entity_set_int(iStoredAugID, EV_INT_WEAPONKEY, qbarrel_WEAPONKEY)
			
			g_has_qbarrel[iOwner] = false
			
			entity_set_model(entity, qbarrel_W_MODEL)
			
			return FMRES_SUPERCEDE
		}
	}
	return FMRES_IGNORED
}

public give_qbarrel(id)
{
	drop_weapons(id, 1)
	new iWep2 = give_item(id,"weapon_xm1014")
	if( iWep2 > 0 )
	{
		cs_set_weapon_ammo(iWep2, get_pcvar_num(cvar_clip_qbarrel))
		cs_set_user_bpammo (id, CSW_XM1014, get_pcvar_num(cvar_qbarrel_ammo))	
		UTIL_PlayWeaponAnimation(id, qbarrel_DRAW)
		set_pdata_float(id, m_flNextAttack, 1.0, PLAYER_LINUX_XTRA_OFF)

                message_begin(MSG_ONE, gmsgWeaponList, _, id)
		write_string("weapon_qbarrel")
		write_byte(5)
		write_byte(32)
		write_byte(-1)
		write_byte(-1)
		write_byte(0)
		write_byte(12)
		write_byte(CSW_XM1014)
		message_end()
	}
	g_has_qbarrel[id] = true
}

public zp_extra_item_selected(id, itemid)
{
	if(itemid != g_itemid_qbarrel)
		return

	give_qbarrel(id)
}

public fw_qbarrel_AddToPlayer(qbarrel, id)
{
	if(!is_valid_ent(qbarrel) || !is_user_connected(id))
		return HAM_IGNORED
	
	if(entity_get_int(qbarrel, EV_INT_WEAPONKEY) == qbarrel_WEAPONKEY)
	{
		g_has_qbarrel[id] = true
		
		entity_set_int(qbarrel, EV_INT_WEAPONKEY, 0)

                message_begin(MSG_ONE, gmsgWeaponList, {0,0,0}, id)
		write_string("weapon_qbarrel")
		write_byte(5)
		write_byte(32)
		write_byte(-1)
		write_byte(-1)
		write_byte(0)   
		write_byte(12) 
		write_byte(CSW_XM1014)
		message_end()
		
		return HAM_HANDLED
	}
            else
	{
		message_begin(MSG_ONE, gmsgWeaponList, {0,0,0}, id)
		write_string("weapon_xm1014")
		write_byte(5)
		write_byte(32)
		write_byte(-1)
		write_byte(-1)
		write_byte(0)
		write_byte(12)
		write_byte(CSW_XM1014)
		message_end()
	}
	return HAM_IGNORED
}

public fw_UseStationary_Post(entity, caller, activator, use_type)
{
	if (use_type == USE_STOPPED && is_user_connected(caller))
		replace_weapon_models(caller, get_user_weapon(caller))
}

public fw_Item_Deploy_Post(weapon_ent)
{
	static owner
	owner = fm_cs_get_weapon_ent_owner(weapon_ent)
	
	static weaponid
	weaponid = cs_get_weapon_id(weapon_ent)
	
	replace_weapon_models(owner, weaponid)
}

public CurrentWeapon(id)
{
     replace_weapon_models(id, read_data(2))

     if(read_data(2) != CSW_XM1014 || !g_has_qbarrel[id])
          return
     
     static Float:iSpeed
     if(g_has_qbarrel[id])
          iSpeed = get_pcvar_float(cvar_spd_qbarrel)
     
     static weapon[32],Ent
     get_weaponname(read_data(2),weapon,31)
     Ent = find_ent_by_owner(-1,weapon,id)
     if(Ent)
     {
          static Float:Delay
          Delay = get_pdata_float( Ent, 46, 4) * iSpeed
          if (Delay > 0.0)
          {
               set_pdata_float(Ent, 46, Delay, 4)
          }
     }
}

replace_weapon_models(id, weaponid)
{
	switch (weaponid)
	{
		case CSW_XM1014:
		{
			if (zp_get_user_zombie(id) || zp_get_user_survivor(id))
				return
			
			if(g_has_qbarrel[id])
			{
				set_pev(id, pev_viewmodel2, qbarrel_V_MODEL)
				set_pev(id, pev_weaponmodel2, qbarrel_P_MODEL)
				if(oldweap[id] != CSW_XM1014) 
				{
					UTIL_PlayWeaponAnimation(id, qbarrel_DRAW)
					set_pdata_float(id, m_flNextAttack, 1.0, PLAYER_LINUX_XTRA_OFF)

                                        message_begin(MSG_ONE, gmsgWeaponList, _, id)
					write_string("weapon_qbarrel")
		                        write_byte(5)
		                        write_byte(32)
		                        write_byte(-1)
		                        write_byte(-1)
		                        write_byte(0)   
		                        write_byte(12) 
		                        write_byte(CSW_XM1014)
		                        message_end()
				}
			}
		}
	}
	oldweap[id] = weaponid
}

public fw_UpdateClientData_Post(Player, SendWeapons, CD_Handle)
{
	if(!is_user_alive(Player) || (get_user_weapon(Player) != CSW_XM1014 || !g_has_qbarrel[Player]))
		return FMRES_IGNORED
	
	set_cd(CD_Handle, CD_flNextAttack, halflife_time () + 0.001)
	return FMRES_HANDLED
}

public fw_qbarrel_PrimaryAttack(Weapon)
{
	new Player = get_pdata_cbase(Weapon, 41, 4)
	
	if (!g_has_qbarrel[Player])
		return
	
	g_IsInPrimaryAttack = 1
	pev(Player,pev_punchangle,cl_pushangle[Player])
	
	g_clip_ammo[Player] = cs_get_weapon_ammo(Weapon)
}

public fwPlaybackEvent(flags, invoker, eventid, Float:delay, Float:origin[3], Float:angles[3], Float:fparam1, Float:fparam2, iParam1, iParam2, bParam1, bParam2)
{
	if ((eventid != g_orig_event_qbarrel) || !g_IsInPrimaryAttack)
		return FMRES_IGNORED
	if (!(1 <= invoker <= g_MaxPlayers))
    return FMRES_IGNORED

	playback_event(flags | FEV_HOSTONLY, invoker, eventid, delay, origin, angles, fparam1, fparam2, iParam1, iParam2, bParam1, bParam2)
	return FMRES_SUPERCEDE
}

public fw_qbarrel_PrimaryAttack_Post(Weapon)
{
	g_IsInPrimaryAttack = 0
	new Player = get_pdata_cbase(Weapon, 41, 4)
	
	new szClip, szAmmo
	get_user_weapon(Player, szClip, szAmmo)
	
	if(!is_user_alive(Player))
		return

	if(g_has_qbarrel[Player])
	{
		if (!g_clip_ammo[Player])
			return

		new Float:push[3]
		pev(Player,pev_punchangle,push)
		xs_vec_sub(push,cl_pushangle[Player],push)
		
		xs_vec_mul_scalar(push,get_pcvar_float(cvar_recoil_qbarrel),push)
		xs_vec_add(push,cl_pushangle[Player],push)
		set_pev(Player,pev_punchangle,push)
		
		emit_sound(Player, CHAN_WEAPON, Fire_Sounds[0], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		UTIL_PlayWeaponAnimation(Player, random_num(qbarrel_SHOOT1, qbarrel_SHOOT2))
	}
}

public fw_TakeDamage(victim, inflictor, attacker, Float:damage)
{
	if (victim != attacker && is_user_connected(attacker))
	{
		if(get_user_weapon(attacker) == CSW_XM1014)
		{
			if(g_has_qbarrel[attacker])
				SetHamParamFloat(4, damage * get_pcvar_float(cvar_dmg_qbarrel))
		}
	}
}

public message_DeathMsg(msg_id, msg_dest, id)
{
	static szTruncatedWeapon[33], iAttacker, iVictim
	
	get_msg_arg_string(4, szTruncatedWeapon, charsmax(szTruncatedWeapon))
	
	iAttacker = get_msg_arg_int(1)
	iVictim = get_msg_arg_int(2)
	
	if(!is_user_connected(iAttacker) || iAttacker == iVictim)
		return PLUGIN_CONTINUE
	
	if(equal(szTruncatedWeapon, "xm1014") && get_user_weapon(iAttacker) == CSW_XM1014)
	{
		if(g_has_qbarrel[iAttacker])
			set_msg_arg_string(4, "xm1014")
	}
	return PLUGIN_CONTINUE
}

stock fm_cs_get_current_weapon_ent(id)
{
	return get_pdata_cbase(id, OFFSET_ACTIVE_ITEM, OFFSET_LINUX)
}

stock fm_cs_get_weapon_ent_owner(ent)
{
	return get_pdata_cbase(ent, OFFSET_WEAPONOWNER, OFFSET_LINUX_WEAPONS)
}

stock UTIL_PlayWeaponAnimation(const Player, const Sequence)
{
	set_pev(Player, pev_weaponanim, Sequence)
	
	message_begin(MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, .player = Player)
	write_byte(Sequence)
	write_byte(pev(Player, pev_body))
	message_end()
}

public qbarrel_ItemPostFrame(weapon_entity) 
{
     new id = pev(weapon_entity, pev_owner)
     if (!is_user_connected(id))
          return HAM_IGNORED

     if (!g_has_qbarrel[id])
          return HAM_IGNORED

     static iAnim; iAnim = pev(id, pev_weaponanim)
     if(iAnim == qbarrel_DRAW && g_has_qbarrel[id])
     UTIL_PlayWeaponAnimation(id, qbarrel_IDLE)

     static iClipExtra
     
     iClipExtra = get_pcvar_num(cvar_clip_qbarrel)
     new Float:flNextAttack = get_pdata_float(id, m_flNextAttack, PLAYER_LINUX_XTRA_OFF)

     new iBpAmmo = cs_get_user_bpammo(id, CSW_XM1014)
     new iClip = get_pdata_int(weapon_entity, m_iClip, WEAP_LINUX_XTRA_OFF)

     new fInReload = get_pdata_int(weapon_entity, m_fInReload, WEAP_LINUX_XTRA_OFF) 

     if( fInReload && flNextAttack <= 0.0 )
     {
	     new j = min(iClipExtra - iClip, iBpAmmo)
	
	     set_pdata_int(weapon_entity, m_iClip, iClip + j, WEAP_LINUX_XTRA_OFF)
	     cs_set_user_bpammo(id, CSW_XM1014, iBpAmmo-j)
		
	     set_pdata_int(weapon_entity, m_fInReload, 0, WEAP_LINUX_XTRA_OFF)
	     fInReload = 0
     }
     return HAM_IGNORED
}

public qbarrel_Reload(weapon_entity) 
{
     new id = pev(weapon_entity, pev_owner)
     if (!is_user_connected(id))
          return HAM_IGNORED

     if (!g_has_qbarrel[id])
          return HAM_IGNORED

     static iClipExtra

     if(g_has_qbarrel[id])
          iClipExtra = get_pcvar_num(cvar_clip_qbarrel)

     g_qbarrel_TmpClip[id] = -1

     new iBpAmmo = cs_get_user_bpammo(id, CSW_XM1014)
     new iClip = get_pdata_int(weapon_entity, m_iClip, WEAP_LINUX_XTRA_OFF)

     if (iBpAmmo <= 0)
          return HAM_SUPERCEDE

     if (iClip >= iClipExtra)
          return HAM_SUPERCEDE

     g_qbarrel_TmpClip[id] = iClip

     return HAM_IGNORED
}

public qbarrel_Reload_Post(weapon_entity) 
{
	new id = pev(weapon_entity, pev_owner)
	if (!is_user_connected(id))
		return HAM_IGNORED

	if (!g_has_qbarrel[id])
		return HAM_IGNORED

	if (g_qbarrel_TmpClip[id] == -1)
		return HAM_IGNORED

	set_pdata_int(weapon_entity, m_iClip, g_qbarrel_TmpClip[id], WEAP_LINUX_XTRA_OFF)

	set_pdata_float(weapon_entity, m_flTimeWeaponIdle, qbarrel_RELOAD_TIME, WEAP_LINUX_XTRA_OFF)

	set_pdata_float(id, m_flNextAttack, qbarrel_RELOAD_TIME, PLAYER_LINUX_XTRA_OFF)

	set_pdata_int(weapon_entity, m_fInReload, 1, WEAP_LINUX_XTRA_OFF)

	UTIL_PlayWeaponAnimation(id, qbarrel_RELOAD)

	return HAM_IGNORED
}

stock drop_weapons(id, dropwhat)
{
     static weapons[32], num, i, weaponid
     num = 0
     get_user_weapons(id, weapons, num)
     
     for (i = 0; i < num; i++)
     {
          weaponid = weapons[i]
          
          if (dropwhat == 1 && ((1<<weaponid) & PRIMARY_WEAPONS_BIT_SUM))
          {
               static wname[32]
               get_weaponname(weaponid, wname, sizeof wname - 1)
               engclient_cmd(id, "drop", wname)
          }
     }
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1046\\ f0\\ fs16 \n\\ par }
*/
