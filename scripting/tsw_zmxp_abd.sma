/* Plugin generated by AMXX-Studio */

#include <amxmodx>
#include <amxmisc>

#define PLUGIN "[ZMXP] Bullet Damage"
#define VERSION "1.0"
#define AUTHOR "Satelite"

new g_hudmsg1

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	g_hudmsg1 = CreateHudSyncObj()	
}

public client_damage(attacker, victim, damage)
{
	if ( victim == attacker ) return
	if ( is_user_admin(attacker) ) return // Bullet damage apenas para Non-vips
	if ( !is_user_connected(victim) || !is_user_connected(attacker) ) return
	
	set_hudmessage(0, 100, 200, -1.0, 0.55, 2, 0.1, 4.0, 0.02, 0.02, -1)
	ShowSyncHudMsg(attacker, g_hudmsg1, "%d^n", damage)
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
