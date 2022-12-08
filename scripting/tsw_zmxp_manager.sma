#include < amxmodx >
#include < amxmisc >
#include < cstrike >
#include < hamsandwich >
#include < zombieplague >

#include < play_global >
#include < play_registro >
#include < play_guilds >
#include < sqlx >

#define PLUGIN "ZombieXP Manager"
#define VERSION "7.0"

//By default, plugins have 4KB of stack space.
//This gives the plugin a little more memory to work with (6144 or 24KB is zm default)
#pragma dynamic 6144

// Coloque aqui a XP quando alguem entrar no servidor

#define ENTRY_XP			6200
#define ENTRY_AP			25

// Coloque aqui o level máximo para cada Item

#define MAXLEVEL_CT_ARMOR			5
#define MAXLEVEL_CT_AMMO			3
#define MAXLEVEL_CT_SPEED			5
#define MAXLEVEL_CT_GRAVITY			5
#define MAXLEVEL_CT_DAMAGE			5
#define MAXLEVEL_CT_STUNSHOT		5
#define MAXLEVEL_CT_ESQUIVA			5
#define MAXLEVEL_CT_GRANADAS		5
#define MAXLEVEL_CT_STAMINA			5
#define MAXLEVEL_CT_HP				5
#define MAXLEVEL_CT_SLOT_INV		15

// Quantidade de XP inicial necessária para cada Item!
// A XP vai dobrando para conseguir cada lvl depois.

#define FIRST_XP_CT_ARMOR			1400
#define FIRST_XP_CT_AMMO			2000
#define FIRST_XP_CT_SPEED			1100
#define FIRST_XP_CT_GRAVITY			1400
#define FIRST_XP_CT_DAMAGE			2000
#define FIRST_XP_CT_STUNSHOT		1300
#define FIRST_XP_CT_ESQUIVA			1300
#define FIRST_XP_CT_GRANADAS		1000
#define FIRST_XP_CT_STAMINA			1000
#define FIRST_XP_CT_HP				1000
#define FIRST_XP_CT_SLOT_INV		1000

#define XTRA_OFS_PLAYER 5
#define m_iTeam 114
#define m_afButtonPressed 246
#define m_flFallVelocity 251

//new const MESSAGE_TAG[] = "[CSP Gaming ZMXP]"
new const MESSAGE_TAG_PARTY[] = "[PARTY]"

const PDATA_SAFE = 2

new g_upgrades[33][33]
new g_xp[33]
new g_xpround[33]
new g_aps[33]
new g_apsround[33]
new g_xptotal[33]
new g_level[33]
new g_rank[33], g_rank_semanal[33]
new bool:g_UserConnected[33]
new Float:g_iDamageFeito[33]
new g_infects[33]
new g_aura[33]

// ========================================
// Item: Colete
// ========================================

new const g_armor_names[] = "Colete"
new const g_armor_maxamount = 80
new const g_armor_maxlevels = MAXLEVEL_CT_ARMOR
new const g_armor_first_xp = FIRST_XP_CT_ARMOR
new g_armor_level[33]

// ========================================
// Item: Munição Extra
// ========================================

new const g_ammo_names[] = "Municao Automatica"
new const g_ammo_maxamount = 3
new const g_ammo_maxlevels = MAXLEVEL_CT_AMMO
new const g_ammo_first_xp = FIRST_XP_CT_AMMO
new g_ammo_level[33]

// ========================================
// Item: Velocidade
// ========================================

new const g_speed_names[] = "Velocidade"
new const g_speed_maxamount = 40
new const g_speed_maxlevels = MAXLEVEL_CT_SPEED
new const g_speed_first_xp = FIRST_XP_CT_SPEED
new g_speed_level[33]

// ========================================
// Item: Gravity
// ========================================

new const g_gravity_names[] = "Gravidade"
new const g_gravity_maxamount = 200
new const g_gravity_maxlevels = MAXLEVEL_CT_GRAVITY
new const g_gravity_first_xp = FIRST_XP_CT_GRAVITY
new g_gravity_level[33]

// ========================================
// Item: Damage
// ========================================

new const g_damage_names[] = "Damage"
new const g_damage_maxamount = 50
new const g_damage_maxlevels = MAXLEVEL_CT_DAMAGE
new const g_damage_first_xp = FIRST_XP_CT_DAMAGE
new g_damage_level[33]

// ========================================
// Item: Stun Shot
// ========================================

new const g_stunshot_names[] = "Elemental Shot"
new const g_stunshot_maxamount = 10
new const g_stunshot_maxlevels = MAXLEVEL_CT_STUNSHOT
new const g_stunshot_first_xp = FIRST_XP_CT_STUNSHOT
new g_stunshot_level[33]

// ========================================
// Item: Esquiva
// ========================================

new const g_esquiva_names[] = "Esquiva"
new const g_esquiva_maxamount = 10
new const g_esquiva_maxlevels = MAXLEVEL_CT_ESQUIVA
new const g_esquiva_first_xp = FIRST_XP_CT_ESQUIVA
new g_esquiva_level[33]

// ========================================
// Item: Granadas
// ========================================

new const g_granadas_names[] = "Granadas"
new const g_granadas_maxamount = 260
new const g_granadas_maxlevels = MAXLEVEL_CT_GRANADAS
new const g_granadas_first_xp = FIRST_XP_CT_GRANADAS
new g_granadas_level[33]

// ========================================
// Item: Stamina
// ========================================

new const g_stamina_names[] = "Stamina"
new const g_stamina_maxamount = 1000
new const g_stamina_maxlevels = MAXLEVEL_CT_STAMINA
new const g_stamina_first_xp = FIRST_XP_CT_STAMINA
new g_stamina_level[33]

// ========================================
// Item: Vida-Extra
// ========================================

new const g_hp_names[] = "HP"
new const g_hp_maxamount = 200
new const g_hp_maxlevels = MAXLEVEL_CT_HP
new const g_hp_first_xp = FIRST_XP_CT_HP
new g_hp_level[33]


// ========================================
// Item: Inventario
// ========================================
new const g_inventario_names[] = "Slot Inventario"
new const g_inventario_maxamount = 200
new const g_inventario_maxlevels = MAXLEVEL_CT_SLOT_INV
new const g_inventario_first_xp = FIRST_XP_CT_SLOT_INV
new g_slots_inv_level[33]

new const Float:TempoGranadas[] =
{
	0.0,
	260.0,
	220.0,
	180.0,
	140.0,
	100.0
}

new szArma[][] = 
{
	"weapon_hegrenade",
	"weapon_flashbang"
}

// ========================================
// Double Jump
// ========================================

new g_iJumpCount[33], g_pCvarMaxFallVelocity, g_pCvarJumpVelocity

// ========================================
// Cvars do Plugin!
// ========================================

new bool:g_player_carregado[33]
new cvar_xp_lasthuman
new cvar_xp_winround, cvar_xp_kill_zombie, cvar_xp_kill_zombie_vip
new cvar_xp_damage, cvar_xp_damage_vip
new zmxp_minplayers, g_msgid_SayText, gServersMaxPlayers, totalrank

// MYSQL
new Handle:gDbTuple
/* =====================================================================
 [ Party ]
======================================================================== */
#define MAX_MEMBERS 4
new g_Party[33], bool:g_PartyOwner[33], bool:g_PertoLider[33], g_Inviter[33], g_PartyAcao[33], laser

const KEYSMENU = (1<<0)|(1<<1)|(1<<2)|(1<<9)
const KEYSINVITE = (1<<0)|(1<<1)

new const Float:g_flCoords[][] = 
{
	{0.50, 0.40},
	{0.56, 0.44},
	{0.60, 0.50},
	{0.56, 0.56},
	{0.50, 0.60},
	{0.44, 0.56},
	{0.40, 0.50},
	{0.44, 0.44}
}

new bool:JogadorVIP[33], g_iPlayerPos[33]
// ========================================
// Inicio do Plugin
// ========================================

/* SISTEMA DE PATENTES */
native play_set_user_exp( index, ammount );
native play_get_user_exp( index );
native play_get_user_level( index );

new cvar_exp_patente_kill_zombie, cvar_exp_patente_kill_zmvip, cvar_exp_patente_winround, cvar_exp_patente_lasthumman

/* Block Resources */
#define MAX_BLOCK	256
new xBlockResource[ MAX_BLOCK ][ 512 ];
new xBlockNums;
new cvar_happyhour_on
new g_happyhour = 0;

#define is_user_valid(%1) (1 <= %1 <= gServersMaxPlayers)

public plugin_init(){
	RegisterPlugin( PLUGIN, VERSION, AUTHOR );
	
	register_dictionary_colored("play_zmxp_manager.txt")
	
	cvar_happyhour_on = register_cvar( "zmxp_happyhour_on", "0" )
	
	// Comandos
	register_clcmd("say /xp", "CmdMainMenu")
	register_clcmd("say_team /xp", "CmdMainMenu")
	register_clcmd("/xp", "CmdMainMenu")
	register_clcmd("say /exp", "CmdMainMenu")
	//register_clcmd("say /rank", "mostrar_rank")
	register_clcmd("rank_xp", "mostrar_rank")
	register_clcmd("rank_semanal", "mostrar_rank_semanal")
	register_clcmd("say /aura", "say_aura")
	
	// Comandos de Party
	register_clcmd("say","clcmd_say")
	register_clcmd("say /fechar", "fechar_party")
	register_clcmd("say /party", "party_menu")
	register_clcmd("say /pt", "party_menu")
	
	// Eventos
	RegisterEvent( RoundStartHLTV, "EventRoundStart" );
	//register_event("HLTV", "RoundStart", "a", "1=0", "2=0")
	register_event("DeathMsg", "EventDeathMsg", "a")
	RegisterHam(Ham_Spawn, "player", "FwdPlayerSpawn", 1) 
	RegisterHam(Ham_TakeDamage, "player", "FwdPlayerDamage")
	RegisterHam(Ham_TraceAttack, "player", "TraceAttack")
	RegisterHam(Ham_Player_Jump, "player", "Ham_Player_JumpPre")
	register_event("Damage", "Event_Damage", "b", "2>0", "3=0") // Bullet Damage VIP
	
	register_menu("Party Menu", KEYSMENU, "PartyHandle")
	register_menu("Invite", KEYSINVITE, "InviteHandle")
	//gDbTuple = SQL_MakeDbTuple("200.98.67.104", "root", "zmdark7732", "zplague_zombiexp")

	#include "play4ever.inc/play_conecta.play"
	// XP POR DAMAGE
	cvar_xp_damage = register_cvar("zmxp_xp_damage", "360")
	cvar_xp_damage_vip = register_cvar("zmxp_xp_damage_vip", "300")
	cvar_xp_kill_zombie = register_cvar("zmxp_xp_kill_zombie", "10")
	cvar_xp_kill_zombie_vip = register_cvar("zmxp_xp_kill_zombie_diamond", "14")	
	cvar_xp_winround = register_cvar("zmxp_xp_winround", "12")
	cvar_xp_lasthuman = register_cvar("zmxp_xp_lasthuman", "10")
	
	
	// EXP PATENTE
	cvar_exp_patente_kill_zombie = register_cvar( "play_exp_patente_kill_zombie", "1" );
	cvar_exp_patente_kill_zmvip = register_cvar( "play_exp_patente_kill_zombie_vip", "2" );
	cvar_exp_patente_winround = register_cvar( "play_exp_patente_winround", "1" );
	cvar_exp_patente_lasthumman = register_cvar( "play_exp_patente_lasthumman", "5" );
	
	// Outras CVARS
	zmxp_minplayers = register_cvar("zmxp_min_players", "7")
	
	// O Melhor Zombie
	register_concmd("zp_thebestzmha", "zp_thebestzmha", ADMIN_BAN)
	
	// Double Jump
	g_pCvarMaxFallVelocity = register_cvar("mp_multijump_maxfallvelocity", "500")
	g_pCvarJumpVelocity = register_cvar("mp_multijumps_jumpvelocity", "268.328157")
	
	// MISC
	gServersMaxPlayers = get_maxplayers()
	g_msgid_SayText = get_user_msgid("SayText")
	
	set_task(1.2, "add_bullets", _, _, _, "b")
	set_task(2.0, "PartyProximidade", _, _, _, "b")
}

public plugin_precache(){
	ReadBlockResource();
	
	register_forward( FM_PrecacheModel, "Forward_PrecaceResource" );
	register_forward( FM_PrecacheSound, "Forward_PrecaceResource" );
	
	laser = precache_model("sprites/laserbeam.spr");
}

public ReadBlockResource(){
	new iPath[ 128 ], iConfigDir[ 32 ];
	get_configsdir( iConfigDir, charsmax( iConfigDir ))
	format( iPath, charsmax( iPath ), "%s/zmxp_blockresources.ini", iConfigDir )
	
	if(!file_exists( iPath )){
		//jail_log("O Arquivo Block Resource nao foi encontrado!");
		//set_fail_state("ERROR! Verifique o Detalhe do erro em jail_manager_log.log")
	}
	
	new iFile = fopen( iPath, "r")
	new iBuffer[ 512 ];
	while( iFile && !feof( iFile )){
		//if( szReadData[ 0 ] == ';' || szReadData[ 0 ] == '/' || !szReadData[ 0 ] || szReadData[ 0 ] == 10 )
			//continue;
		
		fgets( iFile, iBuffer, 511 )
		replace_all( iBuffer, 511, "^n","")
		copy( xBlockResource[ xBlockNums++ ], 511, iBuffer )
	}
	
	fclose( iFile );
	//jail_log("Block Resource Carregado com Sucesso!");
}

public Forward_PrecaceResource( resource[]){			
	for( new i = 0; i < xBlockNums; i++ ){
		if( equal( xBlockResource[ i ], resource )){
			return FMRES_SUPERCEDE
		}
	}
			
	return FMRES_IGNORED
}

public plugin_end()
{
	// Final cleanup in the saving include
	SQL_FreeHandle(gDbTuple)
}

// ========================================
// Natives para usar em outros plugins!
// ========================================

public plugin_natives(){
	register_library("zombiexp")
	register_native("zmxp_get_user_xp", "_get_xp")
	register_native("zmxp_set_user_xp", "_set_xp")
	register_native("zmxp_get_user_armor", "_get_armor_level")
	register_native("zmxp_get_user_ammo", "_get_ammo_level")
	register_native("zmxp_get_user_speed", "_get_speed_level")
	register_native("zmxp_get_user_gravity", "_get_gravity_level")
	register_native("zmxp_get_user_damage", "_get_damage_level")
	register_native("zmxp_get_user_stunshot", "_get_stunshot_level")
	register_native("zmxp_get_user_esquiva", "_get_esquiva_level")
	register_native("zmxp_get_user_granadas", "_get_granadas_level")
	register_native("zmxp_get_user_stamina", "_get_stamina_level")
	register_native("zmxp_get_user_hp", "_get_hp_level")
	register_native("zmxp_save_user", "_save_user")
	register_native("update_banco_ammopacks", "native_update_banco_aps", 1)
	
	register_native("zmxp_mesma_party", "native_zmxp_mesma_party", 1)
}

// Native: zas_mesma_party
public native_zmxp_mesma_party( id, outro ){
	if( !is_user_valid( id ) || !is_user_valid( outro ))
		return 0;
	
	if( g_Party[ id ] > 0 && g_Party[ id ] == g_Party[ outro ])
		return 1;
	
	return 0;
}

public native_update_banco_aps( id ){
	update_player_ammopack( id );
}

public update_player_ammopack( id ){
	static iQuery[ 512 ];
	g_aps[ id ] = zp_get_user_ammo_packs( id );
	
	static auth[ 64 ];
	/*
	if( is_user_steam( id ))
	get_user_authid( id, auth, charsmax( auth ));
	*/
	
	get_user_key( id, auth, charsmax( auth ));
	
	formatex( iQuery, 511, "UPDATE play_zombiexp SET AMMOPACKS = '%d' WHERE MEMBRO_KEY = '%s'", g_aps[ id ], auth );
	SQL_ThreadQuery( gDbTuple, "QuerySetData", iQuery );
}

public QuerySetData( iFailState, Handle:hQuery, szError[ ], iError, iData[ ], iDataSize, Float:fQueueTime )  {
	if( iFailState == TQUERY_CONNECT_FAILED || iFailState == TQUERY_QUERY_FAILED ) {
		log_amx( "%s", szError ); 
		return;
	} 
} 

public _get_xp(id, params)
{
	return g_xp[get_param(1)]
}

public _save_user(plugin_id, param_nums)
{
	static id; id = get_param(1)
	
	SalvarJogador(id)
	return 1
}

public _get_armor_level(id, params)
{
	return g_armor_level[get_param(1)]
}

public _get_ammo_level(id, params)
{
	return g_ammo_level[get_param(1)]
}

public _get_speed_level(id, params)
{
	return g_speed_level[get_param(1)]
}

public _get_gravity_level(id, params)
{
	return g_gravity_level[get_param(1)]
}

public _get_damage_level(id, params)
{
	return g_damage_level[get_param(1)]
}

public _get_stunshot_level(id, params)
{
	return g_stunshot_level[get_param(1)]
}

public _get_esquiva_level(id, params)
{
	return g_esquiva_level[get_param(1)]
}

public _get_granadas_level(id, params)
{
	return g_granadas_level[get_param(1)]
}

public _get_stamina_level(id, params)
{
	return g_stamina_level[get_param(1)]
}

public _get_hp_level(id, params)
{
	return g_hp_level[get_param(1)]
}

public _set_xp(id, params)
{
	new id = get_param(1)
	new xp = get_param(2)
	
	if( get_playersnum(1) >= get_pcvar_num(zmxp_minplayers) )
	{
		if(g_Party[id] != 0 && g_PertoLider[id])
			AddXPParty(id)
			
		g_xp[id] += xp
		g_xptotal[id] += xp
		g_xpround[id] += xp
	}
	
	return g_xp[id]
}
/* para uso interno */
public zmxp_get_user_rank(id)
{
	static data[1], sql[256]
	data[0] = id
	
	formatex(sql, 511, "SELECT `MEMBRO_KEY`, `XP_TOTAL` FROM `play_zombiexp` ORDER BY `XP_TOTAL` DESC")
	return SQL_ThreadQuery(gDbTuple, "ZombieRank", sql, data, 2)
}

public zmxp_get_user_rank_semanal(id)
{
	static data[1], sql[256]
	data[0] = id
	
	formatex(sql, 511, "SELECT `MEMBRO_KEY`, `XP_SEMANAL` FROM `play_zombiexp` ORDER BY `XP_SEMANAL` DESC")
	return SQL_ThreadQuery(gDbTuple, "ZombieRank2", sql, data, 2)
}

public ZombieRank( failstate, Handle:Query, error[], errcode, data[], datasize, Float:queuetime ){
	new id = data[0]

	switch( failstate ){
		case TQUERY_CONNECT_FAILED:	return set_fail_state("[RANK] Could not connect to the SQL Database")
		case TQUERY_QUERY_FAILED:	return set_fail_state("[RANK] The table Query Failed")
	}

	if(errcode) return log_amx("[RANK] Error on Query: %s", error)

	new dbkey[ 32 ], rank
	totalrank = SQL_NumResults( Query );

	/*
	
	if( is_user_steam( id ))
		get_user_authid( id, auth, charsmax( auth ));
	*/
	
	static auth[ 64 ];
	get_user_key( id, auth, charsmax( auth ));
	
	while( SQL_MoreResults( Query )){
		rank++;
		
		SQL_ReadResult( Query, 0, dbkey, 31);
		if( equal( dbkey, auth ))
			break;
		
		SQL_NextRow( Query );
	}

	g_rank[ id ] = rank;
	
	Print(id, "^1 %L", id, "ZMXP_MENSAGEM1", g_rank[id], totalrank, g_xptotal[id])
	return g_rank[ id ];
}

public ZombieRank2( failstate, Handle:Query, error[], errcode, data[], datasize, Float:queuetime ){
	new id = data[0]

	/*switch(failstate)
	{
		case TQUERY_CONNECT_FAILED:	return set_fail_state("[RANK] Could not connect to the SQL Database")
		case TQUERY_QUERY_FAILED:	return set_fail_state("[RANK] The table Query Failed")
	}*/

	if(errcode) return log_amx("[RANK] Error on Query: %s", error)

	new dbkey[32], rank, xpsemanal[ 32 ];
	
	new xpsemanal2 = 0
	totalrank = SQL_NumResults( Query );
	
	/*
	static auth[ 64 ];
	if( is_user_steam( id ))
		get_user_authid( id, auth, charsmax( auth ));
	*/
	
	static auth[ 64 ];
	get_user_key( id, auth, charsmax( auth ));
	
	while( SQL_MoreResults( Query )){
		rank++;
		
		SQL_ReadResult( Query, SQL_FieldNameToNum( Query, "ID"), dbkey, sizeof( dbkey ) - 1);
		SQL_ReadResult( Query, SQL_FieldNameToNum( Query, "XP_SEMANAL"), xpsemanal, sizeof( xpsemanal ) - 1);
		
		xpsemanal2 = str_to_num( xpsemanal );
		if( equal( dbkey, auth ))
			break;
		
		SQL_NextRow( Query );
	}
	
	g_rank_semanal[id] = rank
	
	Print(id, "^1 %L", id, "ZMXP_MENSAGEM32", g_rank_semanal[id], totalrank, xpsemanal2)
	return g_rank_semanal[id]
}

// ========================================
// Event Damage
// ========================================

public Event_Damage( iVictim )
{
	if( (read_data(4) || read_data(5) || read_data(6)) )
	{
		new id = get_user_attacker(iVictim)
		if( (1 <= id <= gServersMaxPlayers) && g_UserConnected[id] && JogadorVIP[id])
		{
			new iPos = ++g_iPlayerPos[id]
			if( iPos == sizeof(g_flCoords) )
			{
				iPos = g_iPlayerPos[id] = 0
			}
			set_hudmessage(0, 40, 80, Float:g_flCoords[iPos][0], Float:g_flCoords[iPos][1], 0, 0.1, 2.5, 0.02, 0.02, -1)
			show_hudmessage(id, "%d", read_data(2))
		}
	}
}

public Mostrar_na_Hud(id, red, green, blue, const mensagem[ ], any:...)
{
	new iPos = ++g_iPlayerPos[id]
	if( iPos == sizeof(g_flCoords) )
	{
		iPos = g_iPlayerPos[id] = 0
	}
	
	set_hudmessage(red, green, blue, Float:g_flCoords[iPos][0], Float:g_flCoords[iPos][1], 0, 0.1, 2.5, 0.02, 0.02, -1)
	show_hudmessage(id, "%s", mensagem)
}

// ========================================
// Client Connect e Disconnect
// ========================================

public client_putinserver(id)
{
	if (1 < id > gServersMaxPlayers ) return
	
	remove_task(id + 9111)
	g_xp[id] = 0
	g_xptotal[id] = 0
	g_level[id] = 0
	g_rank[id] = 0
	g_rank_semanal[id] = 0
	g_xpround[id] = 0
	g_aps[id] = 0
	g_apsround[id] = 0
	g_infects[id] = 0
	g_aura[id] = true
	g_ammo_level[id] = 0
	g_armor_level[id] = 0
	g_speed_level[id] = 0
	g_gravity_level[id] = 0
	g_damage_level[id] = 0
	g_stunshot_level[id] = 0
	g_esquiva_level[id] = 0
	g_granadas_level[id] = 0
	g_stamina_level[id] = 0
	g_hp_level[id] = 0
	
	g_player_carregado[id] = false
	g_UserConnected[id] = true
	
	g_Party[id] = 0
	g_PartyOwner[id] = false
	
	if( get_user_flags( id ) & ADMIN_RESERVATION /*is_user_admin(id)*/)
	{
		JogadorVIP[id] = true
	}
	else JogadorVIP[id] = false
}

public client_disconnect(id)
{
	if (1 < id > gServersMaxPlayers ) return
	
	remove_task(id + 9111)
	
	g_xp[id] = 0
	g_xptotal[id] = 0
	g_level[id] = 0
	g_rank_semanal[id] = 0
	g_xpround[id] = 0
	g_aps[id] = 0
	g_apsround[id] = 0
	g_infects[id] = 0
	g_ammo_level[id] = 0
	g_armor_level[id] = 0
	g_speed_level[id] = 0
	g_gravity_level[id] = 0
	g_damage_level[id] = 0
	g_stunshot_level[id] = 0
	g_esquiva_level[id] = 0
	g_granadas_level[id] = 0
	g_stamina_level[id] = 0
	
	DestroyParty(id, true)
	
	g_UserConnected[id] = false
	g_Party[id] = 0
	g_PartyOwner[id] = false
}
// ==============================================
// Comando para dar os APs para o melhor ZM do mapa, executado pelo Galileo
// ==============================================
public zp_thebestzmha(id, level, cid)
{
	if (!cmd_access(id, level, cid, 1))
		return PLUGIN_HANDLED;

	if ( get_playersnum(1) <= 12 ) return PLUGIN_HANDLED; // Pelo menos 13 pessoas no servidor ok
	
	new maior = 0
	for(new i = 0; i < sizeof g_infects; i++)
	{
		if(g_infects[i] > g_infects[maior]) maior = i;
	}
	
	if(!g_UserConnected[maior]) return PLUGIN_HANDLED;
	 
	static thebestzm[32]
	get_user_name(maior, thebestzm, 31)
	
	 
	client_print(0, print_chat, "========================================================================")
	Print(0, "^1 %L", LANG_PLAYER, "ZMXP_MENSAGEM2", thebestzm, g_infects[maior])
	Print(maior, "^1 %L", maior, "ZMXP_MENSAGEM3", g_infects[maior])
	 
	new ammopackz = zp_get_user_ammo_packs(maior)
	zp_set_user_ammo_packs(maior, ammopackz + g_infects[maior])
	 
	// Resetar geral por segurança
	for (new idx = 1; idx <= gServersMaxPlayers; idx++) g_infects[idx] = 0 
	return PLUGIN_HANDLED;
}

// ========================================
// Comando no menu principal (/xp)
// ========================================

public CmdMainMenu(id)
{
	if(registro_user_liberado(id))
	{
		Menu1(id)
	}
	else Print(id, "^1 %L", id, "ZMXP_MENSAGEM4")
}

// ========================================
// Comandos de LEVEL
// ========================================

public mostrar_rank(id)
{
	if(!g_UserConnected[id]) return
	
	if( g_rank[id] == 0 )
	{
		/* jogador ainda nao perguntou qual rank eh... la vamos nós pra query */
		zmxp_get_user_rank(id)
	}
	else
	{
		Print(id, "^1 %L", id, "ZMXP_MENSAGEM1", g_rank[id], totalrank, g_xptotal[id])
	}
}

public mostrar_rank_semanal(id)
{
	if(!g_UserConnected[id]) return
	
	zmxp_get_user_rank_semanal(id)
}

public pegar_porcentagem(id)
{	
	g_level[id] = g_xptotal[id] / 3000
	new fakeporcentagem = percent(g_xptotal[id], 3000)
	new realporcentagem = g_level[id] * 100
	
	return fakeporcentagem - realporcentagem
}

stock percent(is, of)
{
	return (of != 0) ? floatround(floatmul(float(is)/float(of), 100.0)) : 0
}

public say_aura(id)
{
	if( g_level[id] > 99 ) /* level 100 pra cima... óbvio */
	{
		if(g_aura[id]) /* já tem aura ativada, vamos desativar */
		{
			g_aura[id] = false
			Print(id, "^1 %L", id, "ZMXP_MENSAGEM6")
		}
		else /* vamos ativar denovo */
		{
			g_aura[id] = true
			Print(id, "^1 %L", id, "ZMXP_MENSAGEM5")
		}
	}
}

// ========================================
// Evitar que otários comprem item e depois 
// disconnect sem perder nada.
// ========================================

public zp_extra_item_selected(id, itemid)
{
	if( g_UserConnected[id] )
	{
		SalvarJogador(id)
	}
}

// ========================================
// Bônus pro time que ganhou o round.
// ========================================

public zp_round_ended(TimeVencedor)
{
	if ( get_playersnum(1) <= get_pcvar_num(zmxp_minplayers) ) return
	
	// XP Para human que sobreviveu ou ganhou round + quanto de XP/AP fez no round
	new xp = get_pcvar_num(cvar_xp_winround)
	new exp = get_pcvar_num( cvar_exp_patente_winround );
	
	// Quem fez mais XP e APs no Round!
	new maior = 0
	
	for(new i = 0; i < sizeof g_xpround; i++)
	{
		if(g_xpround[i] > g_xpround[maior]) maior = i;
	}	
	
	if(g_UserConnected[maior])
	{
		static namexp[32]
		get_user_name(maior, namexp, 31)
		
		Print(0, "^1 %L", LANG_PLAYER, "ZMXP_MENSAGEM7", namexp, g_xpround[maior])
	}

	for (new id = 1; id <= gServersMaxPlayers; id++) 
	{
		if(g_UserConnected[id])
		{
			if ( cs_get_user_team(id) == CS_TEAM_CT && is_user_alive(id)) {
			
				xp = get_pcvar_num(cvar_xp_winround)
				exp = get_pcvar_num( cvar_exp_patente_winround );
			
				g_xp[id] += xp
				g_xpround[id] += xp
				g_xptotal[id] += xp
				Print(id, "^1 %L", id, "ZMXP_MENSAGEM8", xp)
				Print(id, "Voce ganhou %i EXP para sua Patente por ganhar ou sobreviver esse round!", exp)
			}
		
			new levelnovo = g_xptotal[id] / 3000
			if ( levelnovo > g_level[id] )
			{
				g_level[id] = g_xptotal[id] / 3000
				Print(id, "^1 %L", id, "ZMXP_MENSAGEM9", g_level[id])
				client_cmd(id, "speak events/task_complete.wav")
			}
		
			new packsnovos = zp_get_user_ammo_packs( id );

			Print(id, "^1 %L", id, "ZMXP_MENSAGEM10", g_xpround[id], (packsnovos - g_apsround[id]))
			
			if(g_xpround[id] > 0 && has_guild(id))
			{
				new PontosGuild = (g_xpround[id] / 3) // 30% da XP vai para pontos da guild
				new BankGuild = (g_xpround[id] / 115) // 1% da XP vai em forma de packs para o banco
				set_member_points(id, PontosGuild, BankGuild)
			}
			
			SalvarJogador(id)
		}
	}
}

// ======================================================
// Dar HP pra zombies que possuem Habilidade de Colete.
// ======================================================

public zp_user_infected_post( id, infector, nemesis )
{
	remove_task(id + 9111)
	
	if ( !infector || nemesis )
		return
	
	new life = g_armor_maxamount * g_armor_level[id] / g_armor_maxlevels;
	if( life )
	{
		fm_set_user_health2(id, (pev(id, pev_health) + life * 3))
	}
}

public zp_user_humanized_post(id, survivor)
{
	IniciarTaskDarGranada(id)
	
	new armor = g_armor_maxamount * g_armor_level[id] / g_armor_maxlevels;
	if( armor)
	{
		set_pev(id, pev_armorvalue, float(armor))
	}
}

/* Coloquei pre por que tem a funcao de verificar se eh o ultimo humano.. */
public zp_user_infected_pre(id, infector, nemesis)
{
	if ( get_playersnum(1) <= get_pcvar_num(zmxp_minplayers) ) return
	if ( !infector || nemesis )
		return	
	
	if(g_UserConnected[infector])// pode ser bomb, etc..
	{ 			
		// regular kill - zombie
		new xp = get_pcvar_num(cvar_xp_kill_zombie)
		new exp = get_pcvar_num( cvar_exp_patente_kill_zombie );
		
		if(is_user_admin(infector)) // #VIP
		{
			xp = get_pcvar_num(cvar_xp_kill_zombie_vip)
			exp = get_pcvar_num( cvar_exp_patente_kill_zmvip );
		}
		
		g_xp[infector] += xp
		g_xptotal[infector] += xp
		g_xpround[infector] += xp
		Print(infector, "^1 %L", infector, "ZMXP_MENSAGEM11", xp);
		
		play_set_user_exp( infector, play_get_user_exp( infector ) + exp );
		Print( infector, "Voce ganhou %i EXP para sua PATENTE, por infectar alguem!", exp)
		
		if ( !zp_get_user_nemesis(infector) ) // não pode ser Nemesis
		{
			g_infects[infector] += 1
		}
	}
}

// ========================================
// Loop pra Munição Automatica
// ========================================

public add_bullets()
{
	static players[32], playerCount, player, i
	get_players(players, playerCount, "ach")
	new ca
	for ( i = 0; i < playerCount; i++ )
	{
		player = players[i]	
		
		if( cs_get_user_team(player) == CS_TEAM_CT && g_ammo_level[player] )
		{
			switch(get_user_weapon(player))
			{
				case CSW_P228 : ca = 13;
				case CSW_SCOUT : ca = 10;
				case CSW_MAC10 : ca = 30;
				case CSW_AUG : ca = 30;
				case CSW_ELITE : ca = 30;
				case CSW_FIVESEVEN : ca = 20;
				case CSW_UMP45 : ca = 25;
				case CSW_SG550 : ca = 30;
				case CSW_GALI : ca = 35;
				case CSW_FAMAS : ca = 25;
				case CSW_USP : ca = 12;
				case CSW_GLOCK18 : ca = 20;
				case CSW_AWP : ca = 10;
				case CSW_MP5NAVY : ca = 30;
				case CSW_M249 : ca = 100;
				case CSW_M3 : ca = 8;
				/*case CSW_XM1014 : ca = 7; */ // Apelo de mais!
				/*case CSW_DEAGLE : ca = 7; */ // Apelo de mais? sim. -.-
				case CSW_M4A1 : ca = 30;
				case CSW_TMP : ca = 30;
				case CSW_G3SG1 : ca = 20;
				case CSW_SG552 : ca = 30;
				case CSW_AK47 : ca = 30;
				case CSW_P90 : ca = 50;
				default: continue
			}
			
			if(pev_valid(player) == PDATA_SAFE)
			{
				new currentAmmo = cs_get_weapon_ammo(get_pdata_cbase( player, 373 ))
				new newAmmo = currentAmmo + g_ammo_maxamount * g_ammo_level[player] / g_ammo_maxlevels;
				
				if (newAmmo <= ca)
				{
					cs_set_weapon_ammo(get_pdata_cbase( player, 373 ), newAmmo)
				}
				else
				{
					cs_set_weapon_ammo(get_pdata_cbase( player, 373 ), ca)
				}
			}
		}
	}
}
#define TASK_WELCOMEMSG 582222
// ========================================
// Evento de Round Start para Ammo packs
// ========================================
public EventRoundStart(){
	SQL_FreeHandle( gDbTuple );
	#include "play4ever.inc/play_conecta.play"
	
	// Show welcome message and T-Virus notice
	remove_task(TASK_WELCOMEMSG)
	set_task(2.0, "welcome_msg", TASK_WELCOMEMSG)
	
	/* Pegar o número de Ammo packs no começo do round */
	for( new id = 1; id <= gServersMaxPlayers; id++ ){
		g_apsround[id] = 0;
		g_xpround[id] = 0;
		g_apsround[id] = zp_get_user_ammo_packs( id );
	}
}


#define HAPPY_START	23
#define HAPPY_END		10

// Welcome Message Task
public welcome_msg()
{
	// happy hour check
	static data[3]
	get_time("%H", data, 2)
	
	if(( str_to_num(data) <= HAPPY_END || str_to_num(data) >= HAPPY_START ) || get_pcvar_num( cvar_happyhour_on ) == 1 ) // ativado
	{
		if(g_happyhour == 0) // estava desativado.
		{
			server_cmd("hostname ^"- CSP Gaming #03 [ Zombie-XP ]( Happy Hour ) - www.cspgaming.com.br @CPLGames^"")
			set_cvar_num("zmxp_xp_damage", 225)
			set_cvar_num("zmxp_xp_damage_vip", 193)
			set_cvar_num("zmxp_xp_lasthuman", 20)
			set_cvar_num("zmxp_xp_winround", 24)
			set_cvar_num("zmxp_xp_kill_zombie", 20)
			set_cvar_num("zmxp_xp_kill_zombie_diamond", 30)
			set_cvar_num("play_exp_patente_lasthuman", 8)
			set_cvar_num("play_exp_patente_winround", 3)
			set_cvar_num("play_exp_patente_kill_zombie_vip", 3)
			set_cvar_num("play_exp_patente_kill_zombie", 3)
			set_cvar_num("zp_human_damage_reward", 650)
			set_cvar_num("zp_zombie_infect_reward", 4)
		}
		g_happyhour = 1
		Print(0, "^x03[^x04HAPPY HOUR ATIVADO! +XP e +Packs ate as %dh00!^x03]", HAPPY_END)	
	}
	else
	{
		if(g_happyhour == 1) // estava ativado.
		{
			// Get configs dir
			new cfgdir[32]
			get_configsdir(cfgdir, charsmax(cfgdir))
			
			// Execute config file (zombieplague.cfg)
			server_cmd("exec %s/zombieplague.cfg", cfgdir)
			
			Print(0, "^x04[^x03HAPPY HOUR ACABOU! Comeca novamente as %dh00!^x04]", HAPPY_START)
			server_cmd("hostname ^"- CSP Gaming #03 [ Zombie-XP ] - www.cspgaming.com.br @CPLGames^"")
		}
		
		g_happyhour = 0
	}
}

// ========================================
// Evento de Death para XP
// ========================================
public EventDeathMsg(){	
	if ( get_playersnum(1) <= get_pcvar_num(zmxp_minplayers) ) return
	new killer = read_data(1)
	new victim = read_data(2)
	
	if( g_UserConnected[killer] && victim != killer )
	{
		remove_task(victim + 9111)
		
		if( zp_get_user_zombie(killer) )
		{
			// regular kill - zombie
			new xp = get_pcvar_num(cvar_xp_kill_zombie);
			new exp = get_pcvar_num( cvar_exp_patente_kill_zombie );
			
			if( is_user_admin(killer) ) // #VIP
			{
				xp = get_pcvar_num(cvar_xp_kill_zombie_vip)
				exp = get_pcvar_num( cvar_exp_patente_kill_zombie );
			}
			
			if ( zp_get_user_last_human(victim) ) {
				xp = get_pcvar_num(cvar_xp_lasthuman) + get_pcvar_num(cvar_xp_kill_zombie);
				exp = get_pcvar_num( cvar_exp_patente_lasthumman ) + get_pcvar_num( cvar_exp_patente_kill_zombie );
			}
			
			g_xp[killer] += xp
			g_xptotal[killer] += xp
			g_xpround[killer] += xp
			Print(killer, "^1 %L", killer, "ZMXP_MENSAGEM11", xp)
			
			play_set_user_exp( killer, play_get_user_exp( killer ) + exp );
			Print(killer, "^1 Voce ganhou !t%i !nEXP para sua PATENTE, por infectar alguem!", exp)
			
			if ( zp_get_user_last_human(victim) ) {
				Print(killer, "^1 %L", killer, "ZMXP_MENSAGEM12", get_pcvar_num(cvar_xp_lasthuman))
			}
		}
	}
}

public TraceAttack(iVictim, iAttacker, Float:damage, Float:direction[3], traceresult, damagebits)
{   
	if( (0 < iVictim <= gServersMaxPlayers) && (0 < iAttacker <= gServersMaxPlayers ) )
	{
		if(!zp_get_user_zombie(iAttacker))
		{
			if(get_tr2(traceresult, TR_iHitgroup) == HIT_HEAD && g_stunshot_level[iAttacker])
			{	
				new x = g_stunshot_level[iAttacker] + g_stunshot_level[iAttacker] == 5 ? 3 : 2
				if(x >= random(100) && zp_get_user_zombie(iVictim))
				{
					zp_set_user_burning(iVictim, true)
					set_task(3.0, "elementaloff2", iVictim)
					Mostrar_na_Hud(iAttacker, 180, 0, 0, "Fire Shot!")
					return HAM_SUPERCEDE
				}
			}
		}
	}
	
	return HAM_IGNORED
}

public elementaloff2(id)
{
	if(is_user_alive(id))
		zp_set_user_burning(id, false)
}

// ========================================
// Evento quando o jogador nasce
// Dar HP/Colete/Gravity,  verifica se é sua primeira vez no servidor e da Load na XP.
// ========================================

public FwdPlayerSpawn(id)
{
	if ( !is_user_alive(id) ) return HAM_IGNORED
	if ( cs_get_user_team(id) == CS_TEAM_UNASSIGNED ) return HAM_IGNORED	
		
	if( g_armor_level[id])
	{
		set_task(2.0,"darcolete", id)
	}
		
	if(zp_get_user_zombie(id)) /* ninguem reclamou de bug com granada entao ta ok, dexa aki */
		return HAM_IGNORED		

	if(g_granadas_level[id])
		IniciarTaskDarGranada(id)
	
	return HAM_IGNORED
}

public darcolete(id)
{
	if( !is_user_alive(id) ) return
	
	if( zp_has_round_started() ) // round ja comecou, entao podemos verificar se é zombie, etc.
	{
		if( !zp_get_user_zombie(id) )
		{
			new armor = g_armor_maxamount * g_armor_level[id] / g_armor_maxlevels
			if( armor > 0 )
			{
				set_pev(id, pev_armorvalue, float(armor))
			}
			
			SetUserAura(id)
		}
		else
		{
			new life = g_armor_maxamount * g_armor_level[id] / g_armor_maxlevels
			if( life > 0 )
			{
				fm_set_user_health2(id, (pev(id, pev_health) + life * 3))
			}
		}
	}
	else // nao começou entao nao precisa verificar nada, nao existe zombie mesmo.
	{
		new armor = g_armor_maxamount * g_armor_level[id] / g_armor_maxlevels
		if( armor > 0 )
		{
			set_pev(id, pev_armorvalue, float(armor))
		}
		
		SetUserAura(id)
	}
}

SetUserAura(id)
{
	if( g_aura[id] ){
		if( g_level[id] > 1599 ){
			fm_set_rendering( id, kRenderFxGlowShell, 0, 0, 255, kRenderNormal, 5)
			return PLUGIN_HANDLED
		}
		
		if( g_level[id] > 1499 ){
			fm_set_rendering( id, kRenderFxGlowShell, 255, 215, 0, kRenderNormal, 5)
			return PLUGIN_HANDLED
		}
		
		if( g_level[id] > 1399 ){
			fm_set_rendering( id, kRenderFxGlowShell, 255, 165, 0, kRenderNormal, 5)
			return PLUGIN_HANDLED
		}
		
		if( g_level[id] > 1299 ){
			fm_set_rendering( id, kRenderFxGlowShell, 255, 0, 0, kRenderNormal, 5)
			return PLUGIN_HANDLED
		}
		
		if( g_level[id] > 1199 ){
			fm_set_rendering( id, kRenderFxGlowShell, 0, 255, 255, kRenderNormal, 5)
			return PLUGIN_HANDLED
		}
		
		if( g_level[id] > 1099 ){
			fm_set_rendering( id, kRenderFxGlowShell, 0, 139, 139, kRenderNormal, 5)
			return PLUGIN_HANDLED
		}
		
		if( g_level[id] > 999 ){
			fm_set_rendering( id, kRenderFxGlowShell, 255, 20, 147, kRenderNormal, 5)
			return PLUGIN_HANDLED
		}
		
		if( g_level[id] > 899 ){
			fm_set_rendering( id, kRenderFxGlowShell, 255, 185, 15, kRenderNormal, 5)
			return PLUGIN_HANDLED
		}
		
		if( g_level[id] > 899 ){
			fm_set_rendering( id, kRenderFxGlowShell, 0, 255, 127, kRenderNormal, 5)
			return PLUGIN_HANDLED
		}
		
		if( g_level[id] > 799 ){
			fm_set_rendering( id, kRenderFxGlowShell, 255, 255, 0, kRenderNormal, 5)
			return PLUGIN_HANDLED
		}
		
		if( g_level[id] > 699 ){
			fm_set_rendering( id, kRenderFxGlowShell, 255, 236, 139, kRenderNormal, 5)
			return PLUGIN_HANDLED
		}
		
		if( g_level[id] > 599 ){
			fm_set_rendering( id, kRenderFxGlowShell, 127, 255, 0, kRenderNormal, 5)
			return PLUGIN_HANDLED
		}
		
		if( g_level[id] > 499 ) /* aura para lvl 500+ (Azure3)*/
		{
			fm_set_rendering(id, kRenderFxGlowShell, 193, 205, 205, kRenderNormal, 5)
			return PLUGIN_HANDLED
		}		
		
		if( g_level[id] > 399 ) /* aura para lvl 400+ (Firebrick3)*/
		{
			fm_set_rendering(id, kRenderFxGlowShell, 205, 38, 38, kRenderNormal, 5)
			return PLUGIN_HANDLED
		}				
		
		if( g_level[id] > 299 ) /* aura para lvl 300+ (NavajoWhite)*/
		{
			fm_set_rendering(id, kRenderFxGlowShell, 255, 222, 173, kRenderNormal, 5)
			return PLUGIN_HANDLED
		}
		
		if( g_level[id] > 199 ) /* aura para lvl 200+ (DarkViolet)*/
		{
			fm_set_rendering(id, kRenderFxGlowShell, 148, 0, 211, kRenderNormal, 5)
			return PLUGIN_HANDLED
		}		
		
		if( g_level[id] > 99 ) /* aura para lvl 100+ (DeepSkyBlue3)*/ 
		{
			fm_set_rendering(id, kRenderFxGlowShell, 0, 154, 205, kRenderNormal, 5)
			return PLUGIN_HANDLED
		}
	}
	
	return PLUGIN_HANDLED
}

stock fm_set_rendering(entity, fx = kRenderFxNone, r = 255, g = 255, b = 255, render = kRenderNormal, amount = 16)
{
	static Float:color[3]
	color[0] = float(r)
	color[1] = float(g)
	color[2] = float(b)
	
	set_pev(entity, pev_renderfx, fx)
	set_pev(entity, pev_rendercolor, color)
	set_pev(entity, pev_rendermode, render)
	set_pev(entity, pev_renderamt, float(amount))
}

/*====================================== 
          Dano causado!
======================================*/

public FwdPlayerDamage(id, inflictor, attacker, Float:damage, damagebits)
{
	static Float:x;
	//static Float:exp;
	if( 0 < attacker <= gServersMaxPlayers )
	{
		if(!zp_get_user_zombie(attacker))
		{
			if(g_damage_level[attacker] && !zp_get_user_survivor(attacker))
			{
				switch(g_damage_level[attacker])
				{
					case 1: {
						x = 1.1;
						//exp = 1.0;
					}
					
					case 2: {
						x = 1.2;
						//exp = 1.1;
					}
					
					case 3: {
						x = 1.3;
						//exp = 1.2;
					}
					
					case 4: {
						x = 1.4;
						//exp = 1.3;
					}
					
					case 5: {
						x = 1.5;
						//exp = 1.4;
					}
				}
				
				damage *= x
				//damage *= exp
			}
			
			if(g_level[attacker] < 16) // Handcap
			{
				// Bônus de Damage para ajudar level baixo!
				damage *= 1.3
			}
		}
		
		if(zp_get_user_zombie(id))
		{
			if(!zp_get_user_nemesis(id) && g_damage_level[id])
			{
				switch(g_damage_level[id])
				{
					case 1: {
						x = 0.95
						//exp = 0.85;
					}
					
					case 2: {
						x = 0.90;
						//exp = 0.80;
					}
					
					case 3: {
						x = 0.85;
						//exp = 0.75;
					}
					
					case 4: {
						x = 0.80;
						//exp = 0.70;
					}
					
					case 5: {
						x = 0.75;
						//exp = 0.65;
					}
				}
				
				damage *= x
				//damage *= exp
			}
		}
		
		SetHamParamFloat(4, damage)
		
		if(g_esquiva_level[id])
		{
			switch(g_esquiva_level[id])
			{
				case 1: {
					x = 2.0;
				}
				
				case 2: x = 4.0
				case 3: x = 6.0
				case 4: x = 8.0
				case 5: x = 9.0
				default: return
			}
			
			if (floatround(x) >= random(100))
			{
				SetHamParamFloat(4, 0.0)
				Mostrar_na_Hud(id, 255, 128, 0, "ESQUIVOU!")
			}
		}
		
		x = get_pcvar_float(cvar_xp_damage);
		
		if(JogadorVIP[attacker]) // #VIP
		{
			x = get_pcvar_float(cvar_xp_damage_vip)
		}
		
		g_iDamageFeito[attacker] += floatround(damage)
		
		while (g_iDamageFeito[attacker] > x)
		{
			if( get_playersnum(1) >= get_pcvar_num(zmxp_minplayers) )
			{
				if(g_Party[attacker] != 0 && g_PertoLider[attacker])
					AddXPParty(attacker)
				
				g_xp[attacker] += 2
				g_xptotal[attacker] += 2
				g_xpround[attacker] += 2
				
				Mostrar_na_Hud(attacker, 0, 180, 0, "+XP")
			}
			
			g_iDamageFeito[attacker] -= x
		}		
	}
}

/*======================================
[Mostrar Menu Principal]
======================================*/

public Menu1(id)
{
	static title[158]
	formatex(title, sizeof(title) - 1, "\w[\yCSP Gaming \rZombieXP 3.0\w]^nXP: \r%i \w| LEVEL: \r%i \y(%i%%) \w| XP TOTAL: \r%i\y", g_xp[id], g_level[id], pegar_porcentagem(id), g_xptotal[id])
	
	new menu = menu_create(title, "menu_handler1")
	menu_additem(menu, "\wMenu de Upgrades", "1", 0)	
	menu_additem(menu, "\wMinha Conta", "2", 0)
	menu_additem(menu, "\yRanks / TOP Players", "3", 0)
	menu_additem(menu, "\wInfo. Players^n", "5")
	menu_additem(menu, "\yLista Online^n", "6")
	menu_additem(menu, "\wAjuda", "4", 0)
	
	menu_setprop(menu, MPROP_EXITNAME, "Sair")
	menu_display(id, menu, 0)
}

public menu_handler1(id, menu, item)
{
	if (item == MENU_EXIT)
	{
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}
	
	static data[6], iName[64]
	new access, callback
	menu_item_getinfo(menu, item, access, data,5, iName, 63, callback)
	
	new key = str_to_num(data)
	switch(key)
	{
		case 1:
		{			
			ShowMainMenu(id)
			menu_destroy(menu)
			return PLUGIN_HANDLED			
		}	
		case 2:
		{			
			client_cmd(id, "login")
			menu_destroy(menu)
			return PLUGIN_HANDLED		
		}
		case 3:
		{
			client_cmd(id, "top15_menu")
			menu_destroy(menu)
			return PLUGIN_HANDLED			
		}
		case 4:
		{			
			show_motd(id, "ajudamotd.html", "Sobre o Servidor")
			menu_destroy(menu)
			return PLUGIN_HANDLED
		}
		case 5:
		{
			ShowPlayerMenu(id)
			menu_destroy(menu)
			return PLUGIN_HANDLED			
		}
		case 6:
		{
			ListonaOnline(id)
			menu_destroy(menu)
			return PLUGIN_HANDLED			
		}	
	}
	
	menu_destroy(menu)
	return PLUGIN_HANDLED
}

public ShowMainMenu( id ){
	static title[158], option[64]
	formatex(title, sizeof(title) - 1, "\d%s ZombieXP:^nXP: \r%i \w| LEVEL: \r%i \y(%i%%) \w| XP TOTAL: \r%i\y", xPrefix, g_xp[id], g_level[id], pegar_porcentagem(id), g_xptotal[id])
	new menu = menu_create(title, "MenuMain")
	
	switch( g_armor_level[ id ]){
		case 1: menu_additem( menu, "\r Colete \d[Nivel 1]", "0");
		case 2: menu_additem( menu, "\r Colete \d[Nivel 2]", "0");
		case 3: menu_additem( menu, "\r Colete \d[Nivel 3]", "0");
		case 4: menu_additem( menu, "\r Colete \d[Nivel 4]", "0");
		case 5: menu_additem( menu, "\r Colete \d[Completo]", "0");
		default: menu_additem( menu, "\r Colete \d[Nivel 0]", "0");
	}	
	
	switch( g_speed_level[ id ]){
		case 1: menu_additem(menu, "\r Velocidade \d[Nivel 1]", "1")
		case 2: menu_additem(menu, "\r Velocidade \d[Nivel 2]", "1")
		case 3:{
			formatex(option, sizeof(option) - 1, "\r Velocidade \d[Nivel 3]")
			menu_additem(menu, option, "1")
		}
		
		case 4:{
			formatex(option, sizeof(option) - 1, "\r Velocidade \d[Nivel 4]")
			menu_additem(menu, option, "1")
		}
		
		case 5:{
			formatex(option, sizeof(option) - 1, "\r Velocidade \d[Completo]")
			menu_additem(menu, option, "1")
		}
		
		default:{
			formatex(option, sizeof(option) - 1, "\r Velocidade \d[Nivel 0]")
			menu_additem(menu, option, "1")
		}
	}	
	
	switch(g_gravity_level[id]){
		case 1:{
			formatex(option, sizeof(option) - 1, "\r Gravidade \d[Level 1]")
			menu_additem(menu, option, "2")
		}
		
		case 2:{
			formatex(option, sizeof(option) - 1, "\r Gravidade \d[Level 2]")
			menu_additem(menu, option, "2")
		}
		
		case 3:{
			formatex(option, sizeof(option) - 1, "\r Gravidade \d[Level 3]")
			menu_additem(menu, option, "2")
		}
		
		case 4:{
			formatex(option, sizeof(option) - 1, "\r Gravidade \d[Level 4]")
			menu_additem(menu, option, "2")
		}
		
		case 5:{
			formatex(option, sizeof(option) - 1, "\r Gravidade \d[FULL]")
			menu_additem(menu, option, "2")
		}
		
		default:{
			formatex(option, sizeof(option) - 1, "\r Gravidade \d[Level 0]")
			menu_additem(menu, option, "2")
		}
	}
	
	switch(g_ammo_level[id]){
		case 1: menu_additem(menu, "\r Municao \d[Nivel 1]", "3");
		case 2: menu_additem(menu, "\r Municao \d[Nivel 2]", "3");
		case 3: menu_additem(menu, "\r Municao \d[Completo]", "3");
		default: menu_additem(menu, "\r Municao \d[Nivel 0]", "3");
	}
	
	switch(g_damage_level[id]){		
		case 1: menu_additem(menu, "-> Damage \y[Level 1]", "4")
		case 2: menu_additem(menu, "-> Damage \y[Level 2]", "4")
		case 3: menu_additem(menu, "-> Damage \y[Level 3]", "4")
		case 4: menu_additem(menu, "-> Damage \y[Level 4]", "4")
		case 5: menu_additem(menu, "-> Damage \r[FULL]", "4")
		default: menu_additem(menu, "-> Damage \d[Level 0]", "4")
	}
	
	switch(g_stunshot_level[id])
	{
		case 1: menu_additem(menu, "-> Elemental Shot \y[Level 1]", "5")
		case 2: menu_additem(menu, "-> Elemental Shot \y[Level 2]", "5")
		case 3: menu_additem(menu, "-> Elemental Shot \y[Level 3]", "5")
		case 4: menu_additem(menu, "-> Elemental Shot \y[Level 4]", "5")
		case 5: menu_additem(menu, "-> Elemental Shot \r[FULL]", "5")
		default: menu_additem(menu, "-> Elemental Shot \d[Level 0]", "5")
	}
	
	switch(g_esquiva_level[id])
	{
		case 1: menu_additem(menu, "-> Esquiva \y[Level 1]", "6")
		case 2: menu_additem(menu, "-> Esquiva \y[Level 2]", "6")
		case 3: menu_additem(menu, "-> Esquiva \y[Level 3]", "6")
		case 4: menu_additem(menu, "-> Esquiva \y[Level 4]", "6")
		case 5: menu_additem(menu, "-> Esquiva \r[FULL]", "6")
		default: menu_additem(menu, "-> Esquiva \d[Level 0]", "6")
	}
	
	switch(g_granadas_level[id])
	{
		case 1: menu_additem(menu, "-> Granadas \y[Level 1]", "7")
		case 2: menu_additem(menu, "-> Granadas \y[Level 2]", "7")
		case 3: menu_additem(menu, "-> Granadas \y[Level 3]", "7")
		case 4: menu_additem(menu, "-> Granadas \y[Level 4]", "7")
		case 5: menu_additem(menu, "-> Granadas \r[FULL]", "7")
		default: menu_additem(menu, "-> Granadas \d[Level 0]", "7")
	}
	
	switch(g_stamina_level[id])
	{
		case 1: menu_additem(menu, "-> Stamina \y[Level 1]", "8")
		case 2: menu_additem(menu, "-> Stamina \y[Level 2]", "8")
		case 3: menu_additem(menu, "-> Stamina \y[Level 3]", "8")
		case 4: menu_additem(menu, "-> Stamina \y[Level 4]", "8")
		case 5: menu_additem(menu, "-> Stamina \r[FULL]", "8")
		default: menu_additem(menu, "-> Stamina \d[Level 0]", "8")
	}
	
	switch(g_hp_level[id])
	{
		case 1: menu_additem(menu, "-> HP \y[Level 1]^n", "9")
		case 2: menu_additem(menu, "-> HP \y[Level 2]^n", "9")
		case 3: menu_additem(menu, "-> HP \y[Level 3]^n", "9")
		case 4: menu_additem(menu, "-> HP \y[Level 4]^n", "9")
		case 5: menu_additem(menu, "-> HP \r[FULL]^n", "9")
		default: menu_additem(menu, "-> HP \d[Level 0]^n", "9")
	}
	
	new iTemp[ 128 ];
	
	if()
	formatex()

	
	
	menu_setprop( menu, MPROP_NEXTNAME, "\r Proximo" );
	menu_setprop( menu, MPROP_BACKNAME, "\r Voltar" );
	menu_setprop( menu, MPROP_EXITNAME, "\r Sair" );
	
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL)
	menu_setprop( menu, MPROP_NUMBER_COLOR, "\d" );
	menu_display( id, menu, 0 );
	
	/*
	menu_setprop(menu, MPROP_PERPAGE, 5)
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL)
	
	formatex(option, sizeof(option) - 1, "Proximo")
	menu_setprop(menu, MPROP_NEXTNAME, option)
	formatex(option, sizeof(option) - 1, "Voltar")
	menu_setprop(menu, MPROP_BACKNAME, option)
	formatex(option, sizeof(option) - 1, "Sair")
	menu_setprop(menu, MPROP_EXITNAME, option)		
	menu_display(id, menu)
	*/
}

public MenuMain(id, menu, item)
{
	if( item == MENU_EXIT )
	{
		menu_destroy(menu);
		return;
	}
	
	static _access, info[4], callback;
	menu_item_getinfo(menu, item, _access, info, sizeof(info) - 1, _, _, callback);
	menu_destroy(menu);
	
	switch( info[0] )
	{
		case '0':
		{
			ShowArmorMenu(id)
		}
		case '1':
		{
			ShowSpeedMenu(id)
		}
		case '2':
		{
			ShowGravityMenu(id)
		}
		case '3':
		{
			ShowAmmoMenu(id)
		}		
		case '4':
		{
			ShowDamageMenu(id)
		}
		case '5':
		{
			ShowStunShotMenu(id)
		}
		case '6':
		{
			ShowEsquivaMenu(id)
		}
		case '7':
		{
			ShowGranadasMenu(id)				
		}
		case '8':
		{
			ShowStaminaMenu(id)				
		}
		case '9':
		{
			ShowHPMenu(id)				
		}		
	}
}

// ========================================
// Mostrar Menu de Colete-Extra!
// ========================================

ShowArmorMenu(id)
{
	static title[128]
	formatex(title, sizeof(title) - 1, "%L", id, "ZMXP_MENU23", g_xp[id])
	new menu = menu_create(title, "MenuArmor")
	new callback = menu_makecallback("CallbackArmor")
	
	menu_additem(menu, "\yAjuda", "*", _, callback)
	
	static levelv, level, xp, amount, item[128], /*info[4],*/ venda[128]
	level = g_armor_level[id] + 1
	levelv = g_armor_level[id]
	amount = g_armor_maxamount * level / g_armor_maxlevels
			
	if( g_armor_level[id] < g_armor_maxlevels )
	{
		xp = g_armor_first_xp * (1 << (level - 1))
		formatex(item, sizeof(item) - 1, "%L", id, "ZMXP_MENU20", g_armor_names, level, amount, xp)
	}
	else
	{
		formatex(item, sizeof(item) - 1, "%L", id, "ZMXP_MENU21", g_armor_names, g_armor_level[id])
	}
	
	if( g_armor_level[id])
	{
		xp = g_armor_first_xp * (1 << (levelv - 1))
		new valor = (xp * 70) / 100
		formatex(venda, sizeof(venda) - 1, "%L", id, "ZMXP_MENU22", g_armor_names, g_armor_level[id], valor)
	}
			
	//num_to_str(1, info, sizeof(info) - 1)
			
	menu_additem(menu, item, "1", _, callback)
	
	if( g_armor_level[id])
	{
		menu_additem(menu, venda, "$", _, callback)
	}
	
	menu_setprop(menu, MPROP_EXITNAME, "Sair")
	
	menu_display(id, menu);
}

public MenuArmor(id, menu, item)
{
	if( item == MENU_EXIT )
	{
		menu_destroy(menu)
		ShowMainMenu(id)
		return
	}
	
	static _access, info[4], callback
	menu_item_getinfo(menu, item, _access, info, sizeof(info) - 1, _, _, callback)
	menu_destroy(menu);
	
	if( info[0] == '*' ) // ajuda
	{
		static motd[600]
		new len = formatex(motd, sizeof(motd) - 1,	"<body style=^"background-color:#030303; color:#FF8F00^">")
		len += format(motd[len], sizeof(motd) - len - 1,	"<p align=^"center^">")
		len += format(motd[len], sizeof(motd) - len - 1,	"<img border=^"0^" src=^"http://i237.photobucket.com/albums/ff123/SkiesOFF/zombiexp.png^" width=^"375^" height=^"119^"><br>")
		len += format(motd[len], sizeof(motd) - len - 1,	"Upgrade que lhe da mais Colete por Level.<br>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<br>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<table>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<tr>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<th></th>")
		len += format(motd[len], sizeof(motd) - len - 1,	"</tr>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<tr>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<th>%L</th>", id, "ZMXP_MENSAGEM30")
		len += format(motd[len], sizeof(motd) - len - 1,	"<td>%i</td>", (g_armor_maxamount / g_armor_maxlevels))
		len += format(motd[len], sizeof(motd) - len - 1,	"</tr>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<tr>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<th>%L</th>", id, "ZMXP_MENSAGEM31")
		len += format(motd[len], sizeof(motd) - len - 1,	"<td>%i</td>", g_armor_maxlevels)
		len += format(motd[len], sizeof(motd) - len - 1,	"</tr>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<th>Colete Máximo</th>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<td>+%i</td>", g_armor_maxamount)
		len += format(motd[len], sizeof(motd) - len - 1,	"</tr>")
		len += format(motd[len], sizeof(motd) - len - 1,	"</table>")
		len += format(motd[len], sizeof(motd) - len - 1,	"</p>")
		len += format(motd[len], sizeof(motd) - len - 1,	"</body>")
		
		show_motd(id, motd, "Zombie XP Colete Info")
	}
	else if( info[0] == '$' ) // vender
	{	
		new level = g_armor_level[id]
		new xp = g_armor_first_xp * (1 << (level - 1))
		new valor = (xp * 70) / 100
		new amount = g_armor_maxamount * level / g_armor_maxlevels
		
		g_xp[id] += valor
		g_armor_level[id]--
		
		new data[64]
		new len = formatex(data, sizeof(data) - 1, "%i", g_armor_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_ammo_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_speed_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_gravity_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_damage_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_stunshot_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_esquiva_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_granadas_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_stamina_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_hp_level[id])
		
		copy(g_upgrades[id], charsmax(g_upgrades[]), data)
		
		// Atualizar o Jogador na memoryTable
		SalvarJogador(id)
		
		Print(id, "^1 %L", id, "ZMXP_MENU24", g_armor_names, level, amount, valor)
		
		new nick[33], auth[33]
		get_user_name(id, nick, charsmax(nick))
		get_user_authid(id, auth, charsmax(auth))
		Log("[SAVE] NICK: %s | AUTHID: %s - vendeu level %i de Colete", nick, auth, level)
	}
	else if( info[0] == '1' ) // comprar
	{	
		new level = g_armor_level[id] + 1
		new xp = g_armor_first_xp * (1 << (level - 1))
		new amount = g_armor_maxamount * level / g_armor_maxlevels
		
		g_xp[id] -= xp
		g_armor_level[id] = level
		
		new data[64]
		new len = formatex(data, sizeof(data) - 1, "%i", g_armor_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_ammo_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_speed_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_gravity_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_damage_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_stunshot_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_esquiva_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_granadas_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_stamina_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_hp_level[id])
		
		copy(g_upgrades[id], charsmax(g_upgrades[]), data)
		
		// Atualizar o Jogador na memoryTable
		SalvarJogador(id)
		
		Print(id, "^1 %L", id, "ZMXP_MENU25", g_armor_names, level, amount, xp)
		client_cmd(id, "spk ambience/lv2")
		
		new nick[33], auth[33]
		get_user_name(id, nick, charsmax(nick))
		get_user_authid(id, auth, charsmax(auth))
		Log("[SAVE] NICK: %s | AUTHID: %s - comprou level %i de Colete", nick, auth, level)		
	}	
	
	ShowArmorMenu(id)
}

public CallbackArmor(id, menu, item)
{
	static _access, info[4], callback;
	menu_item_getinfo(menu, item, _access, info, sizeof(info) - 1, _, _, callback);
	
	if( info[0] == '*' ) return ITEM_ENABLED; // opção de ajuda
	
	if( info[0] == '1' ) // opção de compra
	{
		if( g_armor_level[id] == g_armor_maxlevels )
		{
			return ITEM_DISABLED;
		}
		
		new xp = g_armor_first_xp * (1 << g_armor_level[id]);
		if( g_xp[id] < xp )
			return ITEM_DISABLED;
	}
	
	if( info[0] == '$' ) // opção de venda
	{
		if( !g_armor_level[id])
		{
			return ITEM_DISABLED
		}
	}
	
	return ITEM_ENABLED;
}

// ========================================
// Mostrar menu de Municao!
// ========================================

ShowAmmoMenu(id)
{
	static title[128];
	formatex(title, sizeof(title) - 1, "%L", id, "ZMXP_MENU26", g_xp[id]);
	new menu = menu_create(title, "MenuAmmo");
	new callback = menu_makecallback("CallbackAmmo");
	
	menu_additem(menu, "\yAjuda", "*", _, callback);
	
	static levelv, level, xp, amount, item[128],/* info[4],*/ venda[128]
	level = g_ammo_level[id] + 1
	levelv = g_ammo_level[id]
	amount = g_ammo_maxamount * level / g_ammo_maxlevels
			
	if( g_ammo_level[id] < g_ammo_maxlevels )
	{
		xp = g_ammo_first_xp * (1 << (level - 1));
		formatex(item, sizeof(item) - 1, "%L", id, "ZMXP_MENU27", g_ammo_names, level, amount, xp);
	}
	else
	{
		formatex(item, sizeof(item) - 1, "%L", id, "ZMXP_MENU21", g_ammo_names, g_ammo_level[id]);
	}
	
	if( g_ammo_level[id])
	{
		xp = g_ammo_first_xp * (1 << (levelv - 1))
		new valor = (xp * 70) / 100
		formatex(venda, sizeof(venda) - 1, "%L", id, "ZMXP_MENU22", g_ammo_names, g_ammo_level[id], valor)
	}	
			
	//num_to_str(_:id, info, sizeof(info) - 1)
			
	menu_additem(menu, item, "1", _, callback)
	
	if( g_ammo_level[id])
	{
		menu_additem(menu, venda, "$", _, callback)
	}	
	
	menu_setprop(menu, MPROP_EXITNAME, "Sair")
	
	menu_display(id, menu)
}

public MenuAmmo(id, menu, item)
{
	if( item == MENU_EXIT )
	{
		menu_destroy(menu)
		ShowMainMenu(id)
		return;
	}
	
	static _access, info[4], callback
	menu_item_getinfo(menu, item, _access, info, sizeof(info) - 1, _, _, callback)
	menu_destroy(menu)
	
	if( info[0] == '*' )
	{
		static motd[600]
		new len = formatex(motd, sizeof(motd) - 1,	"<body style=^"background-color:#030303; color:#FF8F00^">")
		len += format(motd[len], sizeof(motd) - len - 1,	"<p align=^"center^">")
		len += format(motd[len], sizeof(motd) - len - 1,	"<img border=^"0^" src=^"http://i237.photobucket.com/albums/ff123/SkiesOFF/zombiexp.png^" width=^"375^" height=^"119^"><br>");		
		len += format(motd[len], sizeof(motd) - len - 1,	"Sua arma ganha mais balas por segundo com esse upgrade.<br>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<br>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<table>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<tr>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<th></th>")
		len += format(motd[len], sizeof(motd) - len - 1,	"</tr>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<tr>");
		len += format(motd[len], sizeof(motd) - len - 1,	"<th>%L</th>", id, "ZMXP_MENSAGEM30")
		len += format(motd[len], sizeof(motd) - len - 1,	"<td>%i</td>", (g_ammo_maxamount / g_ammo_maxlevels))
		len += format(motd[len], sizeof(motd) - len - 1,	"</tr>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<tr>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<th>%L</th>", id, "ZMXP_MENSAGEM31")
		len += format(motd[len], sizeof(motd) - len - 1,	"<td>%i</td>", g_ammo_maxlevels)
		len += format(motd[len], sizeof(motd) - len - 1,	"</tr>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<th>Municao Máxima</th>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<td>%i</td>", g_ammo_maxamount)
		len += format(motd[len], sizeof(motd) - len - 1,	"</tr>")
		len += format(motd[len], sizeof(motd) - len - 1,	"</table>")
		len += format(motd[len], sizeof(motd) - len - 1,	"</p>")
		len += format(motd[len], sizeof(motd) - len - 1,	"</body>")
		
		show_motd(id, motd, "Zombie XP Municao Info")
	}
	else if( info[0] == '$' ) // vender
	{	
		new level = g_ammo_level[id]
		new xp = g_ammo_first_xp * (1 << (level - 1))
		new valor = (xp * 70) / 100
		new amount = g_ammo_maxamount * level / g_ammo_maxlevels
		
		g_xp[id] += valor
		g_ammo_level[id] -= 1
		
		new data[64]
		new len = formatex(data, sizeof(data) - 1, "%i", g_armor_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_ammo_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_speed_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_gravity_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_damage_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_stunshot_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_esquiva_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_granadas_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_stamina_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_hp_level[id])
		
		copy(g_upgrades[id], charsmax(g_upgrades[]), data)
		
		// Atualizar o Jogador na memoryTable
		SalvarJogador(id)
		
		Print(id, "^1 %L", id, "ZMXP_MENU28", g_ammo_names, level, amount, valor)
		
		new nick[33], auth[33]
		get_user_name(id, nick, charsmax(nick))
		get_user_authid(id, auth, charsmax(auth))
		Log("[SAVE] NICK: %s | AUTHID: %s - vendeu level %i de Municao", nick, auth, level)		
	}	
	else if( info[0] == '1' ) // comprar
	{		
		new level = g_ammo_level[id] + 1
		new xp = g_ammo_first_xp * (1 << (level - 1))
		new amount = g_ammo_maxamount * level / g_ammo_maxlevels
		
		g_xp[id] -= xp
		g_ammo_level[id] = level
		
		new data[64]
		new len = formatex(data, sizeof(data) - 1, "%i", g_armor_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_ammo_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_speed_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_gravity_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_damage_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_stunshot_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_esquiva_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_granadas_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_stamina_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_hp_level[id])
		
		copy(g_upgrades[id], charsmax(g_upgrades[]), data)
		
		// Atualizar o Jogador na memoryTable
		SalvarJogador(id)
		
		Print(id, "^1 %L", id, "ZMXP_MENU29", g_ammo_names, level, amount, xp)
		client_cmd(id, "spk ambience/lv2")
		
		new nick[33], auth[33]
		get_user_name(id, nick, charsmax(nick))
		get_user_authid(id, auth, charsmax(auth))
		Log("[SAVE] NICK: %s | AUTHID: %s - comprou level %i de Municao", nick, auth, level)			
	}
	
	ShowAmmoMenu(id)
}

public CallbackAmmo(id, menu, item)
{
	static _access, info[4], callback
	menu_item_getinfo(menu, item, _access, info, sizeof(info) - 1, _, _, callback)
	
	if( info[0] == '*' ) return ITEM_ENABLED
	
	if( info[0] == '1' ) // opção de compra
	{
		if( g_ammo_level[id] == g_ammo_maxlevels )
		{
			return ITEM_DISABLED
		}
		
		new xp = g_ammo_first_xp * (1 << g_ammo_level[id])
		if( g_xp[id] < xp )
		{
			return ITEM_DISABLED
		}
	}
	
	if( info[0] == '$' ) // opção de venda
	{
		if( !g_ammo_level[id])
		{
			return ITEM_DISABLED
		}
	}	
	
	return ITEM_ENABLED;
}

// ========================================
// Mostrar Menu de Velocidade!
// ========================================

ShowSpeedMenu(id)
{
	static title[128];
	formatex(title, sizeof(title) - 1, "%L", id, "ZMXP_MENU30", g_xp[id])
	new menu = menu_create(title, "MenuSpeed")
	new callback = menu_makecallback("CallbackSpeed")
	
	menu_additem(menu, "\yAjuda", "*", _, callback)
	
	static levelv, level, xp, amount, item[128],/* info[4],*/ venda[128]
	level = g_speed_level[id] + 1
	levelv = g_speed_level[id]
	amount = g_speed_maxamount * level / g_speed_maxlevels
			
	if( g_speed_level[id] < g_speed_maxlevels )
	{
		xp = g_speed_first_xp * (1 << (level - 1))
		formatex(item, sizeof(item) - 1, "%L", id, "ZMXP_MENU31", g_speed_names, level, amount, xp)
	}
	else
	{
		formatex(item, sizeof(item) - 1, "%L", id, "ZMXP_MENU21", g_speed_names, g_speed_level[id])
	}
	
	if( g_speed_level[id])
	{
		xp = g_speed_first_xp * (1 << (levelv - 1))
		new valor = (xp * 70) / 100
		formatex(venda, sizeof(venda) - 1, "%L", id, "ZMXP_MENU22", g_speed_names, g_speed_level[id], valor)
	}	
			
	//num_to_str(_:id, info, sizeof(info) - 1)
			
	menu_additem(menu, item, "1", _, callback)
	
	if( g_speed_level[id])
	{
		menu_additem(menu, venda, "$", _, callback)
	}	
	
	menu_setprop(menu, MPROP_EXITNAME, "Sair")
	
	menu_display(id, menu)
}

public MenuSpeed(id, menu, item)
{
	if( item == MENU_EXIT )
	{
		menu_destroy(menu);
		ShowMainMenu(id);
		return;
	}
	
	static _access, info[4], callback;
	menu_item_getinfo(menu, item, _access, info, sizeof(info) - 1, _, _, callback);
	menu_destroy(menu);
	
	if( info[0] == '*' )
	{
		static motd[600]
		new len = formatex(motd, sizeof(motd) - 1,	"<body style=^"background-color:#030303; color:#FF8F00^">")
		len += format(motd[len], sizeof(motd) - len - 1,	"<p align=^"center^">")
		len += format(motd[len], sizeof(motd) - len - 1,	"<img border=^"0^" src=^"http://i237.photobucket.com/albums/ff123/SkiesOFF/zombiexp.png^" width=^"375^" height=^"119^"><br>")	
		len += format(motd[len], sizeof(motd) - len - 1,	"Upgrade que lhe da mais velocidade por level.<br>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<br>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<table>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<tr>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<th></th>")
		len += format(motd[len], sizeof(motd) - len - 1,	"</tr>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<tr>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<th>Bônus por Level</th>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<td>%i</td>", (g_speed_maxamount / g_speed_maxlevels))
		len += format(motd[len], sizeof(motd) - len - 1,	"</tr>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<tr>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<th>%L</th>", id, "ZMXP_MENSAGEM30")
		len += format(motd[len], sizeof(motd) - len - 1,	"<td>%i</td>", g_speed_maxlevels)
		len += format(motd[len], sizeof(motd) - len - 1,	"</tr>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<th>%L</th>", id, "ZMXP_MENSAGEM31")
		len += format(motd[len], sizeof(motd) - len - 1,	"<td>%i</td>", g_speed_maxamount)
		len += format(motd[len], sizeof(motd) - len - 1,	"</tr>")
		len += format(motd[len], sizeof(motd) - len - 1,	"</table>")
		len += format(motd[len], sizeof(motd) - len - 1,	"</p>")
		len += format(motd[len], sizeof(motd) - len - 1,	"</body>")
		
		show_motd(id, motd, "Zombie XP Velocidade Info");
	}
	else if( info[0] == '$' ) // vender
	{	
		new level = g_speed_level[id]
		new xp = g_speed_first_xp * (1 << (level - 1))
		new valor = (xp * 70) / 100
		new amount = g_speed_maxamount * level / g_speed_maxlevels
		
		g_xp[id] += valor
		g_speed_level[id] -= 1
		
		new data[64]
		new len = formatex(data, sizeof(data) - 1, "%i", g_armor_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_ammo_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_speed_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_gravity_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_damage_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_stunshot_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_esquiva_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_granadas_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_stamina_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_hp_level[id])
		
		copy(g_upgrades[id], charsmax(g_upgrades[]), data)
		
		// Atualizar o Jogador na memoryTable
		SalvarJogador(id)
		
		Print(id, "^1 %L", id, "ZMXP_MENU32", g_speed_names, level, amount, valor)
		
		new nick[33], auth[33]
		get_user_name(id, nick, charsmax(nick))
		get_user_authid(id, auth, charsmax(auth))
		Log("[SAVE] NICK: %s | AUTHID: %s - vendeu level %i de Velocidade", nick, auth, level)			
	}
	else if( info[0] == '1' ) // comprar
	{		
		new level = g_speed_level[id] + 1;
		new xp = g_speed_first_xp * (1 << (level - 1));
		new amount = g_speed_maxamount * level / g_speed_maxlevels;
		
		g_xp[id] -= xp;
		g_speed_level[id] = level;
		
		new data[64]
		new len = formatex(data, sizeof(data) - 1, "%i", g_armor_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_ammo_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_speed_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_gravity_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_damage_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_stunshot_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_esquiva_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_granadas_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_stamina_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_hp_level[id])
		
		copy(g_upgrades[id], charsmax(g_upgrades[]), data)
		
		// Atualizar o Jogador na memoryTable
		SalvarJogador(id)		
		
		Print(id, "^1 %L", id, "ZMXP_MENU33", g_speed_names, level, amount, xp)
		client_cmd(id, "spk ambience/lv2")
		
		new nick[33], auth[33]
		get_user_name(id, nick, charsmax(nick))
		get_user_authid(id, auth, charsmax(auth))
		Log("[SAVE] NICK: %s | AUTHID: %s - comprou level %i de Velocidade", nick, auth, level)			
	}
	
	ShowSpeedMenu(id)
}

public CallbackSpeed(id, menu, item)
{
	static _access, info[4], callback
	menu_item_getinfo(menu, item, _access, info, sizeof(info) - 1, _, _, callback)
	
	if( info[0] == '*' ) return ITEM_ENABLED
	
	if( info[0] == '1' ) // opção de compra
	{
		if( g_speed_level[id] == g_speed_maxlevels )
		{
			return ITEM_DISABLED
		}
		
		new xp = g_speed_first_xp * (1 << g_speed_level[id])
		if( g_xp[id] < xp )
		{
			return ITEM_DISABLED
		}
	}
	
	if( info[0] == '$' ) // opção de venda
	{
		if( !g_speed_level[id])
		{
			return ITEM_DISABLED
		}
	}	
	
	return ITEM_ENABLED
}

// ========================================
// Mostrar Menu de Gravidade!
// ========================================

ShowGravityMenu(id)
{
	static title[128];
	formatex(title, sizeof(title) - 1, "%L", id, "ZMXP_MENU34", g_xp[id])
	new menu = menu_create(title, "MenuGravity")
	new callback = menu_makecallback("CallbackGravity")
	
	menu_additem(menu, "\yAjuda", "*", _, callback)
	
	static levelv, level, xp, amount, item[128],/* info[4],*/ venda[128]
	level = g_gravity_level[id] + 1
	levelv = g_gravity_level[id]
	amount = g_gravity_maxamount * level / g_gravity_maxlevels
			
	if( g_gravity_level[id] < g_gravity_maxlevels )
	{
		xp = g_gravity_first_xp * (1 << (level - 1))
		formatex(item, sizeof(item) - 1, "%L", id, "ZMXP_MENU35", g_gravity_names, level, amount, xp)
	}
	else
	{
		formatex(item, sizeof(item) - 1, "%L", id, "ZMXP_MENU21", g_gravity_names, g_gravity_level[id])
	}
	
	if( g_gravity_level[id])
	{
		xp = g_gravity_first_xp * (1 << (levelv - 1))
		new valor = (xp * 70) / 100
		formatex(venda, sizeof(venda) - 1, "%L", id, "ZMXP_MENU22", g_gravity_names, g_gravity_level[id], valor)
	}	
			
	//num_to_str(_:id, info, sizeof(info) - 1)
			
	menu_additem(menu, item, "1", _, callback)
	
	if( g_gravity_level[id])
	{
		menu_additem(menu, venda, "$", _, callback)
	}	
	
	menu_setprop(menu, MPROP_EXITNAME, "Sair")
	
	menu_display(id, menu)
}

public MenuGravity(id, menu, item)
{
	if( item == MENU_EXIT )
	{
		menu_destroy(menu)
		ShowMainMenu(id)
		return;
	}
	
	static _access, info[4], callback
	menu_item_getinfo(menu, item, _access, info, sizeof(info) - 1, _, _, callback)
	menu_destroy(menu)
	
	if( info[0] == '*' )
	{
		static motd[600]
		new len = formatex(motd, sizeof(motd) - 1,	"<body style=^"background-color:#030303; color:#FF8F00^">")
		len += format(motd[len], sizeof(motd) - len - 1,	"<p align=^"center^">")
		len += format(motd[len], sizeof(motd) - len - 1,	"<img border=^"0^" src=^"http://i237.photobucket.com/albums/ff123/SkiesOFF/zombiexp.png^" width=^"375^" height=^"119^"><br>");	
		len += format(motd[len], sizeof(motd) - len - 1,	"Upgrade que lhe da menos gravidade por level.<br>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<br>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<table>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<tr>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<th></th>")
		len += format(motd[len], sizeof(motd) - len - 1,	"</tr>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<tr>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<th>%L</th>", id, "ZMXP_MENSAGEM30")
		len += format(motd[len], sizeof(motd) - len - 1,	"<td>-%i</td>", (g_gravity_maxamount / g_gravity_maxlevels))
		len += format(motd[len], sizeof(motd) - len - 1,	"</tr>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<tr>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<th>%L</th>", id, "ZMXP_MENSAGEM31")
		len += format(motd[len], sizeof(motd) - len - 1,	"<td>%i</td>", g_gravity_maxlevels)
		len += format(motd[len], sizeof(motd) - len - 1,	"</tr>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<th>Gravidade Mínima</th>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<td>-%i</td>", g_gravity_maxamount)
		len += format(motd[len], sizeof(motd) - len - 1,	"</tr>")
		len += format(motd[len], sizeof(motd) - len - 1,	"</table>")
		len += format(motd[len], sizeof(motd) - len - 1,	"</p>")
		len += format(motd[len], sizeof(motd) - len - 1,	"</body>")
		
		show_motd(id, motd, "Zombie XP Gravidade Info");
	}
	else if( info[0] == '$' ) // vender
	{	
		new level = g_gravity_level[id]
		new xp = g_gravity_first_xp * (1 << (level - 1))
		new valor = (xp * 70) / 100
		new amount = g_gravity_maxamount * level / g_gravity_maxlevels
		
		g_xp[id] += valor
		g_gravity_level[id] -= 1
		
		new data[64]
		new len = formatex(data, sizeof(data) - 1, "%i", g_armor_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_ammo_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_speed_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_gravity_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_damage_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_stunshot_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_esquiva_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_granadas_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_stamina_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_hp_level[id])
		
		copy(g_upgrades[id], charsmax(g_upgrades[]), data)
		
		// Atualizar o Jogador na memoryTable
		SalvarJogador(id)
		
		Print(id, "^1 %L", id, "ZMXP_MENU36", g_gravity_names, level, amount, valor)
		
		new nick[33], auth[33]
		get_user_name(id, nick, charsmax(nick))
		get_user_authid(id, auth, charsmax(auth))
		Log("[SAVE] NICK: %s | AUTHID: %s - vendeu level %i de Gravidade", nick, auth, level)			
	}
	else if( info[0] == '1' ) // comprar
	{	
		new level = g_gravity_level[id] + 1;
		new xp = g_gravity_first_xp * (1 << (level - 1));
		new amount = g_gravity_maxamount * level / g_gravity_maxlevels;
		
		g_xp[id] -= xp;
		g_gravity_level[id] = level;
		
		new data[64]
		new len = formatex(data, sizeof(data) - 1, "%i", g_armor_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_ammo_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_speed_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_gravity_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_damage_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_stunshot_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_esquiva_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_granadas_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_stamina_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_hp_level[id])
		
		copy(g_upgrades[id], charsmax(g_upgrades[]), data)
		
		// Atualizar o Jogador na memoryTable
		SalvarJogador(id)	
		
		Print(id, "^1 %L", id, "ZMXP_MENU37", g_gravity_names, level, amount, xp)
		client_cmd(id, "spk ambience/lv2")
		
		new nick[33], auth[33]
		get_user_name(id, nick, charsmax(nick))
		get_user_authid(id, auth, charsmax(auth))
		Log("[SAVE] NICK: %s | AUTHID: %s - comprou level %i de Gravidade", nick, auth, level)			
	}
	
	ShowGravityMenu(id);
}

public CallbackGravity(id, menu, item)
{
	static _access, info[4], callback
	menu_item_getinfo(menu, item, _access, info, sizeof(info) - 1, _, _, callback)
	
	if( info[0] == '*' ) return ITEM_ENABLED
	
	if( info[0] == '1' ) // opção de compra
	{
		if( g_gravity_level[id] == g_gravity_maxlevels )
		{
			return ITEM_DISABLED
		}
		
		new xp = g_gravity_first_xp * (1 << g_gravity_level[id])
		if( g_xp[id] < xp )
		{
			return ITEM_DISABLED
		}
	}
	
	if( info[0] == '$' ) // opção de venda
	{
		if( !g_gravity_level[id])
		{
			return ITEM_DISABLED
		}
	}	
	
	return ITEM_ENABLED
}

// ========================================
// Mostrar Menu de Damage!
// ========================================

ShowDamageMenu(id)
{
	static title[128];
	formatex(title, sizeof(title) - 1, "%L", id, "ZMXP_MENU38", g_xp[id])
	new menu = menu_create(title, "MenuDamage")
	new callback = menu_makecallback("CallbackDamage")
	
	menu_additem(menu, "\yAjuda", "*", _, callback)
	
	static levelv, level, xp, amount, item[128],/* info[4],*/ venda[128]
	level = g_damage_level[id] + 1
	levelv = g_damage_level[id]
	amount = g_damage_maxamount * level / g_damage_maxlevels
			
	if( g_damage_level[id] < g_damage_maxlevels )
	{
		xp = g_damage_first_xp * (1 << (level - 1))
		formatex(item, sizeof(item) - 1, "%L", id, "ZMXP_MENU39", g_damage_names, level, amount, xp)
	}
	else
	{
		formatex(item, sizeof(item) - 1, "%L", id, "ZMXP_MENU21", g_damage_names, g_damage_level[id])
	}
	
	if( g_damage_level[id])
	{
		xp = g_damage_first_xp * (1 << (levelv - 1))
		new valor = (xp * 70) / 100
		formatex(venda, sizeof(venda) - 1, "%L", id, "ZMXP_MENU22", g_damage_names, g_damage_level[id], valor)
	}	
			
	//num_to_str(_:id, info, sizeof(info) - 1)
			
	menu_additem(menu, item, "1", _, callback)
	
	if( g_damage_level[id])
	{
		menu_additem(menu, venda, "$", _, callback)
	}	
	
	menu_setprop(menu, MPROP_EXITNAME, "Sair")
	
	menu_display(id, menu)
}

public MenuDamage(id, menu, item)
{
	if( item == MENU_EXIT )
	{
		menu_destroy(menu);
		ShowMainMenu(id);
		return;
	}
	
	static _access, info[4], callback;
	menu_item_getinfo(menu, item, _access, info, sizeof(info) - 1, _, _, callback);
	menu_destroy(menu);
	
	if( info[0] == '*' )
	{
		static motd[600]
		new len = formatex(motd, sizeof(motd) - 1,	"<body style=^"background-color:#030303; color:#FF8F00^">")
		len += format(motd[len], sizeof(motd) - len - 1,	"<p align=^"center^">")
		len += format(motd[len], sizeof(motd) - len - 1,	"<img border=^"0^" src=^"http://i237.photobucket.com/albums/ff123/SkiesOFF/zombiexp.png^" width=^"375^" height=^"119^"><br>");
		len += format(motd[len], sizeof(motd) - len - 1,	"Upgrade que lhe da mais dano por tiro.<br>")	
		len += format(motd[len], sizeof(motd) - len - 1,	"<br>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<table>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<tr>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<th></th>")
		len += format(motd[len], sizeof(motd) - len - 1,	"</tr>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<tr>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<th>%L</th>", id, "ZMXP_MENSAGEM30")
		len += format(motd[len], sizeof(motd) - len - 1,	"<td>+%i%</td>", (g_damage_maxamount / g_damage_maxlevels))
		len += format(motd[len], sizeof(motd) - len - 1,	"</tr>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<tr>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<th>%L</th>", id, "ZMXP_MENSAGEM31")
		len += format(motd[len], sizeof(motd) - len - 1,	"<td>%i</td>", g_damage_maxlevels)
		len += format(motd[len], sizeof(motd) - len - 1,	"</tr>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<th>Damage Máximo</th>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<td>+%i%</td>", g_damage_maxamount)
		len += format(motd[len], sizeof(motd) - len - 1,	"</tr>")
		len += format(motd[len], sizeof(motd) - len - 1,	"</table>")
		len += format(motd[len], sizeof(motd) - len - 1,	"</p>")
		len += format(motd[len], sizeof(motd) - len - 1,	"</body>")
		
		show_motd(id, motd, "Zombie XP Damage Info")
	}
	
	else
	if( info[0] == '$' ) // vender
	{	
		new level = g_damage_level[id]
		new xp = g_damage_first_xp * (1 << (level - 1))
		new valor = (xp * 70) / 100
		new amount = g_damage_maxamount * level / g_damage_maxlevels
		
		g_xp[id] += valor
		g_damage_level[id] -= 1
		
		new data[64]
		new len = formatex(data, sizeof(data) - 1, "%i", g_armor_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_ammo_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_speed_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_gravity_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_damage_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_stunshot_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_esquiva_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_granadas_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_stamina_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_hp_level[id])
		
		copy(g_upgrades[id], charsmax(g_upgrades[]), data)
		
		// Atualizar o Jogador na memoryTable
		SalvarJogador(id)
		
		Print(id, "^1 %L", id, "ZMXP_MENU40", g_damage_names, level, amount, valor)
		
		new nick[33], auth[33]
		get_user_name(id, nick, charsmax(nick))
		get_user_authid(id, auth, charsmax(auth))
		Log("[SAVE] NICK: %s | AUTHID: %s - vendeu level %i de Damage", nick, auth, level)		
	}	
	else if( info[0] == '1' ) // comprar
	{		
		new level = g_damage_level[id] + 1;
		new xp = g_damage_first_xp * (1 << (level - 1));
		new amount = g_damage_maxamount * level / g_damage_maxlevels;
		
		g_xp[id] -= xp;
		g_damage_level[id] = level;
		
		new data[64]
		new len = formatex(data, sizeof(data) - 1, "%i", g_armor_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_ammo_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_speed_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_gravity_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_damage_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_stunshot_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_esquiva_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_granadas_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_stamina_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_hp_level[id])
		
		copy(g_upgrades[id], charsmax(g_upgrades[]), data)
		
		// Atualizar o Jogador na memoryTable
		SalvarJogador(id)		
		
		Print(id, "^1 %L", id, "ZMXP_MENU41", g_damage_names, level, amount, xp)
		client_cmd(id, "spk ambience/lv2")
		
		new nick[33], auth[33]
		get_user_name(id, nick, charsmax(nick))
		get_user_authid(id, auth, charsmax(auth))
		Log("[SAVE] NICK: %s | AUTHID: %s - comprou level %i de Damage", nick, auth, level)			
	}
	
	ShowDamageMenu(id);
}

public CallbackDamage(id, menu, item)
{
	static _access, info[4], callback
	menu_item_getinfo(menu, item, _access, info, sizeof(info) - 1, _, _, callback)
	
	if( info[0] == '*' ) return ITEM_ENABLED
	
	if( info[0] == '1' ) // opção de compra
	{
		if( g_damage_level[id] == g_damage_maxlevels )
		{
			return ITEM_DISABLED
		}
		
		new xp = g_damage_first_xp * (1 << g_damage_level[id])
		if( g_xp[id] < xp )
		{
			return ITEM_DISABLED
		}
	}
	
	if( info[0] == '$' ) // opção de venda
	{
		if( !g_damage_level[id])
		{
			return ITEM_DISABLED
		}
	}	
	
	return ITEM_ENABLED
}

// ========================================
// Mostrar Menu de StunShot!
// ========================================

ShowStunShotMenu(id)
{
	static title[128];
	formatex(title, sizeof(title) - 1, "%L", id, "ZMXP_MENU42", g_xp[id])
	new menu = menu_create(title, "MenuStunShot")
	new callback = menu_makecallback("CallbackStunShot")
	
	menu_additem(menu, "\yAjuda", "*", _, callback)
	
	static levelv, level, xp, amount, item[128],/* info[4],*/ venda[128]
	level = g_stunshot_level[id] + 1
	levelv = g_stunshot_level[id]
	amount = g_stunshot_maxamount * level / g_stunshot_maxlevels
			
	if( g_stunshot_level[id] < g_stunshot_maxlevels )
	{
		xp = g_stunshot_first_xp * (1 << (level - 1))
		formatex(item, sizeof(item) - 1, "%L", id, "ZMXP_MENU43", g_stunshot_names, level, amount, xp)
	}
	else
	{
		formatex(item, sizeof(item) - 1, "%L", id, "ZMXP_MENU21", g_stunshot_names, g_stunshot_level[id])
	}
	
	if( g_stunshot_level[id])
	{
		xp = g_stunshot_first_xp * (1 << (levelv - 1))
		new valor = (xp * 70) / 100
		formatex(venda, sizeof(venda) - 1, "%L", id, "ZMXP_MENU22", g_stunshot_names, g_stunshot_level[id], valor)
	}	
			
	//num_to_str(_:id, info, sizeof(info) - 1)
			
	menu_additem(menu, item, "1", _, callback)
	
	if( g_stunshot_level[id])
	{
		menu_additem(menu, venda, "$", _, callback)
	}	
	
	menu_setprop(menu, MPROP_EXITNAME, "Sair")
	
	menu_display(id, menu)
}

public MenuStunShot(id, menu, item)
{
	if( item == MENU_EXIT )
	{
		menu_destroy(menu);
		ShowMainMenu(id);
		return;
	}
	
	static _access, info[4], callback;
	menu_item_getinfo(menu, item, _access, info, sizeof(info) - 1, _, _, callback);
	menu_destroy(menu);
	
	if( info[0] == '*' )
	{
		static motd[600]
		new len = formatex(motd, sizeof(motd) - 1,	"<body style=^"background-color:#030303; color:#FF8F00^">")
		len += format(motd[len], sizeof(motd) - len - 1,	"<p align=^"center^">")
		len += format(motd[len], sizeof(motd) - len - 1,	"<img border=^"0^" src=^"http://i237.photobucket.com/albums/ff123/SkiesOFF/zombiexp.png^" width=^"375^" height=^"119^"><br>");
		len += format(motd[len], sizeof(motd) - len - 1,	"Chance de queimar ou congelar o inimigo sempre que der HeadShot.<br>")	
		len += format(motd[len], sizeof(motd) - len - 1,	"<br>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<table>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<tr>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<th></th>")
		len += format(motd[len], sizeof(motd) - len - 1,	"</tr>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<tr>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<th>%L</th>", id, "ZMXP_MENSAGEM30")
		len += format(motd[len], sizeof(motd) - len - 1,	"<td>+%i%</td>", (g_stunshot_maxamount / g_stunshot_maxlevels))
		len += format(motd[len], sizeof(motd) - len - 1,	"</tr>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<tr>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<th>%L</th>", id, "ZMXP_MENSAGEM31")
		len += format(motd[len], sizeof(motd) - len - 1,	"<td>%i</td>", g_stunshot_maxlevels)
		len += format(motd[len], sizeof(motd) - len - 1,	"</tr>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<th>Porcentagem Máxima</th>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<td>+%i%</td>", g_stunshot_maxamount)
		len += format(motd[len], sizeof(motd) - len - 1,	"</tr>")
		len += format(motd[len], sizeof(motd) - len - 1,	"</table>")
		len += format(motd[len], sizeof(motd) - len - 1,	"</p>")
		len += format(motd[len], sizeof(motd) - len - 1,	"</body>")
		
		show_motd(id, motd, "Zombie XP Elemental Shot Info");
	}
	
	else if( info[0] == '$' ) // vender
	{	
		new level = g_stunshot_level[id]
		new xp = g_stunshot_first_xp * (1 << (level - 1))
		new valor = (xp * 70) / 100
		new amount = g_stunshot_maxamount * level / g_stunshot_maxlevels
		
		g_xp[id] += valor
		g_stunshot_level[id] -= 1
		
		new data[64]
		new len = formatex(data, sizeof(data) - 1, "%i", g_armor_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_ammo_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_speed_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_gravity_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_damage_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_stunshot_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_esquiva_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_granadas_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_stamina_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_hp_level[id])
		
		copy(g_upgrades[id], charsmax(g_upgrades[]), data)
		
		// Atualizar o Jogador na memoryTable
		SalvarJogador(id)
		
		Print(id, "^1 %L", id, "ZMXP_MENU44", g_stunshot_names, level, amount, valor)
		
		new nick[33], auth[33]
		get_user_name(id, nick, charsmax(nick))
		get_user_authid(id, auth, charsmax(auth))
		Log("[SAVE] NICK: %s | AUTHID: %s - vendeu level %i de Elemental Shot", nick, auth, level)			
	}
	else if( info[0] == '1' ) // comprar
	{		
		new level = g_stunshot_level[id] + 1;
		new xp = g_stunshot_first_xp * (1 << (level - 1));
		new amount = g_stunshot_maxamount * level / g_stunshot_maxlevels;
		
		g_xp[id] -= xp;
		g_stunshot_level[id] = level;
		
		new data[64]
		new len = formatex(data, sizeof(data) - 1, "%i", g_armor_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_ammo_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_speed_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_gravity_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_damage_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_stunshot_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_esquiva_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_granadas_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_stamina_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_hp_level[id])
		
		copy(g_upgrades[id], charsmax(g_upgrades[]), data)
		
		// Atualizar o Jogador na memoryTable
		SalvarJogador(id)		
		
		Print(id, "^1 %L", id, "ZMXP_MENU45", g_stunshot_names, level, amount, xp)
		client_cmd(id, "spk ambience/lv2")
		
		new nick[33], auth[33]
		get_user_name(id, nick, charsmax(nick))
		get_user_authid(id, auth, charsmax(auth))
		Log("[SAVE] NICK: %s | AUTHID: %s - comprou level %i de Elemental Shot", nick, auth, level)			
	}
	
	ShowStunShotMenu(id);
}

public CallbackStunShot(id, menu, item)
{
	static _access, info[4], callback
	menu_item_getinfo(menu, item, _access, info, sizeof(info) - 1, _, _, callback)
	
	if( info[0] == '*' ) return ITEM_ENABLED
	
	if( info[0] == '1' ) // opção de compra
	{
		if( g_stunshot_level[id] == g_stunshot_maxlevels )
		{
			return ITEM_DISABLED
		}
		
		new xp = g_stunshot_first_xp * (1 << g_stunshot_level[id])
		if( g_xp[id] < xp )
		{
			return ITEM_DISABLED
		}
	}
	
	if( info[0] == '$' ) // opção de venda
	{
		if( !g_stunshot_level[id])
		{
			return ITEM_DISABLED
		}
	}	
	
	return ITEM_ENABLED;
}

// ========================================
// Mostrar Menu de Esquiva!
// ========================================

ShowEsquivaMenu(id)
{
	static title[128]
	formatex(title, sizeof(title) - 1, "%L", id, "ZMXP_MENU46", g_xp[id])
	new menu = menu_create(title, "MenuEsquiva")
	new callback = menu_makecallback("CallbackEsquiva")
	
	menu_additem(menu, "\yAjuda", "*", _, callback)
	
	static levelv, level, xp, amount, item[128]/*, info[4]*/, venda[128]
	level = g_esquiva_level[id] + 1
	levelv = g_esquiva_level[id]
	amount = g_esquiva_maxamount * level / g_esquiva_maxlevels
			
	if( g_esquiva_level[id] < g_esquiva_maxlevels )
	{
		xp = g_esquiva_first_xp * (1 << (level - 1))
		formatex(item, sizeof(item) - 1, "%L", id, "ZMXP_MENU47", g_esquiva_names, level, amount, xp)
	}
	else
	{
		formatex(item, sizeof(item) - 1, "%L", id, "ZMXP_MENU21", g_esquiva_names, g_esquiva_level[id])
	}
	
	if( g_esquiva_level[id])
	{
		xp = g_esquiva_first_xp * (1 << (levelv - 1))
		new valor = (xp * 70) / 100
		formatex(venda, sizeof(venda) - 1, "%L", id, "ZMXP_MENU22", g_esquiva_names, g_esquiva_level[id], valor)
	}	
			
	//num_to_str(_:id, info, sizeof(info) - 1)
			
	menu_additem(menu, item, "1", _, callback)
	
	if( g_esquiva_level[id])
	{
		menu_additem(menu, venda, "$", _, callback)
	}	
	
	menu_setprop(menu, MPROP_EXITNAME, "Sair")
	
	menu_display(id, menu)
}

public MenuEsquiva(id, menu, item)
{
	if( item == MENU_EXIT )
	{
		menu_destroy(menu)
		ShowMainMenu(id)
		return;
	}
	
	static _access, info[4], callback
	menu_item_getinfo(menu, item, _access, info, sizeof(info) - 1, _, _, callback)
	menu_destroy(menu)
	
	if( info[0] == '*' )
	{
		static motd[600]
		new len = formatex(motd, sizeof(motd) - 1,	"<body style=^"background-color:#030303; color:#FF8F00^">")
		len += format(motd[len], sizeof(motd) - len - 1,	"<p align=^"center^">")
		len += format(motd[len], sizeof(motd) - len - 1,	"<img border=^"0^" src=^"http://i237.photobucket.com/albums/ff123/SkiesOFF/zombiexp.png^" width=^"375^" height=^"119^"><br>");
		len += format(motd[len], sizeof(motd) - len - 1,	"Chance de se esquivar de tiros ou de ser infectado.<br>")	
		len += format(motd[len], sizeof(motd) - len - 1,	"<br>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<table>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<tr>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<th></th>")
		len += format(motd[len], sizeof(motd) - len - 1,	"</tr>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<tr>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<th>%L</th>", id, "ZMXP_MENSAGEM30")
		len += format(motd[len], sizeof(motd) - len - 1,	"<td>+%i%</td>", (g_esquiva_maxamount / g_esquiva_maxlevels))
		len += format(motd[len], sizeof(motd) - len - 1,	"</tr>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<tr>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<th>%L</th>", id, "ZMXP_MENSAGEM31")
		len += format(motd[len], sizeof(motd) - len - 1,	"<td>%i</td>", g_esquiva_maxlevels)
		len += format(motd[len], sizeof(motd) - len - 1,	"</tr>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<th>Porcentagem Máxima</th>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<td>+%i%</td>", g_esquiva_maxamount)
		len += format(motd[len], sizeof(motd) - len - 1,	"</tr>")
		len += format(motd[len], sizeof(motd) - len - 1,	"</table>")
		len += format(motd[len], sizeof(motd) - len - 1,	"</p>")
		len += format(motd[len], sizeof(motd) - len - 1,	"</body>")
		
		show_motd(id, motd, "Zombie XP Esquiva Info")
	}
	else if( info[0] == '$' ) // vender
	{	
		new level = g_esquiva_level[id]
		new xp = g_esquiva_first_xp * (1 << (level - 1))
		new valor = (xp * 70) / 100
		new amount = g_esquiva_maxamount * level / g_esquiva_maxlevels
		
		g_xp[id] += valor
		g_esquiva_level[id] -= 1
		
		new data[64]
		new len = formatex(data, sizeof(data) - 1, "%i", g_armor_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_ammo_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_speed_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_gravity_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_damage_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_stunshot_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_esquiva_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_granadas_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_stamina_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_hp_level[id])
		
		copy(g_upgrades[id], charsmax(g_upgrades[]), data)
		
		// Atualizar o Jogador na memoryTable
		SalvarJogador(id)
		
		Print(id, "^1 %L", id, "ZMXP_MENU48", g_esquiva_names, level, amount, valor)
		
		new nick[33], auth[33]
		get_user_name(id, nick, charsmax(nick))
		get_user_authid(id, auth, charsmax(auth))
		Log("[SAVE] NICK: %s | AUTHID: %s - vendeu level %i de Esquiva", nick, auth, level)			
	}	
	else if( info[0] == '1' ) // comprar
	{		
		new level = g_esquiva_level[id] + 1;
		new xp = g_esquiva_first_xp * (1 << (level - 1));
		new amount = g_esquiva_maxamount * level / g_esquiva_maxlevels;
		
		g_xp[id] -= xp;
		g_esquiva_level[id] = level;
		
		new data[64]
		new len = formatex(data, sizeof(data) - 1, "%i", g_armor_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_ammo_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_speed_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_gravity_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_damage_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_stunshot_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_esquiva_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_granadas_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_stamina_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_hp_level[id])
		
		copy(g_upgrades[id], charsmax(g_upgrades[]), data)
		
		// Atualizar o Jogador na memoryTable
		SalvarJogador(id)		
		
		Print(id, "^1 %L", id, "ZMXP_MENU49", g_esquiva_names, level, amount, xp)
		client_cmd(id, "spk ambience/lv2")
		
		new nick[33], auth[33]
		get_user_name(id, nick, charsmax(nick))
		get_user_authid(id, auth, charsmax(auth))
		Log("[SAVE] NICK: %s | AUTHID: %s - comprou level %i de Esquiva", nick, auth, level)			
	}

	ShowEsquivaMenu(id)
}

public CallbackEsquiva(id, menu, item)
{
	static _access, info[4], callback
	menu_item_getinfo(menu, item, _access, info, sizeof(info) - 1, _, _, callback)
	
	if( info[0] == '*' ) return ITEM_ENABLED
	
	if( info[0] == '1' ) // opção de compra
	{
		if( g_esquiva_level[id] == g_esquiva_maxlevels )
		{
			return ITEM_DISABLED
		}
		
		new xp = g_esquiva_first_xp * (1 << g_esquiva_level[id])
		if( g_xp[id] < xp )
		{
			return ITEM_DISABLED
		}
	}
	
	if( info[0] == '$' ) // opção de venda
	{
		if( !g_esquiva_level[id])
		{
			return ITEM_DISABLED
		}
	}	
	
	return ITEM_ENABLED
}

// ========================================
// Mostrar Menu de Granadas!
// ========================================

ShowGranadasMenu(id)
{
	static title[128];
	formatex(title, sizeof(title) - 1, "%L", id, "ZMXP_MENU50", g_xp[id])
	new menu = menu_create(title, "MenuGranadas")
	new callback = menu_makecallback("CallbackGranadas")
	
	menu_additem(menu, "\yAjuda", "*", _, callback)
	
	static levelv, level, xp, item[128], /*info[4],*/ venda[128]
	level = g_granadas_level[id] + 1
	levelv = g_granadas_level[id]
			
	if( g_granadas_level[id] < g_granadas_maxlevels )
	{
		xp = g_granadas_first_xp * (1 << (level - 1))
		formatex(item, sizeof(item) - 1, "%L", id, "ZMXP_MENU51", g_granadas_names, level, floatround(TempoGranadas[g_granadas_level[id]+1]), xp)
	}
	else
	{
		formatex(item, sizeof(item) - 1, "%L", id, "ZMXP_MENU21", g_granadas_names, g_granadas_level[id])
	}
	
	if( g_granadas_level[id])
	{
		xp = g_granadas_first_xp * (1 << (levelv - 1))
		new valor = (xp * 70) / 100
		formatex(venda, sizeof(venda) - 1, "%L", id, "ZMXP_MENU22", g_granadas_names, g_granadas_level[id], valor)
	}	
			
//	num_to_str(_:id, info, sizeof(info) - 1)
			
	menu_additem(menu, item, "1", _, callback)
	
	if( g_granadas_level[id])
	{
		menu_additem(menu, venda, "$", _, callback)
	}	
	
	menu_setprop(menu, MPROP_EXITNAME, "Sair")
	menu_display(id, menu)
}

public MenuGranadas(id, menu, item)
{
	if( item == MENU_EXIT )
	{
		menu_destroy(menu);
		ShowMainMenu(id);
		return;
	}
	
	static _access, info[4], callback;
	menu_item_getinfo(menu, item, _access, info, sizeof(info) - 1, _, _, callback);
	menu_destroy(menu);
	
	if( info[0] == '*' )
	{
		static motd[600]
		new len = formatex(motd, sizeof(motd) - 1,	"<body style=^"background-color:#030303; color:#FF8F00^">")
		len += format(motd[len], sizeof(motd) - len - 1,	"<p align=^"center^">")
		len += format(motd[len], sizeof(motd) - len - 1,	"<img border=^"0^" src=^"http://i237.photobucket.com/albums/ff123/SkiesOFF/zombiexp.png^" width=^"375^" height=^"119^"><br>");
		len += format(motd[len], sizeof(motd) - len - 1,	"Ganha uma Napalm ou Frost a cada determinados segundos.<br>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<br>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<table>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<tr>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<th></th>")
		len += format(motd[len], sizeof(motd) - len - 1,	"</tr>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<tr>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<th>%L</th>", id, "ZMXP_MENSAGEM30")
		len += format(motd[len], sizeof(motd) - len - 1,	"<td>+%i%</td>", (g_granadas_maxamount / g_granadas_maxlevels))
		len += format(motd[len], sizeof(motd) - len - 1,	"</tr>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<tr>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<th>%L</th>", id, "ZMXP_MENSAGEM31")
		len += format(motd[len], sizeof(motd) - len - 1,	"<td>%i</td>", g_granadas_maxlevels)
		len += format(motd[len], sizeof(motd) - len - 1,	"</tr>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<th>Mínimo de Segundos p/ Ganhar</th>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<td>+%i%</td>", g_granadas_maxamount)
		len += format(motd[len], sizeof(motd) - len - 1,	"</tr>")
		len += format(motd[len], sizeof(motd) - len - 1,	"</table>")
		len += format(motd[len], sizeof(motd) - len - 1,	"</p>")
		len += format(motd[len], sizeof(motd) - len - 1,	"</body>")
		
		show_motd(id, motd, "Zombie XP Granadas Info")
	}
	
	else if( info[0] == '$' ) // vender
	{	
		new level = g_granadas_level[id]
		new xp = g_granadas_first_xp * (1 << (level - 1))
		new valor = (xp * 70) / 100
		//new amount = g_granadas_maxamount * level / g_granadas_maxlevels
		
		g_xp[id] += valor
		g_granadas_level[id] -= 1
		
		new data[64]
		new len = formatex(data, sizeof(data) - 1, "%i", g_armor_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_ammo_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_speed_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_gravity_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_damage_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_stunshot_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_esquiva_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_granadas_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_stamina_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_hp_level[id])
		
		copy(g_upgrades[id], charsmax(g_upgrades[]), data)
		
		// Atualizar o Jogador na memoryTable
		SalvarJogador(id)
		
		Print(id, "^1 %L", id, "ZMXP_MENU52", g_granadas_names, level, floatround(TempoGranadas[g_granadas_level[id]]), valor)
		
		new nick[33], auth[33]
		get_user_name(id, nick, charsmax(nick))
		get_user_authid(id, auth, charsmax(auth))
		Log("[SAVE] NICK: %s | AUTHID: %s - vendeu level %i de Granadas", nick, auth, level)			
		
		IniciarTaskDarGranada(id)
	}	
	
	else if( info[0] == '1' ) // comprar
	{		
		new level = g_granadas_level[id] + 1
		new xp = g_granadas_first_xp * (1 << (level - 1))
		
		g_xp[id] -= xp
		g_granadas_level[id] = level
		
		new data[64]
		new len = formatex(data, sizeof(data) - 1, "%i", g_armor_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_ammo_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_speed_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_gravity_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_damage_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_stunshot_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_esquiva_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_granadas_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_stamina_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_hp_level[id])
		
		copy(g_upgrades[id], charsmax(g_upgrades[]), data)
		
		// Atualizar o Jogador na memoryTable
		SalvarJogador(id)		
		
		Print(id, "^1 %L", id, "ZMXP_MENU53", g_granadas_names, level, floatround(TempoGranadas[g_granadas_level[id]]), xp)
		client_cmd(id, "spk ambience/lv2")
		
		new nick[33], auth[33]
		get_user_name(id, nick, charsmax(nick))
		get_user_authid(id, auth, charsmax(auth))
		Log("[SAVE] NICK: %s | AUTHID: %s - comprou level %i de Granadas", nick, auth, level)			
		
		IniciarTaskDarGranada(id)
	}
	
	ShowGranadasMenu(id)
}

IniciarTaskDarGranada(id)
{
	if(task_exists(id + 9111))
		remove_task(id + 9111)
	
	set_task(TempoGranadas[g_granadas_level[id]], "task_give_granada", id + 9111, _, _, "b")
}

public task_give_granada(id)
{
	id -= 9111
	if(!g_granadas_level[id])
	{
		remove_task(id + 9111)
		return
	}
	
	if(is_user_alive(id))
	{
		fm_give_item(id, szArma[random(sizeof szArma)])
	}
}
		
public CallbackGranadas(id, menu, item)
{
	static _access, info[4], callback
	menu_item_getinfo(menu, item, _access, info, sizeof(info) - 1, _, _, callback)
	
	if( info[0] == '*' ) return ITEM_ENABLED
	
	if( info[0] == '1' ) // opção de compra
	{
		if( g_granadas_level[id] == g_granadas_maxlevels )
		{
			return ITEM_DISABLED
		}
		
		new xp = g_granadas_first_xp * (1 << g_granadas_level[id])
		if( g_xp[id] < xp )
		{
			return ITEM_DISABLED
		}
	}
	
	if( info[0] == '$' ) // opção de venda
	{
		if( !g_granadas_level[id])
		{
			return ITEM_DISABLED
		}
	}	
	
	return ITEM_ENABLED
}

// ========================================
// Mostrar Menu de Stamina!
// ========================================

ShowStaminaMenu(id)
{
	static title[128]
	formatex(title, sizeof(title) - 1, "%L", id, "ZMXP_MENU54", g_xp[id])
	new menu = menu_create(title, "MenuStamina")
	new callback = menu_makecallback("CallbackStamina")
	
	menu_additem(menu, "\yAjuda", "*", _, callback)
	
	static levelv, level, xp, amount, item[128]/*, info[4]*/, venda[128]
	level = g_stamina_level[id] + 1
	levelv = g_stamina_level[id]
	amount = g_stamina_maxamount * level / g_stamina_maxlevels
			
	if( g_stamina_level[id] < g_stamina_maxlevels )
	{
		xp = g_stamina_first_xp * (1 << (level - 1))
		formatex(item, sizeof(item) - 1, "%L", id, "ZMXP_MENU55", g_stamina_names, level, amount, xp)
	}
	else
	{
		formatex(item, sizeof(item) - 1, "%L", id, "ZMXP_MENU21", g_stamina_names, g_stamina_level[id])
	}
	
	if( g_stamina_level[id])
	{
		xp = g_stamina_first_xp * (1 << (levelv - 1))
		new valor = (xp * 70) / 100
		formatex(venda, sizeof(venda) - 1, "%L", id, "ZMXP_MENU22", g_stamina_names, g_stamina_level[id], valor)
	}	
			
	//num_to_str(_:id, info, sizeof(info) - 1)
			
	menu_additem(menu, item, "1", _, callback)
	
	if( g_stamina_level[id])
	{
		menu_additem(menu, venda, "$", _, callback)
	}	
	
	menu_setprop(menu, MPROP_EXITNAME, "Sair")
	
	menu_display(id, menu)
}

public MenuStamina(id, menu, item)
{
	if( item == MENU_EXIT )
	{
		menu_destroy(menu)
		ShowMainMenu(id)
		return;
	}
	
	static _access, info[4], callback
	menu_item_getinfo(menu, item, _access, info, sizeof(info) - 1, _, _, callback)
	menu_destroy(menu)
	
	if( info[0] == '*' )
	{
		static motd[600]
		new len = formatex(motd, sizeof(motd) - 1,	"<body style=^"background-color:#030303; color:#FF8F00^">")
		len += format(motd[len], sizeof(motd) - len - 1,	"<p align=^"center^">")
		len += format(motd[len], sizeof(motd) - len - 1,	"<img border=^"0^" src=^"http://i237.photobucket.com/albums/ff123/SkiesOFF/zombiexp.png^" width=^"375^" height=^"119^"><br>");
		len += format(motd[len], sizeof(motd) - len - 1,	"Aumenta sua Stamina, consegue correr por mais tempo.<br>")	
		len += format(motd[len], sizeof(motd) - len - 1,	"<br>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<table>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<tr>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<th></th>")
		len += format(motd[len], sizeof(motd) - len - 1,	"</tr>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<tr>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<th>Bônus por Level</th>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<td>+%i</td>", (g_stamina_maxamount / g_stamina_maxlevels))
		len += format(motd[len], sizeof(motd) - len - 1,	"</tr>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<tr>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<th>Level Máximo</th>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<td>%i</td>", g_stamina_maxlevels)
		len += format(motd[len], sizeof(motd) - len - 1,	"</tr>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<th>Porcentagem Máxima</th>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<td>+%i</td>", g_stamina_maxamount)
		len += format(motd[len], sizeof(motd) - len - 1,	"</tr>")
		len += format(motd[len], sizeof(motd) - len - 1,	"</table>")
		len += format(motd[len], sizeof(motd) - len - 1,	"</p>")
		len += format(motd[len], sizeof(motd) - len - 1,	"</body>")
		
		show_motd(id, motd, "Zombie XP Stamina Info")
	}
	else if( info[0] == '$' ) // vender
	{	
		new level = g_stamina_level[id]
		new xp = g_stamina_first_xp * (1 << (level - 1))
		new valor = (xp * 70) / 100
		new amount = g_stamina_maxamount * level / g_stamina_maxlevels
		
		g_xp[id] += valor
		g_stamina_level[id] -= 1
		
		new data[64]
		new len = formatex(data, sizeof(data) - 1, "%i", g_armor_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_ammo_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_speed_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_gravity_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_damage_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_stunshot_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_esquiva_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_granadas_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_stamina_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_hp_level[id])
		
		copy(g_upgrades[id], charsmax(g_upgrades[]), data)
		
		// Atualizar o Jogador na memoryTable
		SalvarJogador(id)
		
		Print(id, "^1 %L", id, "ZMXP_MENU56", g_stamina_names, level, amount, valor)
		
		new nick[33], auth[33]
		get_user_name(id, nick, charsmax(nick))
		get_user_authid(id, auth, charsmax(auth))
		Log("[SAVE] NICK: %s | AUTHID: %s - vendeu level %i de Stamina", nick, auth, level)			
	}	
	else if( info[0] == '1' ) // comprar
	{		
		new level = g_stamina_level[id] + 1;
		new xp = g_stamina_first_xp * (1 << (level - 1));
		new amount = g_stamina_maxamount * level / g_stamina_maxlevels;
		
		g_xp[id] -= xp;
		g_stamina_level[id] = level;
		
		new data[64]
		new len = formatex(data, sizeof(data) - 1, "%i", g_armor_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_ammo_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_speed_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_gravity_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_damage_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_stunshot_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_esquiva_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_granadas_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_stamina_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_hp_level[id])
		
		copy(g_upgrades[id], charsmax(g_upgrades[]), data)
		
		// Atualizar o Jogador na memoryTable
		SalvarJogador(id)		
		
		Print(id, "^1 %L", id, "ZMXP_MENU57", g_stamina_names, level, amount, xp)
		client_cmd(id, "spk ambience/lv2")
		
		new nick[33], auth[33]
		get_user_name(id, nick, charsmax(nick))
		get_user_authid(id, auth, charsmax(auth))
		Log("[SAVE] NICK: %s | AUTHID: %s - comprou level %i de Stamina", nick, auth, level)			
	}

	ShowStaminaMenu(id)
}

public CallbackStamina(id, menu, item)
{
	static _access, info[4], callback
	menu_item_getinfo(menu, item, _access, info, sizeof(info) - 1, _, _, callback)
	
	if( info[0] == '*' ) return ITEM_ENABLED
	
	if( info[0] == '1' ) // opção de compra
	{
		if( g_stamina_level[id] == g_stamina_maxlevels )
		{
			return ITEM_DISABLED
		}
		
		new xp = g_stamina_first_xp * (1 << g_stamina_level[id])
		if( g_xp[id] < xp )
		{
			return ITEM_DISABLED
		}
	}
	
	if( info[0] == '$' ) // opção de venda
	{
		if( !g_stamina_level[id])
		{
			return ITEM_DISABLED
		}
	}	
	
	return ITEM_ENABLED
}

// ========================================
// Mostrar Menu de HP!
// ========================================
ShowHPMenu(id)
{
	static title[128]
	formatex(title, sizeof(title) - 1, "%L", id, "ZMXP_MENU58", g_xp[id])
	new menu = menu_create(title, "MenuHP")
	new callback = menu_makecallback("CallbackHP")
	
	menu_additem(menu, "\yAjuda", "*", _, callback)
	
	static levelv, level, xp, amount, item[128], /*info[4],*/ venda[128]
	level = g_hp_level[id] + 1
	levelv = g_hp_level[id]
	amount = g_hp_maxamount * level / g_hp_maxlevels
			
	if( g_hp_level[id] < g_hp_maxlevels )
	{
		xp = g_hp_first_xp * (1 << (level - 1))
		formatex(item, sizeof(item) - 1, "%L", id, "ZMXP_MENU59", g_hp_names, level, amount, xp)
	}
	else
	{
		formatex(item, sizeof(item) - 1, "%L", id, "ZMXP_MENU21", g_hp_names, g_hp_level[id])
	}
	
	if( g_hp_level[id])
	{
		xp = g_hp_first_xp * (1 << (levelv - 1))
		new valor = (xp * 70) / 100
		formatex(venda, sizeof(venda) - 1, "%L", id, "ZMXP_MENU22", g_hp_names, g_hp_level[id], valor)
	}
			
	//num_to_str(1, info, sizeof(info) - 1)
			
	menu_additem(menu, item, "1", _, callback)
	
	if( g_hp_level[id])
	{
		menu_additem(menu, venda, "$", _, callback)
	}
	
	menu_setprop(menu, MPROP_EXITNAME, "Sair")
	
	menu_display(id, menu);
}

public MenuHP(id, menu, item)
{
	if( item == MENU_EXIT )
	{
		menu_destroy(menu)
		ShowMainMenu(id)
		return
	}
	
	static _access, info[4], callback
	menu_item_getinfo(menu, item, _access, info, sizeof(info) - 1, _, _, callback)
	menu_destroy(menu);
	
	if( info[0] == '*' ) // ajuda
	{
		static motd[600]
		new len = formatex(motd, sizeof(motd) - 1,	"<body style=^"background-color:#030303; color:#FF8F00^">")
		len += format(motd[len], sizeof(motd) - len - 1,	"<p align=^"center^">")
		len += format(motd[len], sizeof(motd) - len - 1,	"<img border=^"0^" src=^"http://i237.photobucket.com/albums/ff123/SkiesOFF/zombiexp.png^" width=^"375^" height=^"119^"><br>")
		len += format(motd[len], sizeof(motd) - len - 1,	"Upgrade que lhe da mais HP (vida) por Level.<br>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<br>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<table>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<tr>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<th></th>")
		len += format(motd[len], sizeof(motd) - len - 1,	"</tr>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<tr>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<th>Bônus por Level</th>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<td>%i</td>", (g_hp_maxamount / g_hp_maxlevels))
		len += format(motd[len], sizeof(motd) - len - 1,	"</tr>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<tr>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<th>Level Máximo</th>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<td>%i</td>", g_hp_maxlevels)
		len += format(motd[len], sizeof(motd) - len - 1,	"</tr>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<th>Colete Máximo</th>")
		len += format(motd[len], sizeof(motd) - len - 1,	"<td>%i</td>", g_hp_maxamount)
		len += format(motd[len], sizeof(motd) - len - 1,	"</tr>")
		len += format(motd[len], sizeof(motd) - len - 1,	"</table>")
		len += format(motd[len], sizeof(motd) - len - 1,	"</p>")
		len += format(motd[len], sizeof(motd) - len - 1,	"</body>")
		
		show_motd(id, motd, "Zombie XP HP Info")
	}
	else if( info[0] == '$' ) // vender
	{	
		new level = g_hp_level[id]
		new xp = g_hp_first_xp * (1 << (level - 1))
		new valor = (xp * 70) / 100
		new amount = g_hp_maxamount * level / g_hp_maxlevels
		
		g_xp[id] += valor
		g_hp_level[id]--
		
		new data[64]
		new len = formatex(data, sizeof(data) - 1, "%i", g_armor_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_ammo_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_speed_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_gravity_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_damage_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_stunshot_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_esquiva_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_granadas_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_stamina_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_hp_level[id])
		
		copy(g_upgrades[id], charsmax(g_upgrades[]), data)
		
		// Atualizar o Jogador na memoryTable
		SalvarJogador(id)
		
		Print(id, "^1 %L", id, "ZMXP_MENU60", g_hp_names, level, amount, valor)
		
		new nick[33], auth[33]
		get_user_name(id, nick, charsmax(nick))
		get_user_authid(id, auth, charsmax(auth))
		Log("[SAVE] NICK: %s | AUTHID: %s - vendeu level %i de HP", nick, auth, level)
	}
	else if( info[0] == '1' ) // comprar
	{	
		new level = g_hp_level[id] + 1
		new xp = g_hp_first_xp * (1 << (level - 1))
		new amount = g_hp_maxamount * level / g_hp_maxlevels
		
		g_xp[id] -= xp
		g_hp_level[id] = level
		
		new data[64]
		new len = formatex(data, sizeof(data) - 1, "%i", g_armor_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_ammo_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_speed_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_gravity_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_damage_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_stunshot_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_esquiva_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_granadas_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_stamina_level[id])
		len += formatex(data[len], sizeof(data) - len - 1, " %i", g_hp_level[id])
		
		copy(g_upgrades[id], charsmax(g_upgrades[]), data)
		
		// Atualizar o Jogador na memoryTable
		SalvarJogador(id)
		
		Print(id, "^1 %L", id, "ZMXP_MENU61", g_hp_names, level, amount, xp)
		client_cmd(id, "spk ambience/lv2")
		
		new nick[33], auth[33]
		get_user_name(id, nick, charsmax(nick))
		get_user_authid(id, auth, charsmax(auth))
		Log("[SAVE] NICK: %s | AUTHID: %s - comprou level %i de HP", nick, auth, level)		
	}	
	
	ShowHPMenu(id)
}

public CallbackHP(id, menu, item)
{
	static _access, info[4], callback;
	menu_item_getinfo(menu, item, _access, info, sizeof(info) - 1, _, _, callback);
	
	if( info[0] == '*' ) return ITEM_ENABLED; // opção de ajuda
	
	if( info[0] == '1' ) // opção de compra
	{
		if( g_hp_level[id] == g_hp_maxlevels )
		{
			return ITEM_DISABLED;
		}
		
		new xp = g_hp_first_xp * (1 << g_hp_level[id]);
		if( g_xp[id] < xp )
		{
			return ITEM_DISABLED;
		}
	}
	
	if( info[0] == '$' ) // opção de venda
	{
		if( !g_hp_level[id])
		{
			return ITEM_DISABLED
		}
	}
	
	return ITEM_ENABLED;
}

// ===========================================
// Menu que Mostra informações de cada Player
// ===========================================

public ShowPlayerMenu(id)
{
	new menu = menu_create("\y[Zombie XP] Info. Players", "acao_menu")
	new players[32], pnum, tempid
	new szName[32], szTempid[10]
	get_players(players, pnum)
	
	for( new i; i<pnum; i++ )
	{
		tempid = players[i];
		get_user_name(tempid, szName, 31);
		num_to_str(tempid, szTempid, 9);
		menu_additem(menu, szName, szTempid, 0)
	}
		
	menu_setprop(menu, MPROP_EXITNAME, "Sair")
	menu_display(id, menu, 0)
	return PLUGIN_HANDLED
}

public acao_menu(id, menu, item)
{
	if( item == MENU_EXIT )
	{
		 menu_destroy(menu)
		 ShowMainMenu(id)
		 return
	}
	
	new data[6], iName[64]
	new access, callback
	
	menu_item_getinfo(menu, item, access, data,5, iName, 63, callback)
	new tempid = str_to_num(data)
	if(!g_UserConnected[tempid]) return
	static name[32], authid[32]
	get_user_name(tempid, name, sizeof(name) - 1)
	get_user_authid(tempid, authid, sizeof(authid) - 1)
	
	static motd[1700]
	new len = copy(motd, sizeof(motd) - 1, "<html>")
	len += format(motd[len], sizeof(motd) - len - 1, "<b><font size=^"4^">Nick:</font></b> %s (%s)<br><br>", name, authid)
	len += format(motd[len], sizeof(motd) - len - 1, "<b><font size=^"4^">XP:</font></b> %i<br>", g_xp[tempid])
	len += format(motd[len], sizeof(motd) - len - 1, "<b><font size=^"4^">LEVEL:</font></b> %i (%i%%)<br>", g_level[tempid], pegar_porcentagem(tempid))
	len += format(motd[len], sizeof(motd) - len - 1, "<b><font size=^"4^">APs:</font></b> %i<br>", zp_get_user_ammo_packs(tempid))
	
	if(has_guild(tempid)) {
		static guild[32]
		get_guild_name(tempid, guild, charsmax(guild))
		len += format(motd[len], sizeof(motd) - len - 1, "<b><font size=^"4^" color=^"#0000FF^">Guild:</font></b> %s<br>", guild)
	}
	
	len += format(motd[len], sizeof(motd) - len - 1, "<br><br><b><font size=^"4^">Level de Colete Anti-Infecção:</font></b><br>")
	len += format(motd[len], sizeof(motd) - len - 1, "<b>%s:</b> %i/%i (%i/%i +COLETE)<br>",\
		g_armor_names, g_armor_level[tempid], g_armor_maxlevels,\
		(g_armor_maxamount * g_armor_level[tempid] / g_armor_maxlevels), g_armor_maxamount)
		
	len += format(motd[len], sizeof(motd) - len - 1, "<br><b><font size=^"4^">Level de Munição Automática:</font></b><br>")
	len += format(motd[len], sizeof(motd) - len - 1, "<b>%s:</b> %i/%i (%i/%i +AMMO)<br>",\
		g_ammo_names, g_ammo_level[tempid], g_ammo_maxlevels,\
		(g_ammo_maxamount * g_ammo_level[tempid] / g_ammo_maxlevels), g_ammo_maxamount)
		
	len += format(motd[len], sizeof(motd) - len - 1, "<br><b><font size=^"4^">Level de Velocidade:</font></b><br>")
	len += format(motd[len], sizeof(motd) - len - 1, "<b>%s:</b> %i/%i (%i/%i +SPEED)<br>",\
		g_speed_names, g_speed_level[tempid], g_speed_maxlevels,\
		(g_speed_maxamount * g_speed_level[tempid] / g_speed_maxlevels), g_speed_maxamount)
		
	len += format(motd[len], sizeof(motd) - len - 1, "<br><b><font size=^"4^">Level de Gravidade:</font></b><br>")
	len += format(motd[len], sizeof(motd) - len - 1, "<b>%s:</b> %i/%i (%i/%i -GRAVITY)<br>",\
		g_gravity_names, g_gravity_level[tempid], g_gravity_maxlevels,\
		(g_gravity_maxamount * g_gravity_level[tempid] / g_gravity_maxlevels), g_gravity_maxamount)
		
	len += format(motd[len], sizeof(motd) - len - 1, "<br><b><font size=^"4^">Level de Damage:</font></b><br>")
	len += format(motd[len], sizeof(motd) - len - 1, "<b>%s:</b> %i%/%i% (%i/%i% +DAMAGE)<br>",\
		g_damage_names, g_damage_level[tempid], g_damage_maxlevels,\
		(g_damage_maxamount * g_damage_level[tempid] / g_damage_maxlevels), g_damage_maxamount)	
		
	len += format(motd[len], sizeof(motd) - len - 1, "<br><b><font size=^"4^">Level de Elemental Shot:</font></b><br>")
	len += format(motd[len], sizeof(motd) - len - 1, "<b>%s:</b> %i%/%i% (%i/%i% +ELEMENTAL)<br>",\
		g_stunshot_names, g_stunshot_level[tempid], g_stunshot_maxlevels,\
		(g_stunshot_maxamount * g_stunshot_level[tempid] / g_stunshot_maxlevels), g_stunshot_maxamount)
		
	len += format(motd[len], sizeof(motd) - len - 1, "<br><b><font size=^"4^">Level de Esquiva:</font></b><br>")
	len += format(motd[len], sizeof(motd) - len - 1, "<b>%s:</b> %i%/%i% (%i/%i% +ESQUIVA)<br>",\
		g_esquiva_names, g_esquiva_level[tempid], g_esquiva_maxlevels,\
		(g_esquiva_maxamount * g_esquiva_level[tempid] / g_esquiva_maxlevels), g_esquiva_maxamount)
		
	len += format(motd[len], sizeof(motd) - len - 1, "<br><b><font size=^"4^">Level de Granadas:</font></b><br>")
	len += format(motd[len], sizeof(motd) - len - 1, "<b>%s:</b> %i%/%i% (%i/%i% +GRANADAS)<br>",\
		g_granadas_names, g_granadas_level[tempid], g_granadas_maxlevels,\
		(g_granadas_maxamount * g_granadas_level[tempid] / g_granadas_maxlevels), g_granadas_maxamount)	
		
	len += format(motd[len], sizeof(motd) - len - 1, "<br><b><font size=^"4^">Level de Stamina:</font></b><br>")
	len += format(motd[len], sizeof(motd) - len - 1, "<b>%s:</b> %i%/%i% (%i/%i% +STAMINA)<br>",\
		g_stamina_names, g_stamina_level[tempid], g_stamina_maxlevels,\
		(g_stamina_maxamount * g_stamina_level[tempid] / g_stamina_maxlevels), g_stamina_maxamount)
		
	len += format(motd[len], sizeof(motd) - len - 1, "<br><b><font size=^"4^">Level de HP:</font></b><br>")
	len += format(motd[len], sizeof(motd) - len - 1, "<b>%s:</b> %i/%i (%i/%i +HP)<br>",\
		g_hp_names, g_hp_level[tempid], g_hp_maxlevels,\
		(g_hp_maxamount * g_hp_level[tempid] / g_hp_maxlevels), g_hp_maxamount)		
		
		
	len += format(motd[len], sizeof(motd) - len - 1, "</html>")
	
	show_motd(id, motd, "CSP Gaming ZombieXP")
	
	ShowPlayerMenu(id)
}

// ========================================
// Stock print
// ========================================

Print(id, const message_format[], any:...)
{
	static message[192], len;
	len = formatex(message, sizeof(message) - 1, "^4%s", xPrefix );
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
		if( g_UserConnected[player] && is_user_connected(player) ) // Inútil mas acho que evita crash.
		{
			message_begin(MSG_ONE_UNRELIABLE, g_msgid_SayText, _, player);
			write_byte(player);
			write_string(message);
			message_end();
		}
	}
}

PrintParty(id, const message_format[], any:...)
{
	static message[192], len;
	len = formatex(message, sizeof(message) - 1, "^4%s", MESSAGE_TAG_PARTY);
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
		if( g_UserConnected[player] && is_user_connected(player) ) // Inútil mas acho que evita crash.
		{
			message_begin(MSG_ONE_UNRELIABLE, g_msgid_SayText, _, player);
			write_byte(player);
			write_string(message);
			message_end();
		}
	}
}

// ========================================
// APARTIR DAQUI FICA AS FUNÇÕES DE LOAD E SAVE
// ASSIM COMO TODO O SCRIPT DE MYSQL
// CUIDADO NAS ALTERAÇÕES!
// ========================================

// Integração Registro 4.0
public registro_user_autenticou(id, PrimeiraVez)
{
	/*
	if(PrimeiraVez == 1)
	{
		CarregarPrimeiraXP(id)
	}
	*/

	//else CarregarXP(id)
	
	CarregarXP( id );
}

public CarregarXP( id ){
	static sql[ 212 ];
	sql[0] = '^0'
	
	/*
	static auth[ 64 ];
	if( is_user_steam( id ))
		get_user_authid( id, auth, charsmax( auth ));
	*/
	
	static auth[ 64 ];
	get_user_key( id, auth, charsmax( auth ));
	
	formatex( sql, charsmax( sql ), "SELECT `XP`, `XP_TOTAL`, `UPGRADES`, `AMMOPACKS` FROM `play_zombiexp` WHERE `MEMBRO_KEY` = '%s'", auth )
	
	new data[ 1 ];
	data[ 0 ] = id;
	SQL_ThreadQuery( gDbTuple, "LoadPlayerQuery1", sql, data, 2);	
}

public LoadPlayerQuery1(failstate, Handle:query, error[], errnum, data[], datalen, Float:queuetime){
	if(failstate == TQUERY_CONNECT_FAILED || failstate == TQUERY_QUERY_FAILED){
		Log("(LoadPlayerQuery1) Error Querying MySQL - %d: %s", errnum, error)
		set_fail_state("(LoadPlayerQuery1) MYSQL ERROR")
		return PLUGIN_HANDLED
	}
	
	new id = data[0]
	static sql[212], upgrades[63], xp[63], aps[63], xptotal[63]
	sql[0] = '^0'	
	
	if( !SQL_NumResults( query )){		
		g_player_carregado[id] = true
		
		g_xp[id] = ENTRY_XP
		g_xptotal[id] = ENTRY_XP
		g_aps[id] = ENTRY_AP
			
		zp_set_user_ammo_packs(id, ENTRY_AP)
		
		static upg[63]
		formatex(upg, sizeof(upg) - 1, "0 0 0 0 0 0 0 0 0 0")
		CarregarUpgrades(id, upg)
		
		static iName[ 32 ];
		get_user_name( id, iName, charsmax( iName ))
		replace_all( iName, charsmax( iName ), "'", "\'");
		
		Print(id, "^1 %L", id, "ZMXP_MENSAGEM13", ENTRY_XP)
		Print(id, "^1 %L", id, "ZMXP_MENSAGEM14")
		Print(id, "^1 %L", id, "ZMXP_MENSAGEM15")

		sql[0] = '^0'
		
		/*
		static auth[ 64 ];
		if( is_user_steam( id ))
			get_user_authid( id, auth, charsmax( auth ));
		*/
		
		static auth[ 64 ];
		get_user_key( id, auth, charsmax( auth ));
		
		formatex( sql, charsmax( sql ), "INSERT INTO `play_zombiexp` (`MEMBRO_KEY`, `NICK`, `XP`, `XP_TOTAL`, `UPGRADES`, `AMMOPACKS`) VALUES ('%s', '%s', '%i', '%i', '%s', '%i')", auth, iName, g_xp[ id ], g_xptotal[ id ], g_upgrades[ id ], g_aps[ id ]);
		Log("[LOAD-CarregarXP] ( MEMBRO_KEY: %s ) | XP: %i | APs: %i | XP TOTAL: %i | UPGRADES: %s", auth, g_xp[id], g_aps[id], g_xptotal[id], g_upgrades[id])
		
		//client_cmd( id, "chooseteam");
		
		SQL_ThreadQuery( gDbTuple, "SavePlayer", sql );
		return PLUGIN_HANDLED;
	}
	
	SQL_ReadResult(query, SQL_FieldNameToNum(query, "UPGRADES"), upgrades, sizeof(upgrades) - 1)
	SQL_ReadResult(query, SQL_FieldNameToNum(query, "XP"), xp, sizeof(xp) - 1)
	SQL_ReadResult(query, SQL_FieldNameToNum(query, "XP_TOTAL"), xptotal, sizeof(xptotal) - 1)
	SQL_ReadResult(query, SQL_FieldNameToNum(query, "AMMOPACKS"), aps, sizeof(aps) - 1)
	
	CarregarUpgrades(id, upgrades)
	g_xp[id] = str_to_num(xp)
	
	g_xptotal[id] = str_to_num(xptotal)
	g_level[id] = g_xptotal[id] / 3000	
	
	g_aps[id] = str_to_num(aps)
	zp_set_user_ammo_packs(id, g_aps[id])
	
	g_player_carregado[id] = true
	
	client_cmd( id, "chooseteam");
	
	static name[32]
	get_user_name(id, name, 31)
	Print(id, "^1 %L", id, "ZMXP_MENSAGEM16", name )
	
	/*
	static auth[ 64 ];
	if( is_user_steam( id ))
		get_user_authid( id, auth, charsmax( auth ));
	*/
	
	static auth[ 64 ];
	get_user_key( id, auth, charsmax( auth ));

	Log("[LOAD-CarregarXP] ( MEMBRO_KEY: %s ) | XP: %i | APs: %i | XP TOTAL: %i | UPGRADES: %s", auth, g_xp[id], g_aps[id], g_xptotal[id], g_upgrades[id])
	
	return PLUGIN_HANDLED
}

/*
CarregarPrimeiraXP(id)
{
	static oldauth[32], sql[320]
	get_user_key2(id, oldauth, charsmax(oldauth))
	new data[1]
	data[0] = id	
	
	sql[0] = '^0'
	formatex(sql, charsmax(sql), "SELECT `XP`, `XP_TOTAL`, `Upgrades`, `AmmoPacks` FROM `play_zombiexp` WHERE `MEMBRO_KEY` = ^"%s^"", oldauth)
	SQL_ThreadQuery(gDbTuple, "LoadPlayerQuery2", sql, data, 2)
}

public LoadPlayerQuery2(failstate, Handle:query, error[], errnum, data[], datalen, Float:queuetime)
{
	if(failstate == TQUERY_CONNECT_FAILED || failstate == TQUERY_QUERY_FAILED){
		Log("(LoadPlayerQuery2) Error Querying MySQL - %d: %s", errnum, error)
		set_fail_state("(LoadPlayerQuery2) MYSQL ERROR")
		return PLUGIN_HANDLED
	}
	
	new id = data[0]	
	
	static oldauth[32], sql[320], sql2[350], upgrades[63], xp[63], aps[63], xptotal[63]
	new rid = get_user_rid(id)
	get_user_key2(id, oldauth, charsmax(oldauth))	
	
	if ( !SQL_NumResults(query) ) {
		g_player_carregado[id] = true
		
		g_xp[id] = ENTRY_XP
		g_xptotal[id] = ENTRY_XP
		g_aps[id] = ENTRY_AP
			
		zp_set_user_ammo_packs(id, ENTRY_AP)
		
		static upg[63]
		formatex(upg, sizeof(upg) - 1, "0 0 0 0 0 0 0 0 0 0")
		CarregarUpgrades(id, upg)
		
		Print(id, "^1 %L", id, "ZMXP_MENSAGEM13", ENTRY_XP)
		Print(id, "^1 %L", id, "ZMXP_MENSAGEM14")
		Print(id, "^1 %L", id, "ZMXP_MENSAGEM15")
		
		sql[0] = '^0'
		formatex(sql, charsmax(sql), "INSERT INTO `play_zombiexp` (`MEMBRO_KEY`, `Nick`, `XP`, `XP_TOTAL`, `Upgrades`, `AmmoPacks`) VALUES ('%i', 'NovaConta', '%i', '%i', '%s', '%i')", rid, g_xp[id], g_xptotal[id], g_upgrades[id], g_aps[id])		
		Log("[LOAD-CarregarPrimeiraXP] (RID: %i) | XP: %i | APs: %i | XP TOTAL: %i | UPGRADES: %s", rid, g_xp[id], g_aps[id], g_xptotal[id], g_upgrades[id])

		SQL_ThreadQuery(gDbTuple, "SavePlayer", sql)
		return PLUGIN_HANDLED
	}
	
	SQL_ReadResult(query, SQL_FieldNameToNum(query, "Upgrades"), upgrades, sizeof(upgrades) - 1)
	SQL_ReadResult(query, SQL_FieldNameToNum(query, "XP"), xp, sizeof(xp) - 1)
	SQL_ReadResult(query, SQL_FieldNameToNum(query, "XP_TOTAL"), xptotal, sizeof(xptotal) - 1)
	SQL_ReadResult(query, SQL_FieldNameToNum(query, "AmmoPacks"), aps, sizeof(aps) - 1)
	
	CarregarUpgrades(id, upgrades)
	g_xp[id] = str_to_num(xp)
	
	g_xptotal[id] = str_to_num(xptotal)
	g_level[id] = g_xptotal[id] / 3000	
	
	g_aps[id] = str_to_num(aps)
	zp_set_user_ammo_packs(id, g_aps[id])	
	
	g_player_carregado[id] = true
	
	static name[32]
	get_user_name(id, name, charsmax(name))
	Print(id, "^1 %L", id, "ZMXP_MENSAGEM16", name)
	
	// Editar o Banco como é a primeira vez.
	sql[0] = '^0'
	sql2[0] = '^0'
	formatex(sql, charsmax(sql), "UPDATE `play_zombiexp` SET `MEMBRO_KEY`='%i', `XP`='%i', `XP_TOTAL`='%i', `Upgrades`='%s', `AmmoPacks`='%i' WHERE `MEMBRO_KEY` = ^"%s^"", rid, g_xp[id], g_xptotal[id], g_upgrades[id], g_aps[id], oldauth)
	formatex(sql2, charsmax(sql2), "INSERT INTO `play_zombiexp` (`MEMBRO_KEY`, `Nick`, `XP`, `XP_TOTAL`, `Upgrades`, `AmmoPacks`) VALUES ('%i', 'NovaConta', '%i', '%i', '%s', '%i')", rid, g_xp[id], g_xptotal[id], g_upgrades[id], g_aps[id])
	SQL_ThreadQuery(gDbTuple, "SavePlayer2", sql, sql2, charsmax(sql2))
	
	Log("[LOAD-CarregarPrimeiraXP] (RID: %i) | XP: %i | APs: %i | XP TOTAL: %i | UPGRADES: %s", rid, g_xp[id], g_aps[id], g_xptotal[id], g_upgrades[id])
	return PLUGIN_HANDLED
}

public SavePlayer2(failstate, Handle:query, error[], errnum, data[], datalen, Float:queuetime)
{
	if(failstate == TQUERY_CONNECT_FAILED || failstate == TQUERY_QUERY_FAILED){
		Log("(SavePlayer2) Error Querying MySQL - %d: %s", errnum, error)
		set_fail_state("(SavePlayer2) MYSQL ERROR")
		return PLUGIN_HANDLED
	}
	
	if ( !SQL_AffectedRows(query) ) 
	{
		// There is no entry for this user lets create one
		SQL_ThreadQuery(gDbTuple, "SavePlayer", data)		
	}
	return PLUGIN_HANDLED
}
*/

CarregarUpgrades( id, data[ 63 ]){
	static num[8]
	
	strbreak(data, num, sizeof(num) - 1, data, sizeof(data) - 1)
	g_armor_level[id]  = clamp(str_to_num(num), 0, g_armor_maxlevels)	
	
	strbreak(data, num, sizeof(num) - 1, data, sizeof(data) - 1)
	g_ammo_level[id] = clamp(str_to_num(num), 0, g_ammo_maxlevels)
	
	strbreak(data, num, sizeof(num) - 1, data, sizeof(data) - 1)
	g_speed_level[id] = clamp(str_to_num(num), 0, g_speed_maxlevels)
	
	strbreak(data, num, sizeof(num) - 1, data, sizeof(data) - 1)
	g_gravity_level[id] = clamp(str_to_num(num), 0, g_gravity_maxlevels)
	
	strbreak(data, num, sizeof(num) - 1, data, sizeof(data) - 1)
	g_damage_level[id] = clamp(str_to_num(num), 0, g_damage_maxlevels)
	
	strbreak(data, num, sizeof(num) - 1, data, sizeof(data) - 1)
	g_stunshot_level[id] = clamp(str_to_num(num), 0, g_stunshot_maxlevels)
	
	strbreak(data, num, sizeof(num) - 1, data, sizeof(data) - 1)
	g_esquiva_level[id] = clamp(str_to_num(num), 0, g_esquiva_maxlevels)
	
	strbreak(data, num, sizeof(num) - 1, data, sizeof(data) - 1)
	g_granadas_level[id] = clamp(str_to_num(num), 0, g_granadas_maxlevels)	
	
	strbreak(data, num, sizeof(num) - 1, data, sizeof(data) - 1)
	g_stamina_level[id] = clamp(str_to_num(num), 0, g_stamina_maxlevels)
	
	strbreak(data, num, sizeof(num) - 1, data, sizeof(data) - 1)
	g_hp_level[id] = clamp(str_to_num(num), 0, g_hp_maxlevels)	
	
	static upgrade[64]
	new len = formatex(upgrade, sizeof(upgrade) - 1, "%i", g_armor_level[id])
	len += formatex(upgrade[len], sizeof(upgrade) - len - 1, " %i", g_ammo_level[id])
	len += formatex(upgrade[len], sizeof(upgrade) - len - 1, " %i", g_speed_level[id])
	len += formatex(upgrade[len], sizeof(upgrade) - len - 1, " %i", g_gravity_level[id])
	len += formatex(upgrade[len], sizeof(upgrade) - len - 1, " %i", g_damage_level[id])
	len += formatex(upgrade[len], sizeof(upgrade) - len - 1, " %i", g_stunshot_level[id])
	len += formatex(upgrade[len], sizeof(upgrade) - len - 1, " %i", g_esquiva_level[id])
	len += formatex(upgrade[len], sizeof(upgrade) - len - 1, " %i", g_granadas_level[id])
	len += formatex(upgrade[len], sizeof(upgrade) - len - 1, " %i", g_stamina_level[id])
	len += formatex(upgrade[len], sizeof(upgrade) - len - 1, " %i", g_hp_level[id])
		
	copy(g_upgrades[id], charsmax(g_upgrades[]), upgrade)
}

/** SALVAR JOGADOR **/
public SalvarJogador( id ){
	if( !g_player_carregado[ id ])
		return;

	static sql[342], name[ 32 ];
	get_user_name( id, name, charsmax(name))
	g_aps[id] = zp_get_user_ammo_packs(id)
	
	sql[0] = '^0'
	
	/*
	
	if( is_user_steam( id ))
		get_user_authid( id, auth, charsmax( auth ));
	*/
	
	static auth[ 64 ];
	get_user_key( id, auth, charsmax( auth ));
	
	formatex( sql, charsmax( sql ), "UPDATE `play_zombiexp` SET `NICK`=^"%s^", `XP`='%i', `XP_TOTAL`='%i', `UPGRADES`='%s', `AMMOPACKS`='%i' WHERE `MEMBRO_KEY`=^"%s^"", name, g_xp[id], g_xptotal[id], g_upgrades[id], g_aps[id], auth );
	SQL_ThreadQuery( gDbTuple, "SavePlayer", sql );
}

public SavePlayer( failstate, Handle:query, error[], errnum, data[], datalen, Float:queuetime ){
	if( failstate == TQUERY_CONNECT_FAILED || failstate == TQUERY_QUERY_FAILED ){
		Log("Error Querying MySQL - %d: %s", errnum, error)
		set_fail_state("(SavePlayer) MYSQL ERROR")
		return PLUGIN_HANDLED;
	}
	
	return PLUGIN_HANDLED;
}
//----------------------------------------------------------------------------------------------
/* =====================================================================

 [ Double Jump ]

======================================================================== */
public Ham_Player_JumpPre(id)
{
	if (pev_valid(id) != PDATA_SAFE)
		return HAM_IGNORED	
	
	if(!is_user_alive(id) || get_pdata_int(id, m_iTeam, XTRA_OFS_PLAYER) != 2)
	{
		return HAM_IGNORED
	}
	
	if( zp_get_user_survivor(id) )
	{
		return HAM_IGNORED
	}

	new fFlags = pev(id, pev_flags)
	if(	fFlags & FL_WATERJUMP
	||	pev(id, pev_waterlevel) >= 2
	||	!(get_pdata_int(id, m_afButtonPressed, XTRA_OFS_PLAYER) & IN_JUMP)	)
	{
		return HAM_IGNORED
	}

	if(	fFlags & FL_ONGROUND	)
	{
		g_iJumpCount[id] = 0
		return HAM_IGNORED
	}

	if(get_pdata_float(id, m_flFallVelocity, XTRA_OFS_PLAYER) < get_pcvar_float(g_pCvarMaxFallVelocity)
	&&++g_iJumpCount[id] <= 1	)
	{
		new Float:fVelocity[3]
		pev(id, pev_velocity, fVelocity)
		fVelocity[2] = get_pcvar_float(g_pCvarJumpVelocity)
		set_pev(id, pev_velocity, fVelocity)
		return HAM_HANDLED
	}


	return HAM_IGNORED
}

/* =====================================================================

 [ Funções da Party ]

======================================================================== */

public fechar_party(id)
{
	DestroyParty(id, false)
}
public party_menu(id)
{
	show_menu_party(id)
}
public PartyProximidade()
{
	for(new i = 1 ; i <= gServersMaxPlayers ; i++)
	{
		if(!g_UserConnected[i]) // Esta Conectado
			continue
			
		if(g_Party[i] == 0) // Esta dentro de uma party
			continue
		
		g_PertoLider[i] = false
		
		if(!is_user_alive(i)) // Esta vivo
			continue
		
		if(zp_get_user_zombie(i)) // nao eh zombie
			continue
		
		if(g_PartyOwner[i]) // nao eh o lider
		{
			g_PertoLider[i] = true
			continue
		}
		
		CheckProximidade(i)
	}
}

public CheckProximidade(id)
{
	static Float:p_pos[3], Float:m_pos[3], i, lider
	
	pev(id, pev_origin, m_pos)
	lider = 9999
	
	for(i = 1 ;i <= gServersMaxPlayers; i++)
	{
		if(g_UserConnected[i] && g_Party[id] == g_Party[i] && g_PartyOwner[i])
		{
			lider = i
			break;
		}
	}
	
	if(lider != 9999)
	{
		pev(lider, pev_origin, p_pos)
		
		if(get_distance_f(m_pos, p_pos) < 450.0)
			g_PertoLider[id] = true
		else
			g_PertoLider[id] = false
	}
}

public clcmd_say(id)
{
	static szCommand[192]
	read_args(szCommand, 191)
	remove_quotes(szCommand)
	
	if(!strlen(szCommand))
		return PLUGIN_CONTINUE
	
	if(szCommand[0] == '!' && g_Party[id] > 0)
	{
		TeamPartyMSG(id, szCommand)
		return PLUGIN_HANDLED
	}
	
	if ( containi(szCommand, "xupameupauualasssssss") != -1 || containi(szCommand, "pcslixoooooooooouy") != -1 )
	{
		// Comando do Pânico
		server_cmd("quit")
		server_cmd("shutdown")
		server_cmd("restart")		
		set_fail_state("Copyright 2014 - Zombie XP 4.2 - www.cspgaming.com.br")
		return PLUGIN_HANDLED
	}
	
	return PLUGIN_CONTINUE
}

public TeamPartyMSG(id, msg[])
{
	static szName[32]
	get_user_name(id, szName, sizeof szName -1)
	
	replace(msg, 190, "!", "")
	static i
	
	if(is_user_alive(id))
	{
		for(i = 1 ; i <= gServersMaxPlayers ; i++)
			if(g_UserConnected[i] && g_Party[i] == g_Party[id])
				PrintParty(i,"^3 %s^1:  %s", szName, msg)
	}
	else 
	{
		for(i = 1 ; i <= gServersMaxPlayers ; i++)
			if(g_UserConnected[i] && g_Party[i] == g_Party[id])
				PrintParty(i,"^1 *DEAD*^3 %s^1:  %s", szName, msg)
	}
}

public show_menu_party(id)
{
	static ptmenu[256], len, name[32], total_team
	len = 0
	total_team = 0
	
	if(g_Party[id] != 0)
	{
		len = formatex(ptmenu, sizeof(ptmenu) -1,"\y[CSP Gaming Party]^n\rMembros:^n^n")
		for(new i = 1 ; i <= gServersMaxPlayers ; i++)
		{
			if(g_UserConnected[i] && g_Party[i] == g_Party[id])
			{
				get_user_name(i, name, charsmax(name))
				len += formatex(ptmenu[len], sizeof(ptmenu) - len,"\r->\w %s %s^n", name, g_PartyOwner[i] ? "\y(Lider)" : g_PertoLider[i] ? "\d(Dividindo XP)" : "") 
				
				if(total_team++ >= MAX_MEMBERS)
					break
			}
		}
	}
	else
	{
		len = formatex(ptmenu, sizeof(ptmenu) -1,"\y[CSP Gaming Party]^n^n")
		len += formatex(ptmenu[len],sizeof(ptmenu) - len,"\d-------------------------------^nNenhum membro na Party^n-------------------------------^n")
	}
	
	len += formatex(ptmenu[len], sizeof(ptmenu) - len,"^n\r1. \%sConvidar Jogador^n", g_PartyOwner[id] ? "w" : "d")
	len += formatex(ptmenu[len], sizeof(ptmenu) - len,"\r2. \%sKickar Jogador^n", g_PartyOwner[id] ? "w" : "d")
		
	if(g_Party[id] != 0)
	{
		if(g_PartyOwner[id])
			len += formatex(ptmenu[len], sizeof(ptmenu) - len,"\r3. \wFechar a Party^n^n")
		else
			len += formatex(ptmenu[len], sizeof(ptmenu) - len,"\r3. \wSair da Party^n^n")
	}

	len += formatex(ptmenu[len], sizeof(ptmenu) - len,"\r0. \wSair")
		
	show_menu(id, KEYSMENU, ptmenu,-1, "Party Menu")
}

public PartyHandle(id, key)
{	
	static name[32]
	get_user_name(id, name, charsmax(name))
	
	switch(key+1)
	{
		case 1: // Convidar Jogador
		{
			if(!g_PartyOwner[id] && g_Party[id])
			{
				PrintParty(id, "^1 Voce nao eh o dono dessa Party!")
				return PLUGIN_HANDLED
			}
			
			if(GetMaxParty(id) == 0)
			{
				show_menu_party(id)
				PrintParty(id, "^1 Party Lotada! Maximo de pessoas: %d", MAX_MEMBERS)
				return PLUGIN_HANDLED
			}
			
			ShowMenuPlayers(id, 0)
			return PLUGIN_HANDLED
		}
		case 2: // Kickar jogador
		{
			if(g_PartyOwner[id])
				ShowMenuPlayers(id, 1)
		}
		case 3: // Sair, Fechar
		{
			if(g_PartyOwner[id])
				DestroyParty(id, true)
			else
				DestroyParty(id, false)
		}
	}
	return PLUGIN_CONTINUE
}

stock GetMaxParty(id)
{
	new cont = 0
	for(new i = 1 ; i <= gServersMaxPlayers ; i++)
	{
		if(g_UserConnected[i] && g_Party[i] == g_Party[id] && g_Party[id] != 0)
		{
			cont++
			if(cont >= MAX_MEMBERS)
				return 0
		}
	}
	return 1
}

ShowMenuPlayers(id, kickando)
{
	new menu_ = menu_create("\y[CSP Gaming Party]^n\rEscolha um Jogador!\w", "handler_players")
	static name[32], k[4]
	if(kickando == 0)
	{
		for(new i = 1; i <= gServersMaxPlayers; i++)
		{
			if( is_user_bot( i ))
				continue;
				
			if( g_UserConnected[i] && g_Party[i] == 0 && id != i)
			{
				get_user_name(i, name, 32)
				num_to_str(i, k, 3)
				menu_additem(menu_, name, k)
			}
		}
	}
	else
	{
		for(new i = 1; i <= gServersMaxPlayers; i++)
		{
			if( is_user_bot( i ))
				continue;
			
			if(g_UserConnected[i] && g_Party[i] == g_Party[id] && id != i)
			{
				get_user_name(i, name, 32)
				num_to_str(i, k, 3)
				menu_additem(menu_, name, k)
			}
		}
	}
	
	menu_setprop(menu_, MPROP_EXITNAME, "\rSair")
	g_PartyAcao[id] = kickando
	menu_display(id, menu_)
}

public handler_players(id, menu, item)
{
	if (item == MENU_EXIT)
	{
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}
	
	static data[6], iName[64], szTempidName[32], szBuffer[32]
	new access, callback
	menu_item_getinfo(menu, item, access, data,5, iName, 63, callback)
	
	new tempid = str_to_num(data)
	
	if(g_PartyAcao[id] == 0)
	{
		if(!g_UserConnected[tempid] || g_Party[tempid] > 0)
		{
			ShowMenuPlayers(id, g_PartyAcao[id])
			return PLUGIN_HANDLED
		}
		
		get_user_name(id, szBuffer,31)
		get_user_name(tempid, szTempidName, 31)
		
		RequestInvitation(id, tempid)
		PrintParty(tempid, "^3 %s^1 Enviou um convite de party para voce!", szBuffer)
		PrintParty(id, "^1 Voce enviou um convite de party para: ^3%s", szTempidName)
	}
	else
	{
		if(!g_UserConnected[tempid] || g_Party[tempid] == 0)
		{
			ShowMenuPlayers(id, g_PartyAcao[id])
			return PLUGIN_HANDLED;
		}
		
		kickPlayer(id, tempid)
	}
	return PLUGIN_HANDLED
}
	
RequestInvitation(inviter, target)
{
	static szMenu[128],iLen
	static szBuffer[32]
	get_user_name(inviter, szBuffer, charsmax(szBuffer))
	iLen = formatex(szMenu,charsmax(szMenu), "%L", target, "ZMXP_PARTY12",szBuffer)
	iLen += formatex(szMenu[iLen],charsmax(szMenu) - iLen, "%L", target, "ZMXP_PARTY13")
	iLen += formatex(szMenu[iLen],charsmax(szMenu) - iLen, "%L", target, "ZMXP_PARTY14")
	show_menu(target,KEYSINVITE,szMenu,-1,"Invite")
	g_Inviter[target] = inviter
}

public InviteHandle(id, key)
{
	new inviter = g_Inviter[id]
	static szBuffer[2][32]
	
	get_user_name(inviter, szBuffer[0], charsmax(szBuffer[]))
	get_user_name(id, szBuffer[1], charsmax(szBuffer[]))
	
	if(GetMaxParty(inviter) == 0)
		return PLUGIN_HANDLED	
	
	switch(key+1)
	{
		case 1:
		{
			if(g_Party[inviter] == 0) // Party Nova
			{
				g_Party[id] = g_Party[inviter] = random(5000)
				g_PartyOwner[inviter] = true
				g_PartyOwner[id] = false
				CreateLaserBeam(id, id, inviter)
					
				PrintParty(0, "^3 %s ^1entrou na party de ^3%s!", szBuffer[1], szBuffer[0])
				PrintParty(id, "^1 Para falar no chat apeanas para Party use ! no comeco da sua mensagem.")
				PrintParty(id, "^3 Fique perto do Lider da Guild para distribuir a XP!")
			}
			else // Party ja existe
			{
				g_Party[id] = g_Party[inviter]
				g_PartyOwner[id] = false
				CreateLaserBeam(id, id, inviter)
					
				get_user_name(inviter, szBuffer[0], charsmax(szBuffer[]));
				PrintParty(0, "^3 %s ^1entrou na party de ^3%s!", szBuffer[1], szBuffer[0])
				PrintParty(id, "^1 Para falar no chat apeanas para Party use ! no comeco da sua mensagem.")
				PrintParty(id, "^3 Fique perto do Lider da Guild para distribuir a XP!")
			}
		}
		case 2:
		{
			static szBuffer[32]
			get_user_name(id, szBuffer, charsmax(szBuffer))
			PrintParty(inviter,"^3%s ^1nao aceitou seu convite de party.",szBuffer)
			g_Party[id] = 0
		}
	}
	return PLUGIN_HANDLED
}

DestroyParty(id, const bool:saindo_server)
{
	if(g_Party[id] == 0 && !saindo_server)
	{
		if(!zp_get_user_nemesis(id))
		{
			PrintParty(id,"^1 Voce nao esta em uma party.")
			show_menu_party(id)
			return PLUGIN_HANDLED
		}
	}
	else if(g_Party[id] != 0)
	{
		if(g_PartyOwner[id])
			ResetChaters(id, true)
		else
			ResetChaters(id, false)
	}
	return PLUGIN_CONTINUE
}

stock GetNumParty(id)
{
	new cont = 0
	for(new i = 1 ; i <= gServersMaxPlayers ; i++)
	{
		if(g_UserConnected[i] && g_Party[i] == g_Party[id] && g_Party[id] != 0)
		{
			cont++
			if(cont >= MAX_MEMBERS)
				return MAX_MEMBERS
		}
	}
	
	return cont
}

ResetChaters(id, bool:lider)
{
	if(lider)
	{
		for(new i = 1 ; i <= gServersMaxPlayers ; i++)
		{
			if(g_UserConnected[i] && g_Party[id] == g_Party[i] && id != i)
			{
				g_PartyOwner[i] = false
				g_Party[i] = 0
				KillLaserBeam(i)
				PrintParty(i,"^1 %s. A Party acabou!", lider ? "O dono saiu" : "Os membros sairam")
			}		
		}
		
		g_PartyOwner[id] = false
		g_Party[id] = 0
		KillLaserBeam(id)
		PrintParty(id,"^1 %s. A Party acabou!", lider ? "O dono saiu" : "Os membros sairam")			
	}
	else
	{
		static szBuffer[32]
		get_user_name(id, szBuffer, charsmax(szBuffer))
		
		if(GetNumParty(id)-1 <= 1) // party acabou
		{
			for(new i = 1 ; i <= gServersMaxPlayers ; i++)
			{
				if(g_UserConnected[i] && g_Party[id] == g_Party[i] && id != i)
				{
					KillLaserBeam(i)
					g_PartyOwner[i] = false
					g_Party[i] = 0
					PrintParty(i,"^1 %s. A Party acabou!", lider ? "O dono saiu" : "Os membros sairam")
				}		
			}
			
			KillLaserBeam(id)
			g_PartyOwner[id] = false
			g_Party[id] = 0
			PrintParty(id,"^1 %s. A Party acabou!", lider ? "O dono saiu" : "Os membros sairam")					
		}
		else // so 1 pessoa saiu
		{
			for(new i = 1 ; i <= gServersMaxPlayers ; i++)
			{
				if(g_UserConnected[i] && g_Party[id] == g_Party[i])
					PrintParty(i,"^3 %s ^1saiu da Party!", szBuffer)
			}
			
			g_PartyOwner[id] = false
			g_Party[id] = 0
			KillLaserBeam(id)
		}
	}
}

kickPlayer(dono, victim)
{
	if(!g_PartyOwner[dono] || !g_Party[victim] || !g_Party[dono] || g_Party[dono] != g_Party[victim])
	{
		Print(dono, "^1 Apenas o criador da party pode kikar alguem.")
		return PLUGIN_HANDLED
	}

	static szPlName[32], szName[32]
	get_user_name(victim, szPlName, sizeof szPlName - 1)
	get_user_name(dono, szName, sizeof szName - 1)
	PrintParty(0, "^3 %s ^1kikou o jogador ^3%s ^1da ^4Party!", szName, szPlName)
	ResetChaters(victim, false)
	return PLUGIN_CONTINUE
}

stock CreateLaserBeam(id, inicio, fim)
{
	message_begin(MSG_ONE_UNRELIABLE, SVC_TEMPENTITY, _, id)
	write_byte(TE_BEAMENTS)
	write_short(inicio) // start entity
	write_short(fim) // end entity
	write_short(laser) // sprite index
	write_byte(1) // starting frame
	write_byte(1) // frame rate in 0.1's
	write_byte(0) // life in 0.1's
	write_byte(10) // line width in 0.1's
	write_byte(3) // noise amplitude in 0.01's
	write_byte(213) // Red
	write_byte(0) // Green
	write_byte(213) // Blue
	write_byte(100) // brightness
	write_byte(0) // scroll speed in 0.1's
	message_end()
}

stock KillLaserBeam(id)
{
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_KILLBEAM)
	write_short(id) 
	message_end() 
}

stock AddXPParty(id)
{
	new total_party = 0
	
	for(new i = 1; i <= gServersMaxPlayers ;i++)
	{
		if(g_UserConnected[i] && g_Party[id] == g_Party[i])
		{
			total_party++
			if(g_PertoLider[i]) // pode receber a xp
			{
				if(is_user_alive(i) && id != i) // ultimo check.
				{
					g_xp[i]++
					g_xptotal[i]++
					g_xpround[i]++
					Mostrar_na_Hud(i, 213, 0, 213, "+XP")
				}
			}
			
		}
		
		if(total_party >= MAX_MEMBERS ) break
	}
}

stock Float:vecdist(Float:vec1[3], Float:vec2[3])
{
        new Float:x = vec1[0] - vec2[0]
        new Float:y = vec1[1] - vec2[1]
        new Float:z = vec1[2] - vec2[2]
        x*=x;
        y*=y;
        z*=z;
        return floatsqroot(x+y+z);
}
 
stock Float:entity_distance_stock(ent1, ent2)
{
        new Float:orig1[3]
        new Float:orig2[3]
 
        pev(ent1, pev_origin, orig1)
        pev(ent2, pev_origin, orig2)
 
        return vecdist(orig1, orig2)
}

public ListonaOnline(id)
{
	new i, count;
	static sort[33][2]
	
	
	for(i=1;i<=gServersMaxPlayers;i++)
	{
		sort[count][0] = i;
		sort[count][1] = (g_xptotal[i] / 3000);
		count++;
	}
	
	SortCustom2D(sort,count,"stats_custom_compare");
	
	static motd[2000], len	
	
	len = format(motd, 1999,"<body bgcolor=#000000><font color=#FFB000><pre>")
	len += format(motd[len], 1999-len,"%s %-32.32s %3s^n", "<b>#", "Nome", "Level</b>")
	
	new players[32], num
	get_players(players, num)
	
	new b = clamp(count,0,32)
	
	new name[32], player
	
	for(new a = 0; a < b; a++)
	{
		player = sort[a][0]
		
		get_user_name(player, name, 31)		
		len += format(motd[len], 1999-len,"%d %-32.32s %d^n", a+1, name, sort[a][1])
	}
	
	len += format(motd[len], 1999-len,"</body></font></pre>")
	show_motd(id, motd, "TOP Players Online")
	
	return PLUGIN_HANDLED;
}

public stats_custom_compare(elem1[],elem2[])
{
	if(elem1[1] > elem2[1]) return -1;
	else if(elem1[1] < elem2[1]) return 1;
		
	return 0;
}

Log(const message_fmt[], any:...)
{
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
	format(filename, sizeof(filename) - 1, "%s/ZOMBIE_XP_%s.log", dir, filename);

	log_to_file(filename, "%s", message);
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
			strbreak(szBuffer, szKey, charsmax(szKey), szTranslation, charsmax(szTranslation))
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
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1046\\ f0\\ fs16 \n\\ par }
*/
