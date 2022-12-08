#include < amxmodx >
#include < colorchat >
#include < play_global >

#define PLUGIN "[PLAY] API: Voteban"
#define VERSION "1.0"

#define CHAT_PREFIX "[VoteBan]"
#define LOG_FILE "voteban.log"

#define MAX_PLAYERS		32

enum { MAKE_VOTEBAN, REMOVE_VOTEBAN, SEE_WHO_VOTED_ON_ME }

new g_szReasons[][] = {
	"FK",
	"FK em Massa",
	"Desconhecimento de Regras",
	"Guarda Sem Mic",
	"Guarda com Mic Ruim",
	"Abuso de Mic",
	"Bug",
	"Anti Jogo",
	"Sem Objetivo"
}

new bool:g_bVotedPlayers[ MAX_PLAYERS + 1 ][ MAX_PLAYERS + 1 ]
new g_iLastTempID[ MAX_PLAYERS + 1 ]
new g_szLastNick[ MAX_PLAYERS + 1 ][ 32 ]

new g_iMaxPlayers
new g_iMenuCallBack
new g_iMakeVoteBanMenuCallback
new g_iRemoveVoteBanMenuCallback
new g_iSeeWhoVotedOnMeMenuCallback

new pCvar_BanPercentage
new pCvar_BanTime
new pCvar_MinPlayersToVoteBan
new pCvar_MaxVoteBansPerPlayer
new pCvar_BanByAmxBans
new pCvar_BanReason
new pCvar_LogVoteBans

native is_user_steam( index );
native get_user_rid( index );
native set_user_ban_rid( index );

public plugin_init(){
	register_plugin( PLUGIN, VERSION, AUTHOR );
	
	g_iMaxPlayers = get_maxplayers();
	
	register_clcmd( "_voteban_motivo", "ClCmd_Reason" )
	
	register_say( "voteban", "ClCmd_Voteban" );
	
	g_iMenuCallBack = menu_makecallback( "_MenuCallBack" )
	g_iMakeVoteBanMenuCallback = menu_makecallback( "_MakeVoteBanMenuCallback" )
	g_iRemoveVoteBanMenuCallback = menu_makecallback( "_RemoveVoteBanMenuCallback" )
	g_iSeeWhoVotedOnMeMenuCallback = menu_makecallback( "_SeeWhoVotedOnMeMenuCallback" )
	
	register_cvar( "avb_version", VERSION, FCVAR_SERVER | FCVAR_SPONLY )
	
	pCvar_BanPercentage = register_cvar( "avb_ban_percentage", "60" )
	pCvar_BanTime = register_cvar( "avb_ban_time_minutes", "10080" )
	pCvar_MinPlayersToVoteBan = register_cvar( "avb_min_players_to_voteban", "3" )
	pCvar_MaxVoteBansPerPlayer = register_cvar( "avb_max_votebans_per_player", "5" )
	pCvar_BanByAmxBans = register_cvar( "avb_ban_by_amx_bans", "0" )
	pCvar_BanReason = register_cvar( "avb_ban_reason", "Banido pelo Voteban" )
	pCvar_LogVoteBans = register_cvar( "avb_log_votebans", "1" )
}

public ClCmd_Reason( id ){
	new szReason[ 64 ]
	read_args( szReason, charsmax( szReason ) ) 
	
	remove_quotes( szReason )
	trim( szReason )
	
	if( szReason[ 0 ]){
		ExecuteVoteBan( id, g_iLastTempID[ id ], szReason )
	}
	
	else {
		ColorChat( id, RED, "%s^x01 Motivo Invalido, digite novamente!", CHAT_PREFIX )
		
		client_cmd( id, "messagemode _voteban_motivo" )
	}
	
	return PLUGIN_HANDLED
}

public client_disconnect( id ){
	get_user_name( id, g_szLastNick[ id ], charsmax( g_szLastNick[ ] ) )
	
	new i
	for( i = 1; i <= g_iMaxPlayers; i++ ){
		g_bVotedPlayers[ id ][ i ] = false;
		g_bVotedPlayers[ i ][ id ] = false;
		
		CheckVote( i )
	}
	
	g_iLastTempID[ id ] = 0
}

public _MenuCallBack( id, menu, item )
{
	switch( item )
	{
		case MAKE_VOTEBAN:
		{
			if( GetVoteBannedPlayers( id ) >= get_pcvar_num( pCvar_MaxVoteBansPerPlayer ) )
			{
				return ITEM_DISABLED
			}
			
			if( GetPlayersNum( ) < get_pcvar_num( pCvar_MinPlayersToVoteBan ) )
			{
				return ITEM_DISABLED
			}
		}
		
		case REMOVE_VOTEBAN:
		{
			if( GetVoteBannedPlayers( id ) == 0 )
			{
				return ITEM_DISABLED
			}
		}
		
		case SEE_WHO_VOTED_ON_ME:
		{
			if( GetVoteBans( id ) == 0 )
			{
				return ITEM_DISABLED
			}
		}
	}
	
	return ITEM_ENABLED
}

public ClCmd_Voteban( id ){
	new iMinPlayers = get_pcvar_num( pCvar_MinPlayersToVoteBan )
	
	if( GetPlayersNum( ) < iMinPlayers ){
		ColorChat( id, RED, "%s^x01 Voce nao pode votar neste momento, e preciso ter %i players online!", CHAT_PREFIX, iMinPlayers )
	}
	
	new iTemp[ 128 ];
	formatex( iTemp, charsmax( iTemp ), "\d%s^n %s VoteBan Menu:^n%s", xMenuLine, xPrefix, xMenuLine );
	new menu = menu_create( iTemp, "VoteBanMenu_Handler" );
	
	menu_additem( menu, "Dar VoteBan", _, _, g_iMenuCallBack );
	menu_additem( menu, "Remover VoteBan", _, _, g_iMenuCallBack );
	menu_additem( menu, "Ver quem me deu voteban", _, _, g_iMenuCallBack );
	
	menu_setprop( menu, MPROP_EXIT, MEXIT_ALL )
	
	menu_display( id, menu, 0 )
}

public VoteBanMenu_Handler( id, menu, item )
{
	menu_destroy( menu )
	
	switch( item )
	{
		case MAKE_VOTEBAN:
		{
			MakeVoteban( id )
		}
		
		case REMOVE_VOTEBAN:
		{
			RemoveVoteban( id )
		}
		
		case SEE_WHO_VOTED_ON_ME:
		{
			SeeWhoVotedOnMe( id )
		}
		
		case MENU_EXIT:
		{
			// nothing, menu already destroyed
		}
	}
}

public _MakeVoteBanMenuCallback( id, make_voteban_menu, item ){
	new szData[ 4 ]
	new access
	new callback
	
	menu_item_getinfo( make_voteban_menu, item, access, szData, charsmax( szData ), _, _, callback )
	
	new iTempID = str_to_num( szData )
	
	if( id == iTempID ){
		return ITEM_DISABLED
	}
	
	if( g_bVotedPlayers[ id ][ iTempID ] == true ){
		return ITEM_DISABLED
	}
	
	return ITEM_ENABLED
}

public MakeVoteban( id ){	
	new make_voteban_menu = menu_create( "\rVoteBan Menu", "MakeVoteBan_Handler" )
	
	new Players[ MAX_PLAYERS ]
	new iNum
	new iTempID
	new i
	
	new szName[ 64 ]
	new szTempid[ 4 ]
	
	get_players( Players, iNum, "ch" )
	
	for( i = 0; i < iNum; i++ ){
		iTempID = Players[ i ]
		
		get_user_name( iTempID, szName, charsmax( szName ) )
		
		if( id == iTempID ){
			format( szName, charsmax( szName ), "%s \r* \y(%i%%)", szName, GetPercentageOfVotes( iTempID ) )
		}
		
		else{
			format( szName, charsmax( szName ), "%s \y(%i%%)", szName, GetPercentageOfVotes( iTempID ) )
		}
		
		num_to_str( iTempID, szTempid, charsmax( szTempid ) )
		
		menu_additem( make_voteban_menu, szName, szTempid, _, g_iMakeVoteBanMenuCallback )
	}
	
	menu_setprop( make_voteban_menu, MPROP_EXIT, MEXIT_ALL )
	
	menu_display( id, make_voteban_menu, 0 )
}

public MakeVoteBan_Handler( id, make_voteban_menu, item ){
	if( item == MENU_EXIT ){
		menu_destroy( make_voteban_menu )
		return
	}
	
	new szTempID[ 4 ]
	new access
	new callback
	
	menu_item_getinfo( make_voteban_menu, item, access, szTempID, charsmax( szTempID ), _, _, callback )
	
	menu_destroy( make_voteban_menu )
	
	new iTempID = str_to_num( szTempID )
	
	if( !is_user_connected( iTempID )){
		ColorChat( id, RED, "%s^x01 O Player %s nao esta conectado!", CHAT_PREFIX, g_szLastNick[ iTempID ] )
		return
	}
	
	g_iLastTempID[ id ] = iTempID
	
	new szTempIDName[ 32 ]
	get_user_name( iTempID, szTempIDName, charsmax( szTempIDName ) )
	
	new szMenuTitle[ 64 ]
	formatex( szMenuTitle, charsmax( szMenuTitle ), "\rVoteBan Motivos \y[ \w%s \y]", szTempIDName )
	
	new reason_of_voteban_menu = menu_create( szMenuTitle, "ReasonOfVoteBan_Handler" )
	
	new i
	for( i = 0; i < sizeof( g_szReasons ); i++ ){
		menu_additem( reason_of_voteban_menu, g_szReasons[ i ])
	}
	
	menu_setprop( reason_of_voteban_menu, MPROP_EXIT, MEXIT_ALL )
	menu_display( id, reason_of_voteban_menu, 0 )	
}

public ReasonOfVoteBan_Handler( id, reason_of_voteban_menu, item ){
	if( item != MENU_EXIT ){
		if( !is_user_connected( g_iLastTempID[ id ])){
			ColorChat( id, RED, "%s^x01 O Player %s nao esta conectado!", CHAT_PREFIX, g_szLastNick[ g_iLastTempID[ id ] ] )
			return
		}
		
		if( item == sizeof( g_szReasons ) - 1 ){
			client_cmd( id, "messagemode _voteban_motivo" )
		}
		
		else{
			ExecuteVoteBan( id, g_iLastTempID[ id ], g_szReasons[ item ] )
		}
	}
	
	menu_destroy( reason_of_voteban_menu )
}

public _RemoveVoteBanMenuCallback( id, remove_voteban_menu, item ){
	new szData[ 4 ]
	new access
	new callback
	
	menu_item_getinfo( remove_voteban_menu, item, access, szData, charsmax( szData ), _, _, callback )
	
	new iTempID = str_to_num( szData );
	if( id == iTempID ){
		return ITEM_DISABLED
	}
	
	if( g_bVotedPlayers[ id ][ iTempID ] == false ){
		return ITEM_DISABLED
	}
	
	return ITEM_ENABLED
}

public RemoveVoteban( id ){
	new remove_voteban_menu = menu_create( "\rRemover VoteBan", "RemoveVoteBan_Handler" )
	
	new Players[ MAX_PLAYERS ]
	new iNum
	new iTempID
	new i
	
	new szName[ 64 ]
	new szTempid[ 4 ]
	
	get_players( Players, iNum, "ch" )
	
	for( i = 0; i < iNum; i++ ){
		iTempID = Players[ i ]
		
		if( g_bVotedPlayers[ id ][ iTempID ] == false )
			continue;
		
		get_user_name( iTempID, szName, charsmax( szName ))
		format( szName, charsmax( szName ), "\y%s \d(%i%%)", szName, GetPercentageOfVotes( iTempID ))
		
		num_to_str( iTempID, szTempid, charsmax( szTempid ))
		
		menu_additem( remove_voteban_menu, szName, szTempid, _, g_iRemoveVoteBanMenuCallback )
	}
	
	menu_setprop( remove_voteban_menu, MPROP_EXIT, MEXIT_ALL )
	
	menu_display( id, remove_voteban_menu, 0 )
}

public RemoveVoteBan_Handler( id, remove_voteban_menu, item ){
	if( item != MENU_EXIT ){
		new szTempID[ 4 ]
		new access
		new callback
		
		menu_item_getinfo( remove_voteban_menu, item, access, szTempID, charsmax( szTempID ), _, _, callback )
		
		new iTempID = str_to_num( szTempID )
		if( !is_user_connected( iTempID )){
			ColorChat( id, RED, "%s^x01 O Player %s nao esta conectado!", CHAT_PREFIX, g_szLastNick[ iTempID ] )
			return
		}
		
		g_bVotedPlayers[ id ][ iTempID ] = false
		
		new szIdName[ 32 ];
		get_user_name( id, szIdName, charsmax( szIdName ) )
		
		new szTempIDName[ 32 ]
		get_user_name( iTempID, szTempIDName, charsmax( szTempIDName ) )
		
		ColorChat( 0, RED, "%s^x01 O Player %s removeu voteban do %s", CHAT_PREFIX, szIdName, szTempIDName )
		
		if( get_pcvar_num( pCvar_LogVoteBans )){
			log_to_file( LOG_FILE, "O Player %s removeu voteban do %s", szIdName, szTempIDName )
		}
	}
	
	menu_destroy( remove_voteban_menu )
}

public _SeeWhoVotedOnMeMenuCallback( id, see_who_voted_on_me_menu, item ){
	return ITEM_DISABLED
}

public SeeWhoVotedOnMe( id ){
	new see_who_voted_on_me_menu = menu_create( "\rPlayers que votaram em voce!", "SeeWhoVotedOnMe_Handler" )
	
	new Players[ MAX_PLAYERS ]
	new iNum
	new iTempID
	new i
	
	new szName[ 64 ]
	
	get_players( Players, iNum, "ch" )
	
	for( i = 0; i < iNum; i++ ){
		iTempID = Players[ i ]
		
		if( g_bVotedPlayers[ iTempID ][ id ] == false ){
			continue
		}
		
		get_user_name( iTempID, szName, charsmax( szName ) )			
		format( szName, charsmax( szName ), "\w%s", szName )
		
		menu_additem( see_who_voted_on_me_menu, szName, _, _, g_iSeeWhoVotedOnMeMenuCallback )
	}
	
	menu_setprop( see_who_voted_on_me_menu, MPROP_EXIT, MEXIT_ALL )
	menu_display( id, see_who_voted_on_me_menu, 0 )
}

public SeeWhoVotedOnMe_Handler( id, see_who_voted_on_me_menu, item ){
	menu_destroy( see_who_voted_on_me_menu )
}

public ExecuteVoteBan( id, iTempID, szReason[]){
	g_bVotedPlayers[ id ][ iTempID ] = true
	
	new szIdName[ 32 ];
	get_user_name( id, szIdName, charsmax( szIdName ) )
	
	new szTempIDName[ 32 ]
	get_user_name( iTempID, szTempIDName, charsmax( szTempIDName ) )
	
	ColorChat( 0, RED, "%s^x01 O Player %s deu voteban no %s (%i%% de votos) Motivo: %s", CHAT_PREFIX, szIdName, szTempIDName, GetPercentageOfVotes( iTempID ), szReason )
	
	if( get_pcvar_num( pCvar_LogVoteBans )){
		log_to_file( LOG_FILE, "O Player %s deu voteban em %s pelo motivo: %s", szIdName, szTempIDName, szReason )
	}
	
	CheckVote( iTempID )
}

public CheckVote( id ){
	if( GetPercentageOfVotes( id ) >= get_pcvar_num( pCvar_BanPercentage )){
		new szName[ 32 ]
		get_user_name( id, szName, charsmax( szName ))
		
		new auth[ 35 ]
		//new rid = get_user_rid( id )
		
		//get_user_authid( id, szAuthID, charsmax( szAuthID ))
		
		new szBanReason[ 32 ]
		get_pcvar_string( pCvar_BanReason, szBanReason, charsmax( szBanReason ) )
		
		new iBanTime = get_pcvar_num( pCvar_BanTime )
		new iUserID = get_user_userid( id )
		
		if( get_pcvar_num( pCvar_BanByAmxBans )){
			server_cmd( "amx_ban ^"%i^" ^"#%i^" ^"%s^"", iBanTime, iUserID, szBanReason )
		}
		
		else{
			if( is_user_steam( id )){
				get_user_authid( id, auth, charsmax( auth ));
			}
			
			else {
				//get_user_name( id, auth, charsmax( auth ));
				get_user_ip( id, auth, charsmax( auth ), 1 );
			}
			
			//set_user_ban_rid( rid );
			
			server_cmd( "kick #%i ^"%s^"", iUserID, szBanReason )
			server_cmd( "banid %i %s", iBanTime, auth )
			server_cmd( "writeid" )
		}
		
		if( iBanTime == 0 )
		{
			ColorChat( 0, RED, "%s^x01 O Player %s foi banido permanente pelo voteban!", CHAT_PREFIX, szName )
			
			if( get_pcvar_num( pCvar_LogVoteBans ) )
			{
				log_to_file( LOG_FILE, "%s foi banido permanente pelo voteban!", szName )
			}
		}
		
		else
		{			
			ColorChat( 0, RED, "%s O Player %s foi banido por %i minuto%s pelo voteban!", CHAT_PREFIX, szName, iBanTime, iBanTime == 1 ? "" : "s" )
			
			if( get_pcvar_num( pCvar_LogVoteBans ) )
			{
				log_to_file( LOG_FILE, "%s foi banido por %i minuto%s pelo voteban!", szName, iBanTime, iBanTime == 1 ? "" : "s" )
			}
		}	
	}
}

GetVoteBannedPlayers( id ){
	new iCount
	
	new i
	for( i = 1; i <= g_iMaxPlayers; i++ ){
		if( g_bVotedPlayers[ id ][ i ] == true ){
			iCount++
		}
	}
	
	return iCount
}

GetVoteBans( id ){
	new iCount
	
	new i
	for( i = 1; i <= g_iMaxPlayers; i++ ){
		if( g_bVotedPlayers[ i ][ id ] == true ){
			iCount++
		}
	}
	
	return iCount
}

GetPercentageOfVotes( id ){
	return floatround( floatmul( float( GetVoteBans( id ) ), 100.0 ) / GetPlayersNum( ) )
}

GetPlayersNum(){
	new Players[ MAX_PLAYERS ]
	new iNum
	get_players( Players, iNum, "ch" )
	
	return iNum
}