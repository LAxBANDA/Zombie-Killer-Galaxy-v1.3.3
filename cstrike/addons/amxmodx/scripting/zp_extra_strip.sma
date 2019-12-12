#include <amxmodx>
#include <fakemeta>
#include <fakemeta_util>
#include <engine>
#include <hamsandwich>
#include <zombiekillergalaxy>
#define pev_nade_type        pev_flTimeStepSound
#define fm_create_entity(%1) engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, %1))

new const NADE_TYPE_STRIPBOMB= 7172
new const sprite_grenade_trail[] = "sprites/laserbeam.spr"
new const sprite_grenade_ring[] = "sprites/shockwave.spr"
new const model_vgrenade_infect[] = "models/zpre4/v_granada_removedora.mdl"
new const model_pgrenade_infect[] = "models/zpre4/p_granada_removedora.mdl"
new const model_wgrenade_infect[] = "models/zpre4/w_granada_removedora.mdl"

new g_iCurrentWeapon[33]
new g_trailSpr, g_exploSpr, cvar_mode, cvar_radius, cvar_max
new has_bomb[33],had_bombs[33];

public plugin_init()
{
	register_plugin("[ZP] Extra Item: Strip Bomb", "1.6", "Hezerf")
	
	RegisterHam(Ham_Think, "grenade", "fw_ThinkGrenade")
	RegisterHam(Ham_Killed, "player", "fw_PlayerKilled")
	
	register_forward(FM_SetModel, "fw_SetModel")
	
	register_event("CurWeapon", "EV_CurWeapon", "be", "1=1", "2=9")
	
	register_event("HLTV","Event_New_Round","a", "1=0", "2=0")
	
	cvar_mode = register_cvar("zp_strip_mode", "2")
	cvar_radius = register_cvar("zp_strip_radius", "250.0")
	cvar_max = register_cvar("zp_strip_max","2")
}

public plugin_precache()
{
	g_trailSpr = engfunc(EngFunc_PrecacheModel, sprite_grenade_trail)
	g_exploSpr = engfunc(EngFunc_PrecacheModel, sprite_grenade_ring)
	
	engfunc(EngFunc_PrecacheModel, model_vgrenade_infect)
	engfunc(EngFunc_PrecacheModel, model_pgrenade_infect)
	engfunc(EngFunc_PrecacheModel, model_wgrenade_infect)
}

public plugin_natives()
{
	register_native("zp_get_user_strip", "native_get_user_strip", 1)
}

public client_disconnect(id)
{
	has_bomb[id] = 0;
	had_bombs[id] = 0;
}

public Event_New_Round()
{
	arrayset(had_bombs,0,32);
	arrayset(has_bomb,0,32);
}
public native_get_user_strip(player)
{
	if(get_pcvar_num(cvar_max) == had_bombs[player])
	{
		zp_set_user_ammo_packs(player,zp_get_user_ammo_packs(player) + 40)
		client_print(player, print_chat, "[ZK Galaxy] Son Maximo 2 Granadas Removedoras de Armas Por Ronda!")
		return;
	}
	
	has_bomb[player]++
	had_bombs[player]++;
	fm_strip_user_gun(player, 9)
	fm_give_item(player, "weapon_smokegrenade")
}

public fw_PlayerKilled(victim, attacker, shouldgib)
	has_bomb[victim] = 0;

public fw_ThinkGrenade(ent)
{
	if(!pev_valid(ent))
		return HAM_IGNORED
	
	static Float:dmg_time
	pev(ent, pev_dmgtime, dmg_time)
	
	if(dmg_time > get_gametime())
		return HAM_IGNORED
	
	static id
	id = pev(ent, pev_owner)
	
	if(pev(ent, pev_nade_type) == NADE_TYPE_STRIPBOMB)
	{ 
		if(has_bomb[id])
		{
			has_bomb[id] = 0
			stripbomb_explode(ent)
			return HAM_SUPERCEDE
		}
	}
	return HAM_IGNORED
}

public fw_SetModel(ent, const model[])
{	
	if (ent < 0)
		return FMRES_IGNORED
	
	if (pev(ent, pev_dmgtime) == 0.0)
		return FMRES_IGNORED
	
	new iOwner = pev(ent, pev_owner)
	
	if (has_bomb[iOwner] && equal(model[7], "w_sm", 4))
	{
		entity_set_model(ent, model_wgrenade_infect)
		
		// Reset any other nade
		set_pev (ent, pev_nade_type, 0 )
		set_pev (ent, pev_nade_type, NADE_TYPE_STRIPBOMB)
		
		fm_set_rendering(ent, kRenderFxGlowShell, 255, 0, 0, kRenderNormal, 16)
		
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(TE_BEAMFOLLOW) // TE id
		write_short(ent) // entity
		write_short(g_trailSpr) // sprite
		write_byte(10) // life
		write_byte(10) // width
		write_byte(255) // r
		write_byte(128) // g
		write_byte(0) // b
		write_byte(200) // brightness
		message_end()
		
		set_pev(ent, pev_nade_type, NADE_TYPE_STRIPBOMB)
	
		return FMRES_SUPERCEDE
	}
	return FMRES_IGNORED
}

public stripbomb_explode(ent)
{
	if (!zp_has_round_started())
		return;
	
	static Float:originF[3]
	pev(ent, pev_origin, originF)
	
	create_blast(originF)
	
	//engfunc(EngFunc_EmitSound, ent, CHAN_WEAPON, grenade_infect[random_num(0, sizeof grenade_infect - 1)], 1.0, ATTN_NORM, 0, PITCH_NORM)
	
	static attacker
	attacker = pev(ent, pev_owner)
	
	has_bomb[attacker] = 0
	
	static victim
	victim = -1
	while ((victim = engfunc(EngFunc_FindEntityInSphere, victim, originF, get_pcvar_float(cvar_radius))) != 0)
	{
		if (!is_user_alive(victim) || zp_get_user_zombie(victim) || zp_get_user_survivor(victim) || zp_get_user_wesker(victim) || 
		zp_get_user_depre(victim) || zp_get_user_sniper(victim) || zp_is_l4d_round())
			continue;
		
		switch(get_pcvar_num(cvar_mode))
		{
			case 0 :
			{
				if (pev(victim, pev_armorvalue) <= 0)
					continue;
				
				set_pev(victim, pev_armorvalue, 0);
			}
			case 1 :
			{
				fm_strip_user_weapons(victim)
				fm_give_item(victim, "weapon_knife")
			}
			case 2 :
			{
				if (pev(victim, pev_armorvalue) > 0)				
					set_pev(victim, pev_armorvalue, 0)
				
				fm_strip_user_weapons(victim)
				fm_give_item(victim, "weapon_knife")
			}
		}
	}
	
	engfunc(EngFunc_RemoveEntity, ent)
}

public create_blast(const Float:originF[3])
{
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
	write_byte(TE_BEAMCYLINDER) // TE id
	engfunc(EngFunc_WriteCoord, originF[0]) // x
	engfunc(EngFunc_WriteCoord, originF[1]) // y
	engfunc(EngFunc_WriteCoord, originF[2]) // z
	engfunc(EngFunc_WriteCoord, originF[0]) // x axis
	engfunc(EngFunc_WriteCoord, originF[1]) // y axis
	engfunc(EngFunc_WriteCoord, originF[2]+385.0) // z axis
	write_short(g_exploSpr) // sprite
	write_byte(0) // startframe
	write_byte(0) // framerate
	write_byte(4) // life
	write_byte(60) // width
	write_byte(0) // noise
	write_byte(255) // red
	write_byte(128) // green
	write_byte(0) // blue
	write_byte(200) // brightness
	write_byte(0) // speed
	message_end()
	
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
	write_byte(TE_BEAMCYLINDER) // TE id
	engfunc(EngFunc_WriteCoord, originF[0]) // x
	engfunc(EngFunc_WriteCoord, originF[1]) // y
	engfunc(EngFunc_WriteCoord, originF[2]) // z
	engfunc(EngFunc_WriteCoord, originF[0]) // x axis
	engfunc(EngFunc_WriteCoord, originF[1]) // y axis
	engfunc(EngFunc_WriteCoord, originF[2]+470.0) // z axis
	write_short(g_exploSpr) // sprite
	write_byte(0) // startframe
	write_byte(0) // framerate
	write_byte(4) // life
	write_byte(60) // width
	write_byte(0) // noise
	write_byte(255) // red
	write_byte(164) // green
	write_byte(0) // blue
	write_byte(200) // brightness
	write_byte(0) // speed
	message_end()
	
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
	write_byte(TE_BEAMCYLINDER) // TE id
	engfunc(EngFunc_WriteCoord, originF[0]) // x
	engfunc(EngFunc_WriteCoord, originF[1]) // y
	engfunc(EngFunc_WriteCoord, originF[2]) // z
	engfunc(EngFunc_WriteCoord, originF[0]) // x axis
	engfunc(EngFunc_WriteCoord, originF[1]) // y axis
	engfunc(EngFunc_WriteCoord, originF[2]+555.0) // z axis
	write_short(g_exploSpr) // sprite
	write_byte(0) // startframe
	write_byte(0) // framerate
	write_byte(4) // life
	write_byte(60) // width
	write_byte(0) // noise
	write_byte(255) // red
	write_byte(200) // green
	write_byte(0) // blue
	write_byte(200) // brightness
	write_byte(0) // speed
	message_end()
}

public EV_CurWeapon(id)
{
	if (!is_user_alive ( id ) || !zp_get_user_zombie(id))
		return PLUGIN_CONTINUE
	
	g_iCurrentWeapon[id] = read_data(2)
	
	if (has_bomb[id] && g_iCurrentWeapon[id] == CSW_SMOKEGRENADE)
	{
		set_pev(id, pev_viewmodel2, model_vgrenade_infect)
		set_pev(id, pev_viewmodel2, model_pgrenade_infect)
	}
	return PLUGIN_CONTINUE
}
