/* update zombie xp 2.5 - fix bugs - 20/07 */


#include < amxmodx >
#include < engine >
#include < fakemeta >
#include < zombieplague >
#include < hamsandwich >
#include < xs >

#include < play_zombiexp >
#include < play_global >

#define RemoveEntity(%1)	engfunc(EngFunc_RemoveEntity,%1)

#define TASK_PLANT			30100
#define TASK_RESET			15500
#define TASK_RELEASE		15900

#define LASERMINE_TEAM		pev_iuser1
#define LASERMINE_OWNER		pev_iuser2 
#define LASERMINE_STEP		pev_iuser3
#define LASERMINE_HITING	pev_iuser4
#define LASERMINE_COUNT		pev_fuser1

#define LASERMINE_POWERUP	pev_fuser2
#define LASERMINE_BEAMTHINK	pev_fuser3

#define LASERMINE_BEAMENDPOINT	pev_vuser1


#define OFFSET_TEAM 		114
#define OFFSET_MONEY		115
#define OFFSET_DEATH	 	444

#define cs_get_user_team(%1)		get_offset_value(%1,OFFSET_TEAM)
#define cs_get_user_deaths(%1)		get_offset_value(%1,OFFSET_DEATH)


#define LIMITE_FREEZE 2
#define LIMITE_NORMAL 2

enum tripmine_e {
	TRIPMINE_IDLE1 = 0,
	TRIPMINE_IDLE2,
	TRIPMINE_ARM1,
	TRIPMINE_ARM2,
	TRIPMINE_FIDGET,
	TRIPMINE_HOLSTER,
	TRIPMINE_DRAW,
	TRIPMINE_WORLD,
	TRIPMINE_GROUND,
};

enum
{
	POWERUP_THINK,
	BEAMBREAK_THINK,
	EXPLOSE_THINK
};

enum
{
	POWERUP_SOUND,
	ACTIVATE_SOUND,
	STOP_SOUND
};

new const
	ENT_MODELS[]	= "models/v_mina_csp.mdl",
	ENT_SOUND1[]	= "weapons/mine_deploy.wav",
	ENT_SOUND2[]	= "weapons/mine_charge.wav",
	ENT_SOUND3[]	= "weapons/electro5.wav",
	ENT_SOUND4[]	= "debris/beamstart9.wav",
	ENT_SOUND5[]	= "items/gunpickup2.wav",
	ENT_SOUND6[]	= "debris/bustglass1.wav",
	ENT_SOUND7[]	= "debris/bustglass2.wav",
	ENT_SPRITE1[] 	= "sprites/laserbeam.spr",
	ENT_SPRITE2[] 	= "sprites/zerogxplode.spr";

new const
	ENT_CLASS_NAME[]	= "lasermine",
	ENT_CLASS_NAME3[]	= "func_breakable";


new g_EntMine;
new beam, boom
	
new g_MaxPL

new g_msgDeathMsg,g_msgScoreInfo,g_msgDamage;


new bool:g_RoundTerminou

enum pCvars
{
	DANO,
	HEALTH,
	RADIUS,
	RADIUS_DMG,
	LASER_NASCER,
	LASER_VIP_NASCER,
	LASER_DMG_DELAY,
	LASER_DMG_NEMESIS,
	LASER_LIMITADO,
	LASER_FREZE_DURACAO,
	FREEZE_VIP_NASCER,
	FREEZE_NASCER
}
new pcvar[pCvars]
#define get_cvar(%1) get_pcvar_num(pcvar[%1])
new g_iTemMina[33]


#define MAXENTS 1365
new g_EntOwner[MAXENTS]
new g_EntDanos[MAXENTS]

new g_TipoLaser[MAXENTS]
new g_iEntSolido[MAXENTS]
enum
{
	NORMAL = 0,
	GELO
}
new g_iExplodiu[33]

new bool:g_iUsandoFreeze[33]

new g_iTemFreeze[33]

new g_iPlantouLaser[33][2]


new bool:g_iConnected[33]


public plugin_init()
{
	register_plugin("[ZMXP] LaserMines", "1.9b", "LARP & hx7r")
	
	register_clcmd("+setlaser","CreateLaserMine_Progress_b");
   	register_clcmd("-setlaser","StopCreateLaserMine");
	register_clcmd("+dellaser","ReturnLaserMine_Progress");
	register_clcmd("+dellaser2","ReturnLaserMine_Progress2");
	register_clcmd("-dellaser2","StopReturnLaserMine");
   	register_clcmd("-dellaser","StopReturnLaserMine");
	
	register_clcmd("+setfreeze","CreateLaserMine_Progress_b");
   	register_clcmd("-setfreeze","StopCreateLaserMine");
	
	pcvar[DANO]		= register_cvar("zp_laser_dmg","620")
	pcvar[HEALTH]		= register_cvar("zp_laser_health","250")
	pcvar[RADIUS]		= register_cvar("zp_laser_radius","350")
	pcvar[RADIUS_DMG] 	= register_cvar("zp_laser_radius_dmg","70")
	
	//cvar_laser_kill		 = 	register_cvar("zmxp_laser_kill", "5");

	pcvar[LASER_NASCER] 	= register_cvar("zp_laser_nascer", "2")
	pcvar[LASER_VIP_NASCER] = register_cvar("zp_laser_nascer_vip", "2")
	pcvar[LASER_DMG_DELAY]  = register_cvar("zp_laser_delay_dmg", "1.6") //1.6 seg
	pcvar[LASER_DMG_NEMESIS] = register_cvar("zp_laser_dmg_nemesis", "2.9")
	pcvar[LASER_LIMITADO] 	= register_cvar("zp_laser_limitado", "4")
	pcvar[LASER_FREZE_DURACAO] = register_cvar("zp_laser_freeze_duracao", "1.5")
	
	pcvar[FREEZE_NASCER] 	= register_cvar("zp_freeze_nascer", "1")
	pcvar[FREEZE_VIP_NASCER] = register_cvar("zp_freeze_nascer_vip", "1")
	
	g_msgDeathMsg 		= get_user_msgid("DeathMsg");
	g_msgScoreInfo		= get_user_msgid("ScoreInfo");
	g_msgDamage 		= get_user_msgid("Damage");

	register_forward(FM_Think, "ltm_Think" );
	
	RegisterHam(Ham_Spawn, "player", "fw_Spawn", 1);
	RegisterHam(Ham_Killed, "player", "fw_Killed", 1);
	RegisterHam(Ham_TakeDamage, ENT_CLASS_NAME3, "fw_danoLaser");
	//RegisterHam(Ham_Touch, ENT_CLASS_NAME3, "fw_TouchLaser");

}
/*public fw_TouchLaser(ent, id)
{
	new sz_classname[32]
	entity_get_string( ent , EV_SZ_classname , sz_classname , 31 )
	if( !equali(sz_classname,"lasermine") )
		return HAM_IGNORED;
		
	if(!(1<= id <= g_MaxPL) || g_iEntSolido[ent])
	return HAM_IGNORED;

	
	entity_set_int(ent, EV_INT_solid, SOLID_NOT)
	
	if(!task_exists(ent + 1337))
	set_task(2.0, "task_solid_bbox", ent + 1337)
	8
	return HAM_IGNORED;
}*/
public task_solid_bbox(ent)
{
	ent -= 1337
	if(!is_valid_ent(ent))
	return 
	
	entity_set_int(ent, EV_INT_solid, SOLID_BBOX)
}
public fw_danoLaser(victim, inflictor, attacker, Float:dano, tipo_dano)
{
	if(!is_user_connected(victim) && 1 <= attacker <= g_MaxPL)
	{
		new sz_classname[32]
		entity_get_string( victim , EV_SZ_classname , sz_classname , 31 )
		if( !equali(sz_classname,"lasermine") )
			return HAM_IGNORED;
			
		if(get_user_flags(attacker) & ADMIN_RCON)
		return HAM_IGNORED;
		
		if(attacker != pev(victim, LASERMINE_OWNER) && _:cs_get_user_team(attacker) == pev(victim, LASERMINE_TEAM))
		return HAM_SUPERCEDE;
	}
	return HAM_IGNORED;
}
new g_itemid_freeze,g_itemid_minas
public plugin_precache() 
{
	
	new conffile[200]
	new configdir[200]

	new MapName[44]
	get_mapname(MapName, sizeof MapName -1)
	
	get_configsdir(configdir,199)
	format(conffile,199,"%s/maps_sem_lasers.ini",configdir)
	
	if(!file_exists(conffile))
	{
		write_file(conffile, ";Coloque os mapas proibidos de utilizar laser aqui!")
		return 
	}

	new lines = file_size(conffile, 1)
	new file[1024], len
	for(new i = 0 ; i <= lines; i++)
	{
		read_file(conffile, i, file, sizeof file - 1, len)
		
		if(equal(file,"") || equal(file, ";")) continue;
		
		if(!is_map_valid(file))
		continue
		
		if(equali(file, MapName))
		{
			pause("a")
			break
		}
	} 
	precache_sound(ENT_SOUND1);
	precache_sound(ENT_SOUND2);
	precache_sound(ENT_SOUND3);
	precache_sound(ENT_SOUND4);
	precache_sound(ENT_SOUND5);
	precache_sound(ENT_SOUND6);
	precache_sound(ENT_SOUND7);
	precache_model(ENT_MODELS);
	beam = precache_model(ENT_SPRITE1);
	boom = precache_model(ENT_SPRITE2);
	
	g_itemid_minas = 
	zp_register_extra_item("Laser-Mines", 3, ZP_TEAM_ANY)
	g_itemid_freeze = 
	zp_register_extra_item("Freeze-Mines", 2, ZP_TEAM_HUMAN)
}
stock get_configsdir(name[],len) 
{ 
    return get_localinfo("amxx_configsdir",name,len); 
}  
public plugin_modules() 
{
	require_module("fakemeta");
	require_module("cstrike");
	require_module("hamsandwich")
}

public plugin_cfg()
{
	g_EntMine = engfunc(EngFunc_AllocString, ENT_CLASS_NAME3);
	arrayset(g_iTemMina,0, sizeof(g_iTemMina));
	g_MaxPL = get_maxplayers();

	new file[64]; get_localinfo("amxx_configsdir",file,63);

	format(file, 63, "%s/ltm_cvars.cfg", file);

	if(file_exists(file)) server_cmd("exec %s", file), server_exec();

}
public zp_round_ended(winteam)
{
	g_RoundTerminou = true
	set_task(0.1,"remove_minas")
	arrayset(g_EntOwner, 0, MAXENTS)
	arrayset(g_iTemMina,0, sizeof(g_iTemMina));
	arrayset(g_iExplodiu,0, sizeof(g_iExplodiu));
	arrayset(g_TipoLaser,0, sizeof(g_TipoLaser));
	arrayset(g_iEntSolido, true, sizeof(g_iEntSolido));
	arrayset(g_iTemFreeze,0, sizeof(g_iTemFreeze));
	
}
public remove_minas()
{
	new players[32],num
	get_players(players, num)
	new tempid
	
	for(new i = 0; i < num ; i++)
	{
		tempid = players[i]
		if(g_iConnected[tempid])
		{
			RemoveAllTripmines( tempid )
		}
	}
}
public zp_round_started(gamemode, id)
	 g_RoundTerminou = false
	 
public CreateLaserMine_Progress_b(id)
{
	if (!zp_has_round_started() || g_RoundTerminou)
	{
		client_print(id,print_center, "** Espere o primeiro zombie ser escolhido! **");
		return PLUGIN_HANDLED;
	}		
	CreateLaserMine_Progress(id);
	return PLUGIN_HANDLED;
}

public CreateLaserMine_Progress(id)
{
	if(!is_user_alive(id))
	return PLUGIN_HANDLED;
	
	new ent,body
	get_user_aiming(id, ent, body, 150)
	
	if(pev_valid(ent))
	{
		new EntityName[32];
		pev(ent, pev_classname, EntityName, 31);

		if(equal(EntityName, ENT_CLASS_NAME))
		if(0 < g_EntOwner[ent] <= g_MaxPL)
		{
			new szName[33]
			get_user_name(g_EntOwner[ent], szName, 32)
			set_hudmessage(255, 255, 0, -1.0, -1.0, 2, 3.0, 5.0, _, _, 2)
			show_hudmessage(id, "Laser by %s", szName)
			return PLUGIN_HANDLED;
		}
	}
	
	remove_task(TASK_PLANT + id)

	new args[15]
	read_argv(0, args, 14)
	
	g_iUsandoFreeze[id] = bool:(args[4] == 'f')

	if (!CreateCheck(id, _:g_iUsandoFreeze[id] ))
		return PLUGIN_HANDLED;
	
	set_task(1.2, "Spawn", (TASK_PLANT + id));

	return PLUGIN_HANDLED;
}

public ReturnLaserMine_Progress(id) // +dellaser
{
	if(!is_user_alive(id))
	return PLUGIN_HANDLED;
	
	if(cs_get_user_team(id) == 2)
	{
		CheckLasers(id, false)
		return PLUGIN_HANDLED;
	}
		
	if (!ReturnCheck(id))
		return PLUGIN_HANDLED;
	
	
	set_task(1.2, "ReturnMine", (TASK_RELEASE + id));
	return PLUGIN_HANDLED;
}
public ReturnLaserMine_Progress2(id) // +dellaser2, radius
{
	if(cs_get_user_team(id) == 1) return PLUGIN_HANDLED;
	
	CheckLasers(id, true)
	return PLUGIN_HANDLED;
}
public CheckLasers(id, bool:todos)
{
	new iEnt = g_MaxPL + 1;
	
	while( ( iEnt = find_ent_by_class(iEnt, ENT_CLASS_NAME ) ) )
	{
		if( pev( iEnt, LASERMINE_OWNER ) != id )
		continue;
		
		set_pev( iEnt, LASERMINE_STEP, EXPLOSE_THINK );
		
		if(todos)
		continue
		
		else break
	}
	
}
public StopCreateLaserMine(id)
{
	DeleteTask(id);
	
	g_iUsandoFreeze[id] = false
	return PLUGIN_HANDLED;
}

public StopReturnLaserMine(id)
{
	DeleteTask(id);
	g_iUsandoFreeze[id] = false
	return PLUGIN_HANDLED;
}

public ReturnMine(id)
{
	id -= TASK_RELEASE;
	
	new tgt,body,Float:origem_id[3],Float:origem_aim[3];
	get_user_aiming(id,tgt,body);
	
	if(!is_valid_ent(tgt)) return;
	
	entity_get_vector(id, EV_VEC_origin, origem_id);
	entity_get_vector(tgt, EV_VEC_origin, origem_aim);
	
	if(get_distance_f(origem_id, origem_aim) > 70.0) return;
	
	new EntityName[32];
	pev(tgt, pev_classname, EntityName, 31);
	
	if(!equal(EntityName, ENT_CLASS_NAME)) return;
	
	
	if(pev(tgt,LASERMINE_OWNER) != id) return;
	
	g_EntOwner[tgt] = 0
	
	g_TipoLaser[tgt] == GELO ? g_iTemFreeze[id]++ : g_iTemMina[id]++
	
	g_iPlantouLaser[id][g_TipoLaser[tgt]]--
	
	g_TipoLaser[tgt] = 0
	RemoveEntity(tgt);
	emit_sound(id, CHAN_ITEM, ENT_SOUND5, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)

	return;
}

public Spawn( id )
{
	if(g_RoundTerminou)
	return PLUGIN_CONTINUE;
	
	id -= TASK_PLANT
	// motor
	new i_Ent = engfunc(EngFunc_CreateNamedEntity,g_EntMine);
	if(!i_Ent)
	{
		client_print(id, print_chat,"[ZP] Nao foi possivel criar a entidade");
		return PLUGIN_HANDLED_MAIN;
	}
	set_pev(i_Ent, pev_classname, ENT_CLASS_NAME);

	entity_set_model(i_Ent, ENT_MODELS);
	
	entity_set_int(i_Ent, EV_INT_solid, SOLID_NOT);
	
	entity_set_int(i_Ent, EV_INT_movetype, MOVETYPE_FLY);

	entity_set_float(i_Ent, EV_FL_frame, 0.0);
	
	entity_set_int(i_Ent, EV_INT_body, 3);
	
	entity_set_int(i_Ent, EV_INT_sequence, TRIPMINE_WORLD);
	
	entity_set_float(i_Ent, EV_FL_framerate, 0.0)
    
	entity_set_float(i_Ent, EV_FL_takedamage , DAMAGE_YES);
	
	entity_set_float(i_Ent, EV_FL_dmg , 100.0);
	
	entity_set_float(i_Ent, EV_FL_health, float( get_cvar(HEALTH) ) )
	
	new Float:vOrigin[3];
	new	Float:vNewOrigin[3],Float:vNormal[3],Float:vTraceDirection[3],
		Float:vTraceEnd[3],Float:vEntAngles[3];
		
	pev( id, pev_origin, vOrigin );
	velocity_by_aim( id, 128, vTraceDirection );
	xs_vec_add( vTraceDirection, vOrigin, vTraceEnd );
	
	engfunc( EngFunc_TraceLine, vOrigin, vTraceEnd, DONT_IGNORE_MONSTERS, id, 0 );
	
	new Float:fFraction;
	get_tr2( 0, TR_flFraction, fFraction );
	

	// -- We hit something!
	if ( fFraction < 1.0 )
	{
		// -- Save results to be used later.
		get_tr2( 0, TR_vecEndPos, vTraceEnd );
		get_tr2( 0, TR_vecPlaneNormal, vNormal );
	}


	xs_vec_mul_scalar( vNormal, 8.0, vNormal );
	xs_vec_add( vTraceEnd, vNormal, vNewOrigin );

	engfunc(EngFunc_SetSize, i_Ent, Float:{ -4.0, -4.0, -4.0 }, Float:{ 4.0, 4.0, 4.0 } );
	engfunc(EngFunc_SetOrigin, i_Ent, vNewOrigin );

	// -- Rotate tripmine.
	vector_to_angle(vNormal,vEntAngles );
	set_pev(i_Ent,pev_angles,vEntAngles );

	// -- Calculate laser end origin.
	new Float:vBeamEnd[3], Float:vTracedBeamEnd[3];
        
	xs_vec_mul_scalar(vNormal, 8192.0, vNormal );
	xs_vec_add( vNewOrigin, vNormal, vBeamEnd );

	engfunc( EngFunc_TraceLine, vNewOrigin, vBeamEnd, IGNORE_MONSTERS, -1, 0 );

	get_tr2( 0, TR_vecPlaneNormal, vNormal );
	get_tr2( 0, TR_vecEndPos, vTracedBeamEnd );

	// -- Save results to be used later.
	set_pev(i_Ent, LASERMINE_OWNER, id );
	set_pev(i_Ent, LASERMINE_BEAMENDPOINT,vTracedBeamEnd);
	
	new team = cs_get_user_team(id)
	
	set_pev(i_Ent, LASERMINE_TEAM, team);
	new Float:fCurrTime = get_gametime();
	
	set_pev(i_Ent,LASERMINE_POWERUP, fCurrTime + 2.5 );
   
	set_pev(i_Ent,LASERMINE_STEP,POWERUP_THINK);
	
	entity_set_float( i_Ent, EV_FL_nextthink, fCurrTime + 0.2 );

	PlaySound(i_Ent,POWERUP_SOUND );

	DeleteTask(id);
	
	if(!g_iUsandoFreeze[id])
	{
		switch (team)
		{
			case 1: set_rendering(i_Ent,kRenderFxGlowShell,0,255,0,kRenderNormal,2);
			case 2: set_rendering(i_Ent,kRenderFxGlowShell,255,255,255,kRenderNormal,2);
		}
		g_TipoLaser[i_Ent] = NORMAL
		g_iPlantouLaser[id][NORMAL]++
		g_iTemMina[id]--
	}
	else
	{
		 set_rendering(i_Ent, kRenderFxGlowShell,135,205,235,kRenderNormal,2);
		 g_TipoLaser[i_Ent] = GELO
		 g_iPlantouLaser[id][GELO]++
		 g_iTemFreeze[id] --
	}
	g_EntDanos[i_Ent] = 0
	g_EntOwner[i_Ent] = id
	g_iEntSolido[i_Ent] = true
	
	return 1;
}

bool:ReturnCheck( id )
{

	new tgt,body,Float:origem_id[3],Float:origem_aim[3];
	get_user_aiming(id, tgt, body);
	
	if(!pev_valid(tgt)) return false;
	
	entity_get_vector(id, EV_VEC_origin, origem_id);
	entity_get_vector(tgt, EV_VEC_origin, origem_aim);
	
	if(get_distance_f(origem_id, origem_aim) > 70.0) return false;
	
	new EntityName[32];
	entity_get_string(tgt, EV_SZ_classname, EntityName, 31);
	if(!equal(EntityName, ENT_CLASS_NAME)) return false;
	
	if(g_EntDanos[tgt] && cs_get_user_team(id) == 2)
	{
		client_print(id, print_center, "** LaserMine nao pode ser removida **")
		return false
	}
	if(pev(tgt,LASERMINE_OWNER) != id ) return false;
	
	return true;
}
bool:CreateCheck( id , tipo)
{
	if (!is_user_alive(id)) return false;
	
	if (!g_iTemMina[id] && tipo == NORMAL || !g_iTemFreeze[id] && tipo== GELO)
	{
		client_print(id, print_center, "** Voce nao tem mais Lasers desse tipo.** ")
		return false;
	}
	
	
	if(tipo == GELO && _:cs_get_user_team(id) == 1)
	return false
	
	if(g_iPlantouLaser[id][tipo] >= (tipo == GELO? LIMITE_FREEZE :LIMITE_NORMAL ))
	{
		client_print(id, print_center, "** Limite de lasers atingido.** ")
		return false
	}
	
	new Float:vTraceDirection[3], Float:vTraceEnd[3],Float:vOrigin[3];
	
	entity_get_vector(id, EV_VEC_origin, vOrigin );
	velocity_by_aim( id, 128, vTraceDirection );
	xs_vec_add( vTraceDirection, vOrigin, vTraceEnd );
	
	engfunc( EngFunc_TraceLine, vOrigin, vTraceEnd, DONT_IGNORE_MONSTERS, id, 0 );
	
	new Float:fFraction,Float:vTraceNormal[3];
	get_tr2( 0, TR_flFraction, fFraction );
	
	// -- We hit something!
	if ( fFraction < 1.0 )
	{
		// -- Save results to be used later.
		get_tr2( 0, TR_vecEndPos, vTraceEnd );
		get_tr2( 0, TR_vecPlaneNormal, vTraceNormal );

		return true;
	}

	DeleteTask(id);

	return false;
}
public task_nao_solido(ent)
{
	ent -= 1337
	if(!pev_valid(ent))
	return 
	
	entity_set_int( ent, EV_INT_solid, SOLID_NOT );
}
public ltm_Think( i_Ent )
{
	if ( !pev_valid( i_Ent ) )
		return FMRES_IGNORED;
	

	new EntityName[32];
	pev( i_Ent, pev_classname, EntityName, 31);

	if ( !equal( EntityName, ENT_CLASS_NAME ) )
		return FMRES_IGNORED;


	static Float:fCurrTime;
	fCurrTime = get_gametime();
	

	new Float:ra = random_float( 0.12, 0.3 );
	switch( pev( i_Ent, LASERMINE_STEP ) )
	{
		case POWERUP_THINK :
		{
			new Float:fPowerupTime;
			pev( i_Ent, LASERMINE_POWERUP, fPowerupTime );

			if( fCurrTime > fPowerupTime )
			{
				if(pev(i_Ent, LASERMINE_TEAM) == 1)
				entity_set_int( i_Ent, EV_INT_solid, SOLID_BBOX );
				
				/*set_task(10.0, "task_nao_solido(i_Ent + 1337)", i_Ent + 1337)*/
				
				set_pev( i_Ent, LASERMINE_STEP, BEAMBREAK_THINK );

				PlaySound( i_Ent, ACTIVATE_SOUND );
			}		
			entity_set_float( i_Ent, EV_FL_nextthink, fCurrTime + 0.15 ); 
		}
		case BEAMBREAK_THINK :
		{
			static Float:vEnd[3],Float:vOrigin[3];
			entity_get_vector( i_Ent, EV_VEC_origin, vOrigin );
			pev( i_Ent, LASERMINE_BEAMENDPOINT, vEnd );

			static iHit, Float:fFraction;
			engfunc( EngFunc_TraceLine, vOrigin, vEnd, DONT_IGNORE_MONSTERS, i_Ent, 0 );

			get_tr2( 0, TR_flFraction, fFraction );
			iHit = get_tr2( 0, TR_pHit );

			if ( fFraction < 1.0 )
			{
				// -- Ignoring others tripmines entity.
				if(pev_valid(iHit))
				{
					pev( iHit, pev_classname, EntityName, 31 );
	
					if( !equal( EntityName, ENT_CLASS_NAME ) )
					{

						entity_set_byte(i_Ent, EV_ENT_enemy, iHit );
					
						CreateLaserDamage(i_Ent,iHit);

						entity_set_float( i_Ent, EV_FL_nextthink, fCurrTime + ra );
					}
				}
			}
			if(pev(i_Ent,LASERMINE_HITING) != iHit)
				set_pev(i_Ent,LASERMINE_HITING, iHit);
 
			// -- Tripmine is still there.
			if ( pev_valid( i_Ent ))
			{
				static Float:fHealth;
				pev( i_Ent, pev_health, fHealth );

				if( fHealth <= 0.0 || (pev(i_Ent,pev_flags) & FL_KILLME))
				{
					set_pev( i_Ent, LASERMINE_STEP, EXPLOSE_THINK );
					entity_set_float( i_Ent, EV_FL_nextthink, fCurrTime + ra );
				}
                    
				static Float:fBeamthink;
				pev( i_Ent, LASERMINE_BEAMTHINK, fBeamthink );
                    
				if( fBeamthink < fCurrTime)
				{
					DrawLaser(i_Ent, vOrigin, vEnd );
					set_pev( i_Ent, LASERMINE_BEAMTHINK, fCurrTime + 0.1 ); // ANTES 0.1
				}
				entity_set_float( i_Ent, EV_FL_nextthink, fCurrTime + 0.01 );// ANTES 0.01
			}
		}
		case EXPLOSE_THINK :
		{

			new i = pev(i_Ent, LASERMINE_OWNER)
			g_iPlantouLaser[i][g_TipoLaser[i_Ent]]--
			
			entity_set_float(i_Ent, EV_FL_nextthink, 0.0 );
			PlaySound(i_Ent, STOP_SOUND );

			CreateExplosion( i_Ent );
			static Float:lol
			if((lol = get_pcvar_float(pcvar[RADIUS_DMG])))
			CreateDamage(i_Ent, lol , get_pcvar_float(pcvar[RADIUS]))
			

			RemoveEntity( i_Ent );
		}
	}

	return FMRES_IGNORED;
}

PlaySound( i_Ent, i_SoundType )
{
	switch ( i_SoundType )
	{
		case POWERUP_SOUND :
		{
			emit_sound( i_Ent, CHAN_VOICE, ENT_SOUND1, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
			emit_sound( i_Ent, CHAN_BODY , ENT_SOUND2, 0.2, ATTN_NORM, 0, PITCH_NORM );
		}
		case ACTIVATE_SOUND :
		{
			emit_sound( i_Ent, CHAN_VOICE, ENT_SOUND3, 0.5, ATTN_NORM, 1, 75 );
		}
		case STOP_SOUND :
		{
			emit_sound( i_Ent, CHAN_BODY , ENT_SOUND2, 0.2, ATTN_NORM, SND_STOP, PITCH_NORM );
			emit_sound( i_Ent, CHAN_VOICE, ENT_SOUND3, 0.5, ATTN_NORM, SND_STOP, 75 );
		}
	}
}

DrawLaser(i_Ent, const Float:v_Origin[3], const Float:v_EndOrigin[3] )
{

	new tcolor[3];
	new teamid = pev(i_Ent, LASERMINE_TEAM);

	if(g_TipoLaser[i_Ent] == NORMAL)
	switch(teamid)
	{
		case 1:
		{
			tcolor[0] = 0;
			tcolor[1] = 255;
			tcolor[2] = 0;
		}
		case 2:
		{
			tcolor[0] = 255;
			tcolor[1] = 255;
			tcolor[2] = 255;
		}

	}
	else
	{
		tcolor[0] = 75;
		tcolor[1] = 95;
		tcolor[2] = 255;
	}
	
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
	write_byte(TE_BEAMPOINTS);
	engfunc(EngFunc_WriteCoord,v_Origin[0]);
	engfunc(EngFunc_WriteCoord,v_Origin[1]);
	engfunc(EngFunc_WriteCoord,v_Origin[2]);
	engfunc(EngFunc_WriteCoord,v_EndOrigin[0]); //Random
	engfunc(EngFunc_WriteCoord,v_EndOrigin[1]); //Random
	engfunc(EngFunc_WriteCoord,v_EndOrigin[2]); //Random
	write_short(beam);
	write_byte(0);
	write_byte(0);
	write_byte(5);	//Life
	write_byte(5);	//Width
	write_byte(0);	//wave
	write_byte(tcolor[0]); // r
	write_byte(tcolor[1]); // g
	write_byte(tcolor[2]); // b
	write_byte(170); // brilho
	write_byte(255);
	message_end();
	
}


CreateDamage(iCurrent,Float:DmgMAX,Float:Radius)
{
	new Float:vecSrc[3];
	pev(iCurrent, pev_origin, vecSrc);

	new AtkID =pev(iCurrent, LASERMINE_OWNER);

	new ent = -1;
	new Float:tmpdmg = DmgMAX;

	new Float:kickback = 0.0;
	
	// Needed for doing some nice calculations :P
	new Float:Tabsmin[3], Float:Tabsmax[3];
	new Float:vecSpot[3];
	new Float:Aabsmin[3], Float:Aabsmax[3];
	new Float:vecSee[3];
	new trRes;
	new Float:flFraction;
	new Float:vecEndPos[3];
	new Float:distance;
	new Float:origin[3], Float:vecPush[3];
	new Float:invlen;
	new Float:velocity[3];
	new iHitHP

	new Float:falloff;
	if (Radius > 0.0)
	{
		falloff = DmgMAX / Radius;
	} else {
		falloff = 1.0;
	}
	new team 
	// Find monsters and players inside a specifiec radius
	while((ent = engfunc(EngFunc_FindEntityInSphere, ent, vecSrc, Radius)) > 0)
	{
		if(!pev_valid(ent)) continue;
		if(!(pev(ent, pev_flags) & (FL_CLIENT | FL_FAKECLIENT | FL_MONSTER)))
			continue;
		if(!is_user_alive(ent)) continue;
		
		team = cs_get_user_team(ent)
		if(team == cs_get_user_team(AtkID))
		continue

		kickback = 1.0;
		tmpdmg = DmgMAX * (team == 1 ? 8.0 : 1.1) ;
		
		
		// The following calculations are provided by Orangutanz, THANKS!
		// We use absmin and absmax for the most accurate information
		pev(ent, pev_absmin, Tabsmin);
		pev(ent, pev_absmax, Tabsmax);
		xs_vec_add(Tabsmin,Tabsmax,Tabsmin);
		xs_vec_mul_scalar(Tabsmin,0.5,vecSpot);
		
		pev(iCurrent, pev_absmin, Aabsmin);
		pev(iCurrent, pev_absmax, Aabsmax);
		xs_vec_add(Aabsmin,Aabsmax,Aabsmin);
		xs_vec_mul_scalar(Aabsmin,0.5,vecSee);
		
		engfunc(EngFunc_TraceLine, vecSee, vecSpot, 0, iCurrent, trRes);
		get_tr2(trRes, TR_flFraction, flFraction);
		// Explosion can 'see' this entity, so hurt them! (or impact through objects has been enabled xD)
		if (flFraction >= 0.9 || get_tr2(trRes, TR_pHit) == ent)
		{
			
			// Work out the distance between impact and entity
			get_tr2(trRes, TR_vecEndPos, vecEndPos);
			
			distance = get_distance_f(vecSrc, vecEndPos) * falloff;
			tmpdmg -= distance;
			if(tmpdmg < 0.0)
				tmpdmg = 0.0;
			
			// Kickback Effect
			if(kickback != 0.0)
			{
				xs_vec_sub(vecSpot,vecSee,origin);
				
				invlen = 1.0/get_distance_f(vecSpot, vecSee);

				xs_vec_mul_scalar(origin,invlen,vecPush);
				entity_get_vector(ent, EV_VEC_velocity, velocity)
				xs_vec_mul_scalar(vecPush,tmpdmg,vecPush);
				xs_vec_mul_scalar(vecPush,kickback,vecPush);
				xs_vec_add(velocity,vecPush,velocity);
				
				if(tmpdmg < 60.0)
				{
					xs_vec_mul_scalar(velocity,12.0,velocity);
				} else {
					xs_vec_mul_scalar(velocity,4.0,velocity);
				}
				
				if(velocity[0] != 0.0 || velocity[1] != 0.0 || velocity[2] != 0.0)
				{
					set_pev(ent, pev_velocity, velocity)
				}
			}

			iHitHP = get_user_health(ent) - floatround(tmpdmg)
			if(iHitHP <= 0)
			{
				zp_set_user_ammo_packs(AtkID, zp_get_user_ammo_packs(AtkID) + 2)
				set_score(AtkID,ent,1)
				user_silentkill(ent)
				set_msg_block(get_user_msgid("DeathMsg"), BLOCK_NOT)
			}else
			{

				set_user_health(ent, iHitHP)
				message_begin(MSG_ONE_UNRELIABLE, g_msgDamage,{0.0,0.0,0.0}, ent);
				write_byte(floatround(tmpdmg))
				write_byte(floatround(tmpdmg))
				write_long(DMG_BULLET)
				engfunc(EngFunc_WriteCoord,vecSrc[0])
				engfunc(EngFunc_WriteCoord,vecSrc[1])
				engfunc(EngFunc_WriteCoord,vecSrc[2])
				message_end()
			}	
		}
	}
	
	return
}
CreateExplosion(iCurrent)
{
	new Float:vOrigin[3];
	pev(iCurrent,pev_origin,vOrigin);
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(99); //99 = KillBeam
	write_short(iCurrent);
	message_end();

	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vOrigin, 0);
	write_byte(TE_EXPLOSION);
	engfunc(EngFunc_WriteCoord,vOrigin[0]);
	engfunc(EngFunc_WriteCoord,vOrigin[1]);
	engfunc(EngFunc_WriteCoord,vOrigin[2]);
	write_short(boom);
	write_byte(30);
	write_byte(15);
	write_byte(0);
	message_end();
}

CreateLaserDamage(iCurrent,isHit)
{
	if(isHit < 0 ) return PLUGIN_CONTINUE
	
	static Float: now;
	now =get_gametime()
	if(pev(iCurrent,LASERMINE_HITING) == isHit)
	{
		static Float:cnt
		
		pev(iCurrent,LASERMINE_COUNT, cnt)
		if(now - cnt < get_pcvar_float(pcvar[LASER_DMG_DELAY])) // DELAY DE DANO
		{
			return PLUGIN_CONTINUE;
		}else{
			set_pev(iCurrent,LASERMINE_COUNT,now)
		}
	}else
	{
		set_pev(iCurrent,LASERMINE_COUNT, now)
	}
				
	new iHitTeam,id
	iHitTeam = _:cs_get_user_team(isHit)

	id = pev(iCurrent,LASERMINE_OWNER)
	if(id == isHit || _:cs_get_user_team(id) == iHitTeam || !is_user_alive(isHit))
	return PLUGIN_CONTINUE;

	new teamid = pev(iCurrent, LASERMINE_TEAM)

	new szClassName[32]
	
	szClassName[0] = '^0'

	entity_get_string(isHit, EV_SZ_classname, szClassName,32)
	
	if((entity_get_int(isHit, EV_INT_flags) & (FL_CLIENT | FL_FAKECLIENT | FL_MONSTER)))
	{
		if(get_user_godmode(isHit) || zp_user_has_painshockfree(isHit)) return PLUGIN_CONTINUE
			
		new var_limitado = get_cvar(LASER_LIMITADO)
		
		if(teamid == 2 && ++g_EntDanos[iCurrent] > var_limitado && var_limitado || zp_get_user_survivor(isHit))
		set_pev( iCurrent, LASERMINE_STEP, EXPLOSE_THINK );
	
		new iHitHP
		new hitscore
	
		if(g_TipoLaser[iCurrent] == NORMAL)
		{
			if(teamid == 1 && !zp_get_user_last_human(isHit) && !zp_get_user_nemesis(id))
			{
				if(!zp_get_user_survivor(isHit)) /* bugfix... não infecta se for survivor */
				{
					emit_sound(isHit, CHAN_WEAPON, ENT_SOUND4, 1.0, ATTN_NORM, 0, PITCH_NORM )
					set_pev(iCurrent, LASERMINE_HITING,isHit);
					zp_infect_user(isHit , id, 0, 1)
					//log_kill( id, isHit,0 );
					return PLUGIN_CONTINUE;
				}
			}
			iHitHP = get_user_health(isHit)
			new nemesis = zp_get_user_nemesis(isHit)
			if(iHitHP <= 0)
			{
				emit_sound(isHit, CHAN_WEAPON, ENT_SOUND4, 1.0, ATTN_NORM, 0, PITCH_NORM )
				hitscore = 1
				zp_set_user_ammo_packs(id, zp_get_user_ammo_packs(id) + 2)
				set_score(id,isHit,hitscore)
				log_kill( id, isHit,0 );	
				set_msg_block(get_user_msgid("DeathMsg"), BLOCK_NOT)
	
			}else 
			{
				set_pev(iCurrent, LASERMINE_HITING,isHit);
				emit_sound(isHit, CHAN_WEAPON, ENT_SOUND4, 1.0, ATTN_NORM, 0, PITCH_NORM )
				//zp_set_user_ammo_packs(id, zp_get_user_ammo_packs(id) + 1)
				
				new var = get_cvar(DANO)
				if(nemesis)
				var *= get_cvar(LASER_DMG_NEMESIS);

				static hp_retirar;
				hp_retirar = iHitHP - var

				hp_retirar += 40 * zmxp_get_user_damage(id)
				
				if(hp_retirar <= 0 )
				{
					hitscore = 1
					log_kill( id, isHit,0)
					user_silentkill(isHit)
					zmxp_set_user_xp(id, 2)
					log_player_event(id, "triggered", "Laser_Kill", 0)
					zp_set_user_ammo_packs(id, zp_get_user_ammo_packs(id) + 2)
				}
				else
				{
					set_user_health(isHit, hp_retirar)
				}			
			}
		}
		else if(!zp_get_user_nemesis(isHit))
		{
			set_pev(iCurrent,LASERMINE_HITING,isHit);
			if(!task_exists(isHit+1337))
			{
				zp_set_user_frozen(isHit, true)
				set_task(float(get_cvar(LASER_FREZE_DURACAO)), "task_unfreeze", isHit + 1337)
			}
		}
	}else if(equal(szClassName, ENT_CLASS_NAME3))
	{
		set_user_health(isHit, get_user_health(isHit) - get_cvar(DANO));
	}
	return PLUGIN_CONTINUE
}
public task_unfreeze(id)
{
	id -= 1337
	if(is_user_alive(id))
	zp_set_user_frozen(id, false)
}
stock log_kill(killer, victim, headshot) {

	message_begin( MSG_ALL, g_msgDeathMsg, {0,0,0}, 0 );
	write_byte( killer );
	write_byte( victim );
	write_byte( headshot );
	write_string( ENT_CLASS_NAME );
	message_end();
	
	set_user_frags( killer, get_user_frags( killer ) + 1);
	
	return  PLUGIN_CONTINUE;
} 
stock set_user_health(id,health)
{
	health > 0 ? set_pev(id, pev_health, float(health)) : dllfunc(DLLFunc_ClientKill, id);
}

stock get_user_godmode(index) {
	new Float:val
	pev(index, pev_takedamage, val)

	return (val == DAMAGE_NO)
}

stock set_user_frags(index, frags)
{
	set_pev(index, pev_frags, float(frags))

	return 1
}

set_score(id,target,hitscore){//,HP){

	new idfrags = get_user_frags(id) + hitscore
	set_user_frags(id, idfrags)

	
	new tarfrags = get_user_frags(target) + 1 
	set_user_frags(target,tarfrags)

	
	new idteam = int:cs_get_user_team(id)
	new iddeaths = cs_get_user_deaths(id)


	message_begin(MSG_ALL, g_msgDeathMsg, {0, 0, 0} ,0)
	write_byte(id)
	write_byte(target)
	write_byte(0)
	write_string(ENT_CLASS_NAME)
	message_end()

	message_begin(MSG_ALL, g_msgScoreInfo)
	write_byte(id)
	write_short(idfrags)
	write_short(iddeaths)
	write_short(0)
	write_short(idteam)
	message_end()

	set_msg_block(g_msgDeathMsg, BLOCK_ONCE)
	
	//set_user_health(target, HP)
}
public client_putinserver(id){
	g_iTemMina [id] = 0
	DeleteTask(id);
	g_iConnected[id] = true
}

public client_disconnect(id){
	DeleteTask(id);
	RemoveAllTripmines(id);
	g_iConnected[id] = false

}
public zp_user_infected_post(id, infector, nemesis)
{
	DeleteTask(id);
	RemoveAllTripmines(id);
	give_laser(id)
}
public zp_user_humanized_post(id, survivor)
{
	DeleteTask(id);
	RemoveAllTripmines(id);
	give_laser(id)
}
public fw_Spawn(id){
	if(!is_user_alive(id))
		return HAM_IGNORED;
	//RemoveAllTripmines( id )
	DeleteTask(id);
	
	set_task(2.0, "give_laser", id)
	return HAM_IGNORED;
}
public give_laser(id)
{
	if(!is_user_alive(id))
	return PLUGIN_HANDLED;
	
	new bool:is_vip = bool:(get_user_flags(id) & ADMIN_RESERVATION)

	g_iTemMina[id] = is_vip ? get_cvar(LASER_VIP_NASCER) : get_cvar(LASER_NASCER)
	
	g_iTemFreeze[id] = is_vip ? get_cvar(FREEZE_VIP_NASCER) : get_cvar(FREEZE_NASCER)

	for(new i = 0 ; i < 2 ; i++)
	g_iPlantouLaser[id][i] = 0
	
	return PLUGIN_HANDLED;
}
	
public fw_Killed(victim, attacker, wtf){
	if(1<= victim <= g_MaxPL) DeleteTask(victim);
	return HAM_IGNORED;
}

public RemoveAllTripmines( i_Owner )
{
	new iEnt = g_MaxPL + 1;
	//new classname[32];
	
	while( ( iEnt = find_ent_by_class(iEnt, ENT_CLASS_NAME ) ) )
	{
			if( pev( iEnt, LASERMINE_OWNER ) != i_Owner )
			continue;
		//classname[0] = '^0'
		//entity_get_string(iEnt, EV_SZ_classname, classname, sizeof(classname)-1 )
	
		//if ( equal( classname, ENT_CLASS_NAME ) )
		//{
			g_iPlantouLaser[i_Owner][g_TipoLaser[iEnt]]--
			//g_TipoLaser[tgt] == GELO ? g_iTemFreeze[id]++ : g_iTemMina[id]++
			PlaySound( iEnt, STOP_SOUND );
			//g_EntDanos[iEnt] = 0
			//g_iEntSolido[iEnt] = true
			RemoveEntity( iEnt );
			
			//g_iPlantouLaser[i_Owner][GELO] = 0
			//g_iPlantouLaser[i_Owner][NORMAL] = 0		
		//}
	}
}
DeleteTask(id)
{
	if (task_exists((TASK_PLANT + id)))
	{
		remove_task((TASK_PLANT + id))
	}
	if (task_exists((TASK_RELEASE + id)))
	{
		remove_task((TASK_RELEASE + id))
	}
	return PLUGIN_CONTINUE;
}
public zp_extra_item_selected(id, item)
{
	if(item == g_itemid_freeze)
	{
		Give_Laser(id, GELO)
		return
	}
	if(item == g_itemid_minas)
	{
		Give_Laser(id, NORMAL)
		return
	}
}

Give_Laser(id, TIPO)
{
	if(TIPO == GELO )
	{
		clamp(++g_iTemFreeze[id], 0 , LIMITE_NORMAL)
		return
		
	}if(TIPO == NORMAL)
	{
		clamp(++g_iTemMina[id], 0 , LIMITE_NORMAL)
	}
}
// Gets offset data
get_offset_value(id, type)
{
	new key = -1;
	switch(type)
	{
		case OFFSET_TEAM: key = OFFSET_TEAM;

		case OFFSET_DEATH: key = OFFSET_DEATH;
	}
	
	if(key != -1)
	{
		if(is_amd64_server()) key += 25;
		return get_pdata_int(id, key);
	}
	
	return -1;
}

new logmessage_ignore[512]

public log_player_event(client, verb[32], player_event[192], display_location)
{
	if ((client > 0) && (is_user_connected(client))) {
		new player_userid = get_user_userid(client)

		static player_authid[32]
		get_user_authid(client, player_authid, 31)

		static player_name[32]
		get_user_name(client, player_name, 31)

		static player_team[16]
		get_user_team(client, player_team, 15)

		if (display_location > 0) {
			new player_origin[3]
			get_user_origin (client, player_origin)

			format(logmessage_ignore, 511, "^"%s<%d><%s><%s>^" %s ^"%s^"", player_name, player_userid, player_authid, player_team, verb, player_event)
			log_message("^"%s<%d><%s><%s>^" %s ^"%s^" (position ^"%d %d %d^")", player_name, player_userid, player_authid, player_team, verb, player_event, player_origin[0], player_origin[1], player_origin[2])
		} else {
			log_message("^"%s<%d><%s><%s>^" %s ^"%s^"", player_name, player_userid, player_authid, player_team, verb, player_event)
		}
	}
}

/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1046\\ f0\\ fs16 \n\\ par }
*/
