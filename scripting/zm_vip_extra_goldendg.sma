/*
[ZP] Extra Item: Golden Deagle
Team: Humans

Description: This plugin adds a new weapon for Human Teams.
Weapon Cost: 20

Features:
- This weapon do more damage
- This weapon has zoom
- Launch Lasers
- This weapon has unlimited bullets

Credits:

KaOs - For his Dual MP5 mod

Cvars:


- zp_goldendg_dmg_multiplier <3> - Damage Multiplier for Golden Deagle
- zp_goldendg_gold_bullets <1|0> - Golden bullets effect ?
- zp_goldendg_custom_model <1|0> - Golden dg Custom Model
- zp_goldendg_unlimited_clip <1|0> - Golden dg Unlimited Clip 

*/

#include <amxmodx>
#include <fakemeta_util>
#include <fun>
#include <hamsandwich>
#include <cstrike>
#include <zombieplague>
#include <zmvip>

#define is_valid_player(%1) (1 <= %1 <= g_iMaxPlayers)

// CS Offsets
#if cellbits == 32
const OFFSET_CLIPAMMO = 51
#else
const OFFSET_CLIPAMMO = 65
#endif
const OFFSET_LINUX_WEAPONS = 4

// Max Clip for weapons
new const MAXCLIP[] = { -1, 13, -1, 10, 1, 7, -1, 30, 30, 1, 30, 20, 25, 30, 35, 25, 12, 20,
			10, 30, 100, 8, 30, 30, 20, 2, 7, 30, 30, -1, 50 }

new DG_V_MODEL[64] = "models/zombie_plague/v_golden_deagle.mdl"
new DG_P_MODEL[64] = "models/zombie_plague/p_golden_deagle.mdl"

/* Pcvars */
new cvar_dmgmultiplier, cvar_goldbullets,  cvar_custommodel, cvar_uclip

// Item ID
new g_itemid

new bool:g_HasDg[33]

new g_hasZoom[ 33 ]
new bullets[ 33 ]

// Sprite
new m_spriteTexture

const Wep_deagle = ((1<<CSW_DEAGLE))

new g_iMaxPlayers
public plugin_init()
{
	
	/* CVARS */
	cvar_dmgmultiplier = register_cvar("zp_goldendg_dmg_multiplier", "2.0")
	cvar_custommodel = register_cvar("zp_goldendg_custom_model", "1")
	cvar_goldbullets = register_cvar("zp_goldendg_gold_bullets", "1")
	//cvar_uclip = register_cvar("zp_goldendg_unlimited_clip", "1")
	
	// Register The Plugin
	register_plugin("[ZMXP] Extra: Golden Deagle", "1.1", "AlejandroSk")
	// Register Zombie Plague extra item
	g_itemid = zv_register_extra_item("Golden Deagle (1 round)", "Double Damage", 20, ZV_TEAM_HUMAN)
	// Death Msg
	register_event("DeathMsg", "Death", "a")
	// Current Weapon Event
	register_event("CurWeapon", "make_tracer", "be", "1=1", "3>0")
	// Ham TakeDamage
	RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage")
	register_forward( FM_CmdStart, "fw_CmdStart" )
	RegisterHam(Ham_Spawn, "player", "fwHamPlayerSpawnPost", 1)
	
	register_message(get_user_msgid("CurWeapon"), "message_cur_weapon")
	
	g_iMaxPlayers = get_maxplayers()
}

public client_putinserver(id)
{
	g_HasDg[id] = false
}

public client_disconnected(id)
{
	g_HasDg[id] = false
}

public Death()
{
	g_HasDg[read_data(2)] = false
}

public fwHamPlayerSpawnPost(id)
{
	g_HasDg[id] = false
}

public plugin_precache()
{
	precache_model(DG_V_MODEL)
	precache_model(DG_P_MODEL)
	m_spriteTexture = precache_model("sprites/dot.spr")
	precache_sound("weapons/zoom.wav")
}

public zp_user_infected_post(id)
{
	if (zp_get_user_zombie(id))
	{
		g_HasDg[id] = false
	}
}
public message_cur_weapon(msg_id, msg_dest, msg_entity)
{
	if (!g_HasDg[msg_entity])
		return;
	
	// Player not alive or not an active weapon
	if (!is_user_alive(msg_entity) || get_msg_arg_int(1) != 1)
		return;
	
	checkModel(msg_entity)
	
	
	static weapon, clip
	weapon = get_msg_arg_int(2) // get weapon ID
	clip = get_msg_arg_int(3) // get weapon clip
	
	set_msg_arg_int(3, get_msg_argtype(3),  13)
	
	if (clip < 2) // refill when clip is nearly empty
	{
		// Get the weapon entity
		static wname[32], weapon_ent
		get_weaponname(weapon, wname, sizeof wname - 1)
		weapon_ent = fm_find_ent_by_owner(-1, wname, msg_entity)
		
		// Set max clip on weapon
		cs_set_weapon_ammo(weapon_ent, MAXCLIP[weapon])
	}
}
public checkModel(id)
{
	if ( zp_get_user_zombie(id) )
		return PLUGIN_CONTINUE
	
	new szWeapID = read_data(2)
	
	if ( szWeapID == CSW_DEAGLE && g_HasDg[id] == true && get_pcvar_num(cvar_custommodel) )
	{
		set_pev(id, pev_viewmodel2, DG_V_MODEL)
		set_pev(id, pev_weaponmodel2, DG_P_MODEL)
	}
	return PLUGIN_CONTINUE
}

public fw_TakeDamage(victim, inflictor, attacker, Float:damage)
{
	 if( !is_valid_player(attacker) || !g_HasDg[attacker] ) return
	 
	 new weapon = get_user_weapon(attacker)
	 
	 if( weapon == CSW_DEAGLE )
	 {
	 	SetHamParamFloat(4, damage * get_pcvar_float( cvar_dmgmultiplier ) )
	 }
}

public fw_CmdStart( id, uc_handle, seed )
{
	if( !is_user_alive( id ) ) 
		return FMRES_IGNORED;
	
	if( ( get_uc( uc_handle, UC_Buttons ) & IN_ATTACK2 ) && !( pev( id, pev_oldbuttons ) & IN_ATTACK2 ) )
	{
		new szClip, szAmmo
		new szWeapID = get_user_weapon( id, szClip, szAmmo )
		
		if( szWeapID == CSW_DEAGLE && g_HasDg[id] == true && !g_hasZoom[id])
		{
			g_hasZoom[id] = true
			cs_set_user_zoom( id, CS_SET_AUGSG552_ZOOM, 0 )
			emit_sound( id, CHAN_ITEM, "weapons/zoom.wav", 0.20, 2.40, 0, 100 )
		}
		
		else if ( szWeapID == CSW_DEAGLE && g_HasDg[id] == true && g_hasZoom[id])
		{
			g_hasZoom[ id ] = false
			cs_set_user_zoom( id, CS_RESET_ZOOM, 0 )
			
		}
		
	}
	return FMRES_IGNORED;
}


public make_tracer(id)
{
	if (get_pcvar_num(cvar_goldbullets))
	{
		new clip,ammo
		new wpnid = get_user_weapon(id,clip,ammo)
		
		if ((bullets[id] > clip) && (wpnid == CSW_DEAGLE) && g_HasDg[id]) 
		{
			new vec1[3], vec2[3]
			get_user_origin(id, vec1, 1) // origin; your camera point.
			get_user_origin(id, vec2, 4) // termina; where your bullet goes (4 is cs-only)
			
			
			//BEAMENTPOINTS
			message_begin( MSG_BROADCAST,SVC_TEMPENTITY)
			write_byte (0)     //TE_BEAMENTPOINTS 0
			write_coord(vec1[0])
			write_coord(vec1[1])
			write_coord(vec1[2])
			write_coord(vec2[0])
			write_coord(vec2[1])
			write_coord(vec2[2])
			write_short( m_spriteTexture )
			write_byte(1) // framestart
			write_byte(5) // framerate
			write_byte(2) // life
			write_byte(10) // width
			write_byte(0) // noise
			write_byte( 255 )     // r, g, b
			write_byte( 215 )       // r, g, b
			write_byte( 0 )       // r, g, b
			write_byte(200) // brightness
			write_byte(150) // speed
			message_end()
		}
	
		bullets[id] = clip
	}
	
}

public zv_extra_item_selected(player, itemid)
{
	if ( itemid == g_itemid )
	{
		if ( user_has_weapon(player, CSW_DEAGLE) )
		{
			engclient_cmd(player, "drop","weapon_deagle")
		}
		
		give_item(player, "weapon_deagle")
		client_print(player, print_chat, "[ZP] Voce comprou uma Golden Deagle")
		g_HasDg[player] = true;
	}
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang3082\\ f0\\ fs16 \n\\ par }
*/
