#include <amxmodx>
#include <fakemeta>
#include <zombieplague>

#define PLUGIN "[ZMXP] zClass Regeneration"
#define VERSION "1.0.6"
#define AUTHOR "ProjetoCS"

new const zclass_name[] = "Zombie Regeneration"
new const zclass_info[] = "[ HP- Velocidade+ Knockback+ ]"
new const zclass_model[] = "zombie_source"
new const zclass_clawmodel[] = "v_knife_regeneration.mdl"
const zclass_health = 1350
const zclass_speed = 235
const Float:zclass_gravity = 0.9
const Float:zclass_knockback = 1.7

new g_zclass_healing


public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	set_task(2.0, "regen_loop", _, _, _, "b")
}

public plugin_precache()
{
	g_zclass_healing = zp_register_zombie_class(zclass_name, zclass_info, zclass_model, zclass_clawmodel, zclass_health, zclass_speed, zclass_gravity, zclass_knockback)
}

public regen_loop()
{
	static players[32], playerCount, player, i
	get_players(players, playerCount, "ah")

	for ( i = 0; i < playerCount; i++ ) {
		player = players[i]

		if (zp_get_user_zombie_class(player) != g_zclass_healing || zp_get_user_nemesis(player) || !zp_get_user_zombie(player)) return
		
		new health = get_user_health(player)
		
		if (health < zclass_health )
		{
			// Aqui colocamos a life a cada 2 segundos =D
			set_pev(player, pev_health, health + 40.0)
		}
	}
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1046\\ f0\\ fs16 \n\\ par }
*/
