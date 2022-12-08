
 #include <amxmodx>
 #include <fakemeta>

 new normalTrace[33], lastTrace[33], cvEnabled, weapon, dummy;

 // plugin load
 public plugin_init()
 {
	register_plugin("No Walls","0.13","Avalanche");

	register_cvar("nowalls_version","0.13",FCVAR_SERVER);
	cvEnabled = register_cvar("nowalls_enabled","1");

	register_event("ResetHUD","event_resethud","b");
	register_clcmd("fullupdate","cmd_fullupdate");

	register_forward(FM_TraceLine,"fw_traceline");
	register_forward(FM_PlayerPostThink,"fw_playerpostthink");
 }

 // reset normal trace id on join or leave
 public client_connect(id)
 {
	normalTrace[id] = 0;
 }

 public client_disconnect(id)
 {
	normalTrace[id] = 0;
 }

 // player spawns, and some other such things
 public event_resethud(id)
 {
	lastTrace[id] = 0;
 }

 // block forced resethud call
 public cmd_fullupdate(id)
 {
	return PLUGIN_HANDLED;
 }

 // traceline hook, meat and bones of the entire plugin
 public fw_traceline(Float:vecStart[3],Float:vecEnd[3],ignoreM,id,ptr) // pentToSkip == id, for clarity
 {
	if(!is_user_connected(id))
		return FMRES_IGNORED;

	// grab normal trace
	if(!normalTrace[id])
	{
		normalTrace[id] = ptr;
		return FMRES_IGNORED;
	}

	// ignore normal trace
	else if(ptr == normalTrace[id])
		return FMRES_IGNORED;

	// no functionality
	if(!get_pcvar_num(cvEnabled))
		return FMRES_IGNORED;

	// not a player entity, or player is dead
	if(!is_user_alive(id))
		return FMRES_IGNORED;

	// not shooting anything
	if(!(pev(id,pev_button) & IN_ATTACK))
		return FMRES_IGNORED;

	weapon = get_user_weapon(id,dummy,dummy);

	// using a shotgun, expect multiple tracelines
	if(weapon == CSW_M3 || weapon == CSW_XM1014)
		return FMRES_IGNORED;

	// this is a second traceline, for shooting through walls
	if(ptr == lastTrace[id])
	{
		// values sure to throw off any traceline
		set_tr(TR_vecEndPos,Float:{4096.0,4096.0,4096.0});
		set_tr(TR_AllSolid,1);
		set_tr(TR_pHit,0);
		set_tr(TR_iHitgroup,0);
		set_tr(TR_flFraction,1.0);

		return FMRES_SUPERCEDE;
	}

	// remeber traceline index for next time
	lastTrace[id] = ptr;

	return FMRES_IGNORED;
 }

 // finished client calculations, reset our traceline index
 public fw_playerpostthink(id)
 {
	lastTrace[id] = 0;
 }
