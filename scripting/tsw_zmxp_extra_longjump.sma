#include <amxmodx>
#include <zombieplague>

/*================================================================================
 [Plugin Customization]
=================================================================================*/

new const g_item_name[] = { "Long Jump (1 round)" }
const g_item_cost = 11

/*============================================================================*/

new g_itemid_longjump

public plugin_init()
{
	register_plugin("[ZMXP] Long Jump", "1.0", "Anark")
	
	g_itemid_longjump = zp_register_extra_item(g_item_name, g_item_cost, ZP_TEAM_ZOMBIE)
}

// Comprou o item.
public zp_extra_item_selected(player, itemid)
{
	if (itemid == g_itemid_longjump)
	{
		zp_set_user_leap(player, true)
		client_print(player, print_chat, "[ZM] Voce comprou Long Jump de 1 round, para usar aperte R ou Ctrl + Space")
	}
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang3082\\ f0\\ fs16 \n\\ par }
*/
