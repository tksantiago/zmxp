#include <amxmodx>
#include <colorchat>
#include <fakemeta_util>
#include <hamsandwich>
#include <zombieplague>

new const szVersao[] = "0.01"

new g_iTemBombaRelogio[33]

new g_pCvarTempoExplosao
new g_CachedStringInfoTarget
new g_bwEnt[33];
new const szModelBomba[] = "models/w_c4.mdl"

new g_iSprite
public plugin_precache()
{
	register_plugin("[ZMXP] Bomba-Relogio", szVersao, "hx7r")
	
	g_CachedStringInfoTarget = engfunc( EngFunc_AllocString, "info_target" );
	
	precache_model(szModelBomba)
	
	g_iSprite = precache_model("sprites/eexplo.spr");
}
public plugin_init() {
	
	RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamagePRE", 1) // para nao tiver morto..
	RegisterHam(Ham_Spawn, "player", "fw_SpawnPlayer", 1)
	g_pCvarTempoExplosao = register_cvar("zp_explosao_tempo", "3.0")

}
public fw_SpawnPlayer(id)
{
	 if(is_user_alive(id))
	 {
		g_iTemBombaRelogio[id] = 0
	 }
		
}
public client_disconnect(id) g_iTemBombaRelogio[id] = false

public fw_TakeDamagePRE(id, wtf, attacker, Float:damage, tipo_dano)
{
	if(!is_user_connected(attacker) || !is_user_alive(id))
		return HAM_IGNORED;
	
	if(!zp_get_user_last_human(attacker))
	return HAM_IGNORED;
	
	if(++g_iTemBombaRelogio[attacker] > 3)
		return HAM_IGNORED;
	if(get_user_weapon(attacker, _, _) != CSW_KNIFE)
	return HAM_IGNORED;
	
	if(zp_get_user_zombie(id) && (get_pdata_int(id, 114) != get_pdata_int(attacker, 114)))
	PrepararBomba(id, attacker)
	
	return HAM_IGNORED;
}

PrepararBomba(vitima, fdp)
{
	new iEnt = g_bwEnt[ vitima ];
	if( !pev_valid( iEnt ) ) {
		g_bwEnt[ vitima ] = iEnt = engfunc ( EngFunc_CreateNamedEntity, g_CachedStringInfoTarget );
		set_pev( iEnt, pev_movetype, MOVETYPE_FOLLOW );
		set_pev( iEnt, pev_body, vitima );
		engfunc( EngFunc_SetModel, iEnt, szModelBomba );
		
	}
	static szName[33]
	get_user_name(fdp, szName, sizeof szName -1)
	
	ColorChat(vitima, TEAM_COLOR, "Jogador^3 %s^1 plantou uma bomba em voce, run to the hills!" , szName)
	fm_set_user_rendering(vitima, kRenderFxNone, 0, 255, 0, kRenderGlow, 1)
	
	if(task_exists(iEnt + 1337))
	remove_task(iEnt + 1337)
	
	set_task(get_pcvar_float(g_pCvarTempoExplosao), "task_Explosao", vitima + 1337)
}
public zp_user_humanized_post(id, survivor)
{
	RemoveEntidade(id)
}
public RemoveEntidade(id)
{
	if(g_bwEnt[id])
		engfunc(EngFunc_RemoveEntity, g_bwEnt[ id ])
	g_bwEnt[ id ] = 0
}

public task_Explosao(id)
{
	id -= 1337
	if(!is_user_connected(id))
	return
	
	if(!g_bwEnt[id])
	return
	
	user_kill(id)

	g_bwEnt[id] = 0
	doExplosion(id)
	
}
doExplosion(ent) {
	new Float:origin[3]
	pev(ent, pev_origin, origin)
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY); 
	write_byte(TE_EXPLOSION);
	write_coord(floatround(origin[0])); 
	write_coord(floatround(origin[1]));      
	write_coord(floatround(origin[2]));
	write_short(g_iSprite);
	write_byte(80);
	write_byte(15); 
	write_byte(0); 
	message_end();
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1046\\ f0\\ fs16 \n\\ par }
*/
