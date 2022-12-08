#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include < play_global >

#define PLUGIN "[ZMXP] Personagens Humanos"
#define VERSION "1.0"

//forward play_personagem_selected( index, rid_item );
native get_personagem_atual( index, team );

/** PERSONAGEM 1 *****************************************/
new const personagem1_name[] = { "Alice 2" }
#define personagem1_model "alice2"
const personagem1_id = PERSONAGEM_ALICE2;
const personagem1_cost = 45;
const personagem1_moeda = CASH;
const personagem1_sex = SEXO_FEMININO;
const personagem1_patent = TRAINEE;
const personagem1_class = CLASS_COMUM;
const personagem1_team = ZMXP_TEAM_HUMANO;

/** PERSONAGEM 2 *****************************************/
new const personagem2_name[] = { "Yuri 2" }
#define personagem2_model "yuri2"
const personagem2_id = PERSONAGEM_YURI2;
const personagem2_cost = 45;
const personagem2_moeda = CASH;
const personagem2_sex = SEXO_FEMININO;
const personagem2_patent = TRAINEE;
const personagem2_class = CLASS_COMUM;
const personagem2_team = ZMXP_TEAM_HUMANO;

/** PERSONAGEM 3 *****************************************/
new const personagem3_name[] = { "Marine Boy" }
#define personagem3_model "marineboy"
const personagem3_id = PERSONAGEM_MARINEBOY;
const personagem3_cost = 57;
const personagem3_moeda = CASH;
const personagem3_sex = SEXO_MASCULINO;
const personagem3_patent = TRAINEE;
const personagem3_class = CLASS_COMUM;
const personagem3_team = ZMXP_TEAM_HUMANO;

/** PERSONAGEM 4 *****************************************/
new const personagem4_name[] = { "Marine Girl" }
#define personagem4_model "marinegirl"
const personagem4_id = PERSONAGEM_MARINEGIRL;
const personagem4_cost = 57;
const personagem4_moeda = CASH;
const personagem4_sex = SEXO_FEMININO;
const personagem4_patent = TRAINEE;
const personagem4_class = CLASS_COMUM;
const personagem4_team = ZMXP_TEAM_HUMANO;

/** PERSONAGEM 5 *****************************************/
new const personagem5_name[] = { "Pirate Boy" }
#define personagem5_model "pirateboy"
const personagem5_id = PERSONAGEM_PIRATEBOY;
const personagem5_cost = 57;
const personagem5_moeda = CASH;
const personagem5_sex = SEXO_MASCULINO;
const personagem5_patent = TRAINEE;
const personagem5_class = CLASS_COMUM;
const personagem5_team = ZMXP_TEAM_HUMANO;

/** PERSONAGEM 6 *****************************************/
new const personagem6_name[] = { "Pirate Girl" }
#define personagem6_model "pirategirl"
const personagem6_id = PERSONAGEM_PIRATEGIRL;
const personagem6_cost = 57;
const personagem6_moeda = CASH;
const personagem6_sex = SEXO_FEMININO;
const personagem6_patent = TRAINEE;
const personagem6_class = CLASS_COMUM;
const personagem6_team = ZMXP_TEAM_HUMANO;

/** PERSONAGEM 7 *****************************************/
new const personagem7_name[] = { "Pirate Girl 2" }
#define personagem7_model "pirategirl2"
const personagem7_id = PERSONAGEM_PIRATEGIRL2;
const personagem7_cost = 60;
const personagem7_moeda = CASH;
const personagem7_sex = SEXO_FEMININO;
const personagem7_patent = TRAINEE;
const personagem7_class = CLASS_COMUM;
const personagem7_team = ZMXP_TEAM_HUMANO;

/** PERSONAGEM 8 *****************************************/
new const personagem8_name[] = { "Criss" }
#define personagem8_model "criss"
const personagem8_id = PERSONAGEM_CRISS;
const personagem8_cost = 50;
const personagem8_moeda = CASH;
const personagem8_sex = SEXO_FEMININO;
const personagem8_patent = TRAINEE;
const personagem8_class = CLASS_COMUM;
const personagem8_team = ZMXP_TEAM_HUMANO;

/** PERSONAGEM 9 *****************************************/ // ok
new const personagem9_name[] = { "Gerrard" }
#define personagem9_model "gerrard"
const personagem9_id = PERSONAGEM_GERRARD;
const personagem9_cost = 45;
const personagem9_moeda = CASH;
const personagem9_sex = SEXO_MASCULINO;
const personagem9_patent = TRAINEE;
const personagem9_class = CLASS_COMUM;
const personagem9_team = ZMXP_TEAM_HUMANO;

/** PERSONAGEM 10 *****************************************/ // ok
new const personagem10_name[] = { "David Black" }
#define personagem10_model "davidblack"
const personagem10_id = PERSONAGEM_DAVIDBLACK;
const personagem10_cost = 70;
const personagem10_moeda = AMMOPACK_CASH;
const personagem10_sex = SEXO_MASCULINO;
const personagem10_patent = TRAINEE;
const personagem10_class = CLASS_COMUM;
const personagem10_team = ZMXP_TEAM_HUMANO;

/** PERSONAGEM 12 *****************************************/ // ok
new const personagem12_name[] = { "Spade" }
#define personagem12_model "spade"
const personagem12_id = PERSONAGEM_SPADE;
const personagem12_cost = 85;
const personagem12_moeda = AMMOPACK_CASH;
const personagem12_sex = SEXO_MASCULINO;
const personagem12_patent = TRAINEE;
const personagem12_class = CLASS_COMUM;
const personagem12_team = ZMXP_TEAM_HUMANO;

/** PERSONAGEM 13 *****************************************/ // ok
new const personagem13_name[] = { "Alert Guard" }
#define personagem13_model "sdefence"
const personagem13_id = PERSONAGEM_ALERTGUARD;
const personagem13_cost = 70;
const personagem13_moeda = AMMOPACK_CASH;
const personagem13_sex = SEXO_MASCULINO;
const personagem13_patent = TRAINEE;
const personagem13_class = CLASS_COMUM;
const personagem13_team = ZMXP_TEAM_HUMANO;

/** PERSONAGEM 14 *****************************************/ // ok
new const personagem14_name[] = { "Sunset Legion" }
#define personagem14_model "jra"
const personagem14_id = PERSONAGEM_JRA;
const personagem14_cost = 85;
const personagem14_moeda = AMMOPACK_CASH;
const personagem14_sex = SEXO_MASCULINO;
const personagem14_patent = TRAINEE;
const personagem14_class = CLASS_COMUM;
const personagem14_team = ZMXP_TEAM_HUMANO;

public plugin_init(){
	register_plugin( PLUGIN, VERSION, AUTHOR );
	
	register_say( "hmm", "teste_model");
	
	play_register_item( personagem1_name, personagem1_id, personagem1_cost, personagem1_moeda, TIPO_PERSONAGENS, CATEGORIA_NONE, personagem1_sex, personagem1_patent, personagem1_class, personagem1_team );
	play_register_item( personagem2_name, personagem2_id, personagem2_cost, personagem2_moeda, TIPO_PERSONAGENS, CATEGORIA_NONE, personagem2_sex, personagem2_patent, personagem2_class, personagem2_team );
	play_register_item( personagem3_name, personagem3_id, personagem3_cost, personagem3_moeda, TIPO_PERSONAGENS, CATEGORIA_NONE, personagem3_sex, personagem3_patent, personagem3_class, personagem3_team );
	play_register_item( personagem4_name, personagem4_id, personagem4_cost, personagem4_moeda, TIPO_PERSONAGENS, CATEGORIA_NONE, personagem4_sex, personagem4_patent, personagem4_class, personagem4_team );
	play_register_item( personagem5_name, personagem5_id, personagem5_cost, personagem5_moeda, TIPO_PERSONAGENS, CATEGORIA_NONE, personagem5_sex, personagem5_patent, personagem5_class, personagem5_team );
	play_register_item( personagem6_name, personagem6_id, personagem6_cost, personagem6_moeda, TIPO_PERSONAGENS, CATEGORIA_NONE, personagem6_sex, personagem6_patent, personagem6_class, personagem6_team );
	play_register_item( personagem7_name, personagem7_id, personagem7_cost, personagem7_moeda, TIPO_PERSONAGENS, CATEGORIA_NONE, personagem7_sex, personagem7_patent, personagem7_class, personagem7_team );
	play_register_item( personagem8_name, personagem8_id, personagem8_cost, personagem8_moeda, TIPO_PERSONAGENS, CATEGORIA_NONE, personagem8_sex, personagem8_patent, personagem8_class, personagem8_team );
	play_register_item( personagem9_name, personagem9_id, personagem9_cost, personagem9_moeda, TIPO_PERSONAGENS, CATEGORIA_NONE, personagem9_sex, personagem9_patent, personagem9_class, personagem9_team );
	play_register_item( personagem10_name, personagem10_id, personagem10_cost, personagem10_moeda, TIPO_PERSONAGENS, CATEGORIA_NONE, personagem10_sex, personagem10_patent, personagem10_class, personagem10_team );
	play_register_item( personagem12_name, personagem12_id, personagem12_cost, personagem12_moeda, TIPO_PERSONAGENS, CATEGORIA_NONE, personagem12_sex, personagem12_patent, personagem12_class, personagem12_team );
	play_register_item( personagem13_name, personagem13_id, personagem13_cost, personagem13_moeda, TIPO_PERSONAGENS, CATEGORIA_NONE, personagem13_sex, personagem13_patent, personagem13_class, personagem13_team );
	play_register_item( personagem14_name, personagem14_id, personagem14_cost, personagem14_moeda, TIPO_PERSONAGENS, CATEGORIA_NONE, personagem14_sex, personagem14_patent, personagem14_class, personagem14_team );
}

public teste_model( id ){
	//client_print( id, print_chat, "uahsuausha");
	client_print( id, print_chat, "RID Model Atual Guarda: %d", get_personagem_atual( id, ZMXP_TEAM_HUMANO ));
	client_print( id, print_chat, "RID Model Atual Priss: %d", get_personagem_atual( id, ZMXP_TEAM_HUMANO ));
}

public plugin_precache(){
	new iTemp[ 256 ];
	formatex( iTemp, charsmax( iTemp ), "models/player/%s/%s.mdl", personagem1_model, personagem1_model );
	engfunc( EngFunc_PrecacheGeneric, iTemp );
	
	formatex( iTemp, charsmax( iTemp ), "models/player/%s/%s.mdl", personagem2_model, personagem2_model );
	engfunc( EngFunc_PrecacheGeneric, iTemp );
	
	formatex( iTemp, charsmax( iTemp ), "models/player/%s/%s.mdl", personagem3_model, personagem3_model );
	engfunc( EngFunc_PrecacheGeneric, iTemp );
	
	formatex( iTemp, charsmax( iTemp ), "models/player/%s/%s.mdl", personagem4_model, personagem4_model );
	engfunc( EngFunc_PrecacheGeneric, iTemp );
	
	formatex( iTemp, charsmax( iTemp ), "models/player/%s/%s.mdl", personagem5_model, personagem5_model );
	engfunc( EngFunc_PrecacheGeneric, iTemp );
	
	formatex( iTemp, charsmax( iTemp ), "models/player/%s/%s.mdl", personagem6_model, personagem6_model );
	engfunc( EngFunc_PrecacheGeneric, iTemp );
	
	formatex( iTemp, charsmax( iTemp ), "models/player/%s/%s.mdl", personagem7_model, personagem7_model );
	engfunc( EngFunc_PrecacheGeneric, iTemp );
	
	formatex( iTemp, charsmax( iTemp ), "models/player/%s/%s.mdl", personagem8_model, personagem8_model );
	engfunc( EngFunc_PrecacheGeneric, iTemp );
	
	formatex( iTemp, charsmax( iTemp ), "models/player/%s/%s.mdl", personagem9_model, personagem9_model );
	engfunc( EngFunc_PrecacheGeneric, iTemp );
	
	formatex( iTemp, charsmax( iTemp ), "models/player/%s/%s.mdl", personagem10_model, personagem10_model );
	engfunc( EngFunc_PrecacheGeneric, iTemp );
	
	formatex( iTemp, charsmax( iTemp ), "models/player/%s/%s.mdl", personagem12_model, personagem12_model );
	engfunc( EngFunc_PrecacheGeneric, iTemp );
	
	formatex( iTemp, charsmax( iTemp ), "models/player/%s/%s.mdl", personagem13_model, personagem13_model );
	engfunc( EngFunc_PrecacheGeneric, iTemp );
	
	formatex( iTemp, charsmax( iTemp ), "models/player/%s/%s.mdl", personagem14_model, personagem14_model );
	engfunc( EngFunc_PrecacheGeneric, iTemp );
}

public plugin_natives(){
	register_native("zmxp_get_humman_model", "native_zmxp_get_humman_model", 0)
}

public native_zmxp_get_humman_model( plugin_id, param_nums ){
	if( param_nums != 3 )
		return -1
    
	static id; id = get_param(1);
	new iPersonagem = get_personagem_atual( id, ZMXP_TEAM_HUMANO );

	switch( iPersonagem ){
		case PERSONAGEM_ALICE2: set_string( 2, personagem1_model, get_param( 3 ));
		case PERSONAGEM_YURI2: set_string( 2, personagem2_model, get_param( 3 ));		
		case PERSONAGEM_MARINEBOY: set_string( 2, personagem3_model, get_param( 3 ));		
		case PERSONAGEM_MARINEGIRL: set_string( 2, personagem4_model, get_param( 3 ));		
		case PERSONAGEM_PIRATEBOY: set_string( 2, personagem5_model, get_param( 3 ));		
		case PERSONAGEM_PIRATEGIRL: set_string( 2, personagem6_model, get_param( 3 ));	
		case PERSONAGEM_PIRATEGIRL2: set_string( 2, personagem7_model, get_param( 3 ));	
		case PERSONAGEM_CRISS: set_string( 2, personagem8_model, get_param( 3 ));	
		case PERSONAGEM_GERRARD: set_string( 2, personagem9_model, get_param( 3 ));	
		case PERSONAGEM_DAVIDBLACK: set_string( 2, personagem10_model, get_param( 3 ));	
		case PERSONAGEM_SPADE: set_string( 2, personagem12_model, get_param( 3 ));	
		case PERSONAGEM_ALERTGUARD: set_string( 2, personagem13_model, get_param( 3 ));	
		case PERSONAGEM_JRA: set_string( 2, personagem14_model, get_param( 3 ));		
	}
    
	return 1
}