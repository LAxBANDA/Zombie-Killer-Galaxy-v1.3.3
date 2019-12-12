/* Plugins By: LA BANDA 2013*/

#define PLUGINNAME        "[ZKG] Clases de Zombie"
#define VERSION           "1.4"
#define AUTHOR            "LA BANDA"

/* Configure This */
#define TAG "^x04[ZKG]^x01"
#define HOOKBUTTON IN_RELOAD
const MAXPLAYERS = 32 // Slots Server

/*-------------------------*/

#include <amxmodx> 
#include <zombiekillergalaxy>
#include <fakemeta>
#include <fakemeta_util>
#include <engine>
#include <hamsandwich>

/*=====================================================================================
                                 [Plugin Customization]
======================================================================================*/

enum _:DATA{
	NAME[40],
	INFO[40],
	PLAYMDL[40],
	KNIFEMDL[40],
	HEALTH,
	SPEED,
	Float:GRAVITY,
	Float:KB
}

enum _:ID{
	CLASSIC = 0,
	WATON,
	CAMUFLADO,
	REGENERADOR,
	HEADCRAB,
	VENENOSO,
	SCOUT,
	HUSK,
	BOOMER,
	BLINDADO,
	QUEMADO,
	ANTARTICO,
	THERMAL,
	CLOT,
	DEIMOS,
	STALKER,
	SCRAKE,
	HUNTER,
	HOUDEYE,
	SIREN,
	CHARGER,
	FLESHPOUND,
	BOOMER2
}

new const ZCLASSES[ID][DATA] ={
	{ "Clasico", "Atributos Normales", "zpre4_z_clasico", "v_knife_zombie_clasico.mdl", 2500, 270, 0.9, 0.8 },
	{ "Waton", "Mucho hp y lento", "zpre4_z_waton", "v_knife_zombie_waton.mdl", 6000, 210, 0.9, 1.7 },
	{ "Camuflado", "Traje Humano Camuflado", "guerilla", "v_knife_zombie_guerilla.mdl", 1900, 260, 0.8, 1.3 },
	{ "Regenerador" , "Regenera Su vida", "zpre4_z_regenerador", "v_knife_zombie_regenerador.mdl", 2500, 270, 0.85, 1.8 },
	{ "Headcrab", "Salto Alto y Poca Vida", "zpre4_z_headcrab", "v_knife_zombie_headcrab.mdl", 300, 400, 0.2, 1.0 },
	{ "Venenoso", "+500 HP x Infectado", "zpre4_z_venenoso", "v_knife_zombie_venenoso.mdl", 1900, 300, 0.85, 1.0 },
	{ "Scout", "Rapido, 0 KBack", "zpre4_z_scout", "v_knife_zombie_scout.mdl", 1800, 390, 0.85, 0.0 },
	{ "Husk", "Dispara Esferas de Fuego", "zpre4_z_husk", "v_knife_zombie_husk.mdl", 2000, 250, 0.9, 1.5 },
	{ "Boomer", "Explota Despues de Morir", "zpre4_z_boomer", "v_knife_zombie_boomer.mdl", 2900, 200, 1.0, 1.0 },
	{ "Blindado", "Solo Muere Con Pistolas", "zpre4_z_blindado", "v_knife_zombie_blindado.mdl", 800, 280, 0.9, 2.0 },
	{ "Quemado", "Inmune Al Fuego", "zpre4_z_quemado", "v_knife_zombie_quemado.mdl", 2000, 250, 0.85, 0.8 },
	{ "Antartico" , "Inmune Al Hielo", "zpre4_z_antartico", "v_knife_zombie_antartico.mdl", 1900, 280, 0.85, 0.8 },
	{ "Thermal", "Detecta Humanos", "zpre4_z_thermal", "v_knife_zombie_thermal.mdl", 2800, 260, 1.0, 1.3 },
	{ "Clot", "Aturde al atacar", "zpre4_z_clot", "v_knife_zombie_clot.mdl", 1800, 260, 0.8, 1.0 },
	{ "Deimos", "Bota Armas a Los Humanos", "zpre4_z_deimos", "v_knife_zombie_deimos.mdl", 2500, 240, 1.0, 1.0 },
	{ "Stalker KF", "Visible Al Atacar", "zpre4_z_stalker", "v_knife_zombie_stalker.mdl", 2500, 260, 1.0, 1.0 },
	{ "Scrake KF", "Mas Rapido Cuando Lo Atacan", "zpre4_z_scrake", "v_knife_zombie_scrake.mdl", 2900, 120, 0.9, 0.7 },
	{ "Hunter", "Salta Agachado", "zpre4_z_hunter", "v_knife_zombie_hunter.mdl", 1200, 290, 0.6, 1.0 },
	{ "Houdeye", "Campo Que Aleja Humanos", "zpre4_z_houndeye", "v_knife_zombie.mdl", 1400, 230, 0.5, 1.2 },
	{ "Siren", "Puede Gritar", "zpre4_z_siren", "v_knife_zombie_siren.mdl", 2000, 220, 0.5, 1.0 },	
	{ "Charger", "Corre & Empuja", "zpre4_z_charger", "v_knife_zombie_charger.mdl", 2200, 230, 1.0, 1.3 },
	{ "FleshPound", "Se Enfurece", "zpre4_z_fleshpound", "v_knife_zombie_fleshpound.mdl", 1600, 260, 0.8, 0.6 },
	{ "Boomer 2", "Tira Acido Encegecedor", "zpre4_z_boomer2", "v_knife_zombie_boomer2.mdl", 2800, 240, 0.9, 1.3 }
}

/* Const Sounds */
new const idle[] = "zpre4/fleshpound_infected.wav"

new const fury[] = "zpre4/fleshpound_rage.wav"

new const normaly[] = "zpre4/fleshpound_normal.wav"

new const g_sndExplode[] = "weapons/c4_explode1.wav"

new const deimos_sound[] = "zpre4/deimos_skill_hit.wav"

new const scrake_hit[] = "zpre4/scrake_talk.wav"

new const change[] = "zpre4/stalker_challenge.wav"

new const vomit_sounds[][] = 
{ 
	"zpre4/male_boomer_vomit_01.wav"
}

new const explode_sounds[][] = 
{ 
	"zpre4/explo_medium_09.wav"
}

new const houndeye_attack[][] = 
{ 
	"zpre4/he_attack1.wav"
}

new const houndeye_blast[][] = 
{ 
	"zpre4/he_blast1.wav" 
}

new const speed[][] = 
{ 
	"zpre4/charger_speed.wav",
	"zpre4/charger_speed2.wav"
}

new const smash[][] = 
{ 
	"zpre4/charger_smash.wav",
	"zpre4/charger_smash3.wav" 

}

new const leap_sound[][] = 
{ 
	"zpre4/hunter_jump.wav", 
	"zpre4/hunter_jump1.wav",
	"zpre4/hunter_jump2.wav",
	"zpre4/hunter_jump3.wav" 
}

new const husk_sound[][] = 
{ 
	"zpre4/zombie_husk/husk_pre_fire.wav", 
	"zpre4/zombie_husk/husk_wind_down.wav",
	"zpre4/zombie_husk/husk_fireball_fire.wav",
	"zpre4/zombie_husk/husk_fireball_loop.wav",
	"zpre4/zombie_husk/husk_fireball_explode.wav"
}

/* Const Sprites*/

new const fire_model[] = "sprites/3dmflared.spr"

new const beam_cylinder[] = "sprites/white.spr"

new const vomit_sprite[] = "sprites/steam1.spr"

/* Const Otros */
const FFADE_IN = 0x0000
const GIB_NEVER = 0
const UNIT_SECOND = (1<<12)
const NADE_TYPE_INFECTION = 	1111
const Float:PA_LOW = 25.0
const Float:PA_HIGH = 50.0

/*  Sprites & Models Indexs */
new g_trailSpr, g_smokeSpr, g_flameSpr, g_exploSpr, spr_smoke_steam1,mdl_gib_legbone, mdl_gib_flesh,mdl_gib_meat, mdl_gib_lung,mdl_gib_spine,
mdl_gib_head,spr_blood_drop,spr_blood_spray, spr_zerogxplode, sprite_playerheat, beamSpr, deimos_spr, g_sprRing, gSprBeam, vomit

/* Variables Globales Index */
new Float:g_iLastFire[MAXPLAYERS+1], Float:g_fDelay[MAXPLAYERS+1], Float:g_lastleaptime[MAXPLAYERS+1], Float:g_iLastVomit[ MAXPLAYERS+1 ]

new bool:lamuerteexplosiva[MAXPLAYERS+1], bool:g_cd[MAXPLAYERS+1], bool:g_iHateSpam[ MAXPLAYERS+1 ], bool:g_bInScreamProcess[MAXPLAYERS+1], 
bool:g_bCanDoScreams[MAXPLAYERS+1], bool:g_bKilledByScream[MAXPLAYERS+1], bool:g_bDoingScream[MAXPLAYERS+1]

new g_damage_scrake[MAXPLAYERS+1] , g_speed_scrake[MAXPLAYERS+1], g_burning_duration[MAXPLAYERS+1], g_ThermalOn[MAXPLAYERS+1], 
is_cooldown[MAXPLAYERS+1], i_cooldown_time[MAXPLAYERS+1], g_speeded[MAXPLAYERS+1], g_abil_one_used[MAXPLAYERS+1], g_empujar[MAXPLAYERS+1],
g_iPlayerTaskTimes[MAXPLAYERS+1], g_veces[MAXPLAYERS+1], i_fury_time[MAXPLAYERS+1]

/* Variables Server */
new giMaxplayers, g_maxplayers, xdattacker

new Float:g_abilonecooldown = 15.0

new g_iCvar_ScreamMode, g_iCvar_ScreamDuration, g_iCvar_ScreamDmg, 
g_iCvar_ScreamStartTime, Float:g_flCvar_ReloadTime, Float:g_flCvar_Radius,
g_iCvar_DamageMode, Float:g_flCvar_ScreamSlowdown, bool:g_bRoundEnding

/* CVARS */
new cvar_fury, cvar_furytime, cvar_speed, cvar_damage, cvar_time, cvar_vomitdist, cvar_explodedist, cvar_wakeuptime, cvar_vomitcooldown,
 cvar_victimrender, cvar_boomer_reward

/* MsgIds */
new gmsgDeathMsg, gmsgScoreInfo, g_msgScreenFade, g_msgScreenShake, gMsgBarTime, g_msgid_ScreenFade, gMsgDamage


/* TASKS & TASKID */
#define ID_FURY (taskid - TASK_FURY)
#define ID_BURN (taskid - TASK_BURN)
#define ID_AURA (taskid - TASK_AURA)
#define ID_STAL (taskid - TASK_STAL)

enum (+= 100)
{
	TASK_STAL = 2000,
	TASK_BURN,
	TASK_AURA,
	TASK_FURY,
	TASK_SCREAM,
	TASK_RELOAD,
	TASK_SCREAMDMG,
	TASK_BARTIME
}

/* Otras etiquetas no modificables */

#define PRIMARY_WEAPONS_BIT_SUM ((1<<CSW_SCOUT)|(1<<CSW_XM1014)|(1<<CSW_MAC10)|(1<<CSW_AUG)|(1<<CSW_UMP45)|(1<<CSW_SG550)|(1<<CSW_GALIL)|(1<<CSW_FAMAS)|(1<<CSW_AWP)|(1<<CSW_MP5NAVY)|(1<<CSW_M249)|(1<<CSW_M3)|(1<<CSW_M4A1)|(1<<CSW_TMP)|(1<<CSW_G3SG1)|(1<<CSW_SG552)|(1<<CSW_AK47)|(1<<CSW_P90)) 
#define zp_get_grenade_type(%1)		(entity_get_int(%1, EV_INT_flTimeStepSound))
#define is_user_valid_alive(%1) (1 <= %1 <= g_maxplayers && is_user_alive(%1))
#define is_user_valid_connected(%1) 	(1 <= %1 <= g_maxplayers && is_user_connected(%1))
#define is_player(%0)    (1 <= %0 <= giMaxplayers)

public plugin_init()
{
	register_plugin(PLUGINNAME, VERSION, AUTHOR)
	
	/* Cvars */
	cvar_vomitdist = register_cvar( "zp_boomer_vomit_dist", "300" )
	cvar_explodedist = register_cvar( "zp_boomer_explode_dist", "300" )
	cvar_wakeuptime = register_cvar( "zp_boomer_blind_time", "4" )
	cvar_vomitcooldown = register_cvar( "zp_boomer_vomit_cooldown", "15.0" )
	cvar_victimrender = register_cvar( "zp_boomer_victim_render", "1" )
	cvar_boomer_reward = register_cvar( "zp_boomer_ap_reward", "0" )
	cvar_speed = register_cvar("zp_charger_speed", "700.0")
	cvar_damage = register_cvar("zp_charger_damage", "10")
	cvar_time = register_cvar("zp_charger_time", "6.0")
	cvar_fury = register_cvar("zp_flesh_fury", "1")
	cvar_furytime = register_cvar("zp_flesh_fury_time", "5.0")
	
	/* MsgId */
	gmsgDeathMsg = get_user_msgid("DeathMsg")
	gmsgScoreInfo = get_user_msgid("ScoreInfo")
	g_msgid_ScreenFade = get_user_msgid( "ScreenFade" )
	gMsgBarTime = get_user_msgid("BarTime")
	g_msgScreenFade = get_user_msgid("ScreenFade")
	g_msgScreenShake = get_user_msgid("ScreenShake")
	gMsgDamage = get_user_msgid("Damage")
	
	/* Hamsandwich */
	RegisterHam(Ham_TraceAttack, "player", "fw_Player_TraceAttack")
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_knife", "fw_knife_post", 1)
	RegisterHam(Ham_Weapon_SecondaryAttack, "weapon_knife", "fw_knife_post", 1)
	RegisterHam(Ham_Spawn, "player", "fw_PlayerSpawn_Post", 1)
	RegisterHam(Ham_Killed, "player", "fw_PlayerKilled")	
	RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage")
	
	/* Fakemeta */
	register_forward(FM_CmdStart, "fw_CmdStart")
	register_forward(FM_Touch, "fw_Touch")
	register_forward(FM_PlayerPreThink, "fw_PlayerPreThink")
	
	/* Events */
	register_event("DeathMsg", "boomer_death", "a")
	register_event("NVGToggle", "Event_NVGToggle", "be")
	register_event( "DeathMsg", "event_DeathMsg", "a" )
	register_event("HLTV", "event_RoundStart", "a", "1=0", "2=0")
	
	/* Otros */
	register_logevent("roundStart", 2, "1=Round_Start")
	
	register_message(gmsgDeathMsg, "message_DeathMsg")

	register_touch("player", "player", "toco")
	
	register_clcmd( "boomer_vomit", "clcmd_vomit" )
	
	g_maxplayers = get_maxplayers()
}

public plugin_precache() 
{
	static i
	for(i = 0; i < sizeof ZCLASSES; i++)
		zp_register_zombie_class(ZCLASSES[i][NAME], ZCLASSES[i][INFO], ZCLASSES[i][PLAYMDL], ZCLASSES[i][KNIFEMDL], ZCLASSES[i][HEALTH], ZCLASSES[i][SPEED], ZCLASSES[i][GRAVITY], ZCLASSES[i][KB])
		
	precache_sound(idle)
	precache_sound(fury)
	precache_sound(normaly)
	precache_sound("zpre4/siren_scream.wav")
	precache_sound(change)
	precache_sound(scrake_hit)
	precache_sound("weapons/mortarhit.wav")
	precache_sound(g_sndExplode) 
	precache_sound(deimos_sound)
	
	gSprBeam = precache_model(beam_cylinder)
	
	for (i = 0; i < sizeof houndeye_attack; i++)
		precache_sound(houndeye_attack[i])
		
	for (i = 0; i < sizeof houndeye_blast; i++)
		precache_sound(houndeye_blast[i])
	
	for(i = 0; i < sizeof leap_sound; i++)
		precache_sound(leap_sound[i])
		
	for(i = 0; i < sizeof husk_sound; i++)
		precache_sound(husk_sound[i])
		
	for( new i = 0; i < sizeof vomit_sounds; i ++ )
		precache_sound( vomit_sounds[ i ] )
		
	for( new i = 0; i < sizeof explode_sounds; i ++ )
		precache_sound( explode_sounds[ i ] )
		
	for(new i = 0; i < sizeof speed; i ++)
		precache_sound(speed[i])
	
	for(new i = 0; i < sizeof smash; i ++)
		precache_sound(smash[i])
		
	mdl_gib_lung = precache_model("models/GIB_Lung.mdl")
	mdl_gib_meat = precache_model("models/GIB_B_Gib.mdl")
	mdl_gib_head = precache_model("models/GIB_Skull.mdl")
	mdl_gib_flesh = precache_model("models/Fleshgibs.mdl")
	mdl_gib_spine = precache_model("models/GIB_B_Bone.mdl")
	mdl_gib_legbone = precache_model("models/GIB_Legbone.mdl")
	precache_model("models/w_egon.mdl")
	
	spr_blood_drop = precache_model("sprites/blood.spr")
	spr_blood_spray = precache_model("sprites/bloodspray.spr")
	spr_zerogxplode = precache_model("sprites/zerogxplode.spr")
	spr_smoke_steam1 = precache_model("sprites/steam1.spr")
	spr_zerogxplode = precache_model("sprites/zerogxplode.spr")
	sprite_playerheat = precache_model("sprites/poison.spr")
	beamSpr = precache_model("sprites/lgtning.spr")
	deimos_spr = precache_model("sprites/zpre4/deimosexp.spr")
	g_trailSpr = precache_model("sprites/laserbeam.spr")
	g_smokeSpr = precache_model("sprites/black_smoke3.spr")
	g_flameSpr = precache_model("sprites/flame.spr")
	g_exploSpr = precache_model("sprites/zerogxplode.spr")
	g_sprRing = precache_model("sprites/shockwave.spr")
	vomit = precache_model( vomit_sprite )
	precache_model(fire_model)
} 

public plugin_cfg()
{
	cache_cvars()
}

public zp_user_infected_post(id, infector)
{
	if(!CheckIsZombie(id))
		return PLUGIN_HANDLED
		
	switch(zp_get_user_zombie_class(id))
	{
		case BOOMER:
		{
			lamuerteexplosiva[id] = true
			zp_colored_print(id, "%s Explotaras Despues de Morir", TAG)
		}
		case HUSK:
		{
			g_iLastFire[id] = 0.0
			
			zp_colored_print(id, "%s Para Dispararar la ^x04Esfera de Fuego^x01 presiona la letra ^x04^"R^"^x01.", TAG) 
			zp_colored_print(id, "%s Para Dispararar la ^x04Esfera de Fuego^x01 presiona la letra ^x04^"R^"^x01.", TAG) 
		}
		case BLINDADO:
		{
			zp_colored_print(id, "%s Recuerda Solo Te Pueden Matar ^x04Con Pistolas", TAG) 
		}
		case QUEMADO:
		{
			zp_colored_print(id, "%s Recuerda Eres^x04 Inmune Al^x03 Fuego", TAG)
			zp_get_user_antifuego(id)
			zp_get_user_noantihielo(id)
		}
		case ANTARTICO:
		{
			zp_get_user_antihielo(id)
			zp_get_user_noantifuego(id)
			zp_colored_print(id, "%s Recuerda Eres^x04 Inmune Al^x03 Hielo", TAG)
		}
		case CLOT:
		{
			zp_colored_print(id, "%s Eres^x04 Zombie Clot^x01, Atacas y Aturdes La Mirada Humana!.", TAG)
		}
		case DEIMOS:
		{
			zp_colored_print(id, "%s Apreta la Letra^x04 R^x01 Para Botar Las Armas Humanas!.", TAG)
			is_cooldown[id] = 0
			g_cd[id] = true
		}
		case STALKER:
		{
			zp_colored_print(id, "%s Eres^x03 Zombie Stalker^x01 Seras Visible Al Atacar", TAG)
			set_pev(id , pev_rendermode, kRenderTransAdd)
			set_pev(id , pev_renderamt, 10.0)
		}
		case SCRAKE:
		{
			g_speed_scrake[id] = 0
			g_damage_scrake[id] = 0
		}
		case HUNTER:
		{
			zp_colored_print(id, "%s Para Avanzar Rapido Presiona^x03 ^"CTRL + R^"", TAG)
		}	
		case SIREN:
		{
			g_bCanDoScreams[id] = true
			zp_colored_print(id, "%s Puedes Usar Tu ^x04Habilidad^x01 Presionando La Letra^x04 ^"R^"", TAG)
		}
		case CHARGER:
		{		
			zp_colored_print(id, "%s Haz Elegido a^x04 Charger ^x01Presiona^x04 R^x01 para tu^x04 Habilidad", TAG) 
			i_cooldown_time[id] = floatround(g_abilonecooldown)
			g_speeded[id] = false
			g_empujar[id] = false
			g_abil_one_used[id] = 0
			remove_task(id)
		}
		case FLESHPOUND:
		{
			zp_colored_print(id, "%s Tienes Solo 1 Adrenalina Presiona^x04 R^x01 Para Ocuparla", TAG) 
			g_speeded[id] = false
			g_veces[id] = get_pcvar_num(cvar_fury)
			i_fury_time[id] = get_pcvar_num(cvar_furytime)
			emit_sound(id, CHAN_STREAM, idle, 1.0, ATTN_NORM, 0, PITCH_HIGH)
			remove_task(id)
		}
		case BOOMER2:
		{
			zp_colored_print(id, "%s Apreta La Letra R Para Vomitar", TAG) 
		}
	}
	
	if(!is_user_connected(infector))
		return PLUGIN_HANDLED;

	static Class
	Class = zp_get_user_zombie_class(infector)
	
	if (Class == VENENOSO)
		set_pev(infector, pev_health, float(pev(infector, pev_health) + 400))
		
	if (Class == REGENERADOR)
	{

	}
	return PLUGIN_CONTINUE
} 

public zp_user_humanized_post(id, taskid)
{
	remove_task(id+TASK_AURA)
	lamuerteexplosiva[id] = false
	is_cooldown[id] = 0
	remove_task(id)
	g_speed_scrake[id] = 0
	g_damage_scrake[id] = 0
	stop_scream_task(id)
	g_bCanDoScreams[id] = false
	g_bDoingScream[id] = false
	g_iPlayerTaskTimes[id] = 0
	remove_task(id+TASK_RELOAD)
	remove_task(id+TASK_SCREAMDMG)
	remove_task(id)
	g_empujar[id] = false
	new id = ID_FURY
	remove_task(id+TASK_FURY)
}

public boomer_death() 
{ 	
	new victim = read_data(2)
	
	if(!lamuerteexplosiva[victim]) 
		return PLUGIN_HANDLED
			
	new Float:origin[3], origin2[3]
	entity_get_vector(victim,EV_VEC_origin,origin)
		
	origin2[0] = floatround(origin[0])
	origin2[1] = floatround(origin[1])
	origin2[2] = floatround(origin[2]) 
		
	if(!CheckIsZombie(victim))
		return HAM_IGNORED;
		
	if (zp_get_user_zombie_class(victim) != BOOMER)
		return HAM_IGNORED;
			
	emit_sound(victim, CHAN_WEAPON, "weapons/mortarhit.wav", 1.0, 0.5, 0, PITCH_NORM)
	emit_sound(victim, CHAN_VOICE, "weapons/mortarhit.wav", 1.0, 0.5, 0, PITCH_NORM) 
		
	for (new e = 1; e < 8; e++)
	{
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(TE_SPRITE)
		write_coord(origin2[0] + random_num(-60,60))
		write_coord(origin2[1] + random_num(-60,60))
		write_coord(origin2[2] +128)
		write_short(spr_zerogxplode)
		write_byte(random_num(30,65))
		write_byte(255)
		message_end()
	}
	for (new e = 1; e < 3; e++)
	{
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(TE_SMOKE)
		write_coord(origin2[0])
		write_coord(origin2[1])
		write_coord(origin2[2] + 256)
		write_short(spr_smoke_steam1)
		write_byte(random_num(80,150))
		write_byte(random_num(5,10))
		message_end()
	}
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_GUNSHOTDECAL)
	write_coord(origin2[0])
	write_coord(origin2[1])
	write_coord(origin2[2])
	write_short(0)			
	write_byte(random_num(46,48))  // decal
	message_end()
	
	new Max_Damage = 80
	new Damage_Radius = 200
	new PlayerPos[3], Distance, Damage
	
	for (new i = 1; i < g_maxplayers; i++) 
	{
		if(!is_user_alive(victim) || zp_get_user_zombie(victim))
			continue
			
		if (is_user_alive(i)) 
		{
			get_user_origin(i, PlayerPos)
			Distance = get_distance(PlayerPos, origin2)
			if (Distance <= Damage_Radius)
			{
				
				message_begin(MSG_ONE, g_msgScreenShake, {0,0,0}, i)  // Shake Screen
				write_short(1<<14)
				write_short(1<<14)
				write_short(1<<14)
				message_end()
				
				Damage = Max_Damage - floatround(floatmul(float(Max_Damage), floatdiv(float(Distance), float(Damage_Radius))))
					
				do_victim(i,victim,Damage,0)
			}
			
		}
		
	}
	lamuerteexplosiva[victim] = false
	return PLUGIN_HANDLED
}

public do_victim (victim,attacker,Damage,team_kill) 
{

	new namek[32],namev[32],authida[35],authidv[35],teama[32],teamv[32]

	get_user_name(victim,namev,31)
	get_user_name(attacker,namek,31)
	get_user_authid(victim,authidv,34)
	get_user_authid(attacker,authida,34)
	get_user_team(victim,teamv,31)
	get_user_team(attacker,teama,31)

	if(Damage >= get_user_health(victim)) 
	{
		if(get_cvar_num("mp_logdetail") == 3) 
		{
			log_message("^"%s<%d><%s><%s>^" attacked ^"%s<%d><%s><%s>^" with ^"bomber^" (hit ^"chest^") (Damage ^"%d^") (health ^"0^")",
			namek,get_user_userid(attacker),authida,teama,namev,get_user_userid(victim),authidv,teamv,Damage)
		
		}
		zp_colored_print(attacker, "%s Usted mató a^x04 %s ^x01por la Explosion del ^x04Boomer", TAG, namev)
		zp_colored_print(victim, "%s Usted fue asesinado por ^x04 %s ^x01por la explosion del ^x04Boomer", TAG, namek)
		if(team_kill == 0)
		{
			fm_set_user_frags(attacker,get_user_frags(attacker) + 1 )
		}
		
		set_msg_block(gmsgDeathMsg,BLOCK_ONCE)
		set_msg_block(gmsgScoreInfo,BLOCK_ONCE)

		user_kill(victim,1)

		replace_dm(attacker,victim,0)

		log_message("^"%s<%d><%s><%s>^" killed ^"%s<%d><%s><%s>^" with ^"bomber^"",
		namek,get_user_userid(attacker),authida,teama,namev,get_user_userid(victim),authidv,teamv)

		if (Damage > 100)
		{						
			new iOrigin[3]
			get_user_origin(victim,iOrigin)
			fm_set_user_rendering(victim,kRenderFxNone,0,0,0,kRenderTransAlpha,0)
			fx_gib_explode(iOrigin,3)
			fx_blood_large(iOrigin,5)
			fx_blood_small(iOrigin,15)
			iOrigin[2] = iOrigin[2] - 20
			fm_set_user_origin(victim,iOrigin)
		}
	}
	else 
	{
		fm_set_user_health(victim,get_user_health(victim) - Damage )
		if(get_cvar_num("mp_logdetail") == 3) 
		{
			log_message("^"%s<%d><%s><%s>^" attacked ^"%s<%d><%s><%s>^" with ^"bomber^" (hit ^"chest^") (Damage ^"%d^") (health ^"%d^")",
			namek,get_user_userid(attacker),authida,teama,namev,get_user_userid(victim),authidv,teamv,Damage,get_user_health(victim))
		}
		zp_colored_print(attacker, "%sUsted a daniado a:^x04 %s ^x01por la Explosion del ^x04Boomer", TAG, namev)
		zp_colored_print(victim, "%sUsted a sido daniado por:^x04 %s ^x01por la Explosion del ^x04Boomer", TAG, namek)
	}
}

public client_disconnect(id) 
{
	lamuerteexplosiva[id] = false
	remove_task(id+TASK_AURA)
	remove_task(id+TASK_BURN)
}  

public client_putinserver(id) 
{
	lamuerteexplosiva[id] = false
}  

public replace_dm (id,tid,tbody) 
{
	//Update killers scorboard with new info
	message_begin(MSG_ALL,gmsgScoreInfo)
	write_byte(id)
	write_short(get_user_frags(id))
	write_short(get_user_deaths(id))
	write_short(0)
	write_short(get_user_team(id))
	message_end()

	//Update victims scoreboard with correct info
	message_begin(MSG_ALL,gmsgScoreInfo)
	write_byte(tid)
	write_short(get_user_frags(tid))
	write_short(get_user_deaths(tid))
	write_short(0)
	write_short(get_user_team(tid))
	message_end()

	//Headshot Kill
	if (tbody == 1) 
	{
		message_begin( MSG_ALL, gmsgDeathMsg,{0,0,0},0)
		write_byte(id)
		write_byte(tid)
		write_string(" missile")
		message_end()
	}

	//Normal Kill
	else 
	{
		message_begin( MSG_ALL, gmsgDeathMsg,{0,0,0},0)
		write_byte(id)
		write_byte(tid)
		write_byte(0)
		write_string("missile")
		message_end()
		
	}

	return PLUGIN_CONTINUE
	
}
static fx_blood_small (origin[3],num) 
{
	// Small splash
	for (new j = 0; j < num; j++) 
	{
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
		write_byte(TE_WORLDDECAL)
		write_coord(origin[0]+random_num(-100,100))
		write_coord(origin[1]+random_num(-100,100))
		write_coord(origin[2]-36)
		write_byte(random_num(190,197)) // Blood decals
		message_end()
	}
	
}

static fx_blood_large (origin[3],num) 
{
	// Large splash
	for (new i = 0; i < num; i++) 
	{
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
		write_byte(TE_WORLDDECAL)
		write_coord(origin[0] + random_num(-50,50))
		write_coord(origin[1] + random_num(-50,50))
		write_coord(origin[2]-36)
		write_byte(random_num(204,205)) // Blood decals
		message_end()
	}
	
}

static fx_gib_explode (origin[3],num) 
{
	
	new flesh[3], x, y, z
	flesh[0] = mdl_gib_flesh
	flesh[1] = mdl_gib_meat
	flesh[2] = mdl_gib_legbone
	
	// Gib explosion
	// Head
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_MODEL)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2])
	write_coord(random_num(-100,100))
	write_coord(random_num(-100,100))
	write_coord(random_num(100,200))
	write_angle(random_num(0,360))
	write_short(mdl_gib_head)
	write_byte(0)
	write_byte(500)
	message_end()
	
	// Spine
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_MODEL)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2])
	write_coord(random_num(-100,100))
	write_coord(random_num(-100,100))
	write_coord(random_num(100,200))
	write_angle(random_num(0,360))
	write_short(mdl_gib_spine)
	write_byte(0)
	write_byte(500)
	message_end()
	
	// Lung
	for(new i = 0; i < random_num(1,2); i++) 
	{
		
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
		write_byte(TE_MODEL)
		write_coord(origin[0])
		write_coord(origin[1])
		write_coord(origin[2])
		write_coord(random_num(-100,100))
		write_coord(random_num(-100,100))
		write_coord(random_num(100,200))
		write_angle(random_num(0,360))
		write_short(mdl_gib_lung)
		write_byte(0)
		write_byte(500)
		message_end()
		
	}
	
	// Parts, 5 times
	for(new i = 0; i < 5; i++) 
	{
		
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
		write_byte(TE_MODEL)
		write_coord(origin[0])
		write_coord(origin[1])
		write_coord(origin[2])
		write_coord(random_num(-100,100))
		write_coord(random_num(-100,100))
		write_coord(random_num(100,200))
		write_angle(random_num(0,360))
		write_short(flesh[random_num(0,2)])
		write_byte(0)
		write_byte(500)
		message_end()
		
	}
	
	// Blood
	for(new i = 0; i < num; i++) 
	{
		x = random_num(-100,100)
		y = random_num(-100,100)
		z = random_num(0,100)
		
		for(new j = 0; j < 5; j++) 
		{
			message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
			write_byte(TE_BLOODSPRITE)
			write_coord(origin[0]+(x*j))
			write_coord(origin[1]+(y*j))
			write_coord(origin[2]+(z*j))
			write_short(spr_blood_spray)
			write_short(spr_blood_drop)
			write_byte(248)
			write_byte(15)
			message_end()
		}
		
	}
	
}
/*------------------------------------------------------------------------------------------------
 Empieza Zombie Husk Y Termina Zombie Boomer 
 ------------------------------------------------------------------------------------------------*/
 
public fw_PlayerSpawn_Post(id)
{
	if (!is_user_alive(id))
		return HAM_IGNORED
		
	if(zp_get_user_zombie_class(id) == DEIMOS && CheckIsZombie(id))
		g_cd[id] = true
	
	remove_task(id+TASK_AURA)
	remove_task(id+TASK_BURN)
	remove_task(id+TASK_RELOAD)
	remove_task(id+TASK_SCREAMDMG)
	stop_scream_task(id)
	g_bDoingScream[id] = false
	g_iPlayerTaskTimes[id] = 0
	return HAM_IGNORED
}

// Ham Player Killed Forward
public fw_PlayerKilled(victim, attacker, shouldgib)
{
	if (!zp_get_user_zombie(victim))
		remove_task(victim+TASK_BURN)
		
	if(zp_get_user_nemesis(victim) || !zp_get_user_assassin(victim) || zp_get_user_alien(victim))
		return HAM_IGNORED
		
	if(!is_user_valid_connected(victim))
		return HAM_IGNORED
		
	stop_scream_task(victim)
		
	g_bDoingScream[victim] = false
	g_iPlayerTaskTimes[victim] = 0
	
	remove_task(victim+TASK_RELOAD)
	remove_task(victim+TASK_SCREAMDMG)
		
	
	if(zp_get_user_zombie_class(victim) == STALKER)
		set_pev(victim , pev_rendermode, kRenderNormal)
    
	return HAM_IGNORED
}

public MakeFire(id)
{
	new Float:Origin[3]
	new Float:vAngle[3]
	new Float:flVelocity[3]
	
	// Get position from eyes
	get_user_eye_position(id, Origin)
	
	// Get View Angles
	entity_get_vector(id, EV_VEC_v_angle, vAngle)
	
	new NewEnt = create_entity("info_target")
	
	entity_set_string(NewEnt, EV_SZ_classname, "fireball")
	
	entity_set_model(NewEnt, fire_model)
	
	entity_set_size(NewEnt, Float:{ -1.5, -1.5, -1.5 }, Float:{ 1.5, 1.5, 1.5 })
	
	entity_set_origin(NewEnt, Origin)
	
	// Set Entity Angles (thanks to Arkshine)
	make_vector(vAngle)
	entity_set_vector(NewEnt, EV_VEC_angles, vAngle)
	
	entity_set_int(NewEnt, EV_INT_solid, SOLID_BBOX)
	
	entity_set_float(NewEnt, EV_FL_scale, 0.3)
	entity_set_int(NewEnt, EV_INT_spawnflags, SF_SPRITE_STARTON)
	entity_set_float(NewEnt, EV_FL_framerate, 25.0)
	set_rendering(NewEnt, kRenderFxNone, 0, 0, 0, kRenderTransAdd, 255)
	
	entity_set_int(NewEnt, EV_INT_movetype, MOVETYPE_FLY)
	entity_set_edict(NewEnt, EV_ENT_owner, id)
	
	// Set Entity Velocity
	velocity_by_aim(id, 700, flVelocity)
	entity_set_vector(NewEnt, EV_VEC_velocity, flVelocity)
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_BEAMFOLLOW) // TE id
	write_short(NewEnt) // entity
	write_short(g_trailSpr) // sprite
	write_byte(5) // life
	write_byte(6) // width
	write_byte(255) // r
	write_byte(0) // g
	write_byte(0) // b
	write_byte(255) // brightness
	message_end()
	
	set_task(0.2, "effect_fire", NewEnt, _, _, "b") 
	
	emit_sound(id, CHAN_ITEM, "zpre4/zombie_husk/husk_fireball_fire.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	emit_sound(NewEnt, CHAN_ITEM, "zpre4/zombie_husk/husk_fireball_loop.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
}

public effect_fire(entity)
{
	if (!pev_valid(entity))
	{
		remove_task(entity)
		return;
	}
	
	// Get origin
	static Float:originF[3]
	pev(entity, pev_origin, originF)
	
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
	write_byte(17)
	engfunc(EngFunc_WriteCoord, originF[0]) 		// x
	engfunc(EngFunc_WriteCoord, originF[1]) 		// y
	engfunc(EngFunc_WriteCoord, originF[2]+30) 		// z
	write_short(g_flameSpr)
	write_byte(5) 						// byte (scale in 0.1's) 188 - era 65
	write_byte(200) 					// byte (framerate)
	message_end()
	
	// Smoke
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
	write_byte(5)
	engfunc(EngFunc_WriteCoord, originF[0]) 	// x
	engfunc(EngFunc_WriteCoord, originF[1]) 	// y
	engfunc(EngFunc_WriteCoord, originF[2]) 	// z
	write_short(g_smokeSpr)				// short (sprite index)
	write_byte(13) 					// byte (scale in 0.1's)
	write_byte(15) 					// byte (framerate)
	message_end()	
	
	// Colored Aura
	engfunc(EngFunc_MessageBegin, MSG_PAS, SVC_TEMPENTITY, originF, 0)
	write_byte(TE_DLIGHT) 			// TE id
	engfunc(EngFunc_WriteCoord, originF[0])	// x
	engfunc(EngFunc_WriteCoord, originF[0])	// y
	engfunc(EngFunc_WriteCoord, originF[0])	// z
	write_byte(25) 				// radius
	write_byte(255) 			// r
	write_byte(128) 			// g
	write_byte(0) 				// b
	write_byte(2) 				// life
	write_byte(3) 				// decay rate
	message_end()
}

// Touch Forward
public fw_Touch(ent, id)
{
	if (!pev_valid(ent)) 
		return PLUGIN_HANDLED
	
	new class[32]
	pev(ent, pev_classname, class, charsmax(class))
	
	if(equal(class, "fireball"))
	{
		xdattacker = entity_get_edict(ent, EV_ENT_owner)
		husk_touch(ent)
		engfunc(EngFunc_RemoveEntity, ent)
		return PLUGIN_HANDLED
	}
	return PLUGIN_HANDLED
}

public husk_touch(ent)
{
	if (!pev_valid(ent)) 
		return;
	
	// Get origin
	static Float:originF[3]
	pev(ent, pev_origin, originF)
	
	// Explosion
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
	write_byte(TE_EXPLOSION)
	engfunc(EngFunc_WriteCoord, originF[0]) // x
	engfunc(EngFunc_WriteCoord, originF[1]) // y
	engfunc(EngFunc_WriteCoord, originF[2]) // z
	write_short(g_exploSpr)
	write_byte(40) 		// byte (scale in 0.1's) 188 - era 65
	write_byte(25) 		// byte (framerate)
	write_byte(TE_EXPLFLAG_NOSOUND) // byte flags
	message_end()
	
	emit_sound(ent, CHAN_ITEM, "zpre4/zombie_husk/husk_fireball_explode.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	
	// Collisions
	static victim
	victim = -1
	
	while ((victim = engfunc(EngFunc_FindEntityInSphere, victim, originF, 200.0)) != 0)
	{
		// Only effect alive zombies
		if (!is_user_valid_alive(victim) || zp_get_user_zombie(victim) || !is_user_valid_alive(xdattacker))
			continue;
		
		message_begin(MSG_ONE_UNRELIABLE, gMsgDamage, _, victim)
		write_byte(0) // damage save
		write_byte(0) // damage take
		write_long(DMG_BURN) // damage type
		write_coord(0) // x
		write_coord(0) // y
		write_coord(0) // z
		message_end()
		
		g_burning_duration[victim] += 5 * 5
		
		// Set burning task on victim if not present
		if (!task_exists(victim+TASK_BURN))
			set_task(0.2, "burning_flame", victim+TASK_BURN, _, _, "b")
	}
}

// Burning Flames
public burning_flame(taskid)
{
	// Get player origin and flags
	static origin[3], flags
	get_user_origin(ID_BURN, origin)
	flags = pev(ID_BURN, pev_flags)
	
	// in water - burning stopped
	if (zp_get_user_zombie(ID_BURN) || (flags & FL_INWATER) || g_burning_duration[ID_BURN] < 1)
	{
		// Smoke sprite
		message_begin(MSG_PVS, SVC_TEMPENTITY, origin)
		write_byte(TE_SMOKE) // TE id
		write_coord(origin[0]) // x
		write_coord(origin[1]) // y
		write_coord(origin[2]-50) // z
		write_short(g_smokeSpr) // sprite
		write_byte(random_num(15, 20)) // scale
		write_byte(random_num(10, 20)) // framerate
		message_end()
		
		// Task not needed anymore
		remove_task(taskid);
		return;
	}
	
	if ((pev(ID_BURN, pev_flags) & FL_ONGROUND) && 0.5 > 0.0)
	{
		static Float:velocity[3]
		pev(ID_BURN, pev_velocity, velocity)
		xs_vec_mul_scalar(velocity, 0.5, velocity)
		set_pev(ID_BURN, pev_velocity, velocity)
	}
	
	// Get player's health
	static health
	health = pev(ID_BURN, pev_health)
	
	if (health > 1)
		fm_set_user_health(ID_BURN, health - 1)
	else
	{
		if(is_user_valid_alive(xdattacker))
			death_message(xdattacker, ID_BURN, "fireball", 1)
	}
	
	// Flame sprite
	message_begin(MSG_PVS, SVC_TEMPENTITY, origin)
	write_byte(TE_SPRITE) // TE id
	write_coord(origin[0]+random_num(-5, 5)) // x
	write_coord(origin[1]+random_num(-5, 5)) // y
	write_coord(origin[2]+random_num(-10, 10)) // z
	write_short(g_flameSpr) // sprite
	write_byte(random_num(5, 10)) // scale
	write_byte(200) // brightness
	message_end()
	
	// Decrease burning duration counter
	g_burning_duration[ID_BURN]--
}


// Death message
public death_message(Killer, Victim, const Weapon [], ScoreBoard)
{
	// Block death msg
	set_msg_block(gmsgDeathMsg, BLOCK_SET)
	ExecuteHamB(Ham_Killed, Victim, Killer, 0)
	set_msg_block(gmsgDeathMsg, BLOCK_NOT)
	
	// Death
	make_deathmsg(Killer, Victim, 0, Weapon)
	
	// Update score board
	if (ScoreBoard)
	{
		message_begin(MSG_BROADCAST, gmsgScoreInfo)
		write_byte(Killer) // id
		write_short(pev(Killer, pev_frags)) // frags
		write_short(get_user_deaths(Killer)) // deaths
		write_short(0) // class?
		write_short(get_user_team(Killer)) // team
		message_end()
		
		message_begin(MSG_BROADCAST, gmsgScoreInfo)
		write_byte(Victim) // id
		write_short(pev(Victim, pev_frags)) // frags
		write_short(get_user_deaths(Victim)) // deaths
		write_short(0) // class?
		write_short(get_user_team(Victim)) // team
		message_end()
	}
}


public EndVictimAim(Touched)
{
	new Float:vec[3] = {-100.0,-100.0,-100.0}
	entity_set_vector(Touched,EV_VEC_punchangle,vec)  
	entity_set_vector(Touched,EV_VEC_punchangle,vec)
	entity_set_vector(Touched,EV_VEC_punchangle,vec)
}

public fw_Player_TraceAttack(iVictim, iAttacker, Float:flDamage, Float:vecDirection[3], iTr, iDamageType)
{	
	if (iVictim == iAttacker || !is_user_valid_alive(iAttacker))
		return HAM_IGNORED;
		
	if(zp_get_user_nemesis(iVictim) || zp_get_user_assassin(iVictim) || zp_get_user_alien(iVictim))
		return HAM_IGNORED;
		
	if(zp_get_user_survivor(iAttacker) || zp_get_user_depre(iAttacker) || zp_get_user_sniper(iAttacker) ||  zp_get_user_l4d(iAttacker, BILL) || zp_get_user_l4d(iAttacker, FRANCIS) || zp_get_user_l4d(iAttacker, LOUIS) || zp_get_user_l4d(iAttacker, ZOEY))
		return HAM_IGNORED;
	
	if(zp_get_user_zombie_class(iVictim) == BLINDADO)
	{				
		if (get_user_weapon(iAttacker) == CSW_SCOUT || get_user_weapon(iAttacker) == CSW_XM1014
		|| get_user_weapon(iAttacker) == CSW_MAC10|| get_user_weapon(iAttacker) == CSW_AUG
		|| get_user_weapon(iAttacker) == CSW_UMP45 || get_user_weapon(iAttacker) == CSW_SG550
		|| get_user_weapon(iAttacker) == CSW_GALIL || get_user_weapon(iAttacker) == CSW_FAMAS
		|| get_user_weapon(iAttacker) == CSW_MP5NAVY || get_user_weapon(iAttacker) == CSW_AWP
		|| get_user_weapon(iAttacker) == CSW_M249 || get_user_weapon(iAttacker) == CSW_M3
		|| get_user_weapon(iAttacker) == CSW_M4A1 || get_user_weapon(iAttacker) == CSW_TMP
		|| get_user_weapon(iAttacker) == CSW_G3SG1 || get_user_weapon(iAttacker) == CSW_SG552
		|| get_user_weapon(iAttacker) == CSW_AK47 || get_user_weapon(iAttacker) == CSW_P90)
		{			
			new Float:vecEndPos[3]
			get_tr2(iTr, TR_vecEndPos, vecEndPos)

			engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecEndPos, 0)
			write_byte(TE_SPARKS) // TE iId
			engfunc(EngFunc_WriteCoord, vecEndPos[0]) // x
			engfunc(EngFunc_WriteCoord, vecEndPos[1]) // y
			engfunc(EngFunc_WriteCoord, vecEndPos[2]) // z
			message_end()
					
			return HAM_SUPERCEDE;
		}
		
	}
	return PLUGIN_HANDLED
}


/*================================================================================
[Stocks]
=================================================================================*/

stock get_user_eye_position(id, Float:flOrigin[3])
{
	static Float:flViewOffs[3]
	entity_get_vector(id, EV_VEC_view_ofs, flViewOffs)
	entity_get_vector(id, EV_VEC_origin, flOrigin)
	xs_vec_add(flOrigin, flViewOffs, flOrigin)
}

stock make_vector(Float:flVec[3])
{
	flVec[0] -= 30.0
	engfunc(EngFunc_MakeVectors, flVec)
	flVec[0] = -(flVec[0] + 30.0)
}

public Event_NVGToggle(id)
	g_ThermalOn[id] = read_data(1)
stock te_sprite(id, Float:origin[3], sprite, scale, brightness)
{
	message_begin(MSG_ONE, SVC_TEMPENTITY, _, id)
	write_byte(TE_SPRITE)
	write_coord(floatround(origin[0]))
	write_coord(floatround(origin[1]))
	write_coord(floatround(origin[2]))
	write_short(sprite)
	write_byte(scale) 
	write_byte(brightness)
	message_end()
}

stock normalize(Float:fIn[3], Float:fOut[3], Float:fMul)
{
	new Float:fLen = xs_vec_len(fIn)
	xs_vec_copy(fIn, fOut)
	
	fOut[0] /= fLen, fOut[1] /= fLen, fOut[2] /= fLen
	fOut[0] *= fMul, fOut[1] *= fMul, fOut[2] *= fMul
}

public client_PostThink(id)
{
	if(!is_user_alive(id) || !CheckIsZombie(id))
		return PLUGIN_CONTINUE
	
	if(zp_get_user_zombie_class(id) != THERMAL)
		return PLUGIN_CONTINUE
	
	if((g_fDelay[id] + 0.2) > get_gametime())
		return PLUGIN_CONTINUE
	
	g_fDelay[id] = get_gametime()
	
	new Float:fMyOrigin[3]
	entity_get_vector(id, EV_VEC_origin, fMyOrigin)
	
	static Players[32], iNum
	get_players(Players, iNum, "a")
	for(new i = 0; i < iNum; ++i) if(id != Players[i])
	{
		new target = Players[i]
		
		new Float:fTargetOrigin[3]
		entity_get_vector(target, EV_VEC_origin, fTargetOrigin)
		
		if((get_distance_f(fMyOrigin, fTargetOrigin) > 500) 
		|| !is_in_viewcone(id, fTargetOrigin))
			continue

		new Float:fMiddle[3], Float:fHitPoint[3]
		xs_vec_sub(fTargetOrigin, fMyOrigin, fMiddle)
		trace_line(-1, fMyOrigin, fTargetOrigin, fHitPoint)
								
		new Float:fWallOffset[3], Float:fDistanceToWall
		fDistanceToWall = vector_distance(fMyOrigin, fHitPoint) - 10.0
		normalize(fMiddle, fWallOffset, fDistanceToWall)
		
		new Float:fSpriteOffset[3]
		xs_vec_add(fWallOffset, fMyOrigin, fSpriteOffset)
		new Float:fScale, Float:fDistanceToTarget = vector_distance(fMyOrigin, fTargetOrigin)
		if(fDistanceToWall > 500.0)
			fScale = 8.0 * (fDistanceToWall / fDistanceToTarget)
		else
			fScale = 2.0
	
		te_sprite(id, fSpriteOffset, sprite_playerheat, floatround(fScale), 125)
	}
	return PLUGIN_CONTINUE
}

public roundStart()
{
	for(new i = 1; i <= g_maxplayers; i++)
	{
		remove_task(i+TASK_AURA)
		is_cooldown[i] = 0
		remove_task(i)
		i_cooldown_time[i] = floatround(g_abilonecooldown)
		g_abil_one_used[i] = 0
		g_speeded[i] = false
		i_fury_time[i] = get_pcvar_num(cvar_furytime)
	}
}

public fw_TakeDamage(victim, inflictor, attacker, Float:damage, damage_type)
{
	if(!is_user_alive(victim) || !is_user_alive(inflictor) || !is_user_alive(attacker))
		return HAM_IGNORED
			
	if(zp_get_user_zombie_class(attacker) == CLOT && zp_get_user_zombie(attacker) && !zp_get_user_nemesis(attacker) 
	&& !zp_get_user_assassin(attacker) && !zp_get_user_alien(attacker))
	{
		if(!zp_get_user_zombie(victim) &&!zp_get_user_survivor(victim) && !zp_get_user_wesker(victim)
		&& !zp_get_user_sniper(victim) && !zp_get_user_depre(victim) && !zp_get_user_ninja(victim)&& !zp_get_user_l4d(victim, BILL) && !zp_get_user_l4d(victim, FRANCIS) && !zp_get_user_l4d(victim, LOUIS) && !zp_get_user_l4d(victim, ZOEY))
		{
			
			message_begin(MSG_ONE, g_msgScreenFade, _, victim)
			write_short((1<<12)) // duration
			write_short(0) // hold time
			write_short(0x0000) // fade type
			write_byte(180) // red
			write_byte(0) // green
			write_byte(0) // blue
			write_byte(200) // alpha
			message_end()
			
			new Float:fVec[3]
			fVec[0] = random_float(50.0, 150.0)
			fVec[1] = random_float(50.0, 150.0)
			fVec[2] = random_float(50.0, 150.0)
			
			set_pev(victim, pev_punchangle, fVec)
			return HAM_IGNORED
		}
	}
	else if(zp_get_user_zombie_class(victim) == SCRAKE && zp_get_user_zombie(victim) && !zp_get_user_zombie(attacker) && !zp_get_user_nemesis(victim) 
	&& !zp_get_user_assassin(victim) && !zp_get_user_alien(victim))
	{
		g_damage_scrake[victim] += floatround(damage)
		
		while(g_damage_scrake[victim] >= 100 && g_speed_scrake[victim] < 20)
		{
			if(g_speed_scrake[victim] != 99)
			{
				g_damage_scrake[victim]-= 100
				g_speed_scrake[victim]++
				zp_colored_print( victim , "^x04%s^x01 Tu Velocidad ha^x04 Aumentado", TAG)
			}
			else
			{
				g_damage_scrake[victim]-= 100
				g_speed_scrake[victim]++
				zp_colored_print( victim , "^x04%s^x01 Esta sera la ultima vez que tu Velocidad^x04 Aumente", TAG)
			}
			emit_sound(victim , CHAN_STREAM, scrake_hit , 1.0, ATTN_NORM, 0, PITCH_HIGH)
		}
		return HAM_IGNORED
	}
	return PLUGIN_CONTINUE
}

drop_weapon(id)
{
	new target, body
	static Float:start[3]
	static Float:aim[3]
	
	pev(id, pev_origin, start)
	fm_get_aim_origin(id, aim)
	
	start[2] += 16.0; // raise
	aim[2] += 16.0; // raise
	get_user_aiming ( id, target, body, 1000)
	
	if(is_user_alive( target ) && !zp_get_user_l4d(target, BILL) && !zp_get_user_l4d(target, FRANCIS) && !zp_get_user_l4d(target, LOUIS) && !zp_get_user_l4d(target, ZOEY) && !zp_get_user_zombie( target ) && !zp_get_user_survivor(target) && !zp_get_user_depre(target) && !zp_get_user_wesker(target) && !zp_get_user_sniper(target))
	{	
		message_begin(MSG_BROADCAST ,SVC_TEMPENTITY)
		write_byte(TE_EXPLOSION)
		engfunc(EngFunc_WriteCoord, aim[0])
		engfunc(EngFunc_WriteCoord, aim[1])
		engfunc(EngFunc_WriteCoord, aim[2])
		write_short(deimos_spr)
		write_byte(10)
		write_byte(30)
		write_byte(4)
		message_end()
		
		emit_sound(id, CHAN_WEAPON, deimos_sound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		
		drop(target)
	}	
	
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(0)
	engfunc(EngFunc_WriteCoord,start[0]);
	engfunc(EngFunc_WriteCoord,start[1]);
	engfunc(EngFunc_WriteCoord,start[2]);
	engfunc(EngFunc_WriteCoord,aim[0]);
	engfunc(EngFunc_WriteCoord,aim[1]);
	engfunc(EngFunc_WriteCoord,aim[2]);
	write_short(beamSpr); // sprite index
	write_byte(0); // start frame
	write_byte(30); // frame rate in 0.1's
	write_byte(10); // life in 0.1's
	write_byte(100); // line width in 0.1's
	write_byte(10); // noise amplititude in 0.01's
	write_byte(200); // red
	write_byte(200); // green
	write_byte(0); // blue
	write_byte(100); // brightness
	write_byte(50); // scroll speed in 0.1's
	message_end();
	set_task(15.0, "reset_cooldown2", id );
}

stock drop(id) 
{
	new weapons[32], num
	get_user_weapons(id, weapons, num)
	for (new i = 0; i < num; i++) {
		if (PRIMARY_WEAPONS_BIT_SUM & (1<<weapons[i])) 
		{
			static wname[32]
			get_weaponname(weapons[i], wname, sizeof wname - 1)
			engclient_cmd(id, "drop", wname)
		}
	}
}

public reset_cooldown2(id)
{
	g_cd[id] = true
	zp_colored_print(id, "%s Enhorabuena,^x04 tu habilidad esta lista^x01, para usarla apreta la letra^x04 ^"^x03R^x04^"^x01 para usarla.", TAG)
}

public fw_PlayerPreThink(id)
{
	if(!is_user_alive(id))
		return FMRES_IGNORED;
	
	if(!CheckIsZombie(id))
		return FMRES_IGNORED;
		
	static iButton; iButton = pev(id, pev_button)
	static iOldButton; iOldButton = pev(id, pev_oldbuttons)
	static Class; Class = zp_get_user_zombie_class(id)
	
	switch(Class)
	{
		case CHARGER:set_pev(id, pev_maxspeed, g_speeded[id] ? get_pcvar_float(cvar_speed) : float(ZCLASSES[CHARGER][SPEED]))
		case FLESHPOUND:
		{
			set_pev(id, pev_maxspeed, g_speeded[id] ? 600.0 : float(ZCLASSES[FLESHPOUND][SPEED]))
			if (!(iOldButton & IN_RELOAD) && (iButton & IN_RELOAD))
				clcmd_furia(id)
		}
		case SCRAKE:
		{
			if(g_speed_scrake[id])
			{
				new Float:speed_result = 30.0 * g_speed_scrake[id]
				set_pev(id, pev_maxspeed, 120.0 + speed_result)
			}
		}
	}
	return PLUGIN_HANDLED
}
public fw_CmdStart(id, handle, random_seed)
{
	if(!is_user_alive(id))
		return FMRES_IGNORED;
	
	if(!CheckIsZombie(id))
		return FMRES_IGNORED;
	
	static iInUseButton, iInUseOldButton, Class; 
	iInUseButton = (get_uc(handle, UC_Buttons)); iInUseOldButton = (get_user_oldbutton(id)); Class = zp_get_user_zombie_class(id)
	
	switch(Class)
	{
		case SIREN:
		{
			if(iInUseButton & HOOKBUTTON)
			{
				if(!(iInUseOldButton & HOOKBUTTON) && g_bCanDoScreams[id] && !g_bDoingScream[id] && !g_bRoundEnding)
				{
					message_begin(MSG_ONE, gMsgBarTime , _, id)
					write_byte(g_iCvar_ScreamStartTime) // time
					write_byte(0) // unknown
					message_end()
					
					// Update bool
					g_bInScreamProcess[id] = true
					
					// Next scream time
					set_task(g_iCvar_ScreamStartTime + 0.2, "task_do_scream", id+TASK_SCREAM)
					
					return FMRES_HANDLED
				}
			}
			else
			{
				// Last used button it's +use
				if(iInUseOldButton & HOOKBUTTON && g_bInScreamProcess[id])
				{
					// Stop scream main task
					stop_scream_task(id)
					
					return FMRES_HANDLED
				}
			}
		}
		case DEIMOS:
		{
			if (!g_cd[id])
				return FMRES_IGNORED
			
			if(iInUseButton & HOOKBUTTON)
			{
				drop_weapon(id)
				g_cd[id] = false
			}
			
			iInUseButton &= ~HOOKBUTTON
			set_uc(handle, UC_Buttons, iInUseButton)
			
			return FMRES_HANDLED
		}
		case HOUDEYE:
		{
			if((iInUseButton & HOOKBUTTON) && !(iInUseOldButton & HOOKBUTTON))
			{
				message_begin(MSG_ONE, gMsgBarTime, _, id)
				write_byte(2)
				write_byte(0)
				message_end()
				
				emit_sound(id, CHAN_VOICE, houndeye_attack[random_num(0, sizeof houndeye_attack - 1)], 1.0, ATTN_NORM, 0, PITCH_NORM)
				
				set_task(2.0, "blast_players", id+TASK_BARTIME)
			}
					
			if(iInUseOldButton & HOOKBUTTON && !( iInUseButton & HOOKBUTTON ) )
				set_task(0.1, "blast_stop", id)
				
			return FMRES_HANDLED
		}
		case HUSK:
		{
			if((iInUseButton & HOOKBUTTON) && !(iInUseOldButton & HOOKBUTTON))
			{			
				if(get_gametime() - g_iLastFire[id] < 15.0)
				{
					zp_colored_print(id, "%s Tienes que esperar ^x04%.1f^x01 segundos, para volver a tirar una ^x04Esfera de fuego^x01", TAG, 15.0 - (get_gametime() - g_iLastFire[id]))
					return FMRES_HANDLED
				}
				
				g_iLastFire[id] = get_gametime()
				
				message_begin(MSG_ONE, gMsgBarTime, _, id)
				write_byte(1)
				write_byte(0)
				message_end()
				
				emit_sound(id, CHAN_ITEM, "zpre4/zombie_husk/husk_pre_fire.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
				
				set_task(1.0, "MakeFire", id)
			}
			
			if(iInUseOldButton & HOOKBUTTON && !(iInUseButton & HOOKBUTTON))
			{
				if(task_exists(id))
				{
					zp_colored_print(id, "%s Para Tirar una ^x04Esfera de Fuego ^x01debes Mantener Presionada la Letra ^x04^"R^"^x01.", TAG)
					g_iLastFire[id] = 0.0
					emit_sound(id, CHAN_ITEM, "zpre4/zombie_husk/husk_wind_down.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
				}
				
				message_begin(MSG_ONE, gMsgBarTime, _, id)
				write_byte(0)
				write_byte(0)
				message_end()
				
				remove_task(id)
			}
		}
		case CHARGER:
		{
			if ((iInUseOldButton & HOOKBUTTON) && !(iInUseButton & HOOKBUTTON))
				use_ability_one(id)
		}	
		case HUNTER:
		{
			if (!((pev(id, pev_flags) & FL_ONGROUND) && (pev(id, pev_flags) & FL_DUCKING)))
				return HAM_IGNORED;
			
			static buttons
			buttons = pev(id, pev_button)
			
			// Not doing a longjump (added bot support)
			if (!(buttons & HOOKBUTTON) && !is_user_bot(id))
				return HAM_IGNORED;
			
			static Float:cooldown
			cooldown = 1.0
			
			if (get_gametime() - g_lastleaptime[id] < cooldown)
				return HAM_IGNORED;
		
			static Float:velocity[3]
			velocity_by_aim(id, 600, velocity)
			set_pev(id, pev_velocity, velocity)
				
			emit_sound(id, CHAN_STREAM, leap_sound[random_num(0, sizeof leap_sound -1)], 1.0, ATTN_NORM, 0, PITCH_HIGH)
				
			// Set the current super jump time
			g_lastleaptime[id] = get_gametime()
		}
		case BOOMER2:
		{
			if(!g_iHateSpam[id])
			{
				if( ( get_user_button( id ) & HOOKBUTTON ) )
				{
					g_iHateSpam[ id ] = true
					clcmd_vomit( id )
					set_task( 1.0, "StopSpam_XD", id )
				}
			}
		}
	}
	
	return FMRES_IGNORED
}

public zp_user_unfrozen(id)
{
	if(!CheckIsZombie(id))
		return PLUGIN_CONTINUE
		
	if (zp_get_user_zombie_class(id) != STALKER)
		return PLUGIN_CONTINUE
		
	fm_set_user_rendering(id)
	set_pev(id , pev_rendermode, kRenderTransAdd)
	set_pev(id , pev_renderamt, 10.0)
	
	return PLUGIN_CONTINUE
}
public fw_knife_post(knife)
{
	new id = get_pdata_cbase(knife, 41, 4)
    
	if(!is_user_alive(id))
		return HAM_IGNORED
		
	if(!CheckIsZombie(id))
		return HAM_IGNORED
		
	if(zp_get_user_zombie_class(id) != STALKER)
		return HAM_IGNORED
		
	zp_colored_print(id, "%s Te Has Vuelto^x03 Visible^x01 , Seras Invisible en^x04 0.4 Seg^x03.", TAG)
	set_pev(id , pev_rendermode, kRenderNormal)
	remove_task(id+TASK_STAL)
	set_task(0.4 , "stal2" , id+TASK_STAL)
	emit_sound(id, CHAN_STREAM, change , VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	
	return HAM_IGNORED
}  
 
public stal2(taskid)
{
	new id = ID_STAL
    
	fm_set_user_rendering(id)
	set_pev(id , pev_rendermode, kRenderTransAdd)
	set_pev(id , pev_renderamt, 10.0)
	zp_colored_print(id, "%s Has vuelto a ser^x04 Invisible", TAG)
}

public blast_stop(id)
{
	if(!is_user_alive(id))
		return
		
	message_begin(MSG_ONE, gMsgBarTime, _, id)
	write_byte(0)
	write_byte(0)
	message_end()
	
	remove_task(id+TASK_BARTIME)
}

public blast_players(id)
{
	if(is_user_alive(id))	
		return PLUGIN_HANDLED;
		
	id -= TASK_BARTIME
	
	new Float: iOrigin[3]
	pev(id, pev_origin, iOrigin)
	
	emit_sound(id, CHAN_VOICE, houndeye_blast[random_num(0, sizeof houndeye_blast - 1)], 1.0, ATTN_NORM, 0, PITCH_NORM)
	
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, iOrigin, 0)
	write_byte(TE_BEAMCYLINDER)
	engfunc(EngFunc_WriteCoord, iOrigin[0])
	engfunc(EngFunc_WriteCoord, iOrigin[1])
	engfunc(EngFunc_WriteCoord, iOrigin[2])
	engfunc(EngFunc_WriteCoord, iOrigin[0])
	engfunc(EngFunc_WriteCoord, iOrigin[1])
	engfunc(EngFunc_WriteCoord, iOrigin[2]+385.0)
	write_short(gSprBeam)
	write_byte(0)
	write_byte(0)
	write_byte(6)
	write_byte(200)
	write_byte(0)
	write_byte(255)
	write_byte(255)
	write_byte(255)
	write_byte(200)
	write_byte(0)
	message_end()
	
	static Ent, Float: originF[3]
	
	while( (Ent = engfunc(EngFunc_FindEntityInSphere, Ent, iOrigin, 200.0)) )
	{
		if( is_player(Ent) && Ent != id )
		{
			if(zp_get_user_zombie(Ent))
				return PLUGIN_CONTINUE;
			
			if(get_user_health(Ent) - 80 >= 1)
				fm_set_user_health(Ent, pev(Ent, pev_health) - 80)
			
			pev(Ent, pev_origin, originF)
			
			originF[0] = (originF[0] - iOrigin[0]) * 10.0 
			originF[1] = (originF[1] - iOrigin[1]) * 10.0 
			originF[2] = (originF[2] - iOrigin[2]) + 900.0
			
			set_pev(Ent, pev_velocity, originF)
		}
	}
	
	return PLUGIN_HANDLED;
}

public task_do_scream(id)
{
	// Normalize task
	id -= TASK_SCREAM
	
	// Do scream sound
	emit_sound(id, CHAN_STREAM, "zpre4/siren_scream.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
	
	// Block screams
	g_bCanDoScreams[id] = false
	
	// Reload task
	set_task(g_flCvar_ReloadTime, "task_reload_scream", id+TASK_RELOAD)
	
	// Now it's doing an scream
	g_bDoingScream[id] = true
	
	// Get his origin coords
	static iOrigin[3]
	get_user_origin(id, iOrigin)
	
	// Do a good effect, life the original Killing Floor.
	message_begin(MSG_PVS, SVC_TEMPENTITY, iOrigin) 
	write_byte(TE_LAVASPLASH)
	write_coord(iOrigin[0]) 
	write_coord(iOrigin[1]) 
	write_coord(iOrigin[2]) 
	message_end()
	
	// Scream damage task
	set_task(0.1, "task_scream_process", id+TASK_SCREAMDMG, _, _, "b")
}

public task_reload_scream(id)
{
	// Normalize taks
	id -= TASK_RELOAD
	
	// Can do screams again
	g_bCanDoScreams[id] = true
	
	// Message
	zp_colored_print(id, "%s Listo, Ya Puedes ^x04Usar Tu Habilidad^x01 Otra Vez", TAG)
	zp_colored_print(id, "%s Recuerda, Presiona La Letra^x04 ^"R^"^x01 Para Usar Tu^x03 Habilidad", TAG)
}

public task_scream_process(id)
{
	// Normalize task
	id -= TASK_SCREAMDMG
	
	// Time exceed
	if(g_iPlayerTaskTimes[id] >= (g_iCvar_ScreamDuration*10) || g_bRoundEnding)
	{
		// Remove player task
		remove_task(id+TASK_SCREAMDMG)
		
		// Reset task times count
		g_iPlayerTaskTimes[id] = 0
		
		// Update bool
		g_bDoingScream[id] = false
		
		return;
	}
	
	// Update player task time
	g_iPlayerTaskTimes[id]++
	
	// Get player origin
	static Float:flOrigin[3]
	entity_get_vector(id, EV_VEC_origin, flOrigin)
	
	// Collisions
	static iVictim
	iVictim = -1
	
	// Vector var
	static Float:flVictimOrigin[3]
	
	// A ring effect
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, flOrigin, 0)
	write_byte(TE_BEAMCYLINDER) // TE id
	engfunc(EngFunc_WriteCoord, flOrigin[0]) // x
	engfunc(EngFunc_WriteCoord, flOrigin[1]) // y
	engfunc(EngFunc_WriteCoord, flOrigin[2]) // z
	engfunc(EngFunc_WriteCoord, flOrigin[0]) // x axis
	engfunc(EngFunc_WriteCoord, flOrigin[1]) // y axis
	engfunc(EngFunc_WriteCoord, flOrigin[2] + g_flCvar_Radius) // z axis
	write_short(g_sprRing) // sprite
	write_byte(0) // startframe
	write_byte(0) // framerate
	write_byte(10) // life
	write_byte(25) // width
	write_byte(0) // noise
	write_byte(255) // red
	write_byte(0) // green
	write_byte(0) // blue
	write_byte(200) // brightness
	write_byte(0) // speed
	message_end()
	
	// Screen effects for him self
	screen_effects(id)
	
	// Do scream effects
	while((iVictim = find_ent_in_sphere(iVictim, flOrigin, g_flCvar_Radius)) != 0)
	{
		// Non-player entity
		if(!is_user_valid_connected(iVictim))
		{
			// Validation check
			if(is_valid_ent(iVictim))
			{
				// Get entity classname
				static szClassname[33]
				entity_get_string(iVictim, EV_SZ_classname, szClassname, charsmax(szClassname))
				
				// It's a grenade, and isn't an Infection Bomb
				if(equal(szClassname, "grenade") && zp_get_grenade_type(iVictim) != NADE_TYPE_INFECTION)
				{
					// Get grenade origin
					entity_get_vector(iVictim, EV_VEC_origin, flVictimOrigin)
					
					// Do a good effect
					engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, flVictimOrigin, 0)
					write_byte(TE_PARTICLEBURST) // TE id
					engfunc(EngFunc_WriteCoord, flVictimOrigin[0]) // x
					engfunc(EngFunc_WriteCoord, flVictimOrigin[1]) // y
					engfunc(EngFunc_WriteCoord, flVictimOrigin[2]) // z
					write_short(45) // radius
					write_byte(108) // particle color
					write_byte(10) // duration * 10 will be randomized a bit
					message_end()
					
					// Remove it
					remove_entity(iVictim)
				}
				// If i don't check his solid type, it's used all the time.
				else if(equal(szClassname, "func_breakable") && entity_get_int(iVictim, EV_INT_solid) != SOLID_NOT)
				{
					// Destroy entity if he can
					force_use(id, iVictim)
				}
			}
			
			continue;
		}
			
		// Not alive, zombie or with Godmode
		if(!is_user_alive(iVictim) || zp_get_user_zombie(iVictim))
			continue;
			
		// Screen effects for victims
		screen_effects(iVictim)
			
		// Get scream mode
		switch(g_iCvar_ScreamMode)
		{
			// Do damage
			case 0:
			{
				// Scream slowdown, first should be enabled
				if(g_flCvar_ScreamSlowdown > 0.0)
				{
					// Get his current velocity vector
					static Float:flVelocity[3]
					get_user_velocity(iVictim, flVelocity)
					
					// Multiply his velocity by a number
					xs_vec_mul_scalar(flVelocity, g_flCvar_ScreamSlowdown, flVelocity)
					
					// Set his new velocity vector
					set_user_velocity(iVictim, flVelocity)	
				}
					
				// Get damage result
				static iNewHealth
				iNewHealth = max(0, get_user_health(iVictim) - g_iCvar_ScreamDmg)
				
				// Does not has health
				if(!iNewHealth)
				{
					// Be infected when it's going to die
					if(g_iCvar_DamageMode /* == 1*/)
					{
						// Returns 1 on sucess...
						if(zp_infect_user(iVictim, id, 0, 1))
							continue
					}
	
					// Kill it
					scream_kill(iVictim, id)
					
					continue
				}
				
				// Do fake damage
				fm_set_user_health(iVictim, iNewHealth)
			}
			
			// Instantly Infect
			case 1:
			{
				// Can be infected?
				if(!zp_infect_user(iVictim, id, 0, 1))
				{
					// Kill it
					scream_kill(iVictim, id)
				}
			}
			
			// Instantly Kill
			case 2:
			{
				// Kill it
				scream_kill(iVictim, id)
			}
		}
			
	}
}

stop_scream_task(id)
{
	if(!is_user_alive(id))
		return
		
	// Remove the task
	if(task_exists(id+TASK_SCREAM)) 
	{
		remove_task(id+TASK_SCREAM)
	
		// Remove screen's bar
		message_begin(MSG_ONE, gMsgBarTime, _, id)
		write_byte(0) // time
		write_byte(0) // unknown
		message_end()
		
		// Update bool
		g_bInScreamProcess[id] = false
	}
}

screen_effects(id)
{
	if(!is_user_alive(id))
		return
	// Screen Fade
	message_begin(MSG_ONE_UNRELIABLE, g_msgScreenFade, _, id)
	write_short(UNIT_SECOND*1) // duration
	write_short(UNIT_SECOND*1) // hold time
	write_short(FFADE_IN) // fade type
	write_byte(200) // r
	write_byte(0) // g
	write_byte(0) // b
	write_byte(125) // alpha
	message_end()
	
	// Screen Shake
	message_begin(MSG_ONE_UNRELIABLE, g_msgScreenShake, _, id)
	write_short(UNIT_SECOND*5) // amplitude
	write_short(UNIT_SECOND*1) // duration
	write_short(UNIT_SECOND*5) // frequency
	message_end()
}

cache_cvars()
{
	g_iCvar_ScreamMode = 0
	g_iCvar_ScreamDuration = 3
	g_iCvar_ScreamDmg = 1
	g_iCvar_ScreamStartTime = 1
	g_iCvar_DamageMode = 0
	g_flCvar_ReloadTime = floatmax(g_iCvar_ScreamDuration+0.0, 20.0)
	g_flCvar_Radius = 240.0
	g_flCvar_ScreamSlowdown = 0.5
}

scream_kill(victim, attacker)
{
	// To use later in DeathMsg event
	g_bKilledByScream[victim] = true
	
	// Do kill
	ExecuteHamB(Ham_Killed, victim, attacker, GIB_NEVER)
	
	// We don't need this
	g_bKilledByScream[victim] = false
}

public zp_round_ended(winteam)
{
	// Update bool
	g_bRoundEnding = true
	
	// Make a loop
	static id
	for(id = 1; id <= g_maxplayers; id++)
	{
		// Valid connected
		if(is_user_valid_connected(id))
		{
			// Remove mainly tasks
			stop_scream_task(id)
			remove_task(id+TASK_RELOAD)
		}
	}
}

public event_RoundStart()
{
	cache_cvars()
	g_bRoundEnding = false
}

public message_DeathMsg(msg_id, msg_dest, id)
{
	static iAttacker, iVictim
	
	iAttacker = get_msg_arg_int(1)
	iVictim = get_msg_arg_int(2)
	
	if(!is_user_connected(iAttacker) || iAttacker == iVictim)
		return PLUGIN_CONTINUE
		
	if(g_bKilledByScream[iVictim])
		set_msg_arg_string(4, "siren scream")

	return PLUGIN_CONTINUE
}

public ShowHUD(id)
{
	if(!is_user_alive(id))
	{
		remove_task(id)
		remove_task(id+TASK_FURY)
		return PLUGIN_HANDLED
	}
	static Class
	Class = zp_get_user_zombie_class(id)
	
	if (Class == FLESHPOUND)
	{
		i_fury_time[id] = i_fury_time[id] - 1;
		client_print(id, print_center, "[Adrenalina Termina en ... %d]", i_fury_time[id]+1)	
	}
	else if(Class == CHARGER)
	{		
		i_cooldown_time[id] = i_cooldown_time[id] - 1
		client_print(id, print_center, "Espera %d segundos para Tu Habilidad", i_cooldown_time[id])
	}
	return PLUGIN_HANDLED
}

public use_ability_one(id)
{
	if (!is_user_alive(id))
		return PLUGIN_HANDLED
		
	if(!CheckIsZombie(id))
		return PLUGIN_HANDLED
		
	if(zp_get_user_zombie_class(id) != CHARGER)
		return PLUGIN_HANDLED
		
	if(g_abil_one_used[id])
		return PLUGIN_HANDLED	
	
	message_begin(MSG_ONE, g_msgScreenFade, _, id)
	write_short(0) // duration
	write_short(0) // hold time
	write_short(0x0004) // fade type
	write_byte(255) // red
	write_byte(0) // green
	write_byte(0) // blue
	write_byte(150) // alpha
	message_end()
	
	g_speeded[id] = true
	g_empujar[id] = true
	g_abil_one_used[id] = 1
	
	emit_sound(id, CHAN_STREAM, speed[random_num(0, sizeof speed - 1)], 1.0, ATTN_NORM, 0, PITCH_NORM)
	set_task(get_pcvar_float(cvar_time), "set_normal_speed", id)
	
	return PLUGIN_CONTINUE
}

public set_normal_speed(id)
{
	if (!is_user_alive(id))
		return PLUGIN_HANDLED
		
	if(!CheckIsZombie(id))
		return PLUGIN_HANDLED
		
	if(zp_get_user_zombie_class(id) != CHARGER)
		return PLUGIN_HANDLED
		
	g_speeded[id] = false
	g_empujar[id] = false
	
	// Gradually remove screen's blue tint
	message_begin(MSG_ONE, g_msgScreenFade, _, id)
	write_short((1<<12)) // duration
	write_short(0) // hold time
	write_short(0x0000) // fade type
	write_byte(180) // red
	write_byte(0) // green
	write_byte(0) // blue
	write_byte(200) // alpha
	message_end()
	
	set_task(g_abilonecooldown, "set_ability_one_cooldown", id)
	
	i_cooldown_time[id] = floatround(g_abilonecooldown)
	set_task(1.0, "ShowHUD", id, _, _, "a", i_cooldown_time[id])
	return PLUGIN_HANDLED
}

public set_ability_one_cooldown(id)
{
	if (!is_user_alive(id))
		return PLUGIN_HANDLED
		
	if(!CheckIsZombie(id))
		return PLUGIN_HANDLED
		
	if(zp_get_user_zombie_class(id) != CHARGER)
		return PLUGIN_HANDLED
		
	g_abil_one_used[id] = 0
	zp_colored_print(id, "%s Puedes Volver a usar tu^x04 Habilidad", TAG) 
	
	return PLUGIN_HANDLED
}
public toco(id, iVictim)
{	
	if(!is_user_alive(id)) 
		return PLUGIN_HANDLED
		
	if(!CheckIsZombie(id))
		return PLUGIN_HANDLED
		
	if(zp_get_user_zombie_class(id) != CHARGER)
		return PLUGIN_HANDLED
		
	if(!g_empujar[id])
		return PLUGIN_HANDLED
	
	if(!is_user_alive(iVictim) || zp_get_user_zombie(iVictim) || zp_get_user_nemesis(iVictim) || zp_get_user_assassin(iVictim) || zp_get_user_alien(iVictim))
		return PLUGIN_HANDLED
	
	new Float:start_origin[3], Float:end_origin[3]
	pev(id, pev_origin, start_origin)
	pev(iVictim, pev_origin, end_origin)
	
	start_origin[0] = end_origin[0] - start_origin[0]
	start_origin[1] = end_origin[1] - start_origin[1]
	start_origin[2] = 0.0
	
	xs_vec_normalize(start_origin, end_origin)
	
	end_origin[0] *= 1500.0
	end_origin[1] *= 1000.0
	end_origin[2] = 500.0
	
	set_pev(iVictim, pev_velocity, end_origin)
	
	new hp = get_user_health(iVictim)
	new damage = get_pcvar_num(cvar_damage)
	
	if(hp > damage)
	{		
		new origin[3]
		get_user_origin(iVictim, origin)
		
		message_begin(MSG_ONE, gMsgDamage, {0,0,0}, iVictim)
		write_byte(21)
		write_byte(20)
		write_long(0)
		write_coord(origin[0])
		write_coord(origin[1])
		write_coord(origin[2])
		message_end()
		
		message_begin(MSG_ONE, g_msgScreenShake, {0,0,0}, iVictim)
		write_short(255<<14) // ammount
		write_short(1<<12) // lasts this long
		write_short(255<<14) // frequency
		message_end()
		
		new Float:fVec[3]
		fVec[0] = random_float(PA_LOW, PA_HIGH)
		fVec[1] = 0.0
		fVec[2] = random_float(PA_LOW, PA_HIGH)
		
		set_pev(iVictim, pev_punchangle, fVec)
		
		fm_set_user_health(iVictim, get_user_health(iVictim)-damage)
	}
	else
	{
		death_message(id, iVictim, "knife", 1)
	}
	
	emit_sound(id, CHAN_VOICE, smash[random_num(0, sizeof smash - 1)], 1.0, ATTN_NORM, 0, PITCH_HIGH)
	
	return PLUGIN_HANDLED
}

public clcmd_furia(id)
{
	if(!is_user_alive(id))
		return PLUGIN_HANDLED
		
	if(!CheckIsZombie(id))
		return PLUGIN_HANDLED
		
	if(zp_get_user_zombie_class(id) != FLESHPOUND)
		return PLUGIN_HANDLED
	
	if(!g_veces[id])
	{
		zp_colored_print(id, "%s No Tienes mas Adrenalina hasta Morir", TAG) 
		return PLUGIN_HANDLED
	}
	
	g_speeded[id] = true
	g_veces[id] = g_veces[id] -1
	zp_set_user_nodamage(id)
	set_task(0.1, "effects", id, _, _, "b")
	i_fury_time[id] = get_pcvar_num(cvar_furytime)
	
	set_task(1.0, "ShowHUD", id, _, _, "a", i_fury_time[id])
	
	emit_sound(id, CHAN_STREAM, fury, 1.0, ATTN_NORM, 0, PITCH_HIGH)
	
	return PLUGIN_HANDLED
}

public effects(id)
{
	if(!is_user_alive(id))
		return 
		
	if(!CheckIsZombie(id))
		return
		
	if(zp_get_user_zombie_class(id) != FLESHPOUND)
		return 
		
	static origin[3]
	get_user_origin(id, origin)
	
	message_begin(MSG_PVS, SVC_TEMPENTITY, origin)
	write_byte(TE_PARTICLEBURST) // TE id
	write_coord(origin[0]) // x
	write_coord(origin[1]) // y
	write_coord(origin[2]) // z
	write_short(130) // radius
	write_byte(70) // color
	write_byte(3) // duration (will be randomized a bit)
	message_end()
	
	message_begin(MSG_PVS, SVC_TEMPENTITY, origin)
	write_byte(TE_DLIGHT) // TE id
	write_coord(origin[0]) // x
	write_coord(origin[1]) // y
	write_coord(origin[2]) // z
	write_byte(22) // radius
	write_byte(255) // r
	write_byte(0) // g
	write_byte(30) // b
	write_byte(2) // life
	write_byte(0) // decay rate
	message_end()
	
	set_task(get_pcvar_float(cvar_furytime), "remove_fury", id)
}
public remove_fury(id)
{
	zp_set_user_acabo_nodamage(id)
	remove_task(id)
	emit_sound(id, CHAN_STREAM, normaly, 1.0, ATTN_NORM, 0, PITCH_HIGH)
	g_speeded[id] = false
}

public clcmd_vomit( id )
{
	if(!is_user_alive(id)) 
		return PLUGIN_HANDLED
		
	if(!CheckIsZombie(id))
		return PLUGIN_HANDLED
		
	if(zp_get_user_zombie_class(id) != BOOMER2)
		return PLUGIN_HANDLED
	
	if( get_gametime( ) - g_iLastVomit[ id ] < get_pcvar_float( cvar_vomitcooldown ) )
	{
		zp_colored_print(id, "%s Necesitas esperar^x04 %.1f^x01 seg. para^x03 Vomitar^x01 otra vez.", TAG, get_pcvar_float( cvar_vomitcooldown ) - (get_gametime() - g_iLastVomit[ id ]))
		return PLUGIN_HANDLED
	}
	
	g_iLastVomit[ id ] = get_gametime( )
	
	new target, body, dist = get_pcvar_num( cvar_vomitdist )
	get_user_aiming( id, target, body, dist )
		
	new vec[ 3 ], aimvec[ 3 ], velocityvec[ 3 ]
	new length
	
	get_user_origin( id, vec )
	get_user_origin( id, aimvec, 2 )
	
	velocityvec[ 0 ] = aimvec[ 0 ] - vec[ 0 ]
	velocityvec[ 1 ] = aimvec[ 1 ] - vec[ 1 ]
	velocityvec[ 2 ] = aimvec[ 2 ] - vec[ 2 ]
	length = sqrt( velocityvec[ 0 ] * velocityvec[ 0 ] + velocityvec[ 1 ] * velocityvec[ 1 ] + velocityvec[ 2 ] * velocityvec[ 2 ] )
	velocityvec[ 0 ] = velocityvec[ 0 ] * 10 / length
	velocityvec[ 1 ] = velocityvec[ 1 ] * 10 / length
	velocityvec[ 2 ] = velocityvec[ 2 ] * 10 / length
	
	new args[ 8 ]
	args[ 0 ] = vec[ 0 ]
	args[ 1 ] = vec[ 1 ]
	args[ 2 ] = vec[ 2 ]
	args[ 3 ] = velocityvec[ 0 ]
	args[ 4 ] = velocityvec[ 1 ]
	args[ 5 ] = velocityvec[ 2 ]
	
	set_task( 0.1, "create_sprite", 0, args, 8, "a", 3 )
	
	emit_sound( id, CHAN_STREAM, vomit_sounds[0], 1.0, ATTN_NORM, 0, PITCH_HIGH )
	
	if( is_valid_ent( target ) && is_user_alive( target ) && !zp_get_user_zombie( target ) && get_entity_distance( id, target ) <= dist )
	{
		message_begin( MSG_ONE_UNRELIABLE, g_msgid_ScreenFade, _, target )
		write_short( get_pcvar_num( cvar_wakeuptime ) )
		write_short( get_pcvar_num( cvar_wakeuptime ) )
		write_short( 0x0004 )
		write_byte( 79 )
		write_byte( 180 )
		write_byte( 61 )
		write_byte( 255 )
		message_end( )
		
		if( get_pcvar_num( cvar_victimrender ) )
		{
			set_rendering( target, kRenderFxGlowShell, 79, 180, 61, kRenderNormal, 25 ) 
		}
		set_task( get_pcvar_float( cvar_wakeuptime ), "victim_wakeup", target )
		
		if( !get_pcvar_num( cvar_boomer_reward ) )
			return PLUGIN_HANDLED
	}
	return PLUGIN_HANDLED
}

public create_sprite( args[ ] )
{
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY )
	write_byte( 120 )
	write_coord( args[ 0 ] )
	write_coord( args[ 1 ] )
	write_coord( args[ 2 ] )
	write_coord( args[ 3 ] )
	write_coord( args[ 4 ] )
	write_coord( args[ 5 ] )
	write_short( vomit )
	write_byte( 8 )
	write_byte( 5 )
	write_byte( 150 )
	write_byte( 200 )
	message_end( )
	
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY )
	write_byte( 120 )
	write_coord( args[ 0 ] )
	write_coord( args[ 1 ] )
	write_coord( args[ 2 ] )
	write_coord( args[ 3 ] )
	write_coord( args[ 4 ] )
	write_coord( args[ 5 ] )
	write_short( vomit )
	write_byte( 8 )
	write_byte( 5 )
	write_byte( 150 )
	write_byte( 200 )
	message_end( )
	
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY )
	write_byte( 120 )
	write_coord( args[ 0 ] )
	write_coord( args[ 1 ] )
	write_coord( args[ 2 ] )
	write_coord( args[ 3 ] )
	write_coord( args[ 4 ] )
	write_coord( args[ 5 ] )
	write_short( vomit )
	write_byte( 8 )
	write_byte( 5 )
	write_byte( 150 )
	write_byte( 200 )
	message_end( )
	
	return PLUGIN_CONTINUE
}

public victim_wakeup( id )
{
	if( !is_user_connected( id ) )
		return PLUGIN_HANDLED
	
	message_begin( MSG_ONE_UNRELIABLE, g_msgid_ScreenFade, _, id )
	write_short( ( 1<<12 ) )
	write_short( 0 )
	write_short( 0x0000 )
	write_byte( 0 )
	write_byte( 0 )
	write_byte( 0 )
	write_byte( 255 )
	message_end( )
	
	if( get_pcvar_num( cvar_victimrender ) )
	{
		set_rendering( id )
	}
	return PLUGIN_HANDLED
}

public StopSpam_XD( id )
{
	if( is_user_connected( id ) )
	{	
		g_iHateSpam[ id ] = false
	}
}
public event_DeathMsg( )
{
	new id = read_data( 2 )
	
	if(!is_user_alive(id)) 
		return PLUGIN_HANDLED
		
	if(!CheckIsZombie(id))
		return PLUGIN_HANDLED
		
	if(zp_get_user_zombie_class(id) != BOOMER2)
		return PLUGIN_HANDLED
		
	emit_sound( id, CHAN_STREAM, explode_sounds[0], 1.0, ATTN_NORM, 0, PITCH_HIGH )
	
	for( new i = 1; i <= g_maxplayers; i ++ )
	{
		if( !is_valid_ent( i ) || !is_user_alive( i ) || !is_user_connected( i ) || zp_get_user_zombie( i ) || get_entity_distance( id, i ) > get_pcvar_num( cvar_explodedist ) )
			return PLUGIN_HANDLED
			
		message_begin( MSG_ONE_UNRELIABLE, g_msgid_ScreenFade, _, i )
		write_short( get_pcvar_num( cvar_wakeuptime ) )
		write_short( get_pcvar_num( cvar_wakeuptime ) )
		write_short( 0x0004 )
		write_byte( 79 )
		write_byte( 180 )
		write_byte( 61 )
		write_byte( 255 )
		message_end( )
		
		if( get_pcvar_num( cvar_victimrender ) )
		{
			set_rendering( i, kRenderFxGlowShell, 79, 180, 61, kRenderNormal, 25 )
		}
		
		set_task( get_pcvar_float( cvar_wakeuptime ), "victim_wakeup", i )
		
		if( !get_pcvar_num( cvar_boomer_reward ) )
			return PLUGIN_HANDLED
	}
	return PLUGIN_HANDLED
}

public sqrt( num )
{
	new div = num
	new result = 1
	while( div > result )
	{
		div = ( div + result ) / 2
		result = num / div
	}
	return div
}

public CheckIsZombie(id)
{
	if(!zp_get_user_zombie(id) || zp_get_user_nemesis(id) || zp_get_user_assassin(id) || zp_get_user_alien(id))
		return false
		
	return true
}
