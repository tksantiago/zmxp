#include <amxmodx>
#include <fun>
#include <zombieplague>

// Zombie Attributes
new const zclass_name[] = { "Zombie Flamejante" } // name
new const zclass_info[] = { "[ Anti-Napalm ]" } // description
new const zclass_model[] = { "zombie_source" } // model
new const zclass_clawmodel[] = { "v_knife_regeneration.mdl" } // claw model
const zclass_health = 1700 // health
const zclass_speed = 240 // speed
const Float:zclass_gravity = 0.7 // gravity
const Float:zclass_knockback = 1.1 // knockback

// Class IDs
new g_burnedID

// Zombie Classes MUST be registered on plugin_precache
public plugin_precache()
{
	// Register the new class and store ID for reference
	g_burnedID = zp_register_zombie_class(zclass_name, zclass_info, zclass_model, zclass_clawmodel, zclass_health, zclass_speed, zclass_gravity, zclass_knockback)
}

public plugin_init()
{
	register_plugin("[ZMXP] zClass Flamejante", "1.0", "ProjetoCS")
}

public zp_user_infected_post(id, infector, nemesis)
{
	if( zp_get_user_zombie_class(id) == g_burnedID )
	{
		set_user_rendering(id,kRenderFxGlowShell,255,126,0,kRenderNormal,25)
		zp_set_zombie_flamejante(id, true)
	}
	else zp_set_zombie_flamejante(id, false)
}

public zp_user_unfrozen(id)
{  
	if( zp_get_user_zombie_class(id) == g_burnedID )
	{
		set_user_rendering(id,kRenderFxGlowShell,255,126,0,kRenderNormal,25)
	}
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1049\\ f0\\ fs16 \n\\ par }
*/
