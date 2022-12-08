#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <cstrike>
#include <hamsandwich>
#include <zombieplague>

#include < play_global >
#include < play_zombiexp >

// Flags
#define FLAG_A (1<<0)
#define FLAG_B (1<<1)
#define FLAG_C (1<<2)
#define FLAG_D (1<<3)
#define FLAG_E (1<<4)
#define FLAG_K (1<<10)

#define VERSION "2.0"

new const MESSAGE_TAG[] = "[CSP VIP]"

const ZV_PLUGIN_HANDLED = 97
enum _:items
{
	i_name[31],
	i_description[31],
	i_cost,
	i_team
}

new g_register_in_zp_extra
new g_zp_extra_item_number
new g_menu_close
new extra_items[items]
new Array:items_database
new g_registered_items_count
new g_forward_return
new g_extra_item_selected
new g_infecthealth, g_nemhealth, g_show_vips
new g_msgid_SayText, gServersMaxPlayers
new bool:g_iAlive[33]
new bool:g_UserConnected[33]

#define XTRA_OFS_PLAYER 5
#define m_iTeam 114
#define m_afButtonPressed 246
#define m_flFallVelocity 251

new bool:g_iVip[33]
//new g_iJumpCount[33], g_pCvarMaxFallVelocity, g_pCvarJumpVelocity

public plugin_init()
{
	register_plugin("[ZMXP] VIP Sistem", VERSION, "Satelite")
	RegisterHam(Ham_Spawn, "player", "check_alive", 1)
	RegisterHam(Ham_Killed, "player", "fw_PlayerKilled", 1)
	//RegisterHam(Ham_Player_Jump, "player", "Ham_Player_JumpPre")
	//register_event("ResetHUD", "HUDReset", "be")
	
	gServersMaxPlayers = get_maxplayers()
	g_msgid_SayText = get_user_msgid("SayText")
	
	g_nemhealth = register_cvar("zp_vip_nemextra", "1")
	g_infecthealth = register_cvar("zp_vip_infecthealth", "100")
	g_show_vips = register_cvar("zp_vip_show", "1")
	
	//g_pCvarMaxFallVelocity = register_cvar("mp_multijump_maxfallvelocity", "500")
	//g_pCvarJumpVelocity = register_cvar("mp_multijumps_jumpvelocity", "238.328157")
	//g_pCvarJumpVelocity = register_cvar("mp_multijumps_jumpvelocity", "268.328157")
	
	register_say("vm", "menu_open");
	register_say("vipmenu", "menu_open");
	register_say("menu", "menu_open");
	register_say("vips", "print_adminlist")
	register_say("vip", "ShowMotd")
	
	register_clcmd("vm", "menu_open");
	
	g_register_in_zp_extra = register_cvar("zp_vip_register_in_zp_extra", "1")
	g_menu_close = register_cvar("zp_vip_menu_close", "1")
	items_database = ArrayCreate(items)
	
	new temp[31]
	formatex(temp, 30, "*VIP* Extra Items")
	if(get_pcvar_num(g_register_in_zp_extra)) g_zp_extra_item_number = zp_register_extra_item(temp, 0, 0)
	g_extra_item_selected = CreateMultiForward("zv_extra_item_selected", ET_CONTINUE, FP_CELL, FP_CELL)
}

/*public Ham_Player_JumpPre(id)
{
	if(!g_iVip[id])
	return HAM_IGNORED;
	
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
}*/
	
/*public HUDReset()
{
	new players[32], pNum
	get_players(players, pNum, "a")

	for (new i = 0; i < pNum; i++)
	{
		new id = players[i]
		if (get_user_flags(id) & VIPACCES)
		{
			message_begin(MSG_ALL, get_user_msgid("ScoreAttrib"))
			write_byte(id)
			write_byte(4)
			message_end()
		}
	}
	return PLUGIN_HANDLED
}*/

public check_alive( id ){
	g_iAlive[ id ] = bool:is_user_alive( id );
}

public plugin_natives(){
	register_native("zv_register_extra_item", "native_zv_register_extra_item", 1)
}

public fw_PlayerKilled( victim, attacker ){
	if( is_user_alive( attacker ) && get_user_flags( attacker ) & ACCES_VIP ){
		if( zp_get_user_zombie( attacker ) && !( zp_get_user_nemesis( attacker ) && !get_pcvar_num( g_nemhealth ))){
			fm_set_user_health2( attacker, ( pev( attacker, pev_health ) + get_pcvar_num( g_infecthealth )))
		}
	}
	
	check_alive( victim );
}

public zp_user_infected_post( id, infector, nemesis ){
	if( get_user_flags( infector ) & ACCES_VIP ){
		fm_set_user_health2( infector, ( pev( infector, pev_health ) + get_pcvar_num( g_infecthealth )))
	}	
}

public client_putinserver( id ){
	g_UserConnected[ id ] = true

	g_iVip[id] = bool:( get_user_flags( id ) & ACCES_VIP )
	if( get_pcvar_num( g_show_vips ) == 1 && g_iVip[ id ]){
		new name[100]
		get_user_name(id, name, 100)
		Print(0, "^1 O jogador VIP^3 %s^1 conectou no servidor!", name)
	}
}

public zp_extra_item_selected(id, item_id)
	if(item_id == g_zp_extra_item_number)
		menu_open(id)

public menu_open(id){
	if(get_user_flags(id) & ACCES_VIP ) {
		vip_menu(id)
	}
	
	else Print(id, "^1 Voce nao eh um jogador VIP. Visite: %s", xWebSite )
	
	return PLUGIN_HANDLED
}
	
public vip_menu(id)
{
	if(g_registered_items_count == 0) {
		Print(id, "^1 Menu desativado...")
		return PLUGIN_HANDLED
	}
	new buttons_string[16], menu_string[31], menu
	formatex(menu_string, 30, "\rVIP's extra items:")
	menu = menu_create(menu_string, "vip_menu_handler")
	static i, menu_item[61], team_check, num[3], ammo_packs, check
	check = 0
	team_check = 0
	ammo_packs = zp_get_user_ammo_packs(id)
	if(zp_get_user_zombie(id) && !zp_get_user_nemesis(id)) team_check |= FLAG_A
	else if(!zp_get_user_zombie(id)) team_check |= FLAG_B
	else if(zp_get_user_nemesis(id)) team_check |= FLAG_C
	else if(zp_get_user_survivor(id)) team_check |= FLAG_D
	for(i=0; i < g_registered_items_count; i++) {
		ArrayGetArray(items_database, i, extra_items)
		if(extra_items[i_team] == 0 || team_check & extra_items[i_team]) {
			formatex(menu_item, 61, "%s \r[%s] %s[%d AMMO]", extra_items[i_name], extra_items[i_description], ammo_packs < extra_items[i_cost] ? "\r" : "\y", extra_items[i_cost])
			formatex(num, 2, "%d", i)
			menu_additem(menu, menu_item, num, 0)
			check++
		}
	}
	if(check == 0) {
		Print(id, "^1 Nao existe nenhum extra item para sua classe atual.")
		return 1
	}
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL)
	formatex(buttons_string, 15, "Proximo")
	menu_setprop(menu, MPROP_NEXTNAME, buttons_string)
	formatex(buttons_string, 15, "Voltar")
	menu_setprop(menu, MPROP_BACKNAME, buttons_string)
	formatex(buttons_string, 15, "Sair")
	menu_setprop(menu, MPROP_EXITNAME, buttons_string)
	menu_display(id, menu, 0)
	
	return 1
}
 
public vip_menu_handler(id, menu, item)
{
	if( item == MENU_EXIT )
	{
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}
	
	if( zp_get_user_zombie(id) || zp_get_user_nemesis(id) )
	{
		Print(id, "^1 Esse bug foi corrigido.")
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}
	
	new data[6], iName[64], item_id, ammo_packs
	new access, callback
	menu_item_getinfo(menu, item, access, data,5, iName, 63, callback)
	item_id = str_to_num(data)
	ammo_packs = zp_get_user_ammo_packs(id)
	ArrayGetArray(items_database, item_id, extra_items)
	if(ammo_packs >= extra_items[i_cost]) zp_set_user_ammo_packs(id, ammo_packs - extra_items[i_cost])
	else
	{
		Print(id, "^1 Faltando^3 %d^1 ammo packs para comprar esse item.", extra_items[i_cost]-ammo_packs)
		if(g_menu_close) menu_destroy(menu)
		else vip_menu(id)
		return PLUGIN_HANDLED
	}
	item_id++
	ExecuteForward(g_extra_item_selected, g_forward_return, id, item_id)
	if (g_forward_return >= ZV_PLUGIN_HANDLED)
		zp_set_user_ammo_packs(id, ammo_packs)
	
	if(g_menu_close) menu_destroy(menu)
	else vip_menu(id)
	return PLUGIN_HANDLED
}

public print_adminlist(user) 
{
	new adminnames[33][32]
	new message[256]
	new id, count, x, len
	
	for(id = 1 ; id <= gServersMaxPlayers ; id++)
		if(is_user_connected(id))
		
			if(get_user_flags(id) & ACCES_VIP )
				get_user_name(id, adminnames[count++], 31)

	len = format(message, 255, "^3 VIPs Conectados: ")
	if(count > 0)
	{
		for(x = 0 ; x < count ; x++)
		{
			len += format(message[len], 255-len, "%s%s ", adminnames[x], x < (count-1) ? ", ":"")
			if(len > 96 )
			{
				message[192] = '^0'
				Print(user, "^4 %s", message)
				len = format(message, 255, "")
			}
		}
		message[192] = '^0'
		Print(user, "^4 %s", message)
	}
	else
	{
		Print(user, "^1 Nenhum VIP conectado.")
	}
	
	Print(user, "^1 Para comprar seu VIP:^3 %s", xWebSite )
	
}

public client_disconnect(id)
{
	check_alive(id)
	g_UserConnected[id] = false
}

public ShowMotd(id)
	show_motd(id, "vip.txt")

public native_zv_register_extra_item(const item_name[], const item_discription[], item_cost, item_team)
{
		param_convert(1)
		param_convert(2)
		copy(extra_items[i_name], 30, item_name)
		copy(extra_items[i_description], 30, item_discription)
		extra_items[i_cost] = item_cost
		extra_items[i_team] = item_team
		ArrayPushArray(items_database, extra_items)
		g_registered_items_count++
		
		return g_registered_items_count
}

Print(id, const message_format[], any:...)
{
	static message[192], len;
	len = formatex(message, sizeof(message) - 1, "^4%s", MESSAGE_TAG);
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
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1049\\ f0\\ fs16 \n\\ par }
*/
