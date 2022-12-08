/*
	[ZP] New Win Messages

	Plugin by Shidla [SGC] & xPaw & 93()|29!/<
	
	Idea & models:
	Koshak		| ICQ: 283-361-228	(zombie-mod.ru)

	Credits:
	xPaw									(Main code... My was worse... But it worked too :))
	93()|29!/<	| SkyPE: georgik_braila 	(Bug fixing)
				| Yahoo Messenger: george_stafie
	MeRcyLeZZ								(For his Zombie Plague)
	CHyCMyMpNk	| ICQ: 4-888-617			(forum.hlds.us)
	Fedcomp		| ICQ: 536020				(gm-community.net / forum.hlds.us / amx-x.ru / gscom.org)
	PomanoB		| ICQ: 147-919				(gm-community.net / forum.hlds.us / amx-x.ru)
	DJ_WEST		| ICQ: 634-866 				(For his amx-x.ru & reallite.cs2.ru)
	meTaLiCroSS								(For something, what ever... I know him - we steal something: his idea\code\constant\crap\brain\blablabla :))



	Shidla [SGC] | 2010 | ICQ: 312-298-513
	
	1.4 [Final Version] | 29/10/2010

	http://forums.alliedmods.net/showthread.php?t=128385		// Eng
	http://forum.hlds.us/showthread.php?p=84425					// Rus
*/

#include <amxmodx>
#include <fakemeta>
#include <zombieplague>

new Hands[33], Random, MaxPlayers, ChekUserHands, SetNVision

// Normal Models
new const MODELS[3][] =
{
	"",
	"models/zombie_plague/zombie_win.mdl",
	"models/zombie_plague/human_win.mdl"
}

new const MODELS2[3][] =
{
	"",
	"models/zombie_plague/zombie_win_2.mdl",
	"models/zombie_plague/human_win_2.mdl"
}

// Fliped Models
new const MODELS_FLIP[3][] =
{
	"",
	"models/zombie_plague/zombie_win-f.mdl",
	"models/zombie_plague/human_win-f.mdl"
}

new const MODELS_FLIP2[3][] =
{
	"",
	"models/zombie_plague/zombie_win-f_2.mdl",
	"models/zombie_plague/human_win-f_2.mdl"
}


new g_iModelIndex[3], g_iModelIndexFlip[3], g_iModelIndex2[3], g_iModelIndexFlip2[3], g_iWinTeam

public plugin_init()
{
	register_plugin("[ZMXP] Win Messages", "1.4", "xPaw" )
	
	register_event("HLTV", "EventRoundStart", "a", "1=0", "2=0" )
	register_event("CurWeapon", "EventCurWeapon", "be", "1=1")

	MaxPlayers = get_maxplayers()

	//register_cvar("Shidla", "[ZP] Sub-Plugin: New Win Messages v.1.4", FCVAR_SERVER|FCVAR_SPONLY)
	//register_cvar("zp_new_win_messages", "[ZP] Sub-Plugin: New Win Messages v.1.4", FCVAR_SERVER|FCVAR_SPONLY)

	ChekUserHands = register_cvar("zp_new_win_msg_chek" , "1")
	SetNVision = register_cvar("zp_new_win_msg_set_nvision" , "1")
}

public plugin_precache()
{
	for (new i = WIN_ZOMBIES; i <= WIN_HUMANS; i++)
	{
		// Normal Models
		precache_model(MODELS[i])
		g_iModelIndex[i] = engfunc(EngFunc_AllocString, MODELS[i])
		precache_model(MODELS2[i])
		g_iModelIndex2[i] = engfunc(EngFunc_AllocString, MODELS2[i])

		// Fliped Models
		precache_model(MODELS_FLIP[i])
		g_iModelIndexFlip[i] = engfunc(EngFunc_AllocString, MODELS_FLIP[i])
		precache_model(MODELS_FLIP2[i])
		g_iModelIndexFlip2[i] = engfunc(EngFunc_AllocString, MODELS_FLIP2[i])
	}
}

public client_connect(id)
{
	if(!is_user_bot(id) && get_pcvar_num (ChekUserHands))
		query_client_cvar(id , "cl_righthand" , "Hands_CVAR_Value")
}

public Hands_CVAR_Value(id, const cvar[], const value[])
{
	if((1 <= id <= MaxPlayers) && get_pcvar_num (ChekUserHands))	// Bug Fix & Cheking
		Hands[id] = str_to_num(value)
}

public client_disconnect(id)
{
	if(get_pcvar_num (ChekUserHands))
		Hands[id] = 0
}

public zp_round_ended(iTeam)
{
	if (iTeam == WIN_NO_ONE)
		return
	g_iWinTeam = iTeam
	new iPlayers[32], iNum
	get_players(iPlayers, iNum, "ch")

	Random = random_num(0 , 1)
	for (new i; i < iNum; i++)
	{
		if(get_pcvar_num (ChekUserHands))
			client_cmd(iPlayers[i], "cl_righthand ^"1^"")

		if(get_pcvar_num(SetNVision))
			zp_set_user_nightvision(iPlayers[i], 1)
		
		switch(Random)
		{
			case 0:
			{
				if (get_user_weapon(iPlayers[i]) != CSW_KNIFE)
					set_pev(iPlayers[i], pev_viewmodel, g_iModelIndexFlip[iTeam])
				else
					set_pev(iPlayers[i], pev_viewmodel, g_iModelIndex[iTeam])
			}

			case 1:
			{
				if (get_user_weapon(iPlayers[i]) != CSW_KNIFE)
					set_pev(iPlayers[i], pev_viewmodel, g_iModelIndexFlip2[iTeam])
				else
					set_pev(iPlayers[i], pev_viewmodel, g_iModelIndex2[iTeam])
			}
		}
	}
}

public EventRoundStart()
{
	g_iWinTeam = WIN_NO_ONE

	if(get_pcvar_num (ChekUserHands))
	{
		for (new i = 1; i <= MaxPlayers; i++)
		{
			if(!is_user_connected(i))
				continue		// xPaw fix)))

			client_cmd(i, "cl_righthand ^"%d^"", Hands[i])
		}
	}
}

public EventCurWeapon(const id)
{
	if (g_iWinTeam > WIN_NO_ONE)
	{
		if (get_pcvar_num (ChekUserHands))
			client_cmd(id, "cl_righthand ^"1^"")

		switch(Random)
		{
			case 0:
			{
				if (get_user_weapon(id) != CSW_KNIFE)
					set_pev(id, pev_viewmodel, g_iModelIndexFlip[g_iWinTeam])
				else
					set_pev(id, pev_viewmodel, g_iModelIndex[g_iWinTeam])
			}

			case 1:
			{
				if (get_user_weapon(id) != CSW_KNIFE)
					set_pev(id, pev_viewmodel, g_iModelIndexFlip2[g_iWinTeam])
				else
					set_pev(id, pev_viewmodel, g_iModelIndex2[g_iWinTeam])
			}
		}
	}
}

// Yes, baby, its's Russia! xDD
// Thanks for all, who help me)))