#include <amxmodx>
#include <hamsandwich>
#include <beams>
#include <zombiekillergalaxy>

enum tripmine_e
{
	TRIPMINE_IDLE1 = 0,
	TRIPMINE_IDLE2,
	TRIPMINE_ARM1,
	TRIPMINE_ARM2,
	TRIPMINE_FIDGET,
	TRIPMINE_HOLSTER,
	TRIPMINE_DRAW,
	TRIPMINE_WORLD,
	TRIPMINE_GROUND,
}

#define TAG "^x04[ZKG]^x01"
#define PevThinkType EV_INT_flTimeStepSound
#define PevTripmineOwner EV_INT_iuser2
#define PevBeamOwner EV_INT_iuser3
#define PevBeamTripOwner EV_INT_iuser4
#define TripmineBeamEndPoint EV_VEC_vuser1
#define ThinkTypePowerUp 2918
#define ThinkTypeBeam 3264

#define TASK_PLANT		3023
#define TASK_RELEASE		3069
#define TASK_PROTECTION		3899
#define ID_PROTECTION		(taskid - TASK_PROTECTION)

new const ClassnameTripmine[] = "class_tripmine"
new const ClassnameBreakable[] = "func_breakable"
new const ClassnameBeam[] = "class_beam"
new const ModelTripmine[] = "models/v_tripmine.mdl"
new const SoundDeploy[] = "weapons/mine_deploy.wav"
new const SoundCharge[]	= "weapons/mine_charge.wav"
new const SoundActive[]	= "weapons/mine_activate.wav"
new const SoundBeamStart[] = "debris/beamstart9.wav"
new const SoundGunPickup[] = "items/gunpickup2.wav"
new const SoundGlass[] = "debris/bustglass1.wav"
new const SoundGlass2[] = "debris/bustglass2.wav"
new const SprBeam[] = "sprites/laserbeam.spr"

#define flag_get(%1,%2)				(%1 & (1 << (%2 & 31)))
#define flag_set(%1,%2)				(%1 |= (1 << (%2 & 31)))
#define flag_unset(%1,%2)			(%1 &= ~(1 << (%2 & 31)))
new g_loading_laser;
new g_protection;

new SprBoom, MaxClients
new iPlayerTripmine[33]
new iPlayerDeployed[33]
new CvarDamage, CvarRadius, CvarKbForce, CvarHealth, CvarMaxAmmo, CvarMaxPlant, CvarColor[3]

new g_msgid_bartime, g_Hud

public plugin_init()
{
	register_plugin("[ZMIX] Lasers", "1.0", "LA BANDA")
	
	register_event("HLTV", "OnNewRound", "a", "1=0", "2=0")
	register_logevent("OnRoundStart", 2, "1=Round_Start")
	
	RegisterHam(Ham_Killed, "player", "OnPlayerKilled")
	
	register_think(ClassnameTripmine, "OnThink")
	register_touch(ClassnameBeam, "player", "OnTouch")
	register_forward( FM_TraceLine , "fw_TraceLine" );
	
	register_clcmd("say /lm", "native_get_user_laser" );
	register_clcmd("say_team /lm", "native_get_user_laser" );
	register_clcmd("+setlaser", "CargandoLaser" );
   	register_clcmd("-setlaser", "InterrupcionCargadoLaser" );
	register_clcmd("+dellaser", "DevolviendoLaser" );
   	register_clcmd("-dellaser", "InterrupcionDevolviendoLaser" );
	
	MaxClients = get_maxplayers()
	
	CvarDamage = register_cvar("tripmine_damage", "300")
	CvarRadius = register_cvar("tripmine_radius", "300")
	CvarKbForce = register_cvar("tripmine_kb_force", "5")
	CvarHealth = register_cvar("tripmine_health", "300")
	CvarMaxAmmo = register_cvar("tripmine_maxammo", "3")
	CvarMaxPlant = register_cvar("tripmine_maxplant", "21") //Value > 20 is not recommended
	CvarColor[0] = register_cvar("tripmine_color_r", "0")
	CvarColor[1] = register_cvar("tripmine_color_g", "100")
	CvarColor[2] = register_cvar("tripmine_color_b", "200")
	g_Hud = CreateHudSyncObj()
	g_msgid_bartime = get_user_msgid( "BarTime" );
}

public plugin_natives()
{
	register_native("zp_get_user_laser", "native_get_user_laser", 1)
}

public native_get_user_laser(id)
{
	if(!is_user_alive(id))
		return PLUGIN_HANDLED
	
	new money = zp_get_user_ammo_packs(id)
	new cost = 30
	
	if(IsEnabledBuy(id) == 0)
		return PLUGIN_HANDLED	
		
	if(IsEnabledBuy(id) == -1)
	{
		client_print(id, print_center, "No puedes comprar lasers ahora.")
		return PLUGIN_HANDLED
	}		
		
	if(money < cost)
	{
		client_print(id, print_center, "Te faltan %d Ammopacks para comprar una lasermine.", cost - money)
		return PLUGIN_HANDLED	
	}		
	
	if(TotalDeployedCount() >= get_pcvar_num(CvarMaxPlant))
	{
		client_print(id, print_center, "Hay muchas lasermiens puestas, Maximas: %d", get_pcvar_num(CvarMaxPlant))
		return PLUGIN_HANDLED		
	}
	
	if(iPlayerTripmine[id] + iPlayerDeployed[id] >= get_pcvar_num(CvarMaxAmmo))
	{
		client_print(id, print_center, "Tienes muchas lasermines: %i/%i", iPlayerTripmine[id] + iPlayerDeployed[id], get_pcvar_num(CvarMaxAmmo))
		return PLUGIN_HANDLED
	}
		
	iPlayerTripmine[id]++
	if(iPlayerTripmine[id] == 1) zp_colored_print(id, "%s Colocar Lasers:^x03 Letra ^"P^"^x04 //^x01 Sacar Lasers:^x03 Letra ^"C^"^x01.", TAG);
		
	if(!(get_user_flags(id) & ADMIN_IMMUNITY))
	{
		client_cmd(id, "echo ^"^";bind ^"p^" +setlaser")
		client_cmd(id, "echo ^"^";bind ^"c^" +dellaser")
	}
	emit_sound(id, CHAN_STREAM, SoundGunPickup, 1.0, ATTN_NORM, 0, PITCH_NORM)
	client_print(id, print_center, "Lasers disponibles: %i/%i", iPlayerTripmine[id], get_pcvar_num(CvarMaxAmmo))
		
	zp_set_user_ammo_packs(id, money - cost)
    	return PLUGIN_CONTINUE
}

stock IsEnabledBuy(id)
{
	if(!zp_has_round_started() || zp_is_survivor_round() || zp_is_wesker_round() || zp_is_synapsis_round() || zp_is_lnj_round()
	|| zp_is_l4d_round() || zp_is_ninja_round() || zp_is_depre_round() || zp_is_alien_round()
	|| zp_is_assassin_round() || zp_is_sniper_round() || zp_is_nemesis_round() || zp_is_swarm_round() || zp_is_plague_round())
		return -1
		
	if(zp_get_user_zombie(id) || zp_get_user_survivor(id) || zp_get_user_depre(id) || zp_get_user_wesker(id) || zp_get_user_sniper(id)
	|| zp_get_user_ninja(id))
		return 0
		
	return 1
}

public plugin_precache()
{
	SprBoom = precache_model("sprites/zerogxplode.spr")
	precache_model(ModelTripmine)
	precache_sound(SoundDeploy)
	precache_sound(SoundCharge)
	precache_sound(SoundActive)
	precache_sound(SoundBeamStart)
	precache_sound(SoundGunPickup)
	precache_sound(SoundGlass)
	precache_sound(SoundGlass2)
}

public client_putinserver(id)
{
	ResetValues(id)
	flag_unset(g_protection, id)
	remove_task(id+TASK_PROTECTION)
}

public client_disconnect(id)
{
	ResetValues(id)
	RemovePlayerTripMines(id)
	flag_unset(g_protection, id)
	remove_task(id+TASK_PROTECTION)
}

public OnNewRound()
{
	RemoveAllTripmines()
	
	for(new id = 1; id <= MaxClients; id++) 
		if(is_user_connected(id)) ResetValues(id)
}

public OnRoundStart()
{
	RemoveAllTripmines()
	
	for(new id = 1; id <= MaxClients; id++) 
		if(is_user_connected(id)) ResetValues(id)
	
}

public OnPlayerKilled(id)
{
	ResetValues(id)
	RemovePlayerTripMines(id)
	flag_unset(g_protection, id)
	remove_task(id+TASK_PROTECTION)
}

public OnBreakableTakeDamage(ent, inflictor, attacker, Float:damage, damagebits)
{
	if(!is_valid_ent(ent)) return HAM_IGNORED;
	
	static szClassName[32]
	entity_get_string(ent, EV_SZ_classname, szClassName, charsmax(szClassName))
	
	if(!(equal(szClassName, ClassnameTripmine))) return HAM_IGNORED;
	
	if(!is_user_connected(attacker)) return HAM_IGNORED;
	
	static Owner; Owner = entity_get_int(ent, PevTripmineOwner)
	
	if(is_user_connected(Owner) && (attacker == Owner) || zp_get_user_zombie(attacker)) 
		return HAM_IGNORED;
	
	return HAM_SUPERCEDE
}

public OnThink(ent)
{
	switch(entity_get_int(ent, PevThinkType))
	{
		case ThinkTypePowerUp:
		{
			entity_set_int(ent, EV_INT_solid, SOLID_BBOX)
			emit_sound(ent, CHAN_VOICE, SoundActive, 0.5, ATTN_NORM, 0, 75)
			
			new beam = Beam_Create(SprBeam, 10.0)
			if(!beam)
			{
				remove_entity(ent)
				return FMRES_IGNORED;
			}
			
			static Owner; Owner = entity_get_int(ent, PevTripmineOwner)
			if(!is_user_connected(Owner))
			{
				remove_entity(ent)
				return FMRES_IGNORED;
			}
			
			entity_set_int(beam, PevBeamOwner, Owner)
			entity_set_int(beam, PevBeamTripOwner, ent)
			entity_set_int(ent, PevBeamTripOwner, beam)
			entity_set_string(beam, EV_SZ_classname, ClassnameBeam)
			
			static Float:startOrigin[3], Float:endOrigin[3]
			entity_get_vector(ent, EV_VEC_origin, startOrigin)
			entity_get_vector(ent, TripmineBeamEndPoint, endOrigin)
			Beam_PointsInit(beam, startOrigin, endOrigin)

			new Float:Color[3]
			Color[0] = get_pcvar_float(CvarColor[0])
			Color[1] = get_pcvar_float(CvarColor[1])
			Color[2] = get_pcvar_float(CvarColor[2])
			Beam_SetColor(beam, Color)
			Beam_SetNoise(beam, 0)
			set_pev(ent, pev_renderfx, kRenderFxGlowShell)
			set_pev(ent, pev_rendercolor, Color)
			set_pev(ent, pev_rendermode, kRenderNormal)
			set_pev(ent, pev_renderamt, 0.0)
			
			set_pev(beam, pev_solid, SOLID_TRIGGER)
			set_pev(beam, pev_movetype, MOVETYPE_FLY)			
			
			entity_set_int(ent, PevThinkType, ThinkTypeBeam)
			set_pev(ent, pev_nextthink, get_gametime()+0.1)
		}
		case ThinkTypeBeam:
		{
			if(is_valid_ent(ent))
			{
				static Float:fHealth
				pev(ent, pev_health, fHealth)
				if(fHealth <= 0.0 || (pev(ent,pev_flags) & FL_KILLME))
				{
					set_pev(ent, pev_nextthink, 240.0)
					TripmineExplode(ent)
					return FMRES_IGNORED;
				}
			}

		}
	}
	
	return FMRES_IGNORED;
}

public OnTouch(ent, id)
{
	if(is_user_alive(id) && zp_get_user_zombie(id))
	{
		if(zp_get_user_antilaser(id) || zp_get_user_nemesis(id) || zp_get_user_nodamage(id)
		|| zp_get_user_assassin(id) || zp_get_user_alien(id) || flag_get(g_protection, id))
			return
			
		ExecuteHamB(Ham_Killed, id, entity_get_int(ent, PevBeamOwner), 2);
	}
}

public CargandoLaser(id)
{
	if(!ValidToUseLaser(id, 1) || !IsEnabledBuy(id))
		return PLUGIN_HANDLED;
		
	if(flag_get(g_loading_laser, id) || !IsOnWall(id)) 
		return PLUGIN_HANDLED;
	
	flag_set(g_loading_laser, id);
	
	message_begin(MSG_ONE, g_msgid_bartime, {0, 0, 0}, id );
	write_short(2);
	message_end();
	
	set_task(2.0, "CreateTripmine", id+TASK_PLANT);
	
	return PLUGIN_HANDLED;
}

stock bool:ValidToUseLaser(id, iMode = 0)
{
	if(!is_user_alive(id) || zp_get_user_zombie(id))
		return false
		
	if(iMode == 1)
	{
		if(!iPlayerTripmine[id])
		{
			client_print(id, print_center, "No tienes lasersmines")
			return false
		}
		else if((TotalDeployedCount() >= get_pcvar_num(CvarMaxPlant)))
		{
			client_print(id, print_center, "Hay muchas lasermines puestas, Maximas: %d", get_pcvar_num(CvarMaxPlant))
			return false			
		}
	}
	else if(iMode >= 2)
	{
		new iTarget, iBody,Float:vPlayerOrigin[3],Float:vTargetOrigin[3];
		get_user_aiming(id, iTarget, iBody);
		
		if(!is_valid_ent(iTarget)) return false;
		
		entity_get_vector(id, EV_VEC_origin, vPlayerOrigin);
		entity_get_vector(iTarget, EV_VEC_origin, vTargetOrigin);
		
		if(get_distance_f(vPlayerOrigin,vTargetOrigin) > 40.0) return false;
		
		new szClassName[32]
		entity_get_string(iTarget, EV_SZ_classname, szClassName, charsmax(szClassName));
		
		if(!(equal(szClassName, ClassnameTripmine))) 
			return false;
			
		new iOwnerBeam = entity_get_int(iTarget, PevTripmineOwner)
			
		if(iOwnerBeam != id)
			return false;
			
		if(iMode == 3)
		{
			iOwnerBeam = entity_get_int(iTarget, PevBeamTripOwner)
			if(is_valid_ent(iOwnerBeam)) remove_entity(iOwnerBeam)
			remove_entity(iTarget)
			
			flag_unset(g_loading_laser, id);
			remove_task(id+TASK_RELEASE);
			iPlayerDeployed[id]--;
			iPlayerTripmine[id]++;
			
			emit_sound(id, CHAN_ITEM, SoundGunPickup, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
			client_print(id, print_center, "Tripmines disponibles: %i/%i", iPlayerTripmine[id], get_pcvar_num(CvarMaxAmmo))
		}
	}
	return true
}

public InterrupcionCargadoLaser(id)
{
	if(!flag_get(g_loading_laser, id))
		return PLUGIN_HANDLED;
	
	flag_unset(g_loading_laser, id )
	remove_task(id+TASK_PLANT)
	
	message_begin(MSG_ONE, g_msgid_bartime, { 0, 0, 0 }, id);
	write_short(0);
	message_end();
	
	return PLUGIN_HANDLED;
}

public DevolverLaser(id)
{
	id -= TASK_RELEASE;
	
	if(!ValidToUseLaser(id, 3))
		return PLUGIN_HANDLED;
	
	return PLUGIN_HANDLED;
}

public DevolviendoLaser(id)
{
	if(!iPlayerDeployed[id] || flag_get(g_loading_laser, id))
		return PLUGIN_HANDLED;
		
	if(!ValidToUseLaser(id, 2))
		return PLUGIN_HANDLED;
		
	flag_set(g_loading_laser, id);
	
	message_begin(MSG_ONE, g_msgid_bartime, { 0, 0, 0 }, id );
	write_short(2);
	message_end();
	
	set_task(2.0, "DevolverLaser", id+TASK_RELEASE);
	
	return PLUGIN_HANDLED;
}

public InterrupcionDevolviendoLaser(id)
{
	if(!iPlayerDeployed[id] || !flag_get(g_loading_laser, id))
		return PLUGIN_HANDLED;
	
	flag_unset(g_loading_laser, id);
	remove_task(id+TASK_RELEASE);
	
	message_begin(MSG_ONE, g_msgid_bartime, { 0, 0, 0 }, id );
	write_short(0);
	message_end();
	
	return PLUGIN_HANDLED;
}

public fw_TraceLine( Float:fStart[3] , Float:fEnd[3] , Conditions , id , iTrace )
{
	static iEntity, szClassName[32], fHealth
	iEntity = get_tr2( iTrace , TR_pHit )
	
	if(is_valid_ent(iEntity))
	{
		entity_get_string(iEntity, EV_SZ_classname, szClassName, charsmax(szClassName))
		
		if(equal(szClassName, ClassnameTripmine))
		{
			fHealth = floatround(entity_get_float(iEntity, EV_FL_health))
			get_user_name(entity_get_int(iEntity, PevTripmineOwner), szClassName, charsmax(szClassName))
			set_hudmessage(0 , 130 , 255 , -1.0 , 0.60 , 0 , 0.001 , 0.25 , 0.01 , 0.01 , 2 );
			show_hudmessage( id , "Dueño: %s   |   Vida: %d", szClassName, fHealth)	
		}
	}
}  

#define xTIME 5
new g_fTime[33]
public zp_user_infected_post(id)
{
	ResetValues(id)
	RemovePlayerTripMines(id)
	
	remove_task(id+TASK_PROTECTION)
	flag_set(g_protection, id);
	g_fTime[id] = xTIME
	set_task(float(xTIME), "fnUnSetProtection", id+TASK_PROTECTION)
	set_task(1.0, "task2", id+TASK_PROTECTION, _, _, "a", xTIME)
}

public fnUnSetProtection(taskid)
{
	flag_unset(g_protection, ID_PROTECTION);
}

public task2(taskid)
{
	g_fTime[ID_PROTECTION] -= 1
	set_hudmessage(255, 0, 0, -1.0, -1.0, 1, 0.0, 0.9, 1.0, 1.0)
	ShowSyncHudMsg(ID_PROTECTION, g_Hud, "Proteccion de laser termina en: %d", g_fTime[ID_PROTECTION])
}
public zp_user_humanized_post(id)
{
	ResetValues(id)
	RemovePlayerTripMines(id)
	flag_unset(g_protection, id)
	remove_task(id+TASK_PROTECTION)
}

public CreateTripmine(id)
{
	id -= TASK_PLANT	
	
	if(!IsOnWall(id) || !CheckDistance(id) || !IsEnabledBuy(id)) 
		return;
	
	new ent = create_entity(ClassnameBreakable)
	
	if(!is_valid_ent(ent)) 
		return;
		
	entity_set_string(ent, EV_SZ_classname, ClassnameTripmine)
	entity_set_int(ent, EV_INT_movetype, MOVETYPE_FLY)
	entity_set_int(ent, EV_INT_solid, SOLID_NOT)
	entity_set_model(ent, ModelTripmine)
	entity_set_float(ent, EV_FL_frame, 0.0)
	entity_set_int(ent, EV_INT_body, 3)
	entity_set_int(ent, EV_INT_sequence, TRIPMINE_WORLD)
	entity_set_float(ent, EV_FL_framerate, 0.0)
	entity_set_size(ent, Float:{-4.0, -4.0, -4.0}, Float:{4.0, 4.0, 4.0})
	
	new Float:vNewOrigin[3], Float:vNormal[3], Float:vTraceDirection[3], Float:vTraceEnd[3], Float:vEntAngles[3], Float:vOrigin[3]
	entity_get_vector(id, EV_VEC_origin, vOrigin)
	velocity_by_aim(id, 128, vTraceDirection)
	xs_vec_add(vTraceDirection, vOrigin, vTraceEnd)
	engfunc(EngFunc_TraceLine, vOrigin, vTraceEnd, DONT_IGNORE_MONSTERS, id, 0)
		
	new Float:fFraction
	get_tr2(0, TR_flFraction, fFraction)
	if(fFraction < 1.0)
	{
		get_tr2(0, TR_vecEndPos, vTraceEnd)
		get_tr2(0, TR_vecPlaneNormal, vNormal)
	}
	
	xs_vec_mul_scalar(vNormal, 8.0, vNormal)
	xs_vec_add(vTraceEnd, vNormal, vNewOrigin)
	entity_set_origin(ent, vNewOrigin)
	vector_to_angle(vNormal, vEntAngles)
	set_pev(ent, pev_angles, vEntAngles)
	
	new Float:vBeamEnd[3], Float:vTracedBeamEnd[3]
	xs_vec_mul_scalar(vNormal, 8192.0, vNormal)
	xs_vec_add(vNewOrigin, vNormal, vBeamEnd)
	engfunc(EngFunc_TraceLine, vNewOrigin, vBeamEnd, IGNORE_MONSTERS, -1, 0)
	get_tr2(0, TR_vecPlaneNormal, vNormal)
	get_tr2(0, TR_vecEndPos, vTracedBeamEnd)
	entity_set_vector(ent, TripmineBeamEndPoint, vTracedBeamEnd)
	
	emit_sound(ent, CHAN_VOICE, SoundDeploy, 1.0, ATTN_NORM, 0, PITCH_NORM)
	emit_sound(ent, CHAN_BODY, SoundCharge, 0.2, ATTN_NORM, 0, PITCH_NORM)
	entity_set_int(ent, PevThinkType, ThinkTypePowerUp)

	entity_set_float(ent, EV_FL_nextthink, get_gametime()+1.0)
	entity_set_float(ent, EV_FL_takedamage, DAMAGE_YES)
	entity_set_float(ent, EV_FL_dmg, 100.0)
	entity_set_float(ent, EV_FL_health, get_pcvar_float(CvarHealth))
	entity_set_int(ent, PevTripmineOwner, id)
	
	iPlayerDeployed[id]++
	iPlayerTripmine[id]--
	
	remove_task(id+TASK_PLANT)
	flag_unset(g_loading_laser, id);
	
	static gotham
	
	if(!gotham) RegisterHamFromEntity(Ham_TakeDamage, ent, "OnBreakableTakeDamage");
	
	client_print(id, print_center, "Tripmines disponibles: %i/%i", iPlayerTripmine[id], get_pcvar_num(CvarMaxAmmo))
}

TripmineExplode(ent, id=0)
{
	emit_sound(ent, CHAN_BODY, SoundCharge, 0.2, ATTN_NORM, SND_STOP, PITCH_NORM)
	emit_sound(ent, CHAN_VOICE, SoundActive, 0.5, ATTN_NORM, SND_STOP, 75)
	
	new id2 = entity_get_int(ent, PevTripmineOwner)
	if(iPlayerDeployed[id2]) iPlayerDeployed[id2]--;
	
	new Float:vOrigin[3]
	pev(ent, pev_origin, vOrigin)
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vOrigin, 0)
	write_byte(TE_EXPLOSION)
	engfunc(EngFunc_WriteCoord, vOrigin[0])
	engfunc(EngFunc_WriteCoord, vOrigin[1])
	engfunc(EngFunc_WriteCoord, vOrigin[2])
	write_short(SprBoom)
	write_byte(40)
	write_byte(30)
	write_byte(10)
	message_end()
	
	new victim = -1, Float:cvar_damage = get_pcvar_float(CvarDamage), Float:cvar_radius = get_pcvar_float(CvarRadius), Float:cvar_force = get_pcvar_float(CvarKbForce)
	while((victim = find_ent_in_sphere(victim, vOrigin, cvar_radius)) != 0)
	{
		if(!is_user_alive(victim) || !zp_get_user_zombie(victim)) continue;
		
		new Float:fOrigin[3], Float:fDistance, Float:fDamage
		pev(victim, pev_origin, fOrigin)
		fDistance = get_distance_f(fOrigin, vOrigin)
		fDamage = cvar_damage - floatmul(cvar_damage, floatdiv(fDistance, cvar_radius))
		fDamage *= EstimateTakeHurt(vOrigin, victim, 0)
		
		if(fDamage < 0.1) continue;
		
		ManageEffectAction(victim, fOrigin, vOrigin, fDistance, fDamage * cvar_force)
		if(is_user_connected(id2) && zp_get_user_zombie(victim))
		{
			ExecuteHamB(Ham_TakeDamage, victim, ent, id2, fDamage, DMG_BULLET)
		}
	}
	
	if(id) ExecuteHamB(Ham_TakeDamage, id, ent, id2, cvar_damage, DMG_BULLET)
	
	new beam = entity_get_int(ent, PevBeamTripOwner)
	if(is_valid_ent(beam)) remove_entity(beam);
	remove_entity(ent)
}

TotalDeployedCount()
{
	new iCount=0, j
	for(j=1;j<=MaxClients;j++)
	{
		if(is_user_connected(j)) iCount += iPlayerDeployed[j];
	}

	return iCount;
}

stock bool:IsOnWall(id)
{
	new Float:vTraceDirection[3], Float:vTraceEnd[3], Float:vOrigin[3]
	pev(id, pev_origin, vOrigin)
	velocity_by_aim(id, 128, vTraceDirection)
	xs_vec_add(vTraceDirection, vOrigin, vTraceEnd)
	engfunc(EngFunc_TraceLine, vOrigin, vTraceEnd, DONT_IGNORE_MONSTERS, id, 0)
	
	new Float:fFraction, Float:vTraceNormal[3]
	get_tr2(0, TR_flFraction, fFraction)
	
	if(fFraction >= 1.0)
	{
		client_print(id, print_center, "No puedes colocar lasers aqui")
		return false;
	}
	
	get_tr2(0, TR_vecEndPos, vTraceEnd)
	get_tr2(0, TR_vecPlaneNormal, vTraceNormal)

	return true;
}

stock bool:CheckDistance(id)
{
	new Float:vTraceEnd[3], Float:vOrigin[3], iBody, iTarget
	get_user_aiming(id, iTarget, iBody, 350)
	entity_get_vector(iTarget, EV_VEC_origin, vTraceEnd)
	
	if(get_distance_f(vOrigin, vTraceEnd) > 40.0 || is_user_alive(iTarget))
	{
		client_print(id, print_center, "No puedes colocar lasers aqui.")
		return false;
	}
	return true
}

stock Float:EstimateTakeHurt(Float:fPoint[3], ent, ignored) 
{
	new Float:fOrigin[3], Float:fFraction, tr
	
	pev(ent, pev_origin, fOrigin)
	engfunc(EngFunc_TraceLine, fPoint, fOrigin, DONT_IGNORE_MONSTERS, ignored, tr)
	get_tr2(tr, TR_flFraction, fFraction)
	
	if(fFraction == 1.0 || get_tr2(tr, TR_pHit) == ent) return 1.0;
	
	return 0.6;
}

ManageEffectAction(iEnt, Float:fEntOrigin[3], Float:fPoint[3], Float:fDistance, Float:fDamage)
{
	new Float:Velocity[3]
	pev(iEnt, pev_velocity, Velocity)
	
	new Float:fTime = floatdiv(fDistance, fDamage)
	new Float:fVelocity[3]
	
	fVelocity[0] = floatdiv((fEntOrigin[0] - fPoint[0]), fTime) + Velocity[0]*0.5
	fVelocity[1] = floatdiv((fEntOrigin[1] - fPoint[1]), fTime) + Velocity[1]*0.5
	fVelocity[2] = floatdiv((fEntOrigin[2] - fPoint[2]), fTime) + Velocity[2]*0.5
	
	set_pev(iEnt, pev_velocity, fVelocity)
	
	return 1;
}

RemovePlayerTripMines(id)
{
	new ent = -1
	while((ent = find_ent_by_class(ent, ClassnameTripmine)) != 0)
		if(entity_get_int(ent, PevTripmineOwner) == id) remove_entity(ent)
	
	while((ent = find_ent_by_class(ent, ClassnameBeam)) != 0)
		if(entity_get_int(ent, PevBeamOwner) == id) remove_entity(ent)
}

RemoveAllTripmines()
{
	new ent = -1
	
	while((ent = find_ent_by_class(ent, ClassnameTripmine)) != 0)
		remove_entity(ent)
	
	while((ent = find_ent_by_class(ent, ClassnameBeam)) != 0)
		remove_entity(ent)
	
	for(new id = 1; id <= MaxClients; id++)
		if(is_user_connected(id)) iPlayerDeployed[id] = 0;
}

ResetValues(id)
{
	remove_task(id+TASK_PLANT)
	remove_task(id+TASK_RELEASE)
	flag_unset(g_loading_laser, id)
	iPlayerTripmine[id] = 0
	iPlayerDeployed[id] = 0
}
