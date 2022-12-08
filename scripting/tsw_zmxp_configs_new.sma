#include < amxmodx >
#include < amxmisc >

#include < play_global >
#include < play_colorchat >

#define PLUGIN "Mod Manager"
#define VERSION "1.0"

// MODO CLASSICO
new const MODO_CLASSICO_PLUGINS[] = "/plugins-classic.ini"
new const MODO_CLASSICO_PLUGINS_P[] = "/pause-plugins-classic.ini"

// MODO BIOHAZARD
new const MODO_BIOHAZARD_PLUGINS[] = "/plugins-biohazard.ini"
new const MODO_BIOHAZARD_PLUGINS_P[] = "/pause-plugins-biohazard.ini"

#define MAX_MOD 2
new xTimeLeft, xChangedMod 
new xMainModVotes[ MAX_MOD+1 ];
new bool: xHasVoted[ MAX_PLAYERS+1 ] = { false, ... };

#define TASK_VOTE_MENU 1000

new const TSWModsNames[ MAX_MOD ][] = {
	"Classico",
	"Biohazard"
}

enum {
	MOD_CLASSIC = 0,
	MOD_BIOHAZARD
}

native set_start_vote_map();
new xModRuning;

public plugin_cfg(){
	//new iTemp[ 128 ];
	//formatex( iTemp, charsmax( iTemp ), "- %s [Zombie-XP]( %s ) - by %s", xPrefix, TSWModsNames[ xModRuning ], xHostName );
	//server_cmd( "hostname ^"%s^"", iTemp );
}

public plugin_init(){
	RegisterPlugin( PLUGIN, VERSION, AUTHOR );
	
	register_concmd( "tsw_votemap", "StartModVote", ADMIN_RCON );
	register_forward( FM_GetGameDescription, "FwdGetGameDescription" );
}

public FwdGetGameDescription(){
	new iTemp[ 32 ];
	formatex( iTemp, charsmax( iTemp ), "[%s]", TSWModsNames[ xModRuning ]);
	
	forward_return( FMV_STRING, iTemp );
	return FMRES_SUPERCEDE;
}

public plugin_natives(){	
	new iConfigDir[ 64 ], iURLClassic[ 64 ], iURLBiohazard[ 64 ];
	get_configsdir( iConfigDir, charsmax( iConfigDir ))
	
	format( iURLClassic, charsmax( iURLClassic ), "%s/plugins-classic.ini", iConfigDir );
	format( iURLBiohazard, charsmax( iURLBiohazard ), "%s/plugins-biohazard.ini", iConfigDir );
	
	if( file_exists( iURLClassic )) xModRuning = MOD_CLASSIC;
	else if( file_exists( iURLBiohazard )) xModRuning = MOD_BIOHAZARD;
	
	register_native( "GetModRunning", "native_get_mod_running", 1 );
	register_native( "GetNextMod", "native_get_next_mod", 1);
	register_native( "SetNextMod", "native_set_next_mod", 1);
}

public native_get_mod_running(){
	return xModRuning;
}

public native_get_next_mod(){
	return xChangedMod;
}

public native_set_next_mod( mod ){
	ModChanged( mod );
}

public StartModVote( id ){
	if(!( get_user_flags( id ) & ADMIN_RCON ))
		return;
	
	client_cmd(0, "spk ^"get red(e80) ninety(s45) to check(e20) use bay(s18) mass(e42) cap(s50)^"");
	set_task(8.5, "vote_handleDisplay");
	
	set_task( 1.0, "vote_countdownPendingVote", _, _, _, "a", 7);
}

public vote_countdownPendingVote(){
	static countdown = 7;

	set_hudmessage(0, 222, 50, -1.0, 0.13, 0, 1.0, 0.94, 0.0, 0.0, -1);
	show_hudmessage(0, "A Votacao do Mod tera inicio em %i segundos...", countdown );

	new word[6];
	num_to_word(countdown, word, 5);
		
	client_cmd(0, "spk ^"fvox/%s^"", word);
	
	countdown--;
	
	if( countdown == 0 )
		countdown = 7;
}

public vote_handleDisplay(){
	client_cmd(0, "spk Gman/Gman_Choose%i", random_num(1, 2));
	
	xTimeLeft = 15;
	
	clamp( xTimeLeft, 5, 30 );
	set_task( 1.0, "VoteMenuCountdown", TASK_VOTE_MENU, _, _, "a", xTimeLeft );
}

public VoteMenuCountdown(){
	xTimeLeft--;
	
	if( xTimeLeft > 0 ){	
		new iPlayers[ 32 ], iPlayer, iNum;
		get_players( iPlayers, iNum, "a" );
		
		for( new i = 0; i < iNum; i++ ){
			iPlayer = iPlayers[ i ];
			menu_vote_mod( iPlayer );
		}
	}
	
	else {
		show_menu( 0, 0, "^n", 1 );
		remove_task( TASK_VOTE_MENU );

		xChangedMod = get_votes_result( xMainModVotes, MAX_MOD );
	
		if( xChangedMod < 0 ){
			ColorChat( 0, NORMAL, "^x03 A Votacao falhou, o mod^x04 %s^x01 foi escolhido aleatoriamente!");
			
			new x = random_num( 0, MAX_MOD );
			ModChanged( x );
		}
		
		else {
			for( new i = 0; i < sizeof xHasVoted; i++ )
				xHasVoted[ i ] = false;
			
			ModChanged( xChangedMod );
		}
		
		set_start_vote_map();
	}
}

stock ModChanged( mod ){
	switch( mod ){
		case 0: StartConfigClassic();
		case 1: StartConfigBiohazard();
	}
}

public menu_vote_mod( id ){
	if(!( xTimeLeft > 0 ))
		return;
	
	new iTemp[ 2048 ];
	formatex( iTemp, charsmax( iTemp ), "\d%s^n%s - Escolha o Mod:^n%s^n^n\rTempo Restante: %d", xMenuLine, xPrefix, xMenuLine, xTimeLeft );
	new iMenu = menu_create( iTemp, "menu_vote_handler" );

	new iTemp2[ 512 ]
	for( new i = 0; i < sizeof( TSWModsNames ); i++ ){
		num_to_str( i, iTemp, 127 );
		formatex( iTemp2, charsmax( iTemp2 ), "\y %s\d ( %i%%)", TSWModsNames[ i ], GetPercentVote( i ))
		menu_additem( iMenu, iTemp2, iTemp, 0 );
	}
	
	menu_setprop( iMenu, MPROP_EXITNAME, "\d Sair" );
	menu_setprop( iMenu, MPROP_NUMBER_COLOR, "\r" );
	menu_display( id, iMenu, 0 );
}

stock GetPercentVote( mod ){
	return floatround( floatmul( float( xMainModVotes[ mod ]), 100.0 ) / GetPlayersNum());
}

stock GetPlayersNum(){
	new iPlayers[ MAX_PLAYERS ], iNum
	get_players( iPlayers, iNum, "ch" );
	
	return iNum;
}

public menu_vote_handler( id, menu, item ){
	if( item == MENU_EXIT ){
		menu_destroy( menu );
		return PLUGIN_HANDLED;		
	}
	
	new data[ 6 ], iName[ 64 ], access, callback
	menu_item_getinfo( menu, item, access, data, 5, iName, 63, callback );
	
	if( xHasVoted[ id ]){
		ColorChat( id, GREEN, "^x03 Voce ja votou, aguarde o final da votacao!");
		return PLUGIN_HANDLED;
	}
	
	new iKey = str_to_num( data );	
	xMainModVotes[ iKey ]++;
	xHasVoted[ id ] = true;
	
	new iPlayerName[ 33 ];
	get_user_name( id, iPlayerName, charsmax( iPlayerName ));
	ColorChat( 0, GREEN, "^x03 %s votou para que seja^x04 %s^x01!", iPlayerName, TSWModsNames[ iKey ]);
	
	menu_vote_mod( id );
	
	menu_destroy( menu );
	return PLUGIN_HANDLED;
}

stock get_votes_result( const votes[], len ){
	new maximum = 0;
	for( new i = 0; i < len; i++ ){
		if( votes[ i ] > votes[ maximum ])
			maximum = i;
	}
	
	if( maximum == 0 && votes[0] == 0 ){
		return -1;
	}
	
	return maximum;
}

public StartConfigClassic(){
	new iPluginsClassic[ 64 ], iPluginsBiohazard[ 64 ];
	new iPluginsClassicP[ 64 ], iPluginsBiohazardP[ 64 ];
	
	get_configsdir( iPluginsClassic, charsmax( iPluginsClassic ));
	get_configsdir( iPluginsClassicP, charsmax( iPluginsClassicP ));
	
	get_configsdir( iPluginsBiohazard, charsmax( iPluginsBiohazard ));
	get_configsdir( iPluginsBiohazardP, charsmax( iPluginsBiohazardP ));
	
	
	add( iPluginsClassic, charsmax( iPluginsClassic ), MODO_CLASSICO_PLUGINS );
	add( iPluginsClassicP, charsmax( iPluginsClassicP ), MODO_CLASSICO_PLUGINS_P );
	
	add( iPluginsBiohazard, charsmax( iPluginsBiohazard ), MODO_BIOHAZARD_PLUGINS );
	add( iPluginsBiohazardP, charsmax( iPluginsBiohazardP ), MODO_BIOHAZARD_PLUGINS_P );
	
	// Despausando Plugins
	if( file_exists( iPluginsClassicP ))
		rename_file( iPluginsClassicP, iPluginsClassic, 1);
	
	// Pausando Plugins
	if( file_exists( iPluginsBiohazard ))
		rename_file( iPluginsBiohazard, iPluginsBiohazardP, 1);
}

public StartConfigBiohazard(){
	new iPluginsClassic[ 64 ], iPluginsBiohazard[ 64 ];
	new iPluginsClassicP[ 64 ], iPluginsBiohazardP[ 64 ];
	
	get_configsdir( iPluginsClassic, charsmax( iPluginsClassic ));
	get_configsdir( iPluginsClassicP, charsmax( iPluginsClassicP ));
	
	get_configsdir( iPluginsBiohazard, charsmax( iPluginsBiohazard ));
	get_configsdir( iPluginsBiohazardP, charsmax( iPluginsBiohazardP ));
	
	
	add( iPluginsClassic, charsmax( iPluginsClassic ), MODO_CLASSICO_PLUGINS );
	add( iPluginsClassicP, charsmax( iPluginsClassicP ), MODO_CLASSICO_PLUGINS_P );
	
	add( iPluginsBiohazard, charsmax( iPluginsBiohazard ), MODO_BIOHAZARD_PLUGINS );
	add( iPluginsBiohazardP, charsmax( iPluginsBiohazardP ), MODO_BIOHAZARD_PLUGINS_P );
	
	// Pausando Plugins
	if( file_exists( iPluginsClassic ))
		rename_file( iPluginsClassic, iPluginsClassicP, 1);
	
	// Despausando Plugins
	if( file_exists( iPluginsBiohazardP ))
		rename_file( iPluginsBiohazardP, iPluginsBiohazard, 1);
}
