/**

	Mudando a conta para steam, na coluna PLATAFORMA, o valor sera 0, sendo assim, nao tera plataforma nenhuma,
	quando ele entrar pela steam, a verifica��o de troca de plataforma vira antes da de steam,
	vai verificar atraves do ip
	
	SELECT PLATAFORMA AND IP = '' AND PLATAFORMA = 0
	
	depois que verificar o ip, ele fara update na conta pelo IP, e atualizara ela para steam.
	
	para atualizar o plugin do zmxp ou jail, passa uma forward de mudan�a de conta, que sera puxada no plugin do zmxp
	ela fara update da conta na tabela play_zombiexp
	
*/


#include < amxmodx >
#include < amxmisc >
#include < fakemeta >
#include < sqlx >

#include < a_global >




#define PLUGIN "Registro"
#define VERSION "1.0"

//native save_points( index, ridex );

//#define GAMEMENU_FILE "resource/GameMenu.res"
#define MAX_SIZE 1012

#define TASK_LOGIN 8000

//new g_Text[MAX_SIZE]

#define MAX_LOGIN_xPlayerTentativas 3

new xPlayerTentativas[ MAX_PLAYERS+1 ] // guardar as tentativas...
new motd_recuperar[200] = "http://www.impactgaming.com.br/eduardo/servidores/mail.php?mail=%s"

new bool: xPlayerLogado[ MAX_PLAYERS+1 ];
new bool: xPlayerSTEAM[ MAX_PLAYERS+1 ];
new bool: xPlayerConected[ MAX_PLAYERS+1 ];
new bool: xPlayerNaoQuerRegistrar[ MAX_PLAYERS+1 ];
new bool: xPlayerPediuPraRecuperar[ MAX_PLAYERS+1 ];

/** GLOBAL PLAYER VARS **/
new xPlayerUser[ MAX_PLAYERS+1 ][ 33 ];
new xPlayerPass[ MAX_PLAYERS+1 ][ 33 ];
new xPlayerEmail[ MAX_PLAYERS+1 ][ 64 ];
//new xPlayerKey[ MAX_PLAYERS+1 ];
new xPlayerKey[ MAX_PLAYERS+1 ][ 64 ];
new xPlayerSlotsInv[ MAX_PLAYERS+1 ];
new xPlayerStatusAccount[ MAX_PLAYERS+1 ];

// Menus
new xPlayerMenu[33]
new bool:xPlayerAutoLogin[33]
new g_PlayerDigitar[33]
new xPlayerMenuPassNova[33][33]
// Menu de Login
new g_Menu2LoginDigitado[33][64]
new g_Menu2SenhaDigitada[33][33]
// Menu de Registro
new g_Menu3LoginDigitado[33][33]
new g_Menu3SenhaDigitada[33][33]
new g_Menu3EmailDigitado[33][64]

/** MYSQL **/
new registro_mysql_persistent
new Handle:gDbTuple
new Handle:gDbConnect
new bool:gPersistentTemp
//new xErrorConnect[128];


new xMaxPlayers, g_msgid_SayText, g_msgSyncHud

// Forward
new xPlayerAutenticou, g_DummyResult_f
new const MESSAGE_TAG_REGISTRO[] = "[CSPGAMING - REGISTRO]"

// Menus
const KEYSMENU = MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_5|MENU_KEY_6|MENU_KEY_7|MENU_KEY_8|MENU_KEY_9|MENU_KEY_0
const KEYSPRINCIPAL = MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4
const KEYSREGISTRO = MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_5
const KEYS5 = MENU_KEY_1|MENU_KEY_2|MENU_KEY_0
const KEYS3 = MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_0
const KEYS_TESTE = MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_0
const KEYSUNICA = MENU_KEY_0

#define MAX_SOUNDS 	1
#define TASK_SOUND	100

new sounds_registro[ MAX_SOUNDS ][] = {
	"CSP-2014/welcome1.wav"
}

public plugin_precache(){
	for( new i = 0; i < sizeof( sounds_registro ); i++ )
		engfunc( EngFunc_PrecacheSound, sounds_registro[ i ]);
}

new xNoSxePlayerVip[ 33 ];


//new HudSyncObjMenu1;
//new HudSyncObjMenu2;
//new HudSyncObjMenu3;
//new xCountMenuItens

new error[128]

new xMSGSync[ 15 ];
enum {
	MENU_ITEM = 0,
	MENU_ITEM1,
	MENU_ITEM2,
	MENU_ITEM3,
	MENU_ITEM4,
	MENU_ITEM5,
	MENU_ITEM6,
	MENU_ITEM7,
	MENU_ITEM8,
	
	MENU_TITLE,
	MENU_NUMBERS
}

/*new xSoundsBlock[ 3 ][ 64 ] = {
    "player/britnegative.wav", 
    "player/gernegative.wav", 
    "player/usnegative.wav"
}*/

public plugin_init(){
	
	MySQLx_Init();
	
	register_plugin( PLUGIN, VERSION, AUTHOR );
	
	xMSGSync[ MENU_TITLE ] = CreateHudSyncObj();
	xMSGSync[ MENU_ITEM1 ] = CreateHudSyncObj();
	xMSGSync[ MENU_ITEM2 ] = CreateHudSyncObj();
	xMSGSync[ MENU_NUMBERS ] = CreateHudSyncObj();
	
	//HudSyncObjMenu1 = CreateHudSyncObj();
	//HudSyncObjMenu2 = CreateHudSyncObj();
	//HudSyncObjMenu3 = CreateHudSyncObj();
	
	register_forward( FM_EmitSound, "BlockSounds");
	
	/** SAY COMANDS **/
	RegisterSay("registrar", "cmd_menu_registro");
	RegisterSay("registro", "cmd_menu_registro");
	RegisterSay("register", "cmd_menu_registro");
	RegisterSay("login", "cmd_menu_registro");
	RegisterSay("logar", "cmd_menu_registro");
	RegisterSay("key", "cmd_show_key");
	
	/** CMD COMANDS **/
	register_clcmd("registrar", "cmd_menu_registro");
	register_clcmd("registro", "cmd_menu_registro");
	register_clcmd("register", "cmd_menu_registro");
	register_clcmd("login", "cmd_menu_registro");
	register_clcmd("logar", "cmd_menu_registro");
	register_clcmd("jointeam", "HookTeamCommands");
	register_clcmd("chooseteam", "HookTeamCommands");
	
	register_message(get_user_msgid("ShowMenu"), "TextMenu")
	register_message(get_user_msgid("VGUIMenu"), "VGUIMenu")
	
	register_concmd("DIGITE_SEU_LOGIN", "MenuLogin", ADMIN_ALL, "[ Digite apenas o Login ]")
	register_concmd("DIGITE_SUA_SENHA", "MenuSenha", ADMIN_ALL, "[ Digite apenas a Senha ]")
	register_concmd("DIGITE_SEU_EMAIL", "MenuEmail", ADMIN_ALL, "[ Digite apenas o E-mail ]")
	//register_concmd("DIGITE_SUA_STEAM_ID", "MenuSteamID", ADMIN_ALL, "[ Digite apenas sua SteamID ]")
	
	registro_mysql_persistent = register_cvar("registro_mysql_persistent", "0")
	
	
	xPlayerAutenticou = CreateMultiForward("registro_user_autenticou", ET_IGNORE, FP_CELL, FP_CELL)	
	
	xMaxPlayers = get_maxplayers()
	g_msgid_SayText = get_user_msgid("SayText")
	g_msgSyncHud = CreateHudSyncObj();
	//register_forward(FM_ClientUserInfoChanged, "Fwd_ClientInfoChanged")
	//set_task(5.0, "Read_GameMenu")
	
	register_dictionary_colored("play_api_registro.txt")
		
	register_menu("Menu Principal", KEYSMENU, "PrincipalHandle")
	register_menu("Menu Login", KEYSMENU, "MenuLoginHandler")
	//register_menu("Menu Registro Teste", KEYS_TESTE, "MenuTestHandler")
	
	register_clcmd( "testee", "testee");
}

public BlockSounds( entity, channel, const sound[]){
	/*
    for( new i; i < sizeof xSoundsBlock; i++ ){
		if( equali( sound, xSoundsBlock[ i ]))
			return FMRES_SUPERCEDE;
	}
	
    return FMRES_IGNORED;
	*/
}

public MySQLx_Init(){
	#include "play4ever.inc/play_conecta.play"
}

public testee( id ){
	client_print( id, print_chat, "Limite de: %d", get_user_slots( id ));
}

public cmd_show_key( id )
	client_print( id, print_chat, "Sua Key e: %s", xPlayerKey[ id ]);


/*
public Read_GameMenu()
{
	new i_File, s_File[128]
	
	get_configsdir(s_File, charsmax(s_File))
	
	format(s_File, charsmax(s_File), "%s/gamemenu.txt", s_File)
	
	i_File = fopen(s_File, "r")
	
	fgets(i_File, g_Text, MAX_SIZE)
	fclose(i_File)
}
*/

public plugin_natives(){
	register_library("play_registro");
	
	register_native("get_user_login", "native_get_user_login", 0);
	//register_native("get_user_rid", "native_get_user_rid", 0)
	register_native("get_user_key", "native_get_user_key", 0)
	register_native("is_user_steam", "native_is_user_steam", 1 );
	register_native("registro_user_liberado", "native_registro_user_liberado", 1)
	register_native("set_user_ban_account", "native_set_user_ban_account", 1)
}

public native_get_user_key( plugin_id, param_nums ){
	if(param_nums != 3)
		return -1
	
	static id; id = get_param(1)
	
	if( !xPlayerConected[ id ])
		return 0
	
	set_string( 2, xPlayerKey[ id ], get_param( 3 ))
	
	return 1
}

public native_set_user_ban_account( id ){
	
	/*
	new err,error[128] , szQuery[ 128 ]
	new Handle:connect = SQL_Connect(gDbTuple, err, error, 127) 
	
	if(err){ 
		log_amx("--> MySQL Connection Failed - [%d][%s]",err,error) 
		set_fail_state("mysql connection failed") 
	} 
	
	new Handle:iQuery
	
	formatex( szQuery, 127, "UPDATE play_registro SET STATUS = 0 WHERE RID = %i", rid );
	iQuery = SQL_PrepareQuery(connect, szQuery) 
	SQL_Execute(iQuery) 
	SQL_FreeHandle( iQuery ) 
	SQL_FreeHandle( connect ) 
	
	return true
	*/
}

stock get_user_slots( index ){	
	if( !xPlayerConected[ index ])
		return false;
	
	return xPlayerSlotsInv[ index ];
}

/*
public native_get_user_rid(plugin_id, param_nums){    
	static id; id = get_param(1)
	
	if(!xPlayerConected[id])
		return 0
	
	return xPlayerKey[id]
}
*/

// Native: get_user_key
public native_get_user_login(plugin_id, param_nums)
{
	if(param_nums != 3)
		return -1
	
	static id; id = get_param(1)
	
	if(!xPlayerConected[id])
		return 0
	
	set_string(2, xPlayerUser[id], get_param(3))
	
	return 1
}

public native_is_user_steam( index ){    	
	if(!xPlayerConected[ index ])
		return false;
	
	return xPlayerSTEAM[ index ];
}

public native_registro_user_liberado( index ){   	
	if( !xPlayerConected[ index ])
		return false;
	
	if( xPlayerLogado[ index ] || xPlayerNaoQuerRegistrar[ index ]/* || xPlayerSTEAM[ index ]*/)
		return true;
	
	return false;
}

public cmd_menu_registro( id ){
	if( xPlayerNaoQuerRegistrar[ id ]){
		PrintRegistro( id, "Voce escolheu nao usar o registro, caso queira se registrar de retry!");
		console_print( id, "[REGISTRO] Voce escolheu nao usar o registro, caso queira se registrar de retry!");
		
		return PLUGIN_HANDLED;
	}
	
	else MenuPrincipal( id );
	
	return PLUGIN_HANDLED;
}

public TextMenu( msgid, dest, id ){
	if( !xPlayerConected[ id ])
		return PLUGIN_CONTINUE;
	
	if( !xPlayerLogado[ id ] && !xPlayerNaoQuerRegistrar[ id ]){
		/*
		if( !xPlayerSTEAM[ id ])
			MenuPrincipal( id );
		*/
		
		set_hudmessage( random_num( 0, 255 ), random_num( 0, 255 ), random_num( 0, 255 ), -1.0, 0.35, 2, 1.0, 3.0, 0.1, 5.0, -1);	
		ShowSyncHudMsg( id, g_msgSyncHud, ".....:....... Carregando, por favor aguarde! .......:......");
		
		return PLUGIN_HANDLED;
	}	
	
	return PLUGIN_CONTINUE;
}

public VGUIMenu( msgid, dest, id ){
	if( !xPlayerConected[ id ])
		return PLUGIN_CONTINUE;
	
	if(!xPlayerLogado[ id ] && !xPlayerNaoQuerRegistrar[ id ]){
		/*
		if( !xPlayerSTEAM[ id ])
			MenuPrincipal( id );
		*/
		
		set_hudmessage( random_num( 0, 255 ), random_num( 0, 255 ), random_num( 0, 255 ), -1.0, 0.35, 2, 1.0, 3.0, 0.1, 5.0, -1);
		ShowSyncHudMsg( id, g_msgSyncHud, ".....:....... Carregando, por favor aguarde! .......:......");
		
		return PLUGIN_HANDLED;
	}
	
	return PLUGIN_CONTINUE;
}

public HookTeamCommands( id ){
	if( !xPlayerConected[ id ])
		return PLUGIN_CONTINUE;
	
	/*
	if( get_mod_running() == PLAY_MOD_JAIL ){
		//return PLUGIN_HANDLED;
	}
	*/
	
	if(!xPlayerLogado[ id ] && !xPlayerNaoQuerRegistrar[ id ]/* && !xPlayerSTEAM[ id ]*/){
		MenuPrincipal(id)
		set_hudmessage(random_num(0,255), random_num(0,255), random_num(0,255), -1.0, 0.35, 2, 1.0, 3.0, 0.1, 5.0, -1)
		ShowSyncHudMsg(id, g_msgSyncHud, "ESCOLHA UMA OPCAO DO MENU!")
		return PLUGIN_HANDLED
	}	
	
	return PLUGIN_CONTINUE
}

public Fwd_ClientInfoChanged( id, buffer ){
	if( !xPlayerConected[ id ])
		return FMRES_IGNORED;
	
	static iName[ 32 ], val[ 32 ];
	get_user_name( id, iName, charsmax( iName ))
	replace_all( iName, charsmax( iName ), "'", "\'");
	
	engfunc( EngFunc_InfoKeyValue, buffer, "name", val, sizeof val - 1)
	
	if( containi( val, "[NO-sXe-I]") != -1 && !xPlayerSTEAM[ id ] || !xNoSxePlayerVip[ id ]){
		server_cmd("kick #%i ^"%s - sXe injected obrigatorio para No-Steam.^"", get_user_userid( id ), xPrefix );
		return FMRES_IGNORED;
	}
	
	if( equal( val, iName ))
		return FMRES_IGNORED;
	
	if( !xNoSxePlayerVip[ id ] && !xPlayerSTEAM[ id ] && !xPlayerLogado[ id ]){
		engfunc( EngFunc_SetClientKeyValue, id, buffer, "name", iName );
		client_cmd( id, "name ^"%s^"; setinfo name ^"%s^"", iName, iName );
		
		client_print_color( id, print_team_default, "^x01 Apenas jogadores registrados com conta atualizada e STEAM podem trocar de nick no servidor!")
	}
	
	return FMRES_SUPERCEDE;
}

public CheckSteamAccount( id ){
	static idx 
	idx = ( id - TASK_LOGIN );
	
	new err;
	new Handle:connect = SQL_Connect( gDbTuple,err,error,127) 
	if( err ){ 
		log_amx("--> MySQL Connection Failed - [%d][%s]",err,error) 
		set_fail_state("mysql connection failed") 
	}
	
	/** VERIFICAMOS SE O PLAYER ESTA TENTANDO ATUALIZAR A CONTA PARA STEAM ************************************************/
	
	static iName[ 32 ];
	get_user_name( idx, iName, charsmax( iName ))
	replace_all( iName, charsmax( iName ), "'", "\'");
	
	static iAuth[ 32 ];
	get_user_authid( idx, iAuth, charsmax( iAuth ));
	
	static iUserIP[ 35 ];
	get_user_ip( idx, iUserIP, charsmax( iUserIP ), 1);
	
	new Handle: iQuery1, szQuery1[ 500 ];
	formatex( szQuery1, charsmax( szQuery1 ), "SELECT IP FROM play_registro WHERE IP = '%s' AND PLATAFORMA = 0", iUserIP ); 
	iQuery1 = SQL_PrepareQuery( connect, szQuery1 );
	SQL_Execute( iQuery1 );
	
	if( !SQL_Execute( iQuery1 )){
		xPlayerLogado[ idx ] = false;
		log_message("Erro ao tentar localizar o IP: '%s' - ERRO: '%s'", iUserIP, error );
	}
	
	if( SQL_MoreResults( iQuery1 )){
		new Handle: queryt
		static sqlt[ 320 ];
		
		formatex( sqlt, charsmax( sqlt ), "UPDATE play_registro SET MEMBRO_KEY = '%s', PASSWORD = '%s', EMAIL = '%s', LOGIN = '%s', PLATAFORMA = '1', NICK = '%s' WHERE IP = '%s'", iAuth, iAuth, iAuth, iAuth, iName, iUserIP)
		queryt = SQL_PrepareQuery( connect, sqlt );
		
		if( !SQL_Execute( queryt )){
			xPlayerLogado[ idx ] = false;
			log_message("Erro ao tentar atualizar conta Para Steam IP: '%s' MEMBRO_KEY: '%d' - ERRO: '%s'", iUserIP, iAuth, error );
		}
		
		else client_print_color( idx, print_team_default, "^x01 Sua conta foi Atualizada para STEAM-ID: %s!", iAuth );
	}
	
	SQL_FreeHandle( iQuery1 );
	
	/**********************************************************************************************************************/
	
	new Handle:iQuery, szQuery[ 500 ];
	
	formatex( szQuery, 499, "SELECT MEMBRO_KEY, MAX_INVENTARIO_ITENS, STATUS, IP FROM play_registro WHERE MEMBRO_KEY = '%s' AND PLATAFORMA = 1", iAuth ) 
	iQuery = SQL_PrepareQuery( connect, szQuery );
	SQL_Execute( iQuery );
	
	if( !SQL_Execute( iQuery )){
		xPlayerLogado[ idx ] = false;
		log_message("Erro ao tentar executar a pesquisa no play_registro MEMBRO_KEY: '%d' - ERRO: '%s'", iAuth, error );
	}
	
	if( SQL_MoreResults( iQuery )){
		xPlayerStatusAccount[ idx ] = SQL_ReadResult( iQuery, SQL_FieldNameToNum( iQuery, "STATUS"));
		xPlayerSlotsInv[ idx ] = SQL_ReadResult( iQuery, SQL_FieldNameToNum( iQuery, "MAX_INVENTARIO_ITENS"));
		//xPlayerUpdateAccount[ idx ] = SQL_ReadResult( iQuery, SQL_FieldNameToNum( iQuery, "CONTA_ATUALIZADA"));
		
		//new iPlayerIPMysQl[ 64 ];
		//SQL_ReadResult( iQuery, SQL_FieldNameToNum( iQuery, "IP"), iPlayerIPMysQl, sizeof( iPlayerIPMysQl ) - 1);
		
		if( !xPlayerStatusAccount[ idx ]){
			server_cmd("kick #%i ^"Sua conta %s esta Banida!^"", get_user_userid( idx ), xPrefix )
			return;
		}
		
		//xPlayerKey[ idx ] = logincheck;
		xPlayerLogado[ idx ] = true;
		xPlayerMenu[idx] = 5;
		
		client_print_color( idx, print_team_default, "^x01 Sua conta pela STEAM-ID: %s, foi carregada com sucesso!", iAuth );
		
		set_hudmessage( random_num( 0, 255 ), random_num(0,255), random_num(0,255), 0.01, 0.15, 2, 1.0, 3.0, 0.1, 5.0, -1);
		ShowSyncHudMsg( idx, g_msgSyncHud, "%L", idx, "A5_MENSAGEM");
		
		ExecuteForward( xPlayerAutenticou, g_DummyResult_f, idx, 0);
	}
	
	else {		
		static iName[ 32 ];
		get_user_name( idx, iName, charsmax( iName ))
		replace_all( iName, charsmax( iName ), "'", "\'");
		
		static iUserIP[ 35 ];
		get_user_ip( idx, iUserIP, charsmax( iUserIP ), 1);
		
		static iDateStr[ 82 ];
		get_time( "%Y.%m.%d", iDateStr, charsmax( iDateStr ));
		
		formatex( szQuery, 499, "INSERT INTO play_registro ( MEMBRO_KEY, LOGIN, PASSWORD, EMAIL, NICK, AUTO_LOGIN, IP, ALISTAMENTO, ULTIMO_LOGIN, PLATAFORMA ) VALUES ('%s', '%s', '%s', '%s', '%s', '1', '%s', '%s', '%s', '1')", iAuth, iAuth, iAuth, iAuth, iName, iUserIP, iDateStr, iDateStr );
		iQuery = SQL_PrepareQuery( connect, szQuery );
	
		//client_cmd( id, "chooseteam");
		
		if( SQL_Execute( iQuery )){
			xPlayerLogado[ idx ] = true;
			
			client_print_color( idx, print_team_default, "^x01 Foi detectado que e a sua primeira vez em nossos servidores.");
			client_print_color( idx, print_team_default, "^x01 Seu cadastro foi realizado altomaticamente atraves de sua STEAM-ID: %s", iAuth );
			
			set_hudmessage( random_num( 0, 255 ), random_num(0,255), random_num(0,255), 0.01, 0.15, 2, 1.0, 3.0, 0.1, 5.0, -1);
			ShowSyncHudMsg( idx, g_msgSyncHud, "%L", idx, "A5_MENSAGEM");
			
			ExecuteForward( xPlayerAutenticou, g_DummyResult_f, idx, 1);
		}
		
		else log_message("Erro ao tentar inserir primeiros dados no play_registro MEMBRO_KEY: %s - ERRO: '%s'", iAuth, error );
	}
	
	SQL_FreeHandle( iQuery );
	SQL_FreeHandle( connect );
}

// Login automatico com base no �ltimo IP utilizado pela conta!
public PerformTheMagic( id ){
	static idx 
	idx = (id - TASK_LOGIN)
	
	mySQLConnect()
	if( gDbConnect == Empty_Handle )
		return false
	
	static sql[320], error[128], auto[64]
	new Handle:query
	new errcode
	new autologin
	
	static iUserIP[ 35 ];
	get_user_ip( idx, iUserIP, charsmax( iUserIP ), 1);
	
	sql[0] = '^0';
	formatex( sql, charsmax( sql ), "SELECT MEMBRO_KEY, LOGIN, PASSWORD, EMAIL, AUTO_LOGIN, MAX_INVENTARIO_ITENS, STATUS FROM play_registro WHERE IP = '%s' AND PLATAFORMA = 2", iUserIP );
	query = SQL_PrepareQuery( gDbConnect, "%s", sql );
	
	if ( !SQL_Execute( query )){
		errcode = SQL_QueryError(query, error, charsmax(error))
		Log("Erro query 1: %s [%d] '%s' - '%s'", iUserIP, errcode, error, sql)
		SQL_FreeHandle(query)
		close_mysql()
		return true;
	}
	
	// N�o encontramos nada...
	if ( !SQL_NumResults( query )){
		SQL_FreeHandle( query );
		xPlayerMenu[idx] = 1
		g_PlayerDigitar[idx] = 0
		MenuPrincipal(idx)
		
		// Fechar a conex�o.
		close_mysql()
		return true;
	}
	
	// Mais de 1 IP encontrado... (bugfix)
	if ( SQL_NumResults(query) > 1 ) {
		SQL_FreeHandle(query)
		xPlayerMenu[idx] = 1
		g_PlayerDigitar[idx] = 0
		MenuPrincipal(idx)
		
		// Fechar a conex�o.
		close_mysql()
		return true;
	}
	
	// Encontrou... continuando
	SQL_ReadResult(query, SQL_FieldNameToNum(query, "LOGIN"), xPlayerUser[idx], sizeof(xPlayerUser) - 1)
	SQL_ReadResult(query, SQL_FieldNameToNum(query, "PASSWORD"), xPlayerPass[idx], sizeof(xPlayerPass) - 1)
	SQL_ReadResult(query, SQL_FieldNameToNum(query, "EMAIL"), xPlayerEmail[idx], sizeof(xPlayerEmail) - 1)
	SQL_ReadResult(query, SQL_FieldNameToNum(query, "AUTO_LOGIN"), auto, sizeof(auto) - 1)
	SQL_ReadResult(query, SQL_FieldNameToNum(query, "MEMBRO_KEY"), xPlayerKey[idx], sizeof(xPlayerKey) - 1)
	//SQL_ReadResult(query, SQL_FieldNameToNum(query, "STEAM_ID"), xPlayerSteam[idx], sizeof(xPlayerSteam) - 1)
	xPlayerStatusAccount[ idx ] = SQL_ReadResult( query, SQL_FieldNameToNum( query, "STATUS"));
	
	SQL_FreeHandle(query);
	close_mysql();
	
	if( !xPlayerStatusAccount[ idx ]){
		server_cmd("kick #%i ^"Sua conta %s esta Banida!^"", get_user_userid( idx ), xPrefix )
		return true;
	}
	
	autologin = str_to_num(auto)
	//logincheck = str_to_num(rid)
	
	// AutoLogin desativado!
	if(autologin == 0){
		xPlayerAutoLogin[idx] = false
		xPlayerMenu[idx] = 1
		g_PlayerDigitar[idx] = 0
		MenuPrincipal(idx)
		return true
	}
	
	//static auth[ 64 ];
	//get_user_key2( id, auth, charsmax( auth ))
	
	// Ja tem alguem conectado nessa conta...
	for (new x = 1; x <= xMaxPlayers; x++) {		
		if(xPlayerConected[x] && xPlayerLogado[x] && equal( xPlayerKey[x], xPlayerKey[idx])){
			client_print( idx, print_chat, "Ja tem alguem conectado com essa key!");
			xPlayerMenu[idx] = 1
			g_PlayerDigitar[idx] = 0
			MenuPrincipal(idx)
			return true
		}
	}

	// verificamos se ja tem steam id nos erver, bug de clonar steam
	/*
	for (new x = 1; x <= xMaxPlayers; x++){
		if(xPlayerConected[x] && xPlayerLogado[x] && equal( xPlayerSteam[x], xPlayerSteam[idx])){
			client_print( idx, print_chat, "Proibido Clonar Steam ID!");
			server_cmd( "kick #%d ^"PROIBIDO CLONAR STEAM-ID^"", get_user_userid( idx ))
			return true
		}
	}
	*/
	
	//xPlayerKey[idx] = logincheck
	//set_string( 2, xPlayerKey[idx], charsmax( xPlayerKey[idx]));
	
	xPlayerLogado[idx] = true
	xPlayerAutoLogin[idx] = true
	
	xPlayerMenu[idx] = 5
	
	/* UPDATE NICK *****************************************/
	mySQLConnect()
	if( gDbConnect == Empty_Handle )
		return false;
	
	static error_t[128]
	new Handle:query_t
	new errcode_t
	
	static iName[ 33 ];
	get_user_name( idx, iName, charsmax( iName ));
	replace_all( iName, charsmax( iName ), "'", "\'");
	
	static sql_t[320]
	sql_t[0] = '^0'	
	formatex( sql_t, charsmax( sql_t ), "UPDATE play_registro SET NICK = '%s' WHERE MEMBRO_KEY = '%s'", iName, xPlayerKey[ idx ])
	query_t = SQL_PrepareQuery( gDbConnect, "%s", sql_t );
	
	if( !SQL_Execute( query_t )){
		errcode_t = SQL_QueryError( query_t, error_t, charsmax( error_t ))
		Log("Erro ao Atualizar Nick no Alto-Login: [%d] '%s' - '%s'", errcode_t, error_t, sql_t )
	}
	
	SQL_FreeHandle( query_t );
	close_mysql()
	/****************************************/
	
	set_hudmessage(random_num(0,255), random_num(0,255), random_num(0,255), 0.01, 0.15, 2, 1.0, 3.0, 0.1, 5.0, -1)
	ShowSyncHudMsg(idx, g_msgSyncHud, "%L", idx, "A4_MENSAGEM")		
	
	// forward carregar xp e nascer
	ExecuteForward(xPlayerAutenticou, g_DummyResult_f, idx, 0)
	client_cmd(idx, "chooseteam")
	return true;
}

public client_putinserver( id ){
	set_task( 1.0, "play_connect_sound", id+TASK_SOUND );
	
	if( 1 < id > xMaxPlayers )
		return;
	
	xPlayerLogado[ id ] = false;
	xPlayerConected[ id ] = true;
	xPlayerNaoQuerRegistrar[ id ] = false;
	xPlayerAutoLogin[ id ] = false;
	xPlayerPediuPraRecuperar[ id ] = false;
	
	xPlayerMenu[ id ] = 0;
	//xPlayerKey[ id ] = 0;
	xPlayerSlotsInv[ id ] = 0;
	xPlayerStatusAccount[ id ] = 0;
	xPlayerTentativas[ id ] = 0;

	set_task( 0.5, "DestroyMenu", id );
	set_task( 1.0, "DestroyMenu", id );
	
	static iAuth[ 32 ];
	get_user_authid( id, iAuth, charsmax( iAuth ));
	
	if( equal( iAuth[ 9 ], "PENDING"))
		server_cmd("kick #%i ^"Entre nogvamente no servidor, vc bugou!^"", get_user_userid( id ));
	
	/*
	if( get_user_flags( id ) & ADMIN_RESERVATION ){
		xNoSxePlayerVip[ id ] = true;
		client_print( id, print_chat, "Voce e VIP, nao precisa de sxe!");
	}
	*/
	
	else if( equal( iAuth[ 9 ], "LAN"))
		xPlayerSTEAM[ id ] = false;
		
	else xPlayerSTEAM[ id ] = true;
	
	/*
	if( xPlayerSTEAM[ id ])
		set_task( 4.0, "CheckSteamAccount", id+TASK_LOGIN );
	
	else set_task( 4.0, "PerformTheMagic", id+TASK_LOGIN);
	*/

	set_task( 1.0, "SetBlackFade", id );
	
	set_task( 4.0, "PerformTheMagic", id+TASK_LOGIN);
}

public SetBlackFade( id ){
	message_begin(MSG_ONE,get_user_msgid("ScreenFade"),{0,0,0},id);
	write_short(~0); // duration, ~0 is max
	write_short(~0); // hold time, ~0 is max
	write_short(1<<12); // flags, no idea wtf 1<<12 is
	write_byte(0); // red, 0 for black
	write_byte(0); // green, 0 for black
	write_byte(0); // blue, 0 for black
	write_byte(200); // alpha, 255 for total black
	message_end();
	
	set_task( 15.0, "SetBlackFade", id, _, _, "b")
	//set_task( 15.0, "SetBlackFade", id );
}

public DestroyMenu( id )
	show_menu( id, 0, "^n", 1 );

public play_connect_sound( task ){
	new id = task - TASK_SOUND;
	
	new iTime; iTime = get_user_time( id, 0);
	if( iTime <= 0 ){
		set_task( 1.0, "play_connect_sound", iTime );
	}
	
	else {
		new i = random( MAX_SOUNDS );
		PlaySound( id, sounds_registro[ i ]);
		client_cmd( id, "spk ^"%s^"", sounds_registro[i])
	}
	
	return PLUGIN_CONTINUE
}

public client_disconnected( id ){
	if( 1 < id > xMaxPlayers )
		return;
	
	xPlayerLogado[ id ] = false;
	xPlayerSTEAM[ id ] = false;
	xPlayerConected[ id ] = false;
	xPlayerNaoQuerRegistrar[ id ] = false;
	
	xPlayerMenu[ id ] = 0;
	//xPlayerKey[ id ] = 0;
	xPlayerSlotsInv[ id ] = 0;
	
	if( task_exists( id+TASK_LOGIN ))
		remove_task( id+TASK_LOGIN );
}

public MenuPrincipal( id ){
	ClearSyncHud( id, xMSGSync[ MENU_ITEM1 ]);
	ClearSyncHud( id, xMSGSync[ MENU_ITEM2 ]);
	ClearSyncHud( id, xMSGSync[ MENU_TITLE ]);
	ClearSyncHud( id, xMSGSync[ MENU_NUMBERS ]);
	
	new Float: iMenuPos[ 2 ];
	iMenuPos[ 0 ] = 0.02 * 100.0 / 100.0;
	iMenuPos[ 1 ] = 0.46 * 100.0 / 100.0;
	
	set_hudmessage( 255, 162, 0, iMenuPos[ 0 ], iMenuPos[ 1 ], 0, 6.0, 999.0 );	
	ShowSyncHudMsg( id, xMSGSync[ MENU_TITLE ], "Registro de Contas:" );
	
	set_hudmessage( 255, 162, 0, iMenuPos[ 0 ], iMenuPos[ 1 ], 0, 6.0, 999.0 );	
	ShowSyncHudMsg( id, xMSGSync[ MENU_NUMBERS ], "^n^n^n1.^n^n^n2.^n^n^n3." );
	
	set_hudmessage( 14, 52, 222, iMenuPos[ 0 ], iMenuPos[ 1 ], 0, 6.0, 999.0 );	
	ShowSyncHudMsg( id, xMSGSync[ MENU_ITEM1 ], "^n^n^n    Entrar^n^n^n    Registrar-se^n^n^n    Ajuda" );
	
	set_hudmessage( 17, 99, 255, iMenuPos[ 0 ], iMenuPos[ 1 ], 0, 6.0, 999.0 );	
	ShowSyncHudMsg( id, xMSGSync[ MENU_ITEM2 ], "^n^n^n^n( Acessar sua conta para caregar seus dados )^n^n^n( Registrar uma nova conta )^n^n^n( Esqueci minha senha )" );
	
	show_menu( id, KEYSPRINCIPAL, " ", -1, "Menu Principal");
}

public PrincipalHandle( id, key ){
	ClearSyncHud( id, xMSGSync[ MENU_ITEM1 ]);
	ClearSyncHud( id, xMSGSync[ MENU_ITEM2 ]);
	ClearSyncHud( id, xMSGSync[ MENU_TITLE ]);
	ClearSyncHud( id, xMSGSync[ MENU_NUMBERS ]);
	
	switch( key ){
		case 0: {
			return PLUGIN_HANDLED;
		}
		
		case 1: {
			MenuLoginF( id );
		}
		
		case 2: {
		}
	}
	
	return PLUGIN_HANDLED;
}

public MenuLoginF( id ){
	static menu[512], len
	len = 0	
	
	
	len += formatex(menu[len], charsmax(menu) - len, "\d %s^n %s - Fazendo seu Login^n %s^n^n", xMenuLine, xPrefix, xMenuLine )
			// T�tulo
			//len += formatex(menu[len], charsmax(menu) - len, "%L", id, "M16_MENSAGEM")	
			
	switch(g_PlayerDigitar[id])
	{
		case 0:
		{
			len += formatex(menu[len], charsmax(menu) - len, "%L", id, "M17_MENSAGEM")
		}
				case 1:
				{
					len += formatex(menu[len], charsmax(menu) - len, "%L", id, "M18_MENSAGEM")
				}
				case 2:
				{
					len += formatex(menu[len], charsmax(menu) - len, "%L", id, "M19_MENSAGEM")
					set_hudmessage(random_num(0,255), random_num(0,255), random_num(0,255), 0.01, 0.15, 2, 1.0, 3.0, 0.1, 5.0, -1)
					ShowSyncHudMsg(id, g_msgSyncHud, "%L", id, "A7_MENSAGEM")
				}				
			}
	
	// Detalhes
	switch(g_PlayerDigitar[id])
	{
		case 0:
		{
			len += formatex(menu[len], charsmax(menu) - len, "%L", id, "M20_MENSAGEM")
		}
		case 1:
		{
			len += formatex(menu[len], charsmax(menu) - len, "%L", id, "M21_MENSAGEM", g_Menu2LoginDigitado[id])
		}
		case 2:
		{
			len += formatex(menu[len], charsmax(menu) - len, "%L", id, "M22_MENSAGEM", g_Menu2LoginDigitado[id], g_Menu2SenhaDigitada[id])
		}				
	}
	
	// Op��es
	if(g_PlayerDigitar[id] == 0)
	{
		len += formatex(menu[len], charsmax(menu) - len, "%L", id, "M23_MENSAGEM")
	}			
	
	if(g_PlayerDigitar[id] > 0)
	{
		len += formatex(menu[len], charsmax(menu) - len, "%L", id, "M24_MENSAGEM")
	}
	
	if(g_PlayerDigitar[id] > 1)
	{
		len += formatex(menu[len], charsmax(menu) - len, "%L", id, "M25_MENSAGEM")
	}
	
	len += formatex(menu[len], charsmax(menu) - len, "^n\r4.\w %L", id, "M15_MENSAGEM")
	
	len += formatex(menu[len], charsmax(menu) - len, "\d %s", xMenuLine )			
	
	show_menu( id, KEYSPRINCIPAL, menu, -1, "Menu Login")
}

public MenuLoginHandler( id, key ){
	switch( key ){
		case 0: {
			return PLUGIN_HANDLED;
		}
		
		case 1: {
		}
		
		case 2: {
		}
	}
	
	return PLUGIN_HANDLED;
}



				
public MenuPrincipal2(id)
{
	static menu[512], len
	len = 0	
	
	switch(xPlayerMenu[id])
	{
		case 0:
		{
			return PLUGIN_HANDLED;
		}
		case 1: // Acabou de entrar no servidor. N�o confirmou Login ainda.
		{	
			len += formatex(menu[len], charsmax(menu) - len, "\d %s^n %s Registro de Contas^n %s^n%s^n^n", xMenuLine, xPrefix, xWebSite, xMenuLine )
			// T�tulo
			//len += formatex(menu[len], charsmax(menu) - len, "%L", id, "M1_MENSAGEM")
			
			// Op��es
			len += formatex(menu[len], charsmax(menu) - len, "%L", id, "M2_MENSAGEM")
			len += formatex(menu[len], charsmax(menu) - len, "%L", id, "M3_MENSAGEM")
			
			len += formatex(menu[len], charsmax(menu) - len, "%L", id, "M4_MENSAGEM")
			len += formatex(menu[len], charsmax(menu) - len, "%L", id, "M5_MENSAGEM")
			
			len += formatex(menu[len], charsmax(menu) - len, "%L", id, "M6_MENSAGEM")
			len += formatex(menu[len], charsmax(menu) - len, "%L", id, "M7_MENSAGEM")
			
			//len += formatex(menu[len], charsmax(menu) - len, "%L", id, "M8_MENSAGEM")
			//len += formatex(menu[len], charsmax(menu) - len, "%L", id, "M9_MENSAGEM")
			
			len += formatex(menu[len], charsmax(menu) - len, "\d %s", xMenuLine )
			//set_hudmessage(random_num(0,255), random_num(0,255), random_num(0,255), 0.01, 0.15, 2, 1.0, 3.0, 0.1, 5.0, -1)
			//ShowSyncHudMsg(id, g_msgSyncHud, "%L", id, "A5_MENSAGEM")
			
			show_menu(id, KEYSPRINCIPAL, menu, -1, "Menu Principal")
		}
		case 2: // Menu de Login
		{
			/*
			if(g_Compatibilidade[id])
			{		
				len += formatex(menu[len], charsmax(menu) - len, "\d %s^n %s Registro de Contas^n %s^n%s^n^n", xMenuLine, xPrefix, xWebSite, xMenuLine )
				// T�tulo
				//len += formatex(menu[len], charsmax(menu) - len, "%L", id, "M1_MENSAGEM")
				
				// Op��es
				len += formatex(menu[len], charsmax(menu) - len, "%L", id, "M10_MENSAGEM")
				len += formatex(menu[len], charsmax(menu) - len, "%L", id, "M11_MENSAGEM")
				
				len += formatex(menu[len], charsmax(menu) - len, "%L", id, "M12_MENSAGEM")
				len += formatex(menu[len], charsmax(menu) - len, "%L", id, "M13_MENSAGEM")
				
				len += formatex(menu[len], charsmax(menu) - len, "%L", id, "M14_MENSAGEM")
				
				len += formatex(menu[len], charsmax(menu) - len, "\r0.\w %L", id, "M15_MENSAGEM")
				
				len += formatex(menu[len], charsmax(menu) - len, "\d %s", xMenuLine )
				
				set_hudmessage(random_num(0,255), random_num(0,255), random_num(0,255), 0.01, 0.15, 2, 1.0, 3.0, 0.1, 5.0, -1)
				ShowSyncHudMsg(id, g_msgSyncHud, "%L", id, "A6_MENSAGEM")
				
				show_menu(id, KEYSUNICA, menu, -1, "Menu Principal")
				return PLUGIN_HANDLED;
			}
			*/
		
			len += formatex(menu[len], charsmax(menu) - len, "\d %s^n %s - Fazendo seu Login^n %s^n^n", xMenuLine, xPrefix, xMenuLine )
			// T�tulo
			//len += formatex(menu[len], charsmax(menu) - len, "%L", id, "M16_MENSAGEM")	
			
			switch(g_PlayerDigitar[id])
			{
				case 0:
				{
					len += formatex(menu[len], charsmax(menu) - len, "%L", id, "M17_MENSAGEM")
				}
				case 1:
				{
					len += formatex(menu[len], charsmax(menu) - len, "%L", id, "M18_MENSAGEM")
				}
				case 2:
				{
					len += formatex(menu[len], charsmax(menu) - len, "%L", id, "M19_MENSAGEM")
					set_hudmessage(random_num(0,255), random_num(0,255), random_num(0,255), 0.01, 0.15, 2, 1.0, 3.0, 0.1, 5.0, -1)
					ShowSyncHudMsg(id, g_msgSyncHud, "%L", id, "A7_MENSAGEM")
				}				
			}
			
			// Detalhes
			switch(g_PlayerDigitar[id])
			{
				case 0:
				{
					len += formatex(menu[len], charsmax(menu) - len, "%L", id, "M20_MENSAGEM")
				}
				case 1:
				{
					len += formatex(menu[len], charsmax(menu) - len, "%L", id, "M21_MENSAGEM", g_Menu2LoginDigitado[id])
				}
				case 2:
				{
					len += formatex(menu[len], charsmax(menu) - len, "%L", id, "M22_MENSAGEM", g_Menu2LoginDigitado[id], g_Menu2SenhaDigitada[id])
				}				
			}
			
			// Op��es
			if(g_PlayerDigitar[id] == 0)
			{
				len += formatex(menu[len], charsmax(menu) - len, "%L", id, "M23_MENSAGEM")
			}			
			
			if(g_PlayerDigitar[id] > 0)
			{
				len += formatex(menu[len], charsmax(menu) - len, "%L", id, "M24_MENSAGEM")
			}
			
			if(g_PlayerDigitar[id] > 1)
			{
				len += formatex(menu[len], charsmax(menu) - len, "%L", id, "M25_MENSAGEM")
			}
			
			len += formatex(menu[len], charsmax(menu) - len, "^n\r4.\w %L", id, "M15_MENSAGEM")
			
			len += formatex(menu[len], charsmax(menu) - len, "\d %s", xMenuLine )			
			
			show_menu(id, KEYSPRINCIPAL, menu, -1, "Menu Principal")
		}
		case 3: // Menu de Registro
		{	
			len += formatex(menu[len], charsmax(menu) - len, "\d %s^n %s - Criando uma Nova Conta^n %s^n^n", xMenuLine, xPrefix, xMenuLine )
			// T�tulo
			//len += formatex(menu[len], charsmax(menu) - len, "%L", id, "M26_MENSAGEM")
			
			switch(g_PlayerDigitar[id])
			{
				case 0:
				{
					len += formatex(menu[len], charsmax(menu) - len, "%L", id, "M27_MENSAGEM")
				}
				case 1:
				{
					len += formatex(menu[len], charsmax(menu) - len, "%L", id, "M28_MENSAGEM")
				}
				case 2:
				{
					len += formatex(menu[len], charsmax(menu) - len, "%L", id, "M29_MENSAGEM")
				}
				case 3:
				{
					len += formatex(menu[len], charsmax(menu) - len, "%L", id, "M30_MENSAGEM")
					set_hudmessage(random_num(0,255), random_num(0,255), random_num(0,255), 0.01, 0.15, 2, 1.0, 3.0, 0.1, 5.0, -1)
					ShowSyncHudMsg(id, g_msgSyncHud, "%L", id, "A7_MENSAGEM")
				}				
			}
			
			// Detalhes
			switch(g_PlayerDigitar[id])
			{
				case 0:
				{
					len += formatex(menu[len], charsmax(menu) - len, "%L", id, "M31_MENSAGEM")
				}
				case 1:
				{
					len += formatex(menu[len], charsmax(menu) - len, "%L", id, "M32_MENSAGEM", g_Menu3LoginDigitado[id])
				}
				case 2:
				{
					len += formatex(menu[len], charsmax(menu) - len, "%L", id, "M33_MENSAGEM", g_Menu3LoginDigitado[id], g_Menu3SenhaDigitada[id])
				}
				case 3:
				{
					len += formatex(menu[len], charsmax(menu) - len, "%L", id, "M34_MENSAGEM", g_Menu3LoginDigitado[id], g_Menu3SenhaDigitada[id], g_Menu3EmailDigitado[id])
				}				
			}
			
			// Op��es
			if(g_PlayerDigitar[id] == 0)
			{
				len += formatex(menu[len], charsmax(menu) - len, "%L", id, "M35_MENSAGEM")
			}
			
			if(g_PlayerDigitar[id] > 0)
			{
				len += formatex(menu[len], charsmax(menu) - len, "%L", id, "M36_MENSAGEM")
			}
			
			if(g_PlayerDigitar[id] > 1)
			{
				len += formatex(menu[len], charsmax(menu) - len, "%L", id, "M37_MENSAGEM")
			}
			
			if(g_PlayerDigitar[id] > 2)
			{
				len += formatex(menu[len], charsmax(menu) - len, "%L", id, "M38_MENSAGEM")
			}
			
			len += formatex(menu[len], charsmax(menu) - len, "^n\r5.\w %L", id, "M15_MENSAGEM")
			
			len += formatex(menu[len], charsmax(menu) - len, "\d %s", xMenuLine )
			
			show_menu(id, KEYSREGISTRO, menu, -1, "Menu Principal")
		}
		case 4: // Trocar minha senha
		{
			len += formatex(menu[len], charsmax(menu) - len, "\d %s^n %s - Trocando sua Senha^n %s^n^n", xMenuLine, xPrefix, xMenuLine )
			// T�tulo
			//len += formatex(menu[len], charsmax(menu) - len, "%L", id, "M39_MENSAGEM")
			
			switch(g_PlayerDigitar[id])
			{
				case 0:
				{
					len += formatex(menu[len], charsmax(menu) - len, "%L", id, "M40_MENSAGEM")
				}
				case 1:
				{
					len += formatex(menu[len], charsmax(menu) - len, "%L", id, "M41_MENSAGEM")
				}
				case 2:
				{
					len += formatex(menu[len], charsmax(menu) - len, "%L", id, "M42_MENSAGEM")
					set_hudmessage(random_num(0,255), random_num(0,255), random_num(0,255), 0.01, 0.15, 2, 1.0, 3.0, 0.1, 5.0, -1)
					ShowSyncHudMsg(id, g_msgSyncHud, "%L", id, "A7_MENSAGEM")
				}				
			}
			
			// Detalhes
			switch(g_PlayerDigitar[id])
			{
				case 0:
				{
					len += formatex(menu[len], charsmax(menu) - len, "%L", id, "M43_MENSAGEM")
				}
				case 1:
				{
					len += formatex(menu[len], charsmax(menu) - len, "%L", id, "M44_MENSAGEM", xPlayerPass[id])
				}
				case 2:
				{
					len += formatex(menu[len], charsmax(menu) - len, "%L", id, "M45_MENSAGEM", xPlayerPass[id], xPlayerMenuPassNova[id])
				}				
			}
			
			// Op��es
			if(g_PlayerDigitar[id] == 0)
				len += formatex(menu[len], charsmax(menu) - len, "%L", id, "M46_MENSAGEM")
			
			if(g_PlayerDigitar[id] > 0)
				len += formatex(menu[len], charsmax(menu) - len, "%L", id, "M47_MENSAGEM")
			
			if(g_PlayerDigitar[id] > 1)
				len += formatex(menu[len], charsmax(menu) - len, "%L", id, "M48_MENSAGEM")
			
			len += formatex(menu[len], charsmax(menu) - len, "\r4.\w %L", id, "M15_MENSAGEM")
			
			len += formatex(menu[len], charsmax(menu) - len, "\d %s", xMenuLine )
			
			show_menu(id, KEYSPRINCIPAL, menu, -1, "Menu Principal")
		}
		
		/** REGISTRADO E LOGADO, INFORMA��ES DA CONTA ****/
		case 5: {
			/** TITULO **/
			len += formatex( menu[ len ], charsmax( menu ) - len, "\d%s^n", xMenuLine );
			len += formatex( menu[ len ], charsmax( menu ) - len, "%s - Detalhes da Conta:^n", xPrefix );
			len += formatex( menu[ len ], charsmax( menu ) - len, "\d%s^n^n", xMenuLine );
			
			/*
			if( xPlayerSTEAM[ id ]){
				static iAuth[ 32 ];
				get_user_authid( id, iAuth, charsmax( iAuth ));
				
				// DETALHES DA CONTA STEAM
				len += formatex( menu[ len ], charsmax( menu ) - len, "\r» \wKeyID: \y%s^n\r» \wVIP: %s^n^n", iAuth, is_user_admin( id ) ? "\y[SIM]": "\r[NAO]")
				//len += formatex(menu[len], charsmax(menu) - len, "\wCash: \r%d^n^n", xPlayerCash[ id ])
				//len += formatex(menu[len], charsmax(menu) - len, "\wSlots Inventario: \r%d^n^n", native_get_max_item( id ))
			}
			
			else {
			*/
			
				/** DETALHES DA CONTA NO-STEAM **/
			len += formatex( menu[ len ], charsmax( menu ) - len, "\r» \wLogin: \y%s^n\r» \wKeyID:\y %s^n\r» \wVIP: %s^n^n", xPlayerUser[ id ], xPlayerKey[ id ], is_user_admin( id ) ? "\y[SIM]": "\r[NAO]")
				//len += formatex(menu[len], charsmax(menu) - len, "\wCash: \r%d^n^n", xPlayerCash[ id ])
				//len += formatex(menu[len], charsmax(menu) - len, "\wSlots Inventario: \r%d^n^n", native_get_max_item( id ))
				
				/** OP��ES DA CONTA **/
			len += formatex(menu[len], charsmax(menu) - len, "\r1.\w Alterar Minha Senha^n");	
				
			if( xPlayerAutoLogin[ id ])
				len += formatex(menu[len], charsmax(menu) - len, "\r2.\w Desativar AutoLogin por IP^n^n");
				
			else len += formatex(menu[len], charsmax(menu) - len, "\r2.\w Ativar AutoLogin por IP^n^n");
				
				//len += formatex(menu[len], charsmax(menu) - len, "\r3.\y Mudar Conta Para STEAM^n^n");
			
			//}
	
			len += formatex(menu[len], charsmax(menu) - len, "\r0.\w Sair^n^n");
			
			len += formatex(menu[len], charsmax(menu) - len, "\d%s^n", xMenuLine );
			len += formatex(menu[len], charsmax(menu) - len, "\d%s^n", xWebSite );
			len += formatex(menu[len], charsmax(menu) - len, "\d%s", xMenuLine );
			
			show_menu( id, KEYS3, menu, -1, "Menu Principal")
		}		
	}
	
	return PLUGIN_HANDLED;
}


public PrincipalHandle2(id, key)
{
	switch(xPlayerMenu[id])
	{
		case 0:
		{
			return PLUGIN_HANDLED;
		}
		case 1:
		{
			switch(key)
			{
				case 0: // Ja tenho uma conta
				{
					xPlayerMenu[id] = 2
					g_PlayerDigitar[id] = 0
					MenuPrincipal(id)
					return PLUGIN_HANDLED;
				}
				case 1: // Quero me registrar
				{
					/*
					if(g_Compatibilidade[id])
					{
						MenuPrincipal(id)
						PrintRegistro(id, "^1 %L", id, "A8_MENSAGEM")
						return PLUGIN_HANDLED;
					}
					*/
					
					xPlayerMenu[id] = 3
					g_PlayerDigitar[id] = 0
					MenuPrincipal(id)
					return PLUGIN_HANDLED;
				}
				case 2: // Esqueci minha senha...
				{
					client_cmd(id, "messagemode DIGITE_SEU_EMAIL")
					PrintRegistro(id, "^1 Digite o e-mail da sua conta!")
					set_hudmessage(random_num(0,255), random_num(0,255), random_num(0,255), 0.01, 0.15, 2, 1.0, 3.0, 0.1, 5.0, -1)
					ShowSyncHudMsg(id, g_msgSyncHud, "Digite o e-mail da sua conta")					
					MenuPrincipal(id)
				}
				
				case 3: // Nao quero me registrar
				{	
					MenuPrincipal(id)
					return PLUGIN_HANDLED;
				
					/*
					if(g_Compatibilidade[id])
					{
						MenuPrincipal(id)
						PrintRegistro(id, "^1 %L", id, "A8_MENSAGEM")
						return PLUGIN_HANDLED;
					}
					
					xPlayerNaoQuerRegistrar[id] = true
					xPlayerMenu[id] = 0
					xPlayerKey[id] = 0
					
					if(xPlayerSTEAM[id])
					{
						get_user_authid(id, xPlayerUser[id], charsmax(xPlayerUser[]))
					}
					else
					{
						get_user_name(id, xPlayerUser[id], charsmax(xPlayerUser[]))
					}
					
					client_cmd(id, "chooseteam")
					
					PrintRegistro(id, "^1 %L", id, "A9_MENSAGEM")
					
					if(xPlayerSTEAM[id])
					{
						PrintRegistro(id, "^1 %L", id, "A10_MENSAGEM")
					}
					else PrintRegistro(id, "^1 %L", id, "A11_MENSAGEM")
					
					ExecuteForward(xPlayerAutenticou, g_DummyResult_f, id, 0)
					*/
				}
				
			}
		}
		case 2:
		{
			/*
			if(g_Compatibilidade[id])
			{
				xPlayerMenu[id] = 1
				MenuPrincipal(id)
				return PLUGIN_HANDLED;
			}
			*/
			
			switch(key)
			{
				case 0: // Digitar meu login
				{
					if(g_PlayerDigitar[id] == 0)
					{
						client_cmd(id, "messagemode DIGITE_SEU_LOGIN")
						PrintRegistro(id, "^1 %L", id, "A12_MENSAGEM")
						set_hudmessage(random_num(0,255), random_num(0,255), random_num(0,255), 0.01, 0.15, 2, 1.0, 3.0, 0.1, 5.0, -1)
						ShowSyncHudMsg(id, g_msgSyncHud, "%L", id, "A12_MENSAGEM")
						MenuPrincipal(id)
					}
					else
					{
						g_PlayerDigitar[id] = 0
						
						client_cmd(id, "messagemode DIGITE_SEU_LOGIN")
						PrintRegistro(id, "^1 %L", id, "A12_MENSAGEM")
						set_hudmessage(random_num(0,255), random_num(0,255), random_num(0,255), 0.01, 0.15, 2, 1.0, 3.0, 0.1, 5.0, -1)
						ShowSyncHudMsg(id, g_msgSyncHud, "%L", id, "A12_MENSAGEM")
						MenuPrincipal(id)
					}					
				}
				case 1: // Digitar minha senha
				{
					if(g_PlayerDigitar[id] == 1)
					{
						client_cmd(id, "messagemode DIGITE_SUA_SENHA")
						PrintRegistro(id, "^1 %L", id, "A13_MENSAGEM")
						set_hudmessage(random_num(0,255), random_num(0,255), random_num(0,255), 0.01, 0.15, 2, 1.0, 3.0, 0.1, 5.0, -1)
						ShowSyncHudMsg(id, g_msgSyncHud, "%L", id, "A13_MENSAGEM")
						MenuPrincipal(id)
					}
					else if(g_PlayerDigitar[id] == 2)
					{
						g_PlayerDigitar[id] = 1
						
						client_cmd(id, "messagemode DIGITE_SUA_SENHA")
						PrintRegistro(id, "^1 %L", id, "A13_MENSAGEM")
						set_hudmessage(random_num(0,255), random_num(0,255), random_num(0,255), 0.01, 0.15, 2, 1.0, 3.0, 0.1, 5.0, -1)
						ShowSyncHudMsg(id, g_msgSyncHud, "%L", id, "A13_MENSAGEM")
						MenuPrincipal(id)
					}
					else
					{
						MenuPrincipal(id)
						return PLUGIN_HANDLED;
					}					
				}
				case 2: // Confirmar
				{
					if(g_PlayerDigitar[id] == 2)
					{
						ConfirmarLogin(id)
					}
					else
					{
						MenuPrincipal(id)
						return PLUGIN_HANDLED;
					}
				}
				case 3: // Voltar (Menu Principal 1)
				{
					xPlayerMenu[id] = 1
					MenuPrincipal(id)
					return PLUGIN_HANDLED;
				}
			}
		}
		case 3:
		{
			switch(key)
			{
				case 0: // Digitar meu login
				{
					if(g_PlayerDigitar[id] == 0)
					{
						client_cmd(id, "messagemode DIGITE_SEU_LOGIN")
						PrintRegistro(id, "^1 %L", id, "A14_MENSAGEM")
						set_hudmessage(random_num(0,255), random_num(0,255), random_num(0,255), 0.01, 0.15, 2, 1.0, 3.0, 0.1, 5.0, -1)
						ShowSyncHudMsg(id, g_msgSyncHud, "%L", id, "A14_MENSAGEM")
						MenuPrincipal(id)
					}
					else
					{
						g_PlayerDigitar[id] = 0
						
						client_cmd(id, "messagemode DIGITE_SEU_LOGIN")
						PrintRegistro(id, "^1 %L", id, "A14_MENSAGEM")
						set_hudmessage(random_num(0,255), random_num(0,255), random_num(0,255), 0.01, 0.15, 2, 1.0, 3.0, 0.1, 5.0, -1)
						ShowSyncHudMsg(id, g_msgSyncHud, "%L", id, "A14_MENSAGEM")
						MenuPrincipal(id)
					}					
				}
				case 1: // Digitar minha senha
				{
					if(g_PlayerDigitar[id] == 1)
					{
						client_cmd(id, "messagemode DIGITE_SUA_SENHA")
						PrintRegistro(id, "^1 %L", id, "A15_MENSAGEM")
						set_hudmessage(random_num(0,255), random_num(0,255), random_num(0,255), 0.01, 0.15, 2, 1.0, 3.0, 0.1, 5.0, -1)
						ShowSyncHudMsg(id, g_msgSyncHud, "%L", id, "A15_MENSAGEM")
						MenuPrincipal(id)
					}
					else if(g_PlayerDigitar[id] == 0)
					{
						MenuPrincipal(id)
						return PLUGIN_HANDLED;
					}
					else
					{
						g_PlayerDigitar[id] = 1
						
						client_cmd(id, "messagemode DIGITE_SUA_SENHA")
						PrintRegistro(id, "^1 %L", id, "A15_MENSAGEM")
						set_hudmessage(random_num(0,255), random_num(0,255), random_num(0,255), 0.01, 0.15, 2, 1.0, 3.0, 0.1, 5.0, -1)
						ShowSyncHudMsg(id, g_msgSyncHud, "%L", id, "A15_MENSAGEM")
						MenuPrincipal(id)
					}
				}
				case 2: // Digitar meu e-mail
				{
					if(g_PlayerDigitar[id] == 2)
					{
						client_cmd(id, "messagemode DIGITE_SEU_EMAIL")
						PrintRegistro(id, "^1 %L", id, "A16_MENSAGEM")
						set_hudmessage(random_num(0,255), random_num(0,255), random_num(0,255), 0.01, 0.15, 2, 1.0, 3.0, 0.1, 5.0, -1)
						ShowSyncHudMsg(id, g_msgSyncHud, "%L", id, "A16_MENSAGEM")						
						MenuPrincipal(id)
					}
					else if(g_PlayerDigitar[id] == 0 || g_PlayerDigitar[id] == 1)
					{
						MenuPrincipal(id)
						return PLUGIN_HANDLED;
					}
					else
					{
						g_PlayerDigitar[id] = 2
						
						client_cmd(id, "messagemode DIGITE_SEU_EMAIL")
						PrintRegistro(id, "^1 %L", id, "A16_MENSAGEM")
						set_hudmessage(random_num(0,255), random_num(0,255), random_num(0,255), 0.01, 0.15, 2, 1.0, 3.0, 0.1, 5.0, -1)
						ShowSyncHudMsg(id, g_msgSyncHud, "%L", id, "A16_MENSAGEM")
						MenuPrincipal(id)
					}
				}
				case 3: // Confirmar
				{
					if(g_PlayerDigitar[id] == 3)
					{
						ConfirmarRegistro(id)
					}
					else
					{
						MenuPrincipal(id)
						return PLUGIN_HANDLED;
					}
				}
				case 4: // Voltar (Menu Principal 1)
				{
					xPlayerMenu[id] = 1
					MenuPrincipal(id)
					return PLUGIN_HANDLED;
				}				
			}
		}
		case 4:
		{
			switch(key)
			{
				case 0: // Digitar senha antiga
				{
					if(g_PlayerDigitar[id] == 0)
					{
						client_cmd(id, "messagemode DIGITE_SUA_SENHA")
						PrintRegistro(id, "^1 %L", id, "A15X_MENSAGEM")
						set_hudmessage(random_num(0,255), random_num(0,255), random_num(0,255), 0.01, 0.15, 2, 1.0, 3.0, 0.1, 5.0, -1)
						ShowSyncHudMsg(id, g_msgSyncHud, "%L", id, "A15X_MENSAGEM")
						MenuPrincipal(id)
					}
					else
					{
						g_PlayerDigitar[id] = 0
						
						client_cmd(id, "messagemode DIGITE_SUA_SENHA")
						PrintRegistro(id, "^1 %L", id, "A15X_MENSAGEM")
						set_hudmessage(random_num(0,255), random_num(0,255), random_num(0,255), 0.01, 0.15, 2, 1.0, 3.0, 0.1, 5.0, -1)
						ShowSyncHudMsg(id, g_msgSyncHud, "%L", id, "A15X_MENSAGEM")
						MenuPrincipal(id)
					}
				}
				case 1: // Digitar senha nova
				{
					if(g_PlayerDigitar[id] == 1)
					{
						client_cmd(id, "messagemode DIGITE_SUA_SENHA")
						PrintRegistro(id, "^1 %L", id, "A16X_MENSAGEM")
						set_hudmessage(random_num(0,255), random_num(0,255), random_num(0,255), 0.01, 0.15, 2, 1.0, 3.0, 0.1, 5.0, -1)
						ShowSyncHudMsg(id, g_msgSyncHud, "%L", id, "A16X_MENSAGEM")
						MenuPrincipal(id)
					}
					else if(g_PlayerDigitar[id] == 2)
					{
						g_PlayerDigitar[id] = 1
						
						client_cmd(id, "messagemode DIGITE_SUA_SENHA")
						PrintRegistro(id, "^1 %L", id, "A16X_MENSAGEM")
						set_hudmessage(random_num(0,255), random_num(0,255), random_num(0,255), 0.01, 0.15, 2, 1.0, 3.0, 0.1, 5.0, -1)
						ShowSyncHudMsg(id, g_msgSyncHud, "%L", id, "A16X_MENSAGEM")
						MenuPrincipal(id)
					}
					else
					{
						MenuPrincipal(id)
						return PLUGIN_HANDLED;
					}
				}
				case 2: // Confirmar
				{
					if(g_PlayerDigitar[id] == 2)
					{
						TrocarSenha(id)
					}
					else
					{
						MenuPrincipal(id)
						return PLUGIN_HANDLED;
					}
				}
				case 3: // Voltar ( Menu Principal 5)
				{
					xPlayerMenu[id] = 5
					MenuPrincipal(id)
					return PLUGIN_HANDLED;
				}
			}
		}
		
		/** MENU DE OP��ES DE CONTA **/
		case 5:{
			//if( !xPlayerSTEAM[ id ]){
				switch( key ){
					/** ALTERAR SENHA **/
					case 0:{
						xPlayerMenu[id] = 4
						g_PlayerDigitar[id] = 0
						MenuPrincipal(id)
						return PLUGIN_HANDLED;
					}
					
					/** ATIVAR / DESATIVAR AUTO LOGIN POR IP **/
					case 1: {
						mySQLConnect()
						if ( gDbConnect == Empty_Handle )
							return PLUGIN_HANDLED;
							
						static sql[320], playerip[35]
						new Handle:query
							
						get_user_ip(id, playerip, 34, 1)
							
						sql[0] = '^0'
							
						if(xPlayerAutoLogin[id])
							formatex(sql, charsmax(sql), "UPDATE play_registro SET AUTO_LOGIN = '0' WHERE MEMBRO_KEY = '%s'", xPlayerKey[id])
						
						else formatex(sql, charsmax(sql), "UPDATE play_registro SET AUTO_LOGIN = '1', IP = '%s' WHERE MEMBRO_KEY = '%s'", playerip, xPlayerKey[id])
							
						query = SQL_PrepareQuery(gDbConnect, "%s", sql)
							
						if ( SQL_Execute(query)){
							if(xPlayerAutoLogin[id]){
								xPlayerAutoLogin[id] = false
								PrintRegistro(id, "^1 %L", id, "A20_MENSAGEM")
							}
							
							else{
								xPlayerAutoLogin[id] = true
								PrintRegistro(id, "^1 %L", id, "A21_MENSAGEM")
							}
						}
							
						SQL_FreeHandle(query)
						close_mysql()
					}
					
					/** MUDAR CONTA PARA STEAM *
					case 2: {
						mySQLConnect();
						
						if( gDbConnect == Empty_Handle )
							return PLUGIN_HANDLED;
						
						static sql[ 320 ];
						new Handle:query;
						
						new iUserIP[ 35 ];
						get_user_ip( id, iUserIP, charsmax( iUserIP ), 1)
						
						sql[0] = '^0'
						formatex( sql, charsmax( sql ), "UPDATE play_registro SET PLATAFORMA = '0', IP = '%s' WHERE MEMBRO_KEY = '%s'", iUserIP, xPlayerKey[ id ])
						query = SQL_PrepareQuery( gDbConnect, "%s", sql );
						
						if( SQL_Execute( query ))
							server_cmd("kick #%i ^"%s - Feche seu CS No-STEAM, e abra seu STEAM, e entre novamente!^"", get_user_userid( id ), xPrefix );
						
						SQL_FreeHandle( query );
						close_mysql();
					}
					**/
				}
			//}
		}		
	}
	
	return PLUGIN_HANDLED;
}

mySQLConnect() {
	if ( gDbConnect ) {
		if ( !get_pcvar_num(registro_mysql_persistent) && !gPersistentTemp ) close_mysql()
		else return
	}
	
	if ( !gDbTuple ) {
		SQL_SetAffinity("mysql")
		#include "play4ever.inc/play_conecta.play"
	}
	
	// Attempt to connect
	static error[128]
	new errcode
	if ( gDbTuple ) gDbConnect = SQL_Connect(gDbTuple, errcode, error, charsmax(error))
	
	if ( gDbConnect == Empty_Handle ) {
		Log("MySQL connect error: [%d] '%s'", errcode, error)
		// Free the tuple on a connection error
		SQL_FreeHandle(gDbTuple)
		gDbTuple = Empty_Handle
		return
	}
}

close_mysql() {
	if ( gDbConnect == Empty_Handle || get_pcvar_num(registro_mysql_persistent) || gPersistentTemp ) return
	
	SQL_FreeHandle(gDbConnect)
	gDbConnect = Empty_Handle
}

Log(const message_fmt[], any:...) {
	static message[256];
	vformat(message, sizeof(message) - 1, message_fmt, 2);
	
	static filename[96];
	static dir[64];
	if( !dir[0] )
	{
		get_basedir(dir, sizeof(dir) - 1);
		add(dir, sizeof(dir) - 1, "/logs");
	}
	
	format_time(filename, sizeof(filename) - 1, "%m%d%Y");
	format(filename, sizeof(filename) - 1, "%s/CSP_REGISTRO_%s.log", dir, filename);
	
	log_to_file(filename, "%s", message);
}

PrintRegistro(id, const message_format[], any:...) {
	static message[192], len;
	len = formatex(message, sizeof(message) - 1, "^4%s", MESSAGE_TAG_REGISTRO);
	vformat(message[len], sizeof(message) - len - 1, message_format, 3);
	
	static players[32], pnum;
	if( id )
	{
		players[0] = id;
		pnum = 1;
	}
	else
	{
		get_players(players, pnum);
	}
	
	for( new i = 0, player; i < pnum; i++ )
	{
		player = players[i];
		if( xPlayerConected[player] && is_user_connected(player) ) // In�til mas acho que evita crash.
		{
			message_begin(MSG_ONE_UNRELIABLE, g_msgid_SayText, _, player);
			write_byte(player);
			write_string(message);
			message_end();
		}
	}
}

public MenuLogin(id, level, cid)
{
	if ( !cmd_access(id, level, cid, 2) ) return PLUGIN_HANDLED
	
	if ( read_argc() > 2 ) {
		PrintRegistro(id, "^1 %L", id, "A22_MENSAGEM")
		client_cmd(id, "speak events/friend_died.wav")
		return PLUGIN_HANDLED
	}
	
	new arg[32]
	read_argv(1, arg, charsmax(arg))
	
	new len = strlen(arg)
	
	if(len < 3)
	{
		PrintRegistro(id, "^1 %L", id, "A23_MENSAGEM")
		set_hudmessage(random_num(0,255), random_num(0,255), random_num(0,255), 0.01, 0.15, 2, 1.0, 3.0, 0.1, 5.0, -1)
		ShowSyncHudMsg(id, g_msgSyncHud, "%L", id, "A25_MENSAGEM")
		client_cmd(id, "speak events/friend_died.wav")
		return PLUGIN_HANDLED
	}
	
	if(len > 60)
	{
		PrintRegistro(id, "^1 %L", id, "A24_MENSAGEM")
		set_hudmessage(random_num(0,255), random_num(0,255), random_num(0,255), 0.01, 0.15, 2, 1.0, 3.0, 0.1, 5.0, -1)
		ShowSyncHudMsg(id, g_msgSyncHud, "%L", id, "A25_MENSAGEM")	
		return PLUGIN_HANDLED
	}	
	
	switch(xPlayerMenu[id])
	{
		case 0: // Nao tem
		{
			PrintRegistro(id, "^1 %L", id, "A26_MENSAGEM")
			client_cmd(id, "speak events/friend_died.wav")
			return PLUGIN_HANDLED;
		}
		case 1: // Nao tem
		{
			PrintRegistro(id, "^1 %L", id, "A26_MENSAGEM")
			client_cmd(id, "speak events/friend_died.wav")
			return PLUGIN_HANDLED;
		}
		case 2: // Menu de Login
		{
			if(containi(arg, "'") != -1 || containi(arg, "%") != -1)
			{
				PrintRegistro(id, "^1 %L", id, "A27_MENSAGEM")
				set_hudmessage(random_num(0,255), random_num(0,255), random_num(0,255), 0.01, 0.15, 2, 1.0, 3.0, 0.1, 5.0, -1)
				ShowSyncHudMsg(id, g_msgSyncHud, "%L", id, "A25_MENSAGEM")
				client_cmd(id, "speak events/friend_died.wav")
				return PLUGIN_HANDLED
			}			
			
			if(g_PlayerDigitar[id] > 0)
			{
				PrintRegistro(id, "^1 %L", id, "A26_MENSAGEM")
				client_cmd(id, "speak events/friend_died.wav")
				return PLUGIN_HANDLED;
			}
			
			mySQLConnect()
			if ( gDbConnect == Empty_Handle ) return PLUGIN_HANDLED;
			
			static sql[320], error[128], compat[64]
			new Handle:query
			new errcode
			new contaold
			
			// 1� BUGFIX...
			sql[0] = '^0'
			formatex(sql, charsmax(sql), "SELECT COMPAT FROM play_registro WHERE LOGIN = '%s'", arg)
			query = SQL_PrepareQuery(gDbConnect, "%s", sql)
			
			if ( !SQL_Execute(query) ) {
				errcode = SQL_QueryError(query, error, charsmax(error))
				Log("Erro Digitar Login 69: [%d] '%s' - '%s'", errcode, error, sql)
				SQL_FreeHandle(query)
				close_mysql()
				return PLUGIN_HANDLED;
			}
			
			if ( SQL_NumResults(query) ) {
				
				SQL_ReadResult(query, 0, compat, charsmax(compat))
				
				contaold = str_to_num(compat)
				
				if(contaold == 1)
				{
					SQL_FreeHandle(query)
					close_mysql()
					
					PrintRegistro(id, "^1 %L", id, "A28_MENSAGEM")
					PrintRegistro(id, "^1 %L", id, "A29_MENSAGEM")
					set_hudmessage(random_num(0,255), random_num(0,255), random_num(0,255), 0.01, 0.15, 2, 1.0, 3.0, 0.1, 5.0, -1)
					ShowSyncHudMsg(id, g_msgSyncHud, "%L", id, "A25_MENSAGEM")
					client_cmd(id, "speak events/friend_died.wav")
					return PLUGIN_HANDLED
				}
			}
			
			SQL_FreeHandle(query)
			
			sql[0] = '^0'
			formatex(sql, charsmax(sql), "SELECT COMPAT FROM play_registro WHERE EMAIL = '%s'", arg)
			query = SQL_PrepareQuery(gDbConnect, "%s", sql)
			
			if ( !SQL_Execute(query) ) {
				errcode = SQL_QueryError(query, error, charsmax(error))
				Log("Erro Digitar Login 70: [%d] '%s' - '%s'", errcode, error, sql)
				SQL_FreeHandle(query)
				close_mysql()
				return PLUGIN_HANDLED;
			}
			
			if ( SQL_NumResults(query) ) {
				
				SQL_ReadResult(query, 0, compat, charsmax(compat))
				
				contaold = str_to_num(compat)
				
				if(contaold == 1)
				{
					SQL_FreeHandle(query)
					close_mysql()
					
					PrintRegistro(id, "^1 %L", id, "A28_MENSAGEM")
					PrintRegistro(id, "^1 %L", id, "A29_MENSAGEM")
					set_hudmessage(random_num(0,255), random_num(0,255), random_num(0,255), 0.01, 0.15, 2, 1.0, 3.0, 0.1, 5.0, -1)
					ShowSyncHudMsg(id, g_msgSyncHud, "Email Invalido")
					client_cmd(id, "speak events/friend_died.wav")
					return PLUGIN_HANDLED
				}
			}
			
			SQL_FreeHandle(query)			
			close_mysql()			
			
			copy(g_Menu2LoginDigitado[id], charsmax(g_Menu2LoginDigitado[]), arg)
			g_PlayerDigitar[id] = 1
			
			PrintRegistro(id, "^1 %L", id, "A30_MENSAGEM")
			MenuPrincipal(id)
		}
		case 3: // Menu de Registro
		{
			if(len > 15)
			{
				PrintRegistro(id, "^1 %L", id, "A31_MENSAGEM")
				set_hudmessage(random_num(0,255), random_num(0,255), random_num(0,255), 0.01, 0.15, 2, 1.0, 3.0, 0.1, 5.0, -1)
				ShowSyncHudMsg(id, g_msgSyncHud, "%L", id, "A25_MENSAGEM")
				client_cmd(id, "speak events/friend_died.wav")
				return PLUGIN_HANDLED
			}
			
			if(containi(arg, "'") != -1 || containi(arg, "%") != -1 || containi(arg, "@") != -1 || containi(arg, "*") != -1 || containi(arg, "!") != -1 || containi(arg, "&") != -1 || containi(arg, "(") != -1 || containi(arg, ")") != -1 || containi(arg, "+") != -1 || containi(arg, "#") != -1 || containi(arg, "$") != -1 || containi(arg, "-") != -1)
			{
				PrintRegistro(id, "^1 %L", id, "A32_MENSAGEM")
				client_cmd(id, "speak events/friend_died.wav")
				return PLUGIN_HANDLED
			}			
			
			if(g_PlayerDigitar[id] > 0)
			{
				PrintRegistro(id, "^1 %L", id, "A26_MENSAGEM")
				client_cmd(id, "speak events/friend_died.wav")
				return PLUGIN_HANDLED;
			}
			
			mySQLConnect()
			if ( gDbConnect == Empty_Handle ) return PLUGIN_HANDLED;
			
			static sql[320], error[128]
			new Handle:query
			new errcode
			
			// 1� Verificamos se o Login digitado ja est� em uso...
			
			sql[0] = '^0'
			formatex(sql, charsmax(sql), "SELECT COMPAT FROM play_registro WHERE LOGIN = '%s'", arg)
			query = SQL_PrepareQuery(gDbConnect, "%s", sql)
			
			if ( !SQL_Execute(query) ) {
				errcode = SQL_QueryError(query, error, charsmax(error))
				Log("Erro Digitar Login 1: [%d] '%s' - '%s'", errcode, error, sql)
				SQL_FreeHandle(query)
				close_mysql()
				return PLUGIN_HANDLED;
			}
			
			if ( SQL_NumResults(query) ) { // Encontrou um login igual j�...
				SQL_FreeHandle(query)
				// Fechar a conex�o.
				close_mysql()
				PrintRegistro(id, "^1 %L", id, "A33_MENSAGEM")
				set_hudmessage(random_num(0,255), random_num(0,255), random_num(0,255), 0.01, 0.15, 2, 1.0, 3.0, 0.1, 5.0, -1)
				ShowSyncHudMsg(id, g_msgSyncHud, "%L", id, "A33_MENSAGEM")
				client_cmd(id, "speak events/friend_died.wav")
				return PLUGIN_HANDLED
			}			
			
			SQL_FreeHandle(query)
			close_mysql()
			
			copy(g_Menu3LoginDigitado[id], charsmax(g_Menu3LoginDigitado[]), arg)
			g_PlayerDigitar[id] = 1
			MenuPrincipal(id)
			
			PrintRegistro(id, "^1 %L", id, "A34_MENSAGEM")
			
		}
		case 4: // Nao tem
		{
			PrintRegistro(id, "^1 %L", id, "A26_MENSAGEM")
			client_cmd(id, "speak events/friend_died.wav")
			return PLUGIN_HANDLED;
		}
		case 5: // Nao tem
		{
			PrintRegistro(id, "^1 %L", id, "A26_MENSAGEM")
			client_cmd(id, "speak events/friend_died.wav")
			return PLUGIN_HANDLED;
		}		
	}
	
	return PLUGIN_HANDLED
}

public MenuSenha(id, level, cid)
{
	if ( !cmd_access(id, level, cid, 2) ) return PLUGIN_HANDLED
	
	if ( read_argc() > 2 ) {
		PrintRegistro(id, "^1 %L", id, "A35_MENSAGEM")
		client_cmd(id, "speak events/friend_died.wav")
		return PLUGIN_HANDLED
	}
	
	new arg[32]
	read_argv(1, arg, charsmax(arg))
	
	new len = strlen(arg)
	
	if(len < 3)
	{
		PrintRegistro(id, "^1 %L", id, "A38_MENSAGEM")
		set_hudmessage(random_num(0,255), random_num(0,255), random_num(0,255), 0.01, 0.15, 2, 1.0, 3.0, 0.1, 5.0, -1)
		ShowSyncHudMsg(id, g_msgSyncHud, "%L", id, "A37_MENSAGEM")
		client_cmd(id, "speak events/friend_died.wav")
		return PLUGIN_HANDLED
	}
	
	if(containi(arg, "'") != -1 || containi(arg, "%") != -1 || containi(arg, "@") != -1 || containi(arg, "*") != -1 || containi(arg, "!") != -1 || containi(arg, "&") != -1 || containi(arg, "(") != -1 || containi(arg, ")") != -1 || containi(arg, "+") != -1 || containi(arg, "#") != -1 || containi(arg, "$") != -1 || containi(arg, "-") != -1)
	{
		PrintRegistro(id, "^1 %L", id, "A27_MENSAGEM")
		set_hudmessage(random_num(0,255), random_num(0,255), random_num(0,255), 0.01, 0.15, 2, 1.0, 3.0, 0.1, 5.0, -1)
		ShowSyncHudMsg(id, g_msgSyncHud, "%L", id, "A37_MENSAGEM")
		client_cmd(id, "speak events/friend_died.wav")
		return PLUGIN_HANDLED
	}	
	
	switch(xPlayerMenu[id])
	{
		case 0: // Nao tem
		{
			PrintRegistro(id, "^1 %L", id, "A26_MENSAGEM")
			client_cmd(id, "speak events/friend_died.wav")
			return PLUGIN_HANDLED;
		}
		case 1: // Nao tem
		{
			PrintRegistro(id, "^1 %L", id, "A26_MENSAGEM")
			client_cmd(id, "speak events/friend_died.wav")
			return PLUGIN_HANDLED;
		}
		case 2: // Menu de Login
		{
			if(len > 30)
			{
				PrintRegistro(id, "^1 %L", id, "A36_MENSAGEM")
				set_hudmessage(random_num(0,255), random_num(0,255), random_num(0,255), 0.01, 0.15, 2, 1.0, 3.0, 0.1, 5.0, -1)
				ShowSyncHudMsg(id, g_msgSyncHud, "%L", id, "A37_MENSAGEM")
				client_cmd(id, "speak events/friend_died.wav")
				return PLUGIN_HANDLED
			}
			
			if(g_PlayerDigitar[id] != 1)
			{
				PrintRegistro(id, "^1 %L", id, "A26_MENSAGEM")
				client_cmd(id, "speak events/friend_died.wav")
				return PLUGIN_HANDLED;
			}
			
			copy(g_Menu2SenhaDigitada[id], charsmax(g_Menu2SenhaDigitada[]), arg)
			g_PlayerDigitar[id] = 2
			MenuPrincipal(id)
			
			PrintRegistro(id, "^1 %L", id, "A39_MENSAGEM")
		}
		case 3: // Menu de Registro
		{
			if(len > 15)
			{
				PrintRegistro(id, "^1 %L", id, "A36_MENSAGEM")
				set_hudmessage(random_num(0,255), random_num(0,255), random_num(0,255), 0.01, 0.15, 2, 1.0, 3.0, 0.1, 5.0, -1)
				ShowSyncHudMsg(id, g_msgSyncHud, "%L", id, "A37_MENSAGEM")
				client_cmd(id, "speak events/friend_died.wav")
				return PLUGIN_HANDLED
			}
			
			if(g_PlayerDigitar[id] != 1)
			{
				PrintRegistro(id, "^1 %L", id, "A26_MENSAGEM")
				client_cmd(id, "speak events/friend_died.wav")
				return PLUGIN_HANDLED;
			}			
			
			copy(g_Menu3SenhaDigitada[id], charsmax(g_Menu3SenhaDigitada[]), arg)
			g_PlayerDigitar[id] = 2
			MenuPrincipal(id)
			
			PrintRegistro(id, "^1 %L", id, "A39_MENSAGEM")
			
		}
		case 4: // Trocando a Senha
		{
			//if(g_Compatibilidade[id])
				//return PLUGIN_HANDLED;
			
			if(g_PlayerDigitar[id] == 0) // senha antiga
			{
				if(!equali(arg,xPlayerPass[id]))
				{
					//Senha antiga digitada errada!
					PrintRegistro(id, "^1 %L", id, "A55_MENSAGEM")
					client_cmd(id, "speak events/friend_died.wav")
					return PLUGIN_HANDLED;
				}
				
				g_PlayerDigitar[id] = 1
				MenuPrincipal(id)
				// Senha antiga digitada com sucesso!
				PrintRegistro(id, "^1 %L", id, "A56_MENSAGEM")	
				return PLUGIN_HANDLED;
			}
			
			copy(xPlayerMenuPassNova[id], charsmax(xPlayerMenuPassNova[]), arg)
			g_PlayerDigitar[id] = 2
			MenuPrincipal(id)
			// Senha nova digitada com sucesso... so confirmar!
			PrintRegistro(id, "^1 %L", id, "A57_MENSAGEM")
		}
		case 5: // Nao tem
		{
			PrintRegistro(id, "^1 %L", id, "A26_MENSAGEM")
			client_cmd(id, "speak events/friend_died.wav")
			return PLUGIN_HANDLED;
		}		
	}
	
	return PLUGIN_HANDLED
}

public MenuEmail(id, level, cid)
{
	if ( !cmd_access(id, level, cid, 2) ) return PLUGIN_HANDLED
	
	if ( read_argc() > 2 ) {
		PrintRegistro(id, "^1 %L", id, "A40_MENSAGEM")
		client_cmd(id, "speak events/friend_died.wav")
		return PLUGIN_HANDLED
	}
	
	new arg[64]
	read_argv(1, arg, charsmax(arg))
	
	new len = strlen(arg)
	
	if(len > 60)
	{
		PrintRegistro(id, "^1 %L", id, "A42_MENSAGEM")
		set_hudmessage(random_num(0,255), random_num(0,255), random_num(0,255), 0.01, 0.15, 2, 1.0, 3.0, 0.1, 5.0, -1)
		ShowSyncHudMsg(id, g_msgSyncHud, "%L", id, "A41_MENSAGEM")
		client_cmd(id, "speak events/friend_died.wav")
		return PLUGIN_HANDLED
	}
	
	if(len < 5)
	{
		PrintRegistro(id, "^1 %L", id, "A43_MENSAGEM")
		set_hudmessage(random_num(0,255), random_num(0,255), random_num(0,255), 0.01, 0.15, 2, 1.0, 3.0, 0.1, 5.0, -1)
		ShowSyncHudMsg(id, g_msgSyncHud, "%L", id, "A41_MENSAGEM")
		client_cmd(id, "speak events/friend_died.wav")
		return PLUGIN_HANDLED
	}
	
	if(containi(arg, "'") != -1 || containi(arg, "%") != -1)
	{
		PrintRegistro(id, "^1 %L", id, "A27_MENSAGEM")
		set_hudmessage(random_num(0,255), random_num(0,255), random_num(0,255), 0.01, 0.15, 2, 1.0, 3.0, 0.1, 5.0, -1)
		ShowSyncHudMsg(id, g_msgSyncHud, "%L", id, "A41_MENSAGEM")
		client_cmd(id, "speak events/friend_died.wav")
		return PLUGIN_HANDLED
	}	
	
	switch(xPlayerMenu[id])
	{
		case 0: // Nao tem
		{
			PrintRegistro(id, "^1 %L", id, "A26_MENSAGEM")
			return PLUGIN_HANDLED;
		}
		case 1: // Recuperar Dados
		{
			if(xPlayerPediuPraRecuperar[id])
			{
				PrintRegistro(id, "^1 Voce ja pediu para recuperar os dados da sua conta!")
				return PLUGIN_HANDLED;
			}
			
			mySQLConnect()
			if ( gDbConnect == Empty_Handle ) return PLUGIN_HANDLED;
			
			static sql[320], error[128]
			new Handle:query
			new errcode
			
			// 1� Verificamos se o Email digitado existe...
			
			sql[0] = '^0'
			formatex(sql, charsmax(sql), "SELECT COMPAT FROM play_registro WHERE EMAIL = '%s'", arg)
			query = SQL_PrepareQuery(gDbConnect, "%s", sql)
			
			if ( !SQL_Execute(query) ) {
				errcode = SQL_QueryError(query, error, charsmax(error))
				Log("Erro Digitar Email recupera��o: [%d] '%s' - '%s'", errcode, error, sql)
				SQL_FreeHandle(query)
				close_mysql()
				return PLUGIN_HANDLED;
			}
			
			if ( SQL_NumResults(query) ) { // O e-mail existe!
				SQL_FreeHandle(query)
				// Fechar a conex�o.
				close_mysql()
				
				static RecuperarMotd[200]
				copy(RecuperarMotd, charsmax(RecuperarMotd), motd_recuperar)				
				replace_all(RecuperarMotd, charsmax(RecuperarMotd), "%s", arg)
				
				show_motd(id, RecuperarMotd, "Aguarde... enviando...")
				
				PrintRegistro(id, "^1 Foi enviado um e-mail para^3 %s^1 com o Login e Senha da conta!", arg)
				PrintRegistro(id, "^1 Verifique sua caixa de entrada e/ou lixo eletronico.")
				Log("Pedido de Recupera��o de E-mail para: %s", arg)
				
				xPlayerPediuPraRecuperar[id] = true
				return PLUGIN_HANDLED
			}
			
			// N�o existe...
			SQL_FreeHandle(query)
			close_mysql()
			
			PrintRegistro(id, "^1 O e-mail^3 %s^1 nao consta em nosso Banco de Dados!", arg)
			Log("Pedido de Recupera��o de E-mail para: %s", arg)
			return PLUGIN_HANDLED;
		}
		case 2: // Nao tem
		{
			PrintRegistro(id, "^1 %L", id, "A26_MENSAGEM")
			return PLUGIN_HANDLED;
		}
		case 3: // Menu de Registro
		{
			if(g_PlayerDigitar[id] != 2)
			{
				PrintRegistro(id, "^1 %L", id, "A26_MENSAGEM")
				client_cmd(id, "speak events/friend_died.wav")
				return PLUGIN_HANDLED;
			}
			
			mySQLConnect()
			if ( gDbConnect == Empty_Handle ) return PLUGIN_HANDLED;
			
			static sql[320], error[128]
			new Handle:query
			new errcode
			
			// 1� Verificamos se o Email digitado ja est� em uso...
			
			sql[0] = '^0'
			formatex(sql, charsmax(sql), "SELECT COMPAT FROM play_registro WHERE EMAIL = '%s'", arg)
			query = SQL_PrepareQuery(gDbConnect, "%s", sql)
			
			if ( !SQL_Execute(query) ) {
				errcode = SQL_QueryError(query, error, charsmax(error))
				Log("Erro Digitar Email 1: [%d] '%s' - '%s'", errcode, error, sql)
				SQL_FreeHandle(query)
				close_mysql()
				return PLUGIN_HANDLED;
			}
			
			if ( SQL_NumResults(query) ) { // Encontrou um email igual j�...
				SQL_FreeHandle(query)
				// Fechar a conex�o.
				close_mysql()
				PrintRegistro(id, "^1 %L", id, "A44_MENSAGEM")
				set_hudmessage(random_num(0,255), random_num(0,255), random_num(0,255), 0.01, 0.15, 2, 1.0, 3.0, 0.1, 5.0, -1)
				ShowSyncHudMsg(id, g_msgSyncHud, "%L", id, "A44_MENSAGEM")
				client_cmd(id, "speak events/friend_died.wav")
				return PLUGIN_HANDLED
			}			
			
			SQL_FreeHandle(query)
			close_mysql()			
			
			copy(g_Menu3EmailDigitado[id], charsmax(g_Menu3EmailDigitado[]), arg)
			g_PlayerDigitar[id] = 3
			MenuPrincipal(id)
			
			PrintRegistro(id, "^1 %L", id, "A45_MENSAGEM")
			
		}
		case 4: // Nao tem
		{
			PrintRegistro(id, "^1 %L", id, "A26_MENSAGEM")
			return PLUGIN_HANDLED;
		}
		case 5: // Nao tem
		{
			PrintRegistro(id, "^1 %L", id, "A26_MENSAGEM")
			return PLUGIN_HANDLED;
		}		
	}
	
	return PLUGIN_HANDLED
}

ConfirmarRegistro(id) {
	if(/*g_Compatibilidade[id] || */xPlayerLogado[id] || xPlayerNaoQuerRegistrar[id])
		return true
	
	//static auth[32]
	
	//if( xPlayerSTEAM[ id ])
		//get_user_authid( id, auth, charsmax( auth ));
	
	//else get_user_name( id, auth, charsmax( auth ));
	
	mySQLConnect()
	if ( gDbConnect == Empty_Handle ) return false
	
	static sql[520], error[128], therid[64]
	new Handle:query
	new errcode
	
	// 1� Verificamos se o Login digitado ja est� em uso...
	
	sql[0] = '^0'
	formatex(sql, charsmax(sql), "SELECT LOGIN FROM play_registro WHERE LOGIN = '%s'", g_Menu3LoginDigitado[id]) // mudei para LOGIN, COMPAT
	query = SQL_PrepareQuery(gDbConnect, "%s", sql)
	
	if ( !SQL_Execute(query) ) {
		errcode = SQL_QueryError(query, error, charsmax(error))
		Log("Erro Registro 1: [%d] '%s' - '%s'", errcode, error, sql)
		SQL_FreeHandle(query)
		close_mysql()
		return true
	}
	
	if ( SQL_NumResults(query) ) { // Encontrou um login igual j�...
		SQL_FreeHandle(query)
		// Fechar a conex�o.
		close_mysql()
		
		g_PlayerDigitar[id] = 0
		MenuPrincipal(id)
		PrintRegistro(id, "^1 %L", id, "A33_MENSAGEM")
		set_hudmessage(random_num(0,255), random_num(0,255), random_num(0,255), 0.01, 0.15, 2, 1.0, 3.0, 0.1, 5.0, -1)
		ShowSyncHudMsg(id, g_msgSyncHud, "%L", id, "A33_MENSAGEM")
		client_cmd(id, "speak events/friend_died.wav")
		return true
	}
	
	SQL_FreeHandle(query)
	
	// 2� Verificamos se o E-mail ja esta em uso...
	
	sql[0] = '^0'
	formatex( sql, charsmax( sql ), "SELECT EMAIL FROM play_registro WHERE EMAIL = '%s'", g_Menu3EmailDigitado[id]) // MUDEI PARA EMAIL - COMPAT
	query = SQL_PrepareQuery(gDbConnect, "%s", sql)
	
	if( !SQL_Execute( query )){
		errcode = SQL_QueryError(query, error, charsmax(error))
		Log("Erro Registro 2: [%d] '%s' - '%s'", errcode, error, sql)
		SQL_FreeHandle(query)
		close_mysql()
		return true
	}
	
	// Encontrou um e-mail igual j�...
	if( SQL_NumResults( query )){
		SQL_FreeHandle( query );
		// Fechar a conex�o.
		close_mysql()
		
		g_PlayerDigitar[id] = 2
		MenuPrincipal(id)
		PrintRegistro(id, "^1 %L", id, "A44_MENSAGEM")
		set_hudmessage(random_num(0,255), random_num(0,255), random_num(0,255), 0.01, 0.15, 2, 1.0, 3.0, 0.1, 5.0, -1)
		ShowSyncHudMsg(id, g_msgSyncHud, "%L", id, "A44_MENSAGEM")
		client_cmd(id, "speak events/friend_died.wav")
		return true
	}
	
	SQL_FreeHandle(query)
	
	// 3� Tudo certo ent�o vamos registrar. Primeiro precisamos obter a RID
	sql[0] = '^0'
	formatex(sql, charsmax(sql), "SELECT REGISTRADOS FROM play_count_rid")
	query = SQL_PrepareQuery(gDbConnect, "%s", sql)
	
	if ( !SQL_Execute(query) ) {
		errcode = SQL_QueryError(query, error, charsmax(error))
		Log("Erro Registro 3: [%d] '%s' - '%s'", errcode, error, sql)
		SQL_FreeHandle(query)
		close_mysql()
		return true
	}
	
	SQL_ReadResult( query, 0, therid, charsmax( therid ))
	
	new iCountKey[ 33 ]
	iCountKey[ id ] = str_to_num( therid );
	iCountKey[ id ]++;
	
	//xPlayerKey[ id ] = ;
	//xPlayerKey[ id ]++
	
	new iGenerateKey[ 127 ];
	format( iGenerateKey, charsmax( iGenerateKey ), "CSP_0:0:%i", iCountKey[ id ])
	
	SQL_FreeHandle(query)
	
	// 4� Vamos inserir agora ent�o!
	copy(xPlayerUser[id], charsmax(xPlayerUser[]), g_Menu3LoginDigitado[id])
	copy(xPlayerPass[id], charsmax(xPlayerPass[]), g_Menu3SenhaDigitada[id])
	copy(xPlayerEmail[id], charsmax(xPlayerEmail[]), g_Menu3EmailDigitado[id])
	
	static iDateStr[ 82 ], iName[ 32 ];
	get_user_name( id, iName, charsmax( iName ));
	replace_all( iName, charsmax( iName ), "'", "\'");
	
	get_time( "%Y.%m.%d", iDateStr, charsmax( iDateStr ));

	// editei aki a keyuser
	static iUserIP[ 35 ];
	get_user_ip( id, iUserIP, charsmax( iUserIP ), 1);
	
	sql[0] = '^0'	
	formatex( sql, charsmax( sql ), "INSERT INTO play_registro ( MEMBRO_KEY, LOGIN, PASSWORD, EMAIL, AUTO_LOGIN, IP, ALISTAMENTO, ULTIMO_LOGIN, NICK, PLATAFORMA ) VALUES ('%s', '%s', '%s', '%s', '1', '%s', '%s', '%s', '%s', '2')", /*xPlayerKey[ id ]*/iGenerateKey, xPlayerUser[ id ], xPlayerPass[ id ], xPlayerEmail[ id ], iUserIP, iDateStr, iDateStr, iName )
	query = SQL_PrepareQuery( gDbConnect, "%s", sql);
	
	if( !SQL_Execute( query )){
		errcode = SQL_QueryError( query, error, charsmax( error ))
		Log("Erro Registro 4: [%d] '%s' - '%s'", errcode, error, sql );
		
		SQL_FreeHandle( query );
		close_mysql();
		
		return true;
	}
	
	SQL_FreeHandle( query );
	
	sql[0] = '^0';
	formatex(sql, charsmax( sql ), "UPDATE play_count_rid SET REGISTRADOS = REGISTRADOS + '1'");
	query = SQL_PrepareQuery(gDbConnect, "%s", sql);
	
	if( !SQL_Execute( query )){
		errcode = SQL_QueryError(query, error, charsmax(error))
		Log("Erro Registro 5: [%d] '%s' - '%s'", errcode, error, sql)
		SQL_FreeHandle(query)
		close_mysql()
		return true
	}
	
	SQL_FreeHandle(query)
	close_mysql()
	
	xPlayerLogado[id] = true
	copy( xPlayerKey[ id ], charsmax( xPlayerKey[]), iGenerateKey );
	//g_Compatibilidade[id] = false
	xPlayerMenu[id] = 5
	g_PlayerDigitar[id] = 0
	
	// Editar gamemenu...
	/*
	static g_Texto2[MAX_SIZE]
	copy(g_Texto2, charsmax(g_Texto2), g_Text)
	
	replace_all(g_Texto2, charsmax(g_Texto2), "%l", xPlayerUser[id])
	replace_all(g_Texto2, charsmax(g_Texto2), "%p", xPlayerPass[id])
	
	client_cmd(id, "motdfile %s", GAMEMENU_FILE)
	client_cmd(id, "motd_write %s", g_Texto2)
	client_cmd(id, "motdfile motd.txt") 	
	*/

	//client_cmd(id, "spk ambience/lv2")
	PrintRegistro(id, "^1 %L", id, "A46_MENSAGEM")
	PrintRegistro(id, "^1 %L", id, "A47_MENSAGEM", xPlayerUser[id], xPlayerPass[id], xPlayerEmail[id])
	
	set_hudmessage(random_num(0,255), random_num(0,255), random_num(0,255), 0.01, 0.15, 2, 1.0, 3.0, 0.1, 5.0, -1)
	ShowSyncHudMsg(id, g_msgSyncHud, "%L", id, "A5_MENSAGEM")
	
	// Carrega a XP dele agora e coloca ele dentro do jogo (forward...)
	ExecuteForward(xPlayerAutenticou, g_DummyResult_f, id, 1)
	client_cmd(id, "chooseteam")
	return true
}

ConfirmarLogin(id) {
	if(/*g_Compatibilidade[id] ||*/ xPlayerLogado[id] || xPlayerNaoQuerRegistrar[id])
		return true	
	
	mySQLConnect()
	if ( gDbConnect == Empty_Handle ) return false
	
	static sql[320], error[128], therid[64], playerip[35], autologin[64]
	new Handle:query
	new errcode
	
	// 1� Verificamos se o Login existe
	
	sql[0] = '^0'
	formatex(sql, charsmax(sql), "SELECT MEMBRO_KEY, PASSWORD, EMAIL, AUTO_LOGIN, MAX_INVENTARIO_ITENS, STATUS FROM play_registro WHERE LOGIN = '%s' AND PLATAFORMA = 2", g_Menu2LoginDigitado[id])
	query = SQL_PrepareQuery(gDbConnect, "%s", sql)
	
	if ( !SQL_Execute(query) ) {
		errcode = SQL_QueryError(query, error, charsmax(error))
		Log("Erro Login 1: [%d] '%s' - '%s'", errcode, error, sql)
		SQL_FreeHandle(query)
		close_mysql()
		return true
	}
	
	if ( SQL_NumResults(query) ) { // Encontrou um login igual j�...
		
		//SQL_ReadResult(query, SQL_FieldNameToNum(query, "MEMBRO_KEY"), therid, sizeof(therid) - 1)
		SQL_ReadResult(query, SQL_FieldNameToNum(query, "MEMBRO_KEY"), xPlayerKey[ id ], sizeof( xPlayerKey ) - 1)
		SQL_ReadResult(query, SQL_FieldNameToNum(query, "PASSWORD"), xPlayerPass[id], sizeof(xPlayerPass) - 1)
		SQL_ReadResult(query, SQL_FieldNameToNum(query, "EMAIL"), xPlayerEmail[id], sizeof(xPlayerEmail) - 1)
		SQL_ReadResult(query, SQL_FieldNameToNum(query, "AUTO_LOGIN"), autologin, sizeof(autologin) - 1)
		//SQL_ReadResult(query, SQL_FieldNameToNum(query, "MAX_INVENTARIO_ITENS"), xPlayerSlotsInv[id], sizeof(xPlayerSlotsInv) - 1)
		xPlayerStatusAccount[ id ] = SQL_ReadResult( query, SQL_FieldNameToNum( query, "STATUS"));
		
		// Autenticar...
		if(!equali(g_Menu2SenhaDigitada[id], xPlayerPass[id]))
		{
			SQL_FreeHandle(query)
			// Fechar a conex�o.
			close_mysql()
			
			g_PlayerDigitar[id] = 1
			MenuPrincipal(id)
			PrintRegistro(id, "^1 %L", id, "A48_MENSAGEM")
			set_hudmessage(random_num(0,255), random_num(0,255), random_num(0,255), 0.01, 0.15, 2, 1.0, 3.0, 0.1, 5.0, -1)
			ShowSyncHudMsg(id, g_msgSyncHud, "%L", id, "A48_MENSAGEM")
			client_cmd(id, "speak events/friend_died.wav")
			return true
		}
		
		//loginrid = str_to_num(therid)
		
		if( !xPlayerStatusAccount[ id ]){
			server_cmd("kick #%i ^"Sua conta %s esta Banida!^"", get_user_userid( id ), xPrefix )
			return true;
		}
		
		// Verificar se j� nao tem alguem logado nessa conta
		for (new x = 1; x <= xMaxPlayers; x++)
		{
			if(xPlayerConected[x] && xPlayerLogado[x] && equal( xPlayerKey[x], xPlayerKey[ id ])) // talvez esteja bugado essa poha
			{
				SQL_FreeHandle(query)
				// Fechar a conex�o.
				close_mysql()
				
				xPlayerMenu[id] = 1
				MenuPrincipal(id)
				PrintRegistro(id, "^1 %L", id, "A49_MENSAGEM")
				set_hudmessage(random_num(0,255), random_num(0,255), random_num(0,255), 0.01, 0.15, 2, 1.0, 3.0, 0.1, 5.0, -1)
				ShowSyncHudMsg(id, g_msgSyncHud, "%L", id, "A49_MENSAGEM")
				client_cmd(id, "speak events/friend_died.wav")
				return true
			}
		}
		
		//Tudo OK...
		//xPlayerKey[id] = loginrid
		copy(xPlayerUser[id], charsmax(g_Menu2LoginDigitado[]), g_Menu2LoginDigitado[id])
		//copy(xPlayerKey[id], charsmax(xPlayerKey[]), g_Menu2LoginDigitado[id])
		xPlayerLogado[id] = true
		xPlayerMenu[id] = 5
		
		new verautologin = str_to_num(autologin)
		if( verautologin == 1 )
			xPlayerAutoLogin[ id ] = true;
			
		else xPlayerAutoLogin[ id ] = false;
		
		PrintRegistro(id, "^1 %L", id, "A50_MENSAGEM", xPlayerUser[id])
		
		set_hudmessage(random_num(0,255), random_num(0,255), random_num(0,255), 0.01, 0.15, 2, 1.0, 3.0, 0.1, 5.0, -1)
		ShowSyncHudMsg(id, g_msgSyncHud, "%L", id, "A5_MENSAGEM")		
		
		SQL_FreeHandle(query)
		
		// Atualizar o AutoLogin...
		get_user_ip(id, playerip, 34, 1)
		
		static iName[ 33 ];
		get_user_name( id, iName, charsmax( iName ));
		replace_all( iName, charsmax( iName ), "'", "\'");
		
		sql[0] = '^0'	
		formatex(sql, charsmax(sql), "UPDATE play_registro SET IP = '%s', NICK = '%s' WHERE LOGIN = '%s'", playerip, iName, g_Menu2LoginDigitado[id])
		query = SQL_PrepareQuery(gDbConnect, "%s", sql)
		
		if ( !SQL_Execute(query) ) {
			errcode = SQL_QueryError(query, error, charsmax(error))
			Log("Erro ao inserir IP de AutoLogin 1: [%d] '%s' - '%s'", errcode, error, sql)
		}	
		
		SQL_FreeHandle(query)
		close_mysql() 			
		
		// (forward pra carregar XP e nascer)
		ExecuteForward(xPlayerAutenticou, g_DummyResult_f, id, 0)
		client_cmd(id, "chooseteam")
		return true
	}
	
	SQL_FreeHandle(query)	
	
	// 2� Login atraves do email...
	
	sql[0] = '^0'
	formatex(sql, charsmax(sql), "SELECT MEMBRO_KEY, PASSWORD, LOGIN, AUTO_LOGIN, MAX_INVENTARIO_ITENS FROM play_registro WHERE EMAIL = '%s' AND PLATAFORMA = 2", g_Menu2LoginDigitado[id])
	query = SQL_PrepareQuery(gDbConnect, "%s", sql)
	
	if ( !SQL_Execute(query) ) {
		errcode = SQL_QueryError(query, error, charsmax(error))
		Log("Erro Login 2: [%d] '%s' - '%s'", errcode, error, sql)
		SQL_FreeHandle(query)
		close_mysql()
		return true
	}
	
	if ( SQL_NumResults(query) ) { // Encontrou o e-mail...
		
		SQL_ReadResult(query, SQL_FieldNameToNum(query, "MEMBRO_KEY"), therid, sizeof(therid) - 1)
		SQL_ReadResult(query, SQL_FieldNameToNum(query, "PASSWORD"), xPlayerPass[id], sizeof(xPlayerPass) - 1)
		SQL_ReadResult(query, SQL_FieldNameToNum(query, "LOGIN"), xPlayerUser[id], sizeof(xPlayerUser) - 1)
		SQL_ReadResult(query, SQL_FieldNameToNum(query, "AUTO_LOGIN"), autologin, sizeof(autologin) - 1)
		//SQL_ReadResult(query, SQL_FieldNameToNum(query, "MAX_INVENTARIO_ITENS"), xPlayerSlotsInv[id], sizeof(xPlayerSlotsInv) - 1)
		xPlayerStatusAccount[ id ] = SQL_ReadResult( query, SQL_FieldNameToNum( query, "STATUS"));
		
		
		
		// Autenticar...
		if(!equali(g_Menu2SenhaDigitada[id], xPlayerPass[id]))
		{
			SQL_FreeHandle(query)
			// Fechar a conex�o.
			close_mysql()
			
			g_PlayerDigitar[id] = 1
			MenuPrincipal(id)
			PrintRegistro(id, "^1 %L", id, "A48_MENSAGEM")
			set_hudmessage(random_num(0,255), random_num(0,255), random_num(0,255), 0.01, 0.15, 2, 1.0, 3.0, 0.1, 5.0, -1)
			ShowSyncHudMsg(id, g_msgSyncHud, "%L", id, "A48_MENSAGEM")
			return true
		}
		
		//loginrid = str_to_num(therid)
		
		if( !xPlayerStatusAccount[ id ]){
			server_cmd("kick #%i ^"Sua conta %s esta Banida!^"", get_user_userid( id ), xPrefix )
			return true;
		}
		
		// Verificar se j� nao tem alguem logado nessa conta
		for (new x = 1; x <= xMaxPlayers; x++)
		{
			if(xPlayerConected[x] && xPlayerLogado[x] && equal( xPlayerKey[x], xPlayerKey[ id ]))
			{
				SQL_FreeHandle(query)
				// Fechar a conex�o.
				close_mysql()
				
				xPlayerMenu[id] = 1
				PrintRegistro(id, "^1 %L", id, "A49_MENSAGEM")
				set_hudmessage(random_num(0,255), random_num(0,255), random_num(0,255), 0.01, 0.15, 2, 1.0, 3.0, 0.1, 5.0, -1)
				ShowSyncHudMsg(id, g_msgSyncHud, "%L", id, "A49_MENSAGEM")
				return true
			}
		}
		
		//Tudo OK...
		//xPlayerKey[id] = loginrid
		copy(xPlayerEmail[id], charsmax(g_Menu2LoginDigitado[]), g_Menu2LoginDigitado[id])
		xPlayerLogado[id] = true
		xPlayerMenu[id] = 5
		
		new verautologin = str_to_num(autologin)
		if(verautologin == 1)
		{
			xPlayerAutoLogin[id] = true
		}
		else xPlayerAutoLogin[id] = false
		
		PrintRegistro(id, "^1 %L", id, "A50_MENSAGEM", xPlayerUser[id])
		
		set_hudmessage(random_num(0,255), random_num(0,255), random_num(0,255), 0.01, 0.15, 2, 1.0, 3.0, 0.1, 5.0, -1)
		ShowSyncHudMsg(id, g_msgSyncHud, "%L", id, "A5_MENSAGEM")	
		
		SQL_FreeHandle(query)
		
		// Atualizar o AutoLogin...
		get_user_ip(id, playerip, 34, 1)
		
		static iName[ 33 ];
		get_user_name( id, iName, charsmax( iName ));
		replace_all( iName, charsmax( iName ), "'", "\'");
		
		sql[0] = '^0'	
		formatex(sql, charsmax(sql), "UPDATE play_registro SET IP = '%s', NICK = '%s' WHERE EMAIL ='%s'", playerip, iName, g_Menu2LoginDigitado[id])
		query = SQL_PrepareQuery(gDbConnect, "%s", sql)
		
		if ( !SQL_Execute(query) ) {
			errcode = SQL_QueryError(query, error, charsmax(error))
			Log("Erro ao inserir IP de AutoLogin 1: [%d] '%s' - '%s'", errcode, error, sql)
		}		
		
		SQL_FreeHandle(query)
		close_mysql()
		
		// (forward pra carregar XP e nascer)
		ExecuteForward(xPlayerAutenticou, g_DummyResult_f, id, 0)
		client_cmd(id, "chooseteam")
		return true
	}
	
	SQL_FreeHandle(query)
	close_mysql()	
	
	// Se chegou at� aqui � por que login ou e-mail nao foram encontrados no banco...
	set_hudmessage(random_num(0,255), random_num(0,255), random_num(0,255), 0.01, 0.15, 2, 1.0, 3.0, 0.1, 5.0, -1)
	ShowSyncHudMsg(id, g_msgSyncHud, "%L", id, "A51_MENSAGEM")
	
	g_PlayerDigitar[id] = 0
	MenuPrincipal(id)
	
	PrintRegistro(id, "^1 %L", id, "A52_MENSAGEM", g_Menu2LoginDigitado[id])
	PrintRegistro(id, "^1 %L", id, "A53_MENSAGEM")
	return true
}

TrocarSenha(id) {
	mySQLConnect()
	if ( gDbConnect == Empty_Handle ) return false
	
	static sql[220], error[128]
	new Handle:query
	new errcode
	
	sql[0] = '^0'
	formatex(sql, charsmax(sql), "UPDATE play_registro SET PASSWORD = '%s' WHERE MEMBRO_KEY = '%s'", xPlayerMenuPassNova[id], xPlayerKey[id])
	query = SQL_PrepareQuery(gDbConnect, "%s", sql)
	
	if ( !SQL_Execute(query) ) {
		errcode = SQL_QueryError(query, error, charsmax(error))
		Log("Erro ao trocar senha de %i [%d] '%s' - '%s'", xPlayerKey[id], errcode, error, sql)
		SQL_FreeHandle(query)
		close_mysql()
		PrintRegistro(id, "^1 %L", id, "A54_MENSAGEM")
		return true
	}
	
	xPlayerMenu[id] = 5
	g_PlayerDigitar[id] = 0
	
	copy(xPlayerPass[id], charsmax(xPlayerMenuPassNova[]), xPlayerMenuPassNova[id])
	PrintRegistro(id, "^1 %L", id, "A58_MENSAGEM", xPlayerMenuPassNova[id])
	
	// Editar gamemenu...
	/*
	static g_Texto2[MAX_SIZE]
	copy(g_Texto2, charsmax(g_Texto2), g_Text)
	
	replace_all(g_Texto2, charsmax(g_Texto2), "%l", xPlayerUser[id])
	replace_all(g_Texto2, charsmax(g_Texto2), "%p", xPlayerPass[id])
	
	client_cmd(id, "motdfile %s", GAMEMENU_FILE)
	client_cmd(id, "motd_write %s", g_Texto2)
	client_cmd(id, "motdfile motd.txt")	
	*/
	
	SQL_FreeHandle(query)
	close_mysql()
	return true
}

public register_dictionary_colored(const filename[])
{
	if( !register_dictionary(filename) )
	{
		return 0
	}
	
	new szFileName[256]
	get_localinfo("amxx_datadir", szFileName, charsmax(szFileName))
	format(szFileName, charsmax(szFileName), "%s/lang/%s", szFileName, filename)
	new fp = fopen(szFileName, "rt")
	if( !fp )
	{
		log_error(AMX_ERR_NATIVE, "Failed to open %s", szFileName)
		return 0
	}
	
	new szBuffer[512], szLang[3], szKey[64], szTranslation[256], TransKey:iKey
	
	while( !feof(fp) )
	{
		fgets(fp, szBuffer, charsmax(szBuffer))
		trim(szBuffer)
		
		if( szBuffer[0] == '[' )
		{
			strtok(szBuffer[1], szLang, charsmax(szLang), szBuffer, 1, ']')
		}
		else if( szBuffer[0] )
		{
			argbreak(szBuffer, szKey, charsmax(szKey), szTranslation, charsmax(szTranslation))
			iKey = GetLangTransKey(szKey)
			if( iKey != TransKey_Bad )
			{
				while( replace(szTranslation, charsmax(szTranslation), "!g", "^4") ){}
				while( replace(szTranslation, charsmax(szTranslation), "!t", "^3") ){}
				while( replace(szTranslation, charsmax(szTranslation), "!p", "^n") ){}
				while( replace(szTranslation, charsmax(szTranslation), "!n", "^1") ){}
				AddTranslation(szLang, iKey, szTranslation[2])
			}
		}
	}
	
	fclose(fp)
	return 1
}
