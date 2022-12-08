#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <zombieplague>

#include < play_zombiexp >
#include < play_global >

#define VIPACCES ADMIN_RESERVATION

#define PLUGIN "[ZMXP] VIP Presentes"
#define VERSION "1.0"

new PegouPresente[33], gServersMaxPlayers

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR )
	register_say("presente", "Presentes")
	register_clcmd("/presente", "Presentes")
	
	register_event("HLTV", "RoundStarted", "a", "1=0", "2=0")
	gServersMaxPlayers = get_maxplayers()
}

public RoundStarted()
{
	for (new id = 1; id <= gServersMaxPlayers; id++) 
	{
		PegouPresente[id] = 0
	}
}

public Presentes(id)
{
	if(zp_get_user_zombie(id) || !is_user_alive(id) || zp_get_user_nemesis(id))
	{
		client_print(id, print_chat, "[PRESENTES] Comando disponivel apenas para Humanos VIVOS!")
		return PLUGIN_HANDLED
	}
	
	if( get_user_flags(id) & VIPACCES )
	{
		if(PegouPresente[id] == 0)
		{
			DarPresente(id)
		}
		else client_print(id, print_chat, "[PRESENTES] Calma fio! Apenas 1 vez por round.")
	}
	else client_print(id, print_chat, "[PRESENTES] So para Vips da Promocao de Natal!")
	
	return PLUGIN_HANDLED
}

DarPresente(id)
{
	new x = random(100)
	
	if(x <= 35) // n�o ganhou nada haha (35%)
	{
		client_print(id, print_chat, "[PRESENTES] Seu presente estava vazio =(. Alguem roubou o Papai Noel!")
		PegouPresente[id] = 1
		return PLUGIN_HANDLED
	}
	
	if(x <= 80) // ganhou alguma coisa legal (45%)
	{
		new y = random_num(1, 15)
		
		switch(y)
		{
			case 1:
			{
				set_pev(id, pev_gravity, 0.60)
				client_print(id, print_chat, "[PRESENTES] Voce abriu o presente e ganhou Gravity Level 6 (1 round)")
			}
			case 2:
			{
				fm_set_rendering(id, kRenderFxGlowShell, random_num(0,255), random_num(0,255), random_num(0,255), kRenderNormal, 1)
				client_print(id, print_chat, "[PRESENTES] Voce abriu o presente e ganhou uma aura!")
			}+
			case 3:
			{
				set_pev(id, pev_armorvalue, 180.0)
				client_print(id, print_chat, "[PRESENTES] Voce abriu o presente e ganhou 180 de colete!")
			}
			case 4:
			{
				fm_set_user_health(id, (pev(id, pev_health)+350.0))
				client_print(id, print_chat, "[PRESENTES] Voce abriu o presente e ganhou 350 de HP!")
			}
			case 5:
			{
				set_pev(id, pev_gravity, 0.60)
				client_print(id, print_chat, "[PRESENTES] Voce abriu o presente e ganhou Gravity Level 6 (1 round)")
			}
			case 6:
			{
				fm_give_item(id, "weapon_hegrenade")
				client_print(id, print_chat, "[PRESENTES] Voce abriu o presente e ganhou uma HE!")
			}
			case 7:
			{
				fm_give_item(id, "weapon_flashbang")
				client_print(id, print_chat, "[PRESENTES] Voce abriu o presente e ganhou uma Frost nade!")
			}
			case 8:
			{
				user_slap(id, 1)
				client_print(id, print_chat, "[PRESENTES] Voce abriu o presente e ganhou um slap! Hahaha")
			}
			case 9:
			{
				new iditem = zp_get_extra_item_id("Municao Infinita (1 round)")
				
				if(iditem > 0)
				{
					zp_force_buy_extra_item(id, iditem, 1)
					client_print(id, print_chat, "[PRESENTES] Voce abriu o presente e ganhou Municao Infinita!")
					
					new name[32]
					get_user_name(id, name, 31)
					client_print(0, print_chat, "[PRESENTES] %s ganhou Municao Infinita!", name)					
				}
				else
				{
					DarPresente(id)
					return PLUGIN_HANDLED
				}
			}
			case 10:
			{
				new iditem = zp_get_extra_item_id("G3SG1 Auto-Sniper")
				zp_force_buy_extra_item(id, iditem, 1)
				client_print(id, print_chat, "[PRESENTES] Voce abriu o presente e ganhou uma TEC TEC!")
				
				new name[32]
				get_user_name(id, name, 31)
				client_print(0, print_chat, "[PRESENTES] %s ganhou uma TEC TEC de presente!", name)
			}
			case 11:
			{
				new iditem = zp_get_extra_item_id("Crossbow")
				zp_force_buy_extra_item(id, iditem, 1)
				client_print(id, print_chat, "[PRESENTES] Voce abriu o presente e ganhou uma Crossbow!")
				
				new name[32]
				get_user_name(id, name, 31)
				client_print(0, print_chat, "[PRESENTES] %s ganhou uma Crossbow de presente!", name)				
			}
			case 12:
			{
				new iditem = zp_get_extra_item_id("Campo de Forca Sagrado")
				
				if(iditem > 0)
				{
					zp_force_buy_extra_item(id, iditem, 1)
					client_print(id, print_chat, "[PRESENTES] Voce abriu o presente e ganhou um Campo de Forca Sagrado!")
					
					new name[32]
					get_user_name(id, name, 31)
					client_print(0, print_chat, "[PRESENTES] %s ganhou um Campo de Forca Sagrado de presente!", name)					
				}
				else
				{
					DarPresente(id)
					return PLUGIN_HANDLED
				}
			}
			case 13:
			{
				new iditem = zp_get_extra_item_id("Elemental Guns")
				zp_force_buy_extra_item(id, iditem, 1)
				client_print(id, print_chat, "[PRESENTES] Voce abriu o presente e ganhou uma Elemental Guns!")
				
				new name[32]
				get_user_name(id, name, 31)
				client_print(0, print_chat, "[PRESENTES] %s ganhou uma Elemental Guns de presente!", name)				
			}
			case 14:
			{
				new iditem = zp_get_extra_item_id("[Shotgun] Quad Barrel")
				zp_force_buy_extra_item(id, iditem, 1)
				client_print(id, print_chat, "[PRESENTES] Voce abriu o presente e ganhou uma Quad Barrel!")
				
				new name[32]
				get_user_name(id, name, 31)
				client_print(0, print_chat, "[PRESENTES] %s ganhou uma Quad Barrel de presente!", name)				
			}
			case 15:
			{
				new iditem = zp_get_extra_item_id("P90 dos Brothers")
				zp_force_buy_extra_item(id, iditem, 1)
				client_print(id, print_chat, "[PRESENTES] Voce abriu o presente e ganhou uma P90 dos Brothers!")
				
				new name[32]
				get_user_name(id, name, 31)
				client_print(0, print_chat, "[PRESENTES] %s ganhou uma P90 dos Brothers de presente!", name)				
			}			
		}
		
		PegouPresente[id] = 1
		return PLUGIN_HANDLED
	}
	
	if(x <= 90) // ganhou alguma coisa boa~muito boa (10%) = PACKs
	{
		new y = random_num(10, 70)
		new z = zp_get_user_ammo_packs(id)
		
		zp_set_user_ammo_packs(id, (z+y))
		
		client_print(id, print_chat, "[PRESENTES] Voce abriu o presente e ganhou %i APs!", y)
		
		PegouPresente[id] = 1
		return PLUGIN_HANDLED
	}
	
	if(x <= 100) // ganhou alguma coisa boa~muito boa (10%) = XP
	{
		new y = random_num(1, 120)
		
		zmxp_set_user_xp(id, y)
		
		client_print(id, print_chat, "[PRESENTES] Voce abriu o presente e ganhou %i XP!", y)
		PegouPresente[id] = 1
		return PLUGIN_HANDLED
	}	
	
	return PLUGIN_HANDLED
}

// Give an item to a player (from fakemeta_util)
/*
stock fm_give_item(id, const item[])
{
	static ent
	ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, item))
	if (!pev_valid(ent)) return;
	
	static Float:originF[3]
	pev(id, pev_origin, originF)
	set_pev(ent, pev_origin, originF)
	set_pev(ent, pev_spawnflags, pev(ent, pev_spawnflags) | SF_NORESPAWN)
	dllfunc(DLLFunc_Spawn, ent)
	
	static save
	save = pev(ent, pev_solid)
	dllfunc(DLLFunc_Touch, ent, id)
	if (pev(ent, pev_solid) != save)
		return;
	
	engfunc(EngFunc_RemoveEntity, ent)
}
*/

// Set player's health (from fakemeta_util)
/*
stock fm_set_user_health(id, health)
{
	(health > 0) ? set_pev(id, pev_health, float(health)) : dllfunc(DLLFunc_ClientKill, id);
}
*/

stock fm_set_rendering(entity, fx = kRenderFxNone, r = 255, g = 255, b = 255, render = kRenderNormal, amount = 16)
{
	static Float:color[3]
	color[0] = float(r)
	color[1] = float(g)
	color[2] = float(b)
	
	set_pev(entity, pev_renderfx, fx)
	set_pev(entity, pev_rendercolor, color)
	set_pev(entity, pev_rendermode, render)
	set_pev(entity, pev_renderamt, float(amount))
}