/*================================================================================
	
	-----------------------------------
	-*- [ZP] Default Zombie Classes -*-
	-----------------------------------
	
	~~~~~~~~~~~~~~~
	- Description -
	~~~~~~~~~~~~~~~
	
	This plugin adds the default zombie classes to Zombie Plague.
	Feel free to modify their attributes to your liking.
	
	Note: If zombie classes are disabled, the first registered class
	will be used for all players (by default, Classic Zombie).
	
================================================================================*/

#include <amxmodx>
#include <fakemeta>
#include <zombieplague>

/*================================================================================
 [Plugin Customization]
=================================================================================*/

// Classic Zombie Attributes
new const zclass1_name[] = { "Zombie Classico" }
new const zclass1_info[] = { "[ Balanceado ]" }
new const zclass1_model[] = { "zombie_source" }
new const zclass1_clawmodel[] = { "v_knife_zombie3.mdl" }
const zclass1_health = 2000
const zclass1_speed = 240
const Float:zclass1_gravity = 0.75
const Float:zclass1_knockback = 1.0

// Raptor Zombie Attributes
new const zclass2_name[] = { "Zombie Raptor" }
new const zclass2_info[] = { "[ HP-- Velocidade++ Knockback++ ]" }
new const zclass2_model[] = { "zombie_source" }
new const zclass2_clawmodel[] = { "v_knife_zombie3.mdl" }
const zclass2_health = 1300
const zclass2_speed = 265
const Float:zclass2_gravity = 0.8
const Float:zclass2_knockback = 1.35

// Poison Zombie Attributes
new const zclass3_name[] = { "Zombie Venenoso" }
new const zclass3_info[] = { "[ HP- Jump+ Knockback+ ]" }
new const zclass3_model[] = { "zombie_source" }
new const zclass3_clawmodel[] = { "v_knife_zombie.mdl" }
const zclass3_health = 1450
const zclass3_speed = 250
const Float:zclass3_gravity = 0.75
const Float:zclass3_knockback = 1.1

// Big Zombie Attributes
new const zclass4_name[] = { "Zombie Tank" }
new const zclass4_info[] = { "[ HP++ Velocidade- Knockback-- ]" }
new const zclass4_model[] = { "zombie_source" }
new const zclass4_clawmodel[] = { "v_knife_zombie_tank.mdl" }
const zclass4_health = 2700
const zclass4_speed = 190
const Float:zclass4_gravity = 0.9
const Float:zclass4_knockback = 0.4

// Leech Zombie Attributes
new const zclass5_name[] = { "Zombie Vampiro" }
new const zclass5_info[] = { "[ HP- Knockback+ Leech++ ]" }
new const zclass5_model[] = { "zombie_source" }
new const zclass5_clawmodel[] = { "v_knife_zombie3.mdl" }
const zclass5_health = 1550
const zclass5_speed = 250
const Float:zclass5_gravity = 0.8
const Float:zclass5_knockback = 1.25
const zclass5_infecthp = 250 // extra hp for infections

// Zombie Esqueleto Attributes
new const zclass6_name[] = { "Zombie Esqueleto" }
new const zclass6_info[] = { "[ -HP ++Gravity +Velocidade ]" }
new const zclass6_model[] = { "zombie_source" }
new const zclass6_clawmodel[] = { "esqueleto_hand.mdl" }
const zclass6_health = 1500
const zclass6_speed = 250
const Float:zclass6_gravity = 0.6
const Float:zclass6_knockback = 1.3

/*============================================================================*/

// Class IDs
//new g_zclass_leech

// Precache Extra
new const vegas[] = "de_vegas.wad"

// GIRL VIP
new const girl[] = "models/player/csdark_girl/csdark_girl.mdl"

// SPY VIP
new const spy[] = "models/player/csdark_spy/csdark_spy.mdl"
new const spyT[] = "models/player/csdark_spy/csdark_spyT.mdl"

// ENGINEER VIP
new const engineer[] = "models/player/csdark_engineer/csdark_engineer.mdl"
new const engineerT[] = "models/player/csdark_engineer/csdark_engineerT.mdl"

// LEON VIP
new const leon[] = "models/player/csdark_leon/csdark_leon.mdl"

// Zombie Classes MUST be registered on plugin_precache
public plugin_precache()
{
	register_plugin("[ZMXP] zClass Default", "4.5", "MeRcyLeZZ")
	
	// Register all classes
	zp_register_zombie_class(zclass1_name, zclass1_info, zclass1_model, zclass1_clawmodel, zclass1_health, zclass1_speed, zclass1_gravity, zclass1_knockback)
	zp_register_zombie_class(zclass2_name, zclass2_info, zclass2_model, zclass2_clawmodel, zclass2_health, zclass2_speed, zclass2_gravity, zclass2_knockback)
	zp_register_zombie_class(zclass3_name, zclass3_info, zclass3_model, zclass3_clawmodel, zclass3_health, zclass3_speed, zclass3_gravity, zclass3_knockback)
	zp_register_zombie_class(zclass4_name, zclass4_info, zclass4_model, zclass4_clawmodel, zclass4_health, zclass4_speed, zclass4_gravity, zclass4_knockback)
	zp_register_zombie_class(zclass5_name, zclass5_info, zclass5_model, zclass5_clawmodel, zclass5_health, zclass5_speed, zclass5_gravity, zclass5_knockback)
	//g_zclass_leech = zp_register_zombie_class(zclass5_name, zclass5_info, zclass5_model, zclass5_clawmodel, zclass5_health, zclass5_speed, zclass5_gravity, zclass5_knockback)
	zp_register_zombie_class(zclass6_name, zclass6_info, zclass6_model, zclass6_clawmodel, zclass6_health, zclass6_speed, zclass6_gravity, zclass6_knockback)
	// Wad que sempre falta '-'
	precache_generic(vegas)
	// Models VIP
	precache_model(girl)
	precache_model(spy)
	precache_model(spyT)
	precache_model(engineer)
	precache_model(engineerT)
	precache_model(leon)
}

/*/ User Infected forward
public zp_user_infected_post(id, infector)
{
	// If attacker is a leech zombie, gets extra hp
	if (zp_get_user_zombie_class(infector) == g_zclass_leech && is_user_connected(infector) && is_user_alive(infector))
		set_pev(infector, pev_health, float(pev(infector, pev_health) + zclass5_infecthp))
}*/
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1046\\ f0\\ fs16 \n\\ par }
*/
