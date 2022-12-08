#include <amxmodx>
#include <zombieplague>
#include <zmvip>

#define PLUGIN "[ZMXP] S/N Buy"
#define VERSION "1.1"
#define AUTHOR "Satelite"

new nemesis, survivor
new cvar_n_price, cvar_s_price
new compras = 0

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	cvar_n_price = register_cvar("zp_nemesis_price", "50")
	cvar_s_price = register_cvar("zp_survivor_price", "50")
	
	// Extra items
	nemesis = zv_register_extra_item("Comprar Nemesis", "Por um round", get_pcvar_num(cvar_n_price), 0)
	survivor = zv_register_extra_item("Comprar Survivor","Por um round", get_pcvar_num(cvar_s_price), 0)
}

public zv_extra_item_selected(id, itemid)
{	
	if(itemid == nemesis)
	{
		if( !zp_has_round_started() && compras < 1)
		{
			zp_make_user_nemesis(id)
			new name[64]
			get_user_name(id, name, 63)
			client_print(0, print_chat, "[ZP] Jogador VIP %s comprou Nemesis!", name)
			compras++
		}
		else
		{
			client_print(id, print_chat, "[ZP] So pode comprar Nemesis quando o round ainda nao comecou ou se alguem ja comprou")
			return ZV_PLUGIN_HANDLED
		}
	}
	else if(itemid == survivor)
	{
		
		if( !zp_has_round_started() && compras < 1)
		{
			zp_make_user_survivor(id)
			new name[64]
			get_user_name(id, name, 63)
			client_print(0, print_chat, "[ZP] Jogador VIP %s comprou Survivor!", name)
			compras++
		}
		else
		{
			client_print(id, print_chat, "[ZP] So pode comprar Survivor quando o round ainda nao comecou ou se alguem ja comprou")
			return ZV_PLUGIN_HANDLED
		}
	}
	
	return 1
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1046\\ f0\\ fs16 \n\\ par }
*/
