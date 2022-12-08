#include <amxmodx>
#include <cstrike>
#include <zombieplague>

#define PLUGIN "[Play4Ever] Zombie Atrasado"
#define VERSION "1.0"
#define AUTHOR "Satelite"

new g_TeamJoin[ 33 ];

public plugin_init() {
	register_plugin( PLUGIN, VERSION, AUTHOR );
		
	register_event("TeamInfo","fwPlayerJoinedTeam","a","2=TERRORIST","2=CT")
}

public fwPlayerJoinedTeam()
{
	static id
	id = read_data(1)
	if(!check()) return
	
	if( g_TeamJoin[id] )
	{
		set_task(3.0, "respawn_player", id)
	}
}
bool:check()
{
	
	if( !zp_has_round_started() ) return false
	if( zp_is_nemesis_round() || zp_is_survivor_round() || zp_is_plague_round() || zp_get_human_count() == 1) return false
	
	return true
}
public respawn_player(id)
{
	if( !is_user_connected(id) ) return
	
	if(!check()) return
	
	if( g_TeamJoin[id] )
	{
		client_print(id, print_chat, "[ZM] Voce foi revivido como zombie por entrar atrasado!")
		zp_respawn_user(id, ZP_TEAM_ZOMBIE)
		g_TeamJoin[id] = false
	}
}

public client_putinserver(id)
{
	g_TeamJoin[id] = true
}

public client_disconnect(id)
{
	g_TeamJoin[id] = false
}
