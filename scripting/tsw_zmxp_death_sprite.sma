#include <amxmodx>

// Plugin Version
new const VERSION[] = "1.2a"

// Customization(You do not need to add "sprites/")
new const DEATH_SPRITE[] = "csp_93skull1"

// Player bools
new bool:g_bConnected[33]

// Sprite
new DeathSprite

public plugin_init()
{
	register_plugin("[ZMXP] Death Sprite", VERSION, "eXcalibur.007")
	
	// Death Message event
	register_event("DeathMsg", "event_DeathMsg", "a")
}

public plugin_precache()
{
	// Format the directory so we do not need to add "sprites/"
	new buffer[100]
	formatex(buffer, 99, "sprites/%s.spr", DEATH_SPRITE)
	
	// Precache the model
	DeathSprite = precache_model(buffer)
}

public client_putinserver(id)
{
	g_bConnected[id] = true
}

public client_disconnect(id)
{
	g_bConnected[id] = false
}

public event_DeathMsg()
{
	// Victim's index
	static victim; victim = read_data(2)
	
	// Valid victim
	if(victim)
	{
		set_task(1.0, "show_sprite", victim)
	}
}

public show_sprite(id)
{
	if(g_bConnected[id])
	{
		// Get user's origin
		static origin[3]
		get_user_origin(id, origin)
		
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(TE_SPRITE)
		write_coord(origin[0])
		write_coord(origin[1])
		write_coord(origin[2])
		write_short(DeathSprite)
		write_byte(15)
		write_byte(255)
		message_end()
	}
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
