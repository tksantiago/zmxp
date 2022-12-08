#include < amxmodx >
#include < cstrike >
#include < fakemeta >
#include < zombieplague >
#include < zmvip >

#include < play_global >

#define PLUGIN "[ZMXP] VIP: M4A1 - AK47"
#define VERSION "1.0"

new m4a1, ak47

new const model_ak47[] = "";
new const model_m4a1[] = "";

public plugin_init(){
	register_plugin( PLUGIN, VERSION, AUTHOR );
	
	m4a1 = zv_register_extra_item("M4A1 Asimov", "Normal", 5, ZV_TEAM_HUMAN );
	ak47 = zv_register_extra_item("AK-47 Volcan", "Normal", 5, ZV_TEAM_HUMAN );
}

public plugin_precache(){
	engfunc( EngFunc_PrecacheModel, model_ak47 );
	engfunc( EngFunc_PrecacheModel, model_m4a1 );
}

public zv_extra_item_selected( id, itemid ){	
	if( itemid == m4a1 ){
		fm_strip_user_weapons( id );
		
		fm_give_item( id, "weapon_m4a1");
		fm_give_item( id, "weapon_deagle");
		fm_give_item( id, "weapon_knife");
		
		fm_cs_set_user_bpammo( id, CSW_M4A1, 90);
		fm_cs_set_user_bpammo( id, CSW_DEAGLE, 35);
	}
	
	if( itemid == ak47 ){	
		fm_strip_user_weapons( id );
		
		fm_give_item( id, "weapon_ak47");
		fm_give_item( id, "weapon_deagle");
		fm_give_item( id, "weapon_knife");
		
		fm_cs_set_user_bpammo( id, CSW_AK47, 150);
		fm_cs_set_user_bpammo( id, CSW_DEAGLE, 35);
	}
	
	return 1
}
