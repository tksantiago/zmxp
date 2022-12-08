#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fakemeta>

#define PLUG_NAME 		"Hats"
#define PLUG_AUTH 		"SgtBane"
#define PLUG_VERS 		"1.8 PL1"		// This is called PL1 because there is a fix that the actual author doesn't know. Also ML is added.
#define PLUG_TAG 		"CSPGaming"
#define PLUG_ADMIN		ADMIN_BAN		//Access flags required to give/remove hats
#define PLUG_ADMINB 		ADMIN_LEVEL_B		//Access flags required to set personal hat if admin only is enabled

#define OFFSET_GLOWSET	100

#define HAT_ALL			0
#define HAT_ADMIN		1
#define HAT_TERROR		2
#define HAT_COUNTER		3

#define menusize 		220
#define maxTry			15				//Number of tries to get someone a non-admin random hat before giving up.
#define modelpath		"models/hat"

stock fm_set_entity_visibility(index, visible = 1) set_pev(index, pev_effects, visible == 1 ? pev(index, pev_effects) & ~EF_NODRAW : pev(index, pev_effects) | EF_NODRAW)

new g_HatEnt[33]
new CurrentHat[33]
new CurrentMenu[33]

new HatFile[64]
new MenuPages, TotalHats

#define MAX_HATS 64
new HATMDL[MAX_HATS][26]
new HATNAME[MAX_HATS][26]
new HATREST[MAX_HATS]

new P_AdminOnly
new P_AdminHats
new P_RandomJoin
new P_BotRandom
new P_ForceHat
new P_Glow

public plugin_init() {
	register_plugin(PLUG_NAME, PLUG_VERS, PLUG_AUTH)
	register_logevent("event_roundstart", 	2,	"1=Round_Start")
	register_event("TeamInfo", 				"event_team_info", 	"a" )
	
	register_concmd("amx_givehat", 		"Give_Hat", 	PLUG_ADMIN, 	"<nick> <mdl #>")
	register_concmd("amx_removehats", 	"Remove_Hat", 	PLUG_ADMIN, 	" - Removes hats from everyone.")
	
	register_menucmd(register_menuid("\rCSPGaming - Chapeus: \y[Pagina"),	(1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9),"MenuCommand")
	register_clcmd("say /hats",			"ShowMenu", -1, 	"Shows Knife menu")
	register_clcmd("say /chapeu",			"ShowMenu", -1, 	"Shows Knife menu")
	register_clcmd("hats",			"ShowMenu", -1, 	"Shows Knife menu")
	
	P_AdminOnly		= register_cvar("hat_adminonly",	"0")	//Only admins can use the menu
	P_AdminHats 	= register_cvar("hat_adminhats",	"0")	//Allow hats for admins only (if 0, hats specifically for admins can be used by anyone)
	P_RandomJoin	= register_cvar("hat_random",		"0")	//Random hats for players as they join
	P_BotRandom		= register_cvar("hat_bots",			"1")	//Random hats for bots as they join
	P_ForceHat		= register_cvar("hat_force",		"0")	//Force a specific hat (if not 0)
	P_Glow			= register_cvar("hat_glow",			"0")	//0=None,1=GlowWithPlayer,2=TeamColor

	register_dictionary("play_hats.txt");
}

public ShowMenu(id) {
	if ((get_pcvar_num(P_AdminOnly) == 1 && get_user_flags(id) & PLUG_ADMINB) || (get_pcvar_num(P_AdminOnly) == 0 && get_pcvar_num(P_ForceHat) == 0)) {
		CurrentMenu[id] = 1
		ShowHats(id)
	} else {
		client_print(id,print_chat,"[%s] %L", PLUG_TAG, id, "HATMENU_ADMIN_ONLY")
	}
	return PLUGIN_HANDLED
}

public ShowHats(id) {
	new keys = (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9)
	
	new szMenuBody[menusize + 1], WpnID
	new nLen = format(szMenuBody, menusize, "\rCSPGaming - Chapeus: \y[Pagina %i/%i]^n",CurrentMenu[id],MenuPages)
	
	new MnuClr[3]
	// Get Hat Names And Add Them To The List
	for (new hatid=0; hatid < 8; hatid++) {
		WpnID = ((CurrentMenu[id] * 8) + hatid - 8)
		if (WpnID < TotalHats) {
			menucolor(id, WpnID, MnuClr)
			nLen += format(szMenuBody[nLen], menusize-nLen, "^n\w%i.%s %s", hatid + 1, MnuClr, HATNAME[WpnID])
		}
	}
	
	// Next Page And Previous/Close
	if (CurrentMenu[id] == MenuPages) {
		nLen += format(szMenuBody[nLen], menusize-nLen, "^n^n\d9. Proxima Pagina")
	} else {
		nLen += format(szMenuBody[nLen], menusize-nLen, "^n^n\w9. Proxima Pagina")
	}
	
	if (CurrentMenu[id] > 1) {
		nLen += format(szMenuBody[nLen], menusize-nLen, "^n\w0. Voltar Pagina")
	} else {
		nLen += format(szMenuBody[nLen], menusize-nLen, "^n\w0. Fechar")
	}
	show_menu(id, keys, szMenuBody, -1)
	return PLUGIN_HANDLED
}

public MenuCommand(id, key) {
	switch(key)
	{
		case 8:		//9 - [Next Page]
		{
			if (CurrentMenu[id] < MenuPages) CurrentMenu[id]++
			ShowHats(id)
			return PLUGIN_HANDLED
		}
		case 9:		//0 - [Close]
		{
			CurrentMenu[id]--
			if (CurrentMenu[id] > 0) ShowHats(id)
			return PLUGIN_HANDLED
		}
		default:
		{
			new HatID = ((CurrentMenu[id] * 8) + key - 8)
			if (HatID < TotalHats) {
				if ((get_pcvar_num(P_AdminHats) == 0 && HATREST[HatID] == HAT_ADMIN) || (get_pcvar_num(P_AdminHats) == 1 && HATREST[HatID] == HAT_ADMIN && get_user_flags(id) & PLUG_ADMINB) || HATREST[HatID] == HAT_ALL || (HATREST[HatID] == get_user_team(id) + 1)) {
					Set_Hat(id,HatID,id)
				} else {
					if (HATREST[HatID] == HAT_TERROR && get_user_team(id) == 2) {
						client_print(id,print_chat,"[%s] %L",PLUG_TAG, id, LANG_PLAYER, "HATS_T_ONLY")
					} else if (HATREST[HatID] == HAT_COUNTER && get_user_team(id) == 1) {
						client_print(id,print_chat,"[%s] %L",PLUG_TAG, id, LANG_PLAYER, "HATS_CT_ONLY")
					} else {
						client_print(id,print_chat,"[%s] %L",PLUG_TAG, id, LANG_PLAYER, "HATS_ADMIN_ONLY")
					}
				}
			}
		}
	}
	return PLUGIN_HANDLED
}

public plugin_precache() {
	new cfgDir[32]
	get_configsdir(cfgDir,31)
	formatex(HatFile,63,"%s/play_hats.ini",cfgDir)
	command_load()
	new tmpfile [101]
	for (new i = 1; i < TotalHats; ++i) {
		format(tmpfile, 100, "%s/%s", modelpath, HATMDL[i])
		if (file_exists (tmpfile)) {
			precache_model(tmpfile)
			server_print("[%s] Precached %s", PLUG_TAG, HATMDL[i])
		} else {
			server_print("[%s] Failed to precache %s", PLUG_TAG, tmpfile)
		}
	}
}

public client_putinserver(id) {
	if (get_pcvar_num(P_ForceHat) == 1) {
		new forceID = get_pcvar_num(P_ForceHat)
		if (forceID <= TotalHats - 1) {
			forcehat(id, forceID)
		} else {
			set_pcvar_num(P_ForceHat, 0)
		}
	} else if (get_pcvar_num(P_RandomJoin) == 1 || (get_pcvar_num(P_BotRandom) == 1 && is_user_bot(id))) {
		if (get_pcvar_num(P_ForceHat) == 0) Random_Hat(id)
	}
	return PLUGIN_CONTINUE
}

public event_team_info() {
	if (get_pcvar_num(P_ForceHat) != 0) return
	new id = read_data(1)
	if (HATREST[CurrentHat[id]] == HAT_ALL) return
	if (HATREST[CurrentHat[id]] == HAT_ADMIN && get_user_flags(id) & PLUG_ADMINB) return
	
	new team[3]
	read_data(2, team, 2)
	switch(team[0]) {
		case 'C': {
			if (HATREST[CurrentHat[id]] != HAT_COUNTER) Random_Hat(id)
		}
		case 'T': {
			if (HATREST[CurrentHat[id]] != HAT_TERROR) Random_Hat(id)
		}
		case 'S': {
			Set_Hat(id, 0, 0)
		}
	}
	return
}
public event_roundstart() {
	new forceID = get_pcvar_num(P_ForceHat)
	for (new i = 0; i < get_maxplayers(); ++i) {
		if (is_user_connected(i) && g_HatEnt[i] > 0) {
			if (forceID != 0) {
				forcehat(i, forceID)
			}
			glowhat(i)
		}
	}
	return PLUGIN_CONTINUE
}

public Give_Hat(id, req_flag)
{
	if( !(get_user_flags(id) & req_flag) )
		return PLUGIN_HANDLED
	
	new smodelnum[5], name[32]
	read_argv(1,name,31)
	read_argv(2,smodelnum,4)
	
	new player = cmd_target(id,name,2)
	if (!player) {
		client_print(id,print_chat,"[%s] %L", PLUG_TAG, id, "PLAYER_NOT_EXISTS")
		return PLUGIN_HANDLED
	}
	
	new imodelnum = (str_to_num(smodelnum))
	if (imodelnum > MAX_HATS) return PLUGIN_HANDLED
	
	Set_Hat(player,imodelnum,id)

	return PLUGIN_CONTINUE
}

public Remove_Hat(id, req_flag)
{
	if( !(get_user_flags(id) & req_flag) )
		return PLUGIN_HANDLED

	for (new i = 0; i < get_maxplayers(); ++i) {
		if (is_user_connected(i) && g_HatEnt[i] > 0) {
			Set_Hat(id, 0, 0)
		}
	}
	client_print(id,print_chat,"[%s] %L", PLUG_TAG, id, "HAT_REMOVED_ALL")
	return PLUGIN_CONTINUE
}

public Random_Hat(id) {
	new bool:foundrnd = false, cntTry = 0, randID = random_num (1, TotalHats - 1)
	while (cntTry < maxTry && foundrnd == false) {
		randID = random_num (1, TotalHats - 1)
		cntTry += 1
		if (HATREST[randID] == HAT_ALL) foundrnd = true
		if (HATREST[randID] == HAT_ADMIN && get_user_flags(id) & PLUG_ADMINB) foundrnd = true
		if ((get_user_team(id) != 0) && HATREST[CurrentHat[id]] == get_user_team(id) + 1) foundrnd = true
	}
	if (foundrnd == true) {	//If a valid random hat is found, apply it.
		Set_Hat(id, randID , 0)
	} else {				//Otherwise, don't use any hat.
		Set_Hat(id, 0, 0)	
	}
	return PLUGIN_CONTINUE
}

public Set_Hat(player, imodelnum, targeter) {
	new name[32]
	new tmpfile[101]
	format(tmpfile, 100, "%s/%s", modelpath, HATMDL[imodelnum])
	get_user_name(player, name, 31)
	if (imodelnum == 0) {
		if(g_HatEnt[player] > 0) {
			fm_set_entity_visibility(g_HatEnt[player], 0)
		}
		if (targeter != 0) {
			client_print(targeter, print_chat, "[%s] %L", PLUG_TAG, LANG_PLAYER, "REMOVED_HAT",name)
		}
	} else if (file_exists(tmpfile)) {
		if(g_HatEnt[player] < 1) {
			g_HatEnt[player] = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
			if(g_HatEnt[player] > 0) {
				
				set_pev(g_HatEnt[player], pev_classname, "cso_consume")
				engfunc(EngFunc_SetModel, g_HatEnt[player], tmpfile)
				
				set_pev(g_HatEnt[player], pev_aiment, player)
				set_pev(g_HatEnt[player], pev_framerate, 1.0)
				set_pev(g_HatEnt[player], pev_movetype, MOVETYPE_FOLLOW)
				  
				set_pev(g_HatEnt[player], pev_solid, SOLID_TRIGGER)
				set_pev(g_HatEnt[player], pev_animtime, get_gametime())
				  
				//set_pev(g_HatEnt[player], pev_rendermode, 	kRenderNormal)
			}
		} else {
			engfunc(EngFunc_SetModel, g_HatEnt[player], tmpfile)
		}
		glowhat(player)
		CurrentHat[player] = imodelnum
		if (targeter != 0) {
			client_print(targeter, print_chat, "[%s] %L", PLUG_TAG, LANG_PLAYER, "SET",HATNAME[imodelnum],name)
		}
	}
}

public command_load() {
	if(file_exists(HatFile)) {
		HATMDL[0] = ""
		HATNAME[0] = "None"
		TotalHats = 1
		new TempCrapA[2]
		new sfLineData[128]
		new file = fopen(HatFile,"rt")
		while(file && !feof(file)) {
			fgets(file,sfLineData,127)
			
			// Skip Comment ; // and Empty Lines 
			if (sfLineData[0] == ';' || strlen(sfLineData) < 1 || (sfLineData[0] == '/' && sfLineData[1] == '/')) continue
			
			// BREAK IT UP!
			parse(sfLineData, HATMDL[TotalHats], 25, HATNAME[TotalHats], 25, TempCrapA, 1)
			
			if (TempCrapA[0] == 'A' || TempCrapA[0] == '1') {
				HATREST[TotalHats] = HAT_ADMIN
			} else if (TempCrapA[0] == 'T' || TempCrapA[0] == '2') {
				HATREST[TotalHats] = HAT_TERROR
			} else if (TempCrapA[0] == 'C' || TempCrapA[0] == '3') {
				HATREST[TotalHats] = HAT_COUNTER
			} else {
				HATREST[TotalHats] = HAT_ALL
			}
			TotalHats += 1
			if(TotalHats >= MAX_HATS) {
				server_print("[%s] Reached hat limit",PLUG_TAG)
				break
			}
		}
		if(file) fclose(file)
	}
	MenuPages = floatround((TotalHats / 8.0), floatround_ceil)
	server_print("[%s] Loaded %i hats, and Generated %i pages",PLUG_TAG,TotalHats,MenuPages)
}


menucolor(id, ItemID, MnuClr[3]) {
	//If its the hat they currently have on
	if (ItemID == CurrentHat[id]) {
		MnuClr = "\d"
		return
	}
	if (HATREST[ItemID] != HAT_ALL) {
		//If its an AdminHat&They are NOT an admin
		if (HATREST[ItemID] == HAT_ADMIN && get_pcvar_num(P_AdminHats) == 1) {
			if (get_user_flags(id) & PLUG_ADMINB) {
				MnuClr = "\y"
			} else {
				MnuClr = "\r"
			}
		//If this is a hat set for there team or not
		} else if (HATREST[ItemID] != get_user_team(id) + 1) {
			MnuClr = "\r"
		} else {
			MnuClr = "\y"
		}
	} else {
		MnuClr = "\w"
	}
	return
}

glowhat(id) {
	if (!pev_valid(g_HatEnt[id])) return
	if (get_pcvar_num(P_Glow) != 0) {	//If Glowing Hats Are Enabled
		set_pev(g_HatEnt[id], pev_renderfx,	kRenderFxGlowShell)
		if (get_pcvar_num(P_Glow) == 2) {	//If Not Team Specific, Use Player Glow On Hat
			new Float:curcolors[3], Float:curamt
			pev(id, pev_rendercolor, curcolors)
			pev(id, pev_renderamt, curamt)
			set_pev(g_HatEnt[id], pev_rendercolor, curcolors)
			set_pev(g_HatEnt[id], pev_renderamt, curamt)
		} else {								//If Team Specific, Red=T, Blue=CT
			if (get_user_team(id) == 1) {
				set_pev(g_HatEnt[id], pev_rendercolor, {200.0, 0.0, 0.0})
			} else if (get_user_team(id) == 2) {
				set_pev(g_HatEnt[id], pev_rendercolor, {0.0, 0.0, 200.0})
			}
			set_pev(g_HatEnt[id], pev_renderamt,	50.0)
		}
	} else {
		set_pev(g_HatEnt[id], pev_renderfx,	kRenderFxNone)
		set_pev(g_HatEnt[id], pev_renderamt,	0.0)
	}
	fm_set_entity_visibility(g_HatEnt[id], 1)
	return
}

forcehat(id, forceID) {
	if (forceID == 0) forceID = get_pcvar_num(P_ForceHat)
	if (forceID != 0) {
		if (forceID <= TotalHats - 1) {
			if (forceID != CurrentHat[id]) Set_Hat(id, forceID, 0)
		} else {
			set_pcvar_num(P_ForceHat, 0)
		}
	}
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1046\\ f0\\ fs16 \n\\ par }
*/
