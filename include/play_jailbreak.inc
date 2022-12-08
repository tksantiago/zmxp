#if defined _play_jailbreak_included
  #endinput
#endif
#define _play_jailbreak_included

#define JAIL_TEAM_ANY 0
#define JAIL_TEAM_PRISS (1<<1)
#define JAIL_TEAM_GUARD (1<<2)

#define SETTING_FILE "play_jailbreak.ini"

#define ACCESS_VIP ADMIN_RESERVATION

#define BODY_PRISS 2
#define BODY_GUARD 1
#define BODY_GUARD_VIP 3

#define SKIN_VIP 0
#define SKIN_NORM 1
#define SKIN_ALGEMADO 2
#define SKIN_FREEDAY 3
#define SKIN_REBEL 4

#define PLAYER_NO_REBEL 0
#define PLAYER_REBEL 1

enum {
	DAY_NONE = 0,
	DAY_CAGE,
	DAY_FREE,
	DAY_ZOMBIE
}

enum SpeakersType {
	MUTED_ALL,
	MUTED_SPEAKER,
	ALIVE_SPEAKER,
	ADMIN_SPEAKER,
	TEAM_SPEAKER
};

enum {
	OPTION_OFF = 0,
	OPTION_ON
}

//const JAIL_TEAM_ZOMBIE = (1<<2)
//const JAIL_TEAM_HUMMAN = (1<<3)

//native jail_user_connected( index ); // verefica se o player esta conectado no servidor.
//native jail_user_alive( index ); // verefica se o player esta vivo.
//native jail_user_duel( index );
//native jail_last_priss( index );
//native jail_last_guard( index );

native JailGetUserStuck( index ); // verefica se o player esta travado no mapa.
native JailSetUserKill( index ); // da kill no player com efeito.

native JailSetUserGodMod( index, bool:set = false );
native JailSetUserSpeed( index, Float:speed = 250.0 );

native JailBlockHandCuffed( index, set = 0 );
native JailBlockGetWeapon( index, set = 0 );

/** Reseta o model para o padrão do jailbreak **/
native JailResetUserModel( index );

/** Seta model diferente, digamos model de galinha, zombie etc. **/
native JailSetUserCustomModel( index, const model[]); 

/** SETA A SUB MODEL E SUB SKIN DO MODEL DO JAILBREAK **/
native JailSetUserSubModel( index, body, skin );

/* Da a NightVision para o player
	0 - Desativa NightVision
	1 - Ativa NightVision
*/
native jail_set_user_nightvision( index, set, r,g,b );

/** Abre o Menu de armas **/
//native jail_show_weapons_menu( index );

//native jail_set_user_points( index );
//native jail_get_user_points( index );

//native jail_game_started();
//native jail_is_freeday();
//native jail_get_current_day();
//native jail_open_cells();

/** bloqueia o time a pegar armas **/
//native set_block_get_wpn( team );

/** Mensagem diferente para vitoria do time **/
//native set_win_message( team, const message[]);

/** Shop **/
forward JailShopItemSelected( index, item );
native JailRegisterShop( const item_name[], const item1_info[], item_cost, item_team, item_admin );

/** Days **/
//forward jail_start_specialday( inday );
//native jail_register_day( const day_name[] );

/** Algemas **/
native JailGetUserHandCuffs( index );
native JailSetUserHandCuffs( index, ammount );

/** Frozen - Algemado **/
//native jail_get_user_frozen( index );
//native jail_set_user_frozen( index, set = 0 );
//native jail_set_user_nofrozen( index, set = 0 );
native JailSetUserUnHandCuffed( index ); // Desalgemar Player

/** SETA PARA REBELAR O PLAYER, OU REMOVER **/
native JailSetUserRebelled( index, set = PLAYER_NO_REBEL );

/** DUELO **/
forward JailDuelSelected( index, duel );

/* Register Itens Duelo:

	OP1 = Tiro por Tiro
	OP2 = Gravidade
	OP3 = Velocidade
	OP4 = Mira
*/

native JailRegisterDuel( const duel_name[], csw_item, duel_op1, duel_op2, duel_op3, duel_op4, duel_admin );

/** HAND **/
native JailResetUserHand( index );

native JailSetUserShotButton( index, bool:set = false );

native JailGetPlayerGameTeam( index );

/** LOG  JAILBREAK **/
stock jail_log( type, const message_fmt[], any:...){
	static message[ 256 ];
	vformat( message, sizeof( message ) - 1, message_fmt, 2);
	
	static filename[ 96 ], dir[ 64 ];
	if( !dir[ 0 ]){
		get_basedir( dir, sizeof( dir ) - 1);
		add( dir, sizeof( dir ) - 1, "/logs");
	}
	
	new iTemp[ 128 ];
	switch( type ){
		case LOG_ERROR: formatex( iTemp, charsmax( iTemp ), "ERROR");
		case LOG_OTHERS: formatex( iTemp, charsmax( iTemp ), "OTHERS");
		case LOG_SHOP: formatex( iTemp, charsmax( iTemp ), "SHOP");
		case LOG_DAYS: formatex( iTemp, charsmax( iTemp ), "DAYS");
	}
	
	format_time(filename, sizeof(filename) - 1, "%m%d%Y");
	format(filename, sizeof(filename) - 1, "%s/JAILBREAK_LOGS/%s_%s.log", dir, iTemp, filename );

	log_to_file(filename, "[%s] %s", iTemp, message );
}
