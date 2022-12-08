#include <amxmodx>
#include <zombieplague>

new g_itemid_infammo

public plugin_init()
{
	register_plugin("[ZMXP] Municao Infinita", "1.0", "anark")
	
	g_itemid_infammo = zp_register_extra_item("Municao Infinita (1 round)", 40, ZP_TEAM_HUMAN)	
}

public zp_extra_item_selected(player, itemid)
{
	if (itemid == g_itemid_infammo)
		zp_set_user_unlimited_clip(player, true)
}