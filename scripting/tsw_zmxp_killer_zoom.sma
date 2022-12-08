#include < amxmodx >
#include < hamsandwich >
#include < play_global >

#define PLUGIN "[PLAY] Killer Effect"
#define VERSION "1.0"

new xMessageFov

public plugin_init(){
	register_plugin( PLUGIN, VERSION, AUTHOR );
	
	RegisterHam(Ham_Killed, "player", "fw_PlayerKilled")
	xMessageFov = get_user_msgid("SetFOV");
}

public fw_PlayerKilled( victim, attacker ){
	if( !is_user_connected( attacker ) && !is_user_connected( victim ))
		return HAM_IGNORED;
	
	if( !is_user_alive( attacker ))
		return HAM_IGNORED;
		
	if( attacker == victim )
		return HAM_IGNORED;
		
	set_task(0.1, "effect", victim );

	return HAM_IGNORED;
}

public effect( client ){
	message_begin( MSG_ONE, xMessageFov, _, client );
	write_byte( 50 );
	message_end();
}