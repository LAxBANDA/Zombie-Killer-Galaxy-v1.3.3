#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <engine>
#include <zombiekillergalaxy>
#include <fun>
#include <cstrike>

#define VERSION "0.4b"

const m_pPlayer = 41;
new const NADE_TYPE_PIPE = 4327;
new const NADE_DURATION_PIPE = pev_flSwimTime;
new const g_trailspr[] ="sprites/laserbeam.spr";
new const g_ringspr[] = "sprites/shockwave.spr";
new const g_firespr[] = "sprites/zerogxplode.spr";
new const g_sound[] = "zpre4/pipe_beep.wav";
new const g_vmodel[] = "models/zpre4/v_pipe_bomb.mdl";
new const g_pmodel[] = "models/zpre4/p_pipe_bomb.mdl";
new const g_wmodel[] = "models/zpre4/w_pipe_bomb.mdl";
new const g_vflare[] = "models/zpre4/v_grenade_flare.mdl"; // type here your custom flare model to prevent bug. now uses default model
new cvar_duration, cvar_radius, cvar_sound, cvar_hud, cvar_extraap; // some cvars
new g_msgsync, g_trail, g_ring, g_fire, g_score, g_death, bool: g_has_pipe[33], bool: g_has_shield[33]; // some vars

public plugin_natives() {
	register_native("zp_get_user_pipe", "native_get_user_pipe", 1)
}

// Native: g_zombie
public native_get_user_pipe(id)
{
	if(zp_is_nemesis_round() || zp_is_assassin_round() || zp_is_nemesis_round())
	{
		client_print(id, print_center, "No puedes comprar pipe bomb ahora");
		return PLUGIN_HANDLED;
	}
	
	if(g_has_pipe[id])
	{
		client_print(id, print_center, "Ya tienes una pipebomb");
		return ZP_PLUGIN_HANDLED;
	}
	
	g_has_pipe[id]++;
	new was = cs_get_user_bpammo(id, CSW_SMOKEGRENADE);

	if(was >= 1)
		cs_set_user_bpammo(id, CSW_SMOKEGRENADE, was + 1);
	else
		give_item(id, "weapon_smokegrenade");
		
	replace_models(id);
	
	if(get_pcvar_num(cvar_hud) == 1)
	{
		new msg[32], hud = random_num(0, 1);
	
		if(hud == 0)
			formatex(msg, 31, "Bueno Esto Parece Peligroso");
		else
			formatex(msg, 31, "Bien explosivos caseros!");
	
		set_hudmessage(255, 0, 0, -1.0, 0.55, 0, 0.0, 3.0, 2.0, 1.0, -1);
		ShowSyncHudMsg(id, g_msgsync, "%s", msg);
	}
	
	return PLUGIN_CONTINUE;
}

public plugin_init() {
	register_plugin("[ZP] Extra: Pipe Bomb", VERSION, "4eRT");
	register_forward(FM_SetModel,"fw_SetModel", 1);
	RegisterHam(Ham_Think, "grenade", "fw_ThinkGren");
	RegisterHam(Ham_Spawn, "player", "fw_Spawn");
	RegisterHam(Ham_Item_Deploy, "weapon_smokegrenade", "fw_smDeploy", 1);
	
	// Cvars
	cvar_duration = register_cvar("zp_pipe_duration", "10");
	cvar_radius = register_cvar ( "zp_pipe_radius", "300");
	cvar_sound = register_cvar("zp_pipe_sound", "1");
	cvar_hud = register_cvar("zp_pipe_hud", "1");
	cvar_extraap = register_cvar("zp_pipe_ap", "0");
	
	g_msgsync = CreateHudSyncObj();
	g_score = get_user_msgid("ScoreInfo");
	g_death = get_user_msgid("DeathMsg");
}

public plugin_precache(){
	precache_model(g_vmodel);
	precache_model(g_pmodel);
	precache_model(g_wmodel);
	precache_model(g_vflare);
	precache_sound(g_sound);
	g_fire = precache_model(g_firespr);
	g_trail = precache_model(g_trailspr);
	g_ring = precache_model(g_ringspr);
}

public replace_models(id)
{
	if(get_user_weapon(id) == CSW_SMOKEGRENADE)
	{
		set_pev(id, pev_viewmodel2, g_vmodel);
		set_pev(id, pev_weaponmodel2, g_pmodel);
	}
}

public replace_models2(id)
	if(get_user_weapon(id) == CSW_SMOKEGRENADE)
		set_pev(id, pev_viewmodel2, g_vflare);

public fw_smDeploy(const iEntity)
{
	if(pev_valid(iEntity) != 2)
		return HAM_IGNORED;
    
	new id = get_pdata_cbase(iEntity, m_pPlayer, 4);
    
	if(g_has_pipe[id] && !zp_get_user_zombie(id) && is_user_alive(id))
	{
		set_pev(id, pev_viewmodel2, g_vmodel);
		set_pev(id, pev_weaponmodel2, g_pmodel);
	}
    
	return HAM_IGNORED;
}

public zp_user_infected_post(id)
{
	g_has_pipe[id] = false;
	g_has_shield[id] = false;
}
		
public fw_Spawn(id)
{
	g_has_pipe[id] = false;
	g_has_shield[id] = false;
}

public fw_SetModel(entity, const model[]) // Set smokegrenade pipes effects and type
{
	static Float:dmgtime, owner;
	pev(entity, pev_dmgtime, dmgtime);
	owner = pev(entity, pev_owner);
	
	if(!pev_valid(entity) || dmgtime == 0.0)
		return FMRES_IGNORED;
	
	if (model[9] == 's' && model[10] == 'm' && g_has_pipe[owner])
	{
		g_has_pipe[owner] = false;
		entity_set_model(entity, g_wmodel);
		replace_models2(owner);
		
		set_rendering(entity, kRenderFxGlowShell, 128, 0, 0, kRenderNormal, 16);
		
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(TE_BEAMFOLLOW) // TE id
		write_short(entity) // entity
		write_short(g_trail) // sprite
		write_byte(10) // life
		write_byte(10) // width
		write_byte(128) // r
		write_byte(0) // g
		write_byte(0) // b
		write_byte(255) // brightness
		message_end()
		
		set_pev(entity, pev_flTimeStepSound, NADE_TYPE_PIPE);
		
		return FMRES_SUPERCEDE;
	}
	
	return FMRES_IGNORED;
}

public fw_ThinkGren(entity) // Grenade think event
{
	if (!pev_valid(entity))
		return HAM_IGNORED;
	
	static Float:dmgtime, Float: current_time, attacker;
	pev(entity, pev_dmgtime, dmgtime);
	current_time = get_gametime();
	attacker = pev(entity, pev_owner);
	
	if(dmgtime > current_time)
		return HAM_IGNORED;
	
	if(pev(entity, pev_flTimeStepSound) == NADE_TYPE_PIPE)
	{
		static duration;
		duration = pev(entity, NADE_DURATION_PIPE);
		
		if (duration > 0)
		{
			new Float:originF[3]
			pev(entity, pev_origin, originF);
			
			if (duration == 1)
			{
				remove_task(entity);
				effect(originF);
				
				kill(originF, attacker);
				
				engfunc(EngFunc_RemoveEntity, entity);
				return HAM_SUPERCEDE;
			}
			
			light(originF, duration);
			set_task(0.1, "hook", entity, _, _, "b");
				
			if(get_pcvar_num(cvar_sound))
			{
				if(duration == 2)
					set_task(0.1, "beep", entity, _, _, "b");
				else
					emit_sound(entity, CHAN_WEAPON, g_sound, 1.0, ATTN_NORM, 0, PITCH_HIGH);
			}
			
			set_pev(entity, NADE_DURATION_PIPE, --duration);
			set_pev(entity, pev_dmgtime, current_time + 3.0);
		} else if ((pev(entity, pev_flags) & FL_ONGROUND) && get_speed(entity) < 10)
		{
			set_pev(entity, NADE_DURATION_PIPE, 1 + get_pcvar_num(cvar_duration)/3);
			set_pev(entity, pev_dmgtime, current_time + 0.1);
		} else
			set_pev(entity, pev_dmgtime, current_time + 0.5);
	}
	
	return HAM_IGNORED;
}

public beep(entity) // Plays loop beep sound before explosion
{
	//Bugfix
	if (!pev_valid(entity))
	{
		remove_task(entity);
		return;
	}
	
	emit_sound(entity, CHAN_WEAPON, g_sound, 1.0, ATTN_NORM, 0, PITCH_HIGH);
}

public hook(entity) // Magnet func. Hooks zombies to nade
{
	//Bugfix
	if (!pev_valid(entity))
	{
		remove_task(entity);
		return;
	}
	
	static Float:originF[3], Float:radius, victim = -1;
	radius = get_pcvar_float(cvar_radius);
	pev(entity, pev_origin, originF);
	
	while ((victim = engfunc(EngFunc_FindEntityInSphere, victim, originF, radius)) != 0)
	{
		if (!is_user_alive(victim) || zp_get_user_alien(victim) || zp_get_user_assassin(victim) || zp_get_user_nemesis(victim) || !zp_get_user_zombie(victim) || g_has_shield[victim])
			continue;

		new Float:fl_Velocity[3];
		new vicOrigin[3], originN[3];

		get_user_origin(victim, vicOrigin);
		originN[0] = floatround(originF[0]);
		originN[1] = floatround(originF[1]);
		originN[2] = floatround(originF[2]);
		
		new distance = get_distance(originN, vicOrigin);

		if (distance > 1)
		{
			new Float:fl_Time = distance / 600.0

			fl_Velocity[0] = (originN[0] - vicOrigin[0]) / fl_Time;
			fl_Velocity[1] = (originN[1] - vicOrigin[1]) / fl_Time;
			fl_Velocity[2] = (originN[2] - vicOrigin[2]) / fl_Time;
		} 
		else
		{
			fl_Velocity[0] = 0.0
			fl_Velocity[1] = 0.0
			fl_Velocity[2] = 0.0
		}

		entity_set_vector(victim, EV_VEC_velocity, fl_Velocity);
	}
}
/*
public hurt(entity) // Hurts zombies if mode = 2
{
	//Bugfix
	if (!pev_valid(entity))
	{
		remove_task(entity);
		return;
	}
	
	static Float:originF[3], Float:radius, victim = -1;
	radius = get_pcvar_float(cvar_radius)/2.0;
	pev(entity, pev_origin, originF);
	
	while ((victim = engfunc(EngFunc_FindEntityInSphere, victim, originF, radius)) != 0)
	{
		if (!is_user_alive(victim) || zp_get_user_alien(victim) || zp_get_user_assassin(victim) || zp_get_user_nemesis(victim) || !zp_get_user_zombie(victim) || g_has_shield[victim])
			continue;
		
		ExecuteHamB(Ham_Killed, victim, attacker, 2);
	}
}*/

public kill(const Float:originF[3], attacker) // Kills zombies in radius / 2 if mode = 1
{
	static Float:radius, victim = -1;
	radius = get_pcvar_float(cvar_radius) / 2.0;
	
	while ((victim = engfunc(EngFunc_FindEntityInSphere, victim, originF, radius)) != 0)
	{
		if (!is_user_alive(victim) || !zp_get_user_zombie(victim) || zp_get_user_alien(victim) || zp_get_user_assassin(victim) || zp_get_user_nemesis(victim) || g_has_shield[victim])
			continue;
		
		set_msg_block(g_death, BLOCK_SET);
		ExecuteHamB(Ham_Killed, victim, attacker, 2);
		set_msg_block(g_death, BLOCK_NOT);
		
		if(get_user_health(victim) <= 0)
		{
			SendDeathMsg(attacker, victim);
			
			if(victim != attacker && !zp_get_user_zombie(attacker))
				UpdateFrags(attacker, 1, 1)
			else
				UpdateFrags(attacker, -1, 1)
		}
	}
}

public light(const Float:originF[3], duration)  // Blast ring and small red light around nade from zpre440.sma. Great thx, MeRcyLeZZ!!! ;)
{
	// Lighting
	engfunc(EngFunc_MessageBegin, MSG_PAS, SVC_TEMPENTITY, originF, 0);
	write_byte(TE_DLIGHT); // TE id
	engfunc(EngFunc_WriteCoord, originF[0]); // x
	engfunc(EngFunc_WriteCoord, originF[1]); // y
	engfunc(EngFunc_WriteCoord, originF[2]); // z
	write_byte(5); // radius
	write_byte(128); // r
	write_byte(0); // g
	write_byte(0); // b
	write_byte(51); //life
	write_byte((duration < 2) ? 3 : 0); //decay rate
	message_end();
	
	// Smallest ring
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
	write_byte(TE_BEAMCYLINDER) // TE id
	engfunc(EngFunc_WriteCoord, originF[0]) // x
	engfunc(EngFunc_WriteCoord, originF[1]) // y
	engfunc(EngFunc_WriteCoord, originF[2]) // z
	engfunc(EngFunc_WriteCoord, originF[0]) // x axis
	engfunc(EngFunc_WriteCoord, originF[1]) // y axis
	engfunc(EngFunc_WriteCoord, originF[2]+385.0) // z axis
	write_short(g_ring) // sprite
	write_byte(0) // startframe
	write_byte(0) // framerate
	write_byte(4) // life
	write_byte(60) // width
	write_byte(0) // noise
	write_byte(128) // red
	write_byte(0) // green
	write_byte(0) // blue
	write_byte(200) // brightness
	write_byte(0) // speed
	message_end()
	
	// Medium ring
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
	write_byte(TE_BEAMCYLINDER) // TE id
	engfunc(EngFunc_WriteCoord, originF[0]) // x
	engfunc(EngFunc_WriteCoord, originF[1]) // y
	engfunc(EngFunc_WriteCoord, originF[2]) // z
	engfunc(EngFunc_WriteCoord, originF[0]) // x axis
	engfunc(EngFunc_WriteCoord, originF[1]) // y axis
	engfunc(EngFunc_WriteCoord, originF[2]+470.0) // z axis
	write_short(g_ring) // sprite
	write_byte(0) // startframe
	write_byte(0) // framerate
	write_byte(4) // life
	write_byte(60) // width
	write_byte(0) // noise
	write_byte(128) // red
	write_byte(0) // green
	write_byte(0) // blue
	write_byte(200) // brightness
	write_byte(0) // speed
	message_end()
	
	// Largest ring
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
	write_byte(TE_BEAMCYLINDER) // TE id
	engfunc(EngFunc_WriteCoord, originF[0]) // x
	engfunc(EngFunc_WriteCoord, originF[1]) // y
	engfunc(EngFunc_WriteCoord, originF[2]) // z
	engfunc(EngFunc_WriteCoord, originF[0]) // x axis
	engfunc(EngFunc_WriteCoord, originF[1]) // y axis
	engfunc(EngFunc_WriteCoord, originF[2]+555.0) // z axis
	write_short(g_ring) // sprite
	write_byte(0) // startframe
	write_byte(0) // framerate
	write_byte(4) // life
	write_byte(60) // width
	write_byte(0) // noise
	write_byte(128) // red
	write_byte(0) // green
	write_byte(0) // blue
	write_byte(200) // brightness
	write_byte(0) // speed
	message_end()
}

public effect(const Float:originF[3]) // Explosion effect
{
	// Largest ring
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
	write_byte(TE_BEAMCYLINDER) // TE id
	engfunc(EngFunc_WriteCoord, originF[0]) // x
	engfunc(EngFunc_WriteCoord, originF[1]) // y
	engfunc(EngFunc_WriteCoord, originF[2]) // z
	engfunc(EngFunc_WriteCoord, originF[0]) // x axis
	engfunc(EngFunc_WriteCoord, originF[1]) // y axis
	engfunc(EngFunc_WriteCoord, originF[2]+555.0) // z axis
	write_short(g_ring) // sprite
	write_byte(0) // startframe
	write_byte(0) // framerate
	write_byte(4) // life
	write_byte(60) // width
	write_byte(0) // noise
	write_byte(128) // red
	write_byte(0) // green
	write_byte(0) // blue
	write_byte(200) // brightness
	write_byte(0) // speed
	message_end()
	
	// Explosion sprite
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
	write_byte(TE_EXPLOSION)
	engfunc(EngFunc_WriteCoord, originF[0])
	engfunc(EngFunc_WriteCoord, originF[1])
	engfunc(EngFunc_WriteCoord, originF[2])
	write_short(g_fire) //sprite index
	write_byte(25) // scale in 0.1's
	write_byte(10) // framerate
	write_byte(0) // flags
	message_end()
}

UpdateFrags(attacker, frags, scoreboard) // Updates attacker frags
{
	// Set attacker frags
	set_pev(attacker, pev_frags, float(pev(attacker, pev_frags) + frags))
	
	if(get_pcvar_num(cvar_extraap) > 0)
		zp_set_user_ammo_packs(attacker, zp_get_user_ammo_packs(attacker) + get_pcvar_num(cvar_extraap));
		
	// Update scoreboard with attacker and victim info
	if (scoreboard)
	{
		message_begin(MSG_BROADCAST, g_score)
		write_byte(attacker) // id
		write_short(pev(attacker, pev_frags)) // frags
		write_short(get_user_deaths(attacker)) // deaths
		write_short(0) // class?
		write_short(get_user_team(attacker)) // team
		message_end()
	}
}

SendDeathMsg(attacker, victim) // Sends death message
{
	message_begin(MSG_BROADCAST, g_death)
	write_byte(attacker) // killer
	write_byte(victim) // victim
	write_byte(0) // headshot flag
	write_string("Pipe Bomb") // killer's weapon
	message_end()
}
