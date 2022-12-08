#include < amxmodx >
#include < zombieplague >
#include < play_global >

#define PLUGIN "[ZMXP] Ultimate Sounds"
#define VERSION "1.7"
#define LEVELS 5

new gmsgHudSync, Float:g_last_kill[ MAX_PLAYERS+1 ], kills[ MAX_PLAYERS+1 ], levels[ LEVELS ] = {3, 5, 7, 9, 12}

new stksounds[ LEVELS ][] = {
	"misc/female/f_multikill",
	"misc/female/f_killingspree",
	"misc/female/f_megakill",
	"misc/female/f_ultrakill",
	"misc/female/f_rampage"
};

new stkmessages[ LEVELS ][] = {
	"%s: Multi-Kill!",
	"%s: Killing Spree!",
	"%s: Mega-Kill!",
	"%s: Ultra-Kill!",
	"%s: Rampage!"
}

public plugin_init(){
	register_plugin( PLUGIN, VERSION, AUTHOR );
	
	register_event("DeathMsg", "death_event", "a", "1>0")
	
	gmsgHudSync = CreateHudSyncObj()
}

public death_event( id ){
	new killer = read_data(1)
	new victim = read_data(2)
	
	kills[killer]++
	kills[victim] = 0
	
	static Float:current_time
	current_time = get_gametime()
	
	// DOUBLE KILL
	if( 1.8 > current_time - g_last_kill[id] ){
		announce(killer, 0, 1)
		return PLUGIN_CONTINUE
	}
	
	g_last_kill[id] = get_gametime()
	
	if( kills[ killer ] > 12 && kills[ killer ] %2 == 0 ){
		announce( killer, 0, 3);
		return PLUGIN_CONTINUE;
	}
	
	for( new i = 0; i < LEVELS; i++ ){
        if( kills[ killer ] == levels[ i ]){
			announce( killer, i, 0);
			return PLUGIN_CONTINUE;
		}
	}
	
	return PLUGIN_CONTINUE
}

public zp_user_infected_pre( id, infector, nemesis ){
	kills[id] = 0
}

announce(killer, level, doublekill){
	static name[32]
	get_user_name(killer, name, 31)
	
	if(doublekill == 0){
		set_hudmessage(random(255), random(255), random(255), 0.05, 0.65, 2, 0.02, 6.0, 0.01, 0.1, 2)
		ShowSyncHudMsg(0, gmsgHudSync, stkmessages[level], name)

		for(new i=1;i<=get_maxplayers();i++) 
			if(is_user_connected(i) ==1 )
				client_cmd(i, "spk %s", stksounds[level])
	}
	
	else if(doublekill == 1){
		set_hudmessage(random(255), random(255), random(255), 0.05, 0.65, 2, 0.02, 6.0, 0.01, 0.1, 2)
		ShowSyncHudMsg(0, gmsgHudSync, "%s: Double Kill!", name)
		
		for(new i=1;i<=get_maxplayers();i++) 
			if(is_user_connected(i) ==1 )
				client_cmd(i, "spk misc/female/f_doublekill")
	}
	
	else{
		set_hudmessage(random(255), random(255), random(255), 0.05, 0.65, 2, 0.02, 6.0, 0.01, 0.1, 2)
		ShowSyncHudMsg(0, gmsgHudSync, "%s esta Dominando!", name)
		
		for(new i=1;i<=get_maxplayers();i++) 
		if(is_user_connected(i) ==1 )
		client_cmd(i, "spk misc/female/f_dominating")
	}
}

public client_putinserver(id)
{
	kills[id] = 0
}

public plugin_precache()
{
	precache_sound("misc/female/f_monsterkill.wav")
	precache_sound("misc/female/f_doublekill.wav")
	precache_sound("misc/female/f_killingspree.wav")
	precache_sound("misc/female/f_multikill.wav")
	precache_sound("misc/female/f_ultrakill.wav")
	precache_sound("misc/female/f_rampage.wav")
	precache_sound("misc/female/f_dominating.wav")
	return PLUGIN_CONTINUE 
}