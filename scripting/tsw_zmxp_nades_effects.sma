

#include < amxmodx >
#include < fakemeta >
#include < engine >
#include < hamsandwich >
#include < zombieplague >

#include < play_global >

#define PLUGIN "[ZMXP] New Nades Effects"
#define VERSION "1.0"



const PEV_NADE_TYPE = pev_flTimeStepSound
const PEV_FLARE_DURATION = pev_flSwimTime
const PEV_FLARE_COLOR = pev_punchangle

const NADE_TYPE_INFECTION = 1111
const NADE_TYPE_NAPALM = 2222
const NADE_TYPE_FROST = 3333
const NADE_TYPE_FLARE = 4444

#define TASK_REMOVE_SMOKE_INFECT	10000
#define TASK_SMOKE_INFECT_FREEZE	20000
#define TASK_INFECT_HEALTH			30000
#define TASK_REMOVE_SMOKEICE		40000
#define TASK_SMOKEICE_FREEZE		50000


#define INFECT_COLORS { 0, 255, 0 }
#define FIRE_COLORS { 255, 30, 0 }
#define FROST_COLORS { 0, 174, 255 }
#define FLARE_COLOR { 255, 255, 255 }

#define INFECT_ICON "dmg_rad"
#define FIRE_ICON "dmg_heat"
#define FROST_ICON "dmg_cold"
#define FLARE_ICON "dmg_shock"

#define SMOKE_ICE_CLASSNAME "SmokeIce"
#define GRENADE_ICE_CLASSNAME "GrenadeIce"
#define SMOKE_INFECT_CLASSNAME "SmokeInfect"
#define GRENADE_INFECT_CLASSNAME "GrenadeInfect"

#define infect_explode_sprite1 "sprites/satelite/infect_explode.spr"
#define infect_explode_sprite2 "sprites/satelite/infect_explode2.spr"
#define infect_gib_sprite "sprites/satelite/infect_gib2.spr"
#define infect_smoke_sprite "sprites/satelite/infect_smoke.spr"

#define frost_explode_sprite "sprites/satelite/frost_explode.spr"
#define frost_explode_sprite2 "sprites/_frostexp_1.spr"
#define frost_explode_sprite3 "sprites/_frostexp_2.spr"
#define frost_gib_sprite "sprites/satelite/frost_gib.spr"
#define frost_unfrozen_sprite "sprites/satelite/fun_slow.spr"

#define fire_explode_sprite1 "sprites/satelite/fire_explosion_1.spr"
#define fire_explode_sprite2 "sprites/satelite/fire_explosion_2.spr"
#define fire_gib_sprite "sprites/satelite/fire_gib.spr"
#define fire_black_smoke "sprites/satelite/black_smoke4.spr"
#define fire_cylinder "sprites/white.spr"
#define sprite_flare "sprites/3dmflaora.spr"

//#define smoke_sprite "sprites/black_smoke4.spr"

#define ice_cube_model "models/csp_iceblock.mdl"
//#define smoke_granade "models/w_smokegrenade.mdl"
#define smoke_granade "models/CSP-2014/zmxp/w_grenade_flare.mdl"

new mdl_index[16]
new xIceCubeEnt[ MAX_PLAYERS+1 ];
new Float:xOriginSmokeIce[ 3 ], xSmokeIceEnt[ 3 ];
new Float:xOriginSmokeInfect[ 3 ], xSmokeInfectEnt[ 3 ];

enum { SMOKEICE_FUMACA = 1, SMOKEICE_GRANADA }
enum { SMOKEINFECT_FUMACA = 1, SMOKEINFECT_GRANADA }

new xTouchIn[ MAX_PLAYERS + 1 ];
new Float: xTouchTime[ MAX_PLAYERS + 1 ];
new Float: xSmokeIceTime[ MAX_PLAYERS + 1 ];	
new Float: xSmokeInfectTime[ MAX_PLAYERS + 1 ];	
new bool: xPlayerFrozen[ 33 ]

new xMsgIDStatusIcon, xMsgIDDamage
new xGrenadeIcons[ MAX_PLAYERS+1 ][32];
new xPlayerHealthType[ MAX_PLAYERS+1 ], xPlayerFirstHealth[ MAX_PLAYERS+1 ], bool:xPlayerHealthStart[ MAX_PLAYERS+1 ] = false;

public plugin_init(){
	register_plugin( PLUGIN, VERSION, AUTHOR );
	
	RegisterHam( Ham_Think, "grenade", "fw_ThinkGrenade");
	RegisterHam( Ham_Spawn, "player", "fw_PlayerSpawn_Post", true );
	RegisterHam( Ham_Killed, "player", "fw_PlayerKilled");
	RegisterHam( Ham_Player_PreThink, "player", "fwd_PreThink" );
	
	register_forward( FM_Touch, "fw_TouchSmoke" );
	
	register_event("HLTV", "event_round_start", "a", "1=0", "2=0")
	//register_logevent("event_roundend", 2, "1=Round_End");
	register_event( "CurWeapon", "event_curweapon", "be", "1=1");
	xMsgIDStatusIcon = get_user_msgid("StatusIcon");
	xMsgIDDamage = get_user_msgid("Damage");
}

public plugin_precache(){
	engfunc( EngFunc_PrecacheModel, ice_cube_model );
	
	
	mdl_index[2] = engfunc( EngFunc_PrecacheModel, fire_explode_sprite1 );
	mdl_index[12] = engfunc( EngFunc_PrecacheModel, fire_explode_sprite2 );
	mdl_index[13] = engfunc( EngFunc_PrecacheModel, fire_black_smoke );
	mdl_index[3] = engfunc( EngFunc_PrecacheModel, fire_gib_sprite );
	
	mdl_index[0] = engfunc( EngFunc_PrecacheModel, frost_explode_sprite );
	mdl_index[1] = engfunc( EngFunc_PrecacheModel, frost_gib_sprite );
	//mdl_index[4] = engfunc( EngFunc_PrecacheModel, smoke_sprite );
	mdl_index[6] = engfunc( EngFunc_PrecacheModel, frost_explode_sprite2 );
	mdl_index[7] = engfunc( EngFunc_PrecacheModel, frost_explode_sprite3 );
	mdl_index[8] = engfunc( EngFunc_PrecacheModel, frost_unfrozen_sprite );
	mdl_index[14] = engfunc( EngFunc_PrecacheModel, fire_cylinder );
	mdl_index[15] = engfunc( EngFunc_PrecacheModel, sprite_flare );
	
	/** INFECT **/
	mdl_index[9] = engfunc( EngFunc_PrecacheModel, infect_explode_sprite1 );
	mdl_index[10] = engfunc( EngFunc_PrecacheModel, infect_explode_sprite2 );
	mdl_index[11] = engfunc( EngFunc_PrecacheModel, infect_gib_sprite );
	
	precache_model(smoke_granade);
	precache_model( infect_smoke_sprite );
}

public client_putinserver( id )
	xIceCubeEnt[ id ] = -1;

public client_disconnect( id )
	remove_ice_cube( id );

public zp_user_infected_pre( id ){
	if( xPlayerFrozen[ id ]){
		remove_ice_cube( id );
		UTIL_SpriteTrail( id, mdl_index[1], 30, 3, 2, 30, 0 );
	}
}

public zp_user_humanized_pre( id )
	remove_ice_cube( id );

public zp_user_unfrozen( id ){
	remove_ice_cube( id );
	UTIL_SpriteTrail( id, mdl_index[1], 30, random_num( 3,5 ), random_num( 3,5 ), 30, 0 );
	
	//static Float: iOrigin[3]
	//pev( id, pev_origin, iOrigin)
	
	//UTIL_Explosion( iOrigin, mdl_index[8], 40, 30, 4 );
}

public event_round_start(){
	remove_entity_name( GRENADE_ICE_CLASSNAME );
	remove_entity_name( SMOKE_ICE_CLASSNAME );
	remove_entity_name( GRENADE_INFECT_CLASSNAME );
	remove_entity_name( SMOKE_INFECT_CLASSNAME );
}

public event_curweapon( id ){
	RemoveGrenadeIcon( id );
		
	if( is_user_bot( id ))
		return;
		
	static iWeaponID, iSprite[ 16 ], iColor[3 ]
	iWeaponID = get_user_weapon( id );
	
	switch( iWeaponID ){
		case CSW_HEGRENADE:{
			/** GRANADA DE INFECÇÃO **/
			if( !is_user_alive( id ) || zp_get_user_zombie( id )){
				iSprite = INFECT_ICON;
				iColor = INFECT_COLORS;
			}
			
			/** GRANADA DE FOGO **/
			else {
				iSprite = FIRE_ICON;
				iColor = FIRE_COLORS;
			}
		}
		
		/** GRANADA DE GELO **/
		case CSW_FLASHBANG:{
			iSprite = FROST_ICON;
			iColor = FROST_COLORS;
		}
		
		/** GRANADA DE LUZ **/
		case CSW_SMOKEGRENADE:{
			iSprite = FLARE_ICON;
			iColor = FLARE_COLOR;
		}
		
		default: return;
	}
	
	xGrenadeIcons[ id ] = iSprite;
	ShowGrenadeIcon( id, iSprite, iColor );
	
	return
}

stock ShowGrenadeIcon( index, const sprite[], color[3] ){
	message_begin( MSG_ONE, xMsgIDStatusIcon, {0,0,0}, index );
	write_byte(1) // status (0=hide, 1=show, 2=flash)
	write_string( sprite ) // sprite name
	write_byte( color[0]) // red
	write_byte( color[1]) // green
	write_byte( color[2]) // blue
	message_end()
}

stock RemoveGrenadeIcon( index ){
	message_begin( MSG_ONE, xMsgIDStatusIcon, {0,0,0}, index );
	write_byte(0) // status (0=hide, 1=show, 2=flash)
	write_string( xGrenadeIcons[ index ]) // sprite name
	message_end()
}

public fw_PlayerKilled( victim, attacker, shouldgib ){
	remove_ice_cube( victim );
	RemoveGrenadeIcon( victim );
}

public fw_PlayerSpawn_Post( id ){
	if( !is_user_alive( id ) || !fm_cs_get_user_team( id ))
		return PLUGIN_HANDLED;
	
	remove_ice_cube( id );
	
	new iHealth = get_user_health( id );
	xPlayerFirstHealth[ id ] = iHealth;
	
	xPlayerHealthStart[ id ] = false;
	
	return PLUGIN_HANDLED;
}

public fw_ThinkGrenade( entity ){
	if(!pev_valid( entity ))
		return HAM_IGNORED;

	static Float:dmgtime, Float:current_time, a
	pev(entity, pev_dmgtime, dmgtime)
	current_time = get_gametime();
	
	if( dmgtime > current_time )
		return HAM_IGNORED;
	
	switch( pev( entity, PEV_NADE_TYPE )){
		
		/** GRANADA DE INFECÇÃO **/
		case NADE_TYPE_INFECTION:{
			
			static Float: iOrigin[3]
			pev( entity, pev_origin, iOrigin)
			
			/** GIB EFFECT **/
			nade_effect4( iOrigin, mdl_index[11], 50, random_num(1,3), random_num(20,30), random_num(20,30));
			nade_effect4( iOrigin, mdl_index[11], 50, random_num(1,3), random_num(20,30), random_num(20,30));
			nade_effect4( iOrigin, mdl_index[11], 50, random_num(1,3), random_num(20,30), random_num(20,30));
			nade_effect4( iOrigin, mdl_index[11], 50, random_num(1,3), random_num(20,30), random_num(20,30));
			
			/** LUZ **/
			UTIL_DLight1( iOrigin, 80, INFECT_COLORS, 100, 40 ); // luz clara
			
			/** FUMAÇA **/
			//MakeSmokeInfectEnt( iOrigin, INFECT_COLORS );
			
			//xOriginSmokeInfect = iOrigin;
			//xOriginSmokeInfect[0] += random_float( 5.0, 10.0);
			//xOriginSmokeInfect[1] += random_float( 5.0, 10.0);
			//xOriginSmokeInfect[2] += 30.0;
			
			//set_task( 1.0, "CreateSmokeInfect");
			//set_task( 4.0, "CreateSmokeInfect");
			
			/** EFEITO EXPLOSÃO **/
			iOrigin[2] += 60.0
			UTIL_Explosion1( iOrigin, mdl_index[9], 40, 30, 4 );
			UTIL_Explosion1( iOrigin, mdl_index[10], 20, 30, 4 );
		}
		
		/** GRANADA DE FOGO **/
		case NADE_TYPE_NAPALM:{
			
			static Float: iOrigin[3]
			pev( entity, pev_origin, iOrigin)
		
			//nade_effect1( iOrigin, mdl_index[ 3 ], random_num(3,6), random_num(3,6), 6, 20, 25 )
			//nade_effect1( iOrigin, mdl_index[ 3 ], random_num(10,15), random_num(3,6),4, 20, 25 )
			//nade_effect1( iOrigin, mdl_index[ 3 ], random_num(3,6), random_num(3,6),3, 20, 25 )
			//nade_effect2( iOrigin, { 255, 30, 0 }, 60, 8, 60 )
			
			
			//vOrigin[ 2 ] -= 32.0;
			UTIL_Explosion1( iOrigin, mdl_index[2], 50, 30, 4 );
			UTIL_Explosion1( iOrigin, mdl_index[12], 50, 10, 4 );
			
			UTIL_Smoke1( iOrigin, mdl_index[13], 30, 80 );
			UTIL_Smoke1( iOrigin, mdl_index[13], 15, 80 );
			
			UTIL_DLightHover1( iOrigin, 80, 255, 128, 0, 50, 40 );
			UTIL_BeamCylinder1( iOrigin, mdl_index[14], 0, 6, 20, 255, 255, 128, 0, 255, 0 );
			UTIL_SpriteTrail1( entity, mdl_index[15], 20, 3, random_num( 1, 3), 50, 0 );
			//stock UTIL_SpriteTrail( iEnt, iSprite, iCount, iLife, iScale, iVelocity, iVary )
			
			//iOrigin[2] += 60.0
			//nade_explosion( iOrigin, mdl_index[2], 30, 20 )
			
			for( a = 0; a < 6; a++ ){
				engfunc( EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, iOrigin, 0);
				
				write_byte( TE_SPARKS );
				engfunc( EngFunc_WriteCoord, iOrigin[0] + random_float( -50.0, 50.0 )) // x
				engfunc( EngFunc_WriteCoord, iOrigin[1] + random_float( -50.0, 50.0 )) // y
				engfunc( EngFunc_WriteCoord, iOrigin[2] + random_float( 5.0, 50.0 )) // z
				message_end();
			}
		}
	
		/** GRANADA DE GELO **/
		case NADE_TYPE_FROST:{			
			static Float: iOrigin[ 3 ];
			pev( entity, pev_origin, iOrigin );
			
			nade_effect2( iOrigin, { 10, 124, 255 }, 60, 8, 60 )
			
			/** GIBS **/
			nade_effect4( iOrigin, mdl_index[1], 50, random_num(1,4), random_num(20,30), random_num(20,30));
			nade_effect4( iOrigin, mdl_index[1], 50, random_num(1,4), random_num(20,30), random_num(20,30));
			nade_effect4( iOrigin, mdl_index[1], 50, random_num(1,4), random_num(20,30), random_num(20,30));
			nade_effect4( iOrigin, mdl_index[1], 50, random_num(1,4), random_num(20,30), random_num(20,30));
			
			/** LUZ **/
			UTIL_DLight1( iOrigin, 80, FROST_COLORS, 100, 40 ); // luz clara
			
			/** FUMAÇA **/			
			//MakeSmokeIceEnt( iOrigin, FROST_COLORS );
			
			//xOriginSmokeIce = iOrigin;
			//xOriginSmokeIce[0] += random_float( 5.0, 10.0);
			//xOriginSmokeIce[1] += random_float( 5.0, 10.0);
			//xOriginSmokeIce[2] += 30.0;
			
			//set_task( 1.0, "CreateSmokeIce");
			//set_task( 4.0, "CreateSmokeIce");
			
			/** EFEITO EXPLOSÃO **/
			iOrigin[2] += 60.0
			UTIL_Explosion1( iOrigin, mdl_index[6], 40, 30, 4 );
			UTIL_Explosion1( iOrigin, mdl_index[7], 20, 30, 4 );
			
			nade_explosion( iOrigin, mdl_index[0], 30, 20 )
			
			for( a = 0; a < 6; a++ ){
				engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, iOrigin, 0)
				write_byte(TE_SPARKS);
				engfunc(EngFunc_WriteCoord, iOrigin[0] + random_float( -50.0, 50.0 )) // x
				engfunc(EngFunc_WriteCoord, iOrigin[1] + random_float( -50.0, 50.0 )) // y
				engfunc(EngFunc_WriteCoord, iOrigin[2] + random_float( 5.0, 50.0 )) // z
				message_end();
			}
			
			/**	ICE CUBE **/
			static victim
			victim = -1
			
			while(( victim = engfunc( EngFunc_FindEntityInSphere, victim, iOrigin, 240.0 )) != 0){
				if( !is_user_alive( victim ) || !zp_get_user_zombie( victim ) || zp_get_user_nemesis( victim ) || zp_get_user_survivor( victim ))
					continue;
				
				set_task( 0.1, "task_ice_cube", victim );
				//xSmokeIceToxic[ entity ] = false;
			}
		}
	}
	
	return HAM_IGNORED;
}

public fw_TouchSmoke( entity, player ){
	if( !pev_valid( entity ))
		return HAM_IGNORED;
	
	if( !is_user_alive( player ))
		return HAM_IGNORED;
	
	static classname[ 64 ];
	pev( entity, pev_classname, classname, charsmax( classname ));
	
	if( equal( classname, GRENADE_INFECT_CLASSNAME )){
		if( zp_get_user_nemesis( player ) || zp_get_user_survivor( player ))
			return HAM_IGNORED;
				
		if( zp_get_user_zombie( player )){
			xPlayerHealthType[ player ] = 1;
			xPlayerHealthStart[ player ] = true;
			set_task( 2.0, "SmokeInfectHealth", TASK_INFECT_HEALTH+player, _, _, "b");
		}
			
		else {
			//client_print( player, print_chat, "debug 1")
		}
	}

	return HAM_IGNORED;
}

public SmokeInfectHealth( index ){
	index -= TASK_INFECT_HEALTH;
	
	if( !is_user_connected( index ) && !is_user_alive( index ))
		return PLUGIN_HANDLED;
	
	static iHealth;
	pev( index, pev_health, iHealth );
	switch( xPlayerHealthType[ index ] ){
		case 1: {		
			if( iHealth < xPlayerFirstHealth[ index ] && !xPlayerHealthStart[ index ]){
				set_pev( index, pev_health, iHealth + 10.0 );
				//client_print( index, print_chat, "debug 2")
			}
			
			else if( xPlayerHealthStart[ index ]){
				xPlayerHealthStart[ index ] = false;
			}
		}
		
		case 2: set_pev( index, pev_health, iHealth - 10.0 )
	}
	
	return PLUGIN_HANDLED;
}

public fwd_PreThink( player ){
	if( !is_user_connected( player ))
		return HAM_IGNORED;
	
	if( !is_user_alive( player ))
		return HAM_IGNORED;
			
	new Float:iOriginPlayer[ 3 ];
	pev( player, pev_origin, iOriginPlayer );
    
	new iSmokeIce = -1;
	while(( iSmokeIce = fm_find_ent_in_sphere( iSmokeIce, iOriginPlayer, 60.0 ))){
		static iClassname[32];
		pev( iSmokeIce, pev_classname, iClassname, sizeof( iClassname ))
		
		/** GRANADA DE INFECÇÃO **/
		if( equal( iClassname, GRENADE_INFECT_CLASSNAME )){
			if( !zp_get_user_zombie( player ) || zp_get_user_nemesis( player ) || zp_get_user_survivor( player ))
				return HAM_IGNORED;
			
			if( !xSmokeInfectTime[ player ]){
				xTouchIn[ player ] = true;
				xTouchTime[ player ] = get_gametime();
				xSmokeInfectTime[ player ] = get_gametime();
					
				set_task(0.5, "SmokeInfectTask", TASK_SMOKE_INFECT_FREEZE+player, _, _, "b");
			}
				
			xSmokeInfectTime[ player ] = get_gametime();
			
			message_begin(MSG_ONE_UNRELIABLE, xMsgIDDamage, _, player)
			write_byte(0) // damage save
			write_byte(0) // damage take
			write_long(DMG_NERVEGAS)// damage type - DMG_FREEZE
			write_coord(0) // x
			write_coord(0) // y
			write_coord(0) // z
			message_end()
		}
		
		/** GRANADA DE GELO **/
		if( equal( iClassname, GRENADE_ICE_CLASSNAME )){
			if( !zp_get_user_zombie( player ) || zp_get_user_nemesis( player ) || zp_get_user_survivor( player ))
				return HAM_IGNORED;
			
			if( !xSmokeIceTime[ player ]){
				xTouchIn[ player ] = true;
				xTouchTime[ player ] = get_gametime();
				xSmokeIceTime[ player ] = get_gametime();
				
				set_task(0.5, "SmokeIceFrozenTask", TASK_SMOKEICE_FREEZE+player, _, _, "b");
			}
						
			message_begin(MSG_ONE_UNRELIABLE, xMsgIDDamage, _, player)
			write_byte(0) // damage save
			write_byte(0) // damage take
			write_long(DMG_DROWN) // damage type - DMG_FREEZE
			write_coord(0) // x
			write_coord(0) // y
			write_coord(0) // z
			message_end()
			
			xSmokeIceTime[ player ] = get_gametime();
		}
	}
	
	return HAM_IGNORED;
}

public SmokeInfectTask( iPlayer ){
	iPlayer -= TASK_SMOKE_INFECT_FREEZE;

	if( !is_user_connected( iPlayer ) && !is_user_alive( iPlayer )){
		remove_task( TASK_SMOKE_INFECT_FREEZE+iPlayer );
		return;
	}
	
	new Float:gametime = get_gametime();
	if(( gametime - xSmokeInfectTime[ iPlayer ]) > 0.5){
		xTouchTime[ iPlayer ] = 0.0;
		xSmokeInfectTime[ iPlayer ] = 0.0;
		xTouchIn[ iPlayer ] = false;
		
		remove_task( TASK_SMOKE_INFECT_FREEZE+iPlayer );
		return;
	}
	
	new iTimeLeft = 5 - floatround( gametime - xTouchTime[ iPlayer ]);
	if( iTimeLeft < 1 ){
		zp_infect_user( iPlayer, 0, 0, 0 );
		set_task( 1.0, "remove_smoke_infect", xSmokeInfectEnt[ SMOKEINFECT_GRANADA ]+TASK_REMOVE_SMOKE_INFECT );
		set_task( 3.0, "remove_smoke_infect", xSmokeInfectEnt[ SMOKEINFECT_FUMACA ]+TASK_REMOVE_SMOKE_INFECT );
	}
}

public SmokeIceFrozenTask( iPlayer ){
	iPlayer -= TASK_SMOKEICE_FREEZE;

	if( !is_user_connected( iPlayer )){
		remove_task( TASK_SMOKEICE_FREEZE+iPlayer );
		return;
	}
	
	new Float:gametime = get_gametime();
	if(( gametime - xSmokeIceTime[ iPlayer ]) > 0.5){
		xTouchTime[ iPlayer ] = 0.0;
		xSmokeIceTime[ iPlayer ] = 0.0;
		xTouchIn[ iPlayer ] = false;
		
		remove_task( TASK_SMOKEICE_FREEZE+iPlayer );
		return;
	}
	
	new iTimeLeft = 5 - floatround( gametime - xTouchTime[ iPlayer ]);
	if( iTimeLeft < 1 ){
		zp_set_user_frozen( iPlayer, 1 );
		set_task( 0.1, "task_ice_cube", iPlayer );
		set_task( 1.0, "remove_smokeice", xSmokeIceEnt[ SMOKEICE_GRANADA ]+TASK_REMOVE_SMOKEICE );
		set_task( 3.0, "remove_smokeice", xSmokeIceEnt[ SMOKEICE_FUMACA ]+TASK_REMOVE_SMOKEICE );
	}
}

/** SMOKE ICE *************************************************************/
public MakeSmokeIce( Float:Origin[3], Float:size, Float:speed ){
	static ent
	ent = create_entity("env_sprite");
	xSmokeIceEnt[ SMOKEICE_FUMACA ] = ent;
	
	entity_set_origin( ent, Origin);
	
	set_pev( ent, pev_takedamage, 0.0);
	entity_set_size( ent,Float:{0.0,0.0,0.0},Float:{30.0,30.0,30.0})
	entity_set_int(ent, EV_INT_solid, SOLID_TRIGGER)
	entity_set_int(ent, EV_INT_movetype, MOVETYPE_FLY)
	engfunc( EngFunc_SetModel, ent, frost_explode_sprite2 );
	entity_set_string( ent, EV_SZ_classname, SMOKE_ICE_CLASSNAME );
	
	set_pev( ent, pev_rendermode, kRenderTransAdd);
	set_pev( ent, pev_renderamt, 255.0);
	set_pev( ent, pev_light_level, 180);
	set_pev( ent, pev_scale, size );
	set_pev( ent, pev_animtime, get_gametime());
	set_pev( ent, pev_framerate, speed ); // velocidade da sprite
	set_pev( ent, pev_frame, 0.1);
	set_pev( ent, pev_spawnflags, SF_SPRITE_STARTON );
	entity_set_float( ent, EV_FL_gravity, 1.0 );
	
	dllfunc( DLLFunc_Spawn, ent );
	drop_to_floor(ent)
	set_task( 21.0, "remove_smokeice", ent+TASK_REMOVE_SMOKEICE );
	
	return ent
}

public MakeSmokeIceEnt( Float: Origin[3], color[3]){
	new ent = create_entity("info_target")
	xSmokeIceEnt[ SMOKEICE_GRANADA ] = ent;
	
	entity_set_origin( ent, Origin );
	entity_set_string( ent, EV_SZ_classname, GRENADE_ICE_CLASSNAME );
	entity_set_model( ent, smoke_granade );	
	entity_set_int( ent, EV_INT_solid, SOLID_TRIGGER );
	entity_set_size( ent,Float:{-10.0,-10.0,-10.0},Float:{10.0,10.0,10.0})
	entity_set_float( ent, EV_FL_gravity, 1.0 );
	drop_to_floor(ent)
	fm_set_user_rendering( ent, kRenderFxGlowShell, color[0], color[1], color[2], kRenderNormal, 16);
	set_task( 21.0, "remove_smokeice", ent+TASK_REMOVE_SMOKEICE );
}

public CreateSmokeIce(){
	MakeSmokeIce( xOriginSmokeIce, random_float(1.0, 1.5), 4.0 );
}

public remove_smokeice( entity ){
	entity -= TASK_REMOVE_SMOKEICE;
	
	if( pev_valid( entity )){
		remove_task( entity+TASK_REMOVE_SMOKEICE );
		remove_entity( entity );
	}
}

/** INFECT SMOKE ***************************************************************/
public MakeSmokeInfect( Float:Origin[3], Float:size, Float:speed ){
	static ent
	ent = create_entity("env_sprite");
	xSmokeInfectEnt[ SMOKEINFECT_FUMACA ] = ent;
	
	entity_set_origin( ent, Origin);
	
	set_pev( ent, pev_takedamage, 0.0);
	entity_set_size( ent,Float:{0.0,0.0,0.0},Float:{30.0,30.0,30.0})
	entity_set_int(ent, EV_INT_solid, SOLID_TRIGGER)
	entity_set_int(ent, EV_INT_movetype, MOVETYPE_FLY)
	engfunc( EngFunc_SetModel, ent, infect_smoke_sprite );
	entity_set_string( ent, EV_SZ_classname, SMOKE_INFECT_CLASSNAME );
	
	set_pev( ent, pev_rendermode, kRenderTransAdd);
	set_pev( ent, pev_renderamt, 255.0);
	set_pev( ent, pev_light_level, 180);
	set_pev( ent, pev_scale, size );
	set_pev( ent, pev_animtime, get_gametime());
	set_pev( ent, pev_framerate, speed ); // velocidade da sprite
	set_pev( ent, pev_frame, 0.1);
	set_pev( ent, pev_spawnflags, SF_SPRITE_STARTON );
	entity_set_float( ent, EV_FL_gravity, 1.0 );
	
	dllfunc( DLLFunc_Spawn, ent );
	drop_to_floor(ent)
	set_task( 21.0, "remove_smoke_infect", ent+TASK_REMOVE_SMOKE_INFECT );
	
	return ent
}

public MakeSmokeInfectEnt( Float: Origin[3], color[3]){
	new ent = create_entity("info_target")
	xSmokeInfectEnt[ SMOKEINFECT_GRANADA ] = ent;
	
	entity_set_origin( ent, Origin );
	entity_set_string( ent, EV_SZ_classname, GRENADE_INFECT_CLASSNAME );
	entity_set_model( ent, smoke_granade );	
	entity_set_int( ent, EV_INT_solid, SOLID_TRIGGER );
	entity_set_size( ent,Float:{-10.0,-10.0,-10.0},Float:{10.0,10.0,10.0})
	entity_set_float( ent, EV_FL_gravity, 1.0 );
	drop_to_floor(ent)
	fm_set_user_rendering( ent, kRenderFxGlowShell, color[0], color[1], color[2], kRenderNormal, 16);
	set_task( 21.0, "remove_smoke_infect", ent+TASK_REMOVE_SMOKE_INFECT );
}

public CreateSmokeInfect(){
	MakeSmokeInfect( xOriginSmokeInfect, random_float(1.0, 1.5), 4.0 );
}

public remove_smoke_infect( entity ){
	entity -= TASK_REMOVE_SMOKE_INFECT;
	
	if( pev_valid( entity )){
		remove_task( entity+TASK_REMOVE_SMOKE_INFECT );
		remove_entity( entity );
	}
}

stock UTIL_BeamCylinder1( Float:vOrigin[ 3 ], iSprite, iFramerate, iLife, iWidth, iAmplitude, iRed, iGreen, iBlue, iBright, iSpeed ){	
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
	write_byte( TE_BEAMCYLINDER );
	engfunc( EngFunc_WriteCoord, vOrigin[ 0 ] );
	engfunc( EngFunc_WriteCoord, vOrigin[ 1 ] );
	engfunc( EngFunc_WriteCoord, vOrigin[ 2 ] + 10 );
	engfunc( EngFunc_WriteCoord, vOrigin[ 0 ] );
	engfunc( EngFunc_WriteCoord, vOrigin[ 1 ] + 400 );
	engfunc( EngFunc_WriteCoord, vOrigin[ 2 ] + 400 );
	write_short( iSprite );
	write_byte( 0 );
	write_byte( iFramerate );
	write_byte( iLife );
	write_byte( iWidth );
	write_byte( iAmplitude );
	write_byte( iRed );
	write_byte( iGreen );
	write_byte( iBlue );
	write_byte( iBright );
	write_byte( iSpeed );
	message_end();
}

stock UTIL_SpriteTrail1( iEnt, iSprite, iCount, iLife, iScale, iVelocity, iVary ){
	new Float:vOrigin[ 3 ];
	pev( iEnt, pev_origin, vOrigin );
	
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
	write_byte( TE_SPRITETRAIL );
	engfunc( EngFunc_WriteCoord, vOrigin[ 0 ] );
	engfunc( EngFunc_WriteCoord, vOrigin[ 1 ] );
	engfunc( EngFunc_WriteCoord, vOrigin[ 2 ] + 100 );
	engfunc( EngFunc_WriteCoord, vOrigin[ 0 ] + random_float( -200.0, 200.0 ) );
	engfunc( EngFunc_WriteCoord, vOrigin[ 1 ] + random_float( -200.0, 200.0 ) );
	engfunc( EngFunc_WriteCoord, vOrigin[ 2 ] );
	write_short( iSprite );
	write_byte( iCount );
	write_byte( iLife );
	write_byte( iScale );
	write_byte( iVelocity );
	write_byte( iVary );
	message_end();
}

stock UTIL_Explosion1( Float:vOrigin[ 3 ], iSprite, iScale, iFramerate, Flags ){	
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
	write_byte( TE_EXPLOSION );
	engfunc( EngFunc_WriteCoord, vOrigin[ 0 ] );
	engfunc( EngFunc_WriteCoord, vOrigin[ 1 ] );
	engfunc( EngFunc_WriteCoord, vOrigin[ 2 ] );
	write_short( iSprite );
	write_byte( iScale );
	write_byte( iFramerate );
	write_byte( Flags );
	message_end();
}

stock UTIL_Smoke1( Float:vOrigin[ 3 ], iSprite, iScale, iFramerate ){	
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
	write_byte( TE_SMOKE );
	engfunc( EngFunc_WriteCoord, vOrigin[ 0 ] );
	engfunc( EngFunc_WriteCoord, vOrigin[ 1 ] );
	engfunc( EngFunc_WriteCoord, vOrigin[ 2 ] );
	write_short( iSprite );
	write_byte( iScale );
	write_byte( iFramerate );
	message_end();
}

stock UTIL_DLightHover1( Float:vOrigin[ 3 ], iRadius, iRed, iGreen, iBlue, iLife, iDecay ){
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
	write_byte( TE_DLIGHT );
	engfunc( EngFunc_WriteCoord, vOrigin[ 0 ] );
	engfunc( EngFunc_WriteCoord, vOrigin[ 1 ] );
	engfunc( EngFunc_WriteCoord, vOrigin[ 2 ] );
	write_byte( iRadius );
	write_byte( iRed );
	write_byte( iGreen );
	write_byte( iBlue );
	write_byte( iLife );
	write_byte( iDecay );
	message_end();
}
UTIL_DLight1( iOrigin, 80, FROST_COLORS, 100, 40 )
stock UTIL_DLight1( Float:vOrigin[ 3 ], iRadius, color[3], iLife, iDecay ){	
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
	write_byte( TE_DLIGHT );
	engfunc( EngFunc_WriteCoord, vOrigin[ 0 ] );
	engfunc( EngFunc_WriteCoord, vOrigin[ 1 ] );
	engfunc( EngFunc_WriteCoord, vOrigin[ 2 ] );
	write_byte( iRadius );
	write_byte( color[0] );
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
	write_byte(( 900.0 < 2) ? 3 : 0) // tempo que a luz ficara acesa ( EX: 10 = 1 segundo )
	message_end()
}

stock nade_effect3( Float: origin[3], color[3], radius, life, decay ){
	engfunc(EngFunc_MessageBegin, MSG_PAS, SVC_TEMPENTITY, origin, 0)
	write_byte(TE_DLIGHT) // TE id
	engfunc(EngFunc_WriteCoord, origin[0]) // x
	engfunc(EngFunc_WriteCoord, origin[1]) // y
	engfunc(EngFunc_WriteCoord, origin[2]) // z
	write_byte( radius ) // radius
	write_byte( color[0]) // r
	write_byte( color[1]) // g
	write_byte( color[2]) // b
	write_byte( life ) //life - 21 (EX: 10 Life =  1 segundo )
	write_byte(( float( decay ) < 2) ? 3 : 0) // tempo que a luz ficara acesa ( EX: 10 = 1 segundo )
	message_end()
}

/** EFEITO FUMAÇA E GIBS FLUTUANDO **/
stock nade_effect1( Float:originF[3], index, amount, life, scale, velocity, rvelocity ){
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
	write_byte(TE_SPRITETRAIL)
	engfunc(EngFunc_WriteCoord, originF[0]) // x
	engfunc(EngFunc_WriteCoord, originF[1]) // y
	engfunc(EngFunc_WriteCoord, originF[2] + 4.0) // z ( 4.0)
	engfunc(EngFunc_WriteCoord, originF[0] + random_float(-5.0, 5.0)) // x
	engfunc(EngFunc_WriteCoord, originF[1] + random_float(-5.0, 5.0)) // y
	engfunc(EngFunc_WriteCoord, originF[2] + 100.0) // z
	write_short(index)
	write_byte(amount)
	write_byte(life) 
	write_byte(scale) 
	write_byte(velocity)
	write_byte(rvelocity)
	message_end()
}

stock nade_effect4( Float:origin[3], index, count, scale, velocity, rvelocity ){
	
	static origin2[3]
	origin2[0] = floatround(origin[0]) + random_num(-75,75)
	origin2[1] = floatround(origin[1]) + random_num(-75,75)
	origin2[2] = floatround(origin[2]) + random_num(60,100)
	
	// essa parte faz alguns gibs flutuarem, preciso ve pra faze mais
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY, origin2 ) 
	write_byte(3) // 3
	write_coord(origin2[0])	// start position
	write_coord(origin2[1])
	write_coord(origin2[2])
	write_short(index) 
	write_byte(scale)		// byte (scale in 0.1's) 188 / 3
	write_byte(5)		// byte (framerate) / 5
	write_byte(14)		// byte flags / 14
	message_end()
	
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
	write_byte( 15 );
	write_coord( origin2[ 0 ] ); 	// start position (X)
	write_coord( origin2[ 1 ] ); 	// start position (Y)
	write_coord( origin2[ 2 ] + 40 ); // start position (Z)
	write_coord( origin2[ 0 ] ); 	// end position (X)
	write_coord( origin2[ 1 ] );	// end position (Y)
	write_coord( origin2[ 2 ] );	// end position (Z)
	write_short( index );	// sprite index
	write_byte( count );		// count
	write_byte( 200 );		// life in 0.1's
	write_byte( scale );		// scale in 0.1's
	write_byte( velocity );		// velocity along vector in 10's
	write_byte( rvelocity );		// randomness of velocity in 10's
	message_end();
}

stock nade_explosion( Float:originF[3], index, something1, something2 ){
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
	write_byte(TE_EXPLOSION)
	engfunc(EngFunc_WriteCoord, originF[0]) // x
	engfunc(EngFunc_WriteCoord, originF[1]) // y
	engfunc(EngFunc_WriteCoord, originF[2]) // z
	write_short(index)
	write_byte(something1)
	write_byte(something2)
	write_byte(TE_EXPLFLAG_NODLIGHTS | TE_EXPLFLAG_NOSOUND)
	message_end()
}

stock nade_effect2( Float:originF[3], color[3], radius, life, decals ){
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
	write_byte(TE_DLIGHT);
	engfunc(EngFunc_WriteCoord, originF[0]) // x
	engfunc(EngFunc_WriteCoord, originF[1]) // y
	engfunc(EngFunc_WriteCoord, originF[2] + 4.0) // z
	write_byte( radius ); // radius
	write_byte( color[0]) // red
	write_byte( color[1]) // green
	write_byte( color[2]) // blue
	write_byte( life ); // life
	write_byte( decals ); // decay rate
	message_end();
}

public task_ice_cube( id ){
	static Float: maxspeed;
	maxspeed = entity_get_float( id, EV_FL_maxspeed );
	
	if( maxspeed == 1.0 ){
		create_ice_cube( id );
		xPlayerFrozen[ id ] = true;
	}
}

public create_ice_cube( id ){
	if( !is_user_alive( id ) || !zp_get_user_zombie( id ) || zp_get_user_nemesis( id ))
		return PLUGIN_HANDLED;
	
	new Float:fOrigin[ 3 ]
	entity_get_vector( id, EV_VEC_origin, fOrigin );
	
	if( entity_get_int( id, EV_INT_flags)  & FL_DUCKING )
		fOrigin[2] -= 15.0;
	
	else fOrigin[2] -= 35.0;
	
	if( is_valid_ent( xIceCubeEnt[ id ]))
		entity_set_origin( xIceCubeEnt[ id ], fOrigin );
		
	else {
		new entity = create_entity("info_target")
		
		entity_set_string(entity, EV_SZ_classname, "info_ice_cube")
		
		entity_set_model(entity, ice_cube_model )
		entity_set_origin(entity, fOrigin)
		entity_set_size(entity, Float:{ -3.0, -3.0, -3.0 }, Float:{ 3.0, 3.0, 3.0 })
		
		entity_set_int(entity, EV_INT_solid, SOLID_NOT)
		entity_set_int(entity, EV_INT_movetype, MOVETYPE_FLY)
		
		set_rendering(entity, kRenderFxNone, 255, 255, 255, kRenderTransAdd, 255)
		
		entity_set_edict(entity, EV_ENT_owner, id)
		
		dllfunc(DLLFunc_Spawn, entity)
		
		xIceCubeEnt[id] = entity
	}
	
	return PLUGIN_HANDLED;
}

public remove_ice_cube( id ){
	if( !is_valid_ent( xIceCubeEnt[ id ]))
		return PLUGIN_HANDLED;
	
	remove_entity( xIceCubeEnt[ id ])
	xIceCubeEnt[ id ] = -1;
	xPlayerFrozen[ id ] = false;
	
	return PLUGIN_HANDLED;
}