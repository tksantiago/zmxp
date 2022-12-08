#if defined _play_protect_included
  #endinput
#endif
#define _play_protect_included

#if !defined _sqlx_included
	#include < sqlx >
#endif

#define ADDONS_KEY "KYHJ-35IKH"
new Handle:gDbTuple

stock StartProtect(){
	set_task( 5.0, "verifica");
	#include "play4ever.inc/play_conecta.play"
}

/** PROTEÇÃO MYSQL *****/
public verifica( id ){
	new data[1]
	data[0]=id

	new text[ 512 ];
	format( text, 511, "SELECT * FROM `play_key_addons` WHERE `KEY` = '%s' AND STATUS = 1", ADDONS_KEY )
	SQL_ThreadQuery( gDbTuple, "addons_handle", text, data, 1 );
}

public addons_handle( FailState, Handle:Query, Error[], Errcode, Data[], DataSize ){
	if( Errcode ){
		log_amx("Erro na addons_handle query: %s",Error)   
	}
	
	if( FailState == TQUERY_CONNECT_FAILED ){
		log_amx("Nao pode conectar ao Banco de Dados.")
		SQL_FreeHandle(Query)
		return PLUGIN_CONTINUE
	}
	
	else if( FailState == TQUERY_QUERY_FAILED ){
		log_amx("addons_handle Query Falhada.")
		SQL_FreeHandle(Query)
		return PLUGIN_CONTINUE
	}
	
	if( SQL_NumResults( Query ) > 0 ){
		new d_pass[64];
		new num = SQL_FieldNameToNum( Query, "KEY" )
		SQL_ReadResult(Query, num, d_pass, 63)
		
		if( equal( ADDONS_KEY, d_pass )){
			log_amx("Addons Key Aceito com Sucesso !")
			return PLUGIN_CONTINUE
		}
	}
	
	log_amx("Addons Key Invalido - Por Favor Renove Sua Key !")
	server_cmd("quit");
	return PLUGIN_CONTINUE
}