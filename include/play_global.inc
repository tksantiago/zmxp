#if defined _play_global_included
  #endinput
#endif
#define _play_global_included

#if !defined _fakemeta_included
	#include <fakemeta>
#endif

#if !defined _hamsandwich_included
	#include <hamsandwich>
#endif

#define AUTHOR "Satelite"

#define xPrefix "BRGaMes!CS"
#define xWebSite "www.brgamescs.com.br"
#define xUrlSite "http://www.brgamescs.com.br/forum"
#define xMenuLine "------------------------------------"

/*
#define xPrefix "TsW-BR"
#define xWebSite "www.tswbr.com.br"
#define xUrlSite "http://www.tswbr.com.br/forum"
#define xMenuLine "------------------------------------"
*/

#define xHostName "MaxiGames"

/*
#define xPrefix "CSP Gaming"
#define xWebSite "www.cspgaming.com.br"
#define xUrlSite "http://www.cspgaming.com.br/forum"
#define xMenuLine "------------------------------------"
*/

#define MAX_PLAYERS 				32

#define SetBit(%1,%2)				%2 |= ( 1 << ( %1 & 31 ))
#define ClearBit(%1,%2)				%2 &= ~( 1<<( %1 & 31 ))
#define CheckBit(%1,%2)				( %2 &  1<<( %1 & 31 ))

#define PLAY_TEAM_ANY 				0
#define PLAY_TEAM_TR 				(1<<1)
#define PLAY_TEAM_CT 				(1<<2)

#define FFADE_IN					0x0000	// Just here so we don't pass 0 into the function
#define FFADE_OUT					0x0001	// Fade out (not in)
#define FFADE_MODULATE				0x0002	// Modulate (don't blend)
#define FFADE_STAYOUT				0x0004	//

#define HAS_DEFUSE_KIT				(1<<16)
#define DMG_GRENADE					(1<<24)

#define OFFSET_PDATA_SAFE				2
#define OFFSET_WPN_LINUX  				4
#define OFFSET_LINUX 					5
#define OFFSET_WEAPONOWNER 				41
#define OFFSET_WEAPONID					43
#define OFFSET_WPN_CLIP       			51
#define OFFSET_WEAPONCLIP				52
#define OFFSET_ARMORTYPE					112
#define OFFSET_CS_TEAMS					114
#define OFFSET_PRIMARY_WPN 				116
#define OFFSET_INTERNALMODEL				126
#define OFFSET_NVG 						129
#define OFFSET_BOMB_DEFUSE         		193
#define OFFSET_NEXTHUDTEXTARGSGAMETIME		198
#define OFFSET_ACTIVE_ITEM 				373
#define OFFSET_AMMO_SLOT					376
#define OFFSET_AMMO_AWP            		377
#define OFFSET_AMMO_SCOUT          		378
#define OFFSET_AMMO_M249                	379
#define OFFSET_AMMO_M4A1                	380
#define OFFSET_AMMO_M3                  	381
#define OFFSET_AMMO_USP                 	382
#define OFFSET_AMMO_FIVESEVEN           	383
#define OFFSET_AMMO_DEAGLE              	384
#define OFFSET_AMMO_P228               	 	385
#define OFFSET_AMMO_GLOCK18             	386
#define OFFSET_AMMO_FLASHBANG           	387
#define OFFSET_AMMO_HEGRENADE           	388
#define OFFSET_AMMO_SMOKEGRENADE        	389
#define OFFSET_AMMO_C4                  	390

#if cellbits == 32 
    #define OFFSET_CSMONEY         		115 
#else 
    #define OFFSET_CSMONEY         		140 
#endif 

#define fm_find_ent_in_sphere(%1,%2,%3) engfunc(EngFunc_FindEntityInSphere, %1, %2, %3)

#define OFFSET_MODEL_INDEX			491

static const _CSW_to_offset[] = {
	0, OFFSET_AMMO_P228, OFFSET_AMMO_SCOUT, OFFSET_AMMO_HEGRENADE, OFFSET_AMMO_M3, OFFSET_AMMO_C4, OFFSET_AMMO_USP, OFFSET_AMMO_SMOKEGRENADE,
	OFFSET_AMMO_GLOCK18, OFFSET_AMMO_FIVESEVEN, OFFSET_AMMO_USP, OFFSET_AMMO_M4A1, OFFSET_AMMO_M4A1, OFFSET_AMMO_M4A1, OFFSET_AMMO_USP, OFFSET_AMMO_GLOCK18,
	OFFSET_AMMO_AWP, OFFSET_AMMO_GLOCK18, OFFSET_AMMO_M249, OFFSET_AMMO_M3, OFFSET_AMMO_M4A1, OFFSET_AMMO_GLOCK18, OFFSET_AMMO_SCOUT, OFFSET_AMMO_FLASHBANG,
	OFFSET_AMMO_DEAGLE, OFFSET_AMMO_M4A1, OFFSET_AMMO_SCOUT, 0, OFFSET_AMMO_FIVESEVEN
};

enum {
	FM_CS_TEAM_UNASSIGNED = 0,
	FM_CS_TEAM_T,
	FM_CS_TEAM_CT,
	FM_CS_TEAM_SPECTATOR
};

enum {
	JAIL_TEAM_UNASSIGNED = 0,
	JAIL_TEAM_PRISS,
	JAIL_TEAM_GUARD,
	JAIL_TEAM_SPECTATOR,
	JAIL_TEAM_ALL
};

/*
#define PLAY_TEAM_UNASSIGNED 0
#define PLAY_TEAM_TR 1
#define PLAY_TEAM_CT 2
#define PLAY_TEAM_SPECTATOR 3
#define PLAY_TEAM_PRISS 4
#define PLAY_TEAM_GUARD 5
#define PLAY_TEAM_ZOMBIE 6
#define PLAY_TEAM_HUMANO 7
*/

enum {
	ZAS_TEAM_ALL = 0,
	ZAS_TEAM_ZOMBIE,
	ZAS_TEAM_HUMANO,
	ZAS_TEAM_SPECTATOR
};

enum {
	ZMXP_TEAM_ALL = 0,
	ZMXP_TEAM_ZOMBIE,
	ZMXP_TEAM_HUMANO,
	ZMXP_TEAM_SPECTATOR
};

enum {
	PLAY_MOD_NONE = 0,
	PLAY_MOD_4FUN,
	PLAY_MOD_JAIL,
	PLAY_MOD_ZMXP,
	PLAY_MOD_ZMAS
}


enum {
	MOD_NORMAL = 0, 		// 0
	MOD_DEATHMATCH, 		// 1
	MOD_TEAM_DEATHMATCH,   	// 2
	MOD_ZOMBIE_ORIGIN, 		// 3
	MOD_ZOMBIE_VANGUARD, 	// 4
	MOD_GUN_DEATHMATCH, 	// 5
	MOD_ZOMBIE_ESCAPE, 		// 6
	MOD_DEATHRUN, 			// 7
	MOD_NAO_SEI, 			// 8
	MOD_NAO_SEI2, 			// 9 
	MOD_ZOMBIE_HERO, 		// 10
	MOD_BASEBUILDER,		// 11 
	MOD_JAILBREAK			// 12
}

enum {
	FREE = 0,
	GOLD,
	CASH,
	GOLD_CASH
}

enum { LOG_ERROR = 1, LOG_OTHERS, LOG_SHOP, LOG_DAYS }


stock get_random_array( Array:array_name ){
	return random_num(0, ArraySize( array_name ) - 1);
}

stock delete_task( taskid ){
	if( task_exists( taskid ))
		remove_task( taskid );
}

stock PlaySound( index, const sound[]) {
	if( index == 0 ) {
		if( equal( sound[ strlen( sound ) -4 ], ".mp3")) {
			client_cmd( 0, "mp3 play ^"sound/%s^"", sound );
		}
		
		else {
			client_cmd( 0, "spk ^"%s^"", sound );
		}
	}
	
	else {
		if( is_user_connected( index ) && is_user_alive( index )){
			if( equal( sound[ strlen( sound ) - 4 ], ".mp3" )){
				client_cmd( index, "mp3 play ^"sound/%s^"", sound );
			}
			
			else {
				client_cmd( index, "spk ^"%s^"", sound );
			}
		}
	}
}

stock StopSound( index = 0 ){
	if( index == 0) {
		client_cmd(0, "mp3 stop; stopsound");
	}
	
	else {
		if(!is_user_connected( index ))
			return PLUGIN_HANDLED;
		
		client_cmd( index, "mp3 stop; stopsound");
	}
	
	return PLUGIN_CONTINUE;
}

stock PrintToChat( client, Text[]){
	client_print( client, print_chat, Text );
}

stock PrintToCenter( client, Text[]){
	client_print( client, print_center, Text );
}

enum {
	TIMER_NORM = 1,
	TIMER_REPEAT
}

stock CreateTimer( Float:iTimer, IHandle[], client, type ){
	switch( type ){
		case TIMER_REPEAT: set_task( iTimer, IHandle, client, _, _, "b");
		case TIMER_NORM: set_task( iTimer, IHandle, client );
	}
}


stock RegisterPlugin( plugin[], version[], author[]){
	new szTemp[ 64 ];
	formatex( szTemp, 63, "[ %s ] %s", xPrefix, plugin );
	
	register_plugin( szTemp, version, author );
}

/** PRECACHE *********************/
stock PrecacheSound( sound[] ){
	engfunc( EngFunc_PrecacheSound, sound );
}

stock PrecacheModel( model[] ){
	engfunc( EngFunc_PrecacheModel, model );
}

/** MENU CREATE ******************/
stock MenuCreate( title[], handler[]){
	new iTemp[ 512 ];
	
	formatex( iTemp, charsmax( iTemp ), "\d%s %s:", xPrefix, title );
	return menu_create( iTemp, handler );
}

/* REGISTER FORWARD **************/
enum {
	TraceLinePre = 1,
	TraceLinePost
}

stock RegisterForward( forwards, handle[]){
	switch( forwards ){
		case TraceLinePre: register_forward( FM_TraceLine, handle, false );
		case TraceLinePost: register_forward( FM_TraceLine, handle, true );
	}
}


/* REGISTER EVENTS ***************/
enum {
	RoundStartHLTV = 1,
	RoundStart,
	RoundEnd,
	ResetHud,
	
	SpawnPre,
	SpawnPost
}

stock RegisterEvent( event, handle[]){
	switch( event ){
		case RoundStartHLTV: register_event( "HLTV", handle, "a", "1=0", "2=0" );
		case RoundStart: register_logevent( handle, 2, "1=Round_Start" );
		case RoundEnd: register_logevent( handle, 2, "1=Round_End" );
		case ResetHud: register_event("ResetHUD", handle, "b");
		case SpawnPre: RegisterHam( Ham_Spawn, "player", handle, false );
		case SpawnPost: RegisterHam( Ham_Spawn, "player", handle, true );
	}
}

stock RegisterSay( szSay[], szFunction[]){
	new szTemp[ 64 ];
	formatex( szTemp, 63 , "say /%s", szSay );
	register_clcmd( szTemp, szFunction );
	
	formatex( szTemp, 63 , "say .%s", szSay );
	register_clcmd( szTemp, szFunction );
	
	formatex( szTemp, 63 , "say_team /%s", szSay );
	register_clcmd( szTemp, szFunction );
	
	formatex( szTemp, 63 , "say_team .%s", szSay );
	register_clcmd( szTemp, szFunction );
}


stock register_say( szSay[], szFunction[] ) {
	new szTemp[ 64 ];
	formatex( szTemp, 63 , "say /%s", szSay );
	register_clcmd( szTemp, szFunction );
	
	formatex( szTemp, 63 , "say .%s", szSay );
	register_clcmd( szTemp, szFunction );
	
	formatex( szTemp, 63 , "say_team /%s", szSay );
	register_clcmd( szTemp, szFunction );
	
	formatex( szTemp, 63 , "say_team .%s", szSay );
	register_clcmd( szTemp, szFunction );
}

/*
stock set_weapon_anim( id, anim ) {
	if(!is_user_alive(id))
		return
	
	set_pev(id, pev_weaponanim, anim)
	
	message_begin(MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, _, id)
	write_byte(anim)
	write_byte(pev(id,pev_body))
	message_end()
}
*/

stock fm_set_user_deaths(index, value){
	set_pdata_int(index, 444, value, 5)
}

stock fm_get_user_godmode(index) {
	new Float:val;
	pev(index, pev_takedamage, val);

	return (val == DAMAGE_NO);
}

stock fm_set_user_godmode(index, godmode = 0) {
	set_pev(index, pev_takedamage, godmode == 1 ? DAMAGE_NO : DAMAGE_AIM);

	return 1;
}

stock fm_set_user_money( id, money, flash = 1 ){ 
        set_pdata_int(id, OFFSET_CSMONEY, money, OFFSET_LINUX )

        message_begin(MSG_ONE, get_user_msgid("Money"), {0,0,0}, id)
        write_long(money)
        write_byte(flash)
        message_end()
}

stock fm_get_user_money(id) 
        return get_pdata_int(id, OFFSET_CSMONEY, OFFSET_LINUX)
     
stock set_weapon_anim(id, anim)
{
	if(!is_user_alive(id))
		return
		
	set_pev(id, pev_weaponanim, anim)
	
	message_begin(MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, _, id)
	write_byte(anim)
	write_byte(0)
	message_end()	
}

stock bool:fm_is_ent_visible(index, entity, ignoremonsters = 0) {
	new Float:start[3], Float:dest[3];
	pev(index, pev_origin, start);
	pev(index, pev_view_ofs, dest);
	xs_vec_add(start, dest, start);

	pev(entity, pev_origin, dest);
	engfunc(EngFunc_TraceLine, start, dest, ignoremonsters, index, 0);

	new Float:fraction;
	get_tr2(0, TR_flFraction, fraction);
	if (fraction == 1.0 || get_tr2(0, TR_pHit) == entity)
		return true;

	return false;
}

stock fm_give_item( index, const item[] ) {
	if( !equal( item, "weapon_", 7 ) && !equal( item, "ammo_", 5 ) && !equal( item, "item_", 5 ) )
		return 0;
	
	new ent = fm_create_entity( item );
	if( !pev_valid( ent ) )
		return 0;
	
	new Float:origin[ 3 ];
	pev( index, pev_origin, origin );
	set_pev( ent, pev_origin, origin );
	set_pev( ent, pev_spawnflags, pev( ent, pev_spawnflags ) | SF_NORESPAWN );
	dllfunc( DLLFunc_Spawn, ent );
	
	new save = pev( ent, pev_solid );
	dllfunc( DLLFunc_Touch, ent, index );
	if( pev( ent, pev_solid ) != save )
		return ent;
	
	fm_remove_entity( ent );
	
	return -1;
}

/*
stock fm_set_user_armor(index, armor) {
	set_pev(index, pev_armorvalue, float(armor));

	return 1;
}
*/

stock UTIL_Explosion( entity, iSprite, iScale, iFramerate, Flags ){	
	new Float:vOrigin[ 3 ];
	pev( entity, pev_origin, vOrigin );
	
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

stock UTIL_Smoke( entity, iSprite, iScale, iFramerate ){	
	new Float:vOrigin[ 3 ];
	pev( entity, pev_origin, vOrigin );
	
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

stock UTIL_DLightHover( entity, iRadius, iRed, iGreen, iBlue, iLife, iDecay ){
	new Float:vOrigin[ 3 ];
	pev( entity, pev_origin, vOrigin );
	
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

stock UTIL_DLight( entity, iRadius, color[3], iLife, iDecay ){	
	new Float:vOrigin[ 3 ];
	pev( entity, pev_origin, vOrigin );
	
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

stock UTIL_BeamCylinder( entity, iSprite, iFramerate, iLife, iWidth, iAmplitude, iRed, iGreen, iBlue, iBright, iSpeed ){	
	new Float:vOrigin[ 3 ];
	pev( entity, pev_origin, vOrigin );
	
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

stock UTIL_SpriteTrail( entity, iSprite, iCount, iLife, iScale, iVelocity, iVary ){
	new Float:vOrigin[ 3 ];
	pev( entity, pev_origin, vOrigin );
	
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

stock fm_cs_set_user_armor(client, armorvalue, CsArmorType:armortype){
	set_pdata_int( client, OFFSET_ARMORTYPE, _:armortype, OFFSET_LINUX );
	
	set_pev( client, pev_armorvalue, float(armorvalue));
	
	if( armortype != CS_ARMOR_NONE ){
		static ArmorType;
		if(ArmorType || (ArmorType = get_user_msgid("ArmorType"))){
			emessage_begin(MSG_ONE_UNRELIABLE, ArmorType, _, client);
			ewrite_byte((armortype == CS_ARMOR_VESTHELM) ? 1 : 0);
			emessage_end();
		}
	}
}

// if weapon index isn't passed then assuming that it's the current weapon
stock fm_get_user_weapon_entity(id, wid = 0) {
	new weap = wid, clip, ammo;
	if (!weap && !(weap = get_user_weapon(id, clip, ammo)))
		return 0;
	
	new class[32];
	get_weaponname(weap, class, sizeof class - 1);

	return fm_find_ent_by_owner(-1, class, id);
}

stock fm_cs_get_weapon_ent_owner(ent)
{
	// Prevent server crash if entity's private data not initalized
	if (pev_valid(ent) != OFFSET_PDATA_SAFE)
		return -1;
	
	return get_pdata_cbase(ent, OFFSET_WEAPONOWNER, OFFSET_WPN_LINUX);
}

stock Float: GetUnits( num ){
 	new Float:Feets = (num * 0.0254) * 3.2;
 	return Feets;
}

public Float:GetRealDistance(Float:vOrigin1[3], Float:vOrigin2[3]){
    //new Float:vOrigin1[3], Float:vOrigin2[3]
   // get_array_f(1, vOrigin1, 3)
    //get_array_f(2, vOrigin2, 3)
    
    new Float:hlunits = get_distance_f(vOrigin1, vOrigin2)
    new Float:units = hlunits * 0.0254 // meter
    new convert = get_param(3)

    switch (convert){
        case 0: units *= 39.3701    // inch
        case 1: units *= 3.2808 // foot
        case 2: units *= 1.0936 // yard
        case 3: units *= 0.001  // kilometer
        case 4: units *= 0.0006 // mile
    }
    
    return units
}

/*
stock fm_cs_get_weapon_ent_owner(ent){
	if (pev_valid(ent) != OFFSET_PDATA_SAFE)
		return -1;
	
	if( pev_valid( ent ) != 2 )
        return;
		
	return get_pdata_cbase(ent, OFFSET_WEAPONOWNER, OFFSET_WPN_LINUX )
}
*/

stock fm_cs_get_user_weapon( index, &clip=0, &ammo=0){
	static ent
	ent = get_pdata_cbase( index, 373, 5)
	
	if( !pev_valid( ent ))
		return -1;
	
	new wpnid
	wpnid = fm_cs_get_weapon_id( ent )
	clip = fm_cs_get_weapon_ammo( ent )
	if (wpnid != CSW_KNIFE) ammo = fm_cs_get_user_bpammo(index, wpnid)
	
	return wpnid;
}

stock fm_cs_get_weapon_id(entity){
	return get_pdata_int(entity, OFFSET_WEAPONID, OFFSET_WPN_LINUX );
}

stock fm_set_weapon_ammo(entity, amount){
	set_pdata_int(entity, OFFSET_WPN_CLIP, amount,  OFFSET_WPN_LINUX );
}

stock fm_cs_get_weapon_ammo(entity){
	return get_pdata_int(entity, OFFSET_WEAPONCLIP, OFFSET_WPN_LINUX );
}

stock fm_cs_get_user_bpammo(client, weapon){
	return get_pdata_int(client, _CSW_to_offset[weapon], OFFSET_LINUX );
}

stock fm_create_entity( const classname[] )
	return engfunc( EngFunc_CreateNamedEntity, engfunc( EngFunc_AllocString, classname ) );

stock fm_remove_entity( index )
	return engfunc( EngFunc_RemoveEntity, index );

stock fm_find_ent_by_class( index, const classname[] )
	return engfunc( EngFunc_FindEntityByString, index, "classname", classname );

stock fm_find_ent_by_owner( index, const classname[], owner, jghgtype = 0 ) {
	new strtype[ 11 ] = "classname", ent = index;
	switch( jghgtype ) {
		case 1: strtype = "target";
			case 2: strtype = "targetname";
		}
	
	while( ( ent = engfunc( EngFunc_FindEntityByString, ent, strtype, classname ) ) && pev( ent, pev_owner ) != owner ) {}
	
	return ent;
}

stock fm_set_entity_visibility(index, visible = 1) {
	set_pev(index, pev_effects, visible == 1 ? pev(index, pev_effects) & ~EF_NODRAW : pev(index, pev_effects) | EF_NODRAW);

	return 1;
}

new bool: xPlayerSilent[ MAX_PLAYERS+1 ];
stock fm_set_user_footsteps( index, set = 1 ){
    if( set ){
        set_pev( index, pev_flTimeStepSound, 999 );
        xPlayerSilent[ index ] = true;
    }
    
    else {
        set_pev( index, pev_flTimeStepSound, 400 );
        xPlayerSilent[ index ] = false;
    }
    
    return 1;
}

stock fm_get_user_frags( index ) {
    return pev( index, pev_frags );
}

stock fm_set_user_frags(index, frags) {
	set_pev(index, pev_frags, float(frags));
	
	return 1;
}

stock fm_set_entity_flags( index, flag, onoff ) {
	new flags = pev( index, pev_flags );
	if (( flags & flag ) > 0 )
		return onoff == 1 ? 2 : 1 + 0 * set_pev( index, pev_flags, flags - flag );
	else
		return onoff == 0 ? 2 : 1 + 0 * set_pev( index, pev_flags, flags + flag );
	
	return 0;
}

stock fm_get_user_noclip( index )
	return ( pev( index, pev_movetype ) == MOVETYPE_NOCLIP );
	
stock fm_set_user_gravity( index, Float:gravity = 1.0 ) {
	set_pev( index, pev_gravity, gravity );
	return 1;
}

stock fm_get_user_gravity( index )
	return pev( index, pev_gravity );

stock fm_cs_get_user_team( id )
	return get_pdata_int( id, OFFSET_CS_TEAMS, OFFSET_LINUX );

stock fm_cs_set_user_team( index, team ) {
	if( pev_valid( index ) != OFFSET_PDATA_SAFE ) {
		return 0;
	}
	
	switch( team ) {
		case 1: {
			new iDefuser = get_pdata_int( index, OFFSET_BOMB_DEFUSE );
			if( iDefuser & HAS_DEFUSE_KIT ) {
				iDefuser -= HAS_DEFUSE_KIT
				set_pdata_int( index, OFFSET_BOMB_DEFUSE, iDefuser );
				
				static const defuser[] = "defuser"			
				message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("StatusIcon"), _, index)
				write_byte(0)
				write_string(defuser)
				write_byte(0)
				write_byte(255)
				write_byte(0)
				message_end()
			}
			
			set_pdata_int( index, OFFSET_CS_TEAMS, 1)
			set_pdata_int( index, OFFSET_INTERNALMODEL, 4)
		}
		
		case 2: {
			if( pev( index, pev_weapons ) & ( 1 << CSW_C4 )) {
				engclient_cmd( index, "drop", "weapon_c4")
			}
			
			set_pdata_int( index, OFFSET_CS_TEAMS, 2 )
			set_pdata_int( index, OFFSET_INTERNALMODEL, 6 )
		}
	}
	
	dllfunc( DLLFunc_ClientUserInfoChanged, index, engfunc( EngFunc_GetInfoKeyBuffer, index ))
	
	static const szTeamNames[][] = {"TERRORIST", "CT"}
	message_begin(MSG_BROADCAST, get_user_msgid("TeamInfo"))
	write_byte(index)
	write_string(szTeamNames[team-1])
	message_end()
	
	return 1
}



stock fm_strip_user_weapons( index ){
	new iEnt = engfunc( EngFunc_CreateNamedEntity, engfunc( EngFunc_AllocString, "player_weaponstrip" ) );
	
	if( !pev_valid( iEnt ))
		return 0;
	
	dllfunc( DLLFunc_Spawn, iEnt );
	dllfunc( DLLFunc_Use, iEnt, index );
	engfunc( EngFunc_RemoveEntity, iEnt );
	
	return 1;
}

stock fm_set_user_rendering( entity, fx = kRenderFxNone, r = 255, g = 255, b = 255, render = kRenderNormal, amount = 40 ) {
	new Float:RenderColor[ 3 ];
	RenderColor[ 0 ] = float( r );
	RenderColor[ 1 ] = float( g );
	RenderColor[ 2 ] = float( b );
	
	set_pev( entity, pev_renderfx, fx );
	set_pev( entity, pev_rendercolor, RenderColor );
	set_pev( entity, pev_rendermode, render );
	set_pev( entity, pev_renderamt, float( amount ) );
	
	return 1;
}

/*
stock fm_set_rendering( entity, fx = kRenderFxNone, r = 255, g = 255, b = 255, render = kRenderNormal, amount = 16){
    new Float:color[3]
    color[0] = float(r)
    color[1] = float(g)
    color[2] = float(b)
    
    set_pev(entity, pev_renderfx, fx)
    set_pev(entity, pev_rendercolor, color)
    set_pev(entity, pev_rendermode, render)
    set_pev(entity, pev_renderamt, float(amount))
}
*/

stock fm_set_user_maxspeed( index, Float:speed = 250.0 ) {
	set_pev( index, pev_maxspeed, speed );
	return 1;
}

stock Float:fm_get_user_maxspeed(index) {
	new Float:speed;
	pev(index, pev_maxspeed, speed);

	return speed;
}

stock fm_set_user_health( index, Float:health = 100.0 ) {
	set_pev( index, pev_health, health );
	return 1;
}

stock fm_set_user_health2(id, health){
	( health > 0 ) ? set_pev( id, pev_health, float(health)) : dllfunc(DLLFunc_ClientKill, id);
}

stock fm_cs_set_user_model_index( index, value ){
	set_pdata_int( index, OFFSET_MODEL_INDEX, value, OFFSET_LINUX );
}

stock fm_cs_set_user_model( player, const modelname[]){
	//copy(g_player_model[player], sizeof g_player_model[] - 1,modelname)
	set_user_info( player, "model", modelname)
}


stock fm_cs_get_user_model(player, model[], len){
	get_user_info(player, "model", model, len)
}

stock fm_get_user_model( player, model[], len ){
	engfunc( EngFunc_InfoKeyValue, engfunc( EngFunc_GetInfoKeyBuffer, player ), "model", model, len );
}

#if defined CUSTOM_MODEL
new g_isCustomModel[ MAX_PLAYERS+1 ]
stock fm_reset_user_model( player ){
	g_isCustomModel[ player ] = false;
	dllfunc( DLLFunc_ClientUserInfoChanged, player, engfunc( EngFunc_GetInfoKeyBuffer, player ));
}
#endif

stock fm_set_user_noclip( index, noclip = 0 ) {
	set_pev( index, pev_movetype, noclip == 1 ? MOVETYPE_NOCLIP : MOVETYPE_WALK );
	return 1;
}

stock fm_get_aim_origin(index, Float:origin[3]) {
	new Float:start[3], Float:view_ofs[3];
	pev(index, pev_origin, start);
	pev(index, pev_view_ofs, view_ofs);
	xs_vec_add(start, view_ofs, start);

	new Float:dest[3];
	pev(index, pev_v_angle, dest);
	engfunc(EngFunc_MakeVectors, dest);
	global_get(glb_v_forward, dest);
	xs_vec_mul_scalar(dest, 9999.0, dest);
	xs_vec_add(start, dest, dest);

	engfunc(EngFunc_TraceLine, start, dest, 0, index, 0);
	get_tr2(0, TR_vecEndPos, origin);

	return 1;
}

stock fm_fakedamage(victim, const classname[], Float:takedmgdamage, damagetype) {
	new class[] = "trigger_hurt";
	new entity = fm_create_entity(class);
	if (!entity)
		return 0;

	new value[16];
	float_to_str(takedmgdamage * 2, value, sizeof value - 1);
	fm_set_kvd(entity, "dmg", value, class);

	num_to_str(damagetype, value, sizeof value - 1);
	fm_set_kvd(entity, "damagetype", value, class);

	fm_set_kvd(entity, "origin", "8192 8192 8192", class);
	fm_DispatchSpawn(entity);

	set_pev(entity, pev_classname, classname);
	fm_fake_touch(entity, victim);
	fm_remove_entity(entity);

	return 1;
}

stock fm_set_kvd(entity, const key[], const value[], const classname[] = "") {
	if (classname[0])
		set_kvd(0, KV_ClassName, classname);
	else {
		new class[32];
		pev(entity, pev_classname, class, sizeof class - 1);
		set_kvd(0, KV_ClassName, class);
	}

	set_kvd(0, KV_KeyName, key);
	set_kvd(0, KV_Value, value);
	set_kvd(0, KV_fHandled, 0);

	return dllfunc(DLLFunc_KeyValue, entity, 0);
}

stock fm_DispatchSpawn(entity)
	return dllfunc(DLLFunc_Spawn, entity)

stock fm_fake_touch(toucher, touched)
	return dllfunc(DLLFunc_Touch, toucher, touched)

/*
stock set_entity_anim(ent, anim, reset_frame)
{
	if(!pev_valid(ent)) return
	
	set_pev(ent, pev_animtime, get_gametime())
	set_pev(ent, pev_framerate, 1.0)
	if(reset_frame) set_pev(ent, pev_frame, 0.0)
	
	set_pev(ent, pev_sequence, anim)	
}
*/

/*
stock fm_cs_get_user_team( index ){
	return get_pdata_int( index, OFFSET_CS_TEAMS, OFFSET_LINUX );
}
*/

stock fm_strip_player_weapons( index ) {
	new ent = fm_create_entity( "player_weaponstrip" );
	if( !pev_valid( ent ))
		return 0;
	
	dllfunc( DLLFunc_Spawn, ent );
	dllfunc( DLLFunc_Use, ent, index );
	fm_remove_entity( ent );
	set_pdata_int( index, OFFSET_PRIMARY_WPN, 0, OFFSET_LINUX );
	
	return 1;
}

stock fm_cs_set_user_bpammo( index, weapon, ammo ){
        static offset;
        
        switch( weapon ) {
                case CSW_AWP: offset = OFFSET_AMMO_AWP;
                case CSW_SCOUT, CSW_AK47, CSW_G3SG1: offset = OFFSET_AMMO_SCOUT;
                case CSW_M249: offset = OFFSET_AMMO_M249;
                case CSW_M4A1, CSW_FAMAS, CSW_AUG, CSW_SG550, CSW_GALIL, CSW_SG552: offset = OFFSET_AMMO_M4A1;
                case CSW_M3, CSW_XM1014: offset = OFFSET_AMMO_M3;
                case CSW_USP, CSW_UMP45, CSW_MAC10: offset = OFFSET_AMMO_USP;
                case CSW_FIVESEVEN, CSW_P90: offset = OFFSET_AMMO_FIVESEVEN;
                case CSW_DEAGLE: offset = OFFSET_AMMO_DEAGLE;
                case CSW_P228: offset = OFFSET_AMMO_P228;
                case CSW_GLOCK18, CSW_MP5NAVY, CSW_TMP, CSW_ELITE: offset = OFFSET_AMMO_GLOCK18;
                case CSW_FLASHBANG: offset = OFFSET_AMMO_FLASHBANG;
                case CSW_HEGRENADE: offset = OFFSET_AMMO_HEGRENADE;
                case CSW_SMOKEGRENADE: offset = OFFSET_AMMO_SMOKEGRENADE;
                case CSW_C4: offset = OFFSET_AMMO_C4;
		
                default: return;
        }
        
        set_pdata_int( index, offset, ammo, OFFSET_LINUX );
}

stock fm_cs_set_weapon_ammo( entity, clip ){
        set_pdata_int( entity, OFFSET_WPN_CLIP, clip, OFFSET_WPN_LINUX );
}

stock fm_cs_get_current_weapon_ent( index ){
	if( pev_valid( index ) != OFFSET_PDATA_SAFE )
		return -1;
		
	return get_pdata_cbase( index, OFFSET_ACTIVE_ITEM, OFFSET_LINUX );	
}



stock UTIL_ScreenShake( index, segundos ){
	message_begin( MSG_ONE, get_user_msgid("ScreenShake"), {0,0,0}, index )
     
	write_short(0xFFFF)
	write_short((1<<12)*segundos)
	write_short(0xFFFF)
	message_end()
}

stock UTIL_ScreenFade( index, Timer, Time2, type, Colors[3], Alpha ) {	
	message_begin( MSG_ONE_UNRELIABLE, get_user_msgid("ScreenFade"), _, index );
	
	write_short((1<<12) * Timer)
	write_short((1<<12) * Time2)
	write_short(type) // 0 fade out - fade in
	
	write_byte(Colors[0])
	write_byte(Colors[1])
	write_byte(Colors[2])
	write_byte(Alpha)
	
	message_end()
}

native GetModRunning();

/* Pausadas para Testes, plugin global
stock set_lock_entity( index, entity ){
	entity_set_int( entity, EV_INT_iuser1, index );
}

stock set_unlock_entity( entity ){
	entity_set_int( entity, EV_INT_iuser1, 0 );
}

stock get_user_locker( entity ){
	return entity_get_int( entity, EV_INT_iuser1 );
}

stock is_moving_entity( entity ){
	entity_set_int( entity, EV_INT_iuser2, 1 );
}

stock un_moving_entity( entity ){
	entity_set_int( entity, EV_INT_iuser2, 0 );
}

stock is_user_moving( entity ){
	entity_get_int( entity, EV_INT_iuser2 ) == 1;
}

stock set_user_mover( index, entity ){
	entity_set_int( entity, EV_INT_iuser3, index );
}

stock un_set_user_mover( entity ){
	entity_set_int( entity, EV_INT_iuser3, 0 );
}

stock get_user_mover( entity ){
	return entity_get_int( entity, EV_INT_iuser3 );
}

stock set_last_user_mover( index, entity ){
	entity_set_int( entity, EV_INT_iuser4, index );
}

stock un_set_user_last_mover( entity ){
	entity_set_int( entity, EV_INT_iuser4, 0 );
}

stock get_last_user_mover( entity ){
	return entity_get_int( entity, EV_INT_iuser4 );
}
*/


#include "play4ever.inc/play_patentes.play"
#include "play4ever.inc/play_moeda.play"
//#include "play4ever.inc/play_arsenal.play" MUDANDO PRO PLAY_LOJA
//#include "play4ever.inc/play_costumes.play"
#include "play4ever.inc/play_shop.play"
#include "play4ever.inc/play_loja.play"
