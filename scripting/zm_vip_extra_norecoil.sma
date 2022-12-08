#include <amxmodx>
#include <zombieplague>
#include <zmvip>
#include <hamsandwich>
#include <fakemeta>

#define NO_RECOIL_WEAPONS_BITSUM ((1<<CSW_KNIFE)|(1<<CSW_HEGRENADE)|(1<<CSW_FLASHBANG)|(1<<CSW_SMOKEGRENADE)|(1<<CSW_C4))

#define XO_WEAPON 4
#define m_pPlayer 41

//I don't like this bitwise use as it makes it harder for new people to read
//but since speed is imprortant to this plugin I won't change it. - vittuj
new gAgentZero
new MagicRecoil
#define SetAgentZero(%1)	gAgentZero |= 1<<(%1&31)
#define RemoveAgentZero(%1)	gAgentZero &= ~(1<<(%1&31))
#define GetAgentZero(%1)	(gAgentZero & 1<<(%1&31))
//----------------------------------------------------------------------------------------------
public plugin_init()
{
	// Plugin Info
	register_plugin("[ZMXP] VIP: No Recoil", "1.2", "Freecode")
	
	MagicRecoil = zv_register_extra_item("Precisao Maxima (1 round)", "No Recoil", 28, ZV_TEAM_HUMAN)

	new wpnName[32]
	for ( new wpnId = CSW_P228; wpnId <= CSW_P90; wpnId++ )
	{
		if ( !(NO_RECOIL_WEAPONS_BITSUM & (1<<wpnId)) && get_weaponname(wpnId, wpnName, charsmax(wpnName)) )
		{
			RegisterHam(Ham_Weapon_PrimaryAttack, wpnName, "Ham_Weapon_PrimaryAttack_Post", 1)
		}
	}
	
	RegisterHam(Ham_Spawn, "player", "fw_Spawn3", 1)
}
//----------------------------------------------------------------------------------------------
public zv_extra_item_selected(player, itemid)
{
	if(itemid == MagicRecoil)
	{
		if(GetAgentZero(player))
		{
			client_print(player, print_center, "Voce ja comprou No-Recoil!")
			return ZV_PLUGIN_HANDLED
		}
		else
		{
			SetAgentZero(player)
			client_print(player, print_chat, "[ZP] Voce tem No Recoil ate acabar o round ou morrer!")
		}
	}
	
	return 1;
}
//----------------------------------------------------------------------------------------------
public Ham_Weapon_PrimaryAttack_Post(weapon_ent)
{
	new owner = get_pdata_cbase(weapon_ent, m_pPlayer, XO_WEAPON)

	if ( GetAgentZero(owner) ) {
		set_pev(owner, pev_punchangle, {0.0, 0.0, 0.0})
	}

	return HAM_IGNORED
}
//----------------------------------------------------------------------------------------------
public fw_Spawn3(id)
{
	RemoveAgentZero(id)
}
//----------------------------------------------------------------------------------------------
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1046\\ f0\\ fs16 \n\\ par }
*/
