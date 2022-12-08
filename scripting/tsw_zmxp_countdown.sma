#include < amxmodx >
#include < amxmisc >
#include < zombieplague >
#include < fakemeta >
#include < play_global >

#define PLUGIN "[ZMXP] Countdown"
#define VERSION "1.0"

new countdown, time_s

new const sound_countdown[ 10 ][] = {
	"CSP-2014/count_remix/one.mp3",
	"CSP-2014/count_remix/two.wav",
	"CSP-2014/count_remix/three.mp3",
	"CSP-2014/count_remix/four.wav",
	"CSP-2014/count_remix/five.mp3",
	"CSP-2014/count_remix/six.wav",
	"CSP-2014/count_remix/seven.mp3",
	"CSP-2014/count_remix/eight.wav",
	"CSP-2014/count_remix/nine.mp3",
	"CSP-2014/count_remix/ten.wav"
}

public plugin_init() {
	register_plugin( PLUGIN, VERSION, AUTHOR );
	register_event( "HLTV", "event_round_start", "a", "1=0", "2=0");
}

public plugin_precache(){
	for( new i = 0; i < sizeof( sound_countdown ); i++ )
		engfunc( EngFunc_PrecacheSound, sound_countdown[ i ]);
}

public event_round_start(){
	set_task(0.1, "csozm3_countdown");
	set_task(11.0, "csozm3_ghostchant");
	
	time_s = 20
	countdown = 9
}

public csozm3_countdown(){   	
	client_print( 0, print_center, "Round comeca em %i segundos.", time_s); 
	--time_s;
	
	if( time_s >= 1 )
		set_task(1.0, "csozm3_countdown")
}  

public csozm3_ghostchant(){	
	play_sound( 0, sound_countdown[ countdown ]);
	//emit_sound( 0, CHAN_VOICE, sound_countdown[ countdown ], 1.0, ATTN_NORM, 0, PITCH_NORM )
	
	countdown--
	
	if( countdown >= 1 )
		set_task( 1.0, "csozm3_ghostchant");
}
