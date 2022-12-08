/* =====================================================================
Copyright 2012 - CS DarK Guilds 1.5-Beta - www.zplague.com.br
# Proibida cópia total ou parcial desse plugin! #

              Plugin desenvolvido por anarkista
	             skiesoff@gmail.com

                       - Agradecimentos -

Shine      -> Algumas idéias e ajuda
Skyzika    -> Testes e bug report
GustavoSilveira -> TOP10 Guilds.

                       - Features -

- Sistema de Guild com até 6 membros;
- Líder da Guild tem total controle sobre a mesma;
- Rank de Guilds baseado em Pontos;
- Level de Guild baseada em Pontos com adicionais;
- TOP15 de Guilds;
- Banco da Guild com opção de Saque controlada;
- TAG e Nome customizáveis pelo Líder;
- Guild Chat;
- Guild Voice;
- Proteção para jogadores Non-Steam (compatível com o registro);
- Sistema feito e optimizado para MySQL LOCALHOST.

-> Guild só pode ser criada e destruida por um Administrador com RCON. (não mais)
-> Guild Master só serão aceitos se tiverem VIP no momento da criação.

     Guild Master Menu
	     |
	      -> Adicionar novo membro (por menu)
	      -> Remover membro (comando)
	      -> Aceitar ou Recusar saques do Banco (por menu)
	      -> Alterar Nome da Guild (comando)
	      -> Alterar TAG da Guild (comando)
	      
     Menu de Membros
	     |
	      -> Ver Rank da Guild (chat)
	      -> Ver TOP15 Guilds (motd)
	      -> Sacar AMMO PACKS do Banco da Guild (por menu)
	      -> Stats de todos os membros (motd)
	      -> Sair da Guild (comando)	      
		       
                       - Changelog -
		       
	versão 1.0 BETA
	     |
	      -> Lançamento inicial no servidor.
	
	versão 1.1 BETA
	     |
	      -> Possibilidade de criar Guild liberada ( assim como excluir )
                 Compatibilidade com o Registro 4.0.
		 
	versão 1.5 BETA
	     |
	      -> Os próprios jogadores podem criar Guild
                 O líder pode ser passado para outro Membro
		 O líder pode fechar a Guild.
		 Função get_guild_name consertada.
		 
	Versão 1.5b
	     |
	      -> Trocou nome para Play4Ever
		  
	versão 2.0
		|
		-> Banco Logs
		-> Evento TOP Guilds
		-> Novo menu que mostra todas as guilds online
		-> Novo MOTD de informacoes de cada Guild
		-> Alguns codigos reformulados e otimizados.
	
	versão 5.0
		|- Atualização no Banco de dados.
		|- Mudando sistema para, MEMBRO_KEY, do registro.
		|- Alterado Estilo dos menus.
	      
	      
********************************************************************/

#include < amxmodx >
#include < amxmisc >
#include < cstrike >
#include < hamsandwich >
#include < fakemeta >
#include < play_registro >
#include < zombieplague >
#include < play_zombiexp >
#include < sqlx >
#include < play_global >

#define PLUGIN "[ZMXP] Guilds Manager"
#define VERSION "5.0"

#define GUILD_LIMIT 10

new const MESSAGE_TAG_GUILD[] = "[GUILD]"

// Guilda Membro
new bool:g_GuildaMembro[33] // 1 = tem guild / 0 = nao tem guild
new g_GuildaID[33] // De qual guild ele é? [GUILDid]
new bool:g_GuildaLider[33] // 1 = Lider de uma Guild / 0 = nao é lider
new g_GuildaNome[33][33] // Qual nome da Guild? Apenas para mostrar.
new g_GuildaTag[33][33] // Qual a tag da Guild? Apenas para mostrar.
new g_GuildaMembros[33] // Quantos membros tem na guilda desse cara.
new g_GuildaPoints[33] // Quantos pontos tem na guilda desse cara. (soft cache)
new g_GuildaRank[33] // Qual o rank atual da guilda desse cara. (soft cache)
new bool:g_JogadorConectado[33] // true = conectado / false = desconectado
new bool:g_GuildaVoice[33] = false

new g_GuildaBankSaque[33] // guarda quanto o cara quer sacar da guild

// registra o ID do usuario que esta sendo convidada
new g_iTentandoConvidar[33]
new g_iInviter[33]

new g_BancoSaqueLider[33]
new g_BancoSaqueLiderQuantia[33]

new totalrank, gServerMaxPlayers, g_msgid_SayText

new g_typed[192], g_message[192], g_name[32], g_team

// Guilda Menu
const KEYSMENU = MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_5|MENU_KEY_6|MENU_KEY_7|MENU_KEY_8|MENU_KEY_9|MENU_KEY_0
const KEYSINVITE = (1<<0)|(1<<1)

// MYSQL
new guild_mysql_persistent
new Handle:gDbTuple
new Handle:gDbConnect
new bool:gPersistentTemp
static error[128]

public plugin_init(){
	register_plugin( PLUGIN, VERSION, AUTHOR );
	
	// cvar ai...
	guild_mysql_persistent = register_cvar("guild_mysql_persistent", "0")
	
	// Comando para criar guild.
	//register_concmd("amx_addguild", "AdicionarGuild", ADMIN_RCON, "[Nome da Guilda / TAG da Guild / SAVEKEY do Lider / Nick do Lider / ID]")
	
	// Comandos do Lider
	register_concmd("guild_nome", "Master_Nome", ADMIN_ALL, "Altera o NOME da Guild - Limite de 16 caracteres!")
	register_concmd("guild_tag", "Master_Tag", ADMIN_ALL, "Altera TAG da Guild - Limite de 15 caracteres!")
	
	// Guild Message
	register_clcmd("say", "HookSay")
	register_clcmd("say_team", "HookSayTeam")	
	
	// Abrir menu de guilda
	register_say("guild", "Abrir_GuildaMenu");
	register_say("guilds", "Abrir_GuildsOnline");
	
	register_clcmd("guild", "Abrir_GuildaMenu")
	
	// Sair da Guild
	register_clcmd("quit_guild", "Kitar_Guild")
	
	// Fechar Guild
	register_clcmd("fechar_guild", "Fechar_Guild")
	
	// Guild Voice
	register_forward( FM_Voice_SetClientListening, "voice_listening");
	
	register_clcmd("+guildvoice", "VoiceOn")
	register_clcmd("-guildvoice", "VoiceOff")	
	
	// Registrando o menu da guilda
	register_menu("Guilda Menu", KEYSMENU, "GuildaHandle")
	register_menu("Opcoes Menu", KEYSMENU, "OpcoesHandle")
	register_menu("Banco Menu", KEYSMENU, "BancoHandle")
	register_menu("Admin Menu", KEYSMENU, "AdminHandle")
	register_menu("Excluir Menu", KEYSMENU, "ExcluirHandle")
	register_menu("Criar Menu", KEYSMENU, "CriarHandle")
	register_menu("Convidar",KEYSINVITE,"ConvidarHandle")
	register_menu("Saque",KEYSINVITE,"SaqueHandle")
	
	gServerMaxPlayers = get_maxplayers()
	g_msgid_SayText = get_user_msgid("SayText")
	
	#include "play4ever.inc/play_conecta.play"
}

public plugin_natives(){
	register_library("guilds")
	register_native("has_guild", "_has_guild")
	register_native("set_member_points", "_set_points")
	register_native("get_guild_name", "_get_guild_name")
}

// true = tem guild / false = nao tem
public _has_guild(id, params)
{
	return g_GuildaMembro[get_param(1)]
}
// retorna o nome da guild caso ele tenha
public _get_guild_name(plugin_id, param_nums)
{
	if(param_nums != 3)
		return -1
    
	static id; id = get_param(1)
    
	if(!g_JogadorConectado[id] || !g_GuildaMembro[id])
		return 0
    
	set_string(2, g_GuildaNome[id], get_param(3))
	
	return 1
}
// MemberPoints e BankPoints!
public _set_points( id, params ){
	new id = get_param(1)
	new newpontos = get_param(2)
	new newbankpontos = get_param(3)
	
	if( !g_JogadorConectado[id] || !g_GuildaMembro[ id ])
		return 1
	
	static sql[212];

	if( newpontos <= 0 )
		return 1;
	
	new iName[ 32 ];
	get_user_name( id, iName, charsmax( iName ))
	replace_all( iName, charsmax( iName ), "'", "\'")
	
	sql[0] = '^0'
	
	/*
	static auth[ 64 ];
	if( is_user_steam( id ))
		get_user_authid( id, auth, charsmax( auth ));
	*/
	
	static auth[ 64 ];
	get_user_key( id, auth, charsmax( auth ));
	
	formatex( sql, charsmax( sql ), "UPDATE `play_guilds_membros` SET `PONTOS`=`PONTOS` + '%i', `NICK`='%s' WHERE `MEMBRO_KEY`='%s'", newpontos, iName, auth );
	SQL_ThreadQuery(gDbTuple, "SalvarPlayerGuild", sql)	
	
	if( newbankpontos <= 0 )
		return 1;	
	
	sql[0] = '^0'
	formatex(sql, charsmax(sql), "UPDATE `play_guilds` SET `ZMXP_AMMOPACKS`=`ZMXP_AMMOPACKS` + '%i' WHERE `ID`='%i'", newbankpontos, g_GuildaID[id])
	SQL_ThreadQuery(gDbTuple, "SalvarPlayerGuild", sql)
	return 1
}

public SalvarPlayerGuild(failstate, Handle:query, error[], errnum, data[], datalen, Float:queuetime)
{
	if(failstate == TQUERY_CONNECT_FAILED || failstate == TQUERY_QUERY_FAILED){
		Log("(SalvarPlayerGuild) Error Querying MySQL - %d: %s", errnum, error)
	}
	
	return PLUGIN_HANDLED
}

// Integração Registro 4.0
public registro_user_autenticou( id, PrimeiraVez ){
	/*
	if(PrimeiraVez == 1){
		CarregarPrimeiraGuild(id)
	}
	else CarregarGuild(id)
	*/

	CarregarGuild( id );
}

CarregarGuild( id ){	
	new data[1]
	data[0] = id	
	
	static sql[ 212 ];
	sql[0] = '^0'
	
	/*
	static auth[ 64 ];
	if( is_user_steam( id ))
		get_user_authid( id, auth, charsmax( auth ));
	*/
	
	static auth[ 64 ];
	get_user_key( id, auth, charsmax( auth ));
	
	formatex( sql, charsmax( sql ), "SELECT `ID`, `LIDER` FROM `play_guilds_membros` WHERE `MEMBRO_KEY` = '%s'", auth );
	SQL_ThreadQuery(gDbTuple, "GuildQueryLoad1", sql, data, 2);
	
	return PLUGIN_HANDLED
}

public GuildQueryLoad1(failstate, Handle:query, error[], errnum, data[], datalen, Float:queuetime)
{
	new id = data[0]
	
	if(failstate){
		Log("(GuildQueryLoad1) Error Querying MySQL - %d: %s", errnum, error)
		
		g_GuildaMembro[id] = false
		g_GuildaID[id] = 0
		g_GuildaLider[id] = false
		g_GuildaMembros[id] = 0
		g_GuildaPoints[id] = 0
		g_GuildaRank[id] = 0
		g_iTentandoConvidar[id] = 0
		g_iInviter[id] = 0		
		return PLUGIN_HANDLED
	}
	
	static guildid[63], lider[63]
	
	if ( !SQL_NumResults(query) )
	{
		g_GuildaMembro[id] = false
		g_GuildaID[id] = 0
		g_GuildaLider[id] = false
		g_GuildaMembros[id] = 0
		g_GuildaPoints[id] = 0
		g_GuildaRank[id] = 0
		g_iTentandoConvidar[id] = 0
		g_iInviter[id] = 0
		return PLUGIN_HANDLED
	}
	
	static sql[212]
	
	SQL_ReadResult(query, SQL_FieldNameToNum(query, "ID"), guildid, sizeof(guildid) - 1)
	SQL_ReadResult(query, SQL_FieldNameToNum(query, "LIDER"), lider, sizeof(lider) - 1)
	
	g_GuildaID[id] = str_to_num(guildid)
	
	if(str_to_num(lider) == 1)
	{
		g_GuildaLider[id] = true
	}
	else  g_GuildaLider[id] = false
	
	g_iTentandoConvidar[id] = 0 // Sei la se precisa...
	g_iInviter[id] = 0 // Sei la se precisa...	
	
	/////////////////////// Carregando agora informação sobre a guild do cara.
	sql[0] = '^0'
	formatex(sql, charsmax(sql), "SELECT `GUILD_NAME`, `GUILD_TAG`, `ZMXP_PONTOS` FROM `play_guilds` WHERE `ID` = '%i'", g_GuildaID[id])	
	
	SQL_ThreadQuery(gDbTuple, "GuildQueryLoad2", sql, data, 2)
	return PLUGIN_HANDLED
}

public GuildQueryLoad2(failstate, Handle:query, error[], errnum, data[], datalen, Float:queuetime){
	new id = data[0]
	
	if(failstate){
		Log("(GuildQueryLoad2) Error Querying MySQL - %d: %s", errnum, error)	
		return PLUGIN_HANDLED
	}
	
	static guildapontos[64]
	
	SQL_ReadResult(query, SQL_FieldNameToNum(query, "GUILD_NAME"), g_GuildaNome[id], sizeof(g_GuildaNome) - 1)
	SQL_ReadResult(query, SQL_FieldNameToNum(query, "GUILD_TAG"), g_GuildaTag[id], sizeof(g_GuildaTag) - 1)
	SQL_ReadResult(query, SQL_FieldNameToNum(query, "ZMXP_PONTOS"), guildapontos, sizeof(guildapontos) - 1)
	
	g_GuildaPoints[id] = str_to_num(guildapontos)
	g_GuildaMembro[id] = true
	
	static name[32]
	get_user_name(id, name, 31)
	PrintGuild(id, "^1 Sua guild^3 %s^1 foi carregada com sucesso!", g_GuildaNome[id])
	
	return PLUGIN_HANDLED;
}

public Kitar_Guild( id ){
	if( !g_GuildaMembro[ id ]){
		console_print( id, "[GUILD] Voce nao faz parte de nenhuma guild!");
		return PLUGIN_HANDLED;
	}
	
	if( g_GuildaLider[ id ]){
		console_print( id, "[GUILD] Voce eh o lider de uma guild, nao pode sair assim!");
		return PLUGIN_HANDLED;
	}
	
	if( !registro_user_liberado( id )){
		PrintGuild( id, "^1 Voce nao tem autorizacao para fazer isso.")
		return PLUGIN_HANDLED;
	}
	
	console_print( id, "[GUILD] Removendo voce da Guild %s. Aguarde...", g_GuildaNome[ id ])
	
	mySQLConnect();
	if( gDbConnect == Empty_Handle )
		return false;
	
	static sql[180]
	new Handle:query, errcode
	
	new name[32]
	get_user_name(id, name, 31)	

	sql[0] = '^0'
	
	/*
	static auth[ 64 ];
	if( is_user_steam( id ))
		get_user_authid( id, auth, charsmax( auth ));
	*/
	
	static auth[ 64 ];
	get_user_key( id, auth, charsmax( auth ));

	formatex( sql, charsmax( sql ), "DELETE FROM `play_guilds_membros` WHERE `MEMBRO_KEY`='%s'", auth );
	query = SQL_PrepareQuery(gDbConnect, "%s", sql);
	
	if ( !SQL_Execute(query) ) {
		errcode = SQL_QueryError(query, error, charsmax(error))
		Log("Erro ao remover membro %s: da Guild %s [%d] '%s' - '%s'", name, g_GuildaNome[id], errcode, error, sql)
		SQL_FreeHandle(query)
		console_print(id, "[GUILD] Houve um erro no banco de dados... nao foi possivel remover voce da guild.")
		return PLUGIN_HANDLED;
	}
	
	PrintGuild(0, "^3 %s ^1saiu da Guild^3 %s", name, g_GuildaNome[id])
	
	for (new x = 1; x <= gServerMaxPlayers; x++){
		if(g_JogadorConectado[x] && g_GuildaMembro[x] && g_GuildaID[x] == g_GuildaID[id]){
			// O cara saiu... codigo meio inutil mas fodac
			g_GuildaMembros[x]--
		}
	}
	
	g_GuildaMembro[id] = false
	g_GuildaID[id] = 0
	g_GuildaLider[id] = false
 	g_GuildaMembros[id] = 0
 	g_GuildaPoints[id] = 0
 	g_GuildaRank[id] = 0
	g_iTentandoConvidar[id] = 0
	g_iInviter[id] = 0
	
	SQL_FreeHandle(query)
	close_mysql()
	
	console_print(id, "[GUILD] Voce saiu da guild com sucesso!")
	
	return PLUGIN_HANDLED;
}

public Fechar_Guild(id)
{
	if(!g_GuildaMembro[id])
	{
		console_print(id, "[GUILD] Voce nao faz parte de nenhuma guild!")
		return PLUGIN_HANDLED;
	}
	
	if(!g_GuildaLider[id])
	{
		console_print(id, "[GUILD] Voce nao eh o lider de uma guild!")
		return PLUGIN_HANDLED;
	}
	
	if(!registro_user_liberado(id))
	{
		PrintGuild(id, "^1 Voce nao tem autorizacao para fazer isso.")
		return PLUGIN_HANDLED;
	}
	
	console_print(id, "[GUILD] Fechando Guild %s. Aguarde...", g_GuildaNome[id])
	
	// Primeiro Deletamos Todos os Membros....
	
	mySQLConnect()
	if ( gDbConnect == Empty_Handle ) return false
	
	static sql[180]
	new Handle:query
	new errcode
	
	new name[32]
	get_user_name(id, name, 31)	

	sql[0] = '^0'
	formatex(sql, charsmax(sql), "DELETE FROM `play_guilds_membros` WHERE `ID`='%i'", g_GuildaID[id])
	query = SQL_PrepareQuery(gDbConnect, "%s", sql)
	if ( !SQL_Execute(query) ) {
		errcode = SQL_QueryError(query, error, charsmax(error))
		Log("Erro ao fechar a guild. Lider %s. Guild: %s [%d] '%s' - '%s'", name, g_GuildaNome[id], errcode, error, sql)
		SQL_FreeHandle(query)
		console_print(id, "[PLAY GUILD] Houve um erro no banco de dados... nao foi possivel fechar a guild.")
		return PLUGIN_HANDLED;
	}
	
	SQL_FreeHandle(query)
	
	// Segundo, deletamos do outro banco também...
	
	sql[0] = '^0'
	formatex(sql, charsmax(sql), "DELETE FROM `play_guilds` WHERE `ID`='%i'", g_GuildaID[id])
	query = SQL_PrepareQuery(gDbConnect, "%s", sql)
	if ( !SQL_Execute(query) ) {
		errcode = SQL_QueryError(query, error, charsmax(error))
		Log("(2) Erro ao fechar a guild. Lider %s. Guild: %s [%d] '%s' - '%s'", name, g_GuildaNome[id], errcode, error, sql)
		SQL_FreeHandle(query)
		console_print(id, "[GUILD] Houve um erro no banco de dados... nao foi possivel fechar a guild corretamente.")
		//return PLUGIN_HANDLED; a funcao nao pode parar aqui... depois o admin limpa o banco!
	}
	
	PrintGuild(0, "^3 %s ^1fechou a Guild^3 %s", name, g_GuildaNome[id])
	
	SQL_FreeHandle(query)
	close_mysql()	
	
	// Terceiro, removemos todos os membros que estão online.
	
	for (new x = 1; x <= gServerMaxPlayers; x++)
	{
		if(g_JogadorConectado[x] && g_GuildaMembro[x] && g_GuildaID[x] == g_GuildaID[id] && !g_GuildaLider[x])
		{
			// limpando!
			g_GuildaMembro[x] = false
			g_GuildaID[x] = 0
			g_GuildaLider[x] = false
			g_GuildaMembros[x] = 0
			g_GuildaPoints[x] = 0
			g_GuildaRank[x] = 0
		}
	}
	
	g_GuildaMembro[id] = false
	g_GuildaID[id] = 0
	g_GuildaLider[id] = false
 	g_GuildaMembros[id] = 0
 	g_GuildaPoints[id] = 0
 	g_GuildaRank[id] = 0
	g_iTentandoConvidar[id] = 0
	g_iInviter[id] = 0
	
	console_print(id, "[GUILD] Voce fechou a Guild com sucesso!")
	return PLUGIN_HANDLED;
}

LiderTransferMenu(id)
{
	static title[128];
	formatex(title, sizeof(title) - 1, "\y[ %s ]  \wTransferir Lider:^n", g_GuildaNome[id])
	new menu_ = menu_create(title, "acao2_menu")
	new name[33], k[4]
	
	for(new i = 1 ; i <= gServerMaxPlayers ; i++)
	{
		if(!g_JogadorConectado[i] || id == i || !g_GuildaMembro[i] || g_GuildaID[i] != g_GuildaID[id])
		continue
		
		get_user_name(i, name, 32)
		num_to_str(i, k, 3)
		menu_additem(menu_, name, k)
	}
	
	menu_setprop(menu_, MPROP_EXITNAME, "\rSair")
	menu_display(id, menu_)
}

public acao2_menu( id, menu, item ){
	if( item == MENU_EXIT ){
		 menu_destroy(menu)
		 return PLUGIN_HANDLED;
	}
	
	if( !registro_user_liberado( id )){
		PrintGuild(id, "^1 Voce nao tem autorizacao para fazer isso.")
		return PLUGIN_HANDLED;
	}
	
	if( !g_GuildaLider[ id ]){
		PrintGuild(id, "^1 Voce nao eh o dono dessa guild!")
		return PLUGIN_HANDLED;
	}	
	
	new data[6], iName[64]
	new access, callback
	
	menu_item_getinfo(menu, item, access, data,5, iName, 63, callback)
	new tempid = str_to_num(data)
	
	if( !g_JogadorConectado[ tempid ])
		return PLUGIN_HANDLED;
	
	if( g_GuildaLider[ tempid ]){
		PrintGuild(id, "^1 Erro na acao!")
		return PLUGIN_HANDLED;
	}
	
	if( g_GuildaID[ tempid ] != g_GuildaID[ id ]){
		PrintGuild(id, "^1 Erro na acao!")
		return PLUGIN_HANDLED;
	}
	
	// KEY OLD
	/*
	static auth_old[ 64 ];
	if( is_user_steam( id ))
		get_user_authid( id, auth_old, charsmax( auth_old ));
	*/
	
	static auth_old[ 64 ];
	get_user_key( id, auth_old, charsmax( auth_old ));
	
	// KEY ALVO
	/*
	static auth_alvo[ 64 ];
	if( is_user_steam( tempid ))
		get_user_authid( tempid, auth_alvo, charsmax( auth_alvo ));
	*/
	
	static auth_alvo[ 64 ];
	get_user_key( tempid, auth_alvo, charsmax( auth_alvo ));
	
	/*
	if( ridalvo == 0 ){
		PrintGuild( id, "^1 Essa pessoa precisa ser registrada no Registro 4.0!")
		return PLUGIN_HANDLED;
	}
	
	if( ridold == 0 ){
		PrintGuild(id, "^1 Voce nao eh registrado no Registro 4.0 ainda!")
		return PLUGIN_HANDLED;
	}
	*/
	
	static namer[32]
	get_user_name(tempid, namer, sizeof(namer) - 1)
	
	mySQLConnect()
	if( gDbConnect == Empty_Handle )
		return PLUGIN_HANDLED;
	
	static sql[180]
	new Handle:query, errcode	
	
	sql[0] = '^0'
	formatex( sql, charsmax( sql ), "UPDATE `play_guilds_membros` SET `LIDER`='0' WHERE `MEMBRO_KEY`='%s'", auth_old );
	query = SQL_PrepareQuery(gDbConnect, "%s", sql);
	
	if( !SQL_Execute( query )){
		errcode = SQL_QueryError( query, error, charsmax( error ));
		Log("Erro ao transferir lider de Guild (1) [%d] '%s' - '%s'", errcode, error, sql );
		PrintGuild(id, "^1 Houve um erro no banco de dados...");
		SQL_FreeHandle( query );
		return PLUGIN_HANDLED;
	}
	
	SQL_FreeHandle( query );
	
	sql[0] = '^0'
	formatex( sql, charsmax( sql ), "UPDATE `play_guilds_membros` SET `LIDER`='1' WHERE `MEMBRO_KEY`='%s'", auth_alvo );
	query = SQL_PrepareQuery(gDbConnect, "%s", sql)	
	
	if ( !SQL_Execute(query) ) {
		errcode = SQL_QueryError(query, error, charsmax(error))
		Log("Erro ao transferir lider de Guild (2) [%d] '%s' - '%s'", errcode, error, sql)
		PrintGuild(id, "^1 Houve um erro no banco de dados... Contate um administrador.")
		SQL_FreeHandle(query)
		return PLUGIN_HANDLED;
	}
	
	SQL_FreeHandle(query)
	
	sql[0] = '^0'
	formatex( sql, charsmax( sql ), "UPDATE `play_guilds` SET `KEY_LIDER`='%s' WHERE `ID`='%i'", auth_alvo, g_GuildaID[ id ] );
	query = SQL_PrepareQuery(gDbConnect, "%s", sql)	
	
	if ( !SQL_Execute(query) ) {
		errcode = SQL_QueryError(query, error, charsmax(error))
		Log("Erro ao transferir lider de Guild (3) [%d] '%s' - '%s'", errcode, error, sql)
		PrintGuild(id, "^1 Houve um erro no banco de dados... Contate um administrador.")
		SQL_FreeHandle(query)
		return PLUGIN_HANDLED;
	}
	
	SQL_FreeHandle(query)
	
	close_mysql()
	
	g_GuildaLider[id] = false
	g_GuildaLider[tempid] = true
	
	PrintGuild(0, "^1 A Guild^3 %s^1 foi transferida com sucesso para o Lider^3 %s", g_GuildaNome[id], namer)
	return PLUGIN_HANDLED
}

public Abrir_GuildsOnline(id)
{
	if(!registro_user_liberado(id))
	{
		PrintGuild(id, "^1 Voce nao tem autorizacao para fazer isso.")
		return PLUGIN_HANDLED;
	}
	
	// criando nossa lista
	new OnlineGuilds[33][3], n = 0, flag = 0

	for(new i = 1; i <= gServerMaxPlayers; i++) 
	{
		if(g_JogadorConectado[i] && g_GuildaMembro[i])
		{
			flag = 0
			
			for(new x = 1; x < 33; x++) 
			{
				if(OnlineGuilds[x][0] == g_GuildaID[i]) // Ja ta no sistema
				{
					OnlineGuilds[x][2]++ // aumentando a quantidade de membros online!
					flag = 1
					break;
				}
			}
			
			if(flag == 0) // não ta no sistema ainda
			{
				OnlineGuilds[n][0] = g_GuildaID[i] // colocando a guild no topo da lista
				OnlineGuilds[n][1] = i // so pra pegar um id de referência, assim nao preciso criar uma string
				OnlineGuilds[n][2]++ // aumentando a quantidade de membros online!
				n++ // atualiza o topo
			}
		}
	}
	// lista criada!
	
	new iTemp[ 128 ];
	formatex( iTemp, charsmax( iTemp ), "\d%s - Guilds Online:", xPrefix );
	new menu = menu_create( iTemp, "ation_menu")
	static szTempid[10], message[50]
	
	for(new j = 0; j < n; j++)
	{
		num_to_str(OnlineGuilds[j][1], szTempid, 9);
		formatex(message, charsmax(message), "\w%s \y(%d online)", g_GuildaNome[OnlineGuilds[j][1]], OnlineGuilds[j][2])
		menu_additem(menu, message, szTempid, 0)
	}
	
	menu_setprop(menu, MPROP_EXITNAME, "Sair")
	menu_display(id, menu, 0)	
	
	return PLUGIN_CONTINUE;
}

public ation_menu(id, menu, item)
{
	if( item == MENU_EXIT )
	{
		 menu_destroy(menu)
		 return
	}
	
	static data[6], iName[64]
	new access, callback
	menu_item_getinfo(menu, item, access, data,5, iName, 63, callback)
	new tempid = str_to_num(data)
	
	if(g_JogadorConectado[tempid] && g_GuildaMembro[tempid])
	{
		MostrarMotdMembros(tempid, id)
	}
}

public Abrir_GuildaMenu(id)
{
	if(!registro_user_liberado(id))
	{
		PrintGuild(id, "^1 Voce nao tem autorizacao para fazer isso.")
		return PLUGIN_HANDLED;
	}
	
	if( !g_GuildaMembro[id] )
	{
		CriarMenu(id)
		PrintGuild(id, "^1 Voce nao faz parte de nenhuma guilda!")
		return PLUGIN_HANDLED;
	}
	
	GuildaMenu(id)
	return PLUGIN_CONTINUE;
}

public CriarMenu(id)
{
	static menu[512], len
	len = 0
	
	// Título
	len += formatex(menu[len], charsmax(menu) - len, "\y[ %s ]^n\wGostaria de criar sua Guild por \r500 \wAPs?^n", xPrefix )
	
	// Opções
	len += formatex(menu[len], charsmax(menu) - len, "^n\r1.\w Sim, por favor!^n")
	
	len += formatex(menu[len], charsmax(menu) - len, "\r2.\w Nao, obrigado.^n^n")
	
	len += formatex(menu[len], charsmax(menu) - len, "\r3.\y Vantagens de ter uma Guild^n")
	
	len += formatex(menu[len], charsmax(menu) - len, "^n\r0.\w Sair")
	
	show_menu(id, KEYSMENU, menu, -1, "Criar Menu")
}

public CriarHandle(id, key)
{
	if( g_GuildaMembro[id] ) // Security Check
	{
		return PLUGIN_HANDLED;
	}
	
	switch(key)
	{
		case 0:  // Quer comprar a Guild.
		{
			// Vamo ver se o caboclo tem dinheiro primeiro né...
			new ammopacks = zp_get_user_ammo_packs(id)
			
			if(ammopacks < 500)
			{
				PrintGuild(id, "^1 Voce nao tem 500 packs para criar sua Guild!")
				return PLUGIN_HANDLED;
			}
			
			// OK... let's go!
			/*
			static auth[ 64 ];
			if( is_user_steam( id ))
				get_user_authid( id, auth, charsmax( auth ));
			*/
			
			static auth[ 64 ];
			get_user_key( id, auth, charsmax( auth ));
			
			/*
			if(rid == 0) // (nao é registrado)
			{
				PrintGuild(id, "^1 Voce precisa ser registrado. Digite /registro e faca sua conta!")
				return PLUGIN_HANDLED;
			}
			*/
		
			static namey[64]
			get_user_name(id, namey, charsmax(namey))
			replace_all(namey, charsmax(namey), "'", "\'")
			
			mySQLConnect()
			if ( gDbConnect == Empty_Handle ) return false
	
			static sql[440], guildidz[64]
			new Handle:query
			new errcode
	
			sql[0] = '^0'
			formatex(sql, charsmax(sql), "SELECT `GUILDAS` FROM `play_guilds_dados`")
			query = SQL_PrepareQuery(gDbConnect, "%s", sql)
	
			if ( !SQL_Execute(query) ) {
				errcode = SQL_QueryError(query, error, charsmax(error))
				Log("[GUILDs] Erro ao criar a Guild para o: %s: [%d] '%s' - '%s'", auth, errcode, error, sql)
				SQL_FreeHandle(query)
				PrintGuild(id, "^1 Houve um erro no banco de dados e sua Guild nao foi criada!")
				return PLUGIN_HANDLED
			}
			
			SQL_ReadResult(query, 0, guildidz, charsmax(guildidz))
	
			g_GuildaID[id] = str_to_num(guildidz)
			g_GuildaID[id]++			
			
			SQL_FreeHandle(query)
			
			sql[0] = '^0'	
			formatex(sql, charsmax(sql), "UPDATE `play_guilds_dados` SET `GUILDAS`=`GUILDAS` + '1'")
	
			query = SQL_PrepareQuery(gDbConnect, "%s", sql)
	
			if ( !SQL_Execute(query) ) {
				errcode = SQL_QueryError(query, error, charsmax(error))
				Log("[GUILDs] (2) Erro ao criar a Guild para o: %s: [%d] '%s' - '%s'", auth, errcode, error, sql)
				SQL_FreeHandle(query)
				PrintGuild(id, "^1 Houve um erro no banco de dados e sua Guild nao foi criada!")
				return PLUGIN_HANDLED
			}
	
			SQL_FreeHandle(query)			
			
			sql[0] = '^0'
			formatex( sql, charsmax( sql ), "INSERT INTO `play_guilds` (`ID`, `GUILD_NAME`, `GUILD_TAG`, `KEY_LIDER`, `ZMXP_PONTOS`, `ZMXP_AMMOPACKS`) VALUES ('%i', 'Nova Guild', '[NovaGuild]', '%s', '0', '0')", g_GuildaID[ id ], auth );
			query = SQL_PrepareQuery( gDbConnect, "%s", sql);
			
			if( !SQL_Execute( query )){
				errcode = SQL_QueryError(query, error, charsmax(error))
				Log("[GUILDs] (3) Erro ao criar a Guild para o: %s: [%d] '%s' - '%s'", auth, errcode, error, sql)
				SQL_FreeHandle(query)
				PrintGuild(id, "^1 Houve um erro no banco de dados e sua Guild nao foi criada!")
				return PLUGIN_HANDLED;
			}
			
			else // A query deu certo.
			{
				SQL_FreeHandle(query) // Limpando a query
				
				sql[0] = '^0'
				formatex( sql, charsmax( sql ), "INSERT INTO `play_guilds_membros` (`ID`, `MEMBRO_KEY`, `NICK`, `LIDER`, `PONTOS`) VALUES ('%i', '%s', '%s', '1', '0')", g_GuildaID[id], auth, namey );
				query = SQL_PrepareQuery( gDbConnect, "%s", sql );
		
				if ( !SQL_Execute(query) ) {
					errcode = SQL_QueryError(query, error, charsmax(error))
					Log("[GUILDs] (4) Erro ao criar a Guild para o: %s: [%d] '%s' - '%s'", auth, errcode, error, sql)
					SQL_FreeHandle(query)
					PrintGuild(id, "^1 Houve um erro no banco de dados e sua Guild nao foi criada!")
					return PLUGIN_HANDLED;
				}
				else // A ultima query deu certo
				{
					zp_set_user_ammo_packs(id, ammopacks - 500)
					zmxp_save_user(id)
					
					g_GuildaMembros[id] = 1
					g_GuildaPoints[id] = 0
					g_GuildaRank[id] = 0
					
					g_GuildaMembro[id] = true
					g_GuildaLider[id] = true
					
					copy(g_GuildaNome[id], charsmax(g_GuildaNome[]), "Nova Guild")
					copy(g_GuildaTag[id], charsmax(g_GuildaTag[]), "[NovaGuild]")					
					
					PrintGuild(id, "^1 Sua Guild foi criada com sucesso! Voce ja pode alterar o Nome e a TAG dela!")
					PrintGuild(id, "^3 EH PROIBIDO COLOCAR NOME / TAG OFENSIVA OU COM PUBLICIDADE!")
					
					replace_all(namey, charsmax(namey), "\'", "'")
					PrintGuild(0, "^1 Jogador %s criou uma nova Guild!", namey)
					
					Abrir_GuildaMenu(id)
				}
			}
			
			return PLUGIN_HANDLED;
		}
		case 1: // Não quer comprar..
		{
			return PLUGIN_HANDLED;
		}
		case 2: // MOTD sobre as Guilds.
		{
			show_motd(id, "vantagemguild.html")
		}		
	}
	
	return PLUGIN_HANDLED;
}

public GuildaMenu(id)
{		
	static sql[320]
	new data[1]
	
	data[0] = id
	
	sql[0] = '^0'
	formatex(sql, charsmax(sql), "SELECT `NICK` FROM `play_guilds_membros` WHERE `ID` = '%i' ORDER BY `LIDER` DESC", g_GuildaID[id])
	SQL_ThreadQuery(gDbTuple, "GuildQueryMenu", sql, data, 2)
	return PLUGIN_HANDLED
}

public GuildQueryMenu(failstate, Handle:query, error[], errnum, data[], datalen, Float:queuetime)
{
	if(failstate){
		Log("(GuildQueryMenu) Error Querying MySQL - %d: %s", errnum, error)
		return PLUGIN_HANDLED
	}
	
	new id = data[0]
	static menu[1024], len
	len = 0
	new total_guild = 0
	new conectado = 0	
	
	// Título
	len += formatex(menu[len], charsmax(menu) - len, "\r[ %s ] \w- Level: \r%i\w/10^n\yMembros:^n^n", g_GuildaNome[id], PegarLevelGuild(g_GuildaPoints[id]))
	
	if ( SQL_NumResults(query) ) {
		static membroGuild[32], namet[26]
		
		while ( SQL_MoreResults(query) ) {
			membroGuild[0] = '^0'
			SQL_ReadResult(query, 0, membroGuild, charsmax(membroGuild))
			total_guild++
			conectado = 0
			
			for(new x = 1; x <= gServerMaxPlayers; x++) 
			{
				if(g_JogadorConectado[x] && g_GuildaMembro[x] && g_GuildaID[x] == g_GuildaID[id])
				{	
					namet[0] = '^0'
					get_user_name(x, namet, 25)
					
					if(equal(namet,membroGuild))
					{
						conectado = 1
						break
					}
				}
			}
			
			if(total_guild == 1) // Lider da guild
			{
				len += formatex(menu[len], charsmax(menu) - len, "\%s %s \y[Master] %s^n", conectado ? "w": "d", membroGuild, conectado ? "\y(ONLINE)":"\r(OFFLINE)")
			}
			else len += formatex(menu[len], charsmax(menu) - len, "\%s %s %s^n", conectado ? "w": "d", membroGuild, conectado ? "\y(ONLINE)":"\r(OFFLINE)")
			
			SQL_NextRow(query)
		}
	}
	
	g_GuildaMembros[id] = total_guild // pegar numero de integrantes da guilda para o Handle
	len += formatex(menu[len], charsmax(menu) - len, "^n\r1.\w Menu da Guild^n^n")
	
	if(g_GuildaLider[id])
		len += formatex(menu[len], charsmax(menu) - len, "\r2.\y Administrar Guild^n")
	
	len += formatex(menu[len], charsmax(menu) - len, "^n\r0.\w Sair")
	show_menu(id, KEYSMENU, menu, -1, "Guilda Menu")
	return PLUGIN_HANDLED	
}

public GuildaHandle(id, key)
{
	if( !g_GuildaMembro[id] ) // Security Check
	{
		return PLUGIN_HANDLED;
	}
	
	switch(key)
	{
		case 0:  // Menu de Opções...
		{
			OpcoesMenu(id)
		}
		case 1:
		{
			if(g_GuildaLider[id])  // Administração da Guild
			{
				AdminMenu(id)
			}
			else PrintGuild(id, "^1 Voce nao eh o master da %s !", g_GuildaNome[id])
		}
	}
	
	return PLUGIN_HANDLED;
}

public OpcoesMenu(id)
{	
	static menu[512], len
	len = 0
	
	// Título
	len += formatex(menu[len], charsmax(menu) - len, "\r[ %s ] \w- Level: \r%i\w/10^n\yMenu da Guilda:^n", g_GuildaNome[id], PegarLevelGuild(g_GuildaPoints[id]))
	
	// Opções
	len += formatex(menu[len], charsmax(menu) - len, "^n\r1.\w Rank da Guild^n")
	
	len += formatex(menu[len], charsmax(menu) - len, "\r2.\w Banco da Guild^n")
	
	len += formatex(menu[len], charsmax(menu) - len, "\r3.\w Stats dos Membros^n")
	
	len += formatex(menu[len], charsmax(menu) - len, "\r4.\w Comandos Especiais & Ajuda^n^n")
	
	len += formatex(menu[len], charsmax(menu) - len, "\r5.\r Sair da Guild^n")
	
	if(g_GuildaLider[id])
	{
		len += formatex(menu[len], charsmax(menu) - len, "^n\r7.\y Administrar Guild^n")
	}
	
	len += formatex(menu[len], charsmax(menu) - len, "^n\r0.\w Sair")
	
	show_menu(id, KEYSMENU, menu, -1, "Opcoes Menu")
}

public OpcoesHandle(id, key)
{
	if( !g_GuildaMembro[id] ) // Security Check
	{
		return PLUGIN_HANDLED;
	}
	
	switch (key)
	{
		case 0: // Rank da Guild
		{
			mySQLConnect()
			if ( gDbConnect == Empty_Handle ) return false		
		
			static sql[180], Points[64]
			new Handle:query
			new errcode

			sql[0] = '^0'
			formatex(sql, charsmax(sql), "SELECT `PONTOS` FROM `play_guilds_membros` WHERE `ID` = '%i'", g_GuildaID[id])
			query = SQL_PrepareQuery(gDbConnect, "%s", sql)
		
			if ( !SQL_Execute(query) ) {
				errcode = SQL_QueryError(query, error, charsmax(error))
				Log("Erro ao criar query do rank para Guilda ID: %i [%d] '%s' - '%s'", g_GuildaID[id], errcode, error, sql)
				SQL_FreeHandle(query)
				return PLUGIN_HANDLED;
			}
			
			g_GuildaPoints[id] = 0

			if ( SQL_NumResults(query) ) {
				while ( SQL_MoreResults(query) ) {
					Points[0] = '^0'
					SQL_ReadResult(query, 0, Points, charsmax(Points))
				
					g_GuildaPoints[id] += str_to_num(Points)

					SQL_NextRow(query)
				}
			}
		
			SQL_FreeHandle(query)
		
			// Atualizar no banco de dados...
		
			sql[0] = '^0'
			formatex(sql, charsmax(sql), "UPDATE `play_guilds` SET `ZMXP_PONTOS`='%i' WHERE `ID`='%i'", g_GuildaPoints[id], g_GuildaID[id])
			query = SQL_PrepareQuery(gDbConnect, "%s", sql)
		
			if ( !SQL_Execute(query) ) {
				errcode = SQL_QueryError(query, error, charsmax(error))
				Log("Erro ao atualizar pontos da Guilda ID: %i [%d] '%s' - '%s'", g_GuildaID[id], errcode, error, sql)
				SQL_FreeHandle(query)
				return PLUGIN_HANDLED;
			}
		
			SQL_FreeHandle(query)
		
			// Mostrar o rank atual da guilda. OMG... 3 QUERY IN A ROLL!
		
			sql[0] = '^0'
			formatex(sql, charsmax(sql), "SELECT `ID`, `ZMXP_PONTOS` FROM `play_guilds` ORDER BY `ZMXP_PONTOS` DESC", g_GuildaPoints[id], g_GuildaID[id])
			query = SQL_PrepareQuery(gDbConnect, "%s", sql)
			new rank, dbkey[32]
		
			if ( !SQL_Execute(query) ) {
				errcode = SQL_QueryError(query, error, charsmax(error))
				Log("Erro ao criar o rank da Guilda ID: %i [%d] '%s' - '%s'", g_GuildaID[id], errcode, error, sql)
				SQL_FreeHandle(query)
				return PLUGIN_HANDLED;
			}
		
			totalrank = SQL_NumResults(query)

			while(SQL_MoreResults(query))
			{
				rank++

				SQL_ReadResult(query, 0, dbkey, 31)
			
				if(g_GuildaID[id] == str_to_num(dbkey)) break;

				SQL_NextRow(query)
			}
		
			g_GuildaRank[id] = rank
			
			for (new x = 1; x <= gServerMaxPlayers; x++) 
			{
				if(g_JogadorConectado[x] && g_GuildaMembro[x] && g_GuildaID[x] == g_GuildaID[id])
				{
					//  Atualizar pra todos...
					g_GuildaRank[x] = g_GuildaRank[id]
				}
			}			
		
			PrintGuild(id, "^3 %s^1 esta na no rank^3 #%i^1 de^3 %i^1 guilds com^4 %i^1 pontos!", g_GuildaNome[id], g_GuildaRank[id], totalrank, g_GuildaPoints[id])
		
			SQL_FreeHandle(query)
			close_mysql()
		}		
		case 1: // Banco da Guild
		{
			BancoMenu(id)
		}
		case 2: // Stats dos Membros
		{
			MostrarMotdMembros(id, id)
		}
		case 3: // Comandos Especiais & Ajuda
		{
			show_motd(id, "ajudaguild.html")
		}		
		case 4: // Sair da Guild
		{
			show_motd(id, "sairguild.html")
		}
		case 6: // Administrar Guild
		{
			if(g_GuildaLider[id])
			{
				AdminMenu(id)
			}
			else PrintGuild(id, "^1 Voce nao eh o master da %s !", g_GuildaNome[id])
		}		
	}
	
	return PLUGIN_HANDLED;
}

public BancoMenu(id)
{	
	/////////////////////////////////////////////////////////////////////////////////////////////////////
	
	mySQLConnect()

	if ( gDbConnect == Empty_Handle ) return PLUGIN_HANDLED;
	
	static sql[212], thebankquery[63]
	new Handle:query
	new errcode
	new GuildaBank
	
	sql[0] = '^0'
	formatex(sql, charsmax(sql), "SELECT `ZMXP_AMMOPACKS` FROM `play_guilds` WHERE `ID` = '%i'", g_GuildaID[id])
	query = SQL_PrepareQuery(gDbConnect, "%s", sql)
	
	if ( !SQL_Execute(query) ) {
		errcode = SQL_QueryError(query, error, charsmax(error))
		Log("Erro ao criar query de saque para Guilda: %i [%d] '%s' - '%s'", g_GuildaID[id], errcode, error, sql)
		SQL_FreeHandle(query)
		return PLUGIN_HANDLED;
	}	
	
	SQL_ReadResult(query, 0, thebankquery, charsmax(thebankquery))
	GuildaBank = str_to_num(thebankquery)
	
	SQL_FreeHandle(query)
	close_mysql()
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////
	
	static menu[512], len
	len = 0
	
	// Título
	len += formatex(menu[len], charsmax(menu) - len, "\r[ %s ] \w- Level: \r%i\w/10^n\yBanco da Guild - \dSaldo:\r %i \dAPs^n", g_GuildaNome[id], PegarLevelGuild(g_GuildaPoints[id]), GuildaBank)
	
	// Opções
	len += formatex(menu[len], charsmax(menu) - len, "^n\r1.\y +10 \wSaque^n")
	
	len += formatex(menu[len], charsmax(menu) - len, "\r2.\y -10 \wSaque^n^n")
	
	len += formatex(menu[len], charsmax(menu) - len, "\r3.\w Solicitar saque de \r[%i] \wdo Banco^n^n",  g_GuildaBankSaque[id])
	
	len += formatex(menu[len], charsmax(menu) - len, "^n\r0.\w Sair")
	
	show_menu(id, KEYSMENU, menu, -1, "Banco Menu")
	
	return PLUGIN_HANDLED; // Verificar depois
}

public BancoHandle(id, key)
{
	if( !g_GuildaMembro[id] ) // Security Check
	{
		return PLUGIN_HANDLED;
	}	
	
	switch (key)
	{
		case 0: // ++ Saque
		{
			g_GuildaBankSaque[id] += 10
			
			if( g_GuildaBankSaque[id] > 150 )
			{
				g_GuildaBankSaque[id] = 150
				PrintGuild(id, "^1 O limite de^3 150^1 para o saque foi atingido!")
			}
			
			BancoMenu(id)
			
		}
		case 1: // -- Saque
		{
			g_GuildaBankSaque[id] -= 10
			
			if( g_GuildaBankSaque[id] < 0 )
			{
				g_GuildaBankSaque[id] = 0
			}
			
			BancoMenu(id)
		}
		case 2: // Solicitar Saque...
		{
			if( g_GuildaBankSaque[id] == 0 )
			{
				PrintGuild(id, "^1 Voce nao pode sacar 0 ammo packs do banco!")
				return PLUGIN_HANDLED;
			}
			
			if( g_GuildaLider[id] )
			{
				SolicitarSaqueGuild(id, g_GuildaBankSaque[id], 1)
				// Solicita o saque... id... quantidade de ap... 1 = lider 0 = membro
			}
			else SolicitarSaqueGuild(id, g_GuildaBankSaque[id], 0)
		}
	}
	
	return PLUGIN_HANDLED;
}

public AdminMenu(id)
{	
	static menu[512], len
	len = 0
	
	// Título
	len += formatex(menu[len], charsmax(menu) - len, "\r[ %s ] \w- Level: \r%i\w/10^n\yMenu do Master:^n", g_GuildaNome[id], PegarLevelGuild(g_GuildaPoints[id]))
	
	// Opções
	if(g_GuildaMembros[id] >= GUILD_LIMIT) // Limite de 10 membros na guild
	{
		len += formatex(menu[len], charsmax(menu) - len, "^n\d1.\w Convidar novo jogador^n")
	}
	else len += formatex(menu[len], charsmax(menu) - len, "^n\r1.\w Convidar novo jogador^n")
	
	len += formatex(menu[len], charsmax(menu) - len, "\r2.\w Expulsar jogador^n")
	
	len += formatex(menu[len], charsmax(menu) - len, "\r3.\w Alterar Nome da Guild^n")
	
	len += formatex(menu[len], charsmax(menu) - len, "\r4.\w Alterar TAG da Guild^n^n")
	
	len += formatex(menu[len], charsmax(menu) - len, "\r5.\y Transferir Lider^n")
	
	len += formatex(menu[len], charsmax(menu) - len, "^n\r0.\w Sair")
	
	show_menu(id, KEYSMENU, menu, -1, "Admin Menu")
}

public AdminHandle(id, key)
{
	if( !g_GuildaMembro[id] ) // Security Check
	{
		return PLUGIN_HANDLED;
	}	
	
	switch (key)
	{
		case 0: // Convidar novo jogador
		{
			if(g_GuildaLider[id])
			{
				mySQLConnect()
				if ( gDbConnect == Empty_Handle ) return false
	
				static sql[180]
				new Handle:query
				new errcode
				g_GuildaMembros[id] = 0

				sql[0] = '^0'
				formatex(sql, charsmax(sql), "SELECT `NICK` FROM `play_guilds_membros` WHERE `ID` = '%i' ORDER BY `LIDER` DESC", g_GuildaID[id])
				query = SQL_PrepareQuery(gDbConnect, "%s", sql)
	
				if ( !SQL_Execute(query) ) {
					errcode = SQL_QueryError(query, error, charsmax(error))
					Log("Erro ao contar numero de membros da Guilda: %i [%d] '%s' - '%s'", g_GuildaID[id], errcode, error, sql)
					SQL_FreeHandle(query)
					return PLUGIN_HANDLED;
				}

				if ( SQL_NumResults(query) ) {
					static membroGuild[32]

					while ( SQL_MoreResults(query) ) {
						membroGuild[0] = '^0'
						SQL_ReadResult(query, 0, membroGuild, charsmax(membroGuild))
						g_GuildaMembros[id]++

						SQL_NextRow(query)
					}
				}
				
				SQL_FreeHandle(query)
				close_mysql()
				
				if(g_GuildaMembros[id] >= GUILD_LIMIT)
				{
					PrintGuild(id, "^1 Numero maximo de %i jogadores na guild !", GUILD_LIMIT)
					return PLUGIN_HANDLED;
				}
				// Ainda pode entrar membros.. Vamos lá!
				ShowMenuPlayers(id, true)
				
			}
			else PrintGuild(id, "^1 Voce nao eh o master da %s !", g_GuildaNome[id])
		}
		case 1: // Expulsar jogador
		{
			if(g_GuildaLider[id])
			{
				ExcluirMenu(id)
			}
			else PrintGuild(id, "^1 Voce nao eh o master da %s !", g_GuildaNome[id])
		}
		case 2: // Alterar nome da Guild
		{
			if(g_GuildaLider[id])
			{
				show_motd(id, "nomeguild.html")
			}
			else PrintGuild(id, "^1 Voce nao eh o master da %s !", g_GuildaNome[id])
		}
		case 3: // Alterar TAG da Guild
		{
			if(g_GuildaLider[id])
			{
				show_motd(id, "tagguild.html")
			}
			else PrintGuild(id, "^1 Voce nao eh o master da %s !", g_GuildaNome[id])
		}
		case 4: // Transferir Lider de Guild
		{
			if(g_GuildaLider[id])
			{
				LiderTransferMenu(id)
			}
			else PrintGuild(id, "^1 Voce nao eh o master da %s !", g_GuildaNome[id])
		}		
	}
	
	return PLUGIN_HANDLED;
}

ShowMenuPlayers(id, bool:convidar)
{
	static title[128];
	formatex(title, sizeof(title) - 1, "\r[ %s ]  \wConvidar jogador para Guild^n", g_GuildaNome[id])
	new menu_ = menu_create(title, "handle_player")
	new name[33], k[4]
	
	for(new i = 1 ; i <= gServerMaxPlayers ; i++)
	{
		if(!g_JogadorConectado[i] || id == i || g_GuildaMembro[i] || !registro_user_liberado(i) || is_user_bot( i ))
			continue
		
		get_user_name(i, name, 32)
		num_to_str(i, k, 3)
		menu_additem(menu_, name, k)
	}
	
	menu_setprop(menu_, MPROP_EXITNAME, "\rSair")
	g_iTentandoConvidar[id] = _:convidar
	menu_display(id, menu_)
}

public handle_player(id, menu, item)
{
	if (item == MENU_EXIT)
	{
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}
	
	new data[6], iName[64]
	new access, callback
	menu_item_getinfo(menu, item, access, data,5, iName, 63, callback)
	
	new tempid = str_to_num(data)
	
	if(!registro_user_liberado(tempid) || is_user_bot( tempid ))
	{
		PrintGuild(id, "^1 Ops, ocorreu um erro!")
		return PLUGIN_HANDLED;
	}	
	
	if(!g_JogadorConectado[tempid] || g_GuildaMembro[tempid] == bool:g_iTentandoConvidar[id]) // entendi agora... verifica se quem esta sendo convidado ja tem guild ou nao
	{
		ShowMenuPlayers(id, bool:g_iTentandoConvidar[id])
		return PLUGIN_HANDLED;
	}
	
	new szBuffer[32]
	get_user_name(id, szBuffer,31)
	
	new szTempidName[32]
	get_user_name(tempid, szTempidName, 31)
	
	if(g_iTentandoConvidar[id])
	{
		g_iTentandoConvidar[id] = tempid
		EnviarConviteGuild(id, g_iTentandoConvidar[id])
		
		PrintGuild(g_iTentandoConvidar[id],"^3 %s^1 convidou voce para entrar na Guild^3 %s^1 !", szBuffer, g_GuildaNome[id])
		PrintGuild(id,"^1 Voce convidou o jogador^3 %s^1 para entrar na %s", szTempidName, g_GuildaNome[id])
	}
	
	return PLUGIN_HANDLED;
}
	
EnviarConviteGuild(inviter, target)
{
	static szMenu[128],iLen
	static szBuffer[32]
	get_user_name(inviter, szBuffer, charsmax(szBuffer))
	
	iLen = formatex(szMenu,charsmax(szMenu), "\y[ CONVITE DE GUILD ]^n\wAceita entrar na Guild \y%s \wde %s\w?^n^n",g_GuildaNome[inviter], szBuffer)
	
	iLen += formatex(szMenu[iLen],charsmax(szMenu) - iLen, "\r1. \wAceito^n")
	iLen += formatex(szMenu[iLen],charsmax(szMenu) - iLen, "\r2. \wNao aceito^n")
	
	show_menu(target,KEYSINVITE,szMenu,-1,"Convidar")
	g_iInviter[target] = inviter
}

public ConvidarHandle(id, key)
{
	new inviter = g_iInviter[id]
	static szBuffer[2][32]
	static namez[64]
	
	if( g_GuildaMembros[inviter] >= GUILD_LIMIT ){
		PrintGuild(id, "^1 Ops, ocorreu um erro e voce nao entrou na guild!")
		return PLUGIN_HANDLED
	}
	
	if(!registro_user_liberado(id)){
		PrintGuild(id, "^1 Ops, ocorreu um erro e voce nao entrou na guild!")
		return PLUGIN_HANDLED;
	}	
	
	get_user_name(inviter, szBuffer[0], charsmax(szBuffer[]))
	get_user_name(id, szBuffer[1], charsmax(szBuffer[]))
	get_user_name(id, namez, 63)
	
	/*
	static auth[ 64 ];
	if( is_user_steam( id ))
		get_user_authid( id, auth, charsmax( auth ));
	*/

	static auth[ 64 ];
	get_user_key( id, auth, charsmax( auth ));
	
	switch(key+1)
	{
		case 1: // Aceitou o convite
		{
			if(g_GuildaLider[inviter]) // Ultima verificação pra ver se é o líder.
			{
				if(g_GuildaMembros[inviter] < GUILD_LIMIT)
				{
					mySQLConnect()
	
					if( gDbConnect == Empty_Handle )
						return PLUGIN_HANDLED;
	
					static error[128], sql[542]
					new Handle:query
					new errcode
					
					replace_all(namez, charsmax(namez), "'", "\'")
					
					sql[0] = '^0'
					formatex( sql, charsmax( sql ), "INSERT INTO `play_guilds_membros` (`ID`, `MEMBRO_KEY`, `NICK`, `LIDER`, `PONTOS`) VALUES ('%i', '%s', '%s', '0', '0')", g_GuildaID[inviter], auth, namez );
					query = SQL_PrepareQuery(gDbConnect, "%s", sql)
		
					if ( !SQL_Execute(query) ) {
						errcode = SQL_QueryError(query, error, charsmax(error))
						Log("[GUILDs] Erro ao colocar Membro: %s na Guilda %s [%d] '%s' - '%s'", namez, g_GuildaNome[inviter], errcode, error, sql)
						SQL_FreeHandle(query)
						return PLUGIN_HANDLED
					}
					else // A query deu certo
					{						
						g_GuildaMembros[inviter]++
						
						g_GuildaID[id] = g_GuildaID[inviter]
						g_GuildaMembros[id] = g_GuildaMembros[inviter]
						g_GuildaPoints[id] = g_GuildaPoints[inviter]
						g_GuildaRank[id] = g_GuildaRank[inviter]
			
						copy(g_GuildaNome[id], charsmax(g_GuildaNome[]), g_GuildaNome[inviter])
						copy(g_GuildaTag[id], charsmax(g_GuildaTag[]), g_GuildaTag[inviter])
						
						g_GuildaMembro[id] = true
						g_GuildaLider[id] = false
						
						PrintGuild(0, "^3 %s^1 entrou na Guild^4 %s^1 de^3 %s!", szBuffer[1], g_GuildaNome[inviter], szBuffer[0])
						PrintGuild(id, "^1 Bem-vindo^3 %s^1 na nossa guild,^3 %s^1 =)", szBuffer[1], g_GuildaNome[inviter])
						PrintGuild(id, "^1 Para falar no chat apenas para Guild comece a escrita com #")
						PrintGuild(id, "^1 Para falar no microfone apenas para Guild use a bind letra +guildvoice")
					}
	
					SQL_FreeHandle(query)
					close_mysql()
				}
			}
		}
		case 2: // Recusou o convite
		{
			static szBuffer[32];
			get_user_name(id, szBuffer, charsmax(szBuffer));
			PrintGuild(inviter,"^3 %s^1 nao aceitou seu convite de Guild.",szBuffer);
			g_GuildaMembro[id] = false
			g_iInviter[id] = 0  // talvez bugfix
		}
		
	}
	return PLUGIN_HANDLED
}

public ExcluirMenu(id)
{
	if( !g_GuildaLider[id] ) // Security Check
	{
		return PLUGIN_HANDLED;
	}
	
	if(!registro_user_liberado(id)) // Security Check
	{
		return PLUGIN_HANDLED;
	}	
	
	static menu[1024], len
	len = 0
	
	// Título
	len += formatex(menu[len], charsmax(menu) - len, "\r[ %s ] \w- Remover jogador da Guild^n\dATENCAO: O JOGADOR TERA TODOS OS PONTOS DE CONTRIBUICAO REMOVIDOS!^n^n", g_GuildaNome[id])
	
	mySQLConnect()
	if ( gDbConnect == Empty_Handle ) return false
	
	gPersistentTemp = true
	
	static sql[320]
	new Handle:query
	new errcode
	new total_guild = 0
	new eh_lider = 0

	sql[0] = '^0'
	formatex(sql, charsmax(sql), "SELECT `NICK`, `MEMBRO_KEY`, `LIDER` FROM `play_guilds_membros` WHERE `ID` = '%i'", g_GuildaID[id])
	query = SQL_PrepareQuery(gDbConnect, "%s", sql)
	
	if ( !SQL_Execute(query) ) {
		errcode = SQL_QueryError(query, error, charsmax(error))
		Log("Erro ao criar query do menu de excluir para Guilda ID: %i [%d] '%s' - '%s'", g_GuildaID[id], errcode, error, sql)
		SQL_FreeHandle(query)
		return PLUGIN_HANDLED;
	}

	if ( SQL_NumResults(query) ) {
		static membroGuild[64], membrokey[64], lider[32]

		while ( SQL_MoreResults(query) ) {
			membroGuild[0] = '^0'
			membrokey[0] = '^0'
			lider[0] = '^0'
			SQL_ReadResult(query, SQL_FieldNameToNum(query, "NICK"), membroGuild, sizeof(membroGuild) - 1)
			SQL_ReadResult(query, SQL_FieldNameToNum(query, "MEMBRO_KEY"), membrokey, sizeof(membrokey) - 1)
			SQL_ReadResult(query, SQL_FieldNameToNum(query, "LIDER"), lider, sizeof(lider) - 1)
			
			eh_lider = str_to_num(lider)
			
			if(eh_lider == 0) // Lider da guild
			{
				total_guild++
				len += formatex(menu[len], charsmax(menu) - len, "\r%i.\w %s (%s)^n", total_guild, membroGuild, membrokey)
			}

			SQL_NextRow(query)
		}
	}
	
	gPersistentTemp = false

	SQL_FreeHandle(query)
	close_mysql()
	
	g_GuildaMembros[id] = total_guild // pegar numero de integrantes da guilda para o Handle
	
	len += formatex(menu[len], charsmax(menu) - len, "^n\r0.\w Sair")
	
	show_menu(id, KEYSMENU, menu, -1, "Excluir Menu")
	return PLUGIN_HANDLED
}

public ExcluirHandle(id, key)
{
	if( !g_GuildaLider[id] ) // Security Check
	{
		return PLUGIN_HANDLED;
	}
	
	if(!registro_user_liberado(id)) // Security Check
	{
		return PLUGIN_HANDLED;
	}
	
	mySQLConnect()
	if ( gDbConnect == Empty_Handle ) return PLUGIN_HANDLED;
	
	gPersistentTemp = true
	
	static sql[320]
	new Handle:query
	new errcode
	new total_guild = 0
	new eh_lider = 0

	sql[0] = '^0'
	formatex(sql, charsmax(sql), "SELECT `NICK`, `MEMBRO_KEY`, `LIDER` FROM `play_guilds_membros` WHERE `ID` = '%i'", g_GuildaID[id])
	query = SQL_PrepareQuery(gDbConnect, "%s", sql)
	
	if ( !SQL_Execute(query) ) {
		errcode = SQL_QueryError(query, error, charsmax(error))
		Log("Erro ao criar query do handler de excluir para Guilda ID: %i [%d] '%s' - '%s'", g_GuildaID[id], errcode, error, sql)
		SQL_FreeHandle(query)
		return PLUGIN_HANDLED;
	}

	if ( SQL_NumResults(query) ) {
		static membroGuild[64], membrokey[64], lider[32]

		while ( SQL_MoreResults(query) ) {
			membroGuild[0] = '^0'
			membrokey[0] = '^0'
			lider[0] = '^0'
			SQL_ReadResult(query, SQL_FieldNameToNum(query, "NICK"), membroGuild, sizeof(membroGuild) - 1)
			SQL_ReadResult(query, SQL_FieldNameToNum(query, "MEMBRO_KEY"), membrokey, sizeof(membrokey) - 1)
			SQL_ReadResult(query, SQL_FieldNameToNum(query, "LIDER"), lider, sizeof(lider) - 1)
			
			eh_lider = str_to_num(lider)
			
			if(eh_lider == 0)
				total_guild++
			
			if(total_guild == (key+1))
			{
				if(eh_lider == 0) // Lider da guild.. nao pode ser kickado
				{
					gPersistentTemp = false
					SQL_FreeHandle(query)
					close_mysql()
					RemoverJogadorGuild(id, membrokey)
					return PLUGIN_HANDLED;
				}
			}

			SQL_NextRow(query)
		}
	}
	
	gPersistentTemp = false

	SQL_FreeHandle(query)
	close_mysql()
	
	return PLUGIN_HANDLED;
}

RemoverJogadorGuild(id, key[64])
{
	if(!g_GuildaLider[id])
	{
		PrintGuild(id, "^1 Voce nao eh o lider dessa guild...")
		return PLUGIN_HANDLED;
	}
	
	if(!registro_user_liberado(id)) // Security Check
	{
		return PLUGIN_HANDLED;
	}
	
	//new rid = 0;
	//rid = str_to_num(key)
	
	PrintGuild(id, "^1 Removendo %s da Guild %s", key, g_GuildaNome[id])
	replace_all(key, charsmax(key), "'", "\'")
	
	mySQLConnect();
	
	if( gDbConnect == Empty_Handle )
		return PLUGIN_HANDLED;
	
	static sql[180]
	new Handle:query
	new errcode

	/*
	if(rid == 0){
		formatex(sql, charsmax(sql), "DELETE FROM `play_guilds_membros` WHERE `MEMBRO_KEY`='%s'", key)
	}
	else formatex(sql, charsmax(sql), "DELETE FROM `play_guilds_membros` WHERE `MEMBRO_KEY`='%i'", rid)
	*/
	
	sql[0] = '^0'
	formatex( sql, charsmax( sql ), "DELETE FROM `play_guilds_membros` WHERE `MEMBRO_KEY`='%s'", key );
	query = SQL_PrepareQuery(gDbConnect, "%s", sql);
	
	if ( !SQL_Execute(query) ) {
		errcode = SQL_QueryError(query, error, charsmax(error))
		Log("Erro ao remover membro (2) %s: da Guild %s [%d] '%s' - '%s'", key, g_GuildaNome[id], errcode, error, sql)
		SQL_FreeHandle(query)
		PrintGuild(id, "^1 Houve um erro no banco de dados... nao foi possivel remover %s da guild", key)
		return PLUGIN_HANDLED;
	}
	
	SQL_FreeHandle(query)
	close_mysql()
	
	// nick bugfix
	replace_all(key, charsmax(key), "\'", "'")	
	
	PrintGuild(id, "^1 Voce removeu com sucesso^4 %s^1 da Guild!", key)
	PrintGuild(id, "^1 Verificando se %s esta online...", key)
		
	/*
	static auth[ 64 ];
	if( is_user_steam( id ))
		get_user_authid( id, auth, charsmax( auth ));
	*/
	
	static auth[ 64 ];
	get_user_key( id, auth, charsmax( auth ));
	
	for(new x = 1; x <= gServerMaxPlayers; x++) 
	{
		if(g_JogadorConectado[x] && g_GuildaMembro[x] && g_GuildaID[x] == g_GuildaID[id])
		{	
			/*
			ridmembro = get_user_rid(x)
			
			if(rid > 0 && rid == ridmembro)
			{
				g_GuildaMembro[x] = false
				g_GuildaID[x] = 0
				g_GuildaLider[x] = false
				g_GuildaMembros[x] = 0
				g_GuildaPoints[x] = 0
				g_GuildaRank[x] = 0
				g_iTentandoConvidar[x] = 0
				g_iInviter[x] = 0
				
				PrintGuild(x, "^1 Voce foi removido da Guild^3 %s", g_GuildaNome[id])
				break;
			}
			*/
			
			auth[0] = '^0'
				
			/*			
			if( is_user_steam( x ))
				get_user_authid( x, auth, charsmax( auth ));
			*/
			
			static auth[ 64 ];
			get_user_key( x, auth, charsmax( auth ));
			
			// Esta conectado!
			if( equal( key, auth )){
				g_GuildaMembro[x] = false;
				g_GuildaID[x] = 0;
				g_GuildaLider[x] = false;
				g_GuildaMembros[x] = 0;
				g_GuildaPoints[x] = 0;
				g_GuildaRank[x] = 0;
				g_iTentandoConvidar[x] = 0;
				g_iInviter[x] = 0;
				
				PrintGuild(x, "^1 Voce foi removido da Guild^3 %s", g_GuildaNome[id]);
				break;
			}
		}
	}	
	
	g_GuildaMembros[id]--
	
	new namer[32]
	get_user_name(id, namer, 31)
	
	PrintGuild(0, "^3 %s^1 removeu o jogador^3 %s^1 da Guild^4 %s", namer, key, g_GuildaNome[id])
	return PLUGIN_HANDLED;
}

public client_putinserver(id)
{
	if (1 < id > gServerMaxPlayers ) return
	
	g_JogadorConectado[id] = true
	g_GuildaMembro[id] = false
	g_GuildaID[id] = 0
	g_GuildaLider[id] = false
 	g_GuildaMembros[id] = 0
 	g_GuildaPoints[id] = 0
 	g_GuildaRank[id] = 0
	g_iTentandoConvidar[id] = 0
	g_iInviter[id] = 0
	g_GuildaBankSaque[id] = 0
	g_BancoSaqueLider[id] = 0
	g_BancoSaqueLiderQuantia[id] = 0
}

public client_disconnect(id)
{
	if (1 < id > gServerMaxPlayers ) return
	
	g_JogadorConectado[id] = false
	g_GuildaMembro[id] = false
	g_GuildaID[id] = 0
	g_GuildaLider[id] = false
 	g_GuildaMembros[id] = 0
 	g_GuildaPoints[id] = 0
 	g_GuildaRank[id] = 0
	g_iTentandoConvidar[id] = 0
	g_iInviter[id] = 0
	g_BancoSaqueLider[id] = 0
	g_BancoSaqueLiderQuantia[id] = 0	
}

public Master_Nome(id, level, cid) // Comando para alterar o nome da guild.
{
	if ( !cmd_access(id, level, cid, 2) ) return PLUGIN_HANDLED

	if ( read_argc() > 2 ) {
		console_print(id, "[GUILDs] Argumentos errado. Escreva o nome da guild ENTRE ASPAS.")
		return PLUGIN_HANDLED
	}
	
	if ( !g_GuildaLider[id] )
	{
		console_print(id, "[GUILDs] Voce nao eh o lider dessa guild.")
		return PLUGIN_HANDLED
	}
	
	if(!registro_user_liberado(id))
	{
		PrintGuild(id, "^1 Voce nao tem autorizacao para fazer isso.")
		return PLUGIN_HANDLED;
	}	
	
	new arg[32]
	read_argv(1, arg, charsmax(arg)) // Novo nome da Guilda
	
	new len = strlen(arg)
	
	if(len > 16)
	{
		console_print(id, "[GUILDs] Limite de 16 caracteres para o nome da guild.")
		return PLUGIN_HANDLED
	}
	
	if(len < 5)
	{
		console_print(id, "[GUILDs] Minimo de 6 caracteres para o nome da guild.")
		return PLUGIN_HANDLED
	}
	
	replace_all(arg, charsmax(arg), "'", "\'") // Evitar bug no query
	replace_all(arg, charsmax(arg), "%", "i") // Evitar bug no query
	
	mySQLConnect()

	if ( gDbConnect == Empty_Handle ) return false
	
	static sql[212]
	new Handle:query
	new errcode
	
	sql[0] = '^0'
	formatex(sql, charsmax(sql), "SELECT `ID` FROM `play_guilds` WHERE `GUILD_NAME` = '%s'", arg)
	query = SQL_PrepareQuery(gDbConnect, "%s", sql)
	
	if ( !SQL_Execute(query) ) {
		errcode = SQL_QueryError(query, error, charsmax(error))
		Log("Erro ao trocar o nome da Guild (2) %s: [%d] '%s' - '%s'", g_GuildaNome[id], errcode, error, sql)
		SQL_FreeHandle(query)
		console_print(id, "[GUILDs] Houve um erro no banco de dados, nao foi possivel fazer a alteracao.")
		return PLUGIN_HANDLED
	}
	
	if ( SQL_NumResults(query) ) {
		// Esse nome de Guild já existe...
		
		console_print(id, "[GUILDs] Esse nome de Guild ja esta em uso.")
		
		SQL_FreeHandle(query)
		close_mysql()
		return PLUGIN_HANDLED
	}	
	
	SQL_FreeHandle(query)
	
	sql[0] = '^0'
	formatex(sql, charsmax(sql), "UPDATE `play_guilds` SET `GUILD_NAME`='%s' WHERE `ID`='%i'", arg, g_GuildaID[id])
	query = SQL_PrepareQuery(gDbConnect, "%s", sql)	
	
	if ( !SQL_Execute(query) ) {
		errcode = SQL_QueryError(query, error, charsmax(error))
		Log("Erro ao trocar o nome da Guild %s: [%d] '%s' - '%s'", g_GuildaNome[id], errcode, error, sql)
		SQL_FreeHandle(query)
		console_print(id, "[GUILDs] Houve um erro no banco de dados, nao foi possivel fazer a alteracao.")
		return PLUGIN_HANDLED
	}
	
	SQL_FreeHandle(query)
	close_mysql()
	
	replace_all(arg, charsmax(arg), "\'", "'") // Consertando o nome denovo...
	
	new GuildID = g_GuildaID[id]
	
	for (new x = 1; x <= gServerMaxPlayers; x++) 
	{
		if(g_JogadorConectado[x] && g_GuildaMembro[x] && g_GuildaID[x] == GuildID)
		{	
			copy(g_GuildaNome[x], charsmax(g_GuildaNome[]), arg)
		}
	}
	
	console_print(id, "[GUILDs] Alterou com sucesso o nome da guild para %s !", arg)
	
	return PLUGIN_HANDLED
}

public Master_Tag(id, level, cid) // Comando para alterar a tag da guild.
{
	if ( !cmd_access(id, level, cid, 2) ) return PLUGIN_HANDLED

	if ( read_argc() > 2 ) {
		console_print(id, "[GUILDs] Argumentos errado. Escreva a TAG entre aspas.")
		return PLUGIN_HANDLED
	}
	
	if ( !g_GuildaLider[id] )
	{
		console_print(id, "[GUILDs] Voce nao eh o lider dessa guild.")
		return PLUGIN_HANDLED
	}
	
	if(!registro_user_liberado(id))
	{
		PrintGuild(id, "^1 Voce nao tem autorizacao para fazer isso.")
		return PLUGIN_HANDLED;
	}	
	
	new arg[32]
	read_argv(1, arg, charsmax(arg)) // Nova tag da Guilda
	
	new len = strlen(arg)
	
	if(len > 15)
	{
		console_print(id, "[GUILDs] Limite de 15 caracteres para a tag da guild.")
		return PLUGIN_HANDLED
	}
	
	if(len < 3)
	{
		console_print(id, "[GUILDs] Minimo de 4 caracteres para a tag da guild.")
		return PLUGIN_HANDLED
	}
	
	replace_all(arg, charsmax(arg), "'", "\'") // Evitar bug no query
	replace_all(arg, charsmax(arg), "%", "i") // Evitar bug no query
	
	mySQLConnect()

	if ( gDbConnect == Empty_Handle ) return false
	
	static sql[212]
	new Handle:query
	new errcode
	
	sql[0] = '^0'
	formatex(sql, charsmax(sql), "SELECT `ID` FROM `play_guilds` WHERE `GUILD_TAG` = '%s'", arg)
	query = SQL_PrepareQuery(gDbConnect, "%s", sql)
	
	if ( !SQL_Execute(query) ) {
		errcode = SQL_QueryError(query, error, charsmax(error))
		Log("Erro ao trocar a tag da Guild (2) %s: [%d] '%s' - '%s'", g_GuildaNome[id], errcode, error, sql)
		SQL_FreeHandle(query)
		console_print(id, "[GUILDs] Houve um erro no banco de dados, nao foi possivel fazer a alteracao.")
		return PLUGIN_HANDLED
	}
	
	if ( SQL_NumResults(query) ) {
		// Essa tag de Guild já existe...
		
		console_print(id, "[GUILDs] Essa tag de Guild ja esta em uso.")
		
		SQL_FreeHandle(query)
		close_mysql()
		return PLUGIN_HANDLED
	}	
	
	SQL_FreeHandle(query)	
	
	sql[0] = '^0'
	formatex(sql, charsmax(sql), "UPDATE `play_guilds` SET `GUILD_TAG`='%s' WHERE `ID`='%i'", arg, g_GuildaID[id])
	query = SQL_PrepareQuery(gDbConnect, "%s", sql)	
	
	if ( !SQL_Execute(query) ) {
		errcode = SQL_QueryError(query, error, charsmax(error))
		Log("Erro ao trocar a Tag da Guild %s: [%d] '%s' - '%s'", g_GuildaNome[id], errcode, error, sql)
		SQL_FreeHandle(query)
		console_print(id, "[GUILDs] Houve um erro no banco de dados, nao foi possivel fazer a alteracao.")
		return PLUGIN_HANDLED
	}
	
	SQL_FreeHandle(query)
	close_mysql()
	
	replace_all(arg, charsmax(arg), "\'", "'") // Consertando o nome denovo...	
	
	new GuildID = g_GuildaID[id]
	
	for (new x = 1; x <= gServerMaxPlayers; x++) 
	{
		if(g_JogadorConectado[x] && g_GuildaMembro[x] && g_GuildaID[x] == GuildID)
		{	
			copy(g_GuildaTag[x], charsmax(g_GuildaTag[]), arg)
		}
	}
	
	console_print(id, "[GUILDs] Alterou com sucesso a tag da guild para %s !", arg)
	
	return PLUGIN_HANDLED
}

/*public AdicionarGuild(id, level, cid) // Comando para fazer guilds. Apenas para Admins de alta patente.
{
	if ( !cmd_access(id, level, cid, 2) ) return PLUGIN_HANDLED

	if ( read_argc() > 6 ) {
		console_print(id, "[GUILDs] Argumentos errado. Use aspas. [Nome da Guild / TAG da Guild / SAVEKEY do Lider / Nick do Lider / ID]")
		return PLUGIN_HANDLED
	}

	new arg[32], arg2[32], arg3[64], arg4[10], arg5[64]
	read_argv(1, arg, charsmax(arg)) // Nome da Guilda
	read_argv(2, arg2, charsmax(arg2)) // TAG da Guilda
	read_argv(3, arg3, charsmax(arg3)) // SAVEKEY do Lider
	read_argv(4, arg5, charsmax(arg5)) // Nick do Lider
	read_argv(5, arg4, charsmax(arg4)) // Guilda ID... muito importante para as operações futuras
	
	new GUILDid = str_to_num(arg4) // Pegando a Guilda ID
	
	replace_all(arg, charsmax(arg), "'", "\'") // Evitar bug no query
	replace_all(arg2, charsmax(arg2), "'", "\'") // Evitar bug no query
	replace_all(arg3, charsmax(arg3), "'", "\'") // Evitar bug no query
	replace_all(arg5, charsmax(arg5), "'", "\'") // Evitar bug no query
	
	///////////////////////////////////////////////////////////////////////////////
	mySQLConnect()
	
	if ( gDbConnect == Empty_Handle ) return false
	
	static error[128], sql[542]
	new Handle:query
	new errcode
	
	gPersistentTemp = false
	//////////////////////////////////////////////////////////////////////////////
	sql[0] = '^0'
	formatex(sql, charsmax(sql), "INSERT INTO `play_guilds` (`ID`, `GuildName`, `GuildTag`, `Lider`, `Points`, `Bank`) VALUES ('%i', '%s', '%s', '%s', '0', '0')", GUILDid, arg, arg2, arg3)
	query = SQL_PrepareQuery(gDbConnect, "%s", sql)
	if ( !SQL_Execute(query) ) {
		errcode = SQL_QueryError(query, error, charsmax(error))
		Log("[GUILDs] Erro ao criar a Guild: %s: [%d] '%s' - '%s'", arg, errcode, error, sql)
		SQL_FreeHandle(query)
		//return
	}
	else // A query deu certo.
	{
		SQL_FreeHandle(query) // Limpando a query
		sql[0] = '^0'
		
		console_print(id, "[GUILDs] A Guild %s foi criada. Adicionando o Lider agora...", arg)
		
		formatex(sql, charsmax(sql), "INSERT INTO `play_guilds_membros` (`ID`, `MembroKey`, `Nick`, `Lider`, `MemberPoints`) VALUES ('%i', '%s', '%s', '1', '0')", GUILDid, arg3, arg5)
		query = SQL_PrepareQuery(gDbConnect, "%s", sql)
		
		if ( !SQL_Execute(query) ) {
			errcode = SQL_QueryError(query, error, charsmax(error))
			Log("[GUILDs] Erro ao colocar Lider: %s na Guild %s [%d] '%s' - '%s'", arg3, arg, errcode, error, sql)
			SQL_FreeHandle(query)
			//return
		}
		else // A ultima query deu certo
		{
			console_print(id, "[GUILDs] Sucesso! Lider %s colocado na Guild %s (%i)!", arg3, arg, GUILDid)
		}
	}
	
	SQL_FreeHandle(query)
	close_mysql()

	return PLUGIN_HANDLED
}*/

SolicitarSaqueGuild(id, saque, lider)
{
	if(lider == 0) // Vamos verificar se o líder está online
	{
		new LiderOnline = 666
		
		for (new x = 1; x <= gServerMaxPlayers; x++) 
		{
			if(g_JogadorConectado[x] && g_GuildaMembro[x] && g_GuildaID[x] == g_GuildaID[id] && g_GuildaLider[x])
			{	
				LiderOnline = x // Sim, está online
				break;
			}
		}
		
		if( LiderOnline == 666 ) // Não esta online
		{
			PrintGuild(id,"^1 O master da sua Guild nao esta online!")
			return PLUGIN_HANDLED;
		}
		
		if(!registro_user_liberado(LiderOnline))
		{
			PrintGuild(LiderOnline, "^1 Voce nao tem autorizacao para fazer isso.")
			return PLUGIN_HANDLED;
		}		
		
		// Enviar pedido para o Líder...
		new szMenu[128],iLen
		new szBuffer[32]
		get_user_name(id, szBuffer, charsmax(szBuffer))
	
		iLen = formatex(szMenu,charsmax(szMenu), "\y[ PEDIDO DE SAQUE ]^n\r%s \wquer sacar \r%i \wAPs do Banco da Guild!^n^n", szBuffer, saque)
	
		iLen += formatex(szMenu[iLen],charsmax(szMenu) - iLen, "\r1. \wPermitir^n")
		iLen += formatex(szMenu[iLen],charsmax(szMenu) - iLen, "\r2. \wNao permitir^n")
	
		show_menu(LiderOnline, KEYSINVITE, szMenu, -1, "Saque")
	
		g_BancoSaqueLider[LiderOnline] = id
		g_BancoSaqueLiderQuantia[LiderOnline] = saque
		
		return PLUGIN_HANDLED;
		
	}
	else // É o lider então não precisa de verificação nenhuma, go!
	{
		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// PEGAR O NÚMERO DE PACKS DO BANCO NOVAMENTE
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		mySQLConnect()

		if ( gDbConnect == Empty_Handle ) return PLUGIN_HANDLED;
	
		static sql[212], error[128], thebankquery[63]
		new Handle:query
		new errcode
		new bank
	
		sql[0] = '^0'
		formatex(sql, charsmax(sql), "SELECT `ZMXP_AMMOPACKS` FROM `play_guilds` WHERE `ID` = '%i'", g_GuildaID[id])
		query = SQL_PrepareQuery(gDbConnect, "%s", sql)
	
		if ( !SQL_Execute(query) ) {
			errcode = SQL_QueryError(query, error, charsmax(error))
			Log("Erro ao criar query do Banco Menu 2 para Guilda: %i [%d] '%s' - '%s'", g_GuildaID[id], errcode, error, sql)
			SQL_FreeHandle(query)
			return PLUGIN_HANDLED;
		}	
	
		SQL_ReadResult(query, 0, thebankquery, charsmax(thebankquery))
		bank = str_to_num(thebankquery)
	
		SQL_FreeHandle(query)
		
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		// Checks de segurança...
		if(saque <= 0)
		{
			PrintGuild(id,"^1 Houve um erro ao fazer o saque!")
			close_mysql()
			return PLUGIN_HANDLED;
		}
		
		if(saque > bank)
		{
			PrintGuild(id,"^1 O banco tem apenas %i APs, nao da pra sacar %i!", bank, saque)
			close_mysql()
			return PLUGIN_HANDLED;
		}
		
		// OK... o saque nao é negativo nem maior que a quantidade do banco.
		
		new quantia = (bank -= saque)
		
		sql[0] = '^0'
		formatex(sql, charsmax(sql), "UPDATE `play_guilds` SET `ZMXP_AMMOPACKS`='%i' WHERE `ID`='%i'", quantia, g_GuildaID[id])
		query = SQL_PrepareQuery(gDbConnect, "%s", sql)
	
		if ( !SQL_Execute(query) ) {
			errcode = SQL_QueryError(query, error, charsmax(error))
			Log("Erro no saque de %i para a Guilda: %i [%d] '%s' - '%s'", saque, g_GuildaID[id], errcode, error, sql)
			PrintGuild(id,"^1 Houve um erro no banco de dados... Desculpe.")
			SQL_FreeHandle(query)
			return PLUGIN_HANDLED;
		}
		
		SQL_FreeHandle(query)
		close_mysql()
		
		new ammopackz = zp_get_user_ammo_packs(id)
		zp_set_user_ammo_packs(id, ammopackz + saque)
		
		PrintGuild(id,"^1 Voce recebeu^3 %i^1 APs do Banco da Guild com sucesso!", saque)
		
		new namex[32]
		get_user_name(id, namex, 31)
		
		PrintGuild(0,"^1 Master^3 %s^1 retirou^3 %i^1 APs do Banco da Guild^3 %s", namex, saque, g_GuildaNome[id])
		
		Log("Master %s retirou %i APs do Banco da Guild %s", namex, saque, g_GuildaNome[id])
	}
	
	return PLUGIN_HANDLED;
}

public SaqueHandle(id, key)
{	
	new pedinte = g_BancoSaqueLider[id]
	new saque = g_BancoSaqueLiderQuantia[id]
	new NomeLider[32], NomePedinte[32]
	
	if(saque <= 0)
	{
		PrintGuild(id,"^1 Houve um erro ao fazer o saque!")
		return PLUGIN_HANDLED;
	}	
	
	if(!g_GuildaLider[id])
	{
		PrintGuild(id, "^1 Ops, voce nao eh o lider de uma guild!")
		return PLUGIN_HANDLED
	}
	
	if(!registro_user_liberado(id)) // Security Check
	{
		return PLUGIN_HANDLED;
	}
	
	get_user_name(pedinte, NomePedinte, charsmax(NomePedinte))
	get_user_name(id, NomeLider, charsmax(NomeLider))
	
	switch(key+1)
	{
		case 1: // Aceitou o pedido
		{
			//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
			// PEGAR O NÚMERO DE PACKS DO BANCO NOVAMENTE
			/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
			mySQLConnect()

			if ( gDbConnect == Empty_Handle ) return PLUGIN_HANDLED;
	
			static sql[212], error[128], thebankquery[63]
			new Handle:query
			new errcode
			new bank
	
			sql[0] = '^0'
			formatex(sql, charsmax(sql), "SELECT `ZMXP_AMMOPACKS` FROM `play_guilds` WHERE `ID` = '%i'", g_GuildaID[id])
			query = SQL_PrepareQuery(gDbConnect, "%s", sql)
	
			if ( !SQL_Execute(query) ) {
				errcode = SQL_QueryError(query, error, charsmax(error))
				Log("Erro ao criar query de saque para Guilda: %i [%d] '%s' - '%s'", g_GuildaID[id], errcode, error, sql)
				SQL_FreeHandle(query)
				return PLUGIN_HANDLED;
			}	
	
			SQL_ReadResult(query, 0, thebankquery, charsmax(thebankquery))
			bank = str_to_num(thebankquery)
	
			SQL_FreeHandle(query)
			
			/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
			/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
			// Checks de segurança...
		
			if(saque > bank)
			{
				PrintGuild(id,"^1 O banco tem apenas %i APs, nao da pra sacar %i!", bank, saque)
				PrintGuild(pedinte,"^1 O banco tem apenas %i APs, nao da pra sacar %i!", bank, saque)
				close_mysql()
				return PLUGIN_HANDLED;
			}
		
			// OK... o saque nao é negativo nem maior que a quantidade do banco.
		
			new quantia = (bank -= saque)
		
			sql[0] = '^0'
			formatex(sql, charsmax(sql), "UPDATE `play_guilds` SET `ZMXP_AMMOPACKS`='%i' WHERE `ID`='%i'", quantia, g_GuildaID[id])
			query = SQL_PrepareQuery(gDbConnect, "%s", sql)
	
			if ( !SQL_Execute(query) ) {
				errcode = SQL_QueryError(query, error, charsmax(error))
				Log("Erro no saque de %i para a Guilda: %i [%d] '%s' - '%s'", saque, g_GuildaID[id], errcode, error, sql)
				PrintGuild(id,"^1 Houve um erro no banco de dados... Desculpe.")
				SQL_FreeHandle(query)
				return PLUGIN_HANDLED;
			}
		
			SQL_FreeHandle(query)
			close_mysql()
		
			new ammopackz = zp_get_user_ammo_packs(pedinte)
			zp_set_user_ammo_packs(pedinte, ammopackz + saque)
			
			PrintGuild(pedinte, "^1 O Master^3 %s^1 aceitou seu pedido de saque!", NomeLider)
			PrintGuild(pedinte,"^1 Voce recebeu^3 %i^1 APs do Banco da Guild com sucesso!", saque)
			PrintGuild(0,"^1 Membro^3 %s^1 retirou^3 %i^1 APs do Banco da Guild^3 %s", NomePedinte, saque, g_GuildaNome[pedinte])
			Log("Membro %s retirou %i APs do Banco da Guild %s", NomePedinte, saque, g_GuildaNome[pedinte])
		}
		case 2: // Recusou o pedido
		{
			PrintGuild(pedinte, "^3 %s^1 nao aceitou seu pedido de saque.",NomeLider)
			PrintGuild(id, "^1 Voce recusou o pedido de saque de^3 %s", NomePedinte)
			g_BancoSaqueLider[id] = 0  // talvez bugfix
			g_BancoSaqueLiderQuantia[id] = 0  // talvez bugfix
		}
	}
	
	return PLUGIN_HANDLED
}		

public VoiceOn(id)
{
	g_GuildaVoice[id] = true
	client_cmd(id, "+voicerecord")
	return PLUGIN_HANDLED;
}
public VoiceOff(id)
{
	g_GuildaVoice[id] = false
	client_cmd(id, "-voicerecord")
	return PLUGIN_HANDLED;
}

// ========================================
// Guild Party by hx7r
// ========================================

public voice_listening(receiver, sender, bool:listen)
{
	if(!is_user_connected(receiver) || !is_user_connected(sender) || receiver == sender)
		return FMRES_IGNORED

	if(g_GuildaVoice[sender])
	{
		if(g_GuildaID[sender] == g_GuildaID[receiver])
		{
			engfunc(EngFunc_SetClientListening, receiver, sender, true)
			return FMRES_SUPERCEDE
		}
		else
		{
			engfunc(EngFunc_SetClientListening, receiver, sender, false)
			forward_return(FMV_CELL, false);
			return FMRES_SUPERCEDE;
		}
		
	}
	return FMRES_IGNORED
}

public HookSay(id)
{	
	read_args(g_typed, charsmax(g_typed))
	remove_quotes(g_typed)
	
	if(containi(g_typed, "%") != -1)
		return PLUGIN_HANDLED
	
	if(!g_GuildaMembro[id]) return PLUGIN_CONTINUE

	if(equal(g_typed, "") || !g_JogadorConectado[id])
		return PLUGIN_CONTINUE	
	
	if(g_typed[0] == '#')
	{
		TeamGuildMSG(id, g_typed)
		return PLUGIN_HANDLED
	}	
	
	get_user_name(id, g_name, charsmax(g_name))
	g_team = get_user_team(id)		
	
	new const team_info[2][][] = {
		{"*SPEC* ", "*DEAD* ", "*DEAD* ", "*SPEC* "},
		{"", "", "", ""}
	}
	
	formatex(g_message, charsmax(g_message), "^1%s^4%s^3 %s :^1 %s", team_info[is_user_alive(id)][g_team], g_GuildaTag[id], g_name, g_typed)

	for(new i = 1; i <= gServerMaxPlayers; i++)
	{
		if(!is_user_connected(i) || !g_JogadorConectado[i]) // Check duplo anti-crash
			continue

		if(is_user_alive(id) && is_user_alive(i) || !is_user_alive(id) && !is_user_alive(i))
		{
			send_message(g_message, id, i)
		}
	}	
		
	return PLUGIN_HANDLED_MAIN
}

public HookSayTeam(id)
{
	read_args(g_typed, charsmax(g_typed))
	remove_quotes(g_typed)
	
	if(containi(g_typed, "%") != -1)
		return PLUGIN_HANDLED
	
	if(!g_GuildaMembro[id]) return PLUGIN_CONTINUE

	if(equal(g_typed, "") || !g_JogadorConectado[id])
		return PLUGIN_CONTINUE	

	get_user_name(id, g_name, charsmax(g_name))
	g_team = get_user_team(id)
	
	new const team_info[2][][] = {
		{"(Spectator) ", "*DEAD*(Terrorist) ", "*DEAD*(Counter-Terrorist) ", "(Spectator) "},
		{"(Spectator) ", "(Terrorist) ", "(Counter-Terrorist) ", "(Spectator) "}
	}
	
	formatex(g_message, charsmax(g_message), "^1%s^4%s^3 %s :^1 %s", team_info[is_user_alive(id)][g_team], g_GuildaTag[id], g_name, g_typed)

	for(new i = 1; i <= gServerMaxPlayers; i++)
	{
		if(!is_user_connected(i) || !g_JogadorConectado[i]) // Check duplo anti-crash
			continue

		if(get_user_team(id) == get_user_team(i))
		{
			if(is_user_alive(id) && is_user_alive(i) || !is_user_alive(id) && !is_user_alive(i))
			{
				send_message(g_message, id, i)
			}
		}
	}

	return PLUGIN_HANDLED_MAIN
}

public TeamGuildMSG(id, msg[])
{
	new szName[33]
	get_user_name (id, szName, sizeof szName -1)
	
	replace(msg, 190, "#", "")
	static i
	
	if( is_user_alive(id) )
	{
		for(i = 1 ; i <= gServerMaxPlayers ; i++)
		if(g_JogadorConectado[i] && g_GuildaMembro[i] && g_GuildaID[i] == g_GuildaID[id])
		{
			if(g_GuildaLider[id])
			{
				PrintGuildChat(i,"^3 (Master) %s^4:  %s", szName, msg)
			}
			else PrintGuildChat(i,"^3 %s^1:  %s", szName, msg)
			
			client_cmd(i, "speak events/enemy_died.wav")
		}
	}
	else 
	{
		for(i = 1 ; i <= gServerMaxPlayers ; i++)
		if(g_JogadorConectado[i] && g_GuildaMembro[i] && g_GuildaID[i] == g_GuildaID[id])
		{
			if(g_GuildaLider[id])
			{
				PrintGuildChat(i,"^1 *DEAD*^3 (Master) %s^4:  %s", szName, msg)
			}
			else PrintGuildChat(i,"^1 *DEAD*^3 %s^1:  %s", szName, msg)
			
			client_cmd(i, "speak events/enemy_died.wav")
		}
	}
}

mySQLConnect()
{
	if ( gDbConnect ) {
		if ( !get_pcvar_num(guild_mysql_persistent) && !gPersistentTemp ) close_mysql()
		else return
	}

	if ( !gDbTuple ) {
		//mysql only for now
		SQL_SetAffinity("mysql")

		// Set up the tuple, cache the information
		//gDbTuple = SQL_MakeDbTuple("localhost", "root", "zmdark7732", "zplague_zombieas")
		//gDbTuple = SQL_MakeDbTuple("localhost", "root", "zmdark7732", "zplague_zombiexp")
		#include "play4ever.inc/play_conecta.play"
	}

	// Attempt to connect
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

close_mysql()
{
	if ( gDbConnect == Empty_Handle || get_pcvar_num(guild_mysql_persistent) || gPersistentTemp ) return

	SQL_FreeHandle(gDbConnect)
	gDbConnect = Empty_Handle
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
	format(filename, sizeof(filename) - 1, "%s/PLAY_GUILD_%s.log", dir, filename);

	log_to_file(filename, "%s", message);
}

PrintGuild(id, const message_format[], any:...)
{
	static message[192], len;
	len = formatex(message, sizeof(message) - 1, "^4%s", MESSAGE_TAG_GUILD);
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
		if( g_JogadorConectado[player] && is_user_connected(player) ) // Inútil mas acho que evita crash.
		{
			message_begin(MSG_ONE_UNRELIABLE, g_msgid_SayText, _, player);
			write_byte(player);
			write_string(message);
			message_end();
		}
	}
}

PrintGuildChat(id, const message_format[], any:...)
{
	static message[192], len;
	len = formatex(message, sizeof(message) - 1, "^4%s [Chat]", g_GuildaTag[id]);
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
		if( g_JogadorConectado[player] && is_user_connected(player) ) // Inútil mas acho que evita crash.
		{
			message_begin(MSG_ONE_UNRELIABLE, g_msgid_SayText, _, player);
			write_byte(player);
			write_string(message);
			message_end();
		}
	}
}

stock send_message(const message[], const id, const i)
{
	message_begin(MSG_ONE, g_msgid_SayText, {0, 0, 0}, i)
	write_byte(id)
	write_string(message)
	message_end()
}

PegarLevelGuild( pontos ){
	if( pontos <= 1000 )
		return 0;
	
	if( pontos <= 5000 )
		return 1;
	
	if( pontos <= 15000 )
		return 2;
	
	if(pontos <= 25000)
	{
		return 3
	}
	
	if(pontos <= 45000)
	{
		return 4
	}
	
	if(pontos <= 80000)
	{
		return 5
	}
	
	if(pontos <= 120000)
	{
		return 6
	}
	
	if(pontos <= 190000)
	{
		return 7
	}
	
	if(pontos <= 250000)
	{
		return 8
	}
	
	if(pontos <= 320000)
	{
		return 9
	}	
	
	if(pontos <= 400000)
	{
		return 10
	}
	
	if(pontos > 400000)
	{
		return 10
	}	
	
	return 0
}

MostrarMotdMembros(id, paraquem)
{
	static motd[2048]
	new len = formatex(motd, sizeof(motd) - 1, "<body style=^"background-color:#030303; color:#FF8F00^">")
	len += format(motd[len], sizeof(motd) - len - 1,	"<font face=^"Verdana^" size=^"4^">NOME DA GUILD: <b>%s </b><br>", g_GuildaNome[id])
	len += format(motd[len], sizeof(motd) - len - 1,	"RANK DA GUILD: <b>%i</b></font><br>", g_GuildaRank[id])
	len += format(motd[len], sizeof(motd) - len - 1,	"<br>")
	len += format(motd[len], sizeof(motd) - len - 1,	"<br><font face=^"Verdana^" size=^"2^">")
	
	mySQLConnect()
	if ( gDbConnect == Empty_Handle ) return false
	
	static sql[320]
	new Handle:query
	new errcode, member_points
	new total_guild = 0
	new total_points = 0

	sql[0] = '^0'
	formatex(sql, charsmax(sql), "SELECT `NICK`, `MEMBRO_KEY`, `PONTOS` FROM `play_guilds_membros` WHERE `ID` = '%i' ORDER BY `LIDER` DESC", g_GuildaID[id])
	query = SQL_PrepareQuery(gDbConnect, "%s", sql)
	
	if ( !SQL_Execute(query) ) {
		errcode = SQL_QueryError(query, error, charsmax(error))
		Log("Erro ao criar query do motd para Guild ID: %i [%d] '%s' - '%s'", g_GuildaID[id], errcode, error, sql)
		SQL_FreeHandle(query)
		return PLUGIN_HANDLED;
	}

	if ( SQL_NumResults(query) ) {
		static membroGuild[64], memberkey[64], memberpoints[32]

		while ( SQL_MoreResults(query) ) {
			membroGuild[0] = '^0'
			memberkey[0] = '^0'
			memberpoints[0] = '^0'
			
			SQL_ReadResult(query, SQL_FieldNameToNum(query, "NICK"), membroGuild, sizeof(membroGuild) - 1)
			SQL_ReadResult(query, SQL_FieldNameToNum(query, "MEMBRO_KEY"), memberkey, sizeof(memberkey) - 1)
			SQL_ReadResult(query, SQL_FieldNameToNum(query, "PONTOS"), memberpoints, sizeof(memberpoints) - 1)
			
			member_points = str_to_num(memberpoints)
			total_points += member_points
			total_guild++
			
			if(total_guild == 1) // Lider da guild
			{
				len += format(motd[len], sizeof(motd) - len - 1, "[%i] NICK: <b>%s</b> || KEY: <b>%s</b> || Pontos: <b>%i</b>  <b>(MASTER)</b><br>", total_guild, membroGuild, memberkey, member_points)
			}
			else len += format(motd[len], sizeof(motd) - len - 1, "[%i] NICK: <b>%s</b> || KEY: <b>%s</b> || Pontos: <b>%i</b><br>", total_guild, membroGuild, memberkey, member_points)

			SQL_NextRow(query)
		}
	}

	SQL_FreeHandle(query)
	close_mysql()
	
	len += format(motd[len], sizeof(motd) - len - 1,	"<br>")
	len += format(motd[len], sizeof(motd) - len - 1,	"Total de Pontos da Guild: <b>%i</b></font>", total_points)
	
	new iTemp[ 128 ]
	formatex( iTemp, charsmax( iTemp ), "%s Guilds", xPrefix );
	show_motd(paraquem, motd, iTemp );
	
	return PLUGIN_HANDLED;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1046\\ f0\\ fs16 \n\\ par }
*/
