#include < amxmodx >
#include < fakemeta >
#include < xs >
#include < zombieplague >

#include < play_global >
#include < play_zombiexp >

#define PLUGIN "[ZMXP] Stamina"
#define VERSION "1.1"

new const g_sound_breathe[] = "player/breathe1.wav"

new g_runningcounter[33], g_breathing[33], g_stamina[33]
new cvar_duration, cvar_survivor, cvar_deplete, cvar_regain_walking, cvar_regain_standing

public plugin_precache(){
	precache_sound( g_sound_breathe );
}

public plugin_init(){
	register_plugin( PLUGIN, VERSION, AUTHOR );
	
	register_forward(FM_StartFrame, "fw_StartFrame")
	
	register_event("HLTV", "event_round_start", "a", "1=0", "2=0")
	register_event("DeathMsg", "event_deathmsg", "a")
	
	cvar_duration = register_cvar("zp_stamina_duration", "700")
	cvar_survivor = register_cvar("zp_stamina_survivor", "0")
	
	cvar_deplete = register_cvar("zp_stamina_deplete", "3")
	cvar_regain_walking = register_cvar("zp_stamina_regain_walking", "1")
	cvar_regain_standing = register_cvar("zp_stamina_regain_standing", "2")
}

public plugin_natives(){
	register_library("play_stamina");
	register_native("zp_get_user_stamina", "_get_user_stamina")
}

public _get_user_stamina(id, params)
{
	new Float:staminapct = float(g_stamina[get_param(1)] - g_runningcounter[get_param(1)]) // Quanto de Stamina o jogador tem
	new porcento = floatround((staminapct / g_stamina[get_param(1)]) * 100) // Pegar a porcentagem
	
	return porcento
}

// Had to use FM_StartFrame for accurate checks
// since PreThink depends on the client's FPS
public fw_StartFrame()
{
	// We don't wannna check too fast, but fast enough...
	static Float:lastcheck
	if (get_gametime() - lastcheck < 0.1)
		return;
	lastcheck = get_gametime()
	
	// Loop through players
	static id
	for (id = 1; id <= 32; id++)
	{
		// Not alive or zombie
		if (!is_user_alive(id) || zp_get_user_zombie(id))
			continue;
		
		// Survivor cvar disabled
		if (!get_pcvar_num(cvar_survivor) && zp_get_user_survivor(id))
			continue;
		
		// Not on ground
		if (!(pev(id, pev_flags) & FL_ONGROUND))
			continue;
		
		// Get our current velocity
		static Float:velocity[3]
		pev(id, pev_velocity, velocity)		
		
		// Max running time exceeded?
		if (g_runningcounter[id] > g_stamina[id])
		{
			// Decrease speed gradually
			xs_vec_mul_scalar(velocity, (10-(g_runningcounter[id]-g_stamina[id]))*0.1, velocity)
			set_pev(id, pev_velocity, velocity)
		}
		
		// Start playing breathing sounds when we are close to getting tired
		if (g_runningcounter[id] > g_stamina[id]*0.75)
		{
			if (!g_breathing[id])
			{
				engfunc(EngFunc_EmitSound, id, CHAN_AUTO, g_sound_breathe, 1.0, ATTN_NORM, 0, PITCH_NORM)
				g_breathing[id] = true
			}
		}
		// If not, stop breathing sounds
		else if (g_breathing[id])
		{
			engfunc(EngFunc_EmitSound, id, CHAN_AUTO, g_sound_breathe, 1.0, ATTN_NORM, SND_STOP, PITCH_NORM)
			g_breathing[id] = false
		}
		
		// Get current speed
		static speed
		speed = floatround(vector_length(velocity))
		
		// Running
		if (speed > pev(id, pev_maxspeed)*0.6)
		{			
			// Increase distance counter
			g_runningcounter[id] = min(g_runningcounter[id]+get_pcvar_num(cvar_deplete), g_stamina[id]+10)			
		}
		// Walking
		else if (speed > pev(id, pev_maxspeed)*0.1)
		{
			// Decrease distance counter
			g_runningcounter[id] = max(0, g_runningcounter[id]-get_pcvar_num(cvar_regain_walking))
		}
		// Standing still
		else
		{
			// Decrease distance counter
			g_runningcounter[id] = max(0, g_runningcounter[id]-get_pcvar_num(cvar_regain_standing))
		}
	}
}

// Reset counters on new round
public event_round_start()
{
	for (new i = 1; i <= 32; i++)
	{
		g_runningcounter[i] = 0
		GetStaminaLevel(i)
	}
}

public GetStaminaLevel(id)
{
	switch(zmxp_get_user_stamina(id))
	{
		case 1: g_stamina[id] = (get_pcvar_num(cvar_duration) + 200)
		case 2: g_stamina[id] = (get_pcvar_num(cvar_duration) + 400)
		case 3: g_stamina[id] = (get_pcvar_num(cvar_duration) + 600)
		case 4: g_stamina[id] = (get_pcvar_num(cvar_duration) + 800)
		case 5: g_stamina[id] = (get_pcvar_num(cvar_duration) + 1000)
		default: g_stamina[id] = get_pcvar_num(cvar_duration)
	}
}

// Stop breathing sounds and reset counter when killed
public event_deathmsg()
{
	new victim = read_data(2)
	
	if(g_breathing[victim])
	{
		engfunc(EngFunc_EmitSound, victim, CHAN_AUTO, g_sound_breathe, 1.0, ATTN_NORM, SND_STOP, PITCH_NORM)
		g_breathing[victim] = false
	}
	g_runningcounter[victim] = 0
}

// Stop breathing sounds and reset counter when infected
public zp_user_infected_post(id, infector)
{
	if(g_breathing[id])
	{
		engfunc(EngFunc_EmitSound, id, CHAN_AUTO, g_sound_breathe, 1.0, ATTN_NORM, SND_STOP, PITCH_NORM)
		g_breathing[id] = false
	}
	g_runningcounter[id] = 0
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1046\\ f0\\ fs16 \n\\ par }
*/
