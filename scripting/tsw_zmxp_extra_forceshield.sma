#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <cstrike>
#include <zombieplague>
#include <hamsandwich>
#include <fakemeta_util>
#include <fun>

#define PLUGIN "[ZMXP] Campo de Forca"

/*=============================[Plugin Customization]=============================*/

//#define CAMPO_ROUND_NAME "Force Shield (One Round)"
#define CAMPO_TIME_NAME "Campo de Forca Sagrado"

#define CAMPO_TASK
#define RANDOM_COLOR

new const NADE_TYPE_CAMPO = 5698 

new const model_grenade[] = "models/zombie_plague/v_gren_koshak.mdl"

new const model[ 2 ][] = {
	"models/zombie_plague/aura_koshak.mdl",
	"models/CSP-2014/zmxp/sf_pumpkin.mdl"
}

//new const model[] = "models/zombie_plague/aura_koshak.mdl"
new const sprite_grenade_trail[] = "sprites/laserbeam.spr"
new const entclas[] = "campo_forca"
new cvar_flaregrenades, g_trailSpr, cvar_push, g_itemID
new bool:g_bomb[33]
new g_tempo[33]
new Float:vColor[33][ 3 ]
new g_Delay
/*=============================[End Customization]=============================*/

public plugin_init(){
	register_plugin(PLUGIN, "0.01", "lucas_7_94")
	
	RegisterHam(Ham_Think, "grenade", "fw_ThinkGrenade")
	
	cvar_flaregrenades = get_cvar_pointer("zp_flare_grenades")
	
	register_forward( FM_SetModel, "fw_SetModel");
	register_forward( FM_Touch, "fw_touch");

	register_event( "CurWeapon", "hook_curwpn", "be", "1=1", "2!29" );
	register_event("HLTV", "event_round_start", "a", "1=0", "2=0")
	
	cvar_push = register_cvar("zp_forze_push", "4.0") // antes 5.5
	g_Delay = register_cvar("zp_campo_forca_tempo", "65");
	
	g_itemID = zp_register_extra_item( CAMPO_TIME_NAME, 45, ZP_TEAM_HUMAN ) // 35 ap
}

public event_round_start() {
	
	#if defined CAMPO_ROUND
	remove_entity_name(entclas)
	#endif
	
	arrayset( g_bomb, false, 33 );
}

public plugin_precache(){
	g_trailSpr = engfunc( EngFunc_PrecacheModel, sprite_grenade_trail );
	
	engfunc( EngFunc_PrecacheModel, model_grenade );
	
	for( new i = 0; i < sizeof( model ); i++ )
		engfunc( EngFunc_PrecacheModel, model[ i ]);
}

public client_disconnect( id )
	g_bomb[id] = false;

public zp_extra_item_selected( player, itemid ){
	if( itemid == g_itemID ){
		if( g_bomb[ player ]){
			client_print( player, print_chat, "[ZP] Voce ja tem um Campo de Forca Sagrado!")
			return ZP_PLUGIN_HANDLED;
		}
		
		if( g_tempo[player] >= 1 ){
			client_print(player, print_chat, "[ZP] Voce ja tem um Campo de Forca funcionando!")
			return ZP_PLUGIN_HANDLED;
		}		

		g_bomb[player] = true
		give_item(player,"weapon_smokegrenade")
			
		client_print(player, print_chat, "[ZP] Voce comprou um Campo de Forca Sagrado! (Smoke)")
		g_tempo[player] = get_pcvar_num(g_Delay)
	}
	
	return PLUGIN_CONTINUE
}

public fw_ThinkGrenade(entity) {   
	
	if(!pev_valid(entity)) return HAM_IGNORED
	
	static Float:dmgtime   
	pev(entity, pev_dmgtime, dmgtime)
	
	if (dmgtime > get_gametime())
		return HAM_IGNORED   
	
	if(pev(entity, pev_flTimeStepSound) == NADE_TYPE_CAMPO)
		crear_ent(entity)
	
	return HAM_SUPERCEDE
}

	
public fw_SetModel(entity, const model[]) {	
	
	static Float:dmgtime
	pev(entity, pev_dmgtime, dmgtime)
	
	if (dmgtime == 0.0)
		return FMRES_IGNORED;
	
	if (equal(model[7], "w_sm", 4))
	{		
		new owner = pev(entity, pev_owner)		
		
		if(!is_user_connected(owner))
		{
			return FMRES_IGNORED;
		}
		if(!zp_get_user_zombie(owner) && g_bomb[owner]) 
		{
			set_pcvar_num(cvar_flaregrenades,0)			
			
			fm_set_rendering(entity, kRenderFxGlowShell, 000, 255, 255, kRenderNormal, 16)
			
			message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
			write_byte(TE_BEAMFOLLOW) // TE id
			write_short(entity) // entity
			write_short(g_trailSpr) // sprite
			write_byte(10) // life
			write_byte(10) // width
			write_byte(000) // r
			write_byte(255) // g
			write_byte(255) // b
			write_byte(500) // brightness
			message_end()
			
			set_pev(entity, pev_flTimeStepSound, NADE_TYPE_CAMPO)
			
			set_task(6.0, "DeleteEntityGrenade" ,entity)
			return FMRES_SUPERCEDE
		}
	}
	return FMRES_IGNORED
	
}

public DeleteEntityGrenade(entity) remove_entity(entity)

public crear_ent(id) {
	
	new attacker
	attacker = pev(id, pev_owner)
	
	g_bomb[attacker] = false
	
	set_pcvar_num(cvar_flaregrenades,1)
	
	// Create entitity
	new iEntity = create_entity("info_target")
	
	if(!is_valid_ent(iEntity))
		return PLUGIN_HANDLED
	
	new Float: Origin[3] 
	entity_get_vector(id, EV_VEC_origin, Origin) 
	
	entity_set_string(iEntity, EV_SZ_classname, entclas)
	
	entity_set_vector(iEntity,EV_VEC_origin, Origin)
	
	new iRandom;
	iRandom = random_num( 0, 1 );
	entity_set_model(iEntity, model[ iRandom ])
	
	entity_set_int(iEntity, EV_INT_solid, SOLID_TRIGGER)
	entity_set_size(iEntity, Float: {-100.0, -100.0, -100.0}, Float: {100.0, 100.0, 100.0})
	entity_set_int(iEntity, EV_INT_renderfx, kRenderFxGlowShell)
	entity_set_int(iEntity, EV_INT_rendermode, kRenderTransAlpha)
	entity_set_float(iEntity, EV_FL_renderamt, 50.0)
	
	if(is_valid_ent(iEntity)){	
		switch( random_num( 1, 10 )){
			case 1:{
				vColor[ attacker ][ 0 ] = 255.0;
				vColor[ attacker ][ 1 ] = 0.0;
				vColor[ attacker ][ 2 ] = 0.0;
			}
			
			case 2:{
				vColor[ attacker ][ 0 ] = 255.0;
				vColor[ attacker ][ 1 ] = 0.0;
				vColor[ attacker ][ 2 ] = 204.0;
			}
			
			case 3:{
				vColor[ attacker ][ 0 ] = 204.0;
				vColor[ attacker ][ 1 ] = 0.0;
				vColor[ attacker ][ 2 ] = 255.0;
			}
			
			case 4:{
				vColor[ attacker ][ 0 ] = 108.0;
				vColor[ attacker ][ 1 ] = 0.0;
				vColor[ attacker ][ 2 ] = 255.0;
			}
			
			case 5:{
				vColor[ attacker ][ 0 ] = 0.0;
				vColor[ attacker ][ 1 ] = 180.0;
				vColor[ attacker ][ 2 ] = 255.0;
			}
			
			case 6:{
				vColor[ attacker ][ 0 ] = 0.0;
				vColor[ attacker ][ 1 ] = 255.0;
				vColor[ attacker ][ 2 ] = 0.0;
			}
			
			case 7:{
				vColor[ attacker ][ 0 ] = 192.0;
				vColor[ attacker ][ 1 ] = 255.0;
				vColor[ attacker ][ 2 ] = 0.0;
			}
			
			case 8:{
				vColor[ attacker ][ 0 ] = 246.0;
				vColor[ attacker ][ 1 ] = 255.0;
				vColor[ attacker ][ 2 ] = 0.0;
			}
			
			case 9:{
				vColor[ attacker ][ 0 ] = 255.0;
				vColor[ attacker ][ 1 ] = 180.0;
				vColor[ attacker ][ 2 ] = 0.0;
			}
			
			case 10:{
				vColor[ attacker ][ 0 ] = 255.0;
				vColor[ attacker ][ 1 ] = 126.0;
				vColor[ attacker ][ 2 ] = 0.0;
			}
		}
		
		/*
		for(new i; i < 3; i++)
			vColor[attacker][i] = random_float(0.0, 255.0)
		*/
		
		entity_set_vector(iEntity, EV_VEC_rendercolor, vColor[ attacker ])
		
		new iColor[3]
		iColor[0] = floatround( vColor[ attacker ][ 0 ] );
		iColor[1] = floatround( vColor[ attacker ][ 1 ] );
		iColor[2] = floatround( vColor[ attacker ][ 2 ] );
		
		UTIL_DLight1( Origin, 80, iColor, 100, get_pcvar_num( g_Delay ));
	}

	set_task(get_pcvar_float(g_Delay), "DeleteEntity", iEntity)
	set_task(0.1,"campo_tempo", attacker)
	
	return PLUGIN_CONTINUE;
}

stock UTIL_DLight1( Float:vOrigin[ 3 ], iRadius, color[3], iLife, iDecay ){
	
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
	write_byte( TE_DLIGHT );
	engfunc( EngFunc_WriteCoord, vOrigin[ 0 ] );
	engfunc( EngFunc_WriteCoord, vOrigin[ 1 ] );
	engfunc( EngFunc_WriteCoord, vOrigin[ 2 ] );
	write_byte( iRadius );
	write_byte( color[0]);
	write_byte( color[1] );
	write_byte( color[2] );
	write_byte( iLife );
	write_byte( iDecay );
	message_end();
	
	engfunc(EngFunc_MessageBegin, MSG_PAS, SVC_TEMPENTITY, vOrigin, 0)
	write_byte(TE_DLIGHT) // TE id
	engfunc(EngFunc_WriteCoord, vOrigin[0]) // x
	engfunc(EngFunc_WriteCoord, vOrigin[1]) // y
	engfunc(EngFunc_WriteCoord, vOrigin[2]) // z
	write_byte( 25 ) // radius
	write_byte( color[0]) // r
	write_byte( color[1]) // g
	write_byte( color[2]) // b
	write_byte( 500 ) //life - 21 (EX: 10 Life =  1 segundo )
	write_byte( ( 900.0 < iDecay ) ? iDecay : 0 ) // tempo que a luz ficara acesa ( EX: 10 = 1 segundo )
	//write_byte( iDecay + 300 ) // tempo que a luz ficara acesa ( EX: 10 = 1 segundo )
	message_end()
}

public zp_user_infected_post( id, infector, nemesis ) // bug fix
{	
	if ( !infector || nemesis )
		return
	
	g_bomb[id] = false
	g_tempo[id] = 0
}

public campo_tempo(id)
{
	if(is_user_connected(id) && !zp_get_user_zombie(id))
	{
		--g_tempo[id]
		set_hudmessage(floatround(vColor[id][0]), floatround(vColor[id][1]), floatround(vColor[id][2]), 0.0, 0.65, 0, 1.0, 1.0, 0.1, 0.2, -1)
		show_hudmessage(id, "Campo: %d segundos", g_tempo[id])
		
		if(g_tempo[id] >= 1)
		{
			// Só continuar o task quando ainda restar 1 segundo para acabar o campo
			set_task(1.0,"campo_tempo", id)
		}
	}
	else g_tempo[id] = 0
}

public fw_touch(ent, touched)
{
	if ( !pev_valid(ent) ) return FMRES_IGNORED;
	static entclass[32];
	pev(ent, pev_classname, entclass, 31);
	
	if ( equali(entclass, entclas) ){	
		if( is_user_alive(touched) && zp_get_user_zombie( touched ) && !zp_get_user_nemesis( touched )){
			new Float:pos_ptr[3], Float:pos_ptd[3], Float:push_power = get_pcvar_float(cvar_push)
			
			pev(ent, pev_origin, pos_ptr)
			pev(touched, pev_origin, pos_ptd)
			
			for(new i = 0; i < 3; i++)
			{
				pos_ptd[i] -= pos_ptr[i]
				pos_ptd[i] *= push_power
			}
			set_pev(touched, pev_velocity, pos_ptd)
			set_pev(touched, pev_impulse, pos_ptd)
		}
	}
	return FMRES_IGNORED;
}

public remove_ent() {
	remove_entity_name(entclas)
}  

public DeleteEntity( entity )  // Thanks xPaw For The Code =D
	if( is_valid_ent( entity ) ) 
	remove_entity( entity );

public hook_curwpn( id ) { 
	if( !is_user_alive( id ) )
		return PLUGIN_CONTINUE;
	
	if( g_bomb[ id ] && !zp_get_user_zombie( id ) )
	{
		if( read_data( 2 ) == CSW_SMOKEGRENADE )
			set_pev( id, pev_viewmodel2, model_grenade )
	}
	return PLUGIN_CONTINUE;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1046\\ f0\\ fs16 \n\\ par }
*/
