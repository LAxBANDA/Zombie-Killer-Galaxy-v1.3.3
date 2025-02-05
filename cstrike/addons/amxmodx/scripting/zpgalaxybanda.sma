/*--- Modelos player*/
new const ZP_CUSTOMIZATION_FILE[] = "zkg_configuracion.ini"
new Array:model_nemesis
new Array:model_alien
new Array:model_assassin
new Array:model_survivor
new Array:model_sniper
new Array:model_depredador
new Array:model_wesker
new Array:model_ninja
new Array:model_bill
new Array:model_francis
new Array:model_louis
new Array:model_zoey
new Array:model_vip
new Array:model_vipgold
new Array:model_human
new Array:model_moderador
new Array:model_creador
new Array:sound_win_humans, Array:sound_win_zombies, Array:sound_win_no_one, Array:sound_ambience, Array:sound_wesker, Array:sound_l4d, Array:sound_synapsis, 
Array:sound_armageddon, Array:sound_depredador, Array:sound_ninja, Array:sound_assassin, Array:sound_torneo, Array:sound_survivor, 
Array:sound_nemesis, Array:sound_sniper, Array:sound_swarm, Array:sound_multipleinfeccion, Array:sound_plague, Array:sound_alien, Array:sound_entrar
enum { SECTION_NONE = 0, SECTION_SERVER, SECTION_PLAYER_MODELS, SECTION_HANDS_MODELS, SECTION_SOUNDS }
/*--- Cielos ---*/
new const sky_names[] = "zpgalaxy"
	
new PLUGIN_NAME[32]
new TAG[32]

/*-------- NO MODIFICAR ------------*/
#define PLUGIN_AUTOR "MercyLeZZ"
/*---------------------*/

new bool:changing_name[33]
new g_top15_clear

/*--- INCLUDES---------*/
#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fakemeta>
#include <hamsandwich>
#include <xs>
#include <engine>
#if AMXX_VERSION_NUM < 183
#include <dhudmessage>
#endif
#include <cs_player_models_api>
#include <natives_galaxy>
#include <sqlx>
/*---------------------*/

const VIPORO = ADMIN_CVAR
const VIP = ADMIN_CHAT
const ADMIN =  ADMIN_RESERVATION
const CREADOR =  ADMIN_IMMUNITY

new Trie:gSayChannels

enum _:e_HooksDate
{
	e_sInput[25],
	e_sOutPut[64]
}

new const g_ChatHooks[][e_HooksDate] =
{
	{ "#Cstrike_Chat_CT",		"^1(Humanos) " },
	{ "#Cstrike_Chat_T",		"^1(Zombies) " },
	{ "#Cstrike_Chat_CT_Dead",	"^1*MUERTO* (Humanos) " },
	{ "#Cstrike_Chat_T_Dead",	"^1*MUERTO* (Zombies) " },
	{ "#Cstrike_Chat_Spec",		"^1(Espectadores) " },
	{ "#Cstrike_Chat_All",		"" },
	{ "#Cstrike_Chat_AllDead",	"^1*MUERTO* " },
	{ "#Cstrike_Chat_AllSpec",	"^1*ESPECTADOR* " }
}
/*
enum _:ADMIN_DATAS 
{ 
	m_szName[32],
	m_iFlag
} 

new const AdminsDatas[][ADMIN_DATAS] =  
{ 
	{ "ADMIN ROOT", CREADOR },
	{ "MODERADOR", ADMIN },
	{ "VIP-ORO", VIPORO },
	{ "VIP", VIP }
}
*/
#define SEMICLIP_TRANSAMOUNT 75
#define SEMICLIP_DISTANCE 125

new bool:g_bSolid[33]
new bool:g_bHasSemiclip[33]
new Float:g_fOrigin[33][3]
/*----------------------------------------------------------------------------
|============================== SISTEMA DE CUENTAS ===========================
------------------------------------------------------------------------------*/

#define TASK_MESS 1950
#define TASK_KICK 2920
#define TASK_MENU 3140
#define TASK_TIMER 4000
#define TASK_AJC 7420
#define MENU_TASK_TIME 0.5
#define AJC_TASK_TIME 0.1
#define g_db "database"

new g_ajc_class[2]
#define TABLA "zpgalaxycuentas"

//Start of Arrays
new text[1024];
new params[2];
new check_pass[34];
new query[4096];
new Handle:g_sqltuple;
new Handle:g_sqltuple2;
new error[512]
new password[33][34];
new typedpass[32];
new new_pass[33][32];
new hash[34];
new Menu[600];
new keys;
new length;
new g_screenfade

new g_MenuChar[1500]
//End fo Arrays

//Start of Booleans
new bool:data_ready = false;
new g_Estado[33]

enum _:DataID {
	Conectado = 0,
	Registrado,
	Logueado
}

enum _:DATOS
{
	Tipo[20]
}

new const ESTADOS[DataID][DATOS] = 
{
	{ "NO REGISTRADO" },
	{ "REGISTRADO" },
	{ "LOGUEADO" }
}
//End of Booleans

//Start of Constants
new const log_file[] = "zp_cuentas_log.txt";
new const JOIN_TEAM_MENU_FIRST[] = "#Team_Select";
new const JOIN_TEAM_MENU_FIRST_SPEC[] = "#Team_Select_Spect";
new const JOIN_TEAM_MENU_INGAME[] = "#IG_Team_Select";
new const JOIN_TEAM_MENU_INGAME_SPEC[] = "#IG_Team_Select_Spect"; 
new const JOIN_TEAM_VGUI_MENU = 2;

#define MAX_LEVEL 300

enum _:gCvarsExtract
{
	gCvarNombre[40],
	gCvarValor[8]
}

enum _:gCvarsID
{
	PACK_INFECTAR_HUMANO,
	EXP_INFECTAR_HUMANO,
	EXP_MATAR_HUMANO,
	POINT_MATAR_HUMANO,
	EXP_MATAR_SURVIVOR,
	POINT_MATAR_SURVIVOR,
	EXP_MATAR_SNIPER,
	POINT_MATAR_SNIPER,
	EXP_MATAR_DEPRE,
	POINT_MATAR_DEPRE,
	EXP_MATAR_NINJA,
	POINT_MATAR_NINJA,
	EXP_MATAR_L4D,
	POINT_MATAR_L4D,
	EXP_MATAR_WESKER,
	POINT_MATAR_WESKER,
	EXP_MATAR_ZOMBIE,
	POINT_MATAR_ZOMBIE,
	EXP_MATAR_ZOMBIE_CUCHI,
	POINT_MATAR_ZOMBIE_CUCHI,
	EXP_MATAR_NEMESIS ,
	POINT_MATAR_NEMESIS ,
	EXP_MATAR_NEMESIS_CUCHI,
	POINT_MATAR_NEMESIS_CUCHI,
	EXP_MATAR_ASSASSIN,
	POINT_MATAR_ASSASSIN,
	EXP_MATAR_ASSASSIN_CUCHI,
	POINT_MATAR_ASSASSIN_CUCHI,
	EXP_MATAR_ALIEN,
	POINT_MATAR_ALIEN,
	EXP_MATAR_ALIEN_CUCHI,
	POINT_MATAR_ALIEN_CUCHI,
	EXP_GANAR_NORMAL,
	POINT_GANAR_NORMAL,
	EXP_GANAR_MULTI,
	POINT_GANAR_MULTI,
	EXP_GANAR_SWARM,
	POINT_GANAR_SWARM,
	EXP_GANAR_PLAGUE,
	POINT_GANAR_PLAGUE,
	EXP_GANAR_TORNEO,
	POINT_GANAR_TORNEO,
	EXP_GANAR_SYNAPSIS,
	POINT_GANAR_SYNAPSIS,
	EXP_GANAR_LNJ,
	POINT_GANAR_LNJ,
	EXP_GANAR_L4D,
	POINT_GANAR_L4D,
	EXP_GANAR_SURVIVOR,
	POINT_GANAR_SURVIVOR,
	EXP_GANAR_SNIPER,
	POINT_GANAR_SNIPER,
	EXP_GANAR_WESKER,
	POINT_GANAR_WESKER,
	EXP_GANAR_DEPRE,
	POINT_GANAR_DEPRE,
	EXP_GANAR_NINJA,
	POINT_GANAR_NINJA,
	EXP_GANAR_NEMESIS,
	POINT_GANAR_NEMESIS,
	EXP_GANAR_ASSASSIN,
	POINT_GANAR_ASSASSIN,
	EXP_GANAR_ALIEN,
	POINT_GANAR_ALIEN,
	EXP_DESINFECTAR,
	VIDA_ADMINGENERAL,
	CHALECO_ADMINGENERAL,
	PACKS_ADMINGENERAL,
	VIDA_ADMIN,
	CHALECO_ADMIN,
	PACKS_ADMIN,
	VIDA_VIP,
	CHALECO_VIP,
	PACKS_VIP,
	VIDA_VIPORO,
	CHALECO_VIPORO,
	PACKS_VIPORO,
	VIDA_PLAYER,
	CHALECO_PLAYER,
	PACKS_PLAYER,
	MULTIPLICACION_ADMINGENERAL,
	MODOS_ADMINGENERAL,
	MULTIPLICACION_ADMIN,
	MODOS_ADMIN,
	MULTIPLICACION_VIP,
	MODOS_VIP,
	MULTIPLICACION_VIPORO,
	MODOS_VIPORO,
	EMPIEZO_HORAFELIZ,
	TERMINO_HORAFELIZ,
	MULTI_HORAFELIZ,
	DURACIONBUBBLE,
	RADIOBUBBLE,
	REDBUBBLE,
	GREENBUBBLE,
	BLUEBUBBLE,
	CUENTAS_ON,
	CUENTAS_GUARDAR,
	CUENTAS_REGTIME,
	CUENTAS_LOGTIME,
	CUENTAS_PASSCHAR,
	CUENTAS_PASSINTENTOS,
	CUENTAS_PASSVECESCAMBIAR,
	CUENTAS_LOGREG,
	CUENTAS_LOGCAMBIARPASS,
	CUENTAS_LOGAUTOLOG,
	CUENTAS_OSCURECER,
	CUENTAS_BLOQUEARSAY,
	CUENTAS_LOGOUT,
	CUENTAS_COUNTTIME,
	CUENTAS_AUTOTEAM,
	CUENTAS_ELEGIREQUIPO,
	CUENTAS_TIEMPO,
	CUENTAS_TIEMPOPASS
}

new const gCvarsPlugin[gCvarsID][gCvarsExtract] = 
{
	{ "zp_ammo_infectar_humano", "2" },
	{ "zp_exp_infectar_humano", "2" },
	{ "zp_exp_matar_humano", "2" },
	{ "zp_puntos_matar_humano", "0" },
	{ "zp_exp_matar_survivor", "30" },
	{ "zp_puntos_matar_survivor", "2" },
	{ "zp_exp_matar_sniper", "25" },
	{ "zp_puntos_matar_sniper", "2" },
	{ "zp_exp_matar_depredador", "20" },
	{ "zp_puntos_matar_depredador", "2" },
	{ "zp_exp_matar_ninja", "50" },
	{ "zp_puntos_matar_ninja", "2" },
	{ "zp_exp_matar_l4d", "18" },
	{ "zp_puntos_matar_l4d", "2" },
	{ "zp_exp_matar_wesker", "70" },
	{ "zp_puntos_matar_wesker", "2" },
	{ "zp_exp_matar_zombie", "3" },
	{ "zp_puntos_matar_zombie", "0" },
	{ "zp_exp_matar_zombie_cuchillo", "9" },
	{ "zp_point_matar_zombie_cuchillo", "0" },
	{ "zp_exp_matar_nemesis", "35" },
	{ "zp_point_matar_nemesis", "2" },
	{ "zp_exp_matar_nemesis_cuchillo", "70" },
	{ "zp_point_matar_nemesis_cuchillo", "4" },
	{ "zp_exp_matar_assassin", "30" },
	{ "zp_point_matar_assassin", "2" },
	{ "zp_exp_matar_assassin_cuchillo", "60" },
	{ "zp_point_matar_assassin_cuchillo", "4" },
	{ "zp_exp_matar_alien", "20" },
	{ "zp_point_matar_alien", "2" },
	{ "zp_exp_matar_alien_cuchillo", "40" },
	{ "zp_puntos_matar_alien_cuchillo", "4" },
	{ "zp_exp_ganar_modo_normal", "2" },
	{ "zp_puntos_ganar_modo_normal", "0" },
	{ "zp_exp_ganar_modo_multi", "4" },
	{ "zp_puntos_ganar_modo_multi", "0" },
	{ "zp_exp_ganar_modo_swarm", "5" },
	{ "zp_puntos_ganar_modo_swarm", "0" },
	{ "zp_exp_ganar_modo_plague", "6" },
	{ "zp_puntos_ganar_modo_plague", "0" },
	{ "zp_exp_ganar_modo_torneo", "10" },
	{ "zp_puntos_ganar_modo_torneo", "0" },
	{ "zp_exp_ganar_modo_synapsis", "12" },
	{ "zp_puntos_ganar_modo_synapsis", "0" },
	{ "zp_exp_ganar_modo_armageddon", "5" },
	{ "zp_puntos_ganar_modo_armageddon", "0" },
	{ "zp_exp_ganar_modo_l4d", "5" },
	{ "zp_puntos_ganar_modo_l4d", "2" },
	{ "zp_exp_ganar_modo_survivor", "10" },
	{ "zp_puntos_ganar_modo_survivor", "0" },
	{ "zp_exp_ganar_modo_sniper", "10" },
	{ "zp_puntos_ganar_modo_sniper", "0" },
	{ "zp_exp_ganar_modo_wesker", "12" },
	{ "zp_puntos_ganar_modo_wesker", "2" },
	{ "zp_exp_ganar_modo_depredador", "10" },
	{ "zp_puntos_ganar_modo_depredador", "0" },
	{ "zp_exp_ganar_modo_ninja", "12" },
	{ "zp_puntos_ganar_modo_ninja", "0" },
	{ "zp_exp_ganar_modo_nemesis", "6" },
	{ "zp_puntos_ganar_modo_nemesis", "0" },
	{ "zp_exp_ganar_modo_assassin", "3" },
	{ "zp_puntos_ganar_modo_assassin", "0" },
	{ "zp_exp_ganar_modo_alien", "5" },
	{ "zp_puntos_ganar_modo_alien", "2" },
	{ "zp_exp_desinfectar", "5" },
	{ "zp_vida_admingeneral", "400" },
	{ "zp_chaleco_admingeneral", "450" },
	{ "zp_ammopacks_admingeneral", "6" },
	{ "zp_vida_admin", "300" },
	{ "zp_chaleco_admin", "350" },
	{ "zp_ammopacks_admin", "4" },
	{ "zp_vida_vip", "200" },
	{ "zp_chaleco_vip", "250" },
	{ "zp_ammopacks_vip", "2" },
	{ "zp_vida_vip_oro", "300" },
	{ "zp_chaleco_vip_oro", "350" },
	{ "zp_ammopacks_vip_oro", "4" },
	{ "zp_vida_player", "100" },
	{ "zp_chaleco_player", "0" },
	{ "zp_ammopacks_player", "0" },
	{ "zp_multiplicacion_admingeneral", "4" },
	{ "zp_modos_admingeneral", "10" },
	{ "zp_multiplicacion_admin", "3" },
	{ "zp_modos_admin", "5" },
	{ "zp_multiplicacion_vip", "2" },
	{ "zp_modos_vip", "2" },
	{ "zp_multiplicacion_vip_oro", "3" },
	{ "zp_modos_vip_oro", "3" },
	{ "zp_empiezo_hora_feliz", "19" },
	{ "zp_termino_hora_feliz", "8" },
	{ "zp_multiplicacion_hora_feliz", "2" },
	{ "zp_burbuja_duracion", "20" },
	{ "zp_burbuja_radio", "130" },
	{ "zp_burbuja_rojo", "0" },
	{ "zp_burbuja_verde", "100" },
	{ "zp_burbuja_azul", "200" },
	{ "zp_on", "1" },
	{ "zp_save_type", "1" },
	{ "zp_register_time", "60" },
	{ "zp_login_time", "60" },
	{ "zp_password_len", "6" },
	{ "zp_attempts", "3" },
	{ "zp_chngpass_times", "3" },
	{ "zp_register_log", "1" },
	{ "zp_chngpass_log", "1" },
	{ "zp_autologin_log", "1" },
	{ "zp_blind", "1" },
	{ "zp_commands", "1" },
	{ "zp_logout", "0" },
	{ "zp_count", "1" },
	{ "zp_ajc_team", "1" },
	{ "zp_ajc_change", "0" },
	{ "zp_cant_login_time", "300" },
	{ "zp_cant_change_pass_time", "300" }

}

enum _:eGamePlayMods{ MODE_NONE = 0, MODE_SURVIVOR, MODE_SWARM, MODE_MULTI, MODE_PLAGUE, MODE_ALIEN, MODE_LNJ,MODE_TORNEO, MODE_SYNAPSIS, 
        MODE_L4D, MODE_SNIPER, MODE_WESKER, MODE_DEPRE, MODE_NINJA, MODE_NEMESIS, MODE_ASSASSIN, MODE_INFECTION, MAX_GAME_MODES }

new g_currentmod
enum _:eGamePlayData
{
	sGamePlayName[32],
	vGamePlayColor[3]
}

new const g_sGamePlayModes[eGamePlayMods][eGamePlayData] = 
{
	{ "Esperando nuevo modo...", { 255, 255, 255 } },
	{ "Modo Survivor", { 0, 0, 255 } },
	{ "Modo Swarm", { 0, 255, 0 } },
	{ "Modo Multiple Infeccion", { 0, 255, 0 } },
	{ "Modo Plague", { 0, 150, 255 } },
	{ "Modo Alien", { 150, 0, 255 } },
	{ "Modo Armageddon", { 0, 0, 255 } },
	{ "Modo Torneo", { 0, 0, 255 } },
	{ "Modo Synapsis", { 0, 0, 255 } },
	{ "Modo Left 4 Dead", { 0, 0, 255 } },
	{ "Modo Sniper", { 0, 255, 0 } },
	{ "Modo Wesker", { 190, 175, 0 } },
	{ "Modo Depredador", { 0, 190, 255 } },
	{ "Modo Ninja", { 255, 140, 0 } },
	{ "Modo Nemesis", { 255, 0, 0 } },
	{ "Modo Assassin", { 255, 255, 0 } },
	{ "Modo Infeccion", { 0, 255, 0 } },
	{ "Modo Versus Mod Random", { 255, 255, 255 } }
	
}

new g_MsgSync4

const MAX_CSDM_SPAWNS = 128
const MAX_STATS_SAVED = 64

enum (+= 100) { TASK_TEAM = 2000,TASK_SPAWN,TASK_BLOOD,TASK_AURA,TASK_BURN,TASK_NVISION,TASK_FLASH,TASK_CHARGE,
               TASK_SHOWHUD,TASK_MAKEZOMBIE,TASK_WELCOMEMSG,TASK_LIGHTING,TASK_AMBIENCESOUNDS, TASK_TORNEOHUD, TASK_COUNTDOWN }

#define ID_TEAM (taskid - TASK_TEAM)
#define ID_SPAWN (taskid - TASK_SPAWN)
#define ID_BLOOD (taskid - TASK_BLOOD)
#define ID_AURA (taskid - TASK_AURA)
#define ID_BURN (taskid - TASK_BURN)
#define ID_NVISION (taskid - TASK_NVISION)
#define ID_FLASH (taskid - TASK_FLASH)
#define ID_CHARGE (taskid - TASK_CHARGE)
#define ID_SHOWHUD (taskid - TASK_SHOWHUD)
#define TASK_PARTICULAS 27777
#define REFILL_WEAPONID args[0]
#define PL_ACTION g_menu_data[id][0]
#define MENU_PAGE_ZCLASS g_menu_data[id][1]
#define MENU_PAGE_EXTRAS g_menu_data[id][2]
#define MENU_PAGE_PLAYERS g_menu_data[id][3]
#define MENU_PAGE_ADMIN1 g_menu_data[id][4]
#define MENU_PAGE_ADMIN2 g_menu_data[id][5]
#define MENU_PAGE_ADMIN0 g_menu_data[id][6]
#define is_human(%1) (!g_zombie[%1] && !g_survivor[%1] && !g_depre[%1] && !g_ninja[%1] && !g_l4d[%1][0] && !g_l4d[%1][1] && !g_l4d[%1][2] && !g_l4d[%1][3] && !g_wesker[%1] && !g_sniper[%1])
#define is_zombie(%1) (g_zombie[%1] && !g_nemesis[%1] && !g_assassin[%1] && !g_alien[%1])

/*------------------ Optimizacion de Arrays Fixed 4.2 -------------------------*/

//#define AMBIENCE_RAIN // Rain
#define AMBIENCE_SNOW // Snow
#define AMBIENCE_FOG // Fog

#if defined AMBIENCE_FOG // Si define AMBIENCE_FOG esta activado
new const FOG_DENSITY[] = "0.0008" // Density
new const FOG_COLOR[] = "128 128 128" // Color: Red Green Blue
#endif

//#define DONT_CHANGE_SKY

new const skynames[][] = { "zpgalaxy_" }
new const zombie_decals[] = { 99, 107, 108, 184, 185, 186, 187, 188, 189 }
new const zombie_infect[][] = { "zpre4/zombie_infec.wav" }
new const zombie_pain[][] = { "zombie_plague/zombie_pain1.wav", "zombie_plague/zombie_pain2.wav", "zombie_plague/zombie_pain3.wav", "zombie_plague/zombie_pain4.wav", "zombie_plague/zombie_pain5.wav" }
new const nemesis_pain[][] = { "zpre4/nemesis_pain1.wav" , "zpre4/nemesis_pain2.wav" , "zpre4/nemesis_pain3.wav" , "zpre4/nemesis_pain4.wav" }
new const assassin_pain[][] = { "zpre4/assassin_pain1.wav" , "zpre4/assassin_pain2.wav" , "zpre4/assassin_pain3.wav" , "zpre4/assassin_pain4.wav" }
new const alien_pain[][] = { "zpre4/alien_pain1.wav" , "zpre4/alien_pain2.wav" , "zpre4/alien_pain3.wav" }
new const zombie_die[][] = { "zpre4/zombie_die1.wav" , "zpre4/zombie_die2.wav" , "zpre4/zombie_die5.wav" }
new const zombie_miss_slash[][] = { "zpre4/knife_slash1.wav" , "zpre4/knife_slash2.wav" }
new const zombie_miss_wall[][] = { "zpre4/knife_hitwall1.wav", "zpre4/knife_hitwall2.wav" }
new const zombie_hit_normal[][] = { "zpre4/knife_hit1.wav" , "zpre4/knife_hit2.wav", "zpre4/knife_hit3.wav", "zpre4/knife_hit4.wav" }
new const zombie_hit_stab[][] = { "zpre4/skullaxe_stab.wav" }
new const zombie_idle[][] = { "zpre4/idle_01.wav" , "zpre4/idle_02.wav" , "zpre4/idle_03.wav" , "zpre4/idle_04.wav" , "zpre4/idle_05.wav" , "zpre4/idle_06.wav" }
new const grenade_fire_player[][] = { "zpre4/zombie_burn1.wav" , "zpre4/zombie_burn1.wav" , "zpre4/zombie_burn1.wav" , "zpre4/zombie_burn1.wav" }

/*------------------------------------------------------------------------------------------------------------------------------*/
new Float:gDisparoAnterior[33]
new attacker
new const Modelo_Disparo[] = "sprites/zpre4/shine_bounce.spr"
new Depre_Efecto
new g_deagle_inf[33]
new g_custom

// Game Modes vars
new Array:g_gamemode_name // caption
new Array:g_gamemode_flag // access flag
new Array:g_gamemode_chance // game modes chance
new Array:g_gamemode_allow // allow infection
new Array:g_gamemode_dm // death match mode
new g_gamemodes_i = MAX_GAME_MODES // loaded game modes counter 
new g_fwGameModeSelected
new g_arrays_created


const ZP_TEAM_NO_ONE = 0
const ZP_TEAM_ANY = 0
const ZP_TEAM_ZOMBIE = (1<<0)
const ZP_TEAM_HUMAN = (1<<1)

const ZCLASS_NONE = -1

const PDATA_SAFE = 2
const OFFSET_CSMENUCODE = 205
const OFFSET_PAINSHOCK = 108
const OFFSET_CSTEAMS = 114
const OFFSET_CSMONEY = 115
const OFFSET_FLASHLIGHT_BATTERY = 244
const OFFSET_CSDEATHS = 444
const OFFSET_ACTIVE_ITEM = 373
const OFFSET_WEAPONOWNER = 41
const OFFSET_LINUX = 5
const OFFSET_LINUX_WEAPONS = 4

enum
{
	FM_CS_TEAM_UNASSIGNED = 0,
	FM_CS_TEAM_T,
	FM_CS_TEAM_CT,
	FM_CS_TEAM_SPECTATOR
}

new const CS_TEAM_NAMES[][] = { "UNASSIGNED", "TERRORIST", "CT", "SPECTATOR" }

const HIDE_MONEY = (1<<5)
const UNIT_SECOND = (1<<12)
const DMG_HEGRENADE = (1<<24)
const IMPULSE_FLASHLIGHT = 100
const USE_USING = 2
const USE_STOPPED = 0
const STEPTIME_SILENT = 999
const BREAK_GLASS = 0x01
const FFADE_IN = 0x0000
const FFADE_STAYOUT = 0x0004

/*--------------------------.  Armamento Default Zombie Plague  .--------------------------*/

new const MAXBPAMMO[] = { -1, 52, -1, 90, 1, 32, 1, 100, 90, 1, 120, 100, 100, 90, 90, 90, 100, 120,
			30, 120, 200, 32, 90, 120, 90, 2, 35, 90, 90, -1, 200 }
			
new const MAXCLIP[] = { -1, 13, -1, 10, -1, 7, -1, 30, 30, -1, 30, 20, 25, 30, 35, 25, 12, 20,
			10, 30, 100, 8, 30, 30, 20, -1, 7, 30, 30, -1, 60 }
			
new const BUYAMMO[] = { -1, 13, -1, 30, -1, 8, -1, 12, 30, -1, 30, 50, 12, 30, 30, 30, 12, 30,
			10, 30, 30, 8, 30, 30, 30, -1, 7, 30, 30, -1, 60 }
			
new const AMMOID[] = { -1, 9, -1, 2, 12, 5, 14, 6, 4, 13, 10, 7, 6, 4, 4, 4, 6, 10,
			1, 10, 3, 5, 4, 10, 2, 11, 8, 4, 2, -1, 7 }
			
new const AMMOTYPE[][] = { "", "357sig", "", "762nato", "", "buckshot", "", "45acp", "556nato", "", "9mm", "57mm", "45acp",
			"556nato", "556nato", "556nato", "45acp", "9mm", "338magnum", "9mm", "556natobox", "buckshot",
			"556nato", "9mm", "762nato", "", "50ae", "556nato", "762nato", "", "57mm" }
			
new const AMMOWEAPON[] = { 0, CSW_AWP, CSW_SCOUT, CSW_M249, CSW_AUG, CSW_XM1014, CSW_MAC10, CSW_FIVESEVEN, CSW_DEAGLE,
			CSW_P228, CSW_ELITE, CSW_FLASHBANG, CSW_HEGRENADE, CSW_SMOKEGRENADE, CSW_C4 }
			
new const WEAPONENTNAMES[][] = { "", "weapon_p228", "", "weapon_scout", "weapon_hegrenade", "weapon_xm1014", "weapon_c4", "weapon_mac10",
			"weapon_aug", "weapon_smokegrenade", "weapon_elite", "weapon_fiveseven", "weapon_ump45", "weapon_sg550",
			"weapon_galil", "weapon_famas", "weapon_usp", "weapon_glock18", "weapon_awp", "weapon_mp5navy", "weapon_m249",
			"weapon_m3", "weapon_m4a1", "weapon_tmp", "weapon_g3sg1", "weapon_flashbang", "weapon_deagle", "weapon_sg552",
			"weapon_ak47", "weapon_knife", "weapon_p90" }
			
new const Float:kb_weapon_power[] = 
{
	-1.0,	// ---
	-1.0,	// P228
	-1.0,	// ---
	-1.0,	// SCOUT
	-1.0,	// ---
	-1.0,	// XM1014
	-1.0,	// ---
	-1.0,	// MAC10
	-1.0,	// AUG
	-1.0,	// ---
	-1.0,	// ELITE
	-1.0,	// FIVESEVEN
	-1.0,	// UMP45
	-1.0,	// SG550
	-1.0,	// GALIL
	-1.0,	// FAMAS
	-1.0,	// USP
	-1.0,	// GLOCK18
	-1.0,	// AWP
	-1.0,	// MP5NAVY
	-1.0,	// M249
	-1.0,	// M3
	-1.0,	// M4A1
	-1.0,	// TMP
	-1.0,	// G3SG1
	-1.0,	// ---
	-1.0,	// DEAGLE
	-1.0,	// SG552
	-1.0,	// AK47
	-1.0,	// ---
	-1.0	// P90
}
/*-------------------------------------------------------------*/


new const g_objective_ents[][] = 
{ 
	"func_bomb_target", 
	"info_bomb_target", 
	"info_vip_start",
	"func_vip_safetyzone", 
	"func_escapezone", 
	"hostage_entity",
	"monster_scientist",
	"func_hostage_rescue",
	"info_hostage_rescue", 
	"env_fog", 
	"env_rain", 
	"env_snow", 
	"item_longjump",
	"func_vehicle" 
}

#define ID_CURE (taskid - TASK_CURE)
new TASK_CURE = 300

new g_habilidad[33] , g_habilidadnext[33], g_msgHostageAdd , g_msgHostageDel , Float: cl_pushangle[33][3]

new g_save_weapons[33][5]
new g_arma_prim[33]
new g_arma_sec[33]
new g_arma_tri[33]
new g_arma_four[33]

enum _:MAX_ATRIBUTOS 
{ 
	gWeaponName[85] = 0, // NOMBRE DE LAS ARMAS
	Red2, // COLOR ROJO DEL TRAIL
	Green2, // COLOR VERDE DEL TRAIL
	Blue2, // COLOR AZUL DEL TRAIL
	Red, // COLOR ROJO DEL TRAIL
	Green, // COLOR VERDE DEL TRAIL
	Blue, // COLOR AZUL DEL TRAIL
	Ancho, // ANCHO RAYO DE EFECTO
	Float:gDamage,// DA�O EJM: 2.0 MULTIPLICADO X2 EL DA�O NORMAL
	gNivelReq, // NIVEL QUE REQUIERE EL ARMA
	gResetReq, // RESET QUE REQUIERE EL ARMA
	gWeapon, // EL CONST DEL ARMA EJEMPLO (CSW_AK47)
	gWeaponClass[85], // NOMBRE DEL CLASS DEL ARMA (weapon_ak47)
	gvModelo[85],
	gpModelo[85],
	Float:Recoil
}

enum _:Granada_Data  
{
	WeaponName[85],
	NivelReq,
	ResetReq,
	Granada_1, 
	Granada_2, 
	Granada_3 
} 

enum _:Cuchillo_Hm
{
	Nombre_Cuchi[40],
	Modelo_Cuchi_V[60],
	Modelo_Cuchi_P[60],
	Float:Damage_Cuchi,
	Nivel_Cuchi,
	Reset_Cuchi
}
		
#define INACTIVE 999.9

// 204, 102, 0    (Bronce) // 255, 204, 0    (Oro) // 153, 153, 153  (Plata) // 184, 0, 245    (Morado)
// 112, 219, 255  (Celeste) // 255, 61, 216   (Rosado) // 255, 143, 31   (Naranjo) // 102, 51, 0 (Cafe)

enum _:ARMITAS
{
	ARMA_TMP = 0,
	ARMA_SCOUT,
	ARMA_M3,
	ARMA_XM1014,
	ARMA_MAC10,
	ARMA_MP5,
	ARMA_UMP45,
	ARMA_SUBMETCRAZY,
	ARMA_P90,
	ARMA_GALIL,
	ARMA_FAMAS,
	ARMA_HK54,
	ARMA_M4A1,
	ARMA_AK47,
	ARMA_SG552,
	ARMA_ESCOPETAAUTOMATIC,
	ARMA_AUG,
	ARMA_M249,
	ARMA_SG550,
	ARMA_SUBFUSILACP,
	ARMA_G3SG1,
	ARMA_FUSILASALTO,
	ARMA_SPIDERNAVY,
	ARMA_SHAKALFAMAS,
	ARMA_M14,
	ARMA_MP5PLATA,
	ARMA_SILVERM4A1,
	ARMA_ESCOPETARECORTADA,
	ARMA_SILVERAK47,
	ARMA_SUBMETRALLETASILVER,
	ARMA_MP5DORADA,
	ARMA_CABALLA,
	ARMA_GOLDENM4A1STARTER,
	ARMA_P90PLATA,
	ARMA_CONEJAX5,
	ARMA_AK47DORADANORMAL,
	ARMA_AWPICE,
	ARMA_AWPFIRE,
	ARMA_SCAR,
	ARMA_MINIGUN,
	ARMA_TACTICALAWP,
	ARMA_M4A1FUTURE,
	ARMA_WHITETIGERMP5,
	ARMA_SUPERAK47DORADA,
	ARMA_FNPLAYBOY,
	ARMA_ELECTRUCUTADORAAWP,
	ARMA_GAUSS,
	ARMA_AWPMIX,
	ARMA_SPAS,
	ARMA_M3GOLD
}
	
new const gArmasOptimizadas[ARMITAS][MAX_ATRIBUTOS] = {
	{ "Schmidt TMP", 0, 0, 0, 0, 0, 0, 0, 1.0, 0, 0, CSW_TMP, "weapon_tmp", "default", "default", INACTIVE },
	{ "Schmitd Scout", 0, 0, 0, 0, 0, 0, 0, 1.0, 0, 0, CSW_SCOUT, "weapon_scout", "default", "default", INACTIVE },
	{ "M3 Super 90", 0, 0, 0, 0, 0, 0, 0, 1.0, 3, 0, CSW_M3, "weapon_m3", "default", "default", INACTIVE },
	{ "XM1014 M4", 0, 0, 0, 0, 0, 0, 0, 1.0, 6, 0, CSW_XM1014, "weapon_xm1014", "default", "default", INACTIVE },
	{ "Ingram Mac-10", 0, 0, 0, 0, 0, 0, 0, 1.0, 8, 0, CSW_MAC10, "weapon_mac10", "default", "default", INACTIVE },
	{ "MP5 Navy", 0, 0, 0, 0, 0, 0, 0, 1.0, 10, 0, CSW_MP5NAVY, "weapon_mp5navy", "default", "default", INACTIVE },
	{ "UMP 45", 0, 0, 0, 0, 0, 0, 0, 1.0, 12, 0, CSW_UMP45, "weapon_ump45", "default", "default", INACTIVE },
	{ "Sub-Metralla Crazy", 0, 0, 0, 102, 51, 0, 6, 1.6, 15, 0, CSW_MAC10, "weapon_mac10", "models/zpre4/armas/v_mac_crazy.mdl", "default", INACTIVE },
	{ "ES P90", 0, 0, 0, 0, 0, 0, 0, 1.0, 20, 0, CSW_P90, "weapon_p90", "default", "default", INACTIVE },
	{ "IMI GALIL", 0, 0, 0, 0, 0, 0, 0, 1.0, 23, 0, CSW_GALIL, "weapon_galil", "default", "default", INACTIVE },
	{ "Famas", 0, 0, 0, 0, 0, 0, 0, 1.0, 27, 0, CSW_FAMAS, "weapon_famas", "default", "default" },
	{ "Sub-Fusil HK54 Bronze", 0, 0, 0, 204, 102, 0, 14, 1.2, 32, 0, CSW_MP5NAVY, "weapon_mp5navy", "models/zpre4/armas/v_mp5_bronze.mdl", "default", INACTIVE },
	{ "M4A1 Carbine", 0, 0, 0, 0, 0, 0, 0, 1.0, 35, 0, CSW_M4A1, "weapon_m4a1", "default", "default", INACTIVE },
	{ "AK-47 Kalashnikov", 0, 0, 0, 0, 0, 0, 0, 1.0, 37, 0, CSW_AK47, "weapon_ak47", "default", "default", INACTIVE },
	{ "SG-552 Commando", 0, 0, 0, 0, 0, 0, 0, 1.0, 42, 0, CSW_SG552, "weapon_sg552", "default", "default", INACTIVE },
	{ "Black Automatic Escopeta", 0, 0, 0, 204, 102, 0, 10, 1.5, 46, 0, CSW_XM1014, "weapon_xm1014", "models/zpre4/armas/v_black_escopeta.mdl", "default", INACTIVE },
	{ "Steyr AUG A1", 0, 0, 0, 0, 0, 0, 0, 1.0, 50, 0, CSW_AUG, "weapon_aug", "default", "default", INACTIVE },
	{ "M249 Machinegun", 0, 0, 0, 0, 0, 0, 0, 1.0, 55, 0, CSW_M249, "weapon_m249", "default", "default", INACTIVE },
	{ "SG-550 Auto-Sniper", 0, 0, 0, 0, 0, 0, 0, 1.0, 59, 0, CSW_SG550, "weapon_sg550", "default", "default", INACTIVE },
	{ "Sub-Fusil .45 ACP", 0, 0, 0, 102, 51, 0, 15, 1.4, 62, 0, CSW_UMP45, "weapon_ump45", "models/zpre4/armas/v_scar.mdl", "default", INACTIVE },
	{ "G3SG1 Auto-Sniper", 0, 0, 0, 0, 0, 0, 0, 1.0, 68, 0, CSW_G3SG1, "weapon_g3sg1", "models/zpre4/armas/v_g3sg1.mdl", "default", INACTIVE },
	{ "Fusil Asalto Qort", 0, 0, 0, 204, 102, 0, 19, 1.7, 75, 0, CSW_GALIL, "weapon_galil", "models/zpre4/armas/v_galil_qort.mdl", "default", INACTIVE },
	{ "Spider Navy Purp", 0, 0, 0, 184, 0, 245, 15, 1.8, 83, 0, CSW_MP5NAVY, "weapon_mp5navy", "models/zpre4/armas/v_spyder_navy.mdl", "default", INACTIVE },
	{ "Shakal Famas FX", 0, 0, 0, 0, 132, 0, 19, 1.9, 88, 0, CSW_FAMAS, "weapon_famas", "models/zpre4/armas/v_shakal_famas.mdl", "default", INACTIVE },
	{ "M14 KR61 Shark", 0, 0, 0, 112, 219, 255, 12, 2.0, 93, 0, CSW_M4A1, "weapon_m4a1", "models/zpre4/armas/v_m14_shark.mdl", "default", INACTIVE },
	{ "MP5 Plateada", 0, 0, 0, 153, 153, 153, 15, 2.3, 100, 0, CSW_MP5NAVY, "weapon_mp5navy", "models/zpre4/armas/v_mp5_plata.mdl", "default", INACTIVE },
	{ "Silver M4A1", 153, 153, 153, 0, 0, 0, 0, 2.1, 107, 0, CSW_M4A1, "weapon_m4a1", "models/zpre4/armas/v_m4a1_silver.mdl", "default", INACTIVE },
	{ "Escopeta Recortada Plata", 0, 0, 0, 153, 153, 153, 15, 2.8, 114, 0, CSW_M3, "weapon_m3", "models/zpre4/armas/v_escopeta_recortada.mdl", "default", INACTIVE },
	{ "Silver AK-47", 153, 153, 153, 0, 0, 0, 0, 2.1, 120, 0, CSW_AK47, "weapon_ak47", "models/zpre4/armas/v_ak47_silver.mdl", "models/zpre4/armas/p_ak47_silver.mdl", INACTIVE },
	{ "Sub-Metralla Silver", 0, 0, 0, 153, 153, 153, 10, 3.5, 126, 0, CSW_MAC10, "weapon_mac10", "models/zpre4/armas/v_metralleta_mano.mdl", "default", INACTIVE },
	{ "MP5 Dorada", 255, 204, 0, 0, 0, 0, 0, 2.4, 133, 0, CSW_MP5NAVY, "weapon_mp5navy", "models/zpre4/armas/v_mp5g.mdl", "models/zpre4/armas/p_mp5g.mdl" },
	{ "Caballa Tactica", 0, 0, 0, 0, 132, 0, 20, 2.0, 140, 0, CSW_SG552, "weapon_sg552", "models/zpre4/armas/v_caballa_tactica.mdl", "models/zpre4/armas/p_caballa_tactica.mdl", INACTIVE },
	{ "Golden M4A1 Starter", 255, 204, 0, 0, 0, 0, 0, 2.2, 148, 0, CSW_M4A1, "weapon_m4a1", "models/zpre4/armas/v_m4a1_gold_starter.mdl", "models/zpre4/armas/p_m4a1_gold_starter.mdl", INACTIVE },
	{ "P90 Balas Plata", 0, 0, 0, 153, 153, 153, 17, 2.6, 155, 0, CSW_P90, "weapon_p90", "models/zpre4/armas/v_p90_plata.mdl", "models/zpre4/armas/p_p90_plata.mdl", INACTIVE },
	{ "Coneja Special (Daño x5)", 0, 0, 0, 255, 61, 216 , 20, 5.0, 158, 0, CSW_SCOUT, "weapon_scout", "models/zpre4/armas/v_pink_scout.mdl", "default", INACTIVE },
	{ "AK-47 Dorada Normal", 255, 204, 0, 0, 0, 0, 0, 2.0, 168, 0, CSW_AK47, "weapon_ak47", "models/zpre4/armas/v_ak47_dorada_normal.mdl", "models/zpre4/armas/p_ak47_dorada_normal.mdl", INACTIVE },
	{ "AWP Congeladora", 20, 80, 180, 0, 0, 0, 0, 2.4, 175, 0, CSW_AWP, "weapon_awp", "models/zpre4/armas/v_awp_hielo.mdl", "models/zpre4/armas/p_awp_hielo.mdl", INACTIVE },
	{ "AWP de Fuego", 255, 143, 31, 0, 0, 0, 0, 2.0, 178, 0, CSW_AWP, "weapon_awp", "models/zpre4/armas/v_awp_fuego.mdl", "models/zpre4/armas/p_awp_fuego.mdl", INACTIVE },
	{ "SCAR Vendetta", 0, 0, 0, 255, 204, 0, 23, 2.0, 185, 0, CSW_SG552, "weapon_sg552", "models/zpre4/armas/v_arma_depredador.mdl", "models/zpre4/armas/p_arma_depredador.mdl", INACTIVE },
	{ "Mini-Gun Machine", 0, 0, 0, 0, 0, 0, 0, 2.1, 197, 0, CSW_M249, "weapon_m249", "models/zpre4/armas/v_m249_xmas.mdl", "models/zpre4/armas/p_m249_xmas.mdl", INACTIVE },
	{ "Tactical AWP", 0, 0, 0, 0, 100, 200, 13, 4.0, 208, 1, CSW_AWP, "weapon_awp", "models/zpre4/armas/v_awp_sniper.mdl", "default", 0.0 },
	{ "Special Future M4A1", 0, 204, 0, 0, 0, 0, 0, 2.2, 219, 1, CSW_M4A1, "weapon_m4a1", "models/zpre4/armas/v_m4a1_special_future.mdl", "models/zpre4/armas/p_m4a1_special_future.mdl", 0.3 },
	{ "White Tiger MP5", 255, 255, 255, 0, 0, 0, 0, 2.7, 228, 2, CSW_MP5NAVY, "weapon_mp5navy", "models/zpre4/armas/v_mp5tiger.mdl", "models/zpre4/armas/p_mp5tiger.mdl", 0.3 },
	{ "Super AK-47 Dorada ", 0, 0, 0, 255, 204, 0, 25, 2.8, 234, 2, CSW_AK47, "weapon_ak47", "models/zpre4/armas/v_ak47_dorada_super.mdl", "models/zpre4/armas/p_ak47_dorada_super.mdl", 0.2 },
	{ "FN PlayBoy", 0, 0, 0, 255, 61, 216, 24, 2.9, 240, 2, CSW_P90, "weapon_p90", "models/zpre4/armas/v_p90lapin.mdl", "models/zpre4/armas/p_p90lapin.mdl", 0.2 },
	{ "Shift AWP Electrucutadora", 0, 0, 0, 0, 0, 0, 0, 3.0, 50, 2, CSW_AWP, "weapon_awp", "models/zpre4/armas/v_lasergun.mdl", "models/zpre4/armas/p_lasergun.mdl", 0.0 },
	{ "Gauss Weapon", 0, 0, 0, 0, 0, 0, 0, 3.5, 110, 4, CSW_AWP, "weapon_awp", "models/zpre4/armas/v_gauss.mdl", "models/zpre4/armas/p_gauss.mdl", 0.0 },
	{ "AWP de Fuego y Hielo", 100, 128, 180, 0, 0, 0, 0, 3.7, 194, 5, CSW_AWP, "weapon_awp", "models/zpre4/armas/v_awp_mezcla.mdl", "default", 0.0 },
	{ "SPAS 12", 0, 0, 0, 112, 219, 255, 18, 4.0, 200, 6, CSW_M3, "weapon_m3", "models/zpre4/armas/v_spas.mdl", "models/zpre4/armas/p_spas.mdl", 0.0 },
	{ "Golden M3", 0, 0, 0, 255, 204, 0, 20, 4.4, 210, 7, CSW_M3, "weapon_m3", "models/zpre4/armas/v_m3_gold.mdl", "default", -1.0 }
}
new const gPistolasOptimizadas[][MAX_ATRIBUTOS] = {
	{ "Glock Normal .18", 0, 0, 0, 0, 0, 0, 0, 1.0, 0, 0, CSW_GLOCK18, "weapon_glock18", "default", "default", INACTIVE },
	{ "USP .45 Normal", 0, 0, 0, 0, 0, 0, 0, 1.0, 4, 0, CSW_USP, "weapon_usp", "default", "default", INACTIVE },
	{ "P228 Normal", 0, 0, 0, 0, 0, 0, 0, 1.0, 12, 0, CSW_P228, "weapon_p228", "default", "default", INACTIVE },
	{ "Deagle Normal", 0, 0, 0, 0, 0, 0, 0, 1.0, 18, 0, CSW_DEAGLE, "weapon_deagle", "default", "default", INACTIVE },
	{ "FiveSeven 57 Comun", 0, 0, 0, 0, 0, 0, 0, 1.0, 24, 0, CSW_FIVESEVEN, "weapon_fiveseven", "default", "default", INACTIVE },
	{ "Doble Pistolas", 0, 0, 0, 0, 0, 0, 0, 1.0, 31, 0, CSW_ELITE, "weapon_elite", "models/zpre4/armas/v_infinity.mdl", "default", INACTIVE },
	{ "Glock Australiana .25", 0, 0, 0, 204, 102, 0, 9, 1.2, 40, 0, CSW_GLOCK18, "weapon_glock18", "models/zpre4/armas/v_glock18_australiana.mdl", "default", INACTIVE },
	{ "Red Magnum Laser", 255, 0, 0, 0, 0, 0, 0, 1.4, 54, 0, CSW_DEAGLE, "weapon_deagle", "models/zpre4/armas/v_laser_magnum.mdl", "models/zpre4/armas/p_laser_magnum.mdl", INACTIVE },
	{ "Jackal Dual Silver", 153, 153, 153, 0, 0, 0, 0, 1.5, 63, 0, CSW_ELITE, "weapon_elite", "models/zpre4/armas/v_jackal.mdl", "default", INACTIVE },
	{ "Colt M1911 + Laser", 0, 0, 0, 255, 204, 0, 15, 1.8, 70, 0, CSW_GLOCK18, "weapon_glock18", "models/zpre4/armas/v_m1911_laser.mdl", "default", INACTIVE },
	{ "Luger Parabellum", 204, 102, 0 , 0, 0, 0, 0, 2.0, 81, 0, CSW_P228, "weapon_p228", "models/zpre4/armas/v_luger.mdl", "default", INACTIVE },
	{ "Walther P38", 255, 61, 216, 0, 0, 0, 0, 2.2, 95, 0, CSW_FIVESEVEN, "weapon_fiveseven", "models/zpre4/armas/v_walter.mdl", "default", INACTIVE },
	{ "Browning High Power", 112, 219, 255, 0, 0, 0, 0, 2.7, 100, 0, CSW_USP, "weapon_usp", "models/zpre4/armas/v_browning.mdl", "default", INACTIVE },
	{ "Sig-Sauer Special", 0, 0, 0, 255, 0, 7, 19, 2.5, 110, 0, CSW_FIVESEVEN, "weapon_fiveseven", "models/zpre4/armas/v_sigsauer.mdl", "default", INACTIVE },
	{ "Beretta Shark", 0, 0, 0, 255, 143, 31, 16, 2.9, 125, 0, CSW_P228, "weapon_p228", "models/zpre4/armas/v_beretta.mdl", "default", INACTIVE },
	{ "Smith & Wesson", 184, 0, 245, 0, 0, 0, 0, 3.1, 133, 0, CSW_DEAGLE, "weapon_deagle", "models/zpre4/armas/v_smith.mdl", "default", INACTIVE },
	{ "Blue Laser 56", 0, 0, 0, 0, 0, 255, 23, 3.5, 147, 0, CSW_FIVESEVEN, "weapon_fiveseven", "models/zpre4/armas/v_laser_56.mdl", "default", INACTIVE },
	{ "Golden Deagle (Wesker)", 0, 0, 0, 255, 204, 0, 19, 2.0, 150, 1, CSW_DEAGLE, "weapon_deagle", "models/zpre4/armas/v_deagle_wesker.mdl", "models/zpre4/armas/p_deagle_wesker.mdl", 0.0 },
	{ "Glock Hielo Fast", 0, 0, 0, 0, 100, 255, 15, 3.8, 156, 2, CSW_GLOCK18, "weapon_glock18", "models/zpre4/armas/v_glock18_hielo.mdl", "default", 0.3 },
	{ "Glock Fuego Fast", 0, 0, 0, 255, 143, 31, 20, 4.0, 164, 3, CSW_GLOCK18, "weapon_glock18", "models/zpre4/armas/v_glock18_fuego.mdl", "default", 0.3 },
	{ "Electro Fast Deagle", 0, 0, 0, 255, 255, 0, 20, 4.3, 173, 4, CSW_DEAGLE, "weapon_deagle", "models/zpre4/armas/v_electro_deagle.mdl", "default", 0.2 },
	{ "Infinity's Explosivas", 0, 0, 0, 0, 0, 0, 0, 5.0, 182, 6, CSW_ELITE, "weapon_elite", "models/zpre4/armas/v_infinity2.mdl", "models/zpre4/armas/p_infinity2.mdl", 0.0 }
}
new const gGranadasOptimizadas[][Granada_Data] =  
{  
	{ "1 Fuego - 1 Hielo - 1 Luz", 0, 0, 1, 1, 1 }, 
	{ "1 Fuego - 1 Hielo - 2 Luz", 25, 0, 1, 1, 2 }, 
	{ "1 Fuego - 2 Hielo - 1 Luz", 50, 0, 2, 1, 2 }, 
	{ "2 Fuego - 2 Hielo - 2 Luz", 75, 0, 2, 2, 2 }, 
	{ "1 Molotov - 2 Hielo - 1 Luz", 100, 0, 1, 2, 1 },
	{ "1 Molotov - 2 Hielo - 1 Burbuja", 125, 0, 1, 2, 1 },
	{ "2 Molotov - 3 Hielo - 1 Burbuja", 150, 0, 2, 3, 1 },
	{ "2 Molotov - 3 Hielo - 2 Burbuja", 175, 1, 2, 3, 2 },
	{ "3 Molotov - 3 Hielo - 2 Burbuja", 200, 1, 3, 3, 2 },
	{ "3 Molotov - 3 Hielo - 3 Burbuja", 225, 2, 3, 3, 3 }
}

new const gCuchillosOptimizadas[][Cuchillo_Hm] =
{
	{ "Espada de Madera", "models/zpre4/v_knife_ciudadano.mdl", "models/zpre4/p_knife_ciudadano.mdl", 1.0, 0, 0 },
	{ "Cortador de Queso", "models/zpre4/v_knife_medico.mdl", "models/zpre4/p_knife_medico.mdl", 2.0, 20, 0 },
	{ "Cuchillo Militar", "models/zpre4/v_knife_milico.mdl", "models/zpre4/p_knife_milico.mdl", 3.0, 50, 0 },
	{ "Machete de Sierra", "models/zpre4/v_knife_comando.mdl", "models/zpre4/p_knife_comando.mdl", 3.5, 80, 0 },
	{ "Hacha de Caza", "models/zpre4/v_knife_capitan.mdl", "models/zpre4/p_knife_capitan.mdl", 4.0, 120, 0 },
	{ "2 Sables", "models/zpre4/v_knife_burlador.mdl", "models/zpre4/p_knife_burlador.mdl", 4.5, 160, 0 },
	{ "Motosierra", "models/zpre4/v_knife_chorizo.mdl", "models/zpre4/p_knife_chorizo.mdl", 5.0, 200, 0 },
	{ "Mariposa Special", "models/zpre4/v_knife_wesker.mdl", "default", 8.0, 210, 1 },
	{ "Machete de Guerra", "models/zpre4/v_knife_sniper.mdl", "default", 8.5, 215, 1 },
	{ "Garras Depredador", "models/zpre4/v_knife_depredador_golden.mdl", "default", 9.5, 215, 2 },
	{ "Mazo Asesino", "models/zpre4/v_knife_survivor.mdl", "models/zpre4/p_knife_survivor.mdl", 10.0, 220, 2 },
	{ "Cuchillo de Fuego", "models/zpre4/v_knife_fuego.mdl", "models/zpre4/p_knife_fuego.mdl", 12.0, 250, 3 },
	{ "Cuchillo de Hielo", "models/zpre4/v_knife_hielo.mdl", "default", 12.5, 280, 3 },
	{ "Sable Ninja", "models/zpre4/v_sable_ninja.mdl", "models/zpre4/p_sable_ninja.mdl", 20.0, 300, 4 }
}

enum _:Habilidades_Hm
{
	Nombre_Clase[40],
	Nombre_Hab[40],
	Nivel_Hab,
	Reset_Hab
}


enum _: MAX_HAB
{
	HAB_NINGUNA = 0,
	HAB_HS,
	HAB_RECOIL,
	HAB_MEDICO,
	HAB_RADAR, 
	HAB_SALTOS,
	HAB_ANTIBOMBAINF
}

new const gHabilidadesHumanas[MAX_HAB][Habilidades_Hm] = 
{
	{ "Clasico", "Ningunga habilidad", 0, 0 },
	{ "Aplicado", "Hace + daño x Headshot", 30, 0 },
	{ "Atinado", "Posee una Baja Recoil", 65, 0 },
	{ "Leech", "Regenera su vida", 97, 0 },
	{ "Espia", "Detecta zombies en radar", 135, 0 },
	{ "Saltarin", "Puede saltar 1 vez en el aire", 166, 0 },
	{ "Mascara", "Inmunidad a Bombas Infeccion", 230, 0 }
}

/*---------- Menu Extra Items ---------------*/
enum _:MAX_ITEMS_ZM
{
	EXTRA_ANTIDOTE_ZM = 0,
	EXTRA_MADNESS_ZM,
	EXTRA_ANTIFUEGO_ZM,
	EXTRA_ANTIHIELO_ZM,
	EXTRA_HAB_RADAR_ZM,
	EXTRA_VIDA_ZM,
	EXTRA_GRAVEDAD_ZM,
	EXTRA_ANTILASER_ZM,
	EXTRA_CONFBOMB_ZM,
	EXTRA_STRIPBOMB_ZM,
	EXTRA_INFBOMB_ZM
}

enum _:MAX_ITEMS_HM
{
	EXTRA_NVISION = 0,
	EXTRA_LASERMINES,
	EXTRA_ELEGIR,
	EXTRA_INFAMMO,
	EXTRA_LUZ,
	EXTRA_FUEGO,
	EXTRA_HIELO,
	EXTRA_SG550,
	EXTRA_G3SG1,
	EXTRA_M249,
	EXTRA_MOLOTOV,
	EXTRA_BURBUJA,
	EXTRA_INFRAGOOGLES,
	EXTRA_HAB_RADAR_HM,
	EXTRA_CHALECO,
	EXTRA_VIDA,
	EXTRA_AUX,
	EXTRA_ANTIBOMB_INF,
	EXTRA_INMUNIDAD,
	EXTRA_SACOS,
	EXTRA_BAZOOKA,
	EXTRA_ANTIDOTEBOMB,
	EXTRA_PIPE,
	EXTRA_MULTISALTOS
}

enum _:Data_Item
{
	NOMBRE[99] ,
	COSTO,
	NIVEL
}

new g_VecesPipe[33]
new g_VecesAntidote[33]

new const gExtraItemsHumanos[MAX_ITEMS_HM][Data_Item] =
{
	{ "Vision Nocturna", 12, 0 },
	{ "LaserMines", 30, 0 },
	{ "Elegir Armas Nuevamente", 25, 0 },
	{ "Balas Infinitas (1 Ronda)", 30, 0 },
	{ "Granada Luz", 5, 0 },
	{ "Granada Fuego", 5, 0 },
	{ "Granada Hielo", 5, 0 },
	{ "Rifle SG-550", 25, 3 },
	{ "Red Rifle Basic", 25, 5 },
	{ "Mini-Gun Machine", 25, 10 },
	{ "Granada Molotov", 15, 15 },
	{ "Granada Burbuja", 15, 20 },
	{ "Gafas Infra-Rojas", 15, 21 },
	{ "Radar Detecta Zombies", 12, 22 },
	{ "+100 Chaleco", 12, 24 },
	{ "+100 Vida", 12, 24 },
	{ "Primeros Auxilios", 20, 26 },
	{ "Mascara Anti-Bombas Infeccion", 20, 30 },
	{ "Inmunidad (15 Segundos)", 30, 40 },
	{ "Sacos de Arena (+10)", 25, 45 },
	{ "Bazooka", 50, 50 },
	{ "Granada Antidoto", 120, 60 },
	{ "Bomba Casera L4D (Pipe Bomb)", 100, 68 },
	{ "MultiSalto(+1)", 15, 95 }
}


new const gExtraItemsZombies[MAX_ITEMS_ZM][Data_Item] =
{
	{ "T-Anti-Virus", 25, 0 },
	{ "Furia Zombie", 30, 10 },
	{ "Proteccion Anti-Fuego", 12, 15 },
	{ "Proteccion Anti-Hielo", 12, 15 },
	{ "Radar Detecta Humanos", 15, 20 },
	{ "+1000 Salud", 15, 25 },
	{ "Super Gravedad", 30, 28 },
	{ "Proteccion Anti-Laser", 40, 40 },
	{ "Bomba Confusion", 30, 80 },
	{ "Bomba Removedora de Armas", 40, 110 },
	{ "Bomba De Infeccion", 100, 190 }

}

/*====================================================================================
                                     [Extra Items]
====================================================================================*/

new sprite_playerheat
new g_radar_detecta_zombies[33], g_antilaser[33]
new g_radar_detecta_humanos[33]
new g_antihielo[33]
new g_has_unlimited_clip[33], g_antinfeccion[33]
new g_antifuego[33]
new Float:g_fDelay[33], g_ThermalOn[33]
new pcvar_delay, pcvar_maxdmg, pcvar_radius
new rocketsmoke, explosion, bazsmoke 
new has_baz[33], CanShoot[33], bazuka[33]
new dmgcount[33]
new g_modcount[33]
new g_modenabled[33]
new bool:g_canRespawn[33]

new g_Saltos[33]
new g_SaltosMax[33]
/*====================================================================================
                                     [FIN Extra Items]
====================================================================================*/
new g_molotovSpr, g_MolotovTrail, hotflarex, thunder, white, ElectroSpr,
g_exploSpr, g_flameSpr, g_smokeSpr, g_glassSpr, gRayoLevelSpr, gTracerDepre, gTracerSpr, g_frost_gib, g_frost_explode
new has_burbuja[33], has_molotov[33], g_antidotebomb[33]


enum _:e_HandsModels
{
	MODEL_VKNIFE_ALIEN = 0,
	MODEL_VKNIFE_ASSASSIN,
	MODEL_VKNIFE_NEMESIS,
	MODEL_VGRENADE_INFECT,
	MODEL_PGRENADE_INFECT,
	MODEL_WGRENADE_INFECT,
	MODEL_VGRENADE_MOLOTOV,
	MODEL_PGRENADE_MOLOTOV,
	MODEL_WGRENADE_MOLOTOV,
	MODEL_VGRENADE_FUEGO,
	MODEL_PGRENADE_FUEGO,
	MODEL_WGRENADE_FUEGO,
	MODEL_VGRENADE_BURBUJA,
	MODEL_PGRENADE_BURBUJA,
	MODEL_WGRENADE_BURBUJA,
	MODEL_XGRENADE_BURBUJA,
	MODEL_VGRENADE_FROST,
	MODEL_PGRENADE_FROST,
	MODEL_WGRENADE_FROST,
	MODEL_VGRENADE_FLARE,
	MODEL_PGRENADE_FLARE,
	MODEL_WGRENADE_FLARE,
	MODEL_VBAZOOKA,
	MODEL_PBAZOOKA,
	MODEL_WBAZOOKA,
	MODEL_XBAZOOKA,
	MODEL_VGRENADE_ANTIDOTO,
	MODEL_PGRENADE_ANTIDOTO,
	MODEL_WGRENADE_ANTIDOTO
}

new gModelsManos[e_HandsModels][64]

new const gConstNombresManos[e_HandsModels][] = 
{
	"MODELO MANOS ALIEN",
	"MODELO MANOS ASSASSIN",
	"MODELO MANOS NEMESIS",
	"MODELO V GRANADA INFECCION",
	"MODELO P GRANADA INFECCION",
	"MODELO W GRANADA INFECCION",
	"MODELO V GRANADA MOLOTOV",
	"MODELO P GRANADA MOLOTOV",
	"MODELO W GRANADA MOLOTOV",
	"MODELO V GRANADA FUEGO",
	"MODELO P GRANADA FUEGO",
	"MODELO W GRANADA FUEGO",
	"MODELO V GRANADA BURBUJA",
	"MODELO P GRANADA BURBUJA",
	"MODELO W GRANADA BURBUJA",
	"MODELO X GRANADA BURBUJA",
	"MODELO V GRANADA HIELO",
	"MODELO P GRANADA HIELO",
	"MODELO W GRANADA HIELO",
	"MODELO V GRANADA LUZ",
	"MODELO P GRANADA LUZ",
	"MODELO W GRANADA LUZ",
	"MODELO V BAZOOKA",
	"MODELO P BAZOOKA",
	"MODELO W BAZOOKA",
	"MODELO X BAZOOKA MISIL",
	"MODELO V GRANADA ANTIDOTO",
	"MODELO P GRANADA ANTIDOTO",
	"MODELO W GRANADA ANTIDOTO"
}

new const Modelos_Server[][] = 
{ 
	"models/player/zpre4_z_krauser/zpre4_z_krausert.mdl"
}

new const Sonidos_Server[][] =
{
	"items/flashlight1.wav",
	"items/9mmclip1.wav",
	"zpre4/escudo.wav",
	"zpre4/inmunidad_on.wav",
	"ambience/xtal_down1.wav",
	"zpre4/subir_nivel1.wav",
	"buttons/spark6.wav",
	"weapons/electro4.wav",
	"zpre4/molotov_explosion.wav",
	"zpre4/antidotebomb_explosion.wav",
	"zpre4/campo_explosion.wav",
	"ambience/particle_suck2.wav",
	"scientist/scream22.wav",
	"items/smallmedkit1.wav",
	"items/nvg_on.wav",
	"warcraft3/impalelaunch1.wav",
	"warcraft3/impalehit.wav",
	"warcraft3/frostnova.wav",
	"zpre4/zombie_madness.wav",
	"nihilanth/nil_thelast.wav",
	"zombie_plague/grenade_infect.wav",
	"zombie_plague/grenade_explode.wav",
	"zombie_plague/zombie_fall1.wav",
	"weapons/rocketfire1.wav",
	"weapons/nuke_fly.wav",
	"weapons/mortarhit.wav",
	"items/gunpickup2.wav"
}

new const COLOR_NAMES[10][9] = 
{
	"Rojo",
	"Verde",
	"Azul",
	"Amarillo",
	"Celeste",
	"Blanco",
	"Violeta",
	"Naranja",
	"Magenta",
	"Violeta"
}

new const COLOR_RGB[10][3] = 
{
	{ 255, 0, 0 },
	{ 0, 255, 0 },
	{ 0, 0, 255 },
	{ 255, 255, 0 },
	{ 135, 206, 255 },
	{ 255, 255, 255 },
	{ 75, 0, 130 },
	{ 255, 112, 40 },
	{ 255, 0, 255 },
	{ 100, 0, 255 }
}

// Hud stuff
new const hud_stuff[][] = 
{
	"Mover a la Izquierda",
	"Mover a la derecha",
	"Mover Arriba",
	"Mover Abajo",
	"Centrar",
	"Esquinar a la Izquierda",
	"Esquinar a la Derecha"
}

// Niveles
#define Exp_Level(%1)       floatround(((%1 + 1) * float(%1 / 2)) * 6)

new g_exp[33], g_level[33], g_reset[33]


enum _:DATA_MEJORA 
{ 
	MEJORA_NAME[33], 
	MEJORA_MAX 
} 	

new gMejoras[][DATA_MEJORA] = 
{ 
	{ "Vida", 40 }, 
	{ "Velocidad", 40 }, 
	{ "Chaleco", 40 }, 
	{ "Gravedad", 40 } 
}

// Mejoras
#define costo(%1)        (%1 * 2) + 10 // costo de mejoras
#define ammount_speed(%1)         (%1 * 2.5) // upgrade speed
#define ammount_health(%1)         (%1 * 5) // upgrade health
#define ammount_armor(%1)         (%1 * 5) // upgrade armor
#define ammount_gravity(%1)     ((%1 * 0.01) * 1.4) // upgrade gravity

// creamos variables multidimensionales
new g_mejoras[33][4] // contiene las mejoras zombies y humanas
new g_puntos[33] // puntos humanos y zombies

// nos vamos al final del zp y agregamos

// Explosion radius for custom grenades
const Float:NADE_EXPLOSION_RADIUS = 240.0

// HACK: pev_ field used to store additional ammo on weapons
const PEV_ADDITIONAL_AMMO = pev_iuser1

// HACK: pev_ field used to store custom nade types and their values
const PEV_NADE_TYPE = pev_flTimeStepSound
enum (+= 1111)
{
	NADE_TYPE_INFECTION = 1111,
	NADE_TYPE_NAPALM,
	NADE_TYPE_FROST,
	NADE_TYPE_FLARE,
	NADE_TYPE_BUBBLE,
	NADE_TYPE_MOLOTOV,
	NADE_TYPE_ANTIDOTO
}
const PEV_FLARE_COLOR = pev_punchangle
const PEV_FLARE_DURATION = pev_flSwimTime

// Weapon bitsums
const PRIMARY_WEAPONS_BIT_SUM = (1<<CSW_SCOUT)|(1<<CSW_XM1014)|(1<<CSW_MAC10)|(1<<CSW_AUG)|(1<<CSW_UMP45)|(1<<CSW_SG550)|(1<<CSW_GALIL)|(1<<CSW_FAMAS)|(1<<CSW_AWP)|(1<<CSW_MP5NAVY)|(1<<CSW_M249)|(1<<CSW_M3)|(1<<CSW_M4A1)|(1<<CSW_TMP)|(1<<CSW_G3SG1)|(1<<CSW_SG552)|(1<<CSW_AK47)|(1<<CSW_P90)
const SECONDARY_WEAPONS_BIT_SUM = (1<<CSW_P228)|(1<<CSW_ELITE)|(1<<CSW_FIVESEVEN)|(1<<CSW_USP)|(1<<CSW_GLOCK18)|(1<<CSW_DEAGLE)
const TERCIARY_WEAPONS_BIT_SUM = (1<<CSW_SMOKEGRENADE)|(1<<CSW_HEGRENADE)|(1<<CSW_FLASHBANG)

// Allowed weapons for zombies (added grenades/bomb for sub-plugin support, since they shouldn't be getting them anyway)
const ZOMBIE_ALLOWED_WEAPONS_BITSUM = (1<<CSW_KNIFE)|(1<<CSW_HEGRENADE)|(1<<CSW_FLASHBANG)|(1<<CSW_SMOKEGRENADE)|(1<<CSW_C4)|(1<<CSW_DEAGLE)

// Classnames for separate model entities
new const WEAPON_ENT_CLASSNAME[] = "weapon_model"

// Menu keys
const KEYSMENU = MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_5|MENU_KEY_6|MENU_KEY_7|MENU_KEY_8|MENU_KEY_9|MENU_KEY_0

// Admin menu actions
enum
{
	ACTION_ZOMBIEFY_HUMANIZE = 0,
	ACTION_MAKE_NEMESIS,
	ACTION_MAKE_SURVIVOR,
	ACTION_MAKE_SNIPER,
	ACTION_MAKE_WESKER,
	ACTION_MAKE_DEPRE,
	ACTION_MAKE_ASSASSIN,
	ACTION_MAKE_ALIEN,
	ACTION_MAKE_NINJA,
	ACTION_RESPAWN_PLAYER,
}

// Custom forward return values
const ZP_PLUGIN_HANDLED = 97

#define SCOREATTRIB_NONE    0
#define SCOREATTRIB_DEAD    ( 1 << 0 )
#define SCOREATTRIB_BOMB    ( 1 << 1 )
#define SCOREATTRIB_VIP  ( 1 << 2 )

/*================================================================================
 [Global Variables]
=================================================================================*/

// Player vars
const MAX_ZOMBIE_CLASSSES = 23
new g_zclass_name[MAX_ZOMBIE_CLASSSES][32] // name
new g_zclass_info[MAX_ZOMBIE_CLASSSES][32] // description
new g_zclass_model[MAX_ZOMBIE_CLASSSES][32] // player model
new g_zclass_modelindex[MAX_ZOMBIE_CLASSSES] // model index
new g_zclass_clawmodel[MAX_ZOMBIE_CLASSSES][32] // claw model
new g_zclass_hp[MAX_ZOMBIE_CLASSSES] // health
new g_zclass_spd[MAX_ZOMBIE_CLASSSES] // speed
new Float:g_zclass_grav[MAX_ZOMBIE_CLASSSES] // gravity
new Float:g_zclass_kb[MAX_ZOMBIE_CLASSSES] // knockback
new Float:g_zombie_spd[33]
new iFlags
new g_zombiescore, g_humanscore
new g_zombie[33] // is zombie
new g_nemesis[33] // is nemesis
new g_survivor[33] // is survivor
new g_firstzombie[33] // is first zombie
new g_lastzombie[33] // is last zombie
new g_lasthuman[33] // is last human
new g_frozen[33] // is frozen (can't move)
new g_nodamage[33] // has spawn protection/zombie madness
new g_respawn_as_zombie[33] // should respawn as zombie
new g_nvision[33] // has night vision
new g_nvisionenabled[33] // has night vision turned on
new g_zombieclass[33] // zombie class
new g_zombieclassnext[33] // zombie class for next infection
new g_flashlight[33] // has custom flashlight turned on
new g_flashbattery[33] = { 100, ... } // custom flashlight battery
new g_canbuy[33] // is allowed to buy a new weapon through the menu
new g_canbuy_sec[33] // is allowed to buy a new weapon through the menu
new g_canbuy_tri[33] // is allowed to buy a new weapon through the menu
new g_canbuy_four[33] // is allowed to buy a new weapon through the menu
new g_ammopacks[33] // ammo pack count
new g_damagedealt[33] // damage dealt to zombies (used to calculate ammo packs reward)
new Float:g_lastleaptime[33] // time leap was last used
new Float:g_lastflashtime[33] // time flashlight was last toggled
new g_playermodel[33][32] // current model's short name [player][model]
new g_menu_data[33][7] // data for some menu handlers
new g_ent_weaponmodel[33] // weapon model entity
new g_burning_duration[33] // burning task duration
new g_sniper[33] // is sniper
new g_wesker[33] // is wesker
new g_depre[33] // is depredador
new g_assassin[33] // is assassin
new g_alien[33] // is alien
new g_l4d[33][4] // is zoey, louis, francis, bill
new g_ninja[33] // is Ninja
new Float:g_hud_pos[33][2] // hud position
new Inmu_Usado[33]

// Segun Colores en escala:  RED, GREEN, BLUE
new Colores[33][15] // (0-1-2) Hud Color... (3-4-5) Nvg Hm... (6-7-8) Nvg Zm... (9-10-11) Linterna... (12-13-14) Flare... 
new g_efecto[33]

// Wesker Deagle
new Trie:g_tClassWesker, g_depreknife[33], g_ninjasable[33], g_zombiefuria[33]
//Happy Hour (Hora Feliz)
new bool:announce_HF[2]
new HF_MULTIPLIER
new g_access_double[33] = { 1, ...}

new db_name[MAX_STATS_SAVED][32] // player name
new db_modcount[MAX_STATS_SAVED] // modcount
new db_modenabled[MAX_STATS_SAVED] // modcount
new db_slot_i // additional saved slots counter (should start on maxplayers+1)

// Game vars
new g_pluginenabled // ZPA enabled
new g_newround // new round starting
new g_endround // round ended
new g_nemround // nemesis round
new g_sniperround // sniper round
new g_weskerround // wesker round
new g_depreround // depredador round
new g_ninjaround // ninja round
new g_assassinround // assasin round
new g_alienround // alien round
new g_lnjround // LNJ round
new g_swarmround // swarm round
new g_torneoround // torneo round
new g_synapsisround // synapsis round
new g_plagueround // plague round
new g_survround // survivor round
new g_l4dround // l4d round
new g_modestarted // mode fully started
new g_lastmode // last played mode
new g_scorezombies, g_scorehumans // team scores
new g_spawnCount, g_spawnCount2 // available spawn points counter
new Float:g_spawns[MAX_CSDM_SPAWNS][3], Float:g_spawns2[MAX_CSDM_SPAWNS][3] // spawn points data
new Float:g_teams_targettime // for adding delays between Team Change messages
new g_MsgSync, g_MsgSync2, g_MsgSync3//, g_MsgSync6 // message sync objects
new g_freezetime // whether CS's freeze time is on
new g_maxplayers // max players counter
new g_czero // whether we are running on a CZ server
new g_fwSpawn, g_fwPrecacheSound // spawn and precache sound forward handles
new g_infbombcounter[33], g_antidotecounter[33], g_madnesscounter[33], g_madnesscounter2[33], g_classcounter[33], g_classcounter2[33] // to limit buying some items
new g_lastplayerleaving // flag for whenever a player leaves and another takes his place
new g_switchingteam // flag for whenever a player's team change emessage is sent
new g_allowinfection

// Message IDs vars
new g_msgNVGToggle, g_msgScoreInfo, g_msgScoreAttrib, g_msgAmmoPickup, g_msgScreenFade,
g_msgDeathMsg, g_msgSetFOV, g_msgFlashlight, g_msgFlashBat, g_msgTeamInfo, g_msgDamage,
g_msgHideWeapon, g_msgCrosshair, g_msgSayText, g_msgScreenShake, g_msgCurWeapon

// Some forward handlers
new g_fwRoundStart, g_fwRoundEnd, g_fwUserInfected_pre, g_fwUserInfected_post,
g_fwUserHumanized_pre, g_fwUserHumanized_post, g_fwUserInfect_attempt,
g_fwUserHumanize_attempt, g_fwUserUnfrozen,
g_fwUserLastZombie, g_fwUserLastHuman, g_fwPlayerSpawnPost, g_fwDummyResult

new g_zclass_i // loaded zombie classes counter

// CVAR pointers
new cvar_lighting, cvar_deathmatch, cvar_customnvg, cvar_hitzones, cvar_logcommands,
cvar_flashsize, cvar_flashdrain, cvar_removedoors, cvar_customflash, cvar_randspawn, 
cvar_infammo, cvar_knockbackpower, cvar_freezeduration, cvar_triggered, cvar_flashcharge,
cvar_spawnprotection, cvar_nvgsize, cvar_flareduration, cvar_zclasses, cvar_warmup, 
cvar_showactivity, cvar_flashdist, cvar_fireduration, cvar_firedamage, cvar_fireslowdown,
cvar_knockbackducking, cvar_knockbackdamage, cvar_knockbackzvel, cvar_preventconsecutive,
cvar_flaresize, cvar_spawndelay, cvar_nvggive,
cvar_knockback, cvar_removedropped, cvar_aiminfo,
cvar_knockbackdist, cvar_flashshowall,
cvar_blockpushables, cvar_madnessduration,cvar_keephealthondisconnect,cvar_flaresize2, cvar_auratodos, 
cvar_antidotelimit, cvar_madnesslimit, cvar_infbomblimit

// CVARS - Zombies
new cvar_leapzombiesforce, cvar_leapzombiesheight, cvar_leapzombiescooldown, cvar_zombiefov, cvar_zombiefirsthp,
cvar_leapzombies, cvar_zombiepainfree, cvar_zombiebleeding

// CVARS - Humanos
new cvar_humanspd

// CVARS - Multiple Infeccion
new cvar_multichance, cvar_multiminplayers, cvar_multiratio, cvar_multi

// CVARS - Swarm
new cvar_swarm, cvar_swarmchance, cvar_swarmminplayers

// CVARS - Plague
new cvar_plague, cvar_plaguechance, cvar_plagueratio, cvar_plagueminplayers, cvar_plaguenemnum, 
cvar_plaguenemhpmulti, cvar_plaguesurvhpmulti, cvar_plaguesurvnum

// CVARS - Nemesis
new cvar_nemhp, cvar_nem, cvar_nemauraradius, cvar_nemchance, cvar_nempainfree, cvar_nemgravity,
cvar_nemspd, cvar_nembasehp, cvar_nemknockback,
cvar_nemminplayers, cvar_leapnemesisforce, cvar_leapnemesisheight, cvar_leapnemesiscooldown, cvar_leapnemesis, 
cvar_nemdamage

// CVARS - Survivor
new cvar_surv, cvar_survchance, cvar_survhp, cvar_survspd, cvar_survpainfree, cvar_survgravity,
cvar_leapsurvivorforce, cvar_leapsurvivorheight, cvar_leapsurvivor, cvar_survbasehp,
cvar_survaura, cvar_survminplayers, cvar_leapsurvivorcooldown,
cvar_survinfammo

// CVARS - Sniper
new cvar_sniper, cvar_sniperchance, cvar_sniperminplayers, cvar_sniperhp,
cvar_sniperbasehp, cvar_sniperpainfree, cvar_sniperinfammo, cvar_sniperspd,
cvar_snipergravity, cvar_sniperaura, cvar_sniperfraggore

// CVARS - Assassin
new cvar_assassin, cvar_assassinchance, cvar_assassinminplayers,
cvar_assassinhp, cvar_assassinbasehp, cvar_assassinspd, cvar_assassingravity, cvar_assassindamage ,cvar_assassinknockback,
cvar_assassinpainfree,cvar_leapassassin, cvar_leapassassinforce, cvar_leapassassinheight, cvar_leapassassincooldown

// CVARS - Alien
new cvar_alien,cvar_alienchance ,cvar_alienminplayers,
cvar_alienhp , cvar_alienbasehp ,cvar_alienspd ,cvar_aliengravity ,cvar_aliendamage ,cvar_alienknockback,
cvar_alienpainfree, cvar_alienratio, cvar_alienglow

// CVARS - LNJ
new cvar_lnj, cvar_lnjchance, cvar_lnjminplayers, cvar_lnjnemhpmulti, cvar_lnjsurvhpmulti,
cvar_lnjratio

// CVARS - Tournament
new cvar_torneochance, cvar_torneo, cvar_torneominplayers

// CVAR - Synapsis
new cvar_synapsis, cvar_synapsischance, cvar_synapsisminplayers, cvar_synapsisnemhpmulti,
cvar_synapsissurvhpmulti

// CVARS - Wesker
new cvar_wesker, cvar_weskerchance, cvar_weskerminplayers, cvar_weskerhp,
cvar_weskerbasehp, cvar_weskerpainfree, cvar_weskerinfammo, cvar_weskerspd,
cvar_weskergravity, cvar_weskeraura

// CVARS - Depredador
new cvar_depre, cvar_deprechance, cvar_depreminplayers, cvar_deprehp,
cvar_deprebasehp, cvar_deprepainfree, cvar_depreinfammo, cvar_deprespd,
cvar_depregravity, cvar_depreaura,
cvar_depredador_fireradius, cvar_depredador_cooldown, cvar_depredador_firespeed, cvar_depredador_damage

// CVARS - L4D
new cvar_l4d, cvar_l4dchance, cvar_l4dminplayers, cvar_l4dratio, cvar_l4dgravity, cvar_l4dbasehp, cvar_l4dhp, 
cvar_l4dspd, cvar_l4daura, cvar_l4dpainfree

// CVARS - Ninja
new cvar_ninja, cvar_ninjachance, cvar_ninjaminplayers, cvar_ninjahp,
cvar_ninjabasehp, cvar_ninjapainfree, cvar_ninjaspd,
cvar_ninjagravity, cvar_ninjaaura,
cvar_leapninja, cvar_leapninjaforce, cvar_leapninjaheight, cvar_leapninjacooldown

// CVARS - Respawn
new cvar_allowrespawninfection, cvar_allowrespawnalien, cvar_allowrespawnassassin, cvar_allowrespawnlnj, cvar_allowrespawntorneo, cvar_allowrespawnswarm,
cvar_allowrespawnplague, cvar_allowrespawnl4d, cvar_allowrespawnninja, cvar_allowrespawnsniper, cvar_allowrespawndepre,
cvar_allowrespawnwesker, cvar_allowrespawnsurv, cvar_allowrespawnnem, cvar_allowrespawnsynapsis,

cvar_respawnzomb, cvar_respawnhum, cvar_respawnnem, cvar_respawnsurv, cvar_respawnsniper, cvar_respawnwesker,
cvar_respawndepre, cvar_respawnninja, cvar_respawnl4d , cvar_respawnalien, cvar_respawnassassin,

cvar_respawnonsuicide, cvar_respawnafterlast, cvar_respawnworldspawnkill, cvar_lnjrespsurv, cvar_lnjrespnem

// Cached stuff for players
new g_isconnected[33] // whether player is connected
new g_isalive[33] // whether player is alive
new g_currentweapon[33] // player's current weapon id
new g_playername[33][33] // player's name
#define is_user_valid_connected(%1) (1 <= %1 <= g_maxplayers && g_isconnected[%1])
#define is_user_valid_alive(%1) (1 <= %1 <= g_maxplayers && g_isalive[%1])

// Cached CVARs
new g_cached_customflash, Float:g_cached_nemspd, Float:g_cached_humanspd,
Float:g_cached_survspd, g_cached_leapzombies, Float:g_cached_leapzombiescooldown, g_cached_leapnemesis,
Float:g_cached_leapnemesiscooldown, g_cached_leapsurvivor, Float:g_cached_leapsurvivorcooldown,
Float:g_cached_sniperspd, g_cached_leapsniper, Float:g_cached_leapsnipercooldown,
Float:g_cached_assassinspd, g_cached_leapassassin, Float:g_cached_leapassassincooldown,
Float:g_cached_alienspd, g_cached_leapalien, Float:g_cached_leapaliencooldown,
Float:g_cached_weskerspd, g_cached_leapwesker, Float:g_cached_leapweskercooldown,
Float:g_cached_deprespd, g_cached_leapdepre, Float:g_cached_leapdeprecooldown,
Float:g_cached_l4dspd, Float:g_cached_ninjaspd, g_cached_leapninja, Float:g_cached_leapninjacooldown

/*================================================================================
 [Natives, Precache and Init]
=================================================================================*/

public plugin_natives()
{
	register_native("zp_exp_user_update", "CheckEXP", 1)
	register_native("zp_get_user_level", "_get_level", 1)
	register_native("zp_get_lastmode", "native_get_lastmode", 1)
	register_native("zp_set_user_level", "_set_level", 1)
	
	register_native("zp_get_user_exp", "_get_exp", 1)
	register_native("zp_get_user_exp_level", "_get_exp_level", 1)
	
	register_native("zp_set_user_exp", "native_set_user_exp", 1)
	
	register_native("zp_set_user_mejora1", "native_set_user_mejora1", 1)
	register_native("zp_set_user_mejora2", "native_set_user_mejora2", 1)
	register_native("zp_set_user_mejora3", "native_set_user_mejora3", 1)
	register_native("zp_set_user_mejora4", "native_set_user_mejora4", 1)
	register_native("zp_set_user_puntos", "native_set_user_puntos", 1)
	register_native("zp_get_user_puntos", "native_get_user_puntos", 1)
	
	register_native("zp_get_user_mejora1", "native_get_user_mejora1", 1)
	register_native("zp_get_user_mejora2", "native_get_user_mejora2", 1)
	register_native("zp_get_user_mejora3", "native_get_user_mejora3", 1)
	register_native("zp_get_user_mejora4", "native_get_user_mejora4", 1)
	
	register_native("zp_get_user_resets", "native_get_user_resets", 1)
	register_native("zp_set_user_resets", "native_set_user_resets", 1)
	
	register_native("zp_get_user_human_class", "native_get_user_human_class", 1)
	register_native("zp_set_user_human_class", "native_set_user_human_class", 1)
	
	register_native("zp_get_hf", "native_get_hf", 1)
	register_native("zp_get_user_double_access", "native_get_user_double_access", 1)
	
	register_native("zp_get_user_antihielo", "native_get_user_antihielo", 1)
	register_native("zp_get_user_noantihielo", "native_get_user_noantihielo", 1)
	register_native("zp_get_user_antifuego", "native_get_user_antifuego", 1)
	register_native("zp_get_user_noantifuego", "native_get_user_noantifuego", 1)
	register_native("zp_get_user_antilaser", "native_get_user_antilaser", 1)
	register_native("zp_get_user_nodamage", "native_get_user_nodamage", 1)
	register_native("zp_set_user_nodamage", "native_set_user_nodamage", 1) 
	register_native("zp_set_user_acabo_nodamage", "native_set_user_acabo_nodamage", 1)
	register_native("zp_override_user_model", "native_override_user_model", 1)
	
	// Player specific natives
	register_native("zp_get_user_zombie", "native_get_user_zombie", 1)
	register_native("zp_get_user_nemesis", "native_get_user_nemesis", 1)
	register_native("zp_get_user_l4d", "native_get_user_l4d", 1)
	register_native("zp_get_user_survivor", "native_get_user_survivor", 1)
	register_native("zp_get_user_first_zombie", "native_get_user_first_zombie", 1)
	register_native("zp_get_user_last_zombie", "native_get_user_last_zombie", 1)
	register_native("zp_get_user_last_human", "native_get_user_last_human", 1)
	register_native("zp_get_user_zombie_class", "native_get_user_zombie_class", 1)
	register_native("zp_get_user_next_class", "native_get_user_next_class", 1)
	register_native("zp_set_user_zombie_class", "native_set_user_zombie_class", 1)
	register_native("zp_get_user_ammo_packs", "native_get_user_ammo_packs", 1)
	register_native("zp_set_user_ammo_packs", "native_set_user_ammo_packs", 1)
	register_native("zp_get_zombie_maxhealth", "native_get_zombie_maxhealth", 1)
	register_native("zp_get_user_batteries", "native_get_user_batteries", 1)
	register_native("zp_set_user_batteries", "native_set_user_batteries", 1)
	register_native("zp_get_user_nightvision", "native_get_user_nightvision", 1)
	register_native("zp_set_user_nightvision", "native_set_user_nightvision", 1)
	register_native("zp_infect_user", "native_infect_user", 1)
	register_native("zp_disinfect_user", "native_disinfect_user", 1)
	register_native("zp_make_user_nemesis", "native_make_user_nemesis", 1)
	register_native("zp_make_user_survivor", "native_make_user_survivor", 1)
	register_native("zp_respawn_user", "native_respawn_user", 1)
	register_native("zp_get_user_sniper", "native_get_user_sniper", 1)
	register_native("zp_make_user_sniper", "native_make_user_sniper", 1)
	register_native("zp_get_user_wesker", "native_get_user_wesker", 1)
	register_native("zp_make_user_wesker", "native_make_user_wesker", 1)
	register_native("zp_get_user_depre", "native_get_user_depre", 1)
	register_native("zp_make_user_depre", "native_make_user_depre", 1)
	register_native("zp_get_user_ninja", "native_get_user_ninja", 1)
	register_native("zp_make_user_ninja", "native_make_user_ninja", 1)
	register_native("zp_get_user_assassin", "native_get_user_assassin", 1)
	register_native("zp_make_user_assassin", "native_make_user_assassin", 1)
	register_native("zp_make_user_alien", "native_make_user_alien", 1)
	register_native("zp_get_user_alien", "native_get_user_alien", 1)
	register_native("zp_get_user_model", "native_get_user_model", 0)
	
	// Round natives
	register_native("zp_has_round_started", "native_has_round_started", 1)
	register_native("zp_is_nemesis_round", "native_is_nemesis_round", 1)
	register_native("zp_is_survivor_round", "native_is_survivor_round", 1)
	register_native("zp_is_swarm_round", "native_is_swarm_round", 1)
	register_native("zp_is_plague_round", "native_is_plague_round", 1)
	register_native("zp_get_zombie_count", "native_get_zombie_count", 1)
	register_native("zp_get_human_count", "native_get_human_count", 1)
	register_native("zp_get_nemesis_count", "native_get_nemesis_count", 1)
	register_native("zp_get_survivor_count", "native_get_survivor_count", 1)
	register_native("zp_is_sniper_round", "native_is_sniper_round", 1)
	register_native("zp_get_sniper_count", "native_get_sniper_count", 1)
	register_native("zp_is_wesker_round", "native_is_wesker_round", 1)
	register_native("zp_get_wesker_count", "native_get_wesker_count", 1)
	register_native("zp_is_depre_round", "native_is_depre_round", 1)
	register_native("zp_get_depre_count", "native_get_depre_count", 1)
	register_native("zp_is_ninja_round", "native_is_ninja_round", 1)
	register_native("zp_get_ninja_count", "native_get_ninja_count", 1)
	register_native("zp_is_assassin_round", "native_is_assassin_round", 1)
	register_native("zp_get_assassin_count", "native_get_assassin_count", 1)
	register_native("zp_is_alien_round", "native_is_alien_round", 1)
	register_native("zp_get_alien_count", "native_get_alien_count", 1)
	register_native("zp_is_lnj_round", "native_is_lnj_round", 1)
	register_native("zp_is_torneo_round", "native_is_torneo_round", 1)
	register_native("zp_is_synapsis_round", "native_is_synapsis_round", 1)
	register_native("zp_is_l4d_round", "native_is_l4d_round", 1)
	register_native("zp_get_l4d_count", "native_get_l4d_count", 1)
	
	// External additions natives
	register_native("zp_register_game_mode", "native_register_game_mode", 1)
	register_native("zp_register_zombie_class", "native_register_zombie_class", 1)
}

public plugin_precache()
{
	PLUGIN_NAME = "Zombie Killer Galaxy"
	register_plugin(PLUGIN_NAME, "1.3", PLUGIN_AUTOR)
	
	g_pluginenabled = true
	
	model_human = ArrayCreate(32, 1)
	model_nemesis = ArrayCreate(32, 1)
	model_alien = ArrayCreate(32, 1)
	model_assassin = ArrayCreate(32, 1)
	model_survivor = ArrayCreate(32, 1)
	model_sniper = ArrayCreate(32, 1)
	model_depredador = ArrayCreate(32, 1)
	model_wesker = ArrayCreate(32, 1)
	model_ninja = ArrayCreate(32, 1)
	model_bill = ArrayCreate(32, 1)
	model_francis = ArrayCreate(32, 1)
	model_louis = ArrayCreate(32, 1)
	model_zoey = ArrayCreate(32, 1)
	model_vip = ArrayCreate(32, 1)
	model_vipgold = ArrayCreate(32, 1)
	model_vip = ArrayCreate(32, 1)
	model_moderador = ArrayCreate(32, 1)
	model_creador = ArrayCreate(32, 1)
	sound_win_zombies = ArrayCreate(64, 1)
	sound_win_humans = ArrayCreate(64, 1)
	sound_win_no_one = ArrayCreate(64, 1)
	sound_ambience = ArrayCreate(64, 1)
	sound_wesker = ArrayCreate(64, 1)
	sound_l4d = ArrayCreate(64, 1)
	sound_synapsis = ArrayCreate(64, 1)
	sound_armageddon = ArrayCreate(64, 1)
	sound_depredador = ArrayCreate(64, 1)
	sound_ninja = ArrayCreate(64, 1)
	sound_assassin = ArrayCreate(64, 1)
	sound_torneo = ArrayCreate(64, 1)
	sound_survivor = ArrayCreate(64, 1)
	sound_nemesis = ArrayCreate(64, 1)
	sound_sniper = ArrayCreate(64, 1)
	sound_swarm = ArrayCreate(64, 1)
	sound_multipleinfeccion = ArrayCreate(64, 1)
	sound_plague = ArrayCreate(64, 1)
	sound_alien = ArrayCreate(64, 1)
	sound_entrar = ArrayCreate(64, 1)
	
	g_gamemode_name = ArrayCreate(32, 1)
	g_gamemode_flag = ArrayCreate(1, 1)
	g_gamemode_chance = ArrayCreate(1, 1)
	g_gamemode_allow = ArrayCreate(1, 1)
	g_gamemode_dm = ArrayCreate(1, 1)
	
	g_arrays_created = true
	
	load_customization_from_files()
	
	new buffer[128], i
	for (i = 0; i < ArraySize(sound_win_zombies); i++)
	{
		ArrayGetString(sound_win_zombies, i, buffer, charsmax(buffer))
		precache_sound2(buffer)
	}
	for (i = 0; i < ArraySize(sound_win_humans); i++)
	{
		ArrayGetString(sound_win_humans, i, buffer, charsmax(buffer))
		precache_sound2(buffer)
	}
	for (i = 0; i < ArraySize(sound_win_no_one); i++)
	{
		ArrayGetString(sound_win_no_one, i, buffer, charsmax(buffer))
		precache_sound2(buffer)
	}
	for (i = 0; i < ArraySize(sound_ambience); i++)
	{
		ArrayGetString(sound_ambience, i, buffer, charsmax(buffer))
		precache_sound2(buffer)
	}
	for (i = 0; i < ArraySize(sound_wesker); i++)
	{
		ArrayGetString(sound_wesker, i, buffer, charsmax(buffer))
		precache_sound2(buffer)
	}
	for (i = 0; i < ArraySize(sound_l4d); i++)
	{
		ArrayGetString(sound_l4d, i, buffer, charsmax(buffer))
		precache_sound2(buffer)
	}
	for (i = 0; i < ArraySize(sound_synapsis); i++)
	{
		ArrayGetString(sound_synapsis, i, buffer, charsmax(buffer))
		precache_sound2(buffer)
	}
	for (i = 0; i < ArraySize(sound_armageddon); i++)
	{
		ArrayGetString(sound_armageddon, i, buffer, charsmax(buffer))
		precache_sound2(buffer)
	}
	for (i = 0; i < ArraySize(sound_depredador); i++)
	{
		ArrayGetString(sound_depredador, i, buffer, charsmax(buffer))
		precache_sound2(buffer)
	}
	for (i = 0; i < ArraySize(sound_ninja); i++)
	{
		ArrayGetString(sound_ninja, i, buffer, charsmax(buffer))
		precache_sound2(buffer)
	}
	for (i = 0; i < ArraySize(sound_assassin); i++)
	{
		ArrayGetString(sound_assassin, i, buffer, charsmax(buffer))
		precache_sound2(buffer)
	}
	for (i = 0; i < ArraySize(sound_torneo); i++)
	{
		ArrayGetString(sound_torneo, i, buffer, charsmax(buffer))
		precache_sound2(buffer)
	}
	for (i = 0; i < ArraySize(sound_survivor); i++)
	{
		ArrayGetString(sound_survivor, i, buffer, charsmax(buffer))
		precache_sound2(buffer)
	}
	for (i = 0; i < ArraySize(sound_nemesis); i++)
	{
		ArrayGetString(sound_nemesis, i, buffer, charsmax(buffer))
		precache_sound2(buffer)
	}
	for (i = 0; i < ArraySize(sound_sniper); i++)
	{
		ArrayGetString(sound_sniper, i, buffer, charsmax(buffer))
		precache_sound2(buffer)
	}
	for (i = 0; i < ArraySize(sound_swarm); i++)
	{
		ArrayGetString(sound_swarm, i, buffer, charsmax(buffer))
		precache_sound2(buffer)
	}
	for (i = 0; i < ArraySize(sound_multipleinfeccion); i++)
	{
		ArrayGetString(sound_multipleinfeccion, i, buffer, charsmax(buffer))
		precache_sound2(buffer)
	}
	for (i = 0; i < ArraySize(sound_plague); i++)
	{
		ArrayGetString(sound_plague, i, buffer, charsmax(buffer))
		precache_sound2(buffer)
	}
	for (i = 0; i < ArraySize(sound_alien); i++)
	{
		ArrayGetString(sound_alien, i, buffer, charsmax(buffer))
		precache_sound2(buffer)
	}
	for (i = 0; i < ArraySize(sound_entrar); i++)
	{
		ArrayGetString(sound_entrar, i, buffer, charsmax(buffer))
		precache_sound2(buffer)
	}
	
	// Modelos
	for (i = 0; i < ArraySize(model_human); i++)
	{
		ArrayGetString(model_human, i, buffer, charsmax(buffer))
		precache_player_model(buffer)
	}
	for (i = 0; i < ArraySize(model_nemesis); i++)
	{
		ArrayGetString(model_nemesis, i, buffer, charsmax(buffer))
		precache_player_model(buffer)
	}
	for (i = 0; i < ArraySize(model_alien); i++)
	{
		ArrayGetString(model_alien, i, buffer, charsmax(buffer))
		precache_player_model(buffer)
	}
	for (i = 0; i < ArraySize(model_assassin); i++)
	{
		ArrayGetString(model_assassin, i, buffer, charsmax(buffer))
		precache_player_model(buffer)
	}
	for (i = 0; i < ArraySize(model_survivor); i++)
	{
		ArrayGetString(model_survivor, i, buffer, charsmax(buffer))
		precache_player_model(buffer)
	}
	for (i = 0; i < ArraySize(model_sniper); i++)
	{
		ArrayGetString(model_sniper, i, buffer, charsmax(buffer))
		precache_player_model(buffer)
	}
	for (i = 0; i < ArraySize(model_depredador); i++)
	{
		ArrayGetString(model_depredador, i, buffer, charsmax(buffer))
		precache_player_model(buffer)
	}
	for (i = 0; i < ArraySize(model_wesker); i++)
	{
		ArrayGetString(model_wesker, i, buffer, charsmax(buffer))
		precache_player_model(buffer)
	}
	for (i = 0; i < ArraySize(model_ninja); i++)
	{
		ArrayGetString(model_ninja, i, buffer, charsmax(buffer))
		precache_player_model(buffer)
	}
	for (i = 0; i < ArraySize(model_bill); i++)
	{
		ArrayGetString(model_bill, i, buffer, charsmax(buffer))
		precache_player_model(buffer)
	}
	for (i = 0; i < ArraySize(model_francis); i++)
	{
		ArrayGetString(model_francis, i, buffer, charsmax(buffer))
		precache_player_model(buffer)
	}
	for (i = 0; i < ArraySize(model_louis); i++)
	{
		ArrayGetString(model_louis, i, buffer, charsmax(buffer))
		precache_player_model(buffer)
	}
	for (i = 0; i < ArraySize(model_zoey); i++)
	{
		ArrayGetString(model_zoey, i, buffer, charsmax(buffer))
		precache_player_model(buffer)
	}
	for (i = 0; i < ArraySize(model_vip); i++)
	{
		ArrayGetString(model_vip, i, buffer, charsmax(buffer))
		precache_player_model(buffer)
	}
	for (i = 0; i < ArraySize(model_vipgold); i++)
	{
		ArrayGetString(model_vipgold, i, buffer, charsmax(buffer))
		precache_player_model(buffer)
	}
	for (i = 0; i < ArraySize(model_moderador); i++)
	{
		ArrayGetString(model_moderador, i, buffer, charsmax(buffer))
		precache_player_model(buffer)
	}
	for (i = 0; i < ArraySize(model_creador); i++)
	{
		ArrayGetString(model_creador, i, buffer, charsmax(buffer))
		precache_player_model(buffer)
	}
	
	for(i = 0; i < e_HandsModels; i++)
		precache_model(gModelsManos[i])
		
	ElectroSpr = precache_model("sprites/spark1.spr");
	sprite_playerheat = precache_model("sprites/poison.spr")
	g_frost_gib = precache_model("sprites/zpre4/frost_gib.spr")
	g_frost_explode = precache_model("sprites/zpre4/frost_explode.spr")
	//Explosion = precache_model("sprites/zerogxplode.spr")
	white = precache_model("sprites/white.spr")
	hotflarex = precache_model("sprites/flare6.spr")
	thunder = precache_model("sprites/zbeam1.spr")
	g_molotovSpr = precache_model("sprites/zpre4/zerogxplode4.spr")
	g_MolotovTrail = precache_model("sprites/zpre4/muzzleflash.spr")
	g_exploSpr = precache_model("sprites/shockwave.spr")
	g_flameSpr = precache_model("sprites/zpre4/flame4.spr")
	g_smokeSpr = precache_model("sprites/black_smoke3.spr")
	g_glassSpr = precache_model("models/glassgibs.mdl")
	gTracerSpr = precache_model("sprites/dot.spr")
	gTracerDepre = precache_model("sprites/laserbeam.spr")
	gRayoLevelSpr = precache_model("sprites/lgtning.spr")
	rocketsmoke = precache_model("sprites/smoke.spr");
	explosion = precache_model("sprites/zpre4/explosion_bazooka.spr");
	bazsmoke  = precache_model("sprites/steam1.spr");
	engfunc(EngFunc_PrecacheModel, Modelo_Disparo)
	Depre_Efecto = engfunc(EngFunc_PrecacheModel, "sprites/zpre4/explosion_depredadador.spr")
	engfunc(EngFunc_PrecacheSound, "zpre4/depredador_fire.wav")
	engfunc(EngFunc_PrecacheSound, "zpre4/depredador_fire2.wav")
	engfunc(EngFunc_PrecacheSound, "zpre4/depredador_explode.wav")
	
	new linedata[100]
	formatex(linedata, charsmax(linedata), "gfx/env/%s_bk.tga", sky_names)
	engfunc(EngFunc_PrecacheGeneric, linedata)
	formatex(linedata, charsmax(linedata), "gfx/env/%s_dn.tga", sky_names)
	engfunc(EngFunc_PrecacheGeneric, linedata)
	formatex(linedata, charsmax(linedata), "gfx/env/%s_ft.tga", sky_names)
	engfunc(EngFunc_PrecacheGeneric, linedata)
	formatex(linedata, charsmax(linedata), "gfx/env/%s_lf.tga", sky_names)
	engfunc(EngFunc_PrecacheGeneric, linedata)
	formatex(linedata, charsmax(linedata), "gfx/env/%s_rt.tga", sky_names)
	engfunc(EngFunc_PrecacheGeneric, linedata)
	formatex(linedata, charsmax(linedata), "gfx/env/%s_up.tga", sky_names)
	engfunc(EngFunc_PrecacheGeneric, linedata)
		
	for (i = 0; i < sizeof zombie_infect; i++)
		engfunc(EngFunc_PrecacheSound, zombie_infect[i])
	for (i = 0; i < sizeof zombie_pain; i++)
		engfunc(EngFunc_PrecacheSound, zombie_pain[i])
	for (i = 0; i < sizeof nemesis_pain; i++)
		engfunc(EngFunc_PrecacheSound, nemesis_pain[i])
	for (i = 0; i < sizeof assassin_pain; i++)
		engfunc(EngFunc_PrecacheSound, assassin_pain[i])
	for (i = 0; i < sizeof alien_pain; i++)
		engfunc(EngFunc_PrecacheSound, alien_pain[i])
	for (i = 0; i < sizeof zombie_die; i++)
		engfunc(EngFunc_PrecacheSound, zombie_die[i])
	for (i = 0; i < sizeof zombie_idle; i++)
		engfunc(EngFunc_PrecacheSound, zombie_idle[i])
	for (i = 0; i < sizeof zombie_miss_slash; i++)
		engfunc(EngFunc_PrecacheSound, zombie_miss_slash[i])
	for (i = 0; i < sizeof zombie_miss_wall; i++)
		engfunc(EngFunc_PrecacheSound, zombie_miss_wall[i])
	for (i = 0; i < sizeof zombie_hit_normal; i++)
		engfunc(EngFunc_PrecacheSound, zombie_hit_normal[i])
	for (i = 0; i < sizeof zombie_hit_stab; i++)
		engfunc(EngFunc_PrecacheSound, zombie_hit_stab[i])
	for (i = 0; i < sizeof grenade_fire_player; i++)
		engfunc(EngFunc_PrecacheSound, grenade_fire_player[i])
		
	for(new i = 0; i < sizeof gArmasOptimizadas; i++)
	{
		if(!(equal(gArmasOptimizadas[i][gvModelo] , "default")))
			precache_model(gArmasOptimizadas[i][gvModelo])
		if(!(equal(gArmasOptimizadas[i][gpModelo] , "default")))
			precache_model(gArmasOptimizadas[i][gpModelo])
	}
	
	for(new i = 0; i < sizeof gPistolasOptimizadas; i++)
	{
		if(!(equal(gPistolasOptimizadas[i][gvModelo] , "default")))
			precache_model(gPistolasOptimizadas[i][gvModelo])
		if(!(equal(gPistolasOptimizadas[i][gpModelo] , "default")))
			precache_model(gPistolasOptimizadas[i][gpModelo])
	}
	for(new i = 0; i < sizeof gCuchillosOptimizadas; i++)
	{
		if(!(equal(gCuchillosOptimizadas[i][Modelo_Cuchi_V] , "default")))
			precache_model(gCuchillosOptimizadas[i][Modelo_Cuchi_V])
		if(!(equal(gCuchillosOptimizadas[i][Modelo_Cuchi_P] , "default")))
			precache_model(gCuchillosOptimizadas[i][Modelo_Cuchi_P])
	}
	
	new ent
	
	// Fake Hostage (to force round ending)
	ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "hostage_entity"))
	if (pev_valid(ent))
	{
		engfunc(EngFunc_SetOrigin, ent, Float:{8192.0 ,8192.0 ,8192.0})
		dllfunc(DLLFunc_Spawn, ent)
	}
	#if defined AMBIENCE_FOG
	ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "env_fog"))
	if (pev_valid(ent))
	{
		fm_set_kvd(ent, "density", FOG_DENSITY, "env_fog")
		fm_set_kvd(ent, "rendercolor", FOG_COLOR, "env_fog")
	}
	#endif
	
	#if defined AMBIENCE_RAIN
	engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "env_rain"))
	#endif
	
	#if defined AMBIENCE_SNOW
	engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "env_snow"))
	#endif
	
	// Load customization data
	g_tClassWesker = TrieCreate()
	RegisterHam(Ham_TraceAttack, "worldspawn", "TraceAttack", 1)
	TrieSetCell(g_tClassWesker, "worldspawn", 1)
	RegisterHam(Ham_TraceAttack, "player", "TraceAttack", 1)
	TrieSetCell(g_tClassWesker, "player", 1)
	register_forward(FM_Spawn, "Spawn", 1)
	
	for (new k = 0; k < sizeof Sonidos_Server; k++) precache_sound(Sonidos_Server[k])
	for (new f = 0; f < sizeof Modelos_Server; f++) precache_model(Modelos_Server[f])
	
	// Fake Hostage (to force round ending)
	ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "hostage_entity"))
	if (pev_valid(ent))
	{
		engfunc(EngFunc_SetOrigin, ent, Float:{8192.0,8192.0,8192.0})
		dllfunc(DLLFunc_Spawn, ent)
	}
	
	// Prevent some entities from spawning
	g_fwSpawn = register_forward(FM_Spawn, "fw_Spawn")
	
	// Prevent hostage sounds from being precached
	g_fwPrecacheSound = register_forward(FM_PrecacheSound, "fw_PrecacheSound")
}

public plugin_init()
{
	// Plugin disabled?
	if (!g_pluginenabled) return;
	
	// No zombie classes?
	if (!g_zclass_i) set_fail_state("No hay clases de zombie cargadas")
	
	// Print the number of registered Zombie Classes
	server_print("[ZK Galaxy] Total Registered Zombie Classes: %d", g_zclass_i)
	
	// Print the number of registered Extra Items
	server_print("[ZK Galaxy] Total Registered Extra Items: %d", MAX_ITEMS_HM + MAX_ITEMS_ZM)

	// Language files
	register_dictionary("zombie_galaxy.txt")
	
	pcvar_delay = register_cvar("zp_baz_delay", "15.0");
	pcvar_maxdmg = register_cvar("zp_baz_dmg", "1200");
	pcvar_radius = register_cvar("zp_baz_radius", "400");
	register_concmd("zp_bazooka", "give_bazooka", CREADOR, "<Nombre/@Todos> Escribe El Nombre de El Jugador.")
	register_event("CurWeapon","switch_to_knife","be","1=1","2=29");
	register_clcmd("drop", "drop_call");
	register_clcmd("kill", "block");
	register_clcmd("baz_fire", "fire_call");
	
	/*=================================================
	|-------------- SISTEMA DE CUENTAS ---------------|
	==================================================*/
	
	register_message(get_user_msgid("ShowMenu"), "TextMenu")
	register_message(get_user_msgid("VGUIMenu"), "VGUIMenu")
	register_menucmd(register_menuid("Register System Main Menu"), 1023, "HandlerMainMenu")
	register_menucmd(register_menuid("Password Menu"), 1023, "HandlerConfirmPasswordMenu")
	register_clcmd("jointeam", "HookTeamCommands")
	register_clcmd("chooseteam", "HookTeamCommands")
	register_clcmd("ESCRIBE_TU_PASSWORD", "Login")
	register_clcmd("REGISTRA_TU_PASSWORD", "Register")
	register_clcmd("say", "client_command1")
	register_clcmd("say_team", "client_command1")
	register_clcmd("NUEVA_PASSWORD", "ChangePasswordNew")
	register_clcmd("PASSWORD_ANTIGUA", "ChangePasswordOld")
	register_forward(FM_ClientUserInfoChanged, "ClientInfoChanged")
	register_clcmd("say top15", "clcmd_saytop15")
	register_clcmd("say /top15", "clcmd_saytop15")
	g_maxplayers = get_maxplayers()
	g_screenfade = get_user_msgid("ScreenFade")
	
	
	/*register_forward(FM_Sys_Error, "shutdown") 
	register_forward(FM_GameShutdown, "shutdown") 
	register_forward(FM_ServerDeactivate , "shutdown") 
	register_forward(FM_ChangeLevel, "shutdown")
	*/
	g_ajc_class[0] = register_cvar("zp_ajc_class_t", "5")
	g_ajc_class[1] = register_cvar("zp_ajc_class_ct", "5")
	
	/*-----------------------------------------------------------------------------------------*/
	/*-----------------------------------------------------------------------------------------*/
	/*-----------------------------------------------------------------------------------------*/
	
	register_forward(FM_Touch, "fw_touch");
	register_forward(FM_Touch, "fw_Touch")

	// Events
	register_event("HLTV", "event_round_start", "a", "1=0", "2=0")
	register_event("StatusValue", "event_show_status", "be", "1=2", "2!0")
	register_event("StatusValue", "event_hide_status", "be", "1=1", "2=0")
	register_logevent("logevent_round_start",2, "1=Round_Start")
	register_logevent("logevent_round_end", 2, "1=Round_End")
	register_event("AmmoX", "event_ammo_x", "be")
	register_event("30", "event_intermission", "a")
		
	g_msgHostageAdd = get_user_msgid("HostagePos")
	g_msgHostageDel = get_user_msgid("HostageK")
	set_task (1.0 ,"radar_scan_detecta_zombies" , _ , _ , _ , "b")
	set_task (1.0 ,"radar_scan_detecta_humanos" , _ , _ , _ , "b")
	
	new weapon_name[24]
	for (new i = 1; i <= 30; i++)
	{
		if (!(ZOMBIE_ALLOWED_WEAPONS_BITSUM & 1 << i) && get_weaponname(i, weapon_name, 23))
		{
			RegisterHam(Ham_Weapon_PrimaryAttack, weapon_name, "fw_Weapon_PrimaryAttack_Post", 1)
		}
	}
	g_fwGameModeSelected = CreateMultiForward("zp_game_mode_selected", ET_IGNORE, FP_CELL, FP_CELL)
	
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_knife", "fw_knife_PrimaryAttack_Post", 1)
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_m249", "fw_m249_PrimaryAttack_Post", 1)
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_awp", "fw_awp_PrimaryAttack_Post", 1)
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_deagle", "fw_deagle_PrimaryAttack_Post", 1)
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_elite", "fw_elite_PrimaryAttack_Post", 1)
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_m3", "fw_m3_PrimaryAttack_Post", 1)
		
	register_forward(FM_AddToFullPack, "fw_WhatTheFuck_Post", 1)
	register_event("CurWeapon", "make_tracer", "be", "1=1", "3>0")
	RegisterHam(Ham_Spawn, "player", "fw_PlayerSpawn_Post", 1)
	RegisterHam(Ham_Killed, "player", "fw_PlayerKilled")
	RegisterHam(Ham_Killed, "player", "fw_PlayerKilled_Post", 1)
	RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage")
	RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage_Post", 1)
	RegisterHam(Ham_TraceAttack, "player", "fw_TraceAttack")
	RegisterHam(Ham_Use, "func_tank", "fw_UseStationary")
	RegisterHam(Ham_Use, "func_tankmortar", "fw_UseStationary")
	RegisterHam(Ham_Use, "func_tankrocket", "fw_UseStationary")
	RegisterHam(Ham_Use, "func_tanklaser", "fw_UseStationary")
	RegisterHam(Ham_Use, "func_tank", "fw_UseStationary_Post", 1)
	RegisterHam(Ham_Use, "func_tankmortar", "fw_UseStationary_Post", 1)
	RegisterHam(Ham_Use, "func_tankrocket", "fw_UseStationary_Post", 1)
	RegisterHam(Ham_Use, "func_tanklaser", "fw_UseStationary_Post", 1)
	RegisterHam(Ham_Use, "func_pushable", "fw_UsePushable")
	RegisterHam(Ham_Touch, "weaponbox", "fw_TouchWeapon")
	RegisterHam(Ham_Touch, "armoury_entity", "fw_TouchWeapon")
	RegisterHam(Ham_Touch, "weapon_shield", "fw_TouchWeapon")
	RegisterHam(Ham_AddPlayerItem, "player", "fw_AddPlayerItem")
	for (new i = 1; i < sizeof WEAPONENTNAMES; i++)
		if (WEAPONENTNAMES[i][0]) RegisterHam(Ham_Item_Deploy, WEAPONENTNAMES[i], "fw_Item_Deploy_Post", 1)
	
	RegisterHam( Ham_Player_Jump, "player", "fw_PlayerJump" )
	
	// FM Forwards
	register_forward(FM_Think, "fw_think")
	register_forward(FM_ClientDisconnect, "fw_ClientDisconnect_Post", 1)
	register_forward(FM_EmitSound, "fw_EmitSound")
	register_forward(FM_ClientUserInfoChanged, "fw_ClientUserInfoChanged")
	register_forward(FM_GetGameDescription, "fw_GetGameDescription")
	register_forward(FM_SetModel, "fw_SetModel", 0)
	RegisterHam(Ham_Think, "grenade", "fw_ThinkGrenade")
	
	register_forward(FM_CmdStart, "fw_CmdStart")
	register_forward(FM_CmdStart, "fw_CmdStart_Post")
	register_forward(FM_PlayerPreThink, "fw_prethink");
	register_forward(FM_PlayerPreThink, "PlayerPreThink")
	register_forward(FM_PlayerPreThink, "fw_PlayerPreThink")
	register_forward(FM_PlayerPreThink, "fw_PlayerPreThink2")
	register_forward(FM_AddToFullPack, "fw_AddToFullPack_Post", 1)
	unregister_forward(FM_Spawn, g_fwSpawn)
	unregister_forward(FM_PrecacheSound, g_fwPrecacheSound)
	//register_forward(FM_ClientUserInfoChanged, "fwClientUserInfoChanged")
	RegisterHam(Ham_Touch, "grenade", "fw_GrenadeTouch", 1)
	
	register_clcmd("say /vida", "Comprar_HP")
	register_clcmd("say_team /vida", "Comprar_HP")
	register_clcmd("say /armor", "Comprar_Armor")
	register_clcmd("say_team /armor", "Comprar_Armor")
	register_clcmd("say /aux", "Comprar_HP_y_Armor")
	register_clcmd("say_team /aux", "Comprar_HP_y_Armor")
	register_clcmd("nightvision", "clcmd_nightvision")
	register_clcmd("drop", "clcmd_drop")
	register_clcmd("buyammo1", "clcmd_buyammo")
	register_clcmd("buyammo2", "clcmd_buyammo")
	register_clcmd("say /consejo","cmdConsejo", _, "- Envia una Consejo al server -")
	register_clcmd("Escribe_Tu_Recomendacion", "Consejo_ASD")
	register_clcmd("say /denunciar","cmdREPORT", _, "- Denunica A un jugador -")
	register_clcmd("Escribe_Tu_Denuncia","ReportSAY")
	
	// Menus
	register_menu("Game Menu", KEYSMENU, "Menu_Principal_Juego_Cases")
	
	// Admin commands
	/*register_concmd("zp_zombie", "cmd_zombie", CREADOR, "<nombre> - convertido en Hombie")
	register_concmd("zp_human", "cmd_human", CREADOR, "<nombre> - convertido en Humano")
	register_concmd("zp_nemesis", "cmd_nemesis", CREADOR, "<nombre> - convertido en Nemesis")
	register_concmd("zp_survivor", "cmd_survivor", CREADOR, "<nombre> - convertido en Survivor")
	register_concmd("zp_respawn", "cmd_respawn", CREADOR, "<nombre> - fue revivido")
	register_concmd("zp_swarm", "cmd_swarm", CREADOR, " - Inicio Modo Swarm")
	register_concmd("zp_multi", "cmd_multi", CREADOR, " - Inicio Modo Multiple Infeccion")
	register_concmd("zp_plague", "cmd_plague", CREADOR, " - Inicio Modo Plaga")
	register_concmd("zp_sniper", "cmd_sniper", CREADOR, "<nombre> - convertido en Sniper")
	register_concmd("zp_wesker", "cmd_wesker", CREADOR, "<nombre> - convertido en Wesker")
	register_concmd("zp_depredador", "cmd_depre", CREADOR, "<nombre> - convertido en Depredador")
	register_concmd("zp_assassin", "cmd_assassin", CREADOR, "<nombre> - convertido en Assassin")
	register_concmd("zp_alien", "cmd_alien", CREADOR, "<nombre> - convertido en Alien")
	register_concmd("zp_lnj", "cmd_lnj", CREADOR, " - Inicio Modo Survivors vs Nemesis")
	register_concmd("zp_torneo", "cmd_torneo", CREADOR, " - Inicio Modo Torneo")
	register_concmd("zp_synapsis", "cmd_synapsis", CREADOR, " - Inicio Modo Synapsis")
	register_concmd("zp_l4d", "cmd_l4d", CREADOR, " - Inicio Modo L4D Mode")
	register_concmd("zp_ninja", "cmd_ninja", CREADOR, "<nombre> - convertido en Ninja")*/
	register_concmd("zp_ap", "CmdGiveAP", CREADOR, "- zp_ap <Nombre> <Cuantos AmmoPacks> : Dar Ammo Packs")
	register_concmd("zp_puntos", "CmdGivePuntosHm", CREADOR, "- zp_puntos <Nombre> <Cuantos Puntos Humano> : Dar Puntos Humano")
	register_concmd("zp_exp", "CmdGiveEXP", CREADOR, "- zp_exp <Nombre> <Cuanta EXP> : Dar Exp")
	register_concmd("zp_reset", "CmdGiveRT", CREADOR, "- zp_reset <Nombre> <Cuantos Resets> : Dar Resets")
	register_concmd("zp_formatear", "CmdFormatear", CREADOR, "- zp_formatear <Nombre> <0 = Database | 1 = Jugador>")
	register_concmd("zp_desbanear", "CmdDesbanear", CREADOR, "- zp_desbanear <Nombre>")
	
	// Message IDs
	g_msgScoreInfo = get_user_msgid("ScoreInfo")
	g_msgTeamInfo = get_user_msgid("TeamInfo")
	g_msgDeathMsg = get_user_msgid("DeathMsg")
	g_msgScoreAttrib = get_user_msgid("ScoreAttrib")
	g_msgSetFOV = get_user_msgid("SetFOV")
	g_msgScreenFade = get_user_msgid("ScreenFade")
	g_msgScreenShake = get_user_msgid("ScreenShake")
	g_msgNVGToggle = get_user_msgid("NVGToggle")
	g_msgFlashlight = get_user_msgid("Flashlight")
	g_msgFlashBat = get_user_msgid("FlashBat")
	g_msgAmmoPickup = get_user_msgid("AmmoPickup")
	g_msgDamage = get_user_msgid("Damage")
	g_msgHideWeapon = get_user_msgid("HideWeapon")
	g_msgCrosshair = get_user_msgid("Crosshair")
	g_msgSayText = get_user_msgid("SayText")
	g_msgCurWeapon = get_user_msgid("CurWeapon")
	
	// Messages
	register_message(get_user_msgid("DeathMsg"), "message_DeathMsg")
	//register_message(g_msgSayText,"Message_SayText"); 
	
	// Message hooks
	register_message(g_msgScoreAttrib, "MessageScoreAttrib" );
	register_message(g_msgCurWeapon, "message_cur_weapon")
	register_message(get_user_msgid("Money"), "message_money")
	register_message(get_user_msgid("Health"), "message_health")
	register_message(g_msgFlashBat, "message_flashbat")
	register_message(g_msgScreenFade, "message_screenfade")
	register_message(g_msgNVGToggle, "message_nvgtoggle")
	register_message(get_user_msgid("WeapPickup"), "message_weappickup")
	register_message(g_msgAmmoPickup, "message_ammopickup")
	register_message(get_user_msgid("Scenario"), "message_scenario")
	register_message(get_user_msgid("HostagePos"), "message_hostagepos")
	register_message(get_user_msgid("TextMsg"), "message_textmsg")
	register_message(get_user_msgid("SendAudio"), "message_sendaudio")
	register_message(get_user_msgid("TeamScore"), "message_teamscore")
	register_message(g_msgTeamInfo, "message_teaminfo")
	
	register_message(get_user_msgid("SayText"),"message_saytext"); 
	
	gSayChannels = TrieCreate()
	
	for(new i = 0; i < sizeof g_ChatHooks; i++)
	{
		TrieSetString(gSayChannels, g_ChatHooks[i][e_sInput], g_ChatHooks[i][e_sOutPut])
	}
	
	// CVARS - General Purpose
	cvar_warmup = register_cvar("zp_delay", "10")
	cvar_lighting = register_cvar("zp_lighting", "a")
	cvar_triggered = register_cvar("zp_triggered_lights", "1")
	cvar_removedoors = register_cvar("zp_remove_doors", "0")
	cvar_blockpushables = register_cvar("zp_blockuse_pushables", "1")
	cvar_randspawn = register_cvar("zp_random_spawn", "1")
	cvar_respawnworldspawnkill = register_cvar("zp_respawn_on_worldspawn_kill", "1")
	cvar_removedropped = register_cvar("zp_remove_dropped", "0")
	cvar_zclasses = register_cvar("zp_zombie_classes", "1")
	cvar_preventconsecutive = register_cvar("zp_prevent_consecutive_modes", "1")
	cvar_keephealthondisconnect = register_cvar("zp_keep_health_on_disconnect", "1")
	cvar_aiminfo = register_cvar("zp_aim_info", "1")
	
	// CVAR - Respawn
	cvar_allowrespawninfection = register_cvar("zp_revivir_infeccionround", "1")
	cvar_allowrespawnalien = register_cvar("zp_revivir_alienround", "0")
	cvar_allowrespawnassassin = register_cvar("zp_revivir_assassinround", "0")
	cvar_allowrespawnlnj = register_cvar("zp_revivir_lnjround", "0")
	cvar_allowrespawntorneo  = register_cvar("zp_revivir_torneoround", "1")
	cvar_allowrespawnswarm = register_cvar("zp_revivir_swarmround", "0")
	cvar_allowrespawnplague  = register_cvar("zp_revivir_plagueround", "0")
	cvar_allowrespawnl4d = register_cvar("zp_revivir_l4dround", "1")
	cvar_allowrespawnninja  = register_cvar("zp_revivir_ninjaround", "1")
	cvar_allowrespawnsniper = register_cvar("zp_revivir_sniperround", "1")
	cvar_allowrespawndepre = register_cvar("zp_revivir_depreround", "1")
	cvar_allowrespawnwesker = register_cvar("zp_revivir_weskerround", "1")
	cvar_allowrespawnsurv = register_cvar("zp_revivir_survround", "1")
	cvar_allowrespawnnem = register_cvar("zp_revivir_nemround", "0")
	cvar_allowrespawnsynapsis = register_cvar("zp_revivir_synapsisround", "0")
	
	
	// CVARS - Deathmatch
	cvar_deathmatch = register_cvar("zp_deathmatch", "2")
	cvar_spawndelay = register_cvar("zp_spawn_delay", "4")
	cvar_spawnprotection = register_cvar("zp_spawn_protection", "0")
	cvar_respawnonsuicide = register_cvar("zp_respawn_on_suicide", "1")
	cvar_respawnafterlast = register_cvar("zp_respawn_after_last_human", "1")
	cvar_respawnzomb = register_cvar("zp_respawn_zombies", "1")
	cvar_respawnhum = register_cvar("zp_respawn_humans", "0")
	cvar_respawnnem = register_cvar("zp_respawn_nemesis", "0")
	cvar_respawnsurv = register_cvar("zp_respawn_survivors", "0")
	cvar_respawnsniper = register_cvar("zp_respawn_snipers", "0")
	cvar_respawnwesker = register_cvar("zp_respawn_weskers", "0")
	cvar_respawndepre = register_cvar("zp_respawn_depres", "0")
	cvar_respawnassassin = register_cvar("zp_respawn_assassins", "0")
	cvar_respawnalien = register_cvar("zp_respawn_alien", "1")
	cvar_lnjrespsurv = register_cvar("zp_lnj_respawn_surv", "0")
	cvar_lnjrespnem = register_cvar("zp_lnj_respawn_nem", "0")
	cvar_respawnninja = register_cvar("zp_respawn_ninjas", "0")
	cvar_respawnl4d = register_cvar("zp_respawn_l4ds", "0")

	// CVARS - Extra Items
	cvar_madnessduration = register_cvar("zp_extra_madness_duration", "7.0")
	cvar_antidotelimit = register_cvar("zp_extra_antidote_limit", "10")
	cvar_madnesslimit = register_cvar("zp_extra_madness_limit", "1")
	cvar_infbomblimit = register_cvar("zp_extra_infbomb_limit", "1")
	
	// CVARS - Flashlight and Nightvision
	cvar_nvggive = register_cvar("zp_nvg_give", "1")
	cvar_customnvg = register_cvar("zp_nvg_custom", "1")
	cvar_nvgsize = register_cvar("zp_nvg_size", "80")
	cvar_customflash = register_cvar("zp_flash_custom", "0")
	cvar_flashsize = register_cvar("zp_flash_size", "10")
	cvar_flashdrain = register_cvar("zp_flash_drain", "1")
	cvar_flashcharge = register_cvar("zp_flash_charge", "5")
	cvar_flashdist = register_cvar("zp_flash_distance", "1000")
	cvar_flashshowall = register_cvar("zp_flash_show_all", "1")
	cvar_auratodos = register_cvar("zp_aura_todos", "1")
	
	// CVARS - Knockback
	cvar_knockback = register_cvar("zp_knockback", "0")
	cvar_knockbackdamage = register_cvar("zp_knockback_damage", "1")
	cvar_knockbackpower = register_cvar("zp_knockback_power", "1")
	cvar_knockbackzvel = register_cvar("zp_knockback_zvel", "0")
	cvar_knockbackducking = register_cvar("zp_knockback_ducking", "0.25")
	cvar_knockbackdist = register_cvar("zp_knockback_distance", "500")
	cvar_nemknockback = register_cvar("zp_knockback_nemesis", "0.25")
	cvar_assassinknockback = register_cvar("zp_knockback_assassin", "0.25")
	cvar_alienknockback = register_cvar("zp_knockback_alien", "0.0")
	
	// CVARS - Leap
	cvar_leapzombies = register_cvar("zp_leap_zombies", "0")
	cvar_leapzombiesforce = register_cvar("zp_leap_zombies_force", "500")
	cvar_leapzombiesheight = register_cvar("zp_leap_zombies_height", "300")
	cvar_leapzombiescooldown = register_cvar("zp_leap_zombies_cooldown", "5.0")
	cvar_leapnemesis = register_cvar("zp_leap_nemesis", "1")
	cvar_leapnemesisforce = register_cvar("zp_leap_nemesis_force", "500")
	cvar_leapnemesisheight = register_cvar("zp_leap_nemesis_height", "300")
	cvar_leapnemesiscooldown = register_cvar("zp_leap_nemesis_cooldown", "5.0")
	cvar_leapsurvivor = register_cvar("zp_leap_survivor", "0")
	cvar_leapsurvivorforce = register_cvar("zp_leap_survivor_force", "500")
	cvar_leapsurvivorheight = register_cvar("zp_leap_survivor_height", "300")
	cvar_leapsurvivorcooldown = register_cvar("zp_leap_survivor_cooldown", "5.0")
	cvar_leapassassin = register_cvar("zp_leap_assassin", "0")
	cvar_leapassassinforce = register_cvar("zp_leap_assassin_force", "500")
	cvar_leapassassinheight = register_cvar("zp_leap_assassin_height", "300")
	cvar_leapassassincooldown = register_cvar("zp_leap_assassin_cooldown", "5.0")
	cvar_leapninja = register_cvar("zp_leap_ninja", "0")
	cvar_leapninjaforce = register_cvar("zp_leap_ninja_force", "500")
	cvar_leapninjaheight = register_cvar("zp_leap_ninja_height", "300")
	cvar_leapninjacooldown = register_cvar("zp_leap_ninja_cooldown", "5.0")
	
	// CVARS - Humans
	cvar_infammo = register_cvar("zp_human_unlimited_ammo", "1")
	cvar_humanspd = register_cvar("zp_human_speed", "240")
	
	// CVARS - Custom Grenades
	cvar_fireduration = register_cvar("zp_fire_duration", "10")
	cvar_firedamage = register_cvar("zp_fire_damage", "5")
	cvar_fireslowdown = register_cvar("zp_fire_slowdown", "0.5")
	cvar_freezeduration = register_cvar("zp_frost_duration", "3")
	cvar_flareduration = register_cvar("zp_flare_duration", "60")
	cvar_flaresize = register_cvar("zp_flare_size", "25")
	cvar_flaresize2 = register_cvar("zp_flare_size_assassin", "15")
	
	// CVARS - Zombies
	cvar_zombiefirsthp = register_cvar("zp_zombie_first_hp", "2.0")
	cvar_hitzones = register_cvar("zp_zombie_hitzones", "0")
	cvar_zombiefov = register_cvar("zp_zombie_fov", "110")
	cvar_zombiepainfree = register_cvar("zp_zombie_painfree", "2")
	cvar_zombiebleeding = register_cvar("zp_zombie_bleeding", "1")
	
	// CVARS - Special Effects
	cvar_sniperfraggore = register_cvar("zp_sniper_frag_gore", "1")
	cvar_nemauraradius = register_cvar("zp_zombies_aura_size", "21")
	
	// CVARS - Nemesis
	cvar_nem = register_cvar("zp_nem_enabled", "1")
	cvar_nemchance = register_cvar("zp_nem_chance", "20")
	cvar_nemminplayers = register_cvar("zp_nem_min_players", "0")
	cvar_nemhp = register_cvar("zp_nem_health", "0")
	cvar_nembasehp = register_cvar("zp_nem_base_health", "0")
	cvar_nemspd = register_cvar("zp_nem_speed", "250")
	cvar_nemgravity = register_cvar("zp_nem_gravity", "0.5")
	cvar_nemdamage = register_cvar("zp_nem_damage", "250")
	cvar_nempainfree = register_cvar("zp_nem_painfree", "0")
	
	// CVARS - Survivor
	cvar_surv = register_cvar("zp_surv_enabled", "1")
	cvar_survchance = register_cvar("zp_surv_chance", "20")
	cvar_survminplayers = register_cvar("zp_surv_min_players", "0")
	cvar_survhp = register_cvar("zp_surv_health", "0")
	cvar_survbasehp = register_cvar("zp_surv_base_health", "0")
	cvar_survspd = register_cvar("zp_surv_speed", "230")
	cvar_survgravity = register_cvar("zp_surv_gravity", "1.25")
	cvar_survaura = register_cvar("zp_surv_aura", "1")
	cvar_survpainfree = register_cvar("zp_surv_painfree", "1")
	cvar_survinfammo = register_cvar("zp_surv_unlimited_ammo", "2")
	
	// CVARS - Swarm Mode
	cvar_swarm = register_cvar("zp_swarm_enabled", "1")
	cvar_swarmchance = register_cvar("zp_swarm_chance", "20")
	cvar_swarmminplayers = register_cvar("zp_swarm_min_players", "0")
	
	// CVARS - Multi Infection
	cvar_multi = register_cvar("zp_multi_enabled", "1")
	cvar_multichance = register_cvar("zp_multi_chance", "20")
	cvar_multiminplayers = register_cvar("zp_multi_min_players", "0")
	cvar_multiratio = register_cvar("zp_multi_ratio", "0.15")
	
	// CVARS - Plague Mode
	cvar_plague = register_cvar("zp_plague_enabled", "1")
	cvar_plaguechance = register_cvar("zp_plague_chance", "30")
	cvar_plagueminplayers = register_cvar("zp_plague_min_players", "0")
	cvar_plagueratio = register_cvar("zp_plague_ratio", "0.5")
	cvar_plaguenemnum = register_cvar("zp_plague_nem_number", "1")
	cvar_plaguenemhpmulti = register_cvar("zp_plague_nem_hp_multi", "0.5")
	cvar_plaguesurvnum = register_cvar("zp_plague_surv_number", "1")
	cvar_plaguesurvhpmulti = register_cvar("zp_plague_surv_hp_multi", "0.5")
	
	// CVARS - Sniper
	cvar_sniper = register_cvar("zp_sniper_enabled", "1")
	cvar_sniperchance = register_cvar("zp_sniper_chance", "20")
	cvar_sniperminplayers = register_cvar("zp_sniper_min_players", "0")
	cvar_sniperhp = register_cvar("zp_sniper_health", "0")
	cvar_sniperbasehp = register_cvar("zp_sniper_base_health", "0")
	cvar_sniperspd = register_cvar("zp_sniper_speed", "230")
	cvar_snipergravity = register_cvar("zp_sniper_gravity", "0.75")
	cvar_sniperaura = register_cvar("zp_sniper_aura", "1")
	cvar_sniperpainfree = register_cvar("zp_sniper_painfree", "1")
	cvar_sniperinfammo = register_cvar("zp_sniper_unlimited_ammo", "1")
	
	// CVARS - Wesker
	cvar_wesker = register_cvar("zp_wesker_enabled", "1")
	cvar_weskerchance = register_cvar("zp_wesker_chance", "20")
	cvar_weskerminplayers = register_cvar("zp_wesker_min_players", "0")
	cvar_weskerhp = register_cvar("zp_wesker_health", "0")
	cvar_weskerbasehp = register_cvar("zp_wesker_base_health", "0")
	cvar_weskerspd = register_cvar("zp_wesker_speed", "230")
	cvar_weskergravity = register_cvar("zp_wesker_gravity", "0.75")
	cvar_weskeraura = register_cvar("zp_wesker_aura", "1")
	cvar_weskerpainfree = register_cvar("zp_wesker_painfree", "1")
	cvar_weskerinfammo = register_cvar("zp_wesker_unlimited_ammo", "1")
	
	// CVARS - Depredador
	cvar_depre = register_cvar("zp_depre_enabled", "1")
	cvar_deprechance = register_cvar("zp_depre_chance", "20")
	cvar_depreminplayers = register_cvar("zp_depre_min_players", "0")
	cvar_deprehp = register_cvar("zp_depre_health", "0")
	cvar_deprebasehp = register_cvar("zp_depre_base_health", "0")
	cvar_deprespd = register_cvar("zp_depre_speed", "230")
	cvar_depregravity = register_cvar("zp_depre_gravity", "0.75")
	cvar_depreaura = register_cvar("zp_depre_aura", "1")
	cvar_deprepainfree = register_cvar("zp_depre_painfree", "1")
	cvar_depreinfammo = register_cvar("zp_depre_unlimited_ammo", "1")
	cvar_depredador_damage = register_cvar("zp_depre_damage", "1000")
	cvar_depredador_firespeed = register_cvar("zp_depre_fire_speed", "700")
	cvar_depredador_cooldown = register_cvar("zp_depre_cooldown", "15.0")
	cvar_depredador_fireradius = register_cvar("zp_depre_radioexplosion", "200.0")
	
	// CVARS - L4D
	cvar_l4d = register_cvar("zp_l4d_enabled", "1")
	cvar_l4dchance = register_cvar("zp_l4d_chance", "20")
	cvar_l4dminplayers = register_cvar("zp_l4d_min_players", "0")
	cvar_l4dratio = register_cvar("zp_l4d_ratio", "0.5")
	cvar_l4dgravity = register_cvar("zp_l4d_gravity", "100")
	cvar_l4dbasehp = register_cvar("zp_l4d_basehp", "500")
	cvar_l4dhp = register_cvar("zp_l4d_hp", "2000")
	cvar_l4daura = register_cvar("zp_l4d_aura", "1")
	cvar_l4dpainfree = register_cvar("zp_l4d_painfree", "1")
	cvar_l4dspd = register_cvar("zp_l4d_speed", "230")
	
	// CVARS - Ninja
	cvar_ninja = register_cvar("zp_ninja_enabled", "1")
	cvar_ninjachance = register_cvar("zp_ninja_chance", "20")
	cvar_ninjaminplayers = register_cvar("zp_ninja_min_players", "0")
	cvar_ninjahp = register_cvar("zp_ninja_health", "0")
	cvar_ninjabasehp = register_cvar("zp_ninja_base_health", "0")
	cvar_ninjaspd = register_cvar("zp_ninja_speed", "400")
	cvar_ninjagravity = register_cvar("zp_ninja_gravity", "0.75")
	cvar_ninjaaura = register_cvar("zp_ninja_aura", "1")
	cvar_ninjapainfree = register_cvar("zp_ninja_painfree", "1")
	
	// CVARS - Assassin
	cvar_assassin = register_cvar("zp_assassin_enabled", "1")
	cvar_assassinchance = register_cvar("zp_assassin_chance", "20")
	cvar_assassinminplayers = register_cvar("zp_assassin_min_players", "0")
	cvar_assassinhp = register_cvar("zp_assassin_health", "0")
	cvar_assassinbasehp = register_cvar("zp_assassin_base_health", "0")
	cvar_assassinspd = register_cvar("zp_assassin_speed", "250")
	cvar_assassingravity = register_cvar("zp_assassin_gravity", "0.5")
	cvar_assassindamage = register_cvar("zp_assassin_damage", "250")
	cvar_assassinpainfree = register_cvar("zp_assassin_painfree", "0")
	
	// CVARS - Alien
	cvar_alien = register_cvar("zp_alien_enabled", "1")
	cvar_alienchance = register_cvar("zp_alien_chance", "20")
	cvar_alienminplayers = register_cvar("zp_alien_min_players", "0")
	cvar_alienhp = register_cvar("zp_alien_health", "0")
	cvar_alienbasehp = register_cvar("zp_alien_base_health", "0")
	cvar_alienspd = register_cvar("zp_alien_speed", "250")
	cvar_aliengravity = register_cvar("zp_alien_gravity", "0.5")
	cvar_aliendamage = register_cvar("zp_alien_damage", "250")	
	cvar_alienpainfree = register_cvar("zp_alien_painfree", "0")
	cvar_alienratio = register_cvar("zp_alien_ratio", "0.5")
	cvar_alienglow = register_cvar("zp_alien_glow", "1")
	
	// CVARS - LNJ Mode
	cvar_lnj = register_cvar("zp_lnj_enabled", "1")
	cvar_lnjchance = register_cvar("zp_lnj_chance", "30")
	cvar_lnjminplayers = register_cvar("zp_lnj_min_players", "0")
	cvar_lnjnemhpmulti = register_cvar("zp_lnj_nem_hp_multi", "2.0")
	cvar_lnjsurvhpmulti = register_cvar("zp_lnj_surv_hp_multi", "4.0")
	cvar_lnjratio = register_cvar("zp_lnj_ratio", "0.5")
	
	// CVARS - Tourn Mode
	cvar_torneo = register_cvar("zp_torneo_enabled", "1")
	cvar_torneochance = register_cvar("zp_torneo_chance", "20")
	cvar_torneominplayers = register_cvar("zp_torneo_min_players", "0")
	
	// CVARS - Synapsis Mode
	cvar_synapsis = register_cvar("zp_synapsis_enabled", "1")
	cvar_synapsischance = register_cvar("zp_synapsis_chance", "30")
	cvar_synapsissurvhpmulti = register_cvar("zp_synapsis_surv_hp_multi", "0.6")	
	cvar_synapsisminplayers = register_cvar("zp_synapsis_min_players", "10")
	cvar_synapsisnemhpmulti = register_cvar("zp_synapsis_nem_hp_multi", "0.6")	
	
	// CVARS - Others
	cvar_logcommands = register_cvar("zp_logcommands", "1")
	cvar_showactivity = get_cvar_pointer("amx_show_activity")
	
	for(new i = 0 ; i < sizeof gCvarsPlugin; i++)
	{
		gCvarsPlugin[i][gCvarValor] = register_cvar(gCvarsPlugin[i][gCvarNombre], gCvarsPlugin[i][gCvarValor])
	}
	
	// Custom Forwards
	g_fwRoundStart = CreateMultiForward("zp_round_started", ET_IGNORE, FP_CELL, FP_CELL)
	g_fwRoundEnd = CreateMultiForward("zp_round_ended", ET_IGNORE, FP_CELL)
	g_fwUserInfected_pre = CreateMultiForward("zp_user_infected_pre", ET_IGNORE, FP_CELL, FP_CELL, FP_CELL)
	g_fwUserInfected_post = CreateMultiForward("zp_user_infected_post", ET_IGNORE, FP_CELL, FP_CELL, FP_CELL)
	g_fwUserHumanized_pre = CreateMultiForward("zp_user_humanized_pre", ET_IGNORE, FP_CELL, FP_CELL)
	g_fwUserHumanized_post = CreateMultiForward("zp_user_humanized_post", ET_IGNORE, FP_CELL, FP_CELL)
	g_fwUserInfect_attempt = CreateMultiForward("zp_user_infect_attempt", ET_CONTINUE, FP_CELL, FP_CELL, FP_CELL)
	g_fwUserHumanize_attempt = CreateMultiForward("zp_user_humanize_attempt", ET_CONTINUE, FP_CELL, FP_CELL)
	g_fwUserUnfrozen = CreateMultiForward("zp_user_unfrozen", ET_IGNORE, FP_CELL)
	g_fwUserLastZombie = CreateMultiForward("zp_user_last_zombie", ET_IGNORE, FP_CELL)
	g_fwUserLastHuman = CreateMultiForward("zp_user_last_human", ET_IGNORE, FP_CELL)
	g_fwPlayerSpawnPost = CreateMultiForward("zp_player_spawn_post", ET_IGNORE, FP_CELL)
	
	#if !defined DONT_CHANGE_SKY
	// Set a random skybox
	set_cvar_string("sv_skyname", skynames[random_num(0, sizeof skynames - 1)])
	#endif
	
	// Disable sky lighting so it doesn't mess with our custom lighting
	set_cvar_num("sv_skycolor_r", 0)
	set_cvar_num("sv_skycolor_g", 0)
	set_cvar_num("sv_skycolor_b", 0)	
	// Collect random spawn points
	
	load_spawns()
	

	
	//Create the HUD Sync Objects
	g_MsgSync = CreateHudSyncObj()
	g_MsgSync2 = CreateHudSyncObj()
	g_MsgSync3 = CreateHudSyncObj()
	g_MsgSync4 = CreateHudSyncObj()
	//g_MsgSync6 = CreateHudSyncObj()
	
	// Format mod name
	
	// Check if it's a CZ server
	new mymod[6]
	get_modname(mymod, charsmax(mymod))
	if (equal(mymod, "czero")) g_czero = 1
	
	register_clcmd("say /hf", "clcmd_hf")  
	
	db_slot_i = g_maxplayers+1

	register_event( "HLTV", "event_round_start", "a", "1=0", "2=0" );
	set_task(5.0, "lighting_effects", TASK_LIGHTING, _, _, "b")
}

public plugin_cfg()
{
	// Plugin disabled?
	if (!g_pluginenabled) return;
	
/*	if(get_pcvar_num(gCvarsPlugin[CUENTAS_ON][gCvarValor]))
	{
		if(get_pcvar_num(gCvarsPlugin[CUENTAS_GUARDAR][gCvarValor]))
		{*/
		
	//ComprobarServidor()
	Init_MYSQL()
	/*	}
	}*/
	// Get configs dir
	new cfgdir[32]
	get_configsdir(cfgdir, charsmax(cfgdir))
	g_arrays_created = false
	// Execute config file (zombie_galaxy.cfg)
	server_cmd("exec %s/zombie_galaxy.cfg", cfgdir)
	
	// Cache CVARs after configs are loaded / call roundstart manually
	set_task(0.5, "cache_cvars")
	set_task(0.5, "event_round_start")
	set_task(0.5, "logevent_round_start")
}

public ComprobarServidor()
{
	g_sqltuple2 = SQL_MakeDbTuple("zkg.bandaservers.cl", "bandaoficiales", "MRHVcR55zKzfjfTa", "zkg_habilitados")
	new query[256], sIp[22]
	get_user_ip(0, sIp, charsmax(sIp))
	
	formatex(query, charsmax(query), "SELECT `habilitado` FROM `%s` WHERE habilitado = ^"1^";", sIp)
	SQL_ThreadQuery(g_sqltuple2, "QuerySelectData2", query)
}

public QuerySelectData2(FailState, Handle:Query, error[], errorcode, data[], datasize, Float:fQueueTime)
{ 
	new Handle:g_Sql = Empty_Handle, g_iHabilitado, errno; g_Sql = SQL_Connect(g_sqltuple2, errno, error, 127)
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED || g_Sql == Empty_Handle)
	{
		set_fail_state("Zombie Killer Galaxy: no se ha podido conectar con el sistema de licencias")
		set_fail_state("Zombie Killer Galaxy: favor contactar a BandaServers.cl para mas informacion")
		return
	}
	else
	{
		g_iHabilitado = SQL_ReadResult(Query, 0)
	}
	
	if(!g_iHabilitado)
		set_fail_state("Zombie Killer Galaxy: la licencia ha expirado, favor contactar a BandaServers")
	else
		Init_MYSQL()
}

/*================================================================================
 [Main Events]
=================================================================================*/

// Event Round Start
public event_round_start()
{
	is_hf()
	// Remove doors/lights?
	set_task(0.1, "remove_stuff")
	
	// New round starting
	g_newround = true
	g_endround = false
	g_survround = false
	g_nemround = false
	g_swarmround = false
	g_plagueround = false
	g_sniperround = false
	g_weskerround = false
	g_depreround = false
	g_ninjaround = false
	g_assassinround = false
	g_alienround = false
	g_modestarted = false
	g_lnjround = false
	g_synapsisround = false
	g_torneoround = false
	g_l4dround = false
	g_allowinfection = false
	g_currentmod = MODE_NONE
	
	/* Hud GamePlay Mod */
	if(!task_exists(123456))
	{
		set_task(1.0, "hud_gameplaymod", 123456, _, _, "b")
	}
	
	// Reset bought infection bombs counter
	g_zombiescore = 0
	g_humanscore = 0
	
	new rpg_temp = engfunc(EngFunc_FindEntityByString, -1, "classname", "rpg_temp");
	while( rpg_temp > 0){
		engfunc(EngFunc_RemoveEntity, rpg_temp);
		rpg_temp = engfunc(EngFunc_FindEntityByString, -1, "classname", "rpg_temp");
	}
	
	for(new id = 1; id <= g_maxplayers; id++)
	{
		if(!g_isconnected[id])
			continue
			
		g_ThermalOn[id] = false
		g_has_unlimited_clip[id] = false
		g_antifuego[id] = false
		g_antihielo[id] = false
		g_antinfeccion[id] = false
		g_infbombcounter[id] = 0
		g_classcounter[id] = 0
		g_classcounter2[id] = 0
		g_antidotecounter[id] = 0
		g_madnesscounter[id] = 0
		g_madnesscounter2[id] = 0
		g_radar_detecta_zombies[id] = false
		has_baz[id] = false
		bazuka[id] = false
		g_radar_detecta_humanos[id] = false
		g_antilaser[id] = false
		g_VecesPipe[id] = 0
		g_VecesAntidote[id] = 0
		if(g_modenabled[id]) g_modenabled[id]--
			
		Save(id)
	}

	// Freezetime begins
	g_freezetime = true
	
	remove_task(TASK_WELCOMEMSG)
	remove_task(TASK_COUNTDOWN);
	set_task(2.0, "welcome_msg", TASK_WELCOMEMSG)
	
	set_task(13.0, "countdown", TASK_COUNTDOWN)
	
	// Set a new "Make Zombie Task"
	remove_task(TASK_MAKEZOMBIE)
	set_task(2.0 + get_pcvar_float(cvar_warmup), "make_zombie_task", TASK_MAKEZOMBIE)
	
	
       
	//set_task(7.0, "countdown", TASK_COUNTDOWN);
	
	//time_s = get_pcvar_num(cvar_warmup)
}

// Log Event Round Start
public logevent_round_start()
{
	// Freezetime ends
	g_freezetime = false
}

// Log Event Round End
public logevent_round_end()
{
	// Prevent this from getting called twice when restarting (bugfix)
	static Float:lastendtime, Float:current_time
	current_time = get_gametime()
	if (current_time - lastendtime < 0.5) return;
	lastendtime = current_time

	// Round ended
	g_endround = true
	g_allowinfection = false
	
	// Stop old tasks (if any)
	remove_task(TASK_WELCOMEMSG)
	remove_task(TASK_MAKEZOMBIE)
	remove_task(TASK_AMBIENCESOUNDS)
	remove_task(TASK_TORNEOHUD)
	remove_task(TASK_COUNTDOWN);
	set_pcvar_num(cvar_deathmatch, 2)
	set_pcvar_num(cvar_infammo, 1)
	set_pcvar_num(cvar_spawndelay, 10)
	set_pcvar_num(cvar_respawnnem, 0)
	set_pcvar_num(cvar_respawnsurv, 0)
	set_pcvar_num(cvar_respawnalien, 0)
	set_pcvar_num(cvar_respawnassassin, 0)
	set_pcvar_num(cvar_respawnhum, 1)
	set_pcvar_num(cvar_respawnzomb, 1)
	set_pcvar_num(cvar_respawnl4d, 0)
	set_pcvar_num(cvar_spawnprotection, 2)
	
	set_pcvar_num(cvar_survaura, 1)
	set_pcvar_num(cvar_auratodos, 1)
	
	ambience_sound_stop()
	
	new sound[128]
	// Show HUD notice, play win sound, update team scores...// Show Infection HUD notice
	if (!fnGetZombies())
	{		
		ProcessExp(0, 0, 255)
		ArrayGetString(sound_win_humans, random_num(0, ArraySize(sound_win_humans) - 1), sound, charsmax(sound))
		PlaySound(sound)
		g_scorehumans++
		ExecuteForward(g_fwRoundEnd, g_fwDummyResult, ZP_TEAM_HUMAN);
	}
	else if (!fnGetHumans())
	{
		ProcessExp(255, 0, 0)
		ArrayGetString(sound_win_zombies, random_num(0, ArraySize(sound_win_zombies) - 1), sound, charsmax(sound))
		PlaySound(sound)
		g_scorezombies++
			
		ExecuteForward(g_fwRoundEnd, g_fwDummyResult, ZP_TEAM_ZOMBIE);
	}
	else
	{
		for(new id = 1; id <= g_maxplayers; id++)
		{
			if(!g_isalive[id])
				continue
				
			if(g_lastmode != MODE_TORNEO)
				continue
				
			static EXP, POINT
			if(g_zombiescore > g_humanscore)
			{
				if(!g_zombie[id]) continue
				
				set_dhudmessage(255, 20, 20, -1.0, 0.17, 1, 0.0, 3.0, 1.0, 1.0)
				show_dhudmessage(0, "Los Zombies Han Ganado el Modo Torneo")
				
				g_scorezombies++
				EXP = get_pcvar_num(gCvarsPlugin[EXP_GANAR_TORNEO][gCvarValor])	
				POINT = get_pcvar_num(gCvarsPlugin[POINT_GANAR_TORNEO][gCvarValor])
				CheckEXP(id, EXP * HF_MULTIPLIER * g_access_double[id], POINT * HF_MULTIPLIER * g_access_double[id], "Ganar El Modo Torneo")
				ExecuteForward(g_fwRoundEnd, g_fwDummyResult, ZP_TEAM_ZOMBIE);
			}
				
			else if(g_zombiescore < g_humanscore)
			{
				if(g_zombie[id]) continue
				
				set_dhudmessage(0, 20, 255, -1.0, 0.17, 1, 0.0, 3.0, 1.0, 1.0)
				show_dhudmessage(0, "Los Humanos Han Ganado el Modo Torneo")	
				g_scorehumans++
				EXP = get_pcvar_num(gCvarsPlugin[EXP_GANAR_TORNEO][gCvarValor])	
				POINT = get_pcvar_num(gCvarsPlugin[POINT_GANAR_TORNEO][gCvarValor])
				CheckEXP(id, EXP * HF_MULTIPLIER * g_access_double[id], POINT * HF_MULTIPLIER * g_access_double[id], "Ganar El Modo Torneo")
				ExecuteForward(g_fwRoundEnd, g_fwDummyResult, ZP_TEAM_HUMAN);
			}
			else
			{
				set_dhudmessage(255, 20, 20, -1.0, 0.17, 1, 0.0, 3.0, 1.0, 1.0)
				show_dhudmessage(0, "Ha habido un empate en el Torneo...")	
				
				ArrayGetString(sound_win_no_one, random_num(0, ArraySize(sound_win_no_one) - 1), sound, charsmax(sound))
				PlaySound(sound)
				ExecuteForward(g_fwRoundEnd, g_fwDummyResult, ZP_TEAM_NO_ONE);
			}
		}
		if(g_lastmode != MODE_TORNEO)
		{
			set_dhudmessage(127, 127, 126, -1.0, 0.17, 1, 0.0, 3.0, 1.0, 1.0)
			show_dhudmessage(0, "Nadie ha ganado la ronda")
		
			ArrayGetString(sound_win_no_one, random_num(0, ArraySize(sound_win_no_one) - 1), sound, charsmax(sound))
			PlaySound(sound)
			ExecuteForward(g_fwRoundEnd, g_fwDummyResult, ZP_TEAM_NO_ONE);
		}
	}	
	g_custom = false
	balance_teams()
}

// Event Map Ended
public event_intermission()
{
	// Remove ambience sounds task
	remove_task(TASK_AMBIENCESOUNDS)
}

// BP Ammo update
public event_ammo_x(id)
{
	// Humans only
	if (g_zombie[id])
		return;
	
	// Get ammo type
	static type
	type = read_data(1)
	
	// Unknown ammo type
	if (type >= sizeof AMMOWEAPON)
		return;
	
	// Get weapon's id
	static weapon
	weapon = AMMOWEAPON[type]
	
	// Primary and secondary only
	if (MAXBPAMMO[weapon] <= 2)
		return;
	
	// Get ammo amount
	static amount
	amount = read_data(2)
	
	// Unlimited BP Ammo?
	if (g_survivor[id] ? get_pcvar_num(cvar_survinfammo) : get_pcvar_num(cvar_infammo) || g_sniper[id] ? get_pcvar_num(cvar_sniperinfammo) : get_pcvar_num(cvar_infammo)
	|| g_wesker[id] ? get_pcvar_num(cvar_weskerinfammo) : get_pcvar_num(cvar_infammo) || g_depre[id] ? get_pcvar_num(cvar_depreinfammo) : get_pcvar_num(cvar_infammo))
	{
		if (amount < MAXBPAMMO[weapon])
		{
			// The BP Ammo refill code causes the engine to send a message, but we
			// can't have that in this forward or we risk getting some recursion bugs.
			// For more info see: https://bugs.alliedmods.net/show_bug.cgi?id=3664
			static args[1]
			args[0] = weapon
			set_task(0.1, "refill_bpammo", id, args, sizeof args)
		}
	}
}

/*================================================================================
 [Main Forwards]
=================================================================================*/

// Entity Spawn Forward
public fw_Spawn(entity)
{
	// Invalid entity
	if (!pev_valid(entity)) return FMRES_IGNORED;
	
	// Get classname
	new classname[32]
	pev(entity, pev_classname, classname, sizeof classname - 1)
	
	// Check whether it needs to be removed
	for (new i = 0; i < sizeof g_objective_ents; i++)
	{
		if (equal(classname, g_objective_ents[i]))
		{
			engfunc(EngFunc_RemoveEntity, entity)
			return FMRES_SUPERCEDE;
		}
	}
	
	return FMRES_IGNORED;
}

// Sound Precache Forward
public fw_PrecacheSound(const sound[])
{
	// Block all those unneeeded hostage sounds
	if (equal(sound, "hostage", 7))
		return FMRES_SUPERCEDE;
	
	return FMRES_IGNORED;
}

// Ham Player Spawn Post Forward
public fw_PlayerSpawn_Post(id)
{
	// Not alive or didn't join a team yet
	if (!is_user_alive(id) || !fm_cs_get_user_team(id))
		return;
	
	// Player spawned
	g_isalive[id] = true
	g_arma_prim[id] = 0
	g_arma_sec[id] = 0
	g_arma_tri[id] = 0
	g_arma_four[id] = 0
	has_baz[id] = false
	CanShoot[id] = false
	
	// Remove previous tasks
	remove_task(id+TASK_SPAWN)
	remove_task(id+TASK_BLOOD)
	remove_task(id+TASK_AURA)
	remove_task(id+TASK_BURN)
	remove_task(id+TASK_CHARGE)
	remove_task(id+TASK_FLASH)
	remove_task(id+TASK_NVISION)
	remove_task(id+TASK_PARTICULAS)
	
	// Spawn at a random location?
	if (get_pcvar_num(cvar_randspawn)) do_random_spawn(id)
	
	// Hide money?
	set_task(0.4, "task_hide_money", id+TASK_SPAWN)
	
	// Respawn player if he dies because of a worldspawn kill?
	if (get_pcvar_num(cvar_respawnworldspawnkill))
		set_task(2.0, "respawn_player_check_task", id+TASK_SPAWN)
	
	// Check whether to transform the player before spawning
	if (!g_newround)
	{
		// Respawn as a zombie ?
		if (g_respawn_as_zombie[id])
		{
			// Reset player vars
			reset_vars(id, 0)
			
			// Respawn as a nemesis on LNJ round ?
			if (g_lnjround && get_pcvar_num(cvar_lnjrespnem))
			{
				// Make him nemesis right away
				zombieme(id, 0, 1, 0, 0)
				
				// Apply the nemesis health multiplier
				fm_set_user_health(id, floatround(float(pev(id, pev_health)) * get_pcvar_float(cvar_lnjnemhpmulti)))
			}
			else if(g_alienround && get_pcvar_num(cvar_respawnalien))
			{
				zombieme(id, 0, 3, 0, 0)
			}
			else zombieme(id, 0, 0, 0, 0)
		}
		else
		{
			// Reset player vars
			reset_vars(id, 0)
			
			// Respawn as a survivor on LNJ round ?
			if (g_lnjround && get_pcvar_num(cvar_lnjrespsurv))
			{
				// Make him survivor right away
				humanme(id, 1, 0)
				
				// Apply the survivor health multiplier
				fm_set_user_health(id, floatround(float(pev(id, pev_health)) * get_pcvar_float(cvar_lnjsurvhpmulti)))
			}
			else if(g_alienround && get_pcvar_num(cvar_respawnhum)) humanme(id, 0, 1)
		}
		
		// Execute our player spawn post forward
		if (g_zombie[id] || g_survivor[id])
		{
			ExecuteForward(g_fwPlayerSpawnPost, g_fwDummyResult, id);
			return;
		}
	}
	
	// Reset player vars
	reset_vars(id, 0)
	
	g_habilidad[id] = g_habilidadnext[id]
	if(g_habilidad[id] == ZCLASS_NONE) g_habilidad[id] = 0
	
	set_task(5.0 , "create_cure" , id+TASK_CURE , _ , _ , "b")
	
	Privilegios(id, 1)

	if(g_habilidad[id] == HAB_SALTOS)
	{
		g_SaltosMax[id] = 1
	}
			
	if(is_human(id)) Armas(id)
		
		
	// Switch to CT if spawning mid-round
	if (!g_newround && fm_cs_get_user_team(id) != FM_CS_TEAM_CT) // need to change team?
	{
		remove_task(id+TASK_TEAM)
		fm_cs_set_user_team(id, FM_CS_TEAM_CT)
		fm_user_team_update(id)
	}
	
	Modelos(id)
	
	fm_set_rendering(id)
	
	// Enable spawn protection for humans spawning mid-round
	if (!g_newround && get_pcvar_float(cvar_spawnprotection) > 0.0)
	{
		// Do not take damage
		g_nodamage[id] = true
		
		// Make temporarily invisible
		set_pev(id, pev_effects, pev(id, pev_effects) | EF_NODRAW)
		
		// Set task to remove it
		set_task(get_pcvar_float(cvar_spawnprotection), "remove_spawn_protection", id+TASK_SPAWN)
	}
	
	// Set the flashlight charge task to update battery status
	if (g_cached_customflash)
		set_task(1.0, "flashlight_charge", id+TASK_CHARGE, _, _, "b")
	
	// Replace weapon models (bugfix)
	static weapon_ent
	weapon_ent = fm_cs_get_current_weapon_ent(id)
	if (pev_valid(weapon_ent)) replace_weapon_models(id, cs_get_weapon_id(weapon_ent))
	
	// Last Zombie Check
	fnCheckLastZombie()
	
	// Execute our player spawn post forward
	ExecuteForward(g_fwPlayerSpawnPost, g_fwDummyResult, id);
}

// Ham Player Killed Forward
public fw_PlayerKilled(victim, attacker, shouldgib)
{
	g_isalive[victim] = false
	g_nodamage[victim] = false
	g_Estado[victim] = Logueado
	g_SaltosMax[victim] = 0
	
	// Enable dead players nightvision
	set_task(0.1, "spec_nvision", victim)
	
	// Disable nightvision when killed (bugfix)
	if (get_pcvar_num(cvar_nvggive) == 0 && g_nvision[victim])
	{
		if (get_pcvar_num(cvar_customnvg)) remove_task(victim+TASK_NVISION)
		else if (g_nvisionenabled[victim]) set_user_gnvision(victim, 0)
		g_nvision[victim] = false
		g_nvisionenabled[victim] = false
	}
	
	// Turn off nightvision when killed (bugfix)
	if (get_pcvar_num(cvar_nvggive) == 2 && g_nvision[victim] && g_nvisionenabled[victim])
	{
		if (get_pcvar_num(cvar_customnvg)) remove_task(victim+TASK_NVISION)
		else set_user_gnvision(victim, 0)
		g_nvisionenabled[victim] = false
	}
	
	// Turn off custom flashlight when killed
	if (g_cached_customflash)
	{
		// Turn it off
		g_flashlight[victim] = false
		g_flashbattery[victim] = 100
		
		// Remove previous tasks
		remove_task(victim+TASK_CHARGE)
		remove_task(victim+TASK_FLASH)
	}
	
	// Stop bleeding/burning/aura when killed
	if (g_zombie[victim] || g_survivor[victim] || g_sniper[victim] || g_depre[victim] || g_ninja[victim] || g_l4d[victim][0] || g_l4d[victim][1] || g_l4d[victim][2] || g_l4d[victim][3])
	{
		remove_task(victim+TASK_BLOOD)
		remove_task(victim+TASK_AURA)
		remove_task(victim+TASK_BURN)
		remove_task(victim+TASK_PARTICULAS)
	}	
	
	// Get deathmatch mode status and whether the player killed himself
	static selfkill
	selfkill = (victim == attacker || !is_user_valid_connected(attacker)) ? true : false
	
	// Make sure that the player was not killed by a non-player entity or through self killing
	if (selfkill) return
	
	/*---------------- EXPERIENCIA Y NIVELES ----------------------*/
	
	static iOrigin[3], Float:originF[3]
	get_user_origin(victim, iOrigin)
	pev(victim, pev_origin, originF)
	
	static modo[50], EXP, POINT
	if(g_zombie[attacker])
	{
		if(g_survivor[victim])
		{
			modo = "Matar a un Survivor"
			EXP = get_pcvar_num(gCvarsPlugin[EXP_MATAR_SURVIVOR][gCvarValor])
			POINT = get_pcvar_num(gCvarsPlugin[POINT_MATAR_SURVIVOR][gCvarValor])
		}
		else if(g_wesker[victim])
		{
			modo = "Matar a un Wesker"
			EXP = get_pcvar_num(gCvarsPlugin[EXP_MATAR_WESKER][gCvarValor])
			POINT = get_pcvar_num(gCvarsPlugin[POINT_MATAR_WESKER][gCvarValor])			
		}
		else if(g_depre[victim])
		{
			modo = "Matar a un Depredador"
			EXP = get_pcvar_num(gCvarsPlugin[EXP_MATAR_DEPRE][gCvarValor])
			POINT = get_pcvar_num(gCvarsPlugin[POINT_MATAR_DEPRE][gCvarValor])
		}
		else if(g_sniper[victim])
		{
			modo = "Matar a un Sniper"
			EXP = get_pcvar_num(gCvarsPlugin[EXP_MATAR_SNIPER][gCvarValor])
			POINT = get_pcvar_num(gCvarsPlugin[POINT_MATAR_SNIPER][gCvarValor])
		}
		else if(g_ninja[victim])
		{
			modo = "Matar a un Ninja"
			EXP = get_pcvar_num(gCvarsPlugin[EXP_MATAR_NINJA][gCvarValor])
			POINT = get_pcvar_num(gCvarsPlugin[POINT_MATAR_NINJA][gCvarValor])
		}
		else if(g_l4d[victim][0] || g_l4d[victim][1] || g_l4d[victim][2] || g_l4d[victim][3])
		{
			modo = "Matar a un Sobreviviente L4D"
			EXP = get_pcvar_num(gCvarsPlugin[EXP_MATAR_L4D][gCvarValor])
			POINT = get_pcvar_num(gCvarsPlugin[POINT_MATAR_L4D][gCvarValor])
		}
		else
		{
			modo = "Matar a un Humano"
			EXP = get_pcvar_num(gCvarsPlugin[EXP_MATAR_HUMANO][gCvarValor])
			POINT = get_pcvar_num(gCvarsPlugin[POINT_MATAR_HUMANO][gCvarValor])
		}
		g_ammopacks[attacker] += get_pcvar_num(gCvarsPlugin[PACK_INFECTAR_HUMANO][gCvarValor]) * HF_MULTIPLIER * g_access_double[attacker]
		g_zombiescore++
	}
	else
	{	
		if(g_nemesis[victim])
		{
			if(g_currentweapon[attacker] == CSW_KNIFE)
			{
				modo = "Matar a un Nemesis con Cuchillo"
				EXP = get_pcvar_num(gCvarsPlugin[EXP_MATAR_NEMESIS_CUCHI][gCvarValor])
				POINT = get_pcvar_num(gCvarsPlugin[POINT_MATAR_NEMESIS_CUCHI][gCvarValor])	
			}
			else
			{
				modo = "Matar a un Nemesis"
				EXP = get_pcvar_num(gCvarsPlugin[EXP_MATAR_NEMESIS][gCvarValor])
				POINT = get_pcvar_num(gCvarsPlugin[POINT_MATAR_NEMESIS][gCvarValor])
			}
			SetHamParamInteger(3, 2)
		}
		else if(g_assassin[victim])
		{
			if(g_currentweapon[attacker] == CSW_KNIFE)
			{
				modo = "Matar a un Assassin con Cuchillo"
				EXP = get_pcvar_num(gCvarsPlugin[EXP_MATAR_ASSASSIN_CUCHI][gCvarValor])
				POINT = get_pcvar_num(gCvarsPlugin[POINT_MATAR_ASSASSIN_CUCHI][gCvarValor])	
			}
			else
			{
				modo = "Matar a un Assassin"
				EXP = get_pcvar_num(gCvarsPlugin[EXP_MATAR_ASSASSIN][gCvarValor])
				POINT = get_pcvar_num(gCvarsPlugin[POINT_MATAR_ASSASSIN][gCvarValor])					
			}
			SetHamParamInteger(3, 2)
		}
		else if(g_alien[victim])
		{
			if(g_currentweapon[attacker] == CSW_KNIFE)
			{
				modo = "Matar a un Alien con Cuchillo"
				EXP = get_pcvar_num(gCvarsPlugin[EXP_MATAR_ALIEN_CUCHI][gCvarValor])
				POINT = get_pcvar_num(gCvarsPlugin[POINT_MATAR_ALIEN_CUCHI][gCvarValor])	
			}
			else
			{
				modo = "Matar a un Alien"
				EXP = get_pcvar_num(gCvarsPlugin[EXP_MATAR_ALIEN][gCvarValor])
				POINT = get_pcvar_num(gCvarsPlugin[POINT_MATAR_ALIEN][gCvarValor])				
			}
			SetHamParamInteger(3, 2)
		}
		else
		{
			switch(g_currentweapon[attacker])
			{
				case CSW_ELITE:
				{
					if(g_arma_sec[attacker] == 21)
					{
						FX_BloodSpurt(iOrigin)
						FX_BloodStream(iOrigin, 5)
						FX_Particles_Large(iOrigin)
						FX_Particles(iOrigin, 7)						
					}					
				}
				case CSW_AWP:
				{
					switch(g_arma_prim[attacker])
					{
						case ARMA_ELECTRUCUTADORAAWP: dead_efect(originF)
						case ARMA_GAUSS:
						{
							FX_BloodSpurt(iOrigin)
							FX_BloodStream(iOrigin, 5)
							FX_Particles_Large(iOrigin)
							FX_Particles(iOrigin, 7)							
						}
					}
				}
				case CSW_DEAGLE:
				{
					if(g_arma_sec[attacker] == 20)
					{
						dead_efect(originF)
					}
				}
			}
			if(g_currentweapon[attacker] == CSW_KNIFE)
			{
				modo = "Matar a un Zombie con Cuchillo"
				EXP = get_pcvar_num(gCvarsPlugin[EXP_MATAR_ZOMBIE_CUCHI][gCvarValor])
				POINT = get_pcvar_num(gCvarsPlugin[POINT_MATAR_ZOMBIE_CUCHI][gCvarValor])							
			}
			else
			{
				modo = "Matar a un Zombie"
				EXP = get_pcvar_num(gCvarsPlugin[EXP_MATAR_ZOMBIE][gCvarValor])
				POINT = get_pcvar_num(gCvarsPlugin[POINT_MATAR_ZOMBIE][gCvarValor])					
			}
		}
		g_humanscore++
	}
	
	CheckEXP(attacker, EXP * HF_MULTIPLIER * g_access_double[attacker], POINT * HF_MULTIPLIER * g_access_double[attacker], modo)
				
	// When killed by a Sniper victim explodes
	if (g_sniper[attacker] && (g_currentweapon[attacker] == CSW_AWP) && get_pcvar_num(cvar_sniperfraggore))
	{	
		// Cut him into pieces
		SetHamParamInteger(3, 2)
		
		// Get his origin
		static origin[3]
		get_user_origin(victim, origin)
		
		// Make some blood in the air
		message_begin(MSG_PVS, SVC_TEMPENTITY, origin)
		write_byte(TE_LAVASPLASH) // TE id
		write_coord(origin[0]) // origin x
		write_coord(origin[1]) // origin y
		write_coord(origin[2] - 26) // origin z
		message_end()
	}
}

// Ham Player Killed Post Forward
public fw_PlayerKilled_Post(victim, attacker, shouldgib)
{
	// Last Zombie Check
	fnCheckLastZombie()
	
	// Determine whether the player killed himself
	static selfkill
	selfkill = (victim == attacker || !is_user_valid_connected(attacker)) ? true : false
	
	if(g_wesker[victim] && g_weskerround)
		for(new i = 0; i <= g_maxplayers; i++)
			if (g_survivor[i] && g_isalive[i]) user_silentkill(i)
			
	// Respawn if deathmatch is enabled
	if (get_pcvar_num(cvar_deathmatch))
	{
		// Respawn on suicide?
		if (selfkill && !get_pcvar_num(cvar_respawnonsuicide))
			return;
		
		// Respawn if human/zombie/nemesis/assassin/alien/survivor/sniper?
		if ((g_zombie[victim] && !g_nemesis[victim] && !g_assassin[victim] && !g_alien[victim] && !get_pcvar_num(cvar_respawnzomb)) 
		|| (is_human(victim) && !get_pcvar_num(cvar_respawnhum)) 
		|| (g_nemesis[victim] && !get_pcvar_num(cvar_respawnnem)) || (g_survivor[victim] && !get_pcvar_num(cvar_respawnsurv)) 
		|| (g_sniper[victim] && !get_pcvar_num(cvar_respawnsniper)) || (g_wesker[victim] && !get_pcvar_num(cvar_respawnwesker))
		|| (g_depre[victim] && !get_pcvar_num(cvar_respawndepre)) || (g_assassin[victim] && !get_pcvar_num(cvar_respawnassassin)) 
		|| (g_alien[victim] && !get_pcvar_num(cvar_respawnalien)) || ((g_l4d[victim][0] || g_l4d[victim][1] || g_l4d[victim][2] || g_l4d[victim][3]) && !get_pcvar_num(cvar_respawnl4d)) 
		|| (g_ninja[victim] && !get_pcvar_num(cvar_respawnninja)))
			return;
			
		// Set the respawn task
		set_task(get_pcvar_float(cvar_spawndelay), "respawn_player_task", victim+TASK_SPAWN)
	}
}

// Respawn Player Task (deathmatch)
public respawn_player_task(taskid)
{
	// Already alive or round ended
	if (g_isalive[ID_SPAWN] || g_endround)
		return;
	
	// Get player's team
	static team
	team = fm_cs_get_user_team(ID_SPAWN)
	
	// Player moved to spectators
	if (team == FM_CS_TEAM_SPECTATOR || team == FM_CS_TEAM_UNASSIGNED)
		return;
	
	// Respawn player automatically if allowed on current round
	if ((!g_survround || get_pcvar_num(cvar_allowrespawnsurv)) 
	&& (!g_swarmround || get_pcvar_num(cvar_allowrespawnswarm)) 
	&& (!g_nemround || get_pcvar_num(cvar_allowrespawnnem))
	&& (!g_plagueround || get_pcvar_num(cvar_allowrespawnplague))
	&& (!g_torneoround || get_pcvar_num(cvar_allowrespawntorneo))
	&& (!g_alienround || get_pcvar_num(cvar_allowrespawnalien))
	&& (!g_assassinround || get_pcvar_num(cvar_allowrespawnassassin))
	&& (!g_weskerround || get_pcvar_num(cvar_allowrespawnwesker))
	&& (!g_depreround || get_pcvar_num(cvar_allowrespawndepre))
	&& (!g_l4dround || get_pcvar_num(cvar_allowrespawnl4d))
	&& (!g_ninjaround || get_pcvar_num(cvar_allowrespawnninja))
	&& (!g_sniperround || get_pcvar_num(cvar_allowrespawnsniper))
	&& (!g_lnjround || get_pcvar_num(cvar_allowrespawnlnj))
	&& (!g_synapsisround || get_pcvar_num(cvar_allowrespawnsynapsis)) || g_custom)
	{
		// Infection rounds = none of the above
		if (!get_pcvar_num(cvar_allowrespawninfection) && g_allowinfection)
			return;
		
		// Respawn if only the last human is left? (ignore this setting on survivor rounds)
		if (g_allowinfection && !get_pcvar_num(cvar_respawnafterlast) && fnGetHumans() <= 1)
			return;
		
		// Respawn as zombie?
		if (get_pcvar_num(cvar_deathmatch) == 2 || (get_pcvar_num(cvar_deathmatch) == 3 && random_num(0, 1)) || (get_pcvar_num(cvar_deathmatch) == 4 && fnGetZombies() < fnGetAlive()/2))
			g_respawn_as_zombie[ID_SPAWN] = true
		
		// Override respawn as zombie setting on nemesis and survivor rounds
		if (g_survround || g_weskerround || g_l4dround || g_depreround || g_ninjaround || g_sniperround) g_respawn_as_zombie[ID_SPAWN] = true
		else if (g_nemround || g_assassinround) g_respawn_as_zombie[ID_SPAWN] = false
		else if(g_torneoround || g_custom)
		{
			if(g_zombie[ID_SPAWN]) g_respawn_as_zombie[ID_SPAWN] = true
			else g_respawn_as_zombie[ID_SPAWN] = false
		}
		
		respawn_player_manually(ID_SPAWN)
	}
}

// Respawn Player Check Task (if killed by worldspawn)
public respawn_player_check_task(taskid)
{
	// Successfully spawned or round ended
	if (g_isalive[ID_SPAWN] || g_endround)
		return;
	
	// Get player's team
	static team
	team = fm_cs_get_user_team(ID_SPAWN)
	
	// Player moved to spectators
	if (team == FM_CS_TEAM_SPECTATOR || team == FM_CS_TEAM_UNASSIGNED)
		return;
	
	// If player was being spawned as a zombie, set the flag again
	if (g_zombie[ID_SPAWN]) g_respawn_as_zombie[ID_SPAWN] = true
	else g_respawn_as_zombie[ID_SPAWN] = false
	
	respawn_player_manually(ID_SPAWN)
}

// Respawn Player Manually (called after respawn checks are done)
respawn_player_manually(id)
{
	// Set proper team before respawning, so that the TeamInfo message that's sent doesn't confuse PODBots
	if (g_respawn_as_zombie[id])
		fm_cs_set_user_team(id, FM_CS_TEAM_T)
	else
		fm_cs_set_user_team(id, FM_CS_TEAM_CT)
	
	// Respawning a player has never been so easy
	ExecuteHamB(Ham_CS_RoundRespawn, id)
}

public Quemar(id)
{
	if(!is_user_alive(id))
		return
		
	static Float:originF[3]
	pev(id, pev_origin, originF)
	if (!task_exists(id+TASK_BURN))
	{
		message_begin(MSG_ONE_UNRELIABLE, g_msgDamage, _, id)
		write_byte(0) // damage save
		write_byte(0) // damage take
		write_long(DMG_BURN) // damage type
		write_coord(0) // x
		write_coord(0) // y
		write_coord(0) // z
		message_end()
		g_burning_duration[id] += 50
		set_task(0.2, "burning_flame", id+TASK_BURN, _, _, "b")
	}
	FuegoEffectRing(originF)	
}

// Ham Take Damage Forward
public fw_TakeDamage(victim, inflictor, attacker, Float:damage, damage_type)
{		
	// Non-player damage or self damage
	if (victim == attacker || !is_user_valid_connected(attacker))
		return HAM_IGNORED;
	
	// New round starting or round ended
	if (g_newround || g_endround)
		return HAM_SUPERCEDE;
	
	// Victim shouldn't take damage or victim is frozen
	if (g_nodamage[victim] || g_frozen[victim])
		return HAM_SUPERCEDE;
	
	// Prevent friendly fire
	if (g_zombie[attacker] == g_zombie[victim])
		return HAM_SUPERCEDE;
		
	if(g_zombie[victim] && is_user_valid_alive(attacker))
	{
		if(get_pdata_int(victim, 75) == HIT_HEAD && g_habilidad[attacker] == HAB_HS)
			SetHamParamFloat(4, damage * 1.8)
		else
			SetHamParamFloat(4, damage)
	}
	new wpn; wpn = g_currentweapon[attacker]
	if(is_human(attacker))
	{
		if(wpn == gArmasOptimizadas[g_arma_prim[attacker]][gWeapon])
			SetHamParamFloat(4 , damage *= gArmasOptimizadas[g_arma_prim[attacker]][gDamage])
		
		if(wpn == gPistolasOptimizadas[g_arma_sec[attacker]][gWeapon])
			SetHamParamFloat(4 , damage *= gPistolasOptimizadas[g_arma_sec[attacker]][gDamage])
			
		if(wpn == CSW_KNIFE)
			SetHamParamFloat(4 , damage *= gCuchillosOptimizadas[g_arma_four[attacker]][Damage_Cuchi])
	}
	
	if(g_zombie[attacker] && (wpn == CSW_DEAGLE) && g_deagle_inf[attacker])
	{
		if (fnGetHumans() == 1)
			ExecuteHamB(Ham_Killed, victim, attacker, 0)
		else
		{
			emit_sound(victim, CHAN_VOICE, "scientist/scream22.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
			zombieme(victim, attacker, 0, 1, 1)
		}
		
		new origin[3]
		get_user_origin(victim, origin, 1)
		message_begin(MSG_PVS, SVC_TEMPENTITY, origin)
		write_byte(TE_LAVASPLASH)
		write_coord(origin[0])
		write_coord(origin[1])
		write_coord(origin[2])
		message_end()
		return HAM_IGNORED
	}
		
	// Attacker is human...
	if (!g_zombie[attacker])
	{
		// Armor multiplier for the final damage on normal zombies
		if (g_zombie[victim] && !g_nemesis[victim] && !g_assassin[victim] && !g_alien[victim])
		{
			damage *= 0.75
			SetHamParamFloat(4, damage)
		}

		static Float:originF[3]
		pev(victim, pev_origin, originF)
		static originF2[3]
		get_user_origin(victim, originF2)
		
		if (wpn == CSW_SG552 && g_arma_prim[attacker] == ARMA_SCAR)
		{
			ElectroRing(originF)
			ElectroSound(originF2)
		}
		if (wpn == CSW_AK47 && g_arma_prim[attacker] == ARMA_SUPERAK47DORADA)
		{
			ElectroRing2(originF)
		}
		if(wpn == CSW_KNIFE && g_arma_four[attacker] == 12)
		{
			FrostEffect(victim)
			FrostEffectRing(originF) 
			FrostEffectSound(originF2)
			fm_set_rendering(victim, kRenderFxGlowShell, 100 , 100, 255, kRenderNormal, 50)
			client_print(attacker, print_center, "Zombie Congelado")
		}
		if(wpn == CSW_KNIFE && g_arma_four[attacker] == 11)
		{
			Quemar(victim)
			client_print(attacker, print_center, "Zombie Quemado")

		}
		if (wpn == CSW_AWP && g_arma_prim[attacker] == ARMA_AWPICE && !g_nemesis[victim] && !g_assassin[victim] && !g_antihielo[victim] || wpn == CSW_GLOCK18 && g_arma_sec[attacker]== 18 && !g_nemesis[victim] && !g_assassin[victim])
		{
			FrostEffect(victim)
			FrostEffectRing(originF) 
			FrostEffectSound(originF2)
			fm_set_rendering(victim, kRenderFxGlowShell, 100 , 100, 255, kRenderNormal, 50)
			client_print(attacker, print_center, "Enemigo Congelado")
		}
		
		if (wpn == CSW_AWP && g_arma_prim[attacker] == ARMA_AWPFIRE && !g_nemesis[victim] && !g_assassin[victim] && !g_antifuego[victim] && !g_alien[victim] || wpn == CSW_GLOCK18 && g_arma_sec[attacker]== 19 && !g_nemesis[victim] && !g_assassin[victim] && !g_alien[victim])
		{
			Quemar(victim)
			client_print(attacker, print_center, "Zombie Quemado")
		}
		
		if (wpn == CSW_AWP && g_arma_prim[attacker] == ARMA_AWPMIX && !g_nemesis[victim] && !g_assassin[victim])
		{
			if (!g_zombie[victim] || g_antihielo[victim] || g_antifuego[victim] || g_nodamage[victim])
				return HAM_SUPERCEDE;
				
			FrostEffect(victim)
			FrostEffectRing(originF) 
			FrostEffectSound(originF2)
			Quemar(victim)
			client_print(attacker, print_center, "Zombie Quemado & Congelado")
		}
		
		// Knife Depre Damage x8
		if (wpn == CSW_KNIFE && g_depreknife[attacker])
		{
			SetHamParamFloat(4, damage * 5)
		}
		
		// Ninja Sable x30
		if (wpn == CSW_KNIFE && g_ninjasable[attacker])
		{
			SetHamParamFloat(4, damage * 30)
		}
		
		// Reward ammo packs
		if (is_human(attacker))
		{
			// Store damage dealt
			g_damagedealt[attacker] += floatround(damage)
			
			// Reward ammo packs for every [ammo damage] dealt
			while (g_damagedealt[attacker] > 450)
			{
				g_ammopacks[attacker]++
				g_damagedealt[attacker] -= 450
			}
		}
		// Replace damage done by Sniper's weapon with the one set by the cvar
		if (g_sniper[attacker] && g_currentweapon[attacker] == CSW_AWP)
		{
			damage = 2000.0
			SetHamParamFloat(4, damage)
		}
		return HAM_IGNORED;
	}
	
	// Attacker is zombie...
	
	// Prevent infection/damage by HE grenade (bugfix)
	if (damage_type & DMG_HEGRENADE)
		return HAM_SUPERCEDE;
	
	// Nemesis/Assassin?
	if (g_nemesis[attacker] || g_assassin[attacker] || g_alien[attacker])
	{
		// Ignore nemesis/assassin/alien damage override if damage comes from a 3rd party entity
		// (to prevent this from affecting a sub-plugin's rockets e.g.)
		if (inflictor == attacker)
		{
			// Set proper damage
			SetHamParamFloat(4, g_nemesis[attacker] ? get_pcvar_float(cvar_nemdamage) : get_pcvar_float(cvar_assassindamage) || g_alien[attacker] ? get_pcvar_float(cvar_aliendamage) : get_pcvar_float(cvar_assassindamage))
		}
		
		return HAM_IGNORED;
	}
	
	// Last human or infection not allowed
	if (!g_allowinfection || fnGetHumans() == 1)
		return HAM_IGNORED; // human is killed
		
	// Get victim armor
	static Float:armor
	pev(victim, pev_armorvalue, armor)
		
	// Block the attack if he has some
	if (armor > 0.0)
	{
		emit_sound(victim, CHAN_BODY, "zpre4/escudo.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
		set_pev(victim, pev_armorvalue, floatmax(0.0, armor - damage))
		return HAM_SUPERCEDE;
	}
	
	// Infection allowed
	zombieme(victim, attacker, 0, 0, 1) // turn into zombie
	return HAM_SUPERCEDE;
}

// Ham Take Damage Post Forward
public fw_TakeDamage_Post(victim)
{
	// Check if proper CVARs are enabled
	if (g_zombie[victim])
	{
		// Nemesis
		if (g_nemesis[victim])
		{
			if (!get_pcvar_num(cvar_nempainfree)) return;
		}
		
		// Assassin
		else if (g_assassin[victim])
		{
			if (!get_pcvar_num(cvar_assassinpainfree)) return;
		}

		// Assassin
		else if (g_alien[victim])
		{
			if (!get_pcvar_num(cvar_alienpainfree)) return;
		}
		
		// Zombie
		else
		{
			switch (get_pcvar_num(cvar_zombiepainfree))
			{
				case 0: return;
				case 2: if (!g_lastzombie[victim]) return;
			}
		}
	}
	else
	{
		// Survivor
		if (g_survivor[victim])
		{
			if (!get_pcvar_num(cvar_survpainfree)) return;
		}
		
		// Sniper
		else if (g_sniper[victim])
		{
			if (!get_pcvar_num(cvar_sniperpainfree)) return;
		}
		// Wesker
		else if (g_wesker[victim])
		{
			if (!get_pcvar_num(cvar_weskerpainfree)) return;
		}
		// Depre
		else if (g_depre[victim])
		{
			if (!get_pcvar_num(cvar_deprepainfree)) return;
		}
		// Ninja
		else if (g_ninja[victim])
		{
			if (!get_pcvar_num(cvar_ninjapainfree)) return;
		}
		// L4D
		else if (g_l4d[victim][0] || g_l4d[victim][1] || g_l4d[victim][2] || g_l4d[victim][3])
		{
			if (!get_pcvar_num(cvar_l4dpainfree)) return;
		}
		
		// Human
		else return;
	}
	
	// Prevent server crash if entity's private data not initalized
	if (pev_valid(victim) != PDATA_SAFE)
		return;
	
	// Set pain shock free offset
	set_pdata_float(victim, OFFSET_PAINSHOCK, 1.0, OFFSET_LINUX)
}

// Ham Trace Attack Forward
public fw_TraceAttack(victim, attacker, Float:damage, Float:direction[3], tracehandle, damage_type)
{
	// Non-player damage or self damage
	if (victim == attacker || !is_user_valid_connected(attacker))
		return HAM_IGNORED;
	
	// New round starting or round ended
	if (g_newround || g_endround)
		return HAM_SUPERCEDE;
	
	// Victim shouldn't take damage or victim is frozen
	if (g_nodamage[victim] || g_frozen[victim])
		return HAM_SUPERCEDE;
	
	// Prevent friendly fire
	if (g_zombie[attacker] == g_zombie[victim])
		return HAM_SUPERCEDE;
	
	// Victim isn't a zombie or not bullet damage, nothing else to do here
	if (!g_zombie[victim] || !(damage_type & DMG_BULLET))
		return HAM_IGNORED;
	
	// If zombie hitzones are enabled, check whether we hit an allowed one
	if (get_pcvar_num(cvar_hitzones) && !g_nemesis[victim] && !g_assassin[victim] && !g_alien[victim] && !(get_pcvar_num(cvar_hitzones) & (1<<get_tr2(tracehandle, TR_iHitgroup))))
		return HAM_SUPERCEDE;
	
	// Knockback disabled, nothing else to do here
	if (!get_pcvar_num(cvar_knockback))
		return HAM_IGNORED;
	
	// Nemesis knockback disabled, nothing else to do here
	if (g_nemesis[victim] && get_pcvar_float(cvar_nemknockback) == 0.0)
		return HAM_IGNORED;
	
	// Assassin knockback disabled, nothing else to do here
	if (g_assassin[victim] && get_pcvar_float(cvar_assassinknockback) == 0.0)
		return HAM_IGNORED;
		
	// Alien knockback disabled, nothing else to do here
	if (g_alien[victim] && get_pcvar_float(cvar_alienknockback) == 0.0)
		return HAM_IGNORED;
	
	// Get whether the victim is in a crouch state
	static ducking
	ducking = pev(victim, pev_flags) & (FL_DUCKING | FL_ONGROUND) == (FL_DUCKING | FL_ONGROUND)
	
	// Zombie knockback when ducking disabled
	if (ducking && get_pcvar_float(cvar_knockbackducking) == 0.0)
		return HAM_IGNORED;
	
	// Get distance between players
	static origin1[3], origin2[3]
	get_user_origin(victim, origin1)
	get_user_origin(attacker, origin2)
	
	// Max distance exceeded
	if (get_distance(origin1, origin2) > get_pcvar_num(cvar_knockbackdist))
		return HAM_IGNORED;
	
	// Get victim's velocity
	static Float:velocity[3]
	pev(victim, pev_velocity, velocity)
	
	// Use damage on knockback calculation
	if (get_pcvar_num(cvar_knockbackdamage))
		xs_vec_mul_scalar(direction, damage, direction)
	
	// Use weapon power on knockback calculation
	if (get_pcvar_num(cvar_knockbackpower) && kb_weapon_power[g_currentweapon[attacker]] > 0.0)
		xs_vec_mul_scalar(direction, kb_weapon_power[g_currentweapon[attacker]], direction)
	
	// Apply ducking knockback multiplier
	if (ducking)
		xs_vec_mul_scalar(direction, get_pcvar_float(cvar_knockbackducking), direction)
	
	// Apply zombie class/nemesis knockback multiplier
	if (g_nemesis[victim])
		xs_vec_mul_scalar(direction, get_pcvar_float(cvar_nemknockback), direction)
	else if (g_assassin[victim])
		xs_vec_mul_scalar(direction, get_pcvar_float(cvar_assassinknockback), direction)
	else if (g_alien[victim])
		xs_vec_mul_scalar(direction, get_pcvar_float(cvar_alienknockback), direction)
	else if (!g_assassin[victim]  && !g_alien[victim] && !g_nemesis[victim])
		xs_vec_mul_scalar(direction, g_zclass_kb[g_zombieclass[victim]], direction)
	
	// Add up the new vector
	xs_vec_add(velocity, direction, direction)
	
	// Should knockback also affect vertical velocity?
	if (!get_pcvar_num(cvar_knockbackzvel))
		direction[2] = velocity[2]
	
	// Set the knockback'd victim's velocity
	set_pev(victim, pev_velocity, direction)
	
	return HAM_IGNORED;
}

// Ham Use Stationary Gun Forward
public fw_UseStationary(entity, caller, activator, use_type)
{
	// Prevent zombies from using stationary guns
	if (use_type == USE_USING && is_user_valid_connected(caller) && g_zombie[caller])
		return HAM_SUPERCEDE;
	
	return HAM_IGNORED;
}

// Ham Use Stationary Gun Post Forward
public fw_UseStationary_Post(entity, caller, activator, use_type)
{
	// Someone stopped using a stationary gun
	if (use_type == USE_STOPPED && is_user_valid_connected(caller))
		replace_weapon_models(caller, g_currentweapon[caller]) // replace weapon models (bugfix)
}

// Ham Use Pushable Forward
public fw_UsePushable()
{
	// Prevent speed bug with pushables?
	if (get_pcvar_num(cvar_blockpushables))
		return HAM_SUPERCEDE;
	
	return HAM_IGNORED;
}

// Ham Weapon Touch Forward
public fw_TouchWeapon(weapon, id)
{
	// Not a player
	if (!is_user_valid_connected(id))
		return HAM_IGNORED;
	
	if (g_zombie[id] || g_survivor[id] || g_sniper[id] || g_wesker[id] || g_depre[id] 
	|| g_l4d[id][0] || g_l4d[id][1] || g_l4d[id][2]  || g_l4d[id][3] || g_ninja[id])
		return HAM_SUPERCEDE;
	
	return HAM_IGNORED;
}

// Ham Weapon Pickup Forward
public fw_AddPlayerItem(id, weapon_ent)
{
	// HACK: Retrieve our custom extra ammo from the weapon
	static extra_ammo
	extra_ammo = pev(weapon_ent, PEV_ADDITIONAL_AMMO)
	
	// If present
	if (extra_ammo)
	{
		// Get weapon's id
		static weaponid
		weaponid = cs_get_weapon_id(weapon_ent)
		
		// Add to player's bpammo
		ExecuteHamB(Ham_GiveAmmo, id, extra_ammo, AMMOTYPE[weaponid], MAXBPAMMO[weaponid])
		set_pev(weapon_ent, PEV_ADDITIONAL_AMMO, 0)
	}
}

// Ham Weapon Deploy Forward
public fw_Item_Deploy_Post(weapon_ent)
{
	// Get weapon's owner
	static owner
	owner = fm_cs_get_weapon_ent_owner(weapon_ent)
	
	// Get weapon's id
	static weaponid
	weaponid = cs_get_weapon_id(weapon_ent)
	
	// Store current weapon's id for reference
	g_currentweapon[owner] = weaponid
	
	// Replace weapon models with custom ones
	replace_weapon_models(owner, weaponid)
	
	// Zombie not holding an allowed weapon for some reason
	if (g_zombie[owner] && !((1<<weaponid) & ZOMBIE_ALLOWED_WEAPONS_BITSUM))
	{
		// Switch to knife
		g_currentweapon[owner] = CSW_KNIFE
		engclient_cmd(owner, "weapon_knife")
	}
}

// WeaponMod bugfix
// forward wpn_gi_reset_weapon(id);
public wpn_gi_reset_weapon(id)
{
	// Replace knife model
	replace_weapon_models(id, CSW_KNIFE)
}

// Client left
public fw_ClientDisconnect_Post()
{
	// Last Zombie Check
	fnCheckLastZombie()
}

// Emit Sound Forward
public fw_EmitSound(id, channel, const sample[], Float:volume, Float:attn, flags, pitch)
{
	// Block all those unneeeded hostage sounds
	if (sample[0] == 'h' && sample[1] == 'o' && sample[2] == 's' && sample[3] == 't' && sample[4] == 'a' && sample[5] == 'g' && sample[6] == 'e')
		return FMRES_SUPERCEDE;
	
	// Replace these next sounds for zombies only
	if (!is_user_valid_connected(id) || !g_zombie[id])
		return FMRES_IGNORED;
	
	// Zombie being hit
	if (sample[7] == 'b' && sample[8] == 'h' && sample[9] == 'i' && sample[10] == 't')
	{
		if (g_nemesis[id])
			emit_sound(id, CHAN_VOICE, nemesis_pain[random_num(0, sizeof nemesis_pain - 1)], 1.0, ATTN_NORM, 0, PITCH_NORM)
		else if (g_assassin[id])
			emit_sound(id, CHAN_VOICE, assassin_pain[random_num(0, sizeof assassin_pain - 1)], 1.0, ATTN_NORM, 0, PITCH_NORM)
		else if (g_alien[id])
			emit_sound(id, CHAN_VOICE, alien_pain[random_num(0, sizeof alien_pain - 1)], 1.0, ATTN_NORM, 0, PITCH_NORM)
		else
			emit_sound(id, CHAN_VOICE, zombie_pain[random_num(0, sizeof zombie_pain - 1)], 1.0, ATTN_NORM, 0, PITCH_NORM)
		return FMRES_SUPERCEDE;
	}
	
	// Zombie attacks with knife
	if (sample[8] == 'k' && sample[9] == 'n' && sample[10] == 'i')
	{
		if (sample[14] == 's' && sample[15] == 'l' && sample[16] == 'a') // slash
		{
			emit_sound(id, CHAN_VOICE, zombie_miss_slash[random_num(0, sizeof zombie_miss_slash - 1)], 1.0, ATTN_NORM, 0, PITCH_NORM)
			return FMRES_SUPERCEDE;
		}
		if (sample[14] == 'h' && sample[15] == 'i' && sample[16] == 't') // hit
		{
			if (sample[17] == 'w') // wall
			{
				emit_sound(id, CHAN_VOICE, zombie_miss_wall[random_num(0, sizeof zombie_miss_wall - 1)], 1.0, ATTN_NORM, 0, PITCH_NORM)
				return FMRES_SUPERCEDE;
			}
			else
			{
				emit_sound(id, CHAN_VOICE, zombie_hit_normal[random_num(0, sizeof zombie_hit_normal - 1)], 1.0, ATTN_NORM, 0, PITCH_NORM)
				return FMRES_SUPERCEDE;
			}
		}
		if (sample[14] == 's' && sample[15] == 't' && sample[16] == 'a') // stab
		{
			emit_sound(id, CHAN_VOICE, zombie_hit_stab[random_num(0, sizeof zombie_hit_stab - 1)], 1.0, ATTN_NORM, 0, PITCH_NORM)
			return FMRES_SUPERCEDE;
		}
	}
	
	// Zombie dies
	if (sample[7] == 'd' && ((sample[8] == 'i' && sample[9] == 'e') || (sample[8] == 'e' && sample[9] == 'a')))
	{
		emit_sound(id, CHAN_VOICE, zombie_die[random_num(0, sizeof zombie_die - 1)], 1.0, ATTN_NORM, 0, PITCH_NORM)
		return FMRES_SUPERCEDE;
	}
	
	// Zombie falls off
	if (sample[10] == 'f' && sample[11] == 'a' && sample[12] == 'l' && sample[13] == 'l')
	{
		emit_sound(id, CHAN_ITEM, "zombie_plague/zombie_fall1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
		return FMRES_SUPERCEDE;
	}
	
	return FMRES_IGNORED;
}

// Forward Client User Info Changed -prevent players from changing models-
public fw_ClientUserInfoChanged(id)
{
	get_user_name(id, g_playername[id], charsmax(g_playername[]))
}

// Forward Get Game Description
public fw_GetGameDescription()
{
	// Return the mod name so it can be easily identified
	forward_return(FMV_STRING, PLUGIN_NAME)
	
	return FMRES_SUPERCEDE;
}

// Forward Set Model
public fw_SetModel(entity, const model[])
{
	// We don't care
	if (strlen(model) < 8)
		return FMRES_IGNORED;
	
	// Remove weapons?
	if (get_pcvar_float(cvar_removedropped) > 0.0)
	{
		// Get entity's classname
		static classname[10]
		pev(entity, pev_classname, classname, charsmax(classname))
		
		// Check if it's a weapon box
		if (equal(classname, "weaponbox"))
		{
			// They get automatically removed when thinking
			set_pev(entity, pev_nextthink, get_gametime() + get_pcvar_float(cvar_removedropped))
			return FMRES_IGNORED;
		}
	}
	
	// Narrow down our matches a bit
	if (model[7] != 'w' || model[8] != '_')
		return FMRES_IGNORED;
	
	// Get damage time of grenade
	static Float:dmgtime
	pev(entity, pev_dmgtime, dmgtime)
	
	// Grenade not yet thrown
	if (dmgtime == 0.0)
		return FMRES_IGNORED;
		
	new owner = pev(entity, pev_owner)
	
	// Get whether grenade's owner is a zombie
	if (g_zombie[pev(entity, pev_owner)])
	{
		if (model[9] == 'h' && model[10] == 'e') // Infection Bomb
		{
			// Give it a glow
			fm_set_rendering(entity, kRenderFxGlowShell, 0, 250, 0, kRenderNormal, 16);
			
			// Set grenade model
			entity_set_model(entity, gModelsManos[MODEL_WGRENADE_INFECT])
			
			// And a colored trail
			message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
			write_byte(TE_BEAMFOLLOW) // TE id
			write_short(entity) // entity
			write_short(gRayoLevelSpr) // sprite
			write_byte(10) // life
			write_byte(2) // width
			write_byte(0) // r
			write_byte(250) // g
			write_byte(0) // b
			write_byte(200) // brightness
			message_end()
			
			// Set grenade type on the thrown grenade entity
			set_pev(entity, PEV_NADE_TYPE, NADE_TYPE_INFECTION)
			return FMRES_SUPERCEDE
		}
	}
	else if (model[9] == 'h' && model[10] == 'e') // Napalm Grenade
	{
		if(has_molotov[owner])
		{		
			// Give it a glow
			fm_set_rendering(entity, kRenderFxGlowShell, 200, 0, 0, kRenderNormal, 16);
			
			entity_set_model(entity, gModelsManos[MODEL_WGRENADE_MOLOTOV])
			
			// And a colored trail
			message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
			write_byte(TE_BEAMFOLLOW) // TE id
			write_short(entity) // entity
			write_short(gRayoLevelSpr) // sprite
			write_byte(10) // life
			write_byte(2) // width
			write_byte(200) // r
			write_byte(100) // g
			write_byte(0) // b
			write_byte(200) // brightness
			message_end()
			
			set_task(0.2, "effect_molotov_fire", entity, _, _, "b") 
			
			// Set grenade type on the thrown grenade entity
			set_pev(entity, PEV_NADE_TYPE, NADE_TYPE_MOLOTOV)
			return FMRES_SUPERCEDE;
		}
		else if(g_antidotebomb[owner])
		{		
			// Give it a glow
			fm_set_rendering(entity, kRenderFxGlowShell, 184, 0, 245, kRenderNormal, 50);
			
			entity_set_model(entity, gModelsManos[MODEL_WGRENADE_ANTIDOTO])
			
			// And a colored trail
			message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
			write_byte(TE_BEAMFOLLOW) // TE id
			write_short(entity) // entity
			write_short(gRayoLevelSpr) // sprite
			write_byte(10) // life
			write_byte(25) // width
			write_byte(184) // r
			write_byte(0) // g
			write_byte(245) // b
			write_byte(255) // brightness
			message_end()
			
			// Set grenade type on the thrown grenade entity
			set_pev(entity, PEV_NADE_TYPE, NADE_TYPE_ANTIDOTO)
			return FMRES_SUPERCEDE;
		}
		else// if(has_fuego[owner])
		{
			// Give it a glow
			fm_set_rendering(entity, kRenderFxGlowShell, 0, 100, 200, kRenderNormal, 16);
			
			// And a colored trail
			message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
			write_byte(TE_BEAMFOLLOW) // TE id
			write_short(entity) // entity
			write_short(gRayoLevelSpr) // sprite
			write_byte(10) // life
			write_byte(2) // width
			write_byte(0) // r
			write_byte(100) // g
			write_byte(200) // b
			write_byte(255) // brightness
			message_end()
			
			entity_set_model(entity, gModelsManos[MODEL_WGRENADE_FUEGO])
			
			// Set grenade type on the thrown grenade entity
			set_pev(entity, PEV_NADE_TYPE, NADE_TYPE_NAPALM)
			
			return FMRES_SUPERCEDE
		}
	}
	else if (model[9] == 'f' && model[10] == 'l') // Frost Grenade
	{
		fm_set_rendering(entity, kRenderFxGlowShell, 0, 100, 200, kRenderNormal, 16);
				
		entity_set_model(entity, gModelsManos[MODEL_WGRENADE_FROST])
			
		// And a colored trail
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(TE_BEAMFOLLOW) // TE id
		write_short(entity) // entity
		write_short(gRayoLevelSpr) // sprite
		write_byte(10) // life
		write_byte(2) // width
		write_byte(0) // r
		write_byte(100) // g
		write_byte(200) // b
		write_byte(200) // brightness
		message_end()
			
		// Set grenade type on the thrown grenade entity
		set_pev(entity, PEV_NADE_TYPE, NADE_TYPE_FROST)
		return FMRES_SUPERCEDE
	}
	else if (model[9] == 's' && model[10] == 'm') // Flare
	{
		static R, G, B
		R = get_pcvar_num(gCvarsPlugin[REDBUBBLE][gCvarValor]) 
		G = get_pcvar_num(gCvarsPlugin[GREENBUBBLE][gCvarValor])
		B = get_pcvar_num(gCvarsPlugin[BLUEBUBBLE][gCvarValor])
		if(has_burbuja[owner])
		{
			fm_set_rendering(entity, kRenderFxGlowShell, R, G, B, kRenderNormal, 20)
			
			entity_set_model(entity, gModelsManos[MODEL_WGRENADE_BURBUJA])
			
			message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
			write_byte(TE_BEAMFOLLOW) // TE id
			write_short(entity) // entity
			write_short(gRayoLevelSpr) // sprite
			write_byte(5) // life
			write_byte(10) // width
			write_byte(R) // r
			write_byte(G) // g
			write_byte(B) // b
			write_byte(255) // brightness
			message_end()
			
			set_pev(entity, PEV_NADE_TYPE, NADE_TYPE_BUBBLE)
			
			return FMRES_SUPERCEDE;
		}		
		else
		{
			static id; id = pev(entity, pev_owner)
			
			entity_set_model(entity, gModelsManos[MODEL_WGRENADE_FLARE])
			
			// And a colored trail
			message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
			write_byte(TE_BEAMFOLLOW) // TE id
			write_short(entity) // entity
			write_short(gRayoLevelSpr) // sprite
			write_byte(10) // life
			write_byte(10) // width
			write_byte(Colores[id][12]) // b
			write_byte(Colores[id][13]) // b
			write_byte(Colores[id][14]) // b
			write_byte(200) // brightness
			message_end()
			
			// Set grenade type on the thrown grenade entity
			//set_pev(entity , pev_effects , EF_LIGHT)
			set_pev(entity, PEV_NADE_TYPE, NADE_TYPE_FLARE)
			
				
			/*for( i = 0 , z = 12 ; i < 3 , z < 15 ; i++ , z++ )
				Colores[id][z] = COLOR_RGB[Key][i]*/
				
			set_pev(entity, PEV_FLARE_COLOR, Colores[id][12], Colores[id][13], Colores[id][14])
			
			return FMRES_SUPERCEDE
		}
	}
	return FMRES_IGNORED;
}

public fw_think(entity)
{
	if (!pev_valid(entity))	return;
	
	static model[64];
	pev(entity, pev_model, model, charsmax(model))

	if (equal(model, gModelsManos[MODEL_XGRENADE_BURBUJA]))
	{
		new e = -1
		
		new Float:centerF[3], Float:originF[3], Float:directionF[3], Float:proporcionF
		pev(entity, pev_origin, centerF)		
		
		while((e = find_ent_in_sphere(e, centerF, get_pcvar_float(gCvarsPlugin[RADIOBUBBLE][gCvarValor]))) != 0)
		{
			// Si no es un player o no es zombie, el campo de fuerza lo ignorar�
			if((e > g_maxplayers) || !g_zombie[e] || g_nodamage[e])
				continue;
			
			pev(e, pev_origin, originF)
			
			// Direccion
			xs_vec_sub(originF, centerF, directionF)
			
			proporcionF = ((get_pcvar_float(gCvarsPlugin[RADIOBUBBLE][gCvarValor]) + 40.0) - vector_length(directionF)) / 10.0

			xs_vec_mul_scalar(directionF, proporcionF, directionF)

			set_pev(e, pev_velocity, directionF)
		}
		
		set_pev(entity, pev_nextthink, get_gametime() + 0.1)		
	}
}

// Ham Grenade Think Forward
public fw_ThinkGrenade(entity)
{
	// Invalid entity
	if (!pev_valid(entity))
		return HAM_IGNORED;
	
	// Get damage time of grenade
	static Float:dmgtime, Float:current_time
	pev(entity, pev_dmgtime, dmgtime)
	current_time = get_gametime()
	
	// Check if it's time to go off
	if (dmgtime > current_time)
		return HAM_IGNORED;
	
	// Check if it's one of our custom nades
	switch (pev(entity, PEV_NADE_TYPE))
	{
		case NADE_TYPE_INFECTION: // Infection Bomb
		{
			infection_explode(entity)
			return HAM_SUPERCEDE;
		}
		case NADE_TYPE_NAPALM: // Napalm Grenade
		{
			//has_fuego[pev(entity, pev_owner)]--
			fire_explode(entity)
			return HAM_SUPERCEDE;
		}
		case NADE_TYPE_FROST: // Frost Grenade
		{
			//has_hielo[pev(entity, pev_owner)]--
			frost_explode(entity)
			return HAM_SUPERCEDE;
		}
		case NADE_TYPE_FLARE: // Flare
		{
			static duration
			duration = pev(entity, PEV_FLARE_DURATION)
			if (duration > 0)
			{
				if (duration == 1)
				{
					engfunc(EngFunc_RemoveEntity, entity)
					return HAM_SUPERCEDE;
				}
				
				flare_lighting(entity, duration)
				
				set_pev(entity, PEV_FLARE_DURATION, --duration)
				set_pev(entity, pev_dmgtime, current_time + 5.0)
			}
			else if ((pev(entity, pev_flags) & FL_ONGROUND) && fm_get_speed(entity) < 10)
			{
				emit_sound(entity, CHAN_AUTO, "items/nvg_on.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)

				set_pev(entity, PEV_FLARE_DURATION, 1 + get_pcvar_num(cvar_flareduration)/5)
				set_pev(entity, pev_dmgtime, current_time + 0.1)
			}
			else
			{
				set_pev(entity, pev_dmgtime, current_time + 0.5)
			}
		}
		case NADE_TYPE_BUBBLE:	// Burbuja
		{
			// Get its duration
			static duration, attacker
			duration = pev(entity, PEV_FLARE_DURATION)

			// Already went off, do lighting loop for the duration of PEV_FLARE_DURATION
			if (duration > 0)
			{
				// Check whether this is the last loop
				if (duration == 1)
				{
					// Get rid of the flare entity
					engfunc(EngFunc_RemoveEntity, entity)
					return HAM_SUPERCEDE;
				}
				
				// Set time for next loop
				set_pev(entity, PEV_FLARE_DURATION, --duration)
				set_pev(entity, pev_dmgtime, current_time + 5.0)
			}
			// Light up when it's stopped on ground
			else if ((pev(entity, pev_flags) & FL_ONGROUND) && fm_get_speed(entity) < 10)
			{
				static R, G, B
				R = get_pcvar_num(gCvarsPlugin[REDBUBBLE][gCvarValor]) 
				G = get_pcvar_num(gCvarsPlugin[GREENBUBBLE][gCvarValor])
				B = get_pcvar_num(gCvarsPlugin[BLUEBUBBLE][gCvarValor])
				
				emit_sound(entity, CHAN_AUTO, "zpre4/campo_explosion.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
				
				entity_set_model(entity, gModelsManos[MODEL_XGRENADE_BURBUJA])
				
				set_rendering(entity, kRenderFxGlowShell, R, G, B, kRenderTransAlpha, 50)
				
				// Set duration and start lightning loop on next think
				set_pev(entity, PEV_FLARE_DURATION, 1 + get_pcvar_num(gCvarsPlugin[DURACIONBUBBLE][gCvarValor]) / 5)
				set_pev(entity, pev_dmgtime, current_time + 0.1)
				set_pev(entity, pev_nextthink, get_gametime() + 0.1)
			}
			else
			{
				has_burbuja[attacker]--			
				
				set_pev(entity, pev_dmgtime, current_time + 0.5)
			}
		}
		case NADE_TYPE_MOLOTOV:
		{
			has_molotov[pev(entity, pev_owner)]--
			
			molotov_explode(entity)
			return HAM_SUPERCEDE;			
		}
		case NADE_TYPE_ANTIDOTO:
		{
			g_antidotebomb[pev(entity, pev_owner)]--
			
			antidotebomb_explode(entity)
			return HAM_SUPERCEDE;			
		}
	}
	
	return HAM_IGNORED;
}

// Forward CmdStart
public fw_CmdStart(id, handle)
{
	// Not alive
	if (!g_isalive[id])
		return;
	
	// This logic looks kinda weird, but it should work in theory...
	// p = g_zombie[id], q = g_survivor[id], r = g_cached_customflash
	// �(p v q v (�p ^ r)) <==> �p ^ �q ^ (p v �r)
	if (is_human(id) && (g_zombie[id] || !g_cached_customflash))
		return;
	
	// Check if it's a flashlight impulse
	if (get_uc(handle, UC_Impulse) != IMPULSE_FLASHLIGHT)
		return;
	
	// Block it I say!
	set_uc(handle, UC_Impulse, 0)
	
	// Should human's custom flashlight be turned on?
	if (is_human(id) && g_flashbattery[id] > 2 && get_gametime() - g_lastflashtime[id] > 1.2)
	{
		// Prevent calling flashlight too quickly (bugfix)
		g_lastflashtime[id] = get_gametime()
		
		// Toggle custom flashlight
		g_flashlight[id] = !(g_flashlight[id])
		
		// Play flashlight toggle sound
		emit_sound(id, CHAN_ITEM, "items/flashlight1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
		
		// Update flashlight status on the HUD
		message_begin(MSG_ONE, g_msgFlashlight, _, id)
		write_byte(g_flashlight[id]) // toggle
		write_byte(g_flashbattery[id]) // battery
		message_end()
		
		// Remove previous tasks
		remove_task(id+TASK_CHARGE)
		remove_task(id+TASK_FLASH)
		
		// Set the flashlight charge task
		set_task(1.0, "flashlight_charge", id+TASK_CHARGE, _, _, "b")
		
		// Call our custom flashlight task if enabled
		if (g_flashlight[id]) set_task(0.1, "set_user_flashlight", id+TASK_FLASH, _, _, "b")
	}
}

// Forward Player PreThink
public fw_PlayerPreThink(id)
{
	// Not alive
	if (!g_isalive[id])
		return;

	static iButton; iButton = pev(id, pev_button)
	static iOldButton; iOldButton = pev(id, pev_oldbuttons)
	
	if(g_depre[id])
	{
		if((iButton & IN_USE) && !(iOldButton & IN_USE))
		{			
			if(get_gametime() - gDisparoAnterior[id] < get_pcvar_float(cvar_depredador_cooldown))
			{
				zp_colored_print(id, "%s Tienes Que Esperar^x03 %.1f^x01 Para Volver A Utilizar Tu Cañon", TAG, get_pcvar_float(cvar_depredador_cooldown)-(get_gametime() - gDisparoAnterior[id]))
				return;
			}
			
			gDisparoAnterior[id] = get_gametime()
			MakeFire(id)
			remove_task(id)
		}
	}
	
	// Silent footsteps for zombies/assassins/aliens ?
	if (g_zombie[id])
		set_pev(id, pev_flTimeStepSound, STEPTIME_SILENT)
	
	// Set Player MaxSpeed
	if (g_frozen[id])
	{
		set_pev(id, pev_velocity, Float:{0.0,0.0,0.0}) // stop motion
		set_pev(id, pev_maxspeed, 1.0) // prevent from moving
		return;
	}
	else if (g_freezetime)
	{
		return; // shouldn't leap while in freezetime
	}
	else
	{
		if (g_zombie[id])
		{
			if (g_nemesis[id])
				set_pev(id, pev_maxspeed, g_cached_nemspd)
			else if (g_assassin[id])
				set_pev(id, pev_maxspeed, g_cached_assassinspd)
			else if (g_alien[id])
				set_pev(id, pev_maxspeed, g_cached_alienspd)
			else
				set_pev(id, pev_maxspeed, g_zombie_spd[id])
		}
		else
		{
			if (g_survivor[id])
				set_pev(id, pev_maxspeed, g_cached_survspd)
			else if (g_sniper[id])
				set_pev(id, pev_maxspeed, g_cached_sniperspd)
			else if (g_wesker[id])
				set_pev(id, pev_maxspeed, g_cached_weskerspd)
			else if (g_depre[id])
				set_pev(id, pev_maxspeed, g_cached_deprespd)
			else if (g_ninja[id])
				set_pev(id, pev_maxspeed, g_cached_ninjaspd)
			else if (g_l4d[id][0])
				set_pev(id, pev_maxspeed, g_cached_l4dspd)
			else if (g_l4d[id][1])
				set_pev(id, pev_maxspeed, g_cached_l4dspd)
			else if (g_l4d[id][2])
				set_pev(id, pev_maxspeed, g_cached_l4dspd)
			else if (g_l4d[id][3])
				set_pev(id, pev_maxspeed, g_cached_l4dspd)
			else
				set_pev(id, pev_maxspeed, g_cached_humanspd + ammount_speed(g_mejoras[id][1]))
		}
	}
	
	// --- Check if player should leap ---
	
	// Check if proper CVARs are enabled and retrieve leap settings
	static Float:cooldown, Float:current_time
	if (g_zombie[id])
	{
		if (g_nemesis[id])
		{
			if (!g_cached_leapnemesis) return;
			cooldown = g_cached_leapnemesiscooldown
		}
		else if (g_assassin[id])
		{
			if (!g_cached_leapassassin) return;
			cooldown = g_cached_leapassassincooldown
		}
		else if (g_alien[id])
		{
			if (!g_cached_leapalien) return;
			cooldown = g_cached_leapaliencooldown
		}
		else if (!g_assassin[id] && !g_alien[id] && !g_nemesis[id])
		{
			switch (g_cached_leapzombies)
			{
				case 0: return;
				case 2: if (!g_firstzombie[id]) return;
				case 3: if (!g_lastzombie[id]) return;
			}
			cooldown = g_cached_leapzombiescooldown
		}
	}
	else
	{
		if (g_survivor[id])
		{
			if (!g_cached_leapsurvivor) return;
			cooldown = g_cached_leapsurvivorcooldown
		}
		else if (g_sniper[id])
		{
			if (!g_cached_leapsniper) return;
			cooldown = g_cached_leapsnipercooldown
		}
		else if (g_wesker[id])
		{
			if (!g_cached_leapwesker) return;
			cooldown = g_cached_leapweskercooldown
		}
		else if (g_depre[id])
		{
			if (!g_cached_leapdepre) return;
			cooldown = g_cached_leapdeprecooldown
		}
		else if (g_ninja[id])
		{
			if (!g_cached_leapninja) return;
			cooldown = g_cached_leapninjacooldown
		}
		else return;
	}
	current_time = get_gametime()
	
	if (current_time - g_lastleaptime[id] < cooldown)
		return;
	
	if (!(pev(id, pev_button) & (IN_JUMP | IN_DUCK) == (IN_JUMP | IN_DUCK)))
		return;
	
	// Not on ground or not enough speed
	if (!(pev(id, pev_flags) & FL_ONGROUND) || fm_get_speed(id) < 80)
		return;
	
	static Float:velocity[3]

	if (g_survivor[id])
		velocity_by_aim(id, get_pcvar_num(cvar_leapsurvivorforce), velocity)
	else if (g_nemesis[id])
		velocity_by_aim(id, get_pcvar_num(cvar_leapnemesisforce), velocity)
	else if (g_assassin[id])
		velocity_by_aim(id, get_pcvar_num(cvar_leapassassinforce), velocity)
	else if (g_ninja[id])
		velocity_by_aim(id, get_pcvar_num(cvar_leapninjaforce), velocity)
	else if (g_zombie[id] && !g_assassin[id] && !g_alien[id] && !g_nemesis[id])
		velocity_by_aim(id, get_pcvar_num(cvar_leapzombiesforce), velocity)
	
	// Set custom height
	if (g_survivor[id])
		velocity[2] = get_pcvar_float(cvar_leapsurvivorheight)
	else if (g_nemesis[id])
		velocity[2] = get_pcvar_float(cvar_leapnemesisheight)
	else if (g_assassin[id])
		velocity[2] = get_pcvar_float(cvar_leapassassinheight)
	else if (g_ninja[id])
		velocity[2] = get_pcvar_float(cvar_leapninjaheight)
	else if (g_zombie[id] && !g_assassin[id] && !g_alien[id] && !g_nemesis[id])
		velocity[2] = get_pcvar_float(cvar_leapzombiesheight)
	
	// Apply the new velocity
	set_pev(id, pev_velocity, velocity)
	
	// Update last leap time
	g_lastleaptime[id] = current_time
}
	
public fw_PlayerPreThink2(id)
{
	if(!g_isalive[id] || g_zombie[id] || g_survivor[id] || g_depre[id] || g_sniper[id] 
	|| g_ninja[id] || g_wesker[id] || g_l4d[id][0] || g_l4d[id][1] || g_l4d[id][2] || g_l4d[id][3] || !g_ThermalOn[id])
		return PLUGIN_CONTINUE;
		
	if((g_fDelay[id] + 0.2) > get_gametime())
		return PLUGIN_CONTINUE;
		
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
		
		if(!g_zombie[target])
			continue;
		
		if((get_distance_f(fMyOrigin, fTargetOrigin) > 500) 
		|| !is_in_viewcone(id, fTargetOrigin))
			continue;
			
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
	return PLUGIN_CONTINUE;
}

/*================================================================================
 [Client Commands]
=================================================================================*/

// Nightvision toggle
public clcmd_nightvision(id)
{
	if (g_nvision[id])
	{
		// Enable-disable
		g_nvisionenabled[id] = !(g_nvisionenabled[id])
		
		// Custom nvg?
		if (get_pcvar_num(cvar_customnvg))
		{
			remove_task(id+TASK_NVISION)
			if (g_nvisionenabled[id]) set_task(0.1, "set_user_nvision", id+TASK_NVISION, _, _, "b")
		}
		else
			set_user_gnvision(id, g_nvisionenabled[id])
	}
	
	return PLUGIN_HANDLED;
}

// Weapon Drop
public clcmd_drop(id)
{
	// Survivor/Sniper should stick with its weapon
	if (g_survivor[id] || g_sniper[id] || g_wesker[id] || g_depre[id] || g_l4d[id][0] || g_l4d[id][1] || g_l4d[id][2] || g_l4d[id][3] || g_ninja[id])
		return PLUGIN_HANDLED
	
	return PLUGIN_CONTINUE;
}

// Buy BP Ammo
public clcmd_buyammo(id)
{
	// Not alive or infinite ammo setting enabled
	if (!g_isalive[id] || get_pcvar_num(cvar_infammo))
		return PLUGIN_HANDLED;
	
	// Not human
	if (g_zombie[id])
	{
		zp_colored_print(id, "%s %L", TAG, id, "CMD_HUMAN_ONLY")
		return PLUGIN_HANDLED;
	}
	
	// Not enough ammo packs
	if (g_ammopacks[id] < 1)
	{
		zp_colored_print(id, "%s %L", TAG, id, "NOT_ENOUGH_AMMO")
		return PLUGIN_HANDLED;
	}
	
	// Get user weapons
	static weapons[32], num, i, currentammo, weaponid, refilled
	num = 0 // reset passed weapons count (bugfix)
	refilled = false
	get_user_weapons(id, weapons, num)
	
	// Loop through them and give the right ammo type
	for (i = 0; i < num; i++)
	{
		// Prevents re-iding the array
		weaponid = weapons[i]
		
		// Primary and secondary only
		if (MAXBPAMMO[weaponid] > 2)
		{
			// Get current ammo of the weapon
			currentammo = cs_get_user_bpammo(id, weaponid)
			
			// Give additional ammo
			ExecuteHamB(Ham_GiveAmmo, id, BUYAMMO[weaponid], AMMOTYPE[weaponid], MAXBPAMMO[weaponid])
			
			// Check whether we actually refilled the weapon's ammo
			if (cs_get_user_bpammo(id, weaponid) - currentammo > 0) refilled = true
		}
	}
	
	// Weapons already have full ammo
	if (!refilled) return PLUGIN_HANDLED;
	
	// Deduce ammo packs, play clip purchase sound, and notify player
	g_ammopacks[id]--
	emit_sound(id, CHAN_ITEM, "items/9mmclip1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
	zp_colored_print(id, "%s %L", TAG, id, "AMMO_BOUGHT")
	
	return PLUGIN_HANDLED;
}
/*
// Block Team Change
public clcmd_changeteam(id)
{
	static team
	team = fm_cs_get_user_team(id)
	
	// Unless it's a spectator joining the game
	if (team == FM_CS_TEAM_SPECTATOR || team == FM_CS_TEAM_UNASSIGNED || g_Estado[id] != Logueado)
		return PLUGIN_CONTINUE;
	
	// Pressing 'M' (chooseteam) ingame should show the main menu instead
	Menu_Principal_Juego(id)
	return PLUGIN_HANDLED;
}*/

/*===============================================================================
 [Menus]
=================================================================================*/

// Game Menu
public Menu_Principal_Juego(id)
{
	static menu[999], len
	len = 0
	iFlags = get_user_flags(id)
	
	// Title
	len += formatex(menu[len], charsmax(menu) - len, "\r-------------------------^n\w%s^n\r-------------------------^n", PLUGIN_NAME)
	
	// 1. Buy weapons
	len += formatex(menu[len], charsmax(menu) - len, "\r1. \yArmas\r &\y Equipamiento^n")
	
	// 2. Extra items
	if (g_isalive[id])
		len += formatex(menu[len], charsmax(menu) - len, "\r2. \yExtra Items^n^n")
	else
		len += formatex(menu[len], charsmax(menu) - len, "\d2. Extra Items^n^n")
	
	// 3. Zombie class
	if(g_classcounter[id] >= 1 && !is_user_admin(id))
		len += formatex(menu[len], charsmax(menu) - len, "\r3. \dClases de Zombie^n")
	else
		len += formatex(menu[len], charsmax(menu) - len, "\r3. \yClases de Zombie^n")
		
	// 4. Human class
	if(g_classcounter[id] >= 1 && !is_user_admin(id))
		len += formatex(menu[len], charsmax(menu) - len, "\r4. \dClases Humanas^n^n")
	else
		len += formatex(menu[len], charsmax(menu) - len, "\r4. \yClases Humanas^n^n")
	
	// 5. Unstuck
	if (g_isalive[id])
		len += formatex(menu[len], charsmax(menu) - len, "\r5.\y Destrabar\r (\wUnstuck\r)^n")
	else
		len += formatex(menu[len], charsmax(menu) - len, "\d5. Destrabar \r(\wUnstuck\r)^n")
		
	// 6. Join spec
	if (iFlags & CREADOR || iFlags & ADMIN)
		len += formatex(menu[len], charsmax(menu) - len, "\r6.\y Cambiar de Equipo^n^n")
	else
		len += formatex(menu[len], charsmax(menu) - len, "\d6. Cambiar de Equipo^n^n")
		
	// 7. Informaciones
	len += formatex(menu[len], charsmax(menu) - len, "\r7.\yReglas, Reclamos & Compra\r VIP^n\w========================")
		
	// 8. Perfil
	len += formatex(menu[len], charsmax(menu) - len, "^n\r8. Cuenta, Cambio de Password, y +^n")
	
	// 9. Admin menu
	if (iFlags & VIP || iFlags &ADMIN || iFlags & CREADOR)
		len += formatex(menu[len], charsmax(menu) - len, "\r9.\w Administracion\r VIP\y/\rMODERADOR^n\w========================")
	else
		len += formatex(menu[len], charsmax(menu) - len, "\d9. Administracion VIP/MODERADOR^n\w========================")
	
	// 0. Exit
	len += formatex(menu[len], charsmax(menu) - len, "^n^n\r0.\y Salir")
	
	if (pev_valid(id) == PDATA_SAFE)
		set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX)
	
	show_menu(id, KEYSMENU, menu, -1, "Game Menu")
}

// Zombie Class Menu
public Menu_Clases_Zombies(id)
{
	if (!g_isconnected[id])
		return;
	
	static menu[400], class, menuid, buffer[64]
	
	formatex(menu, charsmax(menu), "Clases de Zombie \r[\w%d\y Disponibles\r]", g_zclass_i)
	menuid = menu_create(menu, "Menu_Clases_Zombies_Cases")
	
	for (class = 0; class < g_zclass_i; class++)
	{
		if (class == g_zombieclassnext[id])
			formatex(menu, charsmax(menu), "\dZ-%s\r [\d%s\r]", g_zclass_name[class], g_zclass_info[class])
		else
			formatex(menu, charsmax(menu), "\yZ-%s\r [\w%s\r]", g_zclass_name[class], g_zclass_info[class])
			
		buffer[0] = class
		buffer[1] = 0
		menu_additem(menuid, menu, buffer)
	}
	
	// Back - Next - Exit
	formatex(menu, charsmax(menu), "Atras")
	menu_setprop(menuid, MPROP_BACKNAME, menu)
	formatex(menu, charsmax(menu), "Siguiente")
	menu_setprop(menuid, MPROP_NEXTNAME, menu)
	formatex(menu, charsmax(menu), "Salir")
	menu_setprop(menuid, MPROP_EXITNAME, menu)
	
	// If remembered page is greater than number of pages, clamp down the value
	MENU_PAGE_ZCLASS = min(MENU_PAGE_ZCLASS, menu_pages(menuid)-1)
	
	// Fix for AMXX custom menus
	if (pev_valid(id) == PDATA_SAFE)
		set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX)
	
	menu_display(id, menuid, MENU_PAGE_ZCLASS)
}

// Admin Menu
Menu_Admin1(id)
{
	static item[69]
	iFlags = get_user_flags(id)
	
	static iPlayersnum
	iPlayersnum = fnGetAlive()
	
	// Title
	formatex(item, charsmax(item), "\r[\yMenu Convertir\r]\y Te quedan\r %d\y modos", g_modcount[id])
	new menu = menu_create(item, "Menu_Admin1_Cases")
	
	// 1. Zombiefy/Humanize command
	if(iFlags & CREADOR)
		menu_additem(menu, "Hacer \rZombie/Humano", "0")
	else
		menu_additem(menu, "\dHacer \rZombie/Humano", "0")
	
	// 2. Nemesis command
	if(iFlags & CREADOR)
		menu_additem(menu, "Convertir \rNemesis", "1")
	else
		menu_additem(menu, "\dConvertir \rNemesis", "1")
	
	// 3. Survivor command
	if(iFlags & CREADOR)
		menu_additem(menu, "Convertir \rSurvivor", "2")
	else
		menu_additem(menu, "\dConvertir \rSurvivor", "2")
	
	// 4. Sniper command
	if(iFlags & CREADOR)
		menu_additem(menu, "Convertir \rSniper", "3")
	else
		menu_additem(menu, "\dConvertir \rSniper", "3")
		
	// 5. Wesker command
	if(iFlags & CREADOR && !g_newround ||  (iFlags & CREADOR && g_newround && iPlayersnum >= get_pcvar_num(cvar_weskerminplayers)))
		menu_additem(menu, "Convertir \rWesker", "4")
	else
		menu_additem(menu, "\dConvertir \rWesker", "4")
	
	// 6. Depredador command
	if(iFlags & CREADOR)
		menu_additem(menu, "Convertir \rDepredador", "5")
	else
		menu_additem(menu, "\dConvertir \rDepredador", "5")
	
	// 7. Assassin command
	if(iFlags & CREADOR)
		menu_additem(menu, "Convertir \rAssassin", "6")
	else
		menu_additem(menu, "\dConvertir \rAssassin", "6")
		
	// 1. Alien command
	if(iFlags & VIP || iFlags & ADMIN || iFlags & CREADOR)
	{
		if(iFlags & VIP || iFlags & ADMIN)
		{
			if(g_newround)
				menu_additem(menu, "Comenzar\r Modo Alien", "7")
			else
				menu_additem(menu, "\dComenzar\r Modo Alien", "7")
		}
		else
			menu_additem(menu, "Convertir \rAlien", "7")
	}
	else menu_additem(menu, "\dConvertir \rAlien", "7")
	
	// 2. Ninja command
	if(iFlags & CREADOR)
		menu_additem(menu, "Convertir \rNinja", "8")
	else
		menu_additem(menu, "\dConvertir \rNinja", "8")
	
	// 3. Respawn command
	if(iFlags & ADMIN || iFlags & CREADOR)
		menu_additem(menu, "Revivir \rJugador", "9")
	else
		menu_additem(menu, "\dRevivir \rJugador", "9")
		
	
	menu_setprop(menu, MPROP_BACKNAME, "Anterior")
	menu_setprop(menu, MPROP_NEXTNAME, "Siguiente")
	menu_setprop(menu,MPROP_EXITNAME,"Salir")
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL)
	
	// If remembered page is greater than number of pages, clamp down the value
	MENU_PAGE_ADMIN1 = min(MENU_PAGE_ADMIN1, menu_pages(menu)-1)
	
	// Fix for AMXX custom menus
	if (pev_valid(id) == PDATA_SAFE)
		set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX)
	
	menu_display(id, menu, MENU_PAGE_ADMIN1)
	
	return PLUGIN_HANDLED
}

// Admin Menu2
Menu_Admin2(id)
{
	static item[69]
	iFlags = get_user_flags(id)
	static iPlayersnum
	iPlayersnum = fnGetAlive()
	
	// Title
	formatex(item, charsmax(item), "\yMenu Modos Colectivos\w -\y Tienes\r %d\y modos para lanzar", g_modcount[id])
	new menu = menu_create(item, "Menu_Admin2_Cases")
	
	// 1. Multi infection command
	if ((iFlags & VIP || iFlags & ADMIN || iFlags & CREADOR && allowed_multi() && iPlayersnum >= get_pcvar_num(cvar_multiminplayers)))
		menu_additem(menu, "\y Iniciar \rModo Multiple Infeccion", "0")
	else
		menu_additem(menu, "\d Iniciar \rModo Multiple Infeccion", "0")
		
	// 2. Swarm mode command
	if ((iFlags & VIP || iFlags & ADMIN || iFlags & CREADOR && allowed_swarm() && iPlayersnum >= get_pcvar_num(cvar_swarmminplayers)))
		menu_additem(menu, "\y Iniciar \rModo Swarm", "1")
	else
		menu_additem(menu, "\d Iniciar \rModo Swarm", "1")
	
	// 3. Plague mode command
	if ((iFlags & VIP || iFlags & ADMIN || iFlags & CREADOR && allowed_plague() && iPlayersnum >= get_pcvar_num(cvar_plagueminplayers)))
		menu_additem(menu, "\y Iniciar \rModo Plague", "2")
	else
		menu_additem(menu, "\d Iniciar \rModo Plague", "2")
	
	// 4. Armageddon mode command
	if ((iFlags & VIP || iFlags & ADMIN || iFlags & CREADOR && allowed_lnj() && iPlayersnum >= get_pcvar_num(cvar_lnjminplayers)))
		menu_additem(menu, "\y Iniciar \rModo Nemesis vs Survivors", "3")
	else
		menu_additem(menu, "\d Iniciar \rModo Nemesis vs Survivors", "3")
		
	// 5. Tournament mode command
	if ((iFlags & VIP || iFlags & ADMIN || iFlags & CREADOR && allowed_torneo() && iPlayersnum >= get_pcvar_num(cvar_torneominplayers)))
		menu_additem(menu, "\y Iniciar \rModo Torneo", "4")
	else
		menu_additem(menu, "\d Iniciar \rModo Torneo", "4")
		
	// 6. Synapsis mode command
	if ((iFlags & VIP || iFlags & ADMIN || iFlags & CREADOR && allowed_synapsis() && iPlayersnum >= get_pcvar_num(cvar_synapsisminplayers)))
		menu_additem(menu, "\y Iniciar \rModo Synapsis", "5")
	else
		menu_additem(menu, "\d Iniciar \rModo Synapsis", "5")
		
	// 7. L4D mode command
	if ((iFlags & VIP || iFlags & ADMIN || iFlags & CREADOR && allowed_l4d() && iPlayersnum >= get_pcvar_num(cvar_l4dminplayers)))
		menu_additem(menu, "\y Iniciar \rModo Left 4 Dead", "6")
	else
		menu_additem(menu, "\d Iniciar \rModo Left 4 Dead", "6")

	menu_setprop(menu, MPROP_BACKNAME, "Anterior")
	menu_setprop(menu, MPROP_NEXTNAME, "Siguiente")
	menu_setprop(menu,MPROP_EXITNAME,"Salir")
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL)
	
	// If remembered page is greater than number of pages, clamp down the value
	MENU_PAGE_ADMIN2 = min(MENU_PAGE_ADMIN2, menu_pages(menu)-1)
	
	// Fix for AMXX custom menus
	if (pev_valid(id) == PDATA_SAFE)
		set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX)
	
	menu_display(id, menu, MENU_PAGE_ADMIN2)
	
	return PLUGIN_HANDLED
}

// Admin Menu 3
Menu_Admin0(id)
{
	static item[69], iFlags
	iFlags = get_user_flags(id)
	
	// Title
	formatex(item, charsmax(item), "\y%L", id, "MENU3_ADMIN_TITLE")
	new menu = menu_create(item, "Menu_Admin0_Cases")
	
	// 1. Elegir Clase o Revivir
	if (iFlags & VIP || iFlags & ADMIN || iFlags & CREADOR)
		menu_additem(menu, "\yElegir Clase o Revivir", "0")
	else
		menu_additem(menu, "\dElegir Clase o Revivir", "0")
	
	// 2. Main Modes admin menu
	if (iFlags & VIP || iFlags & ADMIN || iFlags & CREADOR)
		menu_additem(menu, "\yIniciar Modos Colectivos", "1")
	else
		menu_additem(menu, "\dIniciar Modos Colectivos", "1")
	
	// 3. Custom modes admin menu
	if (iFlags & VIP || iFlags & ADMIN || iFlags & CREADOR)
		menu_additem(menu, "\yModos Extras\r [\wVersus Modos\r]", "2")
	else
		menu_additem(menu, "\dModos Extras [Versus Modos]", "2")

	// 3. Custom modes admin menu
	if (iFlags & VIP || iFlags & ADMIN || iFlags & CREADOR)
		menu_additem(menu, "\yCambiar Mapa, Kick, Ban, Etc", "3")
	else
		menu_additem(menu, "\dMenu MODERADORES/CREADORES", "3")
	
	menu_setprop(menu, MPROP_BACKNAME, "Anterior")
	menu_setprop(menu, MPROP_NEXTNAME, "Siguiente")
	menu_setprop(menu,MPROP_EXITNAME,"Salir")
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL)
	
	// If remembered page is greater than number of pages, clamp down the value
	MENU_PAGE_ADMIN0 = min(MENU_PAGE_ADMIN0, menu_pages(menu)-1)
	
	// Fix for AMXX custom menus
	if (pev_valid(id) == PDATA_SAFE)
		set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX)
	
	menu_display(id, menu, MENU_PAGE_ADMIN0)
	
	return PLUGIN_HANDLED
}

// Player List Menu
Menu_Lista_Players(id)
{
	static menuid, menu[128], player, buffer[2]
	iFlags = get_user_flags(id)
	
	// Title
	switch (PL_ACTION)
	{
		case ACTION_ZOMBIEFY_HUMANIZE: formatex(menu, charsmax(menu), "Convertir\r Humano\y/\rZombie")
		case ACTION_MAKE_NEMESIS: formatex(menu, charsmax(menu), "Convertir\r Nemesis")
		case ACTION_MAKE_SURVIVOR: formatex(menu, charsmax(menu), "Convertir\r Sobreviviente")
		case ACTION_MAKE_SNIPER: formatex(menu, charsmax(menu), "Convertir\r Sniper")
		case ACTION_MAKE_WESKER: formatex(menu, charsmax(menu), "Convertir\r Wesker")
		case ACTION_MAKE_DEPRE: formatex(menu, charsmax(menu), "Convertir\r Depredador")
		case ACTION_MAKE_ASSASSIN: formatex(menu, charsmax(menu), "Convertir\r Assassin")
		case ACTION_MAKE_ALIEN: formatex(menu, charsmax(menu), "Convertir\r Alien")
		case ACTION_MAKE_NINJA: formatex(menu, charsmax(menu), "Convertir\r Ninja")
		case ACTION_RESPAWN_PLAYER: formatex(menu, charsmax(menu), "Revivir Jugador")
	}
	menuid = menu_create(menu, "Menu_Lista_Players_Cases")
	
	// Player List
	for (player = 1; player <= g_maxplayers; player++)
	{
		// Skip if not connected
		if (!g_isconnected[player])
			continue;
			
		static iPlayersnum
		iPlayersnum = fnGetAlive()
		
		// Format text depending on the action to take
		switch (PL_ACTION)
		{
			case ACTION_ZOMBIEFY_HUMANIZE: // Zombiefy/Humanize command
			{
				if (g_zombie[player])
				{
					if (allowed_human(player) && (iFlags & CREADOR ))
					{
						if (g_nemesis[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_NEMESIS")
						else if (g_assassin[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_ASSASSIN")
						else if (g_alien[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_ALIEN")
						else
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_ZOMBIE")
					}
					else
					{
						if (g_nemesis[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_NEMESIS")
						else if (g_assassin[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_ASSASSIN")
						else if (g_alien[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_ALIEN")
						else
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_ZOMBIE")
					}
				}
				else
				{
					if (allowed_zombie(player) && (iFlags & CREADOR))
					{
						if (g_survivor[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_SURVIVOR")
						else if (g_sniper[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_SNIPER")
						else if (g_wesker[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_WESKER")
						else if (g_depre[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_DEPRE")
						else
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_HUMAN")
					}
					else
					{
						if (g_survivor[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_SURVIVOR")
						else if (g_sniper[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_SNIPER")
						else if (g_wesker[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_WESKER")
						else if (g_depre[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_DEPRE")
						else if (g_ninja[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_NINJA")
						else
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_HUMAN")
					}
				}
			}
			case ACTION_MAKE_NEMESIS: // Nemesis command
			{
				if (allowed_nemesis(player) && (iFlags & CREADOR))
				{
					if (g_zombie[player])
					{
						if (g_nemesis[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_NEMESIS")
						else if (g_assassin[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_ASSASSIN")
						else if (g_alien[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_ALIEN")
						else
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_ZOMBIE")
					}
					else
					{
						if (g_survivor[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_SURVIVOR")
						else if (g_sniper[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_SNIPER")
						else if (g_wesker[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_WESKER")
						else if (g_depre[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_DEPRE")
						else if (g_ninja[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_NINJA")
						else
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_HUMAN")
					}
				}
				else
				{
					if (g_zombie[player])
					{
						if (g_nemesis[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_NEMESIS")
						else if (g_assassin[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_ASSASSIN")
						else if (g_alien[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_ALIEN")
						else
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_ZOMBIE")
					}
					else
					{
						if (g_survivor[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_SURVIVOR")
						else if (g_sniper[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_SNIPER")
						else if (g_wesker[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_WESKER")
						else if (g_depre[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_DEPRE")
						else if (g_ninja[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_NINJA")
						else
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_HUMAN")
					}
				}
			}
			case ACTION_MAKE_SURVIVOR: // Survivor command
			{
				if (allowed_survivor(player) && (iFlags & CREADOR))
				{
					if (g_zombie[player])
					{
						if (g_nemesis[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_NEMESIS")
						else if (g_assassin[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_ASSASSIN")
						else if (g_alien[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_ALIEN")
						else
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_ZOMBIE")
					}
					else
					{
						if (g_survivor[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_SURVIVOR")
						else if (g_sniper[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_SNIPER")
						else if (g_wesker[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_WESKER")
						else if (g_depre[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_DEPRE")
						else if (g_ninja[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_NINJA")
						else
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_HUMAN")
					}
				}
				else
				{
					if (g_zombie[player])
					{
						if (g_nemesis[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_NEMESIS")
						else if (g_assassin[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_ASSASSIN")
						else if (g_alien[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_ALIEN")
						else
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_ZOMBIE")
					}
					else
					{
						if (g_survivor[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_SURVIVOR")
						else if (g_sniper[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_SNIPER")
						else if (g_wesker[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_WESKER")
						else if (g_depre[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_DEPRE")
						else if (g_ninja[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_NINJA")
						else
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_HUMAN")
					}
				}
			}
			case ACTION_MAKE_SNIPER: // Sniper command
			{
				if (allowed_sniper(player) && (iFlags & CREADOR))
				{
					if (g_zombie[player])
					{
						if (g_nemesis[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_NEMESIS")
						else if (g_assassin[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_ASSASSIN")
						else if (g_alien[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_ALIEN")
						else
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_ZOMBIE")
					}
					else
					{
						if (g_survivor[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_SURVIVOR")
						else if (g_sniper[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_SNIPER")
						else if (g_wesker[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_WESKER")
						else if (g_depre[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_DEPRE")
						else if (g_ninja[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_NINJA")
						else
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_HUMAN")
					}
				}
				else
				{
					if (g_zombie[player])
					{
						if (g_nemesis[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_NEMESIS")
						else if (g_assassin[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_ASSASSIN")
						else if (g_alien[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_ALIEN")
						else
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_ZOMBIE")
					}
					else
					{
						if (g_survivor[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_SURVIVOR")
						else if (g_sniper[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_SNIPER")
						else if (g_wesker[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_WESKER")
						else if (g_depre[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_DEPRE")
						else if (g_ninja[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_NINJA")
						else
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_HUMAN")
					}
				}
			}
			case ACTION_MAKE_WESKER: // Wesker command
			{
				if (allowed_wesker(player) && (iFlags & CREADOR && !g_newround ||  (iFlags & CREADOR && g_newround && iPlayersnum >= get_pcvar_num(cvar_weskerminplayers))))
				{
					if (g_zombie[player])
					{
						if (g_nemesis[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_NEMESIS")
						else if (g_assassin[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_ASSASSIN")
						else if (g_alien[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_ALIEN")
						else
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_ZOMBIE")
					}
					else
					{
						if (g_survivor[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_SURVIVOR")
						else if (g_wesker[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_WESKER")
						else if (g_depre[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_DEPRE")
						else if (g_ninja[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_NINJA")
						else if (g_sniper[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_SNIPER")
						else
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_HUMAN")
					}
				}
				else
				{
					if (g_zombie[player])
					{
						if (g_nemesis[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_NEMESIS")
						else if (g_assassin[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_ASSASSIN")
						else if (g_alien[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_ALIEN")
						else
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_ZOMBIE")
					}
					else
					{
						if (g_survivor[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_SURVIVOR")
						else if (g_wesker[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_WESKER")
						else if (g_depre[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_DEPRE")
						else if (g_ninja[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_NINJA")
						else if (g_sniper[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_SNIPER")
						else
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_HUMAN")
					}
				}
			}
			case ACTION_MAKE_DEPRE: // Depredador command
			{
				if (allowed_depre(player) && (iFlags & CREADOR))
				{
					if (g_zombie[player])
					{
						if (g_nemesis[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_NEMESIS")
						else if (g_assassin[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_ASSASSIN")
						else if (g_alien[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_ALIEN")
						else
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_ZOMBIE")
					}
					else
					{
						if (g_survivor[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_SURVIVOR")
						else if (g_depre[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_DEPRE")
						else if (g_ninja[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_NINJA")
						else if (g_wesker[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_WESKER")
						else if (g_sniper[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_SNIPER")
						else
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_HUMAN")
					}
				}
				else
				{
					if (g_zombie[player])
					{
						if (g_nemesis[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_NEMESIS")
						else if (g_assassin[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_ASSASSIN")
						else if (g_alien[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_ALIEN")
						else
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_ZOMBIE")
					}
					else
					{
						if (g_survivor[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_SURVIVOR")
						else if (g_depre[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_DEPRE")
						else if (g_ninja[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_NINJA")
						else if (g_wesker[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_WESKER")
						else if (g_sniper[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_SNIPER")
						else
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_HUMAN")
					}
				}
			}
			case ACTION_MAKE_ASSASSIN: // Assassin command
			{
				if (allowed_assassin(player) && (iFlags & CREADOR))
				{
					if (g_zombie[player])
					{
						if (g_nemesis[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_NEMESIS")
						else if (g_assassin[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_ASSASSIN")
						else if (g_alien[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_ALIEN")
						else
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_ZOMBIE")
					}
					else
					{
						if (g_survivor[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_SURVIVOR")
						else if (g_sniper[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_SNIPER")
						else if (g_wesker[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_WESKER")
						else if (g_depre[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_DEPRE")
						else if (g_ninja[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_NINJA")
						else
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_HUMAN")
					}
				}
				else
				{
					if (g_zombie[player])
					{
						if (g_nemesis[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_NEMESIS")
						else if (g_assassin[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_ASSASSIN")
						else if (g_alien[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_ALIEN")
						else
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_ZOMBIE")
					}
					else
					{
						if (g_survivor[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_SURVIVOR")
						else if (g_sniper[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_SNIPER")
						else if (g_wesker[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_WESKER")
						else if (g_depre[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_DEPRE")
						else if (g_ninja[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_NINJA")
						else
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_HUMAN")
					}
				}
			}
			case ACTION_MAKE_ALIEN: // Alien command
			{
				if (allowed_alien(player) && (iFlags & VIP || iFlags & ADMIN || iFlags & CREADOR))
				{
					if (g_zombie[player])
					{
						if (g_nemesis[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_NEMESIS")
						else if (g_alien[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_ALIEN")
						else if (g_assassin[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_ASSASSIN")
						else
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_ZOMBIE")
					}
					else
					{
						if (g_survivor[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_SURVIVOR")
						else if (g_sniper[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_SNIPER")
						else if (g_wesker[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_WESKER")
						else if (g_depre[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_DEPRE")
						else if (g_ninja[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_NINJA")
						else
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_HUMAN")
					}
				}
				else
				{
					if (g_zombie[player])
					{
						if (g_nemesis[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_NEMESIS")
						else if (g_alien[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_ALIEN")
						else if (g_assassin[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_ASSASSIN")
						else
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_ZOMBIE")
					}
					else
					{
						if (g_survivor[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_SURVIVOR")
						else if (g_sniper[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_SNIPER")
						else if (g_wesker[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_WESKER")
						else if (g_depre[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_DEPRE")
						else if (g_ninja[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_NINJA")
						else
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_HUMAN")
					}
				}
			}
			case ACTION_MAKE_NINJA: // Ninja command
			{
				if (allowed_ninja(player) && (iFlags & CREADOR))
				{
					if (g_zombie[player])
					{
						if (g_nemesis[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_NEMESIS")
						else if (g_assassin[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_ASSASSIN")
						else if (g_alien[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_ALIEN")
						else
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_ZOMBIE")
					}
					else
					{
						if (g_survivor[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_SURVIVOR")
						else if (g_ninja[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_NINJA")
						else if (g_depre[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_DEPRE")
						else if (g_wesker[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_WESKER")
						else if (g_sniper[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_SNIPER")
						else
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_HUMAN")
					}
				}
				else
				{
					if (g_zombie[player])
					{
						if (g_nemesis[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_NEMESIS")
						else if (g_assassin[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_ASSASSIN")
						else if (g_alien[player])
							formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, "CLASS_ALIEN")
						else
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_ZOMBIE")
					}
					else
					{
						if (g_survivor[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_SURVIVOR")
						else if (g_ninja[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_NINJA")
						else if (g_depre[player])
							formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, "CLASS_DEPRE")
						else if (g_wesker[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_WESKER")
						else if (g_sniper[player])
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_SNIPER")
						else
							formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, "CLASS_HUMAN")
					}
				}
			}
			case ACTION_RESPAWN_PLAYER: // Respawn command
			{
				if (allowed_respawn(player) && (iFlags & VIP || iFlags & ADMIN || iFlags & CREADOR))
					formatex(menu, charsmax(menu), "%s", g_playername[player])
				else
					formatex(menu, charsmax(menu), "\d%s", g_playername[player])
			}
		}
		
		// Add player
		buffer[0] = player
		buffer[1] = 0
		menu_additem(menuid, menu, buffer)
	}
	
	// Back - Next - Exit
	formatex(menu, charsmax(menu), "Atras")
	menu_setprop(menuid, MPROP_BACKNAME, menu)
	formatex(menu, charsmax(menu), "Siguiente")
	menu_setprop(menuid, MPROP_NEXTNAME, menu)
	formatex(menu, charsmax(menu), "Salir")
	menu_setprop(menuid, MPROP_EXITNAME, menu)
	
	// If remembered page is greater than number of pages, clamp down the value
	MENU_PAGE_PLAYERS = min(MENU_PAGE_PLAYERS, menu_pages(menuid)-1)
	
	// Fix for AMXX custom menus
	if (pev_valid(id) == PDATA_SAFE)
		set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX)
	
	menu_display(id, menuid, MENU_PAGE_PLAYERS)
}

/*================================================================================
 [Menu Handlers]
=================================================================================*/

// Game Menu
public Menu_Principal_Juego_Cases(id, key)
{
	iFlags = get_user_flags(id)
	switch (key)
	{
		case 0: // Buy Weapons
		{
			if (is_human(id))
				Menu_Seleccion_Armas(id)
		}
		case 1: // Extra Items
		{
			if (g_isalive[id])
			{
				if(!g_newround)
				{
					if(g_zombie[id])
						Menu_Extra_Items_Zombies(id)
					else
						Menu_Extra_Items_Humanos(id)
				}
				else
				{
					zp_colored_print(id, "%s Espera A Que Salga Algun Modo Para Comprar", TAG)
				}
			}
			else
			{
				Menu_Principal_Juego(id)
				zp_colored_print(id, "%s %L", TAG, id, "CMD_NOT")
			}
		}
		case 2: // Zombie Classes
		{
			if(!is_user_admin(id))
			{
				if(g_classcounter[id] >= 1)
				{
					zp_colored_print(id, "%s Se Puede Elegir^x04 Clase de Zombie^x03 Solo Una Vez Por Ronda.", TAG)
					Menu_Principal_Juego(id)
				}
				else if(g_classcounter[id] < 1)
				{
					Menu_Clases_Zombies(id)
				}
			}
			else
			{
				Menu_Clases_Zombies(id)
			}
		}
		case 3: // Human Classes
		{
			if(!is_user_admin(id))
			{
				if(g_classcounter2[id] >= 1)
				{
					zp_colored_print(id, "%s Se Puede Elegir^x04 Clase^x03 Solo Una Vez Por Ronda.", TAG)
					Menu_Principal_Juego(id)
				}
				else if(g_classcounter2[id] < 1)
				{
					Menu_Habilidades(id)
				}
			}
			else
			{
				Menu_Habilidades(id)
			}
		}
		case 4: // Unstuck
		{
			// Check if player is stuck
			if (g_isalive[id])
			{
				if (is_player_stuck(id))
				{
					// Move to an initial spawn
					if (get_pcvar_num(cvar_randspawn))
						do_random_spawn(id) // random spawn (including CSDM)
					else
						do_random_spawn(id, 1) // regular spawn
				/*}
				else
				{*/
					//Menu_Principal_Juego(id)
					//zp_colored_print(id, "%s %L", TAG, id, "CMD_NOT_STUCK")
				}
				
			}
			else
			{
				Menu_Principal_Juego(id)
				zp_colored_print(id, "%s %L", TAG, id, "CMD_NOT")
			}
		}
		case 5: // Join Spectator
		{
			// Player alive?
			if (g_isalive[id])
			{
				// Prevent abuse by non-admins if block suicide setting is enabled
				if (!(iFlags & ADMIN || iFlags & CREADOR))
				{
					Menu_Principal_Juego(id)
					zp_colored_print(id, "%s %L", TAG, id, "CMD_NOT")
					return PLUGIN_HANDLED;
				}
				check_round(id)
				
				// Kill him before he switches team
				dllfunc(DLLFunc_ClientKill, id)
			}
			save_stats(id)
			// Remove previous tasks
			remove_task(id+TASK_TEAM)
			remove_task(id+TASK_FLASH)
			remove_task(id+TASK_CHARGE)
			remove_task(id+TASK_SPAWN)
			remove_task(id+TASK_BLOOD)
			remove_task(id+TASK_AURA)
			remove_task(id+TASK_PARTICULAS)
			remove_task(id+TASK_BURN)
			
			fm_cs_set_user_team(id, FM_CS_TEAM_SPECTATOR)
			fm_user_team_update(id)
		}
		case 6: Menu_Informacion(id)
		case 7: Menu_Perfil(id)
		case 8: // Admin Menu
		{
			// Check if player has the required access
			if (iFlags & VIP || iFlags & ADMIN || iFlags & CREADOR) Menu_Admin0(id)
			else zp_colored_print(id, "%s %L", TAG, id, "CMD_NOT_ACCESS")
		}
	}
	
	return PLUGIN_HANDLED;
}


// Zombie Class Menu
public Menu_Clases_Zombies_Cases(id, menuid, item)
{
	// Player disconnected?
	if (!g_isconnected[id])
	{
		menu_destroy(menuid)
		return PLUGIN_HANDLED;
	}
	
	// Remember player's menu page
	static menudummy
	player_menu_info(id, menudummy, menudummy, MENU_PAGE_ZCLASS)
	
	// Menu was closed
	if (item == MENU_EXIT)
	{
		Menu_Principal_Juego(id)
		menu_destroy(menuid)
		return PLUGIN_HANDLED;
	}
	
	
	// Retrieve zombie class id
	static buffer[2], dummy, classid
	menu_item_getinfo(menuid, item, dummy, buffer, charsmax(buffer), _, _, dummy)
	classid = buffer[0]
	
	g_zombieclassnext[id] = classid
	
	zp_colored_print(id, "%s %L:^x04 %s^x01", TAG, id, "ZOMBIE_SELECT", g_zclass_name[g_zombieclassnext[id]])
	zp_colored_print(id, "%s Vida:^x04 %d^x01 Velocidad:^x04 %d^x01 Gravedad:^x04 %d^x01 Afectado por Balas en un^x04 %d%%^x01", TAG, g_zclass_hp[g_zombieclassnext[id]], 
	g_zclass_spd[g_zombieclassnext[id]], floatround(g_zclass_grav[g_zombieclassnext[id]]*800), floatround(g_zclass_kb[g_zombieclassnext[id]]*100.0))
	
	g_classcounter[id]++
	Menu_Principal_Juego(id)
	menu_destroy(menuid)
	return PLUGIN_HANDLED;
}

// Admin Menu
public Menu_Admin1_Cases(id, menu, item)
{
	// Player disconnected?
	if (!g_isconnected[id])
	{
		menu_destroy(menu)
		return PLUGIN_HANDLED;
	}
	
	// Remember player's menu page
	static menudummy
	player_menu_info(id, menudummy, menudummy, MENU_PAGE_ADMIN1)
	
	// Menu was closed
	if (item == MENU_EXIT)
	{
		Menu_Admin0(id)
		menu_destroy(menu)
		return PLUGIN_HANDLED;
	}
	if (!g_modcount[id])
	{
		zp_colored_print(id, "%s Agotaste el maximo de modos que puedes enviar.", TAG)
		return PLUGIN_HANDLED
	}
	if (g_modenabled[id])
	{
		zp_colored_print(id, "%s Tienes que esperar^x04 %d^x01 rondas para volver a tirar un modo.", TAG, g_modenabled[id])
		return PLUGIN_HANDLED
	}
	
	iFlags = get_user_flags(id)
	
	new data[6], iName[64], access, callback;
	menu_item_getinfo(menu, item, access, data,5, iName, 63, callback);
    
	new key = str_to_num(data)
	static iPlayersnum
	iPlayersnum = fnGetAlive()	
	switch (key)
	{
		case ACTION_ZOMBIEFY_HUMANIZE: // Zombiefy/Humanize command
		{
			if (iFlags & CREADOR)
			{
				// Show player list for admin to pick a target
				PL_ACTION = ACTION_ZOMBIEFY_HUMANIZE
				Menu_Lista_Players(id)
			}
			else
			{
				zp_colored_print(id, "%s %L", TAG, id, "CMD_NOT_ACCESS")
				Menu_Admin1(id)
			}
		}
		case ACTION_MAKE_NEMESIS: // Nemesis command
		{
			if (iFlags & CREADOR)
			{
				// Show player list for admin to pick a target
				PL_ACTION = ACTION_MAKE_NEMESIS
				Menu_Lista_Players(id)
			}
			else
			{
				zp_colored_print(id, "%s %L", TAG, id, "CMD_NOT_ACCESS")
				Menu_Admin1(id)
			}
		}
		case ACTION_MAKE_SURVIVOR: // Survivor command
		{
			if (iFlags & CREADOR)
			{
				// Show player list for admin to pick a target
				PL_ACTION = ACTION_MAKE_SURVIVOR
				Menu_Lista_Players(id)
			}
			else
			{
				zp_colored_print(id, "%s %L", TAG, id, "CMD_NOT_ACCESS")
				Menu_Admin1(id)
			}
		}
		case ACTION_MAKE_SNIPER: // Sniper command
		{
			if (iFlags & CREADOR)
			{
				// Show player list for admin to pick a target
				PL_ACTION = ACTION_MAKE_SNIPER
				Menu_Lista_Players(id)
			}
			else
			{
				zp_colored_print(id, "%s %L", TAG, id, "CMD_NOT_ACCESS")
				Menu_Admin1(id)
			}
		}
		case ACTION_MAKE_WESKER: // Wesker command
		{
			if (iFlags & CREADOR && !g_newround ||  (iFlags & CREADOR && g_newround && iPlayersnum >= get_pcvar_num(cvar_weskerminplayers)))
			{
				// Show player list for admin to pick a target
				PL_ACTION = ACTION_MAKE_WESKER
				Menu_Lista_Players(id)
			}
			else
			{
				zp_colored_print(id, "%s %L", TAG, id, "CMD_NOT_ACCESS")
				Menu_Admin1(id)
			}
		}
		case ACTION_MAKE_DEPRE: // Depredador command
		{
			if (iFlags & CREADOR)
			{
				// Show player list for admin to pick a target
				PL_ACTION = ACTION_MAKE_DEPRE
				Menu_Lista_Players(id)
			}
			else
			{
				zp_colored_print(id, "%s %L", TAG, id, "CMD_NOT_ACCESS")
				Menu_Admin1(id)
			}
		}
		case ACTION_MAKE_ASSASSIN: // Assassin command
		{
			if (iFlags & CREADOR)
			{
				// Show player list for admin to pick a target
				PL_ACTION = ACTION_MAKE_ASSASSIN
				Menu_Lista_Players(id)
			}
			else
			{
				zp_colored_print(id, "%s %L", TAG, id, "CMD_NOT_ACCESS")
				Menu_Admin1(id)
			}
		}
		case ACTION_MAKE_ALIEN: // Alien command
		{
			if (iFlags & VIP || iFlags & ADMIN || iFlags & CREADOR)
			{
				// Show player list for admin to pick a target
				if(g_newround)
				{
					if(g_modcount[id])
					{
						if(!g_modenabled[id])
						{
							if(fnGetAlive() >= get_pcvar_num(cvar_alienminplayers))
							{
								remove_task(TASK_MAKEZOMBIE)
								make_a_zombie(MODE_ALIEN, fnGetRandomAlive(random_num(1, fnGetAlive())))	
								g_modcount[id]--
								g_modenabled[id] = 3
								zp_colored_print(0, "%s^x03 %s^x01 a comenzado el^x04 Modo Alien^x01.", TAG, g_playername[id])
							}
							else
							{
								zp_colored_print(id, "%s^x03 Para comenzar la ronda Alien se necesitan^x04 minimo^x01 %d^x04 jugadores^x01.", TAG, get_pcvar_num(cvar_alienminplayers))
							}
						}
						else
						{
							zp_colored_print(id, "%s Tienes que esperar^x04 %d^x01 rondas para volver a tirar un modo.", TAG, g_modenabled[id])
						}
					}
					else
					{
						zp_colored_print(id, "%s^x04 Ya lanzaste todos los modos que tienes por mapa... Espera el proximo mapa^x01.", TAG)
					}
				}
				else
				{
					if(!(iFlags & CREADOR))
					{
						zp_colored_print(id, "%s %L", TAG, id, "CMD_NOT_ACCESS")
					}
					else
					{
						PL_ACTION = ACTION_MAKE_ALIEN
						Menu_Lista_Players(id)						
					}
				}
			}
			else
			{
				zp_colored_print(id, "%s %L", TAG, id, "CMD_NOT_ACCESS")
				Menu_Admin1(id)
			}
		}
		case ACTION_MAKE_NINJA: // Ninja command
		{
			if (iFlags & CREADOR)
			{
				// Show player list for admin to pick a target
				PL_ACTION = ACTION_MAKE_NINJA
				Menu_Lista_Players(id)
			}
			else
			{
				zp_colored_print(id, "%s %L", TAG, id, "CMD_NOT_ACCESS")
				Menu_Admin1(id)
			}
		}
		case ACTION_RESPAWN_PLAYER: // Respawn command
		{
			if (iFlags & ADMIN || iFlags & CREADOR)
			{
				PL_ACTION = ACTION_RESPAWN_PLAYER
				Menu_Lista_Players(id)
			}
			else
			{
				zp_colored_print(id, "%s Para revivir jugadores tienes que ser^x03 Moderador o Creador^x01.", TAG)
				Menu_Admin1(id)
			}
		}
	}
	return PLUGIN_HANDLED;
}

public Menu_Admin2_Cases(id, menu, item)
{
	// Player disconnected?
	if (!g_isconnected[id])
	{
		menu_destroy(menu)
		return PLUGIN_HANDLED;
	}
	
	if (!g_modcount[id])
	{
		zp_colored_print(id, "%s Agotaste el maximo de modos que puedes enviar.", TAG)
		return PLUGIN_HANDLED
	}
	if (g_modenabled[id])
	{
		zp_colored_print(id, "%s Tienes que esperar^x04 %d^x01 rondas para volver a tirar un modo.", TAG, g_modenabled[id])
		return PLUGIN_HANDLED
	}
	
	// Remember player's menu page
	static menudummy
	player_menu_info(id, menudummy, menudummy, MENU_PAGE_ADMIN2)
	// Menu was closed
	if (item == MENU_EXIT)
	{
		Menu_Admin0(id)
		menu_destroy(menu)
		return PLUGIN_HANDLED;
	}
	
	iFlags = get_user_flags(id)
	
	static iPlayersnum
	iPlayersnum = fnGetAlive()
	
	new data[6], iName[64], access, callback;
	menu_item_getinfo(menu, item, access, data,5, iName, 63, callback);
    
	new key = str_to_num(data)
	switch (key)
	{
		case 0: // Multiple Infection command
		{
			if (iFlags & VIP || iFlags & ADMIN || iFlags & CREADOR)
			{
				if(iPlayersnum >= get_pcvar_num(cvar_multiminplayers))
				{
					if (allowed_multi())
					{
						command_multi(id)
						g_modcount[id]--
						g_modenabled[id] = 3
					}
					else
						zp_colored_print(id, "%s %L", TAG, id, "CMD_NOT")
				}
				else
					zp_colored_print(id, "%s Tienen Que Haber Un^x04 Minimo de %d Jugadores^x01 Para Iniciar El^x03 Modo Multi-Infeccion", TAG, get_pcvar_num(cvar_multiminplayers))	
			}
			else
				zp_colored_print(id, "%s %L", TAG, id, "CMD_NOT_ACCESS")
			
			Menu_Admin2(id)
		}
		case 1: // Swarm Mode command
		{
			if (iFlags & VIP || iFlags & ADMIN || iFlags & CREADOR)
			{
				if(iPlayersnum >= get_pcvar_num(cvar_swarmminplayers))
				{
					if (allowed_swarm())
					{
						command_swarm(id)
						g_modcount[id]--
						g_modenabled[id] = 3
					}
					else
						zp_colored_print(id, "%s %L", TAG, id, "CMD_NOT")
				}
				else
					zp_colored_print(id, "%s Tienen Que Haber Un^x04 Minimo de %d Jugadores^x01 Para Iniciar El^x03 Modo Swarm", TAG, get_pcvar_num(cvar_swarmminplayers))	
			}
			else
				zp_colored_print(id, "%s %L", TAG, id, "CMD_NOT_ACCESS")
			
			Menu_Admin2(id)
		}
		case 2: // Plague Mode command
		{
			if (iFlags & VIP || iFlags & ADMIN || iFlags & CREADOR)
			{
				if(iPlayersnum >= get_pcvar_num(cvar_plagueminplayers))
				{
					if (allowed_plague())
					{
						command_plague(id)
						g_modcount[id]--
						g_modenabled[id] = 3
					}
					else
						zp_colored_print(id, "%s %L", TAG, id, "CMD_NOT")
				}
				else
					zp_colored_print(id, "%s Tienen Que Haber Un^x04 Minimo de %d Jugadores^x01 Para Iniciar El^x03 Modo Plague", TAG, get_pcvar_num(cvar_plagueminplayers))	
			}
			else
				zp_colored_print(id, "%s %L", TAG, id, "CMD_NOT_ACCESS")
			
			Menu_Admin2(id)
		}
		case 3: // Armageddon Mode command
		{
			if (iFlags & VIP || iFlags & ADMIN || iFlags & CREADOR)
			{
				if(iPlayersnum >= get_pcvar_num(cvar_lnjminplayers))
				{
					if (allowed_lnj())
					{
						command_lnj(id)
						g_modcount[id]--
						g_modenabled[id] = 3
					}
					else
						zp_colored_print(id, "%s %L", TAG, id, "CMD_NOT")
				}
				else
					zp_colored_print(id, "%s Tienen Que Haber Un^x04 Minimo de %d Jugadores^x01 Para Iniciar El^x03 Modo Nemesis vs Survivors", TAG, get_pcvar_num(cvar_lnjminplayers))	
			}
			else
				zp_colored_print(id, "%s %L", TAG, id, "CMD_NOT_ACCESS")
			
			Menu_Admin2(id)
		}
		case 4: // Tournament Mode command
		{
			if (iFlags & VIP || iFlags & ADMIN || iFlags & CREADOR)
			{
				if(iPlayersnum >= get_pcvar_num(cvar_torneominplayers))
				{
					if (allowed_torneo())
					{
						command_torneo(id)
						g_modcount[id]--
						g_modenabled[id] = 3
					}
					else
						zp_colored_print(id, "%s %L", TAG, id, "CMD_NOT")
				}
				else
					zp_colored_print(id, "%s Tienen Que Haber Un^x04 Minimo de %d Jugadores^x01 Para Iniciar El^x03 Modo Torneo", TAG, get_pcvar_num(cvar_torneominplayers))	
			}
			else
				zp_colored_print(id, "%s %L", TAG, id, "CMD_NOT_ACCESS")
			
			Menu_Admin2(id)
		}
		case 5: // Synapsis Mode command
		{
			if (iFlags & VIP || iFlags & ADMIN || iFlags & CREADOR)
			{
				if(iPlayersnum >= get_pcvar_num(cvar_synapsisminplayers))
				{
					if (allowed_synapsis())
					{
						command_synapsis(id)
						g_modcount[id]--
						g_modenabled[id] = 3
					}
					else
						zp_colored_print(id, "%s %L", TAG, id, "CMD_NOT")
				}
				else
					zp_colored_print(id, "%s Tienen Que Haber Un^x04 Minimo de %d Jugadores^x01 Para Iniciar El^x03 Modo Synapsis", TAG, get_pcvar_num(cvar_synapsisminplayers))	
			}
			else
				zp_colored_print(id, "%s %L", TAG, id, "CMD_NOT_ACCESS")
			
			Menu_Admin2(id)
		}
		case 6: // L4D Mode command
		{
			if (iFlags & VIP || iFlags & ADMIN || iFlags & CREADOR)
			{
				if(iPlayersnum >= get_pcvar_num(cvar_l4dminplayers))
				{
					if (allowed_l4d())
					{
						command_l4d(id)
						g_modcount[id]--
						g_modenabled[id] = 3
					}
					else
						zp_colored_print(id, "%s %L", TAG, id, "CMD_NOT")
				}
				else
					zp_colored_print(id, "%s Tienen Que Haber Un^x04 Minimo de %d Jugadores^x01 Para Iniciar El^x03 Modo Left 4 Dead", TAG, get_pcvar_num(cvar_l4dminplayers))	
			}
			else
				zp_colored_print(id, "%s %L", TAG, id, "CMD_NOT_ACCESS")
			
			Menu_Admin2(id)
		}
	}
	return PLUGIN_HANDLED;
}

public Menu_Admin0_Cases(id, menu, item)
{
	// Player disconnected?
	if (!g_isconnected[id])
	{
		menu_destroy(menu)
		return PLUGIN_HANDLED;
	}
	
	// Remember player's menu page
	static menudummy
	player_menu_info(id, menudummy, menudummy, MENU_PAGE_ADMIN0)
	
	// Menu was closed
	if (item == MENU_EXIT)
	{
		Menu_Principal_Juego(id)
		menu_destroy(menu)
		return PLUGIN_HANDLED;
	}
	
	iFlags = get_user_flags(id)
	
	new data[6], iName[64], access, callback;
	menu_item_getinfo(menu, item, access, data,5, iName, 63, callback);
    
	new key = str_to_num(data)
	switch (key)
	{
		case 0:
		{
			if (iFlags & VIP || iFlags & ADMIN || iFlags & CREADOR)
				Menu_Admin1(id)
			else
				zp_colored_print(id, "%s %L", TAG, id, "CMD_NOT_ACCESS")
		}
		case 1:
		{
			if (iFlags & VIP || iFlags & ADMIN || iFlags & CREADOR)
				Menu_Admin2(id)
			else
				zp_colored_print(id, "%s %L", TAG, id, "CMD_NOT_ACCESS")
		}
		case 2:
		{
			if (iFlags & VIP || iFlags & ADMIN || iFlags & CREADOR)
				show_menu_game_mode(id)
			else
				zp_colored_print(id, "%s %L", TAG, id, "CMD_NOT_ACCESS")
			
		}
		case 3:
		{
			if (iFlags & ADMIN || iFlags & CREADOR)
				menu_admin(id)
			else
				zp_colored_print(id, "%s %L", TAG, id, "CMD_NOT_ACCESS")
		}
			
	}
	return PLUGIN_HANDLED;
}
// Player List Menu
public Menu_Lista_Players_Cases(id, menuid, item)
{
	// Player disconnected?
	if (!g_isconnected[id])
	{
		menu_destroy(menuid)
		return PLUGIN_HANDLED;
	}
	
	// Remember player's menu page
	static menudummy
	player_menu_info(id, menudummy, menudummy, MENU_PAGE_PLAYERS)
	
	// Menu was closed
	if (item == MENU_EXIT)
	{
		menu_destroy(menuid)
		Menu_Admin1(id)
		return PLUGIN_HANDLED;
	}
	
	// Retrieve player id
	static buffer[2], dummy, playerid
	menu_item_getinfo(menuid, item, dummy, buffer, charsmax(buffer), _, _, dummy)
	playerid = buffer[0]
	
	// Perform action on player
	
	// Get admin flags
	iFlags = get_user_flags(id)
	static iPlayersnum
	iPlayersnum = fnGetAlive()	
	// Make sure it's still connected
	if (g_isconnected[playerid])
	{
		// Perform the right action if allowed
		switch (PL_ACTION)
		{
			case ACTION_ZOMBIEFY_HUMANIZE: // Zombiefy/Humanize command
			{
				if (g_zombie[playerid])
				{
					if (allowed_human(playerid))
						command_human(id, playerid)
					else
						zp_colored_print(id, "%s %L", TAG, id, "CMD_NOT")
				}
				else
				{
					if (allowed_zombie(playerid))
						command_zombie(id, playerid)
					else
						zp_colored_print(id, "%s %L", TAG, id, "CMD_NOT")
				}
			}
			case ACTION_MAKE_NEMESIS: // Nemesis command
			{
				if (allowed_nemesis(playerid))
					command_nemesis(id, playerid)
				else
					zp_colored_print(id, "%s %L", TAG, id, "CMD_NOT")

			}
			case ACTION_MAKE_SURVIVOR: // Survivor command
			{
				if (allowed_survivor(playerid))
					command_survivor(id, playerid)
				else
					zp_colored_print(id, "%s %L", TAG, id, "CMD_NOT")
			}
			case ACTION_MAKE_SNIPER: // Sniper command
			{
				if (allowed_sniper(playerid))
					command_sniper(id, playerid)
				else
					zp_colored_print(id, "%s %L", TAG, id, "CMD_NOT")
			}
			case ACTION_MAKE_WESKER: // Wesker command
			{
				if (allowed_wesker(playerid))
				{
					if(!g_newround ||  g_newround && iPlayersnum >= get_pcvar_num(cvar_weskerminplayers))
						command_wesker(id, playerid)
					else
						zp_colored_print(id, "%s Para comenzar el^x04 Modo Wesker^x01 deben haber minimo^x04 %d^x01 Jugadores^x04.", TAG, get_pcvar_num(cvar_weskerminplayers))
				}
				else
					zp_colored_print(id, "%s %L", TAG, id, "CMD_NOT")
			}
			case ACTION_MAKE_DEPRE: // Depredador command
			{
				if (allowed_depre(playerid))
					command_depre(id, playerid)
				else
					zp_colored_print(id, "%s %L", TAG, id, "CMD_NOT")
			}
			case ACTION_MAKE_ASSASSIN: // Assassin command
			{
				if (allowed_assassin(playerid))
					command_assassin(id, playerid)
				else
					zp_colored_print(id, "%s %L", TAG, id, "CMD_NOT")
			}
			case ACTION_MAKE_ALIEN: // Assassin command
			{
				if (allowed_alien(playerid))
					command_alien(id, playerid)
				else
					zp_colored_print(id, "%s %L", TAG, id, "CMD_NOT")
			}
			case ACTION_MAKE_NINJA: // Ninja command
			{
				if (allowed_ninja(playerid))
					command_ninja(id, playerid)
				else
					zp_colored_print(id, "%s %L", TAG, id, "CMD_NOT")
			}
			case ACTION_RESPAWN_PLAYER: // Respawn command
			{
				if (allowed_respawn(playerid))
					command_respawn(id, playerid)
				else
					zp_colored_print(id, "%s %L", TAG, id, "CMD_NOT")
			}
		}
	}
	else
		zp_colored_print(id, "%s %L", TAG, id, "CMD_NOT")
	
	menu_destroy(menuid)
	Menu_Lista_Players(id)
	return PLUGIN_HANDLED;
}


/*================================================================================
 [Admin Commands]
=================================================================================*/

public CmdGiveRT (id, level, cid)  
{  
	if (!cmd_access (id, level, cid, 3))
		return PLUGIN_HANDLED;
		
	new s_Name[32], s_Amount[9];
	read_argv (1, s_Name, charsmax (s_Name));
	read_argv (2, s_Amount, charsmax (s_Amount)); 
	
	new i_Target = cmd_target (id, s_Name, 2); 
	
	if (!i_Target)
	{
		client_print (id, print_console, "%s Jugador no encontrado para dar Resets", TAG);
		return PLUGIN_HANDLED;
	}	
	
	zp_colored_print(i_Target, "%s El ADMIN %s Te Dio^x04 %d Resets", TAG, g_playername[id], str_to_num(s_Amount))
	g_reset[i_Target] += max (1, str_to_num (s_Amount));
	
	// Log to Zombie Plague log file?
	if (get_pcvar_num(cvar_logcommands))
	{
		static logdata[100], authid[32], ip[16]
		get_user_authid(id, authid, charsmax(authid))
		get_user_ip(id, ip, charsmax(ip), 1)
		formatex(logdata, charsmax(logdata), "El ADMIN %s <%s><%s> - Le Dio %d Resets a %s", g_playername[id], authid, ip, str_to_num(s_Amount), g_playername[i_Target])
		log_to_file("dar_atributos.log", logdata)
	}

	return PLUGIN_HANDLED; 
}


public CmdFormatear(id, level, cid)  
{  
	if (!cmd_access (id, level, cid, 3))
		return PLUGIN_HANDLED;
		
	new s_Name[32], s_Amount[9], ip[16], iLen, sz_Texto[1000]
	
	read_argv (1, s_Name, charsmax (s_Name));
	read_argv (2, s_Amount, charsmax (s_Amount));
	new amount = str_to_num(s_Amount)
	
	if(amount)
	{
		new i_Target = cmd_target (id, s_Name, 2); 
		
		if(!i_Target)
		{
			zp_colored_print(id, "%s^x04 Jugador no encontrado", TAG)
			return PLUGIN_HANDLED
		}
		if(get_pcvar_num(gCvarsPlugin[CUENTAS_GUARDAR][gCvarValor]))
		{
			iLen = 0;
			
			iLen += formatex(sz_Texto[iLen], charsmax(sz_Texto) - iLen, "UPDATE `%s` SET `Password` = ^"cuenta_baneada_galaxy^" WHERE Nombre = ^"%s^";", TABLA, g_playername[i_Target])
			SQL_ThreadQuery(g_sqltuple, "QuerySetData", sz_Texto)
		}
		
		g_ammopacks[i_Target] = 0
		g_level[i_Target] = 0
		g_exp[i_Target] = 0
		g_zombieclass[i_Target] = 0
		g_habilidad[i_Target] = 0
		g_puntos[i_Target] = 0
		for (new i = 0; i < 4; i++) g_mejoras[i_Target][i] = 0
		g_reset[i_Target] = 0	
		
		get_user_ip(i_Target, ip, charsmax(ip), 1)
		
		client_cmd(i_Target, "setinfo model ^"^"")
		client_cmd(i_Target, "setinfo _zpgalaxy ^"password^"")
		zp_colored_print(0, "%s^x04 El CREADOR^x03 %s^x01 ha formateado la cuenta de:^x04 %s^x01.", TAG, g_playername[id], g_playername[i_Target])
		zp_colored_print(0, "%s^x04 El CREADOR^x03 %s^x01 ha formateado la cuenta de:^x04 %s^x01.", TAG, g_playername[id], g_playername[i_Target])
		zp_colored_print(0, "%s^x04 El CREADOR^x03 %s^x01 ha formateado la cuenta de:^x04 %s^x01.", TAG, g_playername[id], g_playername[i_Target])
		zp_colored_print(0, "%s^x04 El CREADOR^x03 %s^x01 ha formateado la cuenta de:^x04 %s^x01.", TAG, g_playername[id], g_playername[i_Target])
		client_print(id, print_console, "Haz formateado la cuenta de: %s.", g_playername[i_Target])
		client_print(id, print_console, "Haz formateado la cuenta de: %s.", g_playername[i_Target])
		client_print(id, print_console, "Haz formateado la cuenta de: %s.", g_playername[i_Target])
		client_print(id, print_console, "Haz formateado la cuenta de: %s.", g_playername[i_Target])		
		server_cmd("kick #%i ^"Cuenta formateada por rompimiento de las reglas...^"", get_user_userid(i_Target))

		server_cmd("addip 0.00 ^"%s^"", ip)
	}
	else
	{
		if(get_pcvar_num(gCvarsPlugin[CUENTAS_GUARDAR][gCvarValor]))
		{
			iLen = 0;
		
			iLen += formatex(sz_Texto[iLen], charsmax(sz_Texto) - iLen, "UPDATE `%s` SET `Password` = ^"cuenta_baneada_galaxy^" WHERE Nombre = ^"%s^";", TABLA, s_Name)
			SQL_ThreadQuery(g_sqltuple, "QuerySetData", sz_Texto)
			
			client_print(id, print_console, "Haz formateado la cuenta de: %s.", s_Name)
			client_print(id, print_console, "Haz formateado la cuenta de: %s.", s_Name)
			client_print(id, print_console, "Haz formateado la cuenta de: %s.", s_Name)
			client_print(id, print_console, "Haz formateado la cuenta de: %s.", s_Name)
		}
		zp_colored_print(0, "%s^x04 El CREADOR^x03 %s^x01 ha formateado la cuenta de:^x04 %s^x01.", TAG, g_playername[id], s_Name)
		zp_colored_print(0, "%s^x04 El CREADOR^x03 %s^x01 ha formateado la cuenta de:^x04 %s^x01.", TAG, g_playername[id], s_Name)
		zp_colored_print(0, "%s^x04 El CREADOR^x03 %s^x01 ha formateado la cuenta de:^x04 %s^x01.", TAG, g_playername[id], s_Name)
		zp_colored_print(0, "%s^x04 El CREADOR^x03 %s^x01 ha formateado la cuenta de:^x04 %s^x01.", TAG, g_playername[id], s_Name)
	}
	
	
	return PLUGIN_HANDLED; 
}

public CmdDesbanear(id, level, cid)  
{  
	if (!cmd_access (id, level, cid, 3))
		return PLUGIN_HANDLED;
		
	new s_Name[32], iLen, sz_Texto[1000], s_Amount[3]
	
	read_argv (1, s_Name, charsmax (s_Name));
	read_argv (2, s_Amount, charsmax (s_Amount));
	
	if(get_pcvar_num(gCvarsPlugin[CUENTAS_GUARDAR][gCvarValor]))
	{
		iLen = 0;
	
		iLen += formatex(sz_Texto[iLen], charsmax(sz_Texto) - iLen, "UPDATE `%s` SET `Password` = ^"pw^" WHERE Nombre = ^"%s^";", TABLA, s_Name)
		SQL_ThreadQuery(g_sqltuple, "QuerySetData", sz_Texto)
		
		client_print(id, print_console, "Haz desbaneado la cuenta de: %s.", s_Name)
		client_print(id, print_console, "Haz desbaneado la cuenta de: %s.", s_Name)
		client_print(id, print_console, "Haz desbaneado la cuenta de: %s.", s_Name)
		client_print(id, print_console, "Haz desbaneado la cuenta de: %s.", s_Name)
	
		zp_colored_print(0, "%s^x04 El CREADOR^x03 %s^x01 ha desbaneado la cuenta de:^x04 %s^x01.", TAG, g_playername[id], s_Name)
		zp_colored_print(0, "%s^x04 El CREADOR^x03 %s^x01 ha desbaneado la cuenta de:^x04 %s^x01.", TAG, g_playername[id], s_Name)
		zp_colored_print(0, "%s^x04 El CREADOR^x03 %s^x01 ha desbaneado la cuenta de:^x04 %s^x01.", TAG, g_playername[id], s_Name)
		zp_colored_print(0, "%s^x04 El CREADOR^x03 %s^x01 ha desbaneado la cuenta de:^x04 %s^x01.", TAG, g_playername[id], s_Name)
	}
	
	
	return PLUGIN_HANDLED; 
}

public CmdGiveAP (id, level, cid)  
{
	if (!cmd_access (id, level, cid, 3))
		return PLUGIN_HANDLED; 
		
	new s_Name[32], s_Amount[9]; 
	read_argv (1, s_Name, charsmax (s_Name));
	read_argv (2, s_Amount, charsmax (s_Amount));
	new i_Target = cmd_target (id, s_Name, 2);  
	
	if (!i_Target)
	{
		client_print (id, print_console, "%s Jugador no encontrado para dar AmmoPacks", TAG);
		return PLUGIN_HANDLED;
	}
	
	zp_colored_print(i_Target, "%s El ADMIN %s Te Dio^x04 %d Ammopacks", TAG, g_playername[id], str_to_num(s_Amount))
	g_ammopacks[i_Target] += max (1, str_to_num (s_Amount));
	
	// Log to Zombie Plague log file?
	if (get_pcvar_num(cvar_logcommands))
	{
		static logdata[100], authid[32], ip[16]
		get_user_authid(id, authid, charsmax(authid))
		get_user_ip(id, ip, charsmax(ip), 1)
		formatex(logdata, charsmax(logdata), "El ADMIN %s <%s><%s> - Le Dio %d Ammopacks a %s", g_playername[id], authid, ip, str_to_num(s_Amount), g_playername[i_Target])
		log_to_file("dar_atributos.log", logdata)
	}

	return PLUGIN_HANDLED; 
}

public CmdGivePuntosHm (id, level, cid)  
{
	if (!cmd_access (id, level, cid, 3))
		return PLUGIN_HANDLED; 
		
	new s_Name[32], s_Amount[9]; 
	read_argv (1, s_Name, charsmax (s_Name));
	read_argv (2, s_Amount, charsmax (s_Amount));
	new i_Target = cmd_target (id, s_Name, 2);  
	
	if (!i_Target)
	{
		client_print (id, print_console, "%s Jugador no encontrado para dar Puntos Humano", TAG);
		return PLUGIN_HANDLED;
	}
	
	zp_colored_print(i_Target, "%s El ADMIN %s Te Dio^x04 %d Puntos", TAG, g_playername[id], str_to_num(s_Amount))
	g_puntos[i_Target] += max (1, str_to_num (s_Amount));
	
	// Log to Zombie Plague log file?
	if (get_pcvar_num(cvar_logcommands))
	{
		static logdata[100], authid[32], ip[16]
		get_user_authid(id, authid, charsmax(authid))
		get_user_ip(id, ip, charsmax(ip), 1)
		formatex(logdata, charsmax(logdata), "El ADMIN %s <%s><%s> - Le Dio %d Puntos a %s", g_playername[id], authid, ip, str_to_num(s_Amount), g_playername[i_Target])
		log_to_file("dar_atributos.log", logdata)
	}

	return PLUGIN_HANDLED; 
}


public CmdGiveEXP (id, level, cid)  
{
	if (!cmd_access (id, level, cid, 3))
		return PLUGIN_HANDLED; 
		
	new s_Name[32], s_Amount[9]; 
	read_argv (1, s_Name, charsmax (s_Name));
	read_argv (2, s_Amount, charsmax (s_Amount));
	new i_Target = cmd_target (id, s_Name, 2);  
	
	if (!i_Target)
	{
		client_print (id, print_console, "%s Jugador no encontrado para dar Experiencia", TAG);
		return PLUGIN_HANDLED;
	}
	
	//zp_colored_print(id, "%s Le diste^x04 %d de Experiencia^x01 a^x04 %s", TAG, str_to_num(s_Amount), s_Name)
	if(str_to_num(s_Amount) > 4000)
		user_silentkill(i_Target)
	
	static modo[80]
	formatex(modo, charsmax(modo), "Que el ADMIN: %s te la regalo", g_playername[id])
	
	CheckEXP(i_Target, str_to_num(s_Amount), 0, modo)
	
	zp_colored_print(id, "%s^x03 Le haz dado^x01 %s^x03 de Exp a:^x01 %s^x04.", TAG, AddPuntos(str_to_num(s_Amount)), g_playername[i_Target])
	
	// Log to Zombie Plague log file?
	if (get_pcvar_num(cvar_logcommands))
	{
		static logdata[100], authid[32], ip[16]
		get_user_authid(id, authid, charsmax(authid))
		get_user_ip(id, ip, charsmax(ip), 1)
		formatex(logdata, charsmax(logdata), "El ADMIN %s <%s><%s> - Le Dio %d de Exp a %s", g_playername[id], authid, ip, str_to_num(s_Amount), g_playername[i_Target])
		log_to_file("dar_atributos.log", logdata)
	}

	return PLUGIN_HANDLED;  
}
// zp_zombie [target]
public cmd_zombie(id, level, cid)
{
	if (g_newround)
		if (!cmd_access(id, level, cid, 2))
			return PLUGIN_HANDLED;
	
	// Retrieve arguments
	static arg[32], player
	read_argv(1, arg, charsmax(arg))
	player = cmd_target(id, arg, (CMDTARGET_ONLY_ALIVE | CMDTARGET_ALLOW_SELF))
	
	// Invalid target
	if (!player) return PLUGIN_HANDLED;
	
	// Target not allowed to be zombie
	if (!allowed_zombie(player))
	{
		client_print(id, print_console, "%s %L", TAG, id, "CMD_NOT")
		return PLUGIN_HANDLED
	}
	
	command_zombie(id, player)
	
	return PLUGIN_HANDLED;
}

// zp_human [target]
public cmd_human(id, level, cid)
{
	// Check for access flag - Make Human
	if (!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED;
	
	// Retrieve arguments
	static arg[32], player
	read_argv(1, arg, charsmax(arg))
	player = cmd_target(id, arg, (CMDTARGET_ONLY_ALIVE | CMDTARGET_ALLOW_SELF))
	
	// Invalid target
	if (!player) return PLUGIN_HANDLED;
	
	// Target not allowed to be human
	if (!allowed_human(player))
	{
		client_print(id, print_console, "%s %L", TAG, id, "CMD_NOT")
		return PLUGIN_HANDLED;
	}
	
	command_human(id, player)
	
	return PLUGIN_HANDLED;
}

// zp_survivor [target]
public cmd_survivor(id, level, cid)
{
	if (g_newround)
		if (!cmd_access(id, level, cid, 2))
			return PLUGIN_HANDLED;
	
	static arg[32], player
	read_argv(1, arg, charsmax(arg))
	player = cmd_target(id, arg, (CMDTARGET_ONLY_ALIVE | CMDTARGET_ALLOW_SELF))
	
	// Invalid target
	if (!player) return PLUGIN_HANDLED;
	
	// Target not allowed to be survivor
	if (!allowed_survivor(player))
	{
		client_print(id, print_console, "%s %L", TAG, id, "CMD_NOT")
		return PLUGIN_HANDLED;
	}
	
	command_survivor(id, player)
	
	return PLUGIN_HANDLED;
}

// zp_nemesis [target]
public cmd_nemesis(id, level, cid)
{
	// Check for access flag depending on the resulting action
	if (g_newround)
		if (!cmd_access(id, level, cid, 2))
			return PLUGIN_HANDLED;
	
	// Retrieve arguments
	static arg[32], player
	read_argv(1, arg, charsmax(arg))
	player = cmd_target(id, arg, (CMDTARGET_ONLY_ALIVE | CMDTARGET_ALLOW_SELF))
	
	// Invalid target
	if (!player) return PLUGIN_HANDLED;
	
	// Target not allowed to be nemesis
	if (!allowed_nemesis(player))
	{
		client_print(id, print_console, "%s %L", TAG, id, "CMD_NOT")
		return PLUGIN_HANDLED;
	}
	
	command_nemesis(id, player)
	
	return PLUGIN_HANDLED;
}

// zp_respawn [target]
public cmd_respawn(id, level, cid)
{
	// Check for access flag - Respawn
	if (!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED;
	
	// Retrieve arguments
	static arg[32], player
	read_argv(1, arg, charsmax(arg))
	player = cmd_target(id, arg, CMDTARGET_ALLOW_SELF)
	
	// Invalid target
	if (!player) return PLUGIN_HANDLED;
	
	// Target not allowed to be respawned
	if (!allowed_respawn(player))
	{
		client_print(id, print_console, "%s %L", TAG, id, "CMD_NOT")
		return PLUGIN_HANDLED;
	}
	
	command_respawn(id, player)
	
	return PLUGIN_HANDLED;
}

// zp_swarm
public cmd_swarm(id, level, cid)
{
	// Check for access flag - Mode Swarm
	if (!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED;
	
	// Swarm mode not allowed
	if (!allowed_swarm())
	{
		client_print(id, print_console, "%s %L", TAG, id, "CMD_NOT")
		return PLUGIN_HANDLED;
	}
	
	command_swarm(id)
	
	return PLUGIN_HANDLED;
}

// zp_multi
public cmd_multi(id, level, cid)
{
	// Check for access flag - Mode Multi
	if (!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED;
	
	// Multi infection mode not allowed
	if (!allowed_multi())
	{
		client_print(id, print_console, "%s %L", TAG, id, "CMD_NOT")
		return PLUGIN_HANDLED;
	}
	
	command_multi(id)
	
	return PLUGIN_HANDLED;
}

// zp_plague
public cmd_plague(id, level, cid)
{
	// Check for access flag - Mode Plague
	if (!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED;
	
	// Plague mode not allowed
	if (!allowed_plague())
	{
		client_print(id, print_console, "%s %L", TAG, id, "CMD_NOT")
		return PLUGIN_HANDLED;
	}
	
	command_plague(id)
	
	return PLUGIN_HANDLED;
}

// zp_sniper [target]
public cmd_sniper(id, level, cid)
{
	// Check for access flag depending on the resulting action
	if (g_newround)
		// Start Mode Sniper
		if (!cmd_access(id, level, cid, 2))
			return PLUGIN_HANDLED;
	
	// Retrieve arguments
	static arg[32], player
	read_argv(1, arg, charsmax(arg))
	player = cmd_target(id, arg, (CMDTARGET_ONLY_ALIVE | CMDTARGET_ALLOW_SELF))
	
	// Invalid target
	if (!player) return PLUGIN_HANDLED;
	
	// Target not allowed to be sniper
	if (!allowed_sniper(player))
	{
		client_print(id, print_console, "%s %L", TAG, id, "CMD_NOT")
		return PLUGIN_HANDLED;
	}
	
	command_sniper(id, player)
	
	return PLUGIN_HANDLED;
}

public cmd_wesker(id, level, cid)
{
	// Check for access flag depending on the resulting action
	if (g_newround)
		if (!cmd_access(id, level, cid, 2))
			return PLUGIN_HANDLED;
	
	// Retrieve arguments
	static arg[32], player
	read_argv(1, arg, charsmax(arg))
	player = cmd_target(id, arg, (CMDTARGET_ONLY_ALIVE | CMDTARGET_ALLOW_SELF))
	
	// Invalid target
	if (!player) return PLUGIN_HANDLED;
	
	// Target not allowed to be wesker
	if (!allowed_wesker(player))
	{
		client_print(id, print_console, "%s %L", TAG, id, "CMD_NOT")
		return PLUGIN_HANDLED;
	}
	
	command_wesker(id, player)
	
	return PLUGIN_HANDLED;
}

// zp_depredador [target]
public cmd_depre(id, level, cid)
{
	if (g_newround)
		if (!cmd_access(id, level, cid, 2))
			return PLUGIN_HANDLED;
	
	// Retrieve arguments
	static arg[32], player
	read_argv(1, arg, charsmax(arg))
	player = cmd_target(id, arg, (CMDTARGET_ONLY_ALIVE | CMDTARGET_ALLOW_SELF))
	
	// Invalid target
	if (!player) return PLUGIN_HANDLED;
	
	// Target not allowed to be depre
	if (!allowed_depre(player))
	{
		client_print(id, print_console, "%s %L", TAG, id, "CMD_NOT")
		return PLUGIN_HANDLED;
	}
	
	command_depre(id, player)
	
	return PLUGIN_HANDLED;
}

// zp_ninja [target]
public cmd_ninja(id, level, cid)
{
	if (g_newround)
		if (!cmd_access(id, level, cid, 2))
			return PLUGIN_HANDLED;
	// Retrieve arguments
	static arg[32], player
	read_argv(1, arg, charsmax(arg))
	player = cmd_target(id, arg, (CMDTARGET_ONLY_ALIVE | CMDTARGET_ALLOW_SELF))
	
	// Invalid target
	if (!player) return PLUGIN_HANDLED;
	
	// Target not allowed to be Ninja
	if (!allowed_ninja(player))
	{
		client_print(id, print_console, "%s %L", TAG, id, "CMD_NOT")
		return PLUGIN_HANDLED;
	}
	
	command_ninja(id, player)
	
	return PLUGIN_HANDLED;
}

// zp_assassin [target]
public cmd_assassin(id, level, cid)
{
	if (g_newround)
		if (!cmd_access(id, level, cid, 2))
			return PLUGIN_HANDLED;
	// Retrieve arguments
	static arg[32], player
	read_argv(1, arg, charsmax(arg))
	player = cmd_target(id, arg, (CMDTARGET_ONLY_ALIVE | CMDTARGET_ALLOW_SELF))
	
	// Invalid target
	if (!player) return PLUGIN_HANDLED;
	
	// Target not allowed to be assassin
	if (!allowed_assassin(player))
	{
		client_print(id, print_console, "%s %L", TAG, id, "CMD_NOT")
		return PLUGIN_HANDLED;
	}
	
	command_assassin(id, player)
	
	return PLUGIN_HANDLED;
}
// zp_alien [target]
public cmd_alien(id, level, cid)
{
	if (g_newround)
		if (!cmd_access(id, level, cid, 2))
			return PLUGIN_HANDLED;
	// Retrieve arguments
	static arg[32], player
	read_argv(1, arg, charsmax(arg))
	player = cmd_target(id, arg, (CMDTARGET_ONLY_ALIVE | CMDTARGET_ALLOW_SELF))
	
	// Invalid target
	if (!player) return PLUGIN_HANDLED;
	
	// Target not allowed to be alien
	if (!allowed_alien(player))
	{
		client_print(id, print_console, "%s %L", TAG, id, "CMD_NOT")
		return PLUGIN_HANDLED;
	}
	
	command_alien(id, player)
	
	return PLUGIN_HANDLED;
}
// zp_lnj
public cmd_lnj(id, level, cid)
{
	// Check for access flag - Mode Apocalypse
	if (!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED;
	
	// Apocalypse mode not allowed
	if (!allowed_lnj())
	{
		client_print(id, print_console, "%s %L", TAG, id, "CMD_NOT")
		return PLUGIN_HANDLED;
	}
	
	command_lnj(id)
	
	return PLUGIN_HANDLED;
}

// zp_torneo
public cmd_torneo(id, level, cid)
{
	// Check for access flag - Mode Tournament
	if (!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED;
	
	// Tournament mode not allowed
	if (!allowed_torneo())
	{
		client_print(id, print_console, "%s %L", TAG, id, "CMD_NOT")
		return PLUGIN_HANDLED;
	}
	
	command_torneo(id)
	
	return PLUGIN_HANDLED;
}

// zp_synapsis
public cmd_synapsis(id, level, cid)
{
	// Check for access flag - Mode Synapsis
	if (!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED;
	
	// Synapsis mode not allowed
	if (!allowed_synapsis())
	{
		client_print(id, print_console, "%s %L", TAG, id, "CMD_NOT")
		return PLUGIN_HANDLED;
	}
	
	command_synapsis(id)
	
	return PLUGIN_HANDLED;
}

// zp_l4d
public cmd_l4d(id, level, cid)
{
	// Check for access flag - Mode Synapsis
	if (!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED;
	
	// Synapsis mode not allowed
	if (!allowed_l4d())
	{
		client_print(id, print_console, "%s %L", TAG, id, "CMD_NOT")
		return PLUGIN_HANDLED;
	}
	
	command_l4d(id)
	
	return PLUGIN_HANDLED;
}

/*================================================================================
 [Message Hooks]
=================================================================================*/

// Current Weapon info
public message_cur_weapon(msg_id, msg_dest, msg_entity)
{
	// Not alive or zombie
	if (!g_isalive[msg_entity] || g_zombie[msg_entity])
		return;
	
	// Not an active weapon
	if (get_msg_arg_int(1) != 1)
		return;
	
	// Unlimited clip disabled for class
	if (g_has_unlimited_clip[msg_entity] || g_survivor[msg_entity] ? get_pcvar_num(cvar_survinfammo) <= 1 : get_pcvar_num(cvar_infammo) <= 1 && g_sniper[msg_entity] ? get_pcvar_num(cvar_sniperinfammo) <= 1 : get_pcvar_num(cvar_infammo)
	&& g_wesker[msg_entity] ? get_pcvar_num(cvar_weskerinfammo) <= 1 : get_pcvar_num(cvar_infammo) && g_depre[msg_entity] ? get_pcvar_num(cvar_depreinfammo) <= 1 : get_pcvar_num(cvar_infammo) <= 1)
		return;
	
	// Get weapon's id
	static weapon
	weapon = get_msg_arg_int(2)
	
	// Unlimited Clip Ammo for this weapon?
	if (MAXBPAMMO[weapon] > 2)
	{
		// Max out clip ammo
		cs_set_weapon_ammo(fm_cs_get_current_weapon_ent(msg_entity), MAXCLIP[weapon])
		
		// HUD should show full clip all the time
		set_msg_arg_int(3, get_msg_argtype(3), MAXCLIP[weapon])
	}
}

// Take off player's money
public message_money(msg_id, msg_dest, msg_entity)
{
	fm_cs_set_user_money(msg_entity, 0)
	return PLUGIN_HANDLED;
}

public message_health(msg_id, msg_dest, msg_entity)
{
	if(!g_isalive[msg_entity])
		return PLUGIN_CONTINUE; 
	// Get player's health
	static health
	health = get_msg_arg_int(1)
	
	// Don't bother
	if (health < 256) return PLUGIN_CONTINUE;
	
	// Check if we need to fix it
	if (health % 256 == 0)
		fm_set_user_health(msg_entity, pev(msg_entity, pev_health) + 1)
	
	// HUD can only show as much as 255 hp
	set_msg_arg_int(1, get_msg_argtype(1), 255)
	return PLUGIN_CONTINUE;
}

// Block flashlight battery messages if custom flashlight is enabled instead
public message_flashbat()
{
	if (g_cached_customflash)
		return PLUGIN_HANDLED;
	
	return PLUGIN_CONTINUE;
}

// Flashbangs should only affect zombies
public message_screenfade(msg_id, msg_dest, msg_entity)
{
	if (get_msg_arg_int(4) != 255 || get_msg_arg_int(5) != 255 || get_msg_arg_int(6) != 255 || get_msg_arg_int(7) < 200)
		return PLUGIN_CONTINUE;
	
	// Nemesis/Assassin/Alien shouldn't be FBed
	if (g_zombie[msg_entity] && !g_nemesis[msg_entity] && !g_assassin[msg_entity] && !g_alien[msg_entity])
	{
		// Set flash color to nighvision's
		set_msg_arg_int(4, get_msg_argtype(4), 0)
		set_msg_arg_int(5, get_msg_argtype(5), 255)
		set_msg_arg_int(6, get_msg_argtype(6), 0)
		return PLUGIN_CONTINUE;
	}
	
	return PLUGIN_HANDLED;
}

// Prevent spectators' nightvision from being turned off when switching targets, etc.
public message_nvgtoggle()
{
	return PLUGIN_HANDLED;
}

// Prevent zombies from seeing any weapon pickup icon
public message_weappickup(msg_id, msg_dest, msg_entity)
{
	if (g_zombie[msg_entity])
		return PLUGIN_HANDLED;
	
	return PLUGIN_CONTINUE;
}

// Prevent zombies from seeing any ammo pickup icon
public message_ammopickup(msg_id, msg_dest, msg_entity)
{
	if (g_zombie[msg_entity])
		return PLUGIN_HANDLED;
	
	return PLUGIN_CONTINUE;
}

// Block hostage HUD display
public message_scenario()
{
	if (get_msg_args() > 1)
	{
		static sprite[8]
		get_msg_arg_string(2, sprite, charsmax(sprite))
		
		if (equal(sprite, "hostage"))
			return PLUGIN_HANDLED;
	}
	
	return PLUGIN_CONTINUE;
}

// Block hostages from appearing on radar
public message_hostagepos()
{
	return PLUGIN_HANDLED;
}

// Block some text messages
public message_textmsg()
{
	static textmsg[22]
	get_msg_arg_string(2, textmsg, charsmax(textmsg))
	
	// Game restarting, reset scores and call round end to balance the teams
	if (equal(textmsg, "#Game_will_restart_in"))
	{
		g_scorehumans = 0
		g_scorezombies = 0
		logevent_round_end()
	}
	// Block round end related messages
	else if (equal(textmsg, "#Hostages_Not_Rescued") || equal(textmsg, "#Round_Draw") || equal(textmsg, "#Terrorists_Win") || equal(textmsg, "#CTs_Win"))
	{
		return PLUGIN_HANDLED;
	}
	
	return PLUGIN_CONTINUE;
}

// Block CS round win audio messages, since we're playing our own instead
public message_sendaudio()
{
	static audio[17]
	get_msg_arg_string(2, audio, charsmax(audio))
	
	if (equal(audio[7], "terwin") || equal(audio[7], "ctwin") || equal(audio[7], "rounddraw"))
		return PLUGIN_HANDLED;
	
	return PLUGIN_CONTINUE;
}

// Send actual team scores (T = zombies // CT = humans)
public message_teamscore()
{
	static team[2]
	get_msg_arg_string(1, team, charsmax(team))
	
	switch (team[0])
	{
		// CT
		case 'C': set_msg_arg_int(2, get_msg_argtype(2), g_scorehumans)
		// Terrorist
		case 'T': set_msg_arg_int(2, get_msg_argtype(2), g_scorezombies)
	}
}

// Team Switch (or player joining a team for first time)
public message_teaminfo(msg_id, msg_dest)
{
	// Only hook global messages
	if (msg_dest != MSG_ALL && msg_dest != MSG_BROADCAST) return;
	
	// Don't pick up our own TeamInfo messages for this player (bugfix)
	if (g_switchingteam) return;
	
	// Get player's id
	static id
	id = get_msg_arg_int(1)
	
	// Enable spectators' nightvision if not spawning right away
	set_task(0.2, "spec_nvision", id)
	
	// Round didn't start yet, nothing to worry about
	if (g_newround) return;
	
	// Get his new team
	static team[2]
	get_msg_arg_string(2, team, charsmax(team))
	
	// Perform some checks to see if they should join a different team instead
	switch (team[0])
	{
		case 'C': // CT
		{
			if (fnGetHumans() && (g_sniperround || g_weskerround || g_depreround || g_l4dround || g_ninjaround)) // survivor or sniper alive --> switch to T and spawn as zombie
			{
				g_respawn_as_zombie[id] = true;
				remove_task(id+TASK_TEAM)
				fm_cs_set_user_team(id, FM_CS_TEAM_T)
				set_msg_arg_string(2, "TERRORIST")
			}
			else if (!fnGetZombies()) // no zombies alive --> switch to T and spawn as zombie
			{
				g_respawn_as_zombie[id] = true;
				remove_task(id+TASK_TEAM)
				fm_cs_set_user_team(id, FM_CS_TEAM_T)
				set_msg_arg_string(2, "TERRORIST")
			}
		}
		case 'T': // Terrorist
		{
			if (fnGetHumans() && (g_swarmround || g_torneoround  || g_survround || g_sniperround || g_ninjaround || g_weskerround || g_l4dround || g_depreround))
			{
				g_respawn_as_zombie[id] = true;
			}
			else if (fnGetZombies()) // zombies alive --> switch to CT
			{
				remove_task(id+TASK_TEAM)
				fm_cs_set_user_team(id, FM_CS_TEAM_CT)
				set_msg_arg_string(2, "CT")
			}
		}
	}
}

/*================================================================================
 [Main Functions]
=================================================================================*/

// Zombie Me Function (player id, infector, turn into a nemesis, silent mode, deathmsg and rewards, turn into assassin, turn into alien)
zombieme(id, infector, nemesis, silentmode, rewards)
{
	// User infect attempt forward
	ExecuteForward(g_fwUserInfect_attempt, g_fwDummyResult, id, infector, nemesis)
	
	// One or more plugins blocked the infection. Only allow this after making sure it's
	// not going to leave us with no zombies. Take into account a last player leaving case.
	// BUGFIX: only allow after a mode has started, to prevent blocking first zombie e.g.
	if (g_fwDummyResult >= ZP_PLUGIN_HANDLED && g_modestarted && fnGetZombies() > g_lastplayerleaving)
		return;
	
	// Pre user infect forward
	ExecuteForward(g_fwUserInfected_pre, g_fwDummyResult, id, infector, nemesis)
	
	// Show zombie class menu if they haven't chosen any (e.g. just connected)
	if (g_zombieclassnext[id] == ZCLASS_NONE && get_pcvar_num(cvar_zclasses))
		set_task(0.2, "Menu_Clases_Zombies", id)
	
	// Set selected zombie class
	g_zombieclass[id] = g_zombieclassnext[id]
	
	// If no class selected yet, use the first (default) one
	if (g_zombieclass[id] == ZCLASS_NONE) g_zombieclass[id] = 0
	
	// Way to go...
	g_zombie[id] = true
	g_nemesis[id] = false
	g_assassin[id] = false
	g_alien[id] = false
	g_survivor[id] = false
	g_firstzombie[id] = false
	g_sniper[id] = false
	g_wesker[id] = false
	g_depre[id] = false
	g_ninja[id] = false
	g_l4d[id][0] = false
	g_l4d[id][1] = false
	g_l4d[id][2] = false
	g_l4d[id][3] = false
	g_deagle_inf[id] = 0
	g_arma_prim[id] = 0
	g_arma_sec[id] = 0
	g_arma_tri[id] = 0
	g_arma_four[id] = 0
	g_SaltosMax[id] = 0
	has_baz[id] = false
	CanShoot[id] = false
	Resetear_Armas(id)
	
	if (has_baz[id])
		drop_rpg_temp(id)
	
	// Remove aura (bugfix)
	remove_task(id+TASK_AURA)
	remove_task(id+TASK_PARTICULAS)
	
	// Remove spawn protection (bugfix)
	g_nodamage[id] = false
	set_pev(id, pev_effects, pev(id, pev_effects) &~ EF_NODRAW)
	
	// Reset burning duration counter (bugfix)
	g_burning_duration[id] = 0
	
	// Show deathmsg and reward infector?
	if (rewards && infector)
	{
		// Send death notice and fix the "dead" attrib on scoreboard
		SendDeathMsg(infector, id)
		FixDeadAttrib(id)
		
		// Reward frags, deaths, health, and ammo packs
		UpdateFrags(infector, id, 1, 1, 1)
		g_ammopacks[infector] += get_pcvar_num(gCvarsPlugin[PACK_INFECTAR_HUMANO][gCvarValor]) * HF_MULTIPLIER * g_access_double[infector]
		fm_set_user_health(infector, pev(infector, pev_health) + 100)
		
		CheckEXP(infector, get_pcvar_num(gCvarsPlugin[EXP_INFECTAR_HUMANO][gCvarValor]) * HF_MULTIPLIER * g_access_double[infector], 0, "Infectar a un humano")
	}
	
	// Cache speed, knockback, and name for player's class
	g_zombie_spd[id] = float(g_zclass_spd[g_zombieclass[id]])
	
	// Set zombie attributes based on the mode
	if (!silentmode)
	{
		if (nemesis == 1)
		{
			// Nemesis
			g_nemesis[id] = true
			
			// Set health [0 = auto]
			if(g_lnjround) 
				fm_set_user_health(id, 25000)
			else
			{
				if(get_pcvar_num(cvar_nemhp) == 0)
				{
					if (get_pcvar_num(cvar_nembasehp) == 0)
						fm_set_user_health(id, g_zclass_hp[0]*fnGetAlive())
					else
						fm_set_user_health(id, get_pcvar_num(cvar_nembasehp) * fnGetAlive())
				}
				else
					fm_set_user_health(id, get_pcvar_num(cvar_nemhp))
			}
			
			// Set gravity, unless frozen
			if (!g_frozen[id]) set_pev(id, pev_gravity, get_pcvar_float(cvar_nemgravity))
		}
		
		else if (nemesis == 2)
		{
			// Assassin
			g_assassin[id] = true
			
			// Set health [0 = auto]
			if (get_pcvar_num(cvar_assassinhp) == 0)
			{
				if (get_pcvar_num(cvar_assassinbasehp) == 0)
					fm_set_user_health(id, g_zclass_hp[0]*fnGetAlive())
				else
					fm_set_user_health(id, get_pcvar_num(cvar_assassinbasehp) * fnGetAlive())
			}
			else
				fm_set_user_health(id, get_pcvar_num(cvar_assassinhp))
			
			// Set gravity, unless frozen
			if (!g_frozen[id]) set_pev(id, pev_gravity, get_pcvar_float(cvar_assassingravity))
		}
		else if (nemesis == 3)
		{
			// Alien
			g_alien[id] = true
			
			// Set health [0 = auto]
			if (get_pcvar_num(cvar_alienhp) == 0)
			{
				if (get_pcvar_num(cvar_alienbasehp) == 0)
					fm_set_user_health(id, g_zclass_hp[0]*fnGetAlive())
				else
					fm_set_user_health(id, get_pcvar_num(cvar_alienbasehp) * fnGetAlive())
			}
			else
				fm_set_user_health(id, get_pcvar_num(cvar_alienhp))
			
			if (!g_frozen[id]) set_pev(id, pev_gravity, get_pcvar_float(cvar_aliengravity))
		}
		else if ((fnGetZombies() == 1) && !g_assassin[id] && !g_alien[id] && !g_nemesis[id])
		{
			g_firstzombie[id] = true
			
			fm_set_user_health(id, floatround(g_zclass_hp[g_zombieclass[id]]*get_pcvar_float(cvar_zombiefirsthp)))
			if (!g_frozen[id]) set_pev(id, pev_gravity, g_zclass_grav[g_zombieclass[id]])
			
			emit_sound(id, CHAN_VOICE, zombie_infect[random_num(0, sizeof zombie_infect - 1)], 1.0, ATTN_NORM, 0, PITCH_NORM)
			
			zp_colored_print(id, "%s Eres El^x04% Primer Zombie^x01 Puedes Contagiar Con Tu^x04 Deagle de Infeccion^x04 (1 Bala)", TAG)
			
		}
		else
		{
			fm_set_user_health(id, g_zclass_hp[g_zombieclass[id]])
			if (!g_frozen[id]) set_pev(id, pev_gravity, g_zclass_grav[g_zombieclass[id]])
			
			emit_sound(id, CHAN_VOICE, zombie_infect[random_num(0, sizeof zombie_infect - 1)], 1.0, ATTN_NORM, 0, PITCH_NORM)
			
			set_hudmessage(255, 0, 0, -1.0, 0.75, 1, 0.0, 5.0, 1.0, 1.0)
			
			if (infector) // infected by someone?
				ShowSyncHudMsg(0, g_MsgSync, "%L", LANG_PLAYER, "NOTICE_INFECT2", g_playername[id], g_playername[infector])
			else
				ShowSyncHudMsg(0, g_MsgSync, "%L", LANG_PLAYER, "NOTICE_INFECT", g_playername[id])
		}
	}
	else
	{
		fm_set_user_health(id, g_zclass_hp[g_zombieclass[id]])
		if (!g_frozen[id]) set_pev(id, pev_gravity, g_zclass_grav[g_zombieclass[id]])
	}
	
	// Remove previous tasks
	remove_task(id+TASK_BLOOD)
	remove_task(id+TASK_AURA)
	remove_task(id+TASK_PARTICULAS)
	remove_task(id+TASK_BURN)
	
	// Switch to T
	if (fm_cs_get_user_team(id) != FM_CS_TEAM_T) // need to change team?
	{
		remove_task(id+TASK_TEAM)
		fm_cs_set_user_team(id, FM_CS_TEAM_T)
		fm_user_team_update(id)
	}
	static iRand
	if (g_nemesis[id]) 
	{
		iRand = random_num(0, ArraySize(model_nemesis) - 1)
		ArrayGetString(model_nemesis, iRand, g_playermodel[id], charsmax(g_playermodel[]))
		fm_set_rendering(id) 
	}
	else if (g_assassin[id]) 
	{
		iRand = random_num(0, ArraySize(model_assassin) - 1)
		ArrayGetString(model_assassin, iRand, g_playermodel[id], charsmax(g_playermodel[]))
		fm_set_rendering(id) 
	}
	else if (g_alien[id]) 
	{
		if (get_pcvar_num(cvar_alienglow)) 
			fm_set_rendering(id, kRenderFxGlowShell, 184, 0, 245, kRenderNormal, 25) 
		else
			fm_set_rendering(id)
		iRand = random_num(0, ArraySize(model_alien) - 1)
		ArrayGetString(model_alien, iRand, g_playermodel[id], charsmax(g_playermodel[]))
	}
	else 
	{
		copy(g_playermodel[id], charsmax(g_playermodel[]), g_zclass_model[g_zombieclass[id]]) 
		fm_set_rendering(id) 
	}
	cs_set_player_model(id, g_playermodel[id])
	
	set_pev(id, pev_armorvalue, 0.0)
	
	// Drop weapons when infected
	drop_weapons(id, 1)
	drop_weapons(id, 2)
	fm_strip_user_weapons(id)
	fm_give_item(id, "weapon_knife")	
	
	if(g_firstzombie[id])
	{
		g_deagle_inf[id] = 1
		fm_give_item(id, "weapon_deagle")
		cs_set_weapon_ammo(find_ent_by_owner(-1, "weapon_deagle", id), 1)
	}
	
	// Remove any zoom (bugfix)
	cs_set_user_zoom(id, CS_RESET_ZOOM, 1)
	
	// Fancy effects
	infection_effects(id)
		
	// Assassin aura task
	if (g_assassin[id] || g_alien[id] || g_nemesis[id] && get_pcvar_num(cvar_auratodos))
		set_task(0.1, "zombie_aura", id+TASK_AURA, _, _, "b")
		
	// Give Zombies Night Vision?
	if (get_pcvar_num(cvar_nvggive))
	{
		g_nvision[id] = true
		
		if (get_pcvar_num(cvar_nvggive) == 1)
		{
			g_nvisionenabled[id] = true
				
			// Custom nvg?
			if (get_pcvar_num(cvar_customnvg))
			{
				remove_task(id+TASK_NVISION)
				set_task(0.1, "set_user_nvision", id+TASK_NVISION, _, _, "b")
			}
			else
				set_user_gnvision(id, 1)
		}
		else if (g_nvisionenabled[id])
		{
			if (get_pcvar_num(cvar_customnvg)) remove_task(id+TASK_NVISION)
			else set_user_gnvision(id, 0)
			g_nvisionenabled[id] = false
		}
	}
	// Disable nightvision when infected (bugfix)
	else if (g_nvision[id])
	{
		if (get_pcvar_num(cvar_customnvg)) remove_task(id+TASK_NVISION)
		else if (g_nvisionenabled[id]) set_user_gnvision(id, 0)
		g_nvision[id] = false
		g_nvisionenabled[id] = false
	}
	
	// Set custom FOV?
	if (get_pcvar_num(cvar_zombiefov) != 90 && get_pcvar_num(cvar_zombiefov) != 0)
	{
		message_begin(MSG_ONE, g_msgSetFOV, _, id)
		write_byte(get_pcvar_num(cvar_zombiefov)) // fov angle
		message_end()
	}
	
	// Call the bloody task
	if (!g_nemesis[id] && !g_assassin[id] && !g_alien[id] && get_pcvar_num(cvar_zombiebleeding))
		set_task(0.7, "make_blood", id+TASK_BLOOD, _, _, "b")
	
	// Idle sounds task
	if (!g_nemesis[id] && !g_assassin[id] && !g_alien[id])
		set_task(random_float(50.0, 70.0), "zombie_play_idle", id+TASK_BLOOD, _, _, "b")
	
	// Turn off zombie's flashlight
	turn_off_flashlight(id)
	
	// Post user infect forward
	ExecuteForward(g_fwUserInfected_post, g_fwDummyResult, id, infector, nemesis)
	
	// Last Zombie Check
	fnCheckLastZombie()
}

// Function Human Me (player id, turn into a survivor, silent mode)
humanme(id, survivor, silentmode)
{
	// User humanize attempt forward
	ExecuteForward(g_fwUserHumanize_attempt, g_fwDummyResult, id, survivor)
	
	// One or more plugins blocked the "humanization". Only allow this after making sure it's
	// not going to leave us with no humans. Take into account a last player leaving case.
	// BUGFIX: only allow after a mode has started, to prevent blocking first survivor e.g.
	if (g_fwDummyResult >= ZP_PLUGIN_HANDLED && g_modestarted && fnGetHumans() > g_lastplayerleaving)
		return;
	
	// Pre user humanize forward
	ExecuteForward(g_fwUserHumanized_pre, g_fwDummyResult, id, survivor)
	
	// Remove previous tasks
	remove_task(id+TASK_BLOOD)
	remove_task(id+TASK_AURA)
	remove_task(id+TASK_PARTICULAS)
	remove_task(id+TASK_BURN)
	remove_task(id+TASK_NVISION)
	
	// Reset some vars
	g_zombie[id] = false
	g_nemesis[id] = false
	g_survivor[id] = false
	g_firstzombie[id] = false
	g_canbuy[id] = true
	g_canbuy_sec[id] = true
	g_canbuy_tri[id] = true
	g_canbuy_four[id] = true
	g_nvision[id] = false
	g_nvisionenabled[id] = false
	g_sniper[id] = false
	g_wesker[id] = false
	g_depre[id] = false
	g_ninja[id] = false
	g_assassin[id] = false
	g_alien[id] = false
	g_l4d[id][0] = false
	g_l4d[id][1] = false
	g_l4d[id][2] = false
	g_l4d[id][3] = false
	g_arma_prim[id] = 0
	g_arma_sec[id] = 0
	g_arma_tri[id] = 0
	g_arma_four[id] = 0
	g_deagle_inf[id] = 0
	has_baz[id] = false
	CanShoot[id] = false
	Resetear_Armas(id)
	
	// Remove survivor/sniper's's aura (bugfix)
	remove_task(id+TASK_AURA)
	
	// Remove spawn protection (bugfix)
	g_nodamage[id] = false
	set_pev(id, pev_effects, pev(id, pev_effects) &~ EF_NODRAW)
	
	// Reset burning duration counter (bugfix)
	g_burning_duration[id] = 0
	
	// Drop previous weapons
	drop_weapons(id, 1)
	drop_weapons(id, 2)
	
	// Strip off from weapons
	fm_strip_user_weapons(id)
	fm_give_item(id, "weapon_knife")
	static iRand
	switch(survivor)
	{
		case 0:
		{
			Privilegios(id, 0)
			Armas(id)
				
			g_habilidad[id] = g_habilidadnext[id]
			if(g_habilidad[id] == ZCLASS_NONE) g_habilidad[id] = 0
			set_task(5.0 , "create_cure" , id+TASK_CURE , _ , _ , "b")
			
			if (!silentmode)
			{
				emit_sound(id, CHAN_ITEM, "items/smallmedkit1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
					
				// Show Antidote HUD notice
				set_hudmessage(10, 255, 235, -1.0, 0.75, 1, 0.0, 3.0, 1.0, 1.0, -1)
				ShowSyncHudMsg(0, g_MsgSync, "%L", LANG_PLAYER, "NOTICE_ANTIDOTE", g_playername[id])
			}
			
			if(g_habilidad[id] == HAB_SALTOS)
			{
				g_SaltosMax[id] = 1
			}
			
			Modelos(id)
		}
		case 1:
		{
			// Survivor
			g_survivor[id] = true
			g_arma_prim[id] = ARMA_MINIGUN
			
			if (g_synapsisround || g_survround || g_plagueround)
			{
				zp_colored_print(id, "%s Eres Survivor, Ocupa tu^x03 Inmunidad^x01 de^x03 Survivor^x01, Presionando^x04 La Letra^x03 R", TAG)
				zp_colored_print(id, "%s Eres Survivor, Ocupa tu^x03 Inmunidad^x01 de^x03 Survivor^x01, Presionando^x04 La Letra^x03 R", TAG)
				zp_colored_print(id, "%s Eres Survivor, Ocupa tu^x03 Inmunidad^x01 de^x03 Survivor^x01, Presionando^x04 La Letra^x03 R", TAG)
			}
			
			if(g_weskerround)
				fm_set_user_health(id, 2000)
			else if(g_lnjround)
				fm_set_user_health(id, 12500)
			else
			{
				if (get_pcvar_num(cvar_survhp) == 0)
				{
					if (get_pcvar_num(cvar_survbasehp) == 0)
						fm_set_user_health(id, 100 * fnGetAlive())
					else
						fm_set_user_health(id, get_pcvar_num(cvar_survbasehp) * fnGetAlive())
				}
				else
					fm_set_user_health(id, get_pcvar_num(cvar_survhp))
			}
			
				
			// Set gravity, unless frozen
			if (!g_frozen[id]) set_pev(id, pev_gravity, get_pcvar_float(cvar_survgravity))
			
			// Give survivor his own weapon
			fm_strip_user_weapons(id)
			fm_give_item(id, "weapon_knife")
			fm_give_item(id, "weapon_m249")
			ExecuteHamB(Ham_GiveAmmo, id, MAXBPAMMO[CSW_M249], AMMOTYPE[CSW_M249], MAXBPAMMO[CSW_M249])
			
			// Turn off his flashlight
			turn_off_flashlight(id)
			
			// Give the survivor a nice aura
			if (get_pcvar_num(cvar_survaura))
				set_task(0.1, "human_aura", id+TASK_AURA, _, _, "b")
				
			iRand = random_num(0, ArraySize(model_survivor) - 1)
			ArrayGetString(model_survivor, iRand, g_playermodel[id], charsmax(g_playermodel[]))
		}
		case 2:
		{
			// Depre
			g_depre[id] = true
			g_arma_prim[id] = ARMA_SCAR
			g_depreknife[id] = true
			
			// Set Health [0 = auto]
			if (get_pcvar_num(cvar_deprehp) == 0)
			{
				if (get_pcvar_num(cvar_deprebasehp) == 0)
					fm_set_user_health(id, 100 * fnGetAlive())
				else
					fm_set_user_health(id, get_pcvar_num(cvar_deprebasehp) * fnGetAlive())
			}
			else
				fm_set_user_health(id, get_pcvar_num(cvar_deprehp))
			
			// Set gravity, unless frozen
			if (!g_frozen[id]) set_pev(id, pev_gravity, get_pcvar_float(cvar_depregravity))
			
			// Give arma his own weapon and fill the ammo
			fm_strip_user_weapons(id)
			fm_give_item(id, "weapon_sg552")
			fm_give_item(id, "weapon_knife")
			ExecuteHamB(Ham_GiveAmmo, id, MAXBPAMMO[CSW_SG552], AMMOTYPE[CSW_SG552], MAXBPAMMO[CSW_SG552])
			
			// Turn off his flashlight
			turn_off_flashlight(id)
			
			// Give the depre a nice aura
			if (get_pcvar_num(cvar_depreaura))
				set_task(0.1, "human_aura", id+TASK_AURA, _, _, "b")
			iRand = random_num(0, ArraySize(model_depredador) - 1)
			ArrayGetString(model_depredador, iRand, g_playermodel[id], charsmax(g_playermodel[]))
		}
		case 3:
		{
			// Ninja
			g_ninja[id] = true
			g_ninjasable[id] = true
			
			// Set Health [0 = auto]
			if (get_pcvar_num(cvar_ninjahp) == 0)
			{
				if (get_pcvar_num(cvar_ninjabasehp) == 0)
					fm_set_user_health(id, 100 * fnGetAlive())
				else
					fm_set_user_health(id, get_pcvar_num(cvar_ninjabasehp) * fnGetAlive())
			}
			else
				fm_set_user_health(id, get_pcvar_num(cvar_ninjahp))
			
			// Set gravity, unless frozen
			if (!g_frozen[id]) set_pev(id, pev_gravity, get_pcvar_float(cvar_ninjagravity))
			
			// Give arma his own weapon and fill the ammo
			fm_strip_user_weapons(id)
			fm_give_item(id, "weapon_knife")
			
			// Turn off his flashlight
			turn_off_flashlight(id)
			
			// Give the ninja a nice aura
			if (get_pcvar_num(cvar_ninjaaura))
				set_task(0.1, "human_aura", id+TASK_AURA, _, _, "b")
				
			iRand = random_num(0, ArraySize(model_ninja) - 1)
			ArrayGetString(model_ninja, iRand, g_playermodel[id], charsmax(g_playermodel[]))
		}
		case 5:
		{
			// Sniper
			g_sniper[id] = true
			g_arma_prim[id] = ARMA_TACTICALAWP
			
			// Set Health [0 = auto]
			if (get_pcvar_num(cvar_sniperhp) == 0)
			{
				if (get_pcvar_num(cvar_sniperbasehp) == 0)
					fm_set_user_health(id, 100 * fnGetAlive())
				else
					fm_set_user_health(id, get_pcvar_num(cvar_sniperbasehp) * fnGetAlive())
			}
			else
				fm_set_user_health(id, get_pcvar_num(cvar_sniperhp))
			
			// Set gravity, unless frozen
			if (!g_frozen[id]) set_pev(id, pev_gravity, get_pcvar_float(cvar_snipergravity))
			
			// Give sniper his own weapon and fill the ammo
			fm_strip_user_weapons(id)
			fm_give_item(id, "weapon_knife")
			fm_give_item(id, "weapon_awp")
			ExecuteHamB(Ham_GiveAmmo, id, MAXBPAMMO[CSW_AWP], AMMOTYPE[CSW_AWP], MAXBPAMMO[CSW_AWP])
			
			// Turn off his flashlight
			turn_off_flashlight(id)
			
			// Give the sniper a nice aura
			if (get_pcvar_num(cvar_sniperaura))
				set_task(0.1, "human_aura", id+TASK_AURA, _, _, "b")
				
			iRand = random_num(0, ArraySize(model_sniper) - 1)
			ArrayGetString(model_sniper, iRand, g_playermodel[id], charsmax(g_playermodel[]))
		}
		case 6:
		{
			// Wesker
			g_wesker[id] = true
			g_arma_sec[id] = 17
			
			// Set Health [0 = auto]
			if (get_pcvar_num(cvar_weskerhp) == 0)
			{
				if (get_pcvar_num(cvar_weskerbasehp) == 0)
					fm_set_user_health(id, 100 * fnGetAlive())
				else
					fm_set_user_health(id, get_pcvar_num(cvar_weskerbasehp) * fnGetAlive())
			}
			else
				fm_set_user_health(id, get_pcvar_num(cvar_weskerhp))
			
			// Set gravity, unless frozen
			if (!g_frozen[id]) set_pev(id, pev_gravity, get_pcvar_float(cvar_weskergravity))
			
			// Give deagle his own weapon and fill the ammo
			fm_strip_user_weapons(id)
			fm_give_item(id, "weapon_knife")
			fm_give_item(id, "weapon_deagle")
			ExecuteHamB(Ham_GiveAmmo, id, MAXBPAMMO[CSW_DEAGLE], AMMOTYPE[CSW_DEAGLE], MAXBPAMMO[CSW_DEAGLE])
			
			// Turn off his flashlight
			turn_off_flashlight(id)
			
			// Give the wesker a nice aura
			if (get_pcvar_num(cvar_weskeraura))
				set_task(0.1, "human_aura", id+TASK_AURA, _, _, "b")
				
			iRand = random_num(0, ArraySize(model_wesker) - 1)
			ArrayGetString(model_wesker, iRand, g_playermodel[id], charsmax(g_playermodel[]))
		}
		case 7:
		{
			// L4D
			g_l4d[id][0] = true
			L4D(id)
			iRand = random_num(0, ArraySize(model_bill) - 1)
			ArrayGetString(model_bill, iRand, g_playermodel[id], charsmax(g_playermodel[]))
			zp_colored_print(id , "%s Has Sido Escojido Como^x04 Bill^x01 , Refugiate Con Tus Companeros", TAG)
			zp_colored_print(id , "%s Has Sido Escojido Como^x04 Bill^x01 , Refugiate Con Tus Companeros", TAG)
			zp_colored_print(id , "%s Has Sido Escojido Como^x04 Bill^x01 , Refugiate Con Tus Companeros", TAG)
			zp_colored_print(id , "%s Has Sido Escojido Como^x04 Bill^x01 , Refugiate Con Tus Companeros", TAG)
		}
		case 8:
		{
			// L4D
			g_l4d[id][1] = true
			L4D(id)
			iRand = random_num(0, ArraySize(model_francis) - 1)
			ArrayGetString(model_francis, iRand, g_playermodel[id], charsmax(g_playermodel[]))
			zp_colored_print(id , "%s Has Sido Escojido Como^x04 Francis^x01 , Refugiate Con Tus Companeros", TAG)
			zp_colored_print(id , "%s Has Sido Escojido Como^x04 Francis^x01 , Refugiate Con Tus Companeros", TAG)
			zp_colored_print(id , "%s Has Sido Escojido Como^x04 Francis^x01 , Refugiate Con Tus Companeros", TAG)
			zp_colored_print(id , "%s Has Sido Escojido Como^x04 Francis^x01 , Refugiate Con Tus Companeros", TAG)
		}
		case 9:
		{
			// L4D
			g_l4d[id][2] = true
			L4D(id)
			iRand = random_num(0, ArraySize(model_louis) - 1)
			ArrayGetString(model_louis, iRand, g_playermodel[id], charsmax(g_playermodel[]))
			zp_colored_print(id , "%s Has Sido Escojido Como^x04 Louis^x01 , Refugiate Con Tus Companeros", TAG)
			zp_colored_print(id , "%s Has Sido Escojido Como^x04 Louis^x01 , Refugiate Con Tus Companeros", TAG)
			zp_colored_print(id , "%s Has Sido Escojido Como^x04 Louis^x01 , Refugiate Con Tus Companeros", TAG)
			zp_colored_print(id , "%s Has Sido Escojido Como^x04 Louis^x01 , Refugiate Con Tus Companeros", TAG)
	
		}
		case 10:
		{
			// L4D
			g_l4d[id][3] = true
			L4D(id)
			iRand = random_num(0, ArraySize(model_zoey) - 1)
			ArrayGetString(model_zoey, iRand, g_playermodel[id], charsmax(g_playermodel[]))
			zp_colored_print(id , "%s Has Sido Escojido Como^x04 Zoey^x01 , Refugiate Con Tus Companeros", TAG)
			zp_colored_print(id , "%s Has Sido Escojido Como^x04 Zoey^x01 , Refugiate Con Tus Companeros", TAG)
			zp_colored_print(id , "%s Has Sido Escojido Como^x04 Zoey^x01 , Refugiate Con Tus Companeros", TAG)
			zp_colored_print(id , "%s Has Sido Escojido Como^x04 Zoey^x01 , Refugiate Con Tus Companeros", TAG)
		}
	}

	cs_set_player_model(id, g_playermodel[id])
	// Switch to CT
	if (fm_cs_get_user_team(id) != FM_CS_TEAM_CT) // need to change team?
	{
		remove_task(id+TASK_TEAM)
		fm_cs_set_user_team(id, FM_CS_TEAM_CT)
		fm_user_team_update(id)
	}
		
	fm_set_rendering(id)

	if(g_lnjround)
	{
		g_nvision[id] = true
		g_nvisionenabled[id] = true	
		remove_task(id+TASK_NVISION)
		set_task(0.1, "set_user_nvision", id+TASK_NVISION, _, _, "b")
	}
	
	// Restore FOV?
	if (get_pcvar_num(cvar_zombiefov) != 90 && get_pcvar_num(cvar_zombiefov) != 0)
	{
		message_begin(MSG_ONE, g_msgSetFOV, _, id)
		write_byte(90) // angle
		message_end()
	}
	
	if (!get_pcvar_num(cvar_customnvg) && g_nvisionenabled[id]) set_user_gnvision(id, 0)
	
	// Post user humanize forward
	ExecuteForward(g_fwUserHumanized_post, g_fwDummyResult, id, survivor)
	
	// Last Zombie Check
	fnCheckLastZombie()
}

/*================================================================================
 [Other Functions and Tasks]
=================================================================================*/

public cache_cvars()
{
	g_cached_customflash = get_pcvar_num(cvar_customflash)
	g_cached_nemspd = get_pcvar_float(cvar_nemspd)
	g_cached_survspd = get_pcvar_float(cvar_survspd)
	g_cached_humanspd = get_pcvar_float(cvar_humanspd)
	g_cached_leapzombies = get_pcvar_num(cvar_leapzombies)
	g_cached_leapzombiescooldown = get_pcvar_float(cvar_leapzombiescooldown)
	g_cached_leapnemesis = get_pcvar_num(cvar_leapnemesis)
	g_cached_leapnemesiscooldown = get_pcvar_float(cvar_leapnemesiscooldown)
	g_cached_leapsurvivor = get_pcvar_num(cvar_leapsurvivor)
	g_cached_leapsurvivorcooldown = get_pcvar_float(cvar_leapsurvivorcooldown)
	g_cached_sniperspd = get_pcvar_float(cvar_sniperspd)
	g_cached_weskerspd = get_pcvar_float(cvar_weskerspd)
	g_cached_deprespd = get_pcvar_float(cvar_deprespd)
	g_cached_ninjaspd = get_pcvar_float(cvar_ninjaspd)
	g_cached_leapninja = get_pcvar_num(cvar_leapninja)
	g_cached_leapninjacooldown = get_pcvar_float(cvar_leapninjacooldown)
	g_cached_assassinspd = get_pcvar_float(cvar_assassinspd)
	g_cached_leapassassin = get_pcvar_num(cvar_leapassassin)
	g_cached_leapassassincooldown = get_pcvar_float(cvar_leapassassincooldown)
	g_cached_alienspd = get_pcvar_float(cvar_alienspd)
	g_cached_l4dspd = get_pcvar_float(cvar_l4dspd)
}
// Disable minmodels task
public disable_minmodels(id)
{
	if (!g_isconnected[id]) return;
	client_cmd(id, "cl_minmodels 0")
}

// Refill BP Ammo Task
public refill_bpammo(const args[], id)
{
	// Player died or turned into a zombie
	if (!g_isalive[id] || g_zombie[id])
		return;
	
	set_msg_block(g_msgAmmoPickup, BLOCK_ONCE)
	ExecuteHamB(Ham_GiveAmmo, id, MAXBPAMMO[REFILL_WEAPONID], AMMOTYPE[REFILL_WEAPONID], MAXBPAMMO[REFILL_WEAPONID])
}

// Balance Teams Task
balance_teams()
{
	// Get amount of users playing
	static iPlayersnum
	iPlayersnum = fnGetPlaying()
	
	// No players, don't bother
	if (iPlayersnum < 1) return;
	
	// Split players evenly
	static iTerrors, iMaxTerrors, id, team[33]
	iMaxTerrors = iPlayersnum/2
	iTerrors = 0
	
	// First, set everyone to CT
	for (id = 1; id <= g_maxplayers; id++)
	{
		// Skip if not connected
		if (!g_isconnected[id])
			continue;
		
		team[id] = fm_cs_get_user_team(id)
		
		// Skip if not playing
		if (team[id] == FM_CS_TEAM_SPECTATOR || team[id] == FM_CS_TEAM_UNASSIGNED)
			continue;
		
		// Set team
		remove_task(id+TASK_TEAM)
		fm_cs_set_user_team(id, FM_CS_TEAM_CT)
		team[id] = FM_CS_TEAM_CT
	}
	
	// Then randomly set half of the players to Terrorists
	while (iTerrors < iMaxTerrors)
	{
		// Keep looping through all players
		if (++id > g_maxplayers) id = 1
		
		// Skip if not connected
		if (!g_isconnected[id])
			continue;
		
		// Skip if not playing or already a Terrorist
		if (team[id] != FM_CS_TEAM_CT)
			continue;
		
		// Random chance
		if (random_num(0, 1))
		{
			fm_cs_set_user_team(id, FM_CS_TEAM_T)
			team[id] = FM_CS_TEAM_T
			iTerrors++
		}
	}
}

// Welcome Message Task
public welcome_msg()
{
	// Show mod info
	zp_colored_print(0, "^x03 <%s^x04>^x03 [By: LA BANDA]", PLUGIN_NAME)
	
	// Show T-virus HUD notice
	set_dhudmessage(0, 160, 255, -1.0, 0.17, 0, 0.0, 4.0, 2.0, 1.0)
	show_dhudmessage(0, "%L", LANG_PLAYER, "NOTICE_VIRUS_FREE")
	set_task(7.0, "event2", TASK_COUNTDOWN)
}

public event2()
{
	set_dhudmessage(184, 0, 245, -1.0, 0.17, 1, 0.0, 7.0, 2.0, 1.0)
	show_dhudmessage(0, "La amenaza se aproxima al planeta tierra...")
	
	client_cmd(0, "spk fvox/biohazard_detected.wav")
}

// Check Round Task -check that we still have both zombies and humans on a round-
check_round(leaving_player)
{
	// Round ended or make_a_zombie task still active
	if (g_endround || task_exists(TASK_MAKEZOMBIE))
		return;
	
	// Get alive players count
	static iPlayersnum, id
	iPlayersnum = fnGetAlive()
	
	// Last alive player, don't bother
	if (iPlayersnum < 2)
		return;
	
	// Last zombie disconnecting
	if (g_zombie[leaving_player] && fnGetZombies() == 1)
	{
		// Only one CT left, don't bother
		if (fnGetHumans() == 1 && fnGetCTs() == 1)
			return;
		
		// Pick a random one to take his place
		while ((id = fnGetRandomAlive(random_num(1, iPlayersnum))) == leaving_player) { /* keep looping */ }
		
		// Show last zombie left notice
		zp_colored_print(0, "%s %L", TAG, LANG_PLAYER, "LAST_ZOMBIE_LEFT", g_playername[id])
		
		// Set player leaving flag
		g_lastplayerleaving = true
		
		// Turn into a Nemesis, Assassin, Alien or just a zombie?
		if (g_nemesis[leaving_player])
			zombieme(id, 0, 1, 0, 0)
		else if (g_assassin[leaving_player])
			zombieme(id, 0, 2, 0, 0)
		else if (g_alien[leaving_player])
			zombieme(id, 0, 3, 0, 0)
		else
			zombieme(id, 0, 0, 0, 0)
		
		// Remove player leaving flag
		g_lastplayerleaving = false
		
		// If Nemesis, set chosen player's health to that of the one who's leaving
		if (get_pcvar_num(cvar_keephealthondisconnect) && g_nemesis[leaving_player] || g_assassin[leaving_player] || g_alien[leaving_player])
			fm_set_user_health(id, pev(leaving_player, pev_health))
	}
	
	// Last human disconnecting
	else if (!g_zombie[leaving_player] && fnGetHumans() == 1)
	{
		// Only one T left, don't bother
		if (fnGetZombies() == 1 && fnGetTs() == 1)
			return;
		
		// Pick a random one to take his place
		while ((id = fnGetRandomAlive(random_num(1, iPlayersnum))) == leaving_player) { /* keep looping */ }
		
		// Show last human left notice
		zp_colored_print(0, "%s %L", TAG, LANG_PLAYER, "LAST_HUMAN_LEFT", g_playername[id])
		
		// Set player leaving flag
		g_lastplayerleaving = true
		
		// Turn into a Survivor, Sniper or just a human?
		if (g_survivor[leaving_player])
			humanme(id, 1, 0)
		else if (g_depre[leaving_player])
			humanme(id, 2, 0)
		else if (g_ninja[leaving_player])
			humanme(id, 3, 0)
		else if (g_sniper[leaving_player])
			humanme(id, 5, 0)
		else if (g_wesker[leaving_player])
			humanme(id, 6, 0)
		else if (g_l4d[leaving_player][0])
			humanme(id, 7, 0)
		else if (g_l4d[leaving_player][1])
			humanme(id, 8, 0)
		else if (g_l4d[leaving_player][2])
			humanme(id, 9, 0)
		else if (g_l4d[leaving_player][3])
			humanme(id, 10, 0)
		else
			humanme(id, 0, 0)
		
		// Remove player leaving flag
		g_lastplayerleaving = false
		
		// If Survivor, set chosen player's health to that of the one who's leaving
		if (get_pcvar_num(cvar_keephealthondisconnect) || g_survivor[leaving_player] || g_sniper[leaving_player]
		|| g_wesker[leaving_player] || g_depre[leaving_player] || g_ninja[leaving_player] || g_l4d[leaving_player][0] 
		|| g_l4d[leaving_player][1] || g_l4d[leaving_player][2] || g_l4d[leaving_player][3])
			fm_set_user_health(id, pev(leaving_player, pev_health))
	}
}

// Flashlight Charge Task
public flashlight_charge(taskid)
{
	if(!is_user_alive(ID_CHARGE))
		return
		
	// Drain or charge?
	if (g_flashlight[ID_CHARGE])
		g_flashbattery[ID_CHARGE] -= get_pcvar_num(cvar_flashdrain)
	else
		g_flashbattery[ID_CHARGE] += get_pcvar_num(cvar_flashcharge)
	
	// Battery fully charged
	if (g_flashbattery[ID_CHARGE] >= 100)
	{
		// Don't exceed 100%
		g_flashbattery[ID_CHARGE] = 100
		
		// Update flashlight battery on HUD
		message_begin(MSG_ONE, g_msgFlashBat, _, ID_CHARGE)
		write_byte(100) // battery
		message_end()
		
		// Task not needed anymore
		remove_task(taskid);
		return;
	}
	
	// Battery depleted
	if (g_flashbattery[ID_CHARGE] <= 0)
	{
		// Turn it off
		g_flashlight[ID_CHARGE] = false
		g_flashbattery[ID_CHARGE] = 0
		
		// Play flashlight toggle sound
		emit_sound(ID_CHARGE, CHAN_ITEM, "items/flashlight1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
		
		// Update flashlight status on HUD
		message_begin(MSG_ONE, g_msgFlashlight, _, ID_CHARGE)
		write_byte(0) // toggle
		write_byte(0) // battery
		message_end()
		
		// Remove flashlight task for this player
		remove_task(ID_CHARGE+TASK_FLASH)
	}
	else
	{
		// Update flashlight battery on HUD
		message_begin(MSG_ONE_UNRELIABLE, g_msgFlashBat, _, ID_CHARGE)
		write_byte(g_flashbattery[ID_CHARGE]) // battery
		message_end()
	}
}

// Remove Spawn Protection Task
public remove_spawn_protection(taskid)
{
	// Not alive
	if (!g_isalive[ID_SPAWN])
		return;
	
	// Remove spawn protection
	g_nodamage[ID_SPAWN] = false
	set_pev(ID_SPAWN, pev_effects, pev(ID_SPAWN, pev_effects) & ~EF_NODRAW)
}

// Hide Player's Money Task
public task_hide_money(taskid)
{
	// Not alive
	if (!g_isalive[ID_SPAWN])
		return;
	
	// Hide money
	message_begin(MSG_ONE, g_msgHideWeapon, _, ID_SPAWN)
	write_byte(HIDE_MONEY) // what to hide bitsum
	message_end()
	
	// Hide the HL crosshair that's drawn
	message_begin(MSG_ONE, g_msgCrosshair, _, ID_SPAWN)
	write_byte(0) // toggle
	message_end()
}

// Turn Off Flashlight and Restore Batteries
turn_off_flashlight(id)
{
	// Restore batteries for the next use
	fm_cs_set_user_batteries(id, 100)
	
	// Check if flashlight is on
	if (pev(id, pev_effects) & EF_DIMLIGHT)
	{
		// Turn it off
		set_pev(id, pev_impulse, IMPULSE_FLASHLIGHT)
	}
	else
	{
		// Clear any stored flashlight impulse (bugfix)
		set_pev(id, pev_impulse, 0)
	}
	
	// Turn off custom flashlight
	if (g_cached_customflash)
	{
		// Turn it off
		g_flashlight[id] = false
		g_flashbattery[id] = 100
		
		// Update flashlight HUD
		message_begin(MSG_ONE, g_msgFlashlight, _, id)
		write_byte(0) // toggle
		write_byte(100) // battery
		message_end()
		
		// Remove previous tasks
		remove_task(id+TASK_CHARGE)
		remove_task(id+TASK_FLASH)
	}
}

// Some one aimed at someone
public event_show_status(id)
{
	// Not a bot and is still connected
	if (g_isconnected[id] && get_pcvar_num(cvar_aiminfo)) 
	{
		// Retrieve the aimed player's id
		static aimid
		aimid = read_data(2)
		
		// Only show friends status ?
		if (g_zombie[id] == g_zombie[aimid])
		{
			static class[32]
			
			// Format the class name according to the player's team
			if (g_zombie[id])
			{
				
				if (g_nemesis[aimid])
					formatex(class, charsmax(class), "%L %L", id, "CLASS_CLASS", id, "CLASS_NEMESIS")
				else if (g_assassin[aimid])
					formatex(class, charsmax(class), "%L %L", id, "CLASS_CLASS", id, "CLASS_ASSASSIN")
				else if (g_alien[aimid])
					formatex(class, charsmax(class), "%L %L", id, "CLASS_CLASS", id, "CLASS_ALIEN")
				else
					copy(class, sizeof class - 1, g_zclass_name[g_zombieclass[aimid]])
			}
			else
			{
				
				if (g_survivor[aimid])
					formatex(class, charsmax(class), "%L %L", id, "CLASS_CLASS", id, "CLASS_SURVIVOR")
				else if (g_sniper[aimid])
					formatex(class, charsmax(class), "%L %L", id, "CLASS_CLASS", id, "CLASS_SNIPER")
				else if (g_wesker[aimid])
					formatex(class, charsmax(class), "%L %L", id, "CLASS_CLASS", id, "CLASS_WESKER")
				else if (g_depre[aimid])
					formatex(class, charsmax(class), "%L %L", id, "CLASS_CLASS", id, "CLASS_DEPRE")
				else if (g_l4d[aimid][0])
					formatex(class, charsmax(class), "%L %L", id, "CLASS_CLASS", id, "CLASS_BILL")
				else if (g_l4d[aimid][1])
					formatex(class, charsmax(class), "%L %L", id, "CLASS_CLASS", id, "CLASS_FRANCIS")
				else if (g_l4d[aimid][2])
					formatex(class, charsmax(class), "%L %L", id, "CLASS_CLASS", id, "CLASS_LOUIS")
				else if (g_l4d[aimid][3])
					formatex(class, charsmax(class), "%L %L", id, "CLASS_CLASS", id, "CLASS_ZOEY")
				else if (g_ninja[aimid])
					formatex(class, charsmax(class), "%L %L", id, "CLASS_CLASS", id, "CLASS_NINJA")
				else
					formatex(class, charsmax(class), "Humano %s", gHabilidadesHumanas[g_habilidad[id]][Nombre_Clase])
			}
			
			// Show the notice
			set_hudmessage(Colores[id][0], Colores[id][1], Colores[id][2], -1.0, 0.60, g_efecto[id], 0.01, 2.0, 0.01, 0.01, -1)
			ShowSyncHudMsg(id, g_MsgSync3, "%L", id, "AIM_INFO", g_playername[aimid], class, AddPuntos(get_user_health(aimid)), AddPuntos(get_user_armor(aimid)), AddPuntos(g_ammopacks[aimid]), g_level[aimid])
		}
	}
}


// Remove the aim-info message
public event_hide_status(id)
{
	ClearSyncHud(id, g_MsgSync3)
}

// Infection Bomb Explosion
infection_explode(ent)
{
	// Round ended (bugfix)
	if (g_endround) return;
	
	// Get origin
	static Float:originF[3]
	pev(ent, pev_origin, originF)
	
	// Make the explosion
	create_blast(originF)
	emit_sound(ent, CHAN_VOICE, "zombie_plague/grenade_infect.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
	
	// Get attacker
	static attacker
	attacker = pev(ent, pev_owner)
	
	// Collisions
	static victim
	victim = -1
	
	while ((victim = engfunc(EngFunc_FindEntityInSphere, victim, originF, NADE_EXPLOSION_RADIUS)) != 0)
	{
		// Only effect alive non-spawnprotected humans
		if (!is_user_valid_alive(victim) || g_zombie[victim] || g_nodamage[victim] || g_habilidad[victim] == HAB_ANTIBOMBAINF || g_antinfeccion[victim])
			continue;
		
		// Last human is killed
		if (fnGetHumans() == 1)
		{
			ExecuteHamB(Ham_Killed, victim, attacker, 0)
			continue;
		}
		emit_sound(victim, CHAN_VOICE, "scientist/scream22.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
		zombieme(victim, attacker, 0, 1, 1)
	}
	
	// Get rid of the grenade
	engfunc(EngFunc_RemoveEntity, ent)
}

// Fire Grenade Explosion
fire_explode(ent)
{
	static Float:originF[3]
	pev(ent, pev_origin, originF)
	
	create_blast2(originF)
	emit_sound(ent, CHAN_AUTO, "zombie_plague/grenade_explode.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	
	static victim
	victim = -1
	while ((victim = engfunc(EngFunc_FindEntityInSphere, victim, originF, NADE_EXPLOSION_RADIUS)) != 0)
	{
		if (!is_user_valid_alive(victim) || !g_zombie[victim] || g_nodamage[victim] || g_firstzombie[victim])
			continue;
		
		message_begin(MSG_ONE_UNRELIABLE, g_msgDamage, _, victim)
		write_byte(0)
		write_byte(0)
		write_long(DMG_BURN)
		write_coord(0)
		write_coord(0)
		write_coord(0)
		message_end()
		
		if (g_nemesis[victim] || g_assassin[victim] || g_antifuego[victim] || g_alien[victim]) // fire duration (nemesis/assassin/alien is fire resistant)
			g_burning_duration[victim] += get_pcvar_num(cvar_fireduration)
		else
			g_burning_duration[victim] += get_pcvar_num(cvar_fireduration) * 5
			
		if (!task_exists(victim+TASK_BURN))
			set_task(0.2, "burning_flame", victim+TASK_BURN, _, _, "b")
	}
	engfunc(EngFunc_RemoveEntity, ent)
}

antidotebomb_explode(ent)
{
	static Float:originF[3]
	pev(ent, pev_origin, originF)
	
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
	write_byte(TE_LAVASPLASH)
	engfunc(EngFunc_WriteCoord, originF[0]) // x
	engfunc(EngFunc_WriteCoord, originF[1]) // y
	engfunc(EngFunc_WriteCoord, originF[2]) // z
	message_end()
	
	static victim
	victim = -1
	
	static attacker
	attacker = pev(ent, pev_owner)
	
	while ((victim = engfunc(EngFunc_FindEntityInSphere, victim, originF, NADE_EXPLOSION_RADIUS)) != 0)
	{
		if (!is_user_valid_alive(victim) || !is_zombie(victim) || fnGetZombies() == 1 || !g_allowinfection)
			continue;
		
		CheckEXP(attacker, get_pcvar_num(gCvarsPlugin[EXP_DESINFECTAR][gCvarValor]), 0, "Desinfectar a un Zombie")	
		humanme(victim, 0, 0)
	}
	emit_sound(ent, CHAN_AUTO, "zpre4/antidotebomb_explosion.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	zp_colored_print(0, "%s ^x04[%s]^x01 Ha Tirado Una^x03 Granada de Desinfeccion.", TAG, g_playername[attacker])
	
	remove_entity(ent)
}

molotov_explode(ent)
{
	// Get origin
	static Float:originF[3]
	pev(ent, pev_origin, originF)
	
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
	write_byte(TE_EXPLOSION)
	engfunc(EngFunc_WriteCoord, originF[0]) // x
	engfunc(EngFunc_WriteCoord, originF[1]) // y
	engfunc(EngFunc_WriteCoord, originF[2]) // z
	write_short(g_molotovSpr)
	write_byte(40) 		// byte (scale in 0.1's) 188 - era 65
	write_byte(25) 		// byte (framerate)
	write_byte(0) 		// byte flags
	message_end()	
	
	emit_sound(ent, CHAN_AUTO, "zpre4/molotov_explosion.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	
	// Collisions
	static victim
	victim = -1
	
	while ((victim = engfunc(EngFunc_FindEntityInSphere, victim, originF, NADE_EXPLOSION_RADIUS)) != 0)
	{
		// Only effect alive zombies
		if (!is_user_valid_alive(victim) || !g_zombie[victim] || g_firstzombie[victim] || g_nodamage[victim])
			continue;
		
		message_begin(MSG_ONE_UNRELIABLE, g_msgDamage, _, victim)
		write_byte(0) // damage save
		write_byte(0) // damage take
		write_long(DMG_BURN) // damage type
		write_coord(0) // x
		write_coord(0) // y
		write_coord(0) // z
		message_end()
		
		if (g_nemesis[victim] || g_assassin[victim] || g_antifuego[victim] || g_alien[victim]) // fire duration (nemesis is fire resistant)
			g_burning_duration[victim] += get_pcvar_num(cvar_fireduration)
		else
			g_burning_duration[victim] += get_pcvar_num(cvar_fireduration) * 5
		
		// Set burning task on victim if not present
		if (!task_exists(victim+TASK_BURN))
			set_task(0.2, "burning_flame", victim+TASK_BURN, _, _, "b")
	}
	
	// Get rid of the grenade
	engfunc(EngFunc_RemoveEntity, ent)	
}

// Frost Grenade Explosion
frost_explode(ent)
{
	// Get origin
	static Float:originF[3]
	pev(ent, pev_origin, originF)
	
	// Make the explosion
	create_blast3(originF)
	
	// Frost nade explode sound
	emit_sound(ent, CHAN_AUTO, "warcraft3/frostnova.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	
	// Collisions
	static victim
	victim = -1
	
	while ((victim = engfunc(EngFunc_FindEntityInSphere, victim, originF, NADE_EXPLOSION_RADIUS)) != 0)
	{
		// Only effect alive unfrozen zombies
		if (!is_user_valid_alive(victim) || !g_zombie[victim] || g_firstzombie[victim] || g_antihielo[victim] || g_frozen[victim] || g_nodamage[victim])
			continue;
		
		// Nemesis and Assassin shouldn't be frozen
		if (g_nemesis[victim] || g_assassin[victim])
		{
			// Get player's origin
			static origin2[3]
			get_user_origin(victim, origin2)
			
			emit_sound(victim, CHAN_AUTO, "warcraft3/impalelaunch1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
			
			// Glass shatter
			message_begin(MSG_PVS, SVC_TEMPENTITY, origin2)
			write_byte(TE_BREAKMODEL) // TE id
			write_coord(origin2[0]) // x
			write_coord(origin2[1]) // y
			write_coord(origin2[2]+24) // z
			write_coord(16) // size x
			write_coord(16) // size y
			write_coord(16) // size z
			write_coord(random_num(-50, 50)) // velocity x
			write_coord(random_num(-50, 50)) // velocity y
			write_coord(25) // velocity z
			write_byte(10) // random velocity
			write_short(g_glassSpr) // model
			write_byte(10) // count
			write_byte(25) // life
			write_byte(BREAK_GLASS) // flags
			message_end()
			
			continue;
		}
		
		message_begin(MSG_ONE_UNRELIABLE, g_msgDamage, _, victim)
		write_byte(0) // damage save
		write_byte(0) // damage take
		write_long(DMG_DROWN) // damage type - DMG_FREEZE
		write_coord(0) // x
		write_coord(0) // y
		write_coord(0) // z
		message_end()
		
		fm_set_rendering(victim, kRenderFxGlowShell, 0, 100, 200, kRenderNormal, 100)
		
		// Freeze sound
		emit_sound(victim, CHAN_AUTO, "warcraft3/impalehit.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		
		// Add a blue tint to their screen
		message_begin(MSG_ONE, g_msgScreenFade, _, victim)
		write_short(0) // duration
		write_short(0) // hold time
		write_short(FFADE_STAYOUT) // fade type
		write_byte(0) // red
		write_byte(50) // green
		write_byte(200) // blue
		write_byte(100) // alpha
		message_end()
		
		// Prevent from jumping
		if (pev(victim, pev_flags) & FL_ONGROUND)
			set_pev(victim, pev_gravity, 999999.9) // set really high
		else
			set_pev(victim, pev_gravity, 0.000001) // no gravity
		
		// Set a task to remove the freeze
		g_frozen[victim] = true;
		set_task(get_pcvar_float(cvar_freezeduration), "remove_freeze", victim)
	}
	
	// Get rid of the grenade
	engfunc(EngFunc_RemoveEntity, ent)
}

// Remove freeze task
public remove_freeze(id)
{
	// Not alive or not frozen anymore
	if (!g_isalive[id] || !g_frozen[id])
		return;
	
	// Unfreeze
	g_frozen[id] = false;
	Remove(id)
	
	if (g_alien[id] && get_pcvar_num(cvar_alienglow)) 
		fm_set_rendering(id, kRenderFxGlowShell, 184, 0, 245, kRenderNormal, 25) 
	else
		fm_set_rendering(id)
	
	// Gradually remove screen's blue tint
	message_begin(MSG_ONE, g_msgScreenFade, _, id)
	write_short(UNIT_SECOND) // duration
	write_short(0) // hold time
	write_short(FFADE_IN) // fade type
	write_byte(0) // red
	write_byte(50) // green
	write_byte(200) // blue
	write_byte(100) // alpha
	message_end()
	
	// Broken glass sound
	emit_sound(id, CHAN_AUTO, "warcraft3/impalelaunch1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	
	// Get player's origin
	static origin2[3]
	get_user_origin(id, origin2)
	
	// Glass shatter
	message_begin(MSG_PVS, SVC_TEMPENTITY, origin2)
	write_byte(TE_BREAKMODEL) // TE id
	write_coord(origin2[0]) // x
	write_coord(origin2[1]) // y
	write_coord(origin2[2]+24) // z
	write_coord(16) // size x
	write_coord(16) // size y
	write_coord(16) // size z
	write_coord(random_num(-50, 50)) // velocity x
	write_coord(random_num(-50, 50)) // velocity y
	write_coord(25) // velocity z
	write_byte(10) // random velocity
	write_short(g_glassSpr) // model
	write_byte(10) // count
	write_byte(25) // life
	write_byte(BREAK_GLASS) // flags
	message_end()
	
	ExecuteForward(g_fwUserUnfrozen, g_fwDummyResult, id);
}

public Remove(id)
{
	// Restore gravity
	if (g_zombie[id])
	{
		if (g_nemesis[id])
			set_pev(id, pev_gravity, get_pcvar_float(cvar_nemgravity))
		else if (g_assassin[id])
			set_pev(id, pev_gravity, get_pcvar_float(cvar_assassingravity))
		else if (g_alien[id])
			set_pev(id, pev_gravity, get_pcvar_float(cvar_aliengravity))
		else
			set_pev(id, pev_gravity, g_zclass_grav[g_zombieclass[id]])
	}
	else
	{
		if (g_survivor[id])
			set_pev(id, pev_gravity, get_pcvar_float(cvar_survgravity))
		else if (g_sniper[id])
			set_pev(id, pev_gravity, get_pcvar_float(cvar_snipergravity))
		else if (g_wesker[id])
			set_pev(id, pev_gravity, get_pcvar_float(cvar_weskergravity))
		else if (g_depre[id])
			set_pev(id, pev_gravity, get_pcvar_float(cvar_depregravity))
		else if (g_ninja[id])
			set_pev(id, pev_gravity, get_pcvar_float(cvar_ninjagravity))
		else if (g_l4d[id][0])
			set_pev(id, pev_gravity, get_pcvar_float(cvar_l4dgravity))
		else if (g_l4d[id][1])
			set_pev(id, pev_gravity, get_pcvar_float(cvar_l4dgravity))
		else if (g_l4d[id][2])
			set_pev(id, pev_gravity, get_pcvar_float(cvar_l4dgravity))
		else if (g_l4d[id][3])
			set_pev(id, pev_gravity, get_pcvar_float(cvar_l4dgravity))
		else
			set_pev(id, pev_gravity, 1.0 - ammount_gravity(g_mejoras[id][3]))
	}
}

// Remove Stuff Task
public remove_stuff()
{
	static ent
	
	// Remove rotating doors
	if (get_pcvar_num(cvar_removedoors) > 0)
	{
		ent = -1;
		while ((ent = engfunc(EngFunc_FindEntityByString, ent, "classname", "func_door_rotating")) != 0)
			engfunc(EngFunc_SetOrigin, ent, Float:{8192.0 ,8192.0 ,8192.0})
	}
	
	// Remove all doors
	if (get_pcvar_num(cvar_removedoors) > 1)
	{
		ent = -1;
		while ((ent = engfunc(EngFunc_FindEntityByString, ent, "classname", "func_door")) != 0)
			engfunc(EngFunc_SetOrigin, ent, Float:{8192.0 ,8192.0 ,8192.0})
	}
	
	// Triggered lights
	if (!get_pcvar_num(cvar_triggered))
	{
		ent = -1
		while ((ent = engfunc(EngFunc_FindEntityByString, ent, "classname", "light")) != 0)
		{
			dllfunc(DLLFunc_Use, ent, 0); // turn off the light
			set_pev(ent, pev_targetname, 0) // prevent it from being triggered
		}
	}
}

// Set Custom Weapon Models
replace_weapon_models(id, weaponid)
{
	switch (weaponid)
	{
		case CSW_KNIFE: // Custom knife models
		{
			if (g_zombie[id])
			{
				if (g_alien[id]) // Alien
				{
					set_pev(id, pev_viewmodel2, gModelsManos[MODEL_VKNIFE_ALIEN])
					set_pev(id, pev_weaponmodel2, "")
				}
				else if (g_assassin[id])
				{
					set_pev(id, pev_viewmodel2, gModelsManos[MODEL_VKNIFE_ASSASSIN])
					set_pev(id, pev_weaponmodel2, "")
				}
				else if (g_nemesis[id])
				{
					set_pev(id, pev_viewmodel2, gModelsManos[MODEL_VKNIFE_NEMESIS])
					set_pev(id, pev_weaponmodel2, "")
				}
				else // Zombies
				{
					static clawmodel[100]
					formatex(clawmodel, sizeof clawmodel - 1, "models/zpre4/%s", g_zclass_clawmodel[g_zombieclass[id]])	
					set_pev(id, pev_viewmodel2, clawmodel)
					set_pev(id, pev_weaponmodel2, "")
				}
			}
			else // Humans
			{
				if (g_depreknife[id])
				{
					set_pev(id, pev_viewmodel2, "models/zpre4/v_knife_depredador_golden.mdl")
					set_pev(id, pev_weaponmodel2, "")
				}
				else if (g_survivor[id])
				{
					set_pev(id, pev_viewmodel2, "models/zpre4/v_knife_survivor.mdl")
					set_pev(id, pev_weaponmodel2, "models/zpre4/p_knife_survivor.mdl")
				}
				else if (g_wesker[id])
				{
					set_pev(id, pev_viewmodel2, "models/zpre4/v_knife_wesker.mdl")
					set_pev(id, pev_weaponmodel2, "")
				}
				else if (g_sniper[id])
				{
					set_pev(id, pev_viewmodel2, "models/zpre4/v_knife_sniper.mdl")
					set_pev(id, pev_weaponmodel2, "")
				}
				else if (g_ninjasable[id])
				{
					set_pev(id, pev_viewmodel2, "models/zpre4/v_sable_ninja.mdl")
					set_pev(id, pev_weaponmodel2, "models/zpre4/p_sable_ninja.mdl")
				}
				else
				{
					set_pev(id, pev_viewmodel2, "models/v_knife.mdl")
					set_pev(id, pev_weaponmodel2, "models/p_knife.mdl")
				}
			}
		}
		case CSW_HEGRENADE: // Infection bomb or fire grenade
		{
			if (g_zombie[id] && !g_newround && !g_endround)
			{
				set_pev(id, pev_viewmodel2, gModelsManos[MODEL_VGRENADE_INFECT])
				set_pev(id, pev_weaponmodel2, gModelsManos[MODEL_PGRENADE_INFECT])
			}
			else if (has_molotov[id])
			{
				set_pev(id, pev_viewmodel2, gModelsManos[MODEL_VGRENADE_MOLOTOV])
				set_pev(id, pev_weaponmodel2, gModelsManos[MODEL_PGRENADE_MOLOTOV])
			}
			else if (g_antidotebomb[id])
			{
				set_pev(id, pev_viewmodel2, gModelsManos[MODEL_VGRENADE_ANTIDOTO])
				set_pev(id, pev_weaponmodel2, gModelsManos[MODEL_PGRENADE_ANTIDOTO])
			}
			else
			{
				set_pev(id, pev_viewmodel2, gModelsManos[MODEL_VGRENADE_FUEGO])
				set_pev(id, pev_weaponmodel2, gModelsManos[MODEL_PGRENADE_FUEGO])
			}
		}
		case CSW_FLASHBANG: // Frost grenade
		{
			set_pev(id, pev_viewmodel2, gModelsManos[MODEL_VGRENADE_FROST])
			set_pev(id, pev_weaponmodel2, gModelsManos[MODEL_PGRENADE_FROST])
		}
		case CSW_SMOKEGRENADE: // Flare grenade
		{
			if(has_burbuja[id])
			{
				set_pev(id, pev_viewmodel2, gModelsManos[MODEL_VGRENADE_BURBUJA])
				set_pev(id, pev_weaponmodel2, gModelsManos[MODEL_PGRENADE_BURBUJA])
			}
			else
			{
				set_pev(id, pev_viewmodel2, gModelsManos[MODEL_VGRENADE_FLARE])
				set_pev(id, pev_weaponmodel2, gModelsManos[MODEL_PGRENADE_FLARE])
			}
		}
	}
	if(weaponid == gArmasOptimizadas[g_arma_prim[id]][gWeapon])
	{
		if(!equal(gArmasOptimizadas[g_arma_prim[id]][gvModelo] , "default"))
			set_pev(id , pev_viewmodel2 , gArmasOptimizadas[g_arma_prim[id]][gvModelo])
		if(!equal(gArmasOptimizadas[g_arma_prim[id]][gpModelo] , "default"))
			set_pev(id , pev_weaponmodel2 , gArmasOptimizadas[g_arma_prim[id]][gpModelo])
	}
	if(weaponid == gPistolasOptimizadas[g_arma_sec[id]][gWeapon])
	{
		if(!equal(gPistolasOptimizadas[g_arma_sec[id]][gvModelo] , "default"))
			set_pev(id , pev_viewmodel2 , gPistolasOptimizadas[g_arma_sec[id]][gvModelo])
		if(!equal(gPistolasOptimizadas[g_arma_sec[id]][gpModelo] , "default"))
			set_pev(id , pev_weaponmodel2 , gPistolasOptimizadas[g_arma_sec[id]][gpModelo])
	}
	if(is_human(id))
	{
		if(weaponid == CSW_KNIFE)
		{
			if(!equal(gCuchillosOptimizadas[g_arma_four[id]][Modelo_Cuchi_V] , "default"))
				set_pev(id , pev_viewmodel2 , gCuchillosOptimizadas[g_arma_four[id]][Modelo_Cuchi_V])
			if(!equal(gCuchillosOptimizadas[g_arma_four[id]][Modelo_Cuchi_P] , "default"))
				set_pev(id , pev_weaponmodel2 , gCuchillosOptimizadas[g_arma_four[id]][Modelo_Cuchi_P])
		}
	}
	fm_set_weaponmodel_ent(id)
	return HAM_IGNORED
}

// Set Weapon Model on Entity
stock fm_set_weaponmodel_ent(id)
{
	// Get player's p_ weapon model
	static model[100]
	pev(id, pev_weaponmodel2, model, sizeof model - 1)
	
	// Set model on entity or make a new one if unexistant
	if (!pev_valid(g_ent_weaponmodel[id]))
	{
		g_ent_weaponmodel[id] = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
		if (!pev_valid(g_ent_weaponmodel[id])) return;
		
		set_pev(g_ent_weaponmodel[id], pev_classname, WEAPON_ENT_CLASSNAME)
		set_pev(g_ent_weaponmodel[id], pev_movetype, MOVETYPE_FOLLOW)
		set_pev(g_ent_weaponmodel[id], pev_aiment, id)
		set_pev(g_ent_weaponmodel[id], pev_owner, id)
	}
	
	engfunc(EngFunc_SetModel, g_ent_weaponmodel[id], model)
}

// Reset Player Vars
reset_vars(id, resetall)
{
	g_zombie[id] = false
	g_nemesis[id] = false
	g_survivor[id] = false
	g_firstzombie[id] = false
	g_lastzombie[id] = false
	g_lasthuman[id] = false
	g_sniper[id] = false
	g_wesker[id] = false
	g_depre[id] = false
	g_assassin[id] = false
	g_alien[id] = false
	g_l4d[id][0] = false
	g_l4d[id][1] = false
	g_l4d[id][2] = false
	g_l4d[id][3] = false
	g_ninja[id] = false
	Resetear_Armas(id)
	g_frozen[id] = false
	g_nodamage[id] = false
	g_respawn_as_zombie[id] = false
	g_nvision[id] = false
	g_nvisionenabled[id] = false
	g_flashlight[id] = false
	g_flashbattery[id] = 100
	g_canbuy[id] = true
	g_canbuy_sec[id] = true
	g_canbuy_tri[id] = true
	g_canbuy_four[id] = true
	g_burning_duration[id] = 0
	
	if (resetall)
	{
		g_Estado[id] = Conectado
		remove_tasks(id)
		g_isconnected[id] = true
		g_hud_pos[id][0] = 0.93
		g_hud_pos[id][1] = 0.15
		g_radar_detecta_humanos[id] = false
		g_radar_detecta_zombies[id] = false
		g_ThermalOn[id] = false
		g_efecto[id] = 0
		for(new i = 0; i < 15; i++) Colores[id][i] = 128
		changing_name[id] = false
		Colores[id][6] = 0
		Colores[id][7] = 128
		Colores[id][8] = 0
		g_save_weapons[id][0] = false
		g_save_weapons[id][1] = -1
		g_save_weapons[id][2] = -1
		g_save_weapons[id][3] = -1
		g_save_weapons[id][4] = -1
		g_arma_prim[id] = 0
		g_arma_sec[id] = 0
		g_antilaser[id] = false
		g_antifuego[id] = false
		g_antihielo[id] = false
		g_canRespawn[id] = false
		g_ammopacks[id] = 50
		g_zombieclass[id] = ZCLASS_NONE
		g_zombieclassnext[id] = ZCLASS_NONE
		g_habilidad[id] = 0
		g_habilidadnext[id] = 0
		MENU_PAGE_ZCLASS = 0
		MENU_PAGE_EXTRAS = 0
		MENU_PAGE_PLAYERS = 0
		MENU_PAGE_ADMIN0 = 0
		MENU_PAGE_ADMIN1 = 0
		MENU_PAGE_ADMIN2 = 0
		PL_ACTION = 0
		g_damagedealt[id] = 0
	}
}
// Set spectators nightvision
public spec_nvision(id)
{
	// Not connected, alive, or bot
	if (!g_isconnected[id] || g_isalive[id])
		return;
	
	// Give Night Vision?
	if (get_pcvar_num(cvar_nvggive))
	{
		g_nvision[id] = true
		
		// Turn on Night Vision automatically?
		if (get_pcvar_num(cvar_nvggive) == 1)
		{
			g_nvisionenabled[id] = true
			
			// Custom nvg?
			if (get_pcvar_num(cvar_customnvg))
			{
				remove_task(id+TASK_NVISION)
				set_task(0.1, "set_user_nvision", id+TASK_NVISION, _, _, "b")
			}
			else
				set_user_gnvision(id, 1)
		}
	}
}
const PEV_SPEC_TARGET = pev_iuser2
// Show HUD Task
public ShowHUD(taskid)
{
	static id
	id = ID_SHOWHUD;	
	
	// Player died?
	if (!g_isalive[id])
	{
		// Get spectating target
		id = pev(id, PEV_SPEC_TARGET)
		
		// Target not alive
		if (!g_isalive[id]) return;
	}
	
	// Format classname
	static class[32]
	
	if (g_zombie[id]) // zombies
	{
		if (g_nemesis[id])
			formatex(class, charsmax(class), "Clase:  %L", ID_SHOWHUD, "CLASS_NEMESIS")
		else if (g_assassin[id])
			formatex(class, charsmax(class), "Clase: %L", ID_SHOWHUD, "CLASS_ASSASSIN")
		else if (g_alien[id])
			formatex(class, charsmax(class), "Clase:  %L", ID_SHOWHUD, "CLASS_ALIEN")
		else
			formatex(class, charsmax(class), "Zombie %s", g_zclass_name[g_zombieclass[id]])
	}
	else // humans
	{
		if (g_survivor[id])
			formatex(class, charsmax(class), "Clase: Survivor")
		else if (g_sniper[id])
			formatex(class, charsmax(class), "Clase: Sniper")
		else if (g_wesker[id])
			formatex(class, charsmax(class), "Clase: Wesker")
		else if (g_depre[id])
			formatex(class, charsmax(class), "Clase: Depredador")
		else if (g_l4d[id][0])
			formatex(class, charsmax(class), "Clase: L4D Bill")
		else if (g_l4d[id][1])
			formatex(class, charsmax(class), "Clase: L4D Francis")
		else if (g_l4d[id][2])
			formatex(class, charsmax(class), "Clase: L4D Louis")
		else if (g_l4d[id][3])
			formatex(class, charsmax(class), "Clase: L4D Zoey")
		else if (g_ninja[id])
			formatex(class, charsmax(class), "Clase: Ninja")
		else
			formatex(class, charsmax(class), "Humano %s", gHabilidadesHumanas[g_habilidad[id]][Nombre_Clase])
	}
	
	// Spectating someone else?
	if (id != ID_SHOWHUD)
	{
		// Show name, health, class, and ammo packs and armor
		set_hudmessage(Colores[ID_SHOWHUD][0], Colores[ID_SHOWHUD][1], Colores[ID_SHOWHUD][2], g_hud_pos[ID_SHOWHUD][0], g_hud_pos[ID_SHOWHUD][1], g_efecto[ID_SHOWHUD], 6.0, 1.1, 0.0, 0.0, -1)
		ShowSyncHudMsg(ID_SHOWHUD, g_MsgSync2, "%s^nJugador: %s^n[%s]^n[Nivel: %d/300 | EXP: %s/%s]^n[Salud: %s | Chaleco: %s]^n[AmmoPacks: %s]^n[Resets: %s | Puntos: %s]", PLUGIN_NAME, g_playername[id],
		class, g_level[id], AddPuntos(g_exp[id]), AddPuntos(Exp_Level(g_level[id])), AddPuntos(get_user_health(id)), AddPuntos(get_user_armor(id)), AddPuntos(g_ammopacks[id]), AddPuntos(g_reset[id]), AddPuntos(g_puntos[id]))
	}
	else
	{
		// Show health, class and ammo packs and armor
		set_hudmessage(Colores[id][0], Colores[id][1], Colores[id][2], g_hud_pos[id][0], g_hud_pos[id][1], g_efecto[id], 6.0, 1.1, 0.0, 0.0, -1)
		ShowSyncHudMsg(ID_SHOWHUD, g_MsgSync2, "%s^n[%s]^n[Nivel: %d/300 | EXP: %s/%s]^n[Salud: %s | Chaleco: %s]^n[AmmoPacks: %s]^n[Resets: %s | Puntos: %s]", PLUGIN_NAME, class, g_level[ID_SHOWHUD], AddPuntos(g_exp[ID_SHOWHUD]), AddPuntos(Exp_Level(g_level[ID_SHOWHUD])), AddPuntos(get_user_health(ID_SHOWHUD)),AddPuntos(get_user_armor(ID_SHOWHUD)),
		AddPuntos(g_ammopacks[ID_SHOWHUD]), AddPuntos(g_reset[ID_SHOWHUD]), AddPuntos(g_puntos[ID_SHOWHUD]))
	}
}

// Play idle zombie sounds
public zombie_play_idle(taskid)
{
	if (g_endround || g_newround) return;
	
	if (g_lastzombie[ID_BLOOD])
		emit_sound(ID_BLOOD, CHAN_AUTO, "nihilanth/nil_thelast.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	else
		emit_sound(ID_BLOOD, CHAN_VOICE, zombie_idle[random_num(0, sizeof zombie_idle - 1)], 1.0, ATTN_NORM, 0, PITCH_NORM)
}

// Madness Over Task
public madness_over(taskid)
{
	g_zombiefuria[ID_BLOOD] = false
	g_nodamage[ID_BLOOD] = false
}

// Place user at a random spawn
do_random_spawn(id, regularspawns = 0)
{
	static hull, sp_id, i
	
	// Get whether the player is crouching
	hull = (pev(id, pev_flags) & FL_DUCKING) ? HULL_HEAD : HULL_HUMAN
	
	// Use regular spawns?
	if (!regularspawns)
	{
		// No spawns?
		if (!g_spawnCount)
			return;
		
		// Choose random spawn to start looping at
		sp_id = random_num(0, g_spawnCount - 1)
		
		// Try to find a clear spawn
		for (i = sp_id + 1; /*no condition*/; i++)
		{
			// Start over when we reach the end
			if (i >= g_spawnCount) i = 0
			
			// Free spawn space?
			if (is_hull_vacant(g_spawns[i], hull))
			{
				// Engfunc_SetOrigin is used so ent's mins and maxs get updated instantly
				engfunc(EngFunc_SetOrigin, id, g_spawns[i])
				break;
			}
			
			// Loop completed, no free space found
			if (i == sp_id) break;
		}
	}
	else
	{
		// No spawns?
		if (!g_spawnCount2)
			return;
		
		// Choose random spawn to start looping at
		sp_id = random_num(0, g_spawnCount2 - 1)
		
		// Try to find a clear spawn
		for (i = sp_id + 1; /*no condition*/; i++)
		{
			// Start over when we reach the end
			if (i >= g_spawnCount2) i = 0
			
			// Free spawn space?
			if (is_hull_vacant(g_spawns2[i], hull))
			{
				// Engfunc_SetOrigin is used so ent's mins and maxs get updated instantly
				engfunc(EngFunc_SetOrigin, id, g_spawns2[i])
				break;
			}
			
			// Loop completed, no free space found
			if (i == sp_id) break;
		}
	}
}

// Get Zombies -returns alive zombies number-
fnGetZombies()
{
	static ids, id
	ids = 0
	
	for (id = 1; id <= g_maxplayers; id++)
	{
		if (g_isalive[id] && g_zombie[id])
			ids++
	}
	
	return ids;
}

// Get Humans -returns alive humans number-
fnGetHumans()
{
	static iHumans, id
	iHumans = 0
	
	for (id = 1; id <= g_maxplayers; id++)
	{
		if (g_isalive[id] && !g_zombie[id])
			iHumans++
	}
	
	return iHumans;
}

// Get Nemesis -returns alive nemesis number-
fnGetNemesis()
{
	static iNemesis, id
	iNemesis = 0
	
	for (id = 1; id <= g_maxplayers; id++)
	{
		if (g_isalive[id] && g_nemesis[id])
			iNemesis++
	}
	
	return iNemesis;
}

// Get Survivors -returns alive survivors number-
fnGetSurvivors()
{
	static iSurvivors, id
	iSurvivors = 0
	
	for (id = 1; id <= g_maxplayers; id++)
	{
		if (g_isalive[id] && g_survivor[id])
			iSurvivors++
	}
	
	return iSurvivors;
}

// Get Snipers -returns alive snipers number-
fnGetSnipers()
{
	static iSnipers, id
	iSnipers = 0
	
	for (id = 1; id <= g_maxplayers; id++)
	{
		if (g_isalive[id] && g_sniper[id])
			iSnipers++
	}
	
	return iSnipers;
}

// Get Weskers -returns alive Weskers number-
fnGetWeskers()
{
	static iWeskers, id
	iWeskers = 0
	
	for (id = 1; id <= g_maxplayers; id++)
	{
		if (g_isalive[id] && g_wesker[id])
			iWeskers++
	}
	
	return iWeskers;
}

// Get Depredadors -returns alive Depredadors number-
fnGetDepres()
{
	static iDepres, id
	iDepres = 0
	
	for (id = 1; id <= g_maxplayers; id++)
	{
		if (g_isalive[id] && g_depre[id])
			iDepres++
	}
	
	return iDepres;
}

// Get L4Ds -returns alive L4ds number-
fnGetL4Ds()
{
	static iL4Ds, id
	iL4Ds = 0
	
	for (id = 1; id <= g_maxplayers; id++)
	{
		if (g_isalive[id] && g_l4d[id][0] || g_l4d[id][1] || g_l4d[id][2] || g_l4d[id][3])
			iL4Ds++
	}
	
	return iL4Ds;
}

// Get Ninjas -returns alive Ninjas number-
fnGetNinjas()
{
	static iNinjas, id
	iNinjas = 0
	
	for (id = 1; id <= g_maxplayers; id++)
	{
		if (g_isalive[id] && g_ninja[id])
			iNinjas++
	}
	
	return iNinjas;
}

// Get Assassins -returns alive assassin numbers-
fnGetAssassin()
{
	static iAssassin, id
	iAssassin = 0
	
	for (id = 1; id <= g_maxplayers; id++)
	{
		if (g_isalive[id] && g_assassin[id])
			iAssassin++
	}
	
	return iAssassin;
}
// Get Aliens -returns alive alien numbers-
fnGetAlien()
{
	static iAlien, id
	iAlien = 0
	
	for (id = 1; id <= g_maxplayers; id++)
	{
		if (g_isalive[id] && g_alien[id])
			iAlien++
	}
	
	return iAlien;
}

// Get Alive -returns alive players number-
fnGetAlive()
{
	static iAlive, id
	iAlive = 0
	
	for (id = 1; id <= g_maxplayers; id++)
	{
		if (g_isalive[id])
			iAlive++
	}
	
	return iAlive;
}

// Get Random Alive -returnsidof alive player number n -
fnGetRandomAlive(n)
{
	static iAlive, id
	iAlive = 0
	
	for (id = 1; id <= g_maxplayers; id++)
	{
		if (g_isalive[id])
			iAlive++
		
		if (iAlive == n)
			return id;
	}
	
	return -1;
}

// Get Playing -returns number of users playing-
fnGetPlaying()
{
	static iPlaying, id, team
	iPlaying = 0
	
	for (id = 1; id <= g_maxplayers; id++)
	{
		if (g_isconnected[id])
		{
			team = fm_cs_get_user_team(id)
			
			if (team != FM_CS_TEAM_SPECTATOR && team != FM_CS_TEAM_UNASSIGNED)
				iPlaying++
		}
	}
	
	return iPlaying;
}

// Get CTs -returns number of CTs connected-
fnGetCTs()
{
	static iCTs, id
	iCTs = 0
	
	for (id = 1; id <= g_maxplayers; id++)
	{
		if (g_isconnected[id])
		{			
			if (fm_cs_get_user_team(id) == FM_CS_TEAM_CT)
				iCTs++
		}
	}
	
	return iCTs;
}

// Get Ts -returns number of Ts connected-
fnGetTs()
{
	static iTs, id
	iTs = 0
	
	for (id = 1; id <= g_maxplayers; id++)
	{
		if (g_isconnected[id])
		{			
			if (fm_cs_get_user_team(id) == FM_CS_TEAM_T)
				iTs++
		}
	}
	
	return iTs;
}

// Get Alive CTs -returns number of CTs alive-
fnGetAliveCTs()
{
	static iCTs, id
	iCTs = 0
	
	for (id = 1; id <= g_maxplayers; id++)
	{
		if (g_isalive[id])
		{			
			if (fm_cs_get_user_team(id) == FM_CS_TEAM_CT)
				iCTs++
		}
	}
	
	return iCTs;
}

// Get Alive Ts -returns number of Ts alive-
fnGetAliveTs()
{
	static iTs, id
	iTs = 0
	
	for (id = 1; id <= g_maxplayers; id++)
	{
		if (g_isalive[id])
		{			
			if (fm_cs_get_user_team(id) == FM_CS_TEAM_T)
				iTs++
		}
	}
	
	return iTs;
}

// Last Zombie Check -check for last zombie and set its flag-
fnCheckLastZombie()
{
	static id
	for (id = 1; id <= g_maxplayers; id++)
	{
		// Last zombie
		if (g_isalive[id] && g_zombie[id] && !g_nemesis[id] && !g_assassin[id] && !g_alien[id] && fnGetZombies() == 1)
		{
			if (!g_lastzombie[id])
			{
				// Last zombie forward
				ExecuteForward(g_fwUserLastZombie, g_fwDummyResult, id);
			}
			g_lastzombie[id] = true
		}
		else
			g_lastzombie[id] = false
		
		// Last human
		if (g_isalive[id] && is_human(id) && fnGetHumans() == 1)
		{
			if (!g_lasthuman[id])
			{
				// Last human forward
				ExecuteForward(g_fwUserLastHuman, g_fwDummyResult, id);
				
				// Reward extra hp
				fm_set_user_health(id, pev(id, pev_health) + 100)
			}
			g_lasthuman[id] = true
		}
		else
			g_lasthuman[id] = false
	}
}

// Checks if a player is allowed to be zombie
allowed_zombie(id)
{
	if ((g_zombie[id] && !g_nemesis[id] && !g_assassin[id] && !g_alien[id]) || g_endround || !g_isalive[id] || task_exists(TASK_WELCOMEMSG) || (!g_newround && !g_zombie[id] && fnGetHumans() == 1))
		return false;
	
	return true;
}

// Checks if a player is allowed to be human
allowed_human(id)
{
	if ((is_human(id)) || g_endround || !g_isalive[id] || task_exists(TASK_WELCOMEMSG) || (!g_newround && g_zombie[id] && fnGetZombies() == 1))
		return false;
	
	return true;
}

// Checks if a player is allowed to be survivor
allowed_survivor(id)
{
	if (g_endround || g_survivor[id] || !g_isalive[id] || task_exists(TASK_WELCOMEMSG) || (!g_newround && g_zombie[id] && fnGetZombies() == 1))
		return false;
	
	return true;
}

// Checks if a player is allowed to be nemesis
allowed_nemesis(id)
{
	if (g_endround || g_nemesis[id] || !g_isalive[id] || task_exists(TASK_WELCOMEMSG) || (!g_newround && !g_zombie[id] && fnGetHumans() == 1))
		return false;
	
	return true;
}

// Checks if a player is allowed to respawn
allowed_respawn(id)
{
	static team
	team = fm_cs_get_user_team(id)
	
	if (g_endround || team == FM_CS_TEAM_SPECTATOR || team == FM_CS_TEAM_UNASSIGNED || g_isalive[id])
		return false;
	
	return true;
}

// Checks if swarm mode is allowed
allowed_swarm()
{
	if (g_endround || !g_newround || task_exists(TASK_WELCOMEMSG))
		return false;
	
	return true;
}

// Checks if multi infection mode is allowed
allowed_multi()
{
	if (g_endround || !g_newround || task_exists(TASK_WELCOMEMSG) || floatround(fnGetAlive()*get_pcvar_float(cvar_multiratio), floatround_ceil) < 2 || floatround(fnGetAlive()*get_pcvar_float(cvar_multiratio), floatround_ceil) >= fnGetAlive())
		return false;
	
	return true;
}

// Checks if plague mode is allowed
allowed_plague()
{
	if (g_endround || !g_newround || task_exists(TASK_WELCOMEMSG) || floatround((fnGetAlive()-(get_pcvar_num(cvar_plaguenemnum)+get_pcvar_num(cvar_plaguesurvnum)))*get_pcvar_float(cvar_plagueratio), floatround_ceil) < 1
	|| fnGetAlive()-(get_pcvar_num(cvar_plaguesurvnum)+get_pcvar_num(cvar_plaguenemnum)+floatround((fnGetAlive()-(get_pcvar_num(cvar_plaguenemnum)+get_pcvar_num(cvar_plaguesurvnum)))*get_pcvar_float(cvar_plagueratio), floatround_ceil)) < 1)
		return false;
	
	return true;
}

// Checks if a player is allowed to be sniper
allowed_sniper(id)
{
	if (g_endround || g_sniper[id] || !g_isalive[id] || task_exists(TASK_WELCOMEMSG) || (!g_newround && g_zombie[id] && fnGetZombies() == 1))
		return false;
	
	return true;
}

// Checks if a player is allowed to be wesker
allowed_wesker(id)
{
	if (g_endround || g_wesker[id] || !g_isalive[id] || task_exists(TASK_WELCOMEMSG) || (!g_newround && g_zombie[id] && fnGetZombies() == 1))
		return false;
	
	return true;
}

// Checks if a player is allowed to be Depredador
allowed_depre(id)
{
	if (g_endround || g_depre[id] || !g_isalive[id] || task_exists(TASK_WELCOMEMSG) || (!g_newround && g_zombie[id] && fnGetZombies() == 1))
		return false;
	
	return true;
}

// Checks if a player is allowed to be Ninja
allowed_ninja(id)
{
	if (g_endround || g_ninja[id] || !g_isalive[id] || task_exists(TASK_WELCOMEMSG) || (!g_newround && g_zombie[id] && fnGetZombies() == 1))
		return false;
	
	return true;
}

// Checks if a player ia sllowed to be assassin
allowed_assassin(id)
{
	if (g_endround || g_assassin[id] || !g_isalive[id] || task_exists(TASK_WELCOMEMSG) || (!g_newround && !g_zombie[id] && fnGetHumans() == 1))
		return false;
	
	return true;
}



// Checks if a player ia sllowed to be assassin
allowed_alien(id)
{
	if (g_endround || g_alien[id] || !g_isalive[id] || task_exists(TASK_WELCOMEMSG) || (!g_newround && !g_zombie[id] && fnGetHumans() == 1))
		return false;
	
	return true;
}

// Checks if armageddon mode is allowed
allowed_lnj()
{
	if (g_endround || !g_newround || task_exists(TASK_WELCOMEMSG) || fnGetAlive() < 2)
		return false;
	
	return true;
}

// Checks if Tournament mode is allowed
allowed_torneo()
{
	if (g_endround || !g_newround || task_exists(TASK_WELCOMEMSG))
		return false;
	
	return true;
}

// Checks if Synapsis mode is allowed
allowed_synapsis()
{
	if (g_endround || !g_newround || task_exists(TASK_WELCOMEMSG))
		return false;
	
	return true;	
}

// Checks if L4D mode is allowed
allowed_l4d()
{
	if (g_endround || !g_newround || task_exists(TASK_WELCOMEMSG))
		return false;
	
	return true;	
}

// Admin Command. zp_zombie
command_zombie(id, player)
{
	// Show activity?
	switch (get_pcvar_num(cvar_showactivity))
	{
		case 1: zp_colored_print(0, "%s ADMIN^x01 -^x03 %s^x01 %L", TAG, g_playername[player], LANG_PLAYER, "CMD_INFECT")
		case 2: zp_colored_print(0, "%s ADMIN^x03 %s^x01 -^x03 %s^x01 %L", TAG, g_playername[id], g_playername[player], LANG_PLAYER, "CMD_INFECT")
	}
	
	// Log to Zombie Plague Advance  log file?
	if (get_pcvar_num(cvar_logcommands))
	{
		static logdata[100], authid[32], ip[16]
		get_user_authid(id, authid, charsmax(authid))
		get_user_ip(id, ip, charsmax(ip), 1)
		formatex(logdata, charsmax(logdata), "ADMIN %s <%s><%s> - %s %L (Players: %d/%d)", g_playername[id], authid, ip, g_playername[player], LANG_SERVER, "CMD_INFECT", fnGetPlaying(), g_maxplayers)
		log_to_file("zombie_galaxy.log", logdata)
	}
	
	// New round?
	if (g_newround)
	{
		// Set as first zombie
		remove_task(TASK_MAKEZOMBIE)
		make_a_zombie(MODE_INFECTION, player)
	}
	else
	{
		// Just infect
		zombieme(player, 0, 0, 0, 0)
	}
}

// Admin Command. zp_human
command_human(id, player)
{
	// Show activity?
	switch (get_pcvar_num(cvar_showactivity))
	{
		case 1: zp_colored_print(0, "%s ADMIN^x01 -^x03 %s^x01 %L", TAG, g_playername[player], LANG_PLAYER, "CMD_DISINFECT")
		case 2: zp_colored_print(0, "%s ADMIN^x03 %s^x01 -^x03 %s^x01 %L", TAG, g_playername[id], g_playername[player], LANG_PLAYER, "CMD_DISINFECT")
	}
	
	// Log to Zombie Plague log file?
	if (get_pcvar_num(cvar_logcommands))
	{
		static logdata[100], authid[32], ip[16]
		get_user_authid(id, authid, charsmax(authid))
		get_user_ip(id, ip, charsmax(ip), 1)
		formatex(logdata, charsmax(logdata), "ADMIN %s <%s><%s> - %s %L (Players: %d/%d)", g_playername[id], authid, ip, g_playername[player], LANG_SERVER,"CMD_DISINFECT", fnGetPlaying(), g_maxplayers)
		log_to_file("zombie_galaxy.log", logdata)
	}
	
	// Turn to human
	humanme(player, 0, 0)
}

// Admin Command. zp_survivor
command_survivor(id, player)
{
	// Show activity?
	switch (get_pcvar_num(cvar_showactivity))
	{
		case 1: zp_colored_print(0, "%s ADMIN^x01 -^x03 %s^x01 %L", TAG, g_playername[player], LANG_PLAYER, "CMD_SURVIVAL")
		case 2: zp_colored_print(0, "%s ADMIN^x03 %s^x01 -^x03 %s^x01 %L", TAG, g_playername[id], g_playername[player], LANG_PLAYER, "CMD_SURVIVAL")
	}
	
	 // Log to Zombie Plague log file?
	if (get_pcvar_num(cvar_logcommands))
	{
		static logdata[100], authid[32], ip[16]
		get_user_authid(id, authid, charsmax(authid))
		get_user_ip(id, ip, charsmax(ip), 1)
		formatex(logdata, charsmax(logdata), "ADMIN %s <%s><%s> - %s %L (Players: %d/%d)", g_playername[id], authid, ip, g_playername[player], LANG_SERVER,"CMD_SURVIVAL", fnGetPlaying(), g_maxplayers)
		log_to_file("zombie_galaxy.log", logdata)
	}
	
	// New round?
	if (g_newround)
	{
		// Set as first survivor
		remove_task(TASK_MAKEZOMBIE)
		make_a_zombie(MODE_SURVIVOR, player)
	}
	else
	{
		// Turn player into a Survivor
		humanme(player, 1, 0)
	}
}

// Admin Command. zp_nemesis
command_nemesis(id, player)
{
	// Show activity?
	switch (get_pcvar_num(cvar_showactivity))
	{
		case 1: zp_colored_print(0, "%s ADMIN^x01 -^x03 %s^x01 %L", TAG, g_playername[player], LANG_PLAYER, "CMD_NEMESIS")
		case 2: zp_colored_print(0, "%s ADMIN^x03 %s^x01 -^x03 %s^x01 %L", TAG, g_playername[id], g_playername[player], LANG_PLAYER, "CMD_NEMESIS")
	}
	
	// Log to Zombie Plague log file?
	if (get_pcvar_num(cvar_logcommands))
	{
		static logdata[100], authid[32], ip[16]
		get_user_authid(id, authid, charsmax(authid))
		get_user_ip(id, ip, charsmax(ip), 1)
		formatex(logdata, charsmax(logdata), "ADMIN %s <%s><%s> - %s %L (Players: %d/%d)", g_playername[id], authid, ip, g_playername[player], LANG_SERVER,"CMD_NEMESIS", fnGetPlaying(), g_maxplayers)
		log_to_file("zombie_galaxy.log", logdata)
	}

	// New round?
	if (g_newround)
	{
		// Set as first nemesis
		remove_task(TASK_MAKEZOMBIE)
		make_a_zombie(MODE_NEMESIS, player)
	}
	else
	{
		// Turn player into a Nemesis
		zombieme(player, 0, 1, 0, 0)
	}
}

// Admin Command. zp_respawn
command_respawn(id, player)
{
	// Show activity?
	switch (get_pcvar_num(cvar_showactivity))
	{
		
		case 1: zp_colored_print(0, "%s ADMIN^x01 -^x03 %s^x01 %L", TAG, g_playername[player], LANG_PLAYER, "CMD_RESPAWN")
		case 2: zp_colored_print(0, "%s ADMIN^x03 %s^x01 -^x03 %s^x01 %L", TAG, g_playername[id], g_playername[player], LANG_PLAYER, "CMD_RESPAWN")
	}
	
	// Log to Zombie Plague log file?
	if (get_pcvar_num(cvar_logcommands))
	{
		static logdata[100], authid[32], ip[16]
		get_user_authid(id, authid, charsmax(authid))
		get_user_ip(id, ip, charsmax(ip), 1)
		formatex(logdata, charsmax(logdata), "ADMIN %s <%s><%s> - %s %L (Players: %d/%d)", g_playername[id], authid, ip, g_playername[player], LANG_SERVER, "CMD_RESPAWN", fnGetPlaying(), g_maxplayers)
		log_to_file("zombie_galaxy.log", logdata)
	}
	
	if (get_pcvar_num(cvar_deathmatch) == 2 || (get_pcvar_num(cvar_deathmatch) == 3 && random_num(0, 1)) || (get_pcvar_num(cvar_deathmatch) == 4 && (fnGetZombies() < (fnGetAlive()/2))))
		g_respawn_as_zombie[player] = true
	
	// Override respawn as zombie setting on nemesis, assassin, alien, survivor and sniper rounds
	if (g_survround || g_sniperround || g_weskerround || g_depreround || g_l4dround || g_ninjaround) g_respawn_as_zombie[player] = true
	else if (g_nemround || g_assassinround || g_alienround) g_respawn_as_zombie[player] = false
	
	respawn_player_manually(player);
}

// Admin Command. zp_swarm
command_swarm(id)
{
	// Show activity?
	switch (get_pcvar_num(cvar_showactivity))
	{
		case 1: zp_colored_print(0, "%s ADMIN^x03 -^x01 %L", TAG, LANG_PLAYER, "CMD_SWARM")
		case 2: zp_colored_print(0, "%s ADMIN^x03 %s^x03 -^x01 %L", TAG, g_playername[id], LANG_PLAYER, "CMD_SWARM")
	}
	
	// Log to Zombie Plague log file?
	if (get_pcvar_num(cvar_logcommands))
	{
		static logdata[100], authid[32], ip[16]
		get_user_authid(id, authid, charsmax(authid))
		get_user_ip(id, ip, charsmax(ip), 1)
		formatex(logdata, charsmax(logdata), "ADMIN %s <%s><%s> - %L (Players: %d/%d)", g_playername[id], authid, ip, LANG_SERVER, "CMD_SWARM", fnGetPlaying(), g_maxplayers)
		log_to_file("zombie_galaxy.log", logdata)
	}
	
	// Call Swarm Mode
	remove_task(TASK_MAKEZOMBIE)
	make_a_zombie(MODE_SWARM, 0)
}

// Admin Command. zp_multi
command_multi(id)
{
	// Show activity?
	switch (get_pcvar_num(cvar_showactivity))
	{
		case 1: zp_colored_print(0, "%s ADMIN^x03 -^x01 %L", TAG, LANG_PLAYER, "CMD_MULTI")
		case 2: zp_colored_print(0, "%s ADMIN^x03 %s^x03 -^x01 %L", TAG, g_playername[id], LANG_PLAYER, "CMD_MULTI")
	}
	
	// Log to Zombie Plague log file?
	if (get_pcvar_num(cvar_logcommands))
	{
		static logdata[100], authid[32], ip[16]
		get_user_authid(id, authid, charsmax(authid))
		get_user_ip(id, ip, charsmax(ip), 1)
		formatex(logdata, charsmax(logdata), "ADMIN %s <%s><%s> - %L (Players: %d/%d)", g_playername[id], authid, ip, LANG_SERVER,"CMD_MULTI", fnGetPlaying(), g_maxplayers)
		log_to_file("zombie_galaxy.log", logdata)
	}
	
	// Call Multi Infection
	remove_task(TASK_MAKEZOMBIE)
	make_a_zombie(MODE_MULTI, 0)
}

// Admin Command. zp_plague
command_plague(id)
{
	// Show activity?
	switch (get_pcvar_num(cvar_showactivity))
	{
		case 1: zp_colored_print(0, "%s ADMIN^x03 -^x01 %L", TAG, LANG_PLAYER, "CMD_PLAGUE")
		case 2: zp_colored_print(0, "%s ADMIN^x03 %s^x03 -^x01 %L", TAG, g_playername[id], LANG_PLAYER, "CMD_PLAGUE")
	}
	
	// Log to Zombie Plague log file?
	if (get_pcvar_num(cvar_logcommands))
	{
		static logdata[100], authid[32], ip[16]
		get_user_authid(id, authid, charsmax(authid))
		get_user_ip(id, ip, charsmax(ip), 1)
		formatex(logdata, charsmax(logdata), "ADMIN %s <%s><%s> - %L (Players: %d/%d)", g_playername[id], authid, ip, LANG_SERVER,"CMD_PLAGUE", fnGetPlaying(), g_maxplayers)
		log_to_file("zombie_galaxy.log", logdata)
	}
	
	// Call Plague Mode
	remove_task(TASK_MAKEZOMBIE)
	make_a_zombie(MODE_PLAGUE, 0)
}

// Admin Command. zp_sniper
command_sniper(id, player)
{
	// Show activity?
	switch (get_pcvar_num(cvar_showactivity))
	{
		case 1: zp_colored_print(0, "%s ADMIN^x01 -^x03 %s^x01 %L", TAG, g_playername[player], LANG_PLAYER, "CMD_SNIPER")
		case 2: zp_colored_print(0, "%s ADMIN^x03 %s^x01 -^x03 %s^x01 %L", TAG, g_playername[id], g_playername[player], LANG_PLAYER, "CMD_SNIPER")
	}
	
	 // Log to Zombie Plague log file?
	if (get_pcvar_num(cvar_logcommands))
	{
		static logdata[100], authid[32], ip[16]
		get_user_authid(id, authid, charsmax(authid))
		get_user_ip(id, ip, charsmax(ip), 1)
		formatex(logdata, charsmax(logdata), "ADMIN %s <%s><%s> - %s %L (Players: %d/%d)", g_playername[id], authid, ip, g_playername[player], LANG_SERVER,"CMD_SNIPER", fnGetPlaying(), g_maxplayers)
		log_to_file("zombie_galaxy.log", logdata)
	}
	
	// New round?
	if (g_newround)
	{
		// Set as first sniper
		remove_task(TASK_MAKEZOMBIE)
		make_a_zombie(MODE_SNIPER, player)
	}
	else
	{
		// Turn player into a Sniper
		humanme(player, 5, 0)
	}
}

// Admin Command. zp_wesker
command_wesker(id, player)
{
	// Show activity?
	switch (get_pcvar_num(cvar_showactivity))
	{
		case 1: zp_colored_print(0, "%s ADMIN^x01 -^x03 %s^x01 %L", TAG, g_playername[player], LANG_PLAYER, "CMD_WESKER")
		case 2: zp_colored_print(0, "%s ADMIN^x03 %s^x01 -^x03 %s^x01 %L", TAG, g_playername[id], g_playername[player], LANG_PLAYER, "CMD_WESKER")
	}
	
	 // Log to Zombie Plague log file?
	if (get_pcvar_num(cvar_logcommands))
	{
		static logdata[100], authid[32], ip[16]
		get_user_authid(id, authid, charsmax(authid))
		get_user_ip(id, ip, charsmax(ip), 1)
		formatex(logdata, charsmax(logdata), "ADMIN %s <%s><%s> - %s %L (Players: %d/%d)", g_playername[id], authid, ip, g_playername[player], LANG_SERVER,"CMD_WESKER", fnGetPlaying(), g_maxplayers)
		log_to_file("zombie_galaxy.log", logdata)
	}
	
	// New round?
	if (g_newround)
	{
		// Set as first wesker
		remove_task(TASK_MAKEZOMBIE)
		make_a_zombie(MODE_WESKER, player)
	}
	else
	{
		// Turn player into a wesker
		humanme(player, 6, 0)
	}
}

// Admin Command. zp_depredador
command_depre(id, player)
{
	// Show activity?
	switch (get_pcvar_num(cvar_showactivity))
	{
		case 1: zp_colored_print(0, "%s ADMIN^x01 -^x03 %s^x01 %L", TAG, g_playername[player], LANG_PLAYER, "CMD_DEPRE")
		case 2: zp_colored_print(0, "%s ADMIN^x03 %s^x01 -^x03 %s^x01 %L", TAG, g_playername[id], g_playername[player], LANG_PLAYER, "CMD_DEPRE")
	}
	
	 // Log to Zombie Plague log file?
	if (get_pcvar_num(cvar_logcommands))
	{
		static logdata[100], authid[32], ip[16]
		get_user_authid(id, authid, charsmax(authid))
		get_user_ip(id, ip, charsmax(ip), 1)
		formatex(logdata, charsmax(logdata), "ADMIN %s <%s><%s> - %s %L (Players: %d/%d)", g_playername[id], authid, ip, g_playername[player], LANG_SERVER,"CMD_DEPRE", fnGetPlaying(), g_maxplayers)
		log_to_file("zombie_galaxy.log", logdata)
	}
	
	// New round?
	if (g_newround)
	{
		// Set as first depre
		remove_task(TASK_MAKEZOMBIE)
		make_a_zombie(MODE_DEPRE, player)
	}
	else
	{
		// Turn player into a depre
		humanme(player, 2, 0)
	}
}

// Admin Command. zp_ninja
command_ninja(id, player)
{
	// Show activity?
	switch (get_pcvar_num(cvar_showactivity))
	{
		case 1: zp_colored_print(0, "%s ADMIN^x01 -^x03 %s^x01 %L", TAG, g_playername[player], LANG_PLAYER, "CMD_NINJA")
		case 2: zp_colored_print(0, "%s ADMIN^x03 %s^x01 -^x03 %s^x01 %L", TAG, g_playername[id], g_playername[player], LANG_PLAYER, "CMD_NINJA")
	}
	
	 // Log to Zombie Plague log file?
	if (get_pcvar_num(cvar_logcommands))
	{
		static logdata[100], authid[32], ip[16]
		get_user_authid(id, authid, charsmax(authid))
		get_user_ip(id, ip, charsmax(ip), 1)
		formatex(logdata, charsmax(logdata), "ADMIN %s <%s><%s> - %s %L (Players: %d/%d)", g_playername[id], authid, ip, g_playername[player], LANG_SERVER,"CMD_NINJA", fnGetPlaying(), g_maxplayers)
		log_to_file("zombie_galaxy.log", logdata)
	}
	
	// New round?
	if (g_newround)
	{
		// Set as first Ninja
		remove_task(TASK_MAKEZOMBIE)
		make_a_zombie(MODE_NINJA, player)
	}
	else
	{
		// Turn player into a Ninja
		humanme(player, 3, 0)
	}
}

// Admin command: Assassin
command_assassin(id, player)
{
	// Show activity?
	switch (get_pcvar_num(cvar_showactivity))
	{
		case 1: zp_colored_print(0, "%s ADMIN^x01 -^x03 %s^x01 %L", TAG, g_playername[player], LANG_PLAYER, "CMD_ASSASSIN")
		case 2: zp_colored_print(0, "%s ADMIN^x03 %s^x01 -^x03 %s^x01 %L", TAG, g_playername[id], g_playername[player], LANG_PLAYER, "CMD_ASSASSIN")
	}
	
	// Log to Zombie Plague log file?
	if (get_pcvar_num(cvar_logcommands))
	{
		static logdata[100], authid[32], ip[16]
		get_user_authid(id, authid, charsmax(authid))
		get_user_ip(id, ip, charsmax(ip), 1)
		formatex(logdata, charsmax(logdata), "ADMIN %s <%s><%s> - %s %L (Players: %d/%d)", g_playername[id], authid, ip, g_playername[player], LANG_SERVER,"CMD_ASSASSIN", fnGetPlaying(), g_maxplayers)
		log_to_file("zombie_galaxy.log", logdata)
	}
	
	// New round?
	if (g_newround)
	{
		// Set as first assassin
		remove_task(TASK_MAKEZOMBIE)
		make_a_zombie(MODE_ASSASSIN, player)
	}
	else
	{
		// Turn player into a Assassin
		zombieme(player, 0, 2, 0, 0)
	}
}
// Admin command: Alien
command_alien(id, player)
{
	// Show activity?
	switch (get_pcvar_num(cvar_showactivity))
	{
		case 1: zp_colored_print(0, "%s ADMIN^x01 -^x03 %s^x01 %L", TAG, g_playername[player], LANG_PLAYER, "CMD_ALIEN")
		case 2: zp_colored_print(0, "%s ADMIN^x03 %s^x01 -^x03 %s^x01 %L", TAG, g_playername[id], g_playername[player], LANG_PLAYER, "CMD_ALIEN")
	}
	
	// Log to Zombie Plague log file?
	if (get_pcvar_num(cvar_logcommands))
	{
		static logdata[100], authid[32], ip[16]
		get_user_authid(id, authid, charsmax(authid))
		get_user_ip(id, ip, charsmax(ip), 1)
		formatex(logdata, charsmax(logdata), "ADMIN %s <%s><%s> - %s %L (Players: %d/%d)", g_playername[id], authid, ip, g_playername[player], LANG_SERVER,"CMD_ALIEN", fnGetPlaying(), g_maxplayers)
		log_to_file("zombie_galaxy.log", logdata)
	}
	
	// New round?
	if (g_newround)
	{
		// Set as first alien
		remove_task(TASK_MAKEZOMBIE)
		make_a_zombie(MODE_ALIEN, player)
	}
	else
	{
		// Turn player into a Assassin
		zombieme(player, 0, 3, 0, 0)
	}
}

// Admin Command. zp_lnj
command_lnj(id)
{
	// Show activity?
	switch (get_pcvar_num(cvar_showactivity))
	{
		case 1: zp_colored_print(0, "%s ADMIN^x03 -^x01 %L", TAG, LANG_PLAYER, "CMD_LNJ")
		case 2: zp_colored_print(0, "%s ADMIN^x03 %s^x03 -^x01 %L", TAG, g_playername[id], LANG_PLAYER, "CMD_LNJ")
	}
	
	// Log to Zombie Plague log file?
	if (get_pcvar_num(cvar_logcommands))
	{
		static logdata[100], authid[32], ip[16]
		get_user_authid(id, authid, charsmax(authid))
		get_user_ip(id, ip, charsmax(ip), 1)
		formatex(logdata, charsmax(logdata), "ADMIN %s <%s><%s> - %L (Players: %d/%d)", g_playername[id], authid, ip, LANG_SERVER, "CMD_LNJ", fnGetPlaying(), g_maxplayers)
		log_to_file("zombie_galaxy.log", logdata)
	}
	
	// Call Armageddon Mode
	remove_task(TASK_MAKEZOMBIE)
	make_a_zombie(MODE_LNJ, 0)
}

// Admin Command. zp_torneo
command_torneo(id)
{
	// Show activity?
	switch (get_pcvar_num(cvar_showactivity))
	{
		case 1: zp_colored_print(0, "%s ADMIN^x03 -^x01 %L", TAG, LANG_PLAYER, "CMD_TORNEO")
		case 2: zp_colored_print(0, "%s ADMIN^x03 %s^x03 -^x01 %L", TAG, g_playername[id], LANG_PLAYER, "CMD_TORNEO")
	}
	
	// Log to Zombie Plague log file?
	if (get_pcvar_num(cvar_logcommands))
	{
		static logdata[100], authid[32], ip[16]
		get_user_authid(id, authid, charsmax(authid))
		get_user_ip(id, ip, charsmax(ip), 1)
		formatex(logdata, charsmax(logdata), "ADMIN %s <%s><%s> - %L (Players: %d/%d)", g_playername[id], authid, ip, LANG_SERVER, "CMD_TORNEO", fnGetPlaying(), g_maxplayers)
		log_to_file("zombie_galaxy.log", logdata)
	}
	
	// Call Tournament Mode
	remove_task(TASK_MAKEZOMBIE)
	make_a_zombie(MODE_TORNEO, 0)
}

// Admin Command. zp_synapsis
command_synapsis(id)
{
	// Show activity?
	switch (get_pcvar_num(cvar_showactivity))
	{
		case 1: zp_colored_print(0, "%s ADMIN^x03 -^x01 %L", TAG, LANG_PLAYER, "CMD_SYNAPSIS")
		case 2: zp_colored_print(0, "%s ADMIN^x03 %s^x03 -^x01 %L", TAG, g_playername[id], LANG_PLAYER, "CMD_SYNAPSIS")
	}
	
	// Log to Zombie Plague log file?
	if (get_pcvar_num(cvar_logcommands))
	{
		static logdata[100], authid[32], ip[16]
		get_user_authid(id, authid, charsmax(authid))
		get_user_ip(id, ip, charsmax(ip), 1)
		formatex(logdata, charsmax(logdata), "ADMIN %s <%s><%s> - %L (Players: %d/%d)", g_playername[id], authid, ip, LANG_SERVER,"CMD_SYNAPSIS", fnGetPlaying(), g_maxplayers)
		log_to_file("zombieplague.log", logdata)
	}
	
	// Call Plague Mode
	remove_task(TASK_MAKEZOMBIE)
	make_a_zombie(MODE_SYNAPSIS, 0)
}

// Admin Command. zp_l4d
command_l4d(id)
{
	// Show activity?
	switch (get_pcvar_num(cvar_showactivity))
	{
		case 1: zp_colored_print(0, "%s ADMIN^x03 -^x01 %L", TAG, LANG_PLAYER, "CMD_L4D")
		case 2: zp_colored_print(0, "%s ADMIN^x03 %s^x03 -^x01 %L", TAG, g_playername[id], LANG_PLAYER, "CMD_L4D")
	}
	
	// Log to Zombie Plague log file?
	if (get_pcvar_num(cvar_logcommands))
	{
		static logdata[100], authid[32], ip[16]
		get_user_authid(id, authid, charsmax(authid))
		get_user_ip(id, ip, charsmax(ip), 1)
		formatex(logdata, charsmax(logdata), "ADMIN %s <%s><%s> - %L (Players: %d/%d)", g_playername[id], authid, ip, LANG_SERVER,"CMD_L4D", fnGetPlaying(), g_maxplayers)
		log_to_file("zombieplague.log", logdata)
	}
	
	// Call Plague Mode
	remove_task(TASK_MAKEZOMBIE)
	make_a_zombie(MODE_L4D, 0)
}

/*================================================================================
 [Custom Natives]
=================================================================================*/

public native_get_user_antifuego(id)
	return g_antifuego[id] = true
public native_get_user_antihielo(id)
	return g_antihielo[id] = true
public native_get_user_noantifuego(id)
	return g_antifuego[id] = false
public native_get_user_noantihielo(id)
	return g_antihielo[id] = false
public native_get_user_nodamage(id)
	return g_nodamage[id]
public native_set_user_nodamage(id)
	return g_nodamage[id] = true
public native_set_user_acabo_nodamage(id)
	return g_nodamage[id] = false
public native_get_user_antilaser(id)
	return g_antilaser[id]

// Native: g_zombie
public native_get_user_zombie(id)
{
	return g_zombie[id];
}

// Native: zp_get_user_nemesis
public native_get_user_nemesis(id)
{
	return g_nemesis[id];
}
	
// Native: zp_get_user_double_access
public native_get_user_double_access(id)
{
	return g_access_double[id];
}

// Native: zp_get_hf
public native_get_hf()
{
	return HF_MULTIPLIER;
}

// Native: zp_get_user_survivor
public native_get_user_survivor(id)
{
	return g_survivor[id];
}

public native_get_user_first_zombie(id)
{
	return g_firstzombie[id];
}

// Native: zp_get_user_last_zombie
public native_get_user_last_zombie(id)
{
	return g_lastzombie[id];
}

// Native: zp_get_user_last_zombie
public native_get_lastmode()
{
	return g_lastmode;
}

// Native: zp_get_user_last_human
public native_get_user_last_human(id)
{
	return g_lasthuman[id];
}

// Native: g_zombie_class
public native_get_user_zombie_class(id)
{
	return g_zombieclass[id];
}

// Native: zp_get_user_next_class
public native_get_user_next_class(id)
{
	return g_zombieclassnext[id];
}
	
public native_set_user_zombie_class(id, classid)
{
	if (classid < 0 || classid >= g_zclass_i)
		return 0;
	
	g_zombieclassnext[id] = classid
	return 1;
}

public native_get_user_human_class(id)
{
	return g_habilidadnext[id];
}
	
public native_set_user_human_class(id, classid)
{
	g_habilidadnext[id] = classid
}

// Native: zp_get_user_ammo_packs
public native_get_user_ammo_packs(id)
{
	return g_ammopacks[id];
}

// Native: zp_set_user_ammo_packs
public native_set_user_ammo_packs(id, amount)
{
	g_ammopacks[id] = amount;
}

public _set_level(id, amount)
{
	g_level[id] = amount;
}

public _get_level(id)
	return g_level[id]


public _get_exp(id)
	return g_exp[id]


public _get_exp_level(id)
	return Exp_Level(g_level[id])

public native_set_user_exp(id, amount)
	g_exp[id] = amount;

public native_get_user_puntos(id)
{
	return g_puntos[id];
}

public native_set_user_puntos(id, amount)
	g_puntos[id] = amount;

	

	
public native_set_user_mejora1(id, amount)
	g_mejoras[id][0] = amount;

public native_get_user_mejora1(id)
{
	return g_mejoras[id][0];
}


public native_set_user_mejora2(id, amount)
	g_mejoras[id][1] = amount;

public native_get_user_mejora2(id)
{
	return g_mejoras[id][1];
}


public native_set_user_mejora3(id, amount)
	g_mejoras[id][2] = amount;

public native_get_user_mejora3(id)
{
	return g_mejoras[id][2];
}


public native_set_user_mejora4(id, amount)
	g_mejoras[id][3] = amount;

public native_get_user_mejora4(id)
{
	return g_mejoras[id][3];
}

public native_set_user_resets(id, amount)
	g_reset[id] = amount;

public native_get_user_resets(id)
{
	return g_reset[id];
}

// Native: zp_get_zombie_maxhealth
public native_get_zombie_maxhealth(id)
{
	if (g_zombie[id] && !g_nemesis[id] && !g_assassin[id] && !g_alien[id])
	{
		if (g_firstzombie[id])
			return floatround(g_zclass_hp[g_zombieclass[id]]*get_pcvar_float(cvar_zombiefirsthp));
		else
			return g_zclass_hp[g_zombieclass[id]];
	}
	return -1;
}

// Native: zp_get_user_batteries
public native_get_user_batteries(id)
{
	return g_flashbattery[id];
}

// Native: zp_set_user_batteries
public native_set_user_batteries(id, value)
{
	// ZPA disabled
	if (!g_pluginenabled)
		return;
	
	g_flashbattery[id] = clamp(value, 0, 100);
	
	if (g_cached_customflash)
	{
		// Set the flashlight charge task to update battery status
		remove_task(id+TASK_CHARGE)
		set_task(1.0, "flashlight_charge", id+TASK_CHARGE, _, _, "b")
	}
}

// Native: zp_get_user_nightvision
public native_get_user_nightvision(id)
{
	return g_nvision[id];
}

// Native: zp_set_user_nightvision
public native_set_user_nightvision(id, set)
{
	// ZPA disabled
	if (!g_pluginenabled)
		return;
	
	if (set)
	{
		g_nvision[id] = true
		g_nvisionenabled[id] = true
		if (get_pcvar_num(cvar_customnvg))
		{
			remove_task(id+TASK_NVISION)
			set_task(0.1, "set_user_nvision", id+TASK_NVISION, _, _, "b")
		}
		else
			set_user_gnvision(id, 1)
	}
	else
	{
		// Turn off NVG for bots
		if (get_pcvar_num(cvar_customnvg)) remove_task(id+TASK_NVISION)
		else if (g_nvisionenabled[id]) set_user_gnvision(id, 0)
		g_nvision[id] = false
		g_nvisionenabled[id] = false
	}
}

// Native: zp_infect_user
public native_infect_user(id, infector, silent, rewards)
{
	// ZPA disabled
	if (!g_pluginenabled)
		return -1;
	
	// Not allowed to be zombie
	if (!allowed_zombie(id))
		return 0;
	
	// New round?
	if (g_newround)
	{
		// Set as first zombie
		remove_task(TASK_MAKEZOMBIE)
		make_a_zombie(MODE_INFECTION, id)
	}
	else
	{
		// Just infect (plus some checks)
		zombieme(id, is_user_valid_alive(infector) ? infector : 0, 0, (silent == 1) ? 1 : 0, (rewards == 1) ? 1 : 0)
	}
	
	return 1;
}

// Native: zp_disinfect_user
public native_disinfect_user(id, silent)
{
	// ZPA disabled
	if (!g_pluginenabled)
		return -1;
	
	// Not allowed to be human
	if (!allowed_human(id))
		return 0;
	
	// Turn to human
	humanme(id, 0, (silent == 1) ? 1 : 0)
	return 1;
}

// Native: zp_make_user_nemesis
public native_make_user_nemesis(id)
{
	// ZPA disabled
	if (!g_pluginenabled)
		return -1;
	
	// Not allowed to be nemesis
	if (!allowed_nemesis(id))
		return 0;
	
	if (g_newround)
	{
		remove_task(TASK_MAKEZOMBIE)
		make_a_zombie(MODE_NEMESIS, id)
	}
	else
	{
		// Turn player into a Nemesis
		zombieme(id, 0, 1, 0, 0)
	}
	
	return 1;
}

// Native: zp_make_user_survivor
public native_make_user_survivor(id)
{
	// ZPA disabled
	if (!g_pluginenabled)
		return -1;
	
	// Not allowed to be survivor
	if (!allowed_survivor(id))
		return 0;
	
	// New round?
	if (g_newround)
	{
		// Set as first survivor
		remove_task(TASK_MAKEZOMBIE)
		make_a_zombie(MODE_SURVIVOR, id)
	}
	else
	{
		// Turn player into a Survivor
		humanme(id, 1, 0)
	}
	
	return 1;
}

// Native: zp_respawn_user
public native_respawn_user(id, team)
{
	// ZPA disabled
	if (!g_pluginenabled)
		return -1;
	
	// Invalid player
	if (!is_user_valid_connected(id))
		return 0;
	
	// Respawn not allowed
	if (!allowed_respawn(id))
		return 0;
	
	// Respawn as zombie?
	g_respawn_as_zombie[id] = (team == ZP_TEAM_ZOMBIE) ? true : false
	
	// Respawnish!
	respawn_player_manually(id)
	return 1;
}

// Native: zp_get_user_sniper
public native_get_user_sniper(id)
{
	return g_sniper[id];
}

// Native: zp_make_user_sniper
public native_make_user_sniper(id)
{
	// ZPA disabled
	if (!g_pluginenabled)
		return -1;
	
	// Not allowed to be sniper
	if (!allowed_sniper(id))
		return 0;
	
	// New round?
	if (g_newround)
	{
		// Set as first sniper
		remove_task(TASK_MAKEZOMBIE)
		make_a_zombie(MODE_SNIPER, id)
	}
	else
	{
		// Turn player into a Sniper
		humanme(id, 5, 0)
	}
	
	return 1;
}

// Native: zp_get_user_wesker
public native_get_user_wesker(id)
{
	return g_wesker[id];
}

// Native: zp_make_user_wesker
public native_make_user_wesker(id)
{
	// ZPA disabled
	if (!g_pluginenabled)
		return -1;
	
	// Not allowed to be wesker
	if (!allowed_wesker(id))
		return 0;
	
	// New round?
	if (g_newround)
	{
		// Set as first wesker
		remove_task(TASK_MAKEZOMBIE)
		make_a_zombie(MODE_WESKER, id)
	}
	else
	{
		// Turn player into a Wesker
		humanme(id, 6, 0)
	}
	
	return 1;
}

// Native: zp_get_user_depre
public native_get_user_depre(id)
{
	return g_depre[id];
}

// Native: zp_make_user_depre
public native_make_user_depre(id)
{
	// ZPA disabled
	if (!g_pluginenabled)
		return -1;
	
	// Not allowed to be depre
	if (!allowed_depre(id))
		return 0;
	
	// New round?
	if (g_newround)
	{
		// Set as first depre
		remove_task(TASK_MAKEZOMBIE)
		make_a_zombie(MODE_DEPRE, id)
	}
	else
	{
		// Turn player into a Depre
		humanme(id, 2, 0)
	}
	
	return 1;
}

// Native: zp_get_user_ninja
public native_get_user_ninja(id)
{
	return g_ninja[id];
}

// Native: zp_make_user_ninja
public native_make_user_ninja(id)
{
	if (!g_pluginenabled)
		return -1;
	if (!allowed_ninja(id))
		return 0;
	if (g_newround)
	{
		remove_task(TASK_MAKEZOMBIE)
		make_a_zombie(MODE_NINJA, id)
	}
	else
		humanme(id, 3, 0)
	
	return 1;
}

// Native: zp_get_user_assassin
public native_get_user_assassin(id)
{
	return g_assassin[id];
}

 // Native: zp_make_user_assassin
public native_make_user_assassin(id)
{
	// ZPA disabled
	if (!g_pluginenabled)
		return -1;
	
	// Not allowed to be assassin
	if (!allowed_assassin(id))
		return 0;
	
	// New round?
	if (g_newround)
	{
		// Set as first assassin
		remove_task(TASK_MAKEZOMBIE)
		make_a_zombie(MODE_ASSASSIN, id)
	}
	else
	{
		// Turn player into a Assassin
		zombieme(id, 0, 2, 0, 0)
	}
	
	return 1;
} 
// Native: zp_make_user_alien
public native_make_user_alien(id)
{
	// ZPA disabled
	if (!g_pluginenabled)
		return -1;
	
	// Not allowed to be assassin
	if (!allowed_alien(id))
		return 0;
	
	// New round?
	if (g_newround)
	{
		// Set as first assassin
		remove_task(TASK_MAKEZOMBIE)
		make_a_zombie(MODE_ALIEN, id)
	}
	else
	{
		// Turn player into a Alien
		zombieme(id, 0, 3, 0, 0)
	}
	
	return 1;
}

// Native: zp_get_user_alien
public native_get_user_alien(id)
{
	return g_alien[id];
}


// Native: zp_get_user_model
public native_get_user_model(plugin_id, param_nums)
{
	// ZPA disabled
	if (!g_pluginenabled)
		return -1;
	
	// Insufficient number of arguments
	if (param_nums != 3)
		return -1;
	
	// Retrieve the player's id
	static id; id = get_param(1)
	
	// Not an alive player or invalid player
	if (!is_user_valid_alive(id))
		return 0;
	
	// Retrieve the player's current model
	static current_model[32]
	fm_cs_get_user_model(id, current_model, charsmax(current_model))
	
	// Copy the model name into the array passed
	set_string(2, current_model, get_param(3))
	
	return 1;
}

// Native: zp_has_round_started
public native_has_round_started()
{
	if (g_newround) return 0; // not started
	if (g_modestarted) return 1; // started
	return 2; // starting
}

// Native: zp_is_nemesis_round
public native_is_nemesis_round()
{
	return g_nemround;
}

// Native: zp_is_survivor_round
public native_is_survivor_round()
{
	return g_survround;
}

// Native: zp_is_swarm_round
public native_is_swarm_round()
{
	return g_swarmround;
}

// Native: zp_is_plague_round
public native_is_plague_round()
	return g_plagueround;

// Native: zp_get_zombie_count
public native_get_zombie_count()
	return fnGetZombies();

// Native: zp_get_human_count
public native_get_human_count()
	return fnGetHumans();

// Native: zp_get_nemesis_count
public native_get_nemesis_count()
	return fnGetNemesis();

// Native: zp_get_survivor_count
public native_get_survivor_count()
	return fnGetSurvivors();

// Native: zp_is_sniper_round
public native_is_sniper_round()
	return g_sniperround;
	
// Native: zp_get_sniper_count
public native_get_sniper_count()
	return fnGetSnipers();

// Native: zp_is_wesker_round
public native_is_wesker_round()
	return g_weskerround;

// Native: zp_get_wesker_count
public native_get_wesker_count()
	return fnGetWeskers();
	
// Native: zp_is_depre_round
public native_is_depre_round()
	return g_depreround;

// Native: zp_get_depre_count
public native_get_depre_count()
	return fnGetDepres();

// Native: zp_is_l4d_round
public native_is_l4d_round()
	return g_l4dround;

// Native: zp_get_l4d_count
public native_get_l4d_count()
	return fnGetL4Ds();

// Native: zp_is_ninja_round
public native_is_ninja_round()
	return g_ninjaround;

// Native: zp_get_ninja_count
public native_get_ninja_count()
	return fnGetNinjas();
// Native: zp_is_assassin_round
public native_is_assassin_round()
	return g_assassinround;

// Native: zp_get_assassin_count
public native_get_assassin_count()
	return fnGetAssassin();

// Native: zp_is_alien_round
public native_is_alien_round()
	return g_alienround;

// Native: zp_get_alien_count
public native_get_alien_count()
	return fnGetAlien();

// Native: zp_is_lnj_round
public native_is_lnj_round()
	return g_lnjround;

// Native: zp_is_torneo_round
public native_is_torneo_round()
	return g_torneoround;

// Native: zp_is_synapsis_round
public native_is_synapsis_round()
	return g_synapsisround;
	
public native_register_zombie_class(const name[], const info[], const model[], const clawmodel[], hp, speed, Float:gravity, Float:knockback)
{
	// Reached zombie classes limit
	if (g_zclass_i >= sizeof g_zclass_name)
		return -1;
	
	// Strings passed byref
	param_convert(1)
	param_convert(2)
	param_convert(3)
	param_convert(4)
	
	// Add the class
	copy(g_zclass_name[g_zclass_i], sizeof g_zclass_name[] - 1, name)
	copy(g_zclass_info[g_zclass_i], sizeof g_zclass_info[] - 1, info)
	copy(g_zclass_model[g_zclass_i], sizeof g_zclass_model[] - 1, model)
	copy(g_zclass_clawmodel[g_zclass_i], sizeof g_zclass_clawmodel[] - 1, clawmodel)
	g_zclass_hp[g_zclass_i] = hp
	g_zclass_spd[g_zclass_i] = speed
	g_zclass_grav[g_zclass_i] = gravity
	g_zclass_kb[g_zclass_i] = knockback
	
	// Precache custom models and retrieve the modelindex
	new prec_mdl[100]
	formatex(prec_mdl, sizeof prec_mdl - 1, "models/player/%s/%s.mdl", model, model)
	g_zclass_modelindex[g_zclass_i] = engfunc(EngFunc_PrecacheModel, prec_mdl)
	formatex(prec_mdl, sizeof prec_mdl - 1, "models/zpre4/%s", clawmodel)
	engfunc(EngFunc_PrecacheModel, prec_mdl)
	
	// Increase registered classes counter
	g_zclass_i++
	
	// Return id under which we registered the class
	return g_zclass_i-1;
}

/*================================================================================
 [Custom Messages]
=================================================================================*/

// Custom Night Vision
public set_user_nvision(taskid)
{
	if(!is_user_connected(ID_NVISION))
	{
		remove_task(taskid)
		return
	}
		
	// Get player's origin
	static origin[3]
	get_user_origin(ID_NVISION, origin)
	
	// Nightvision message
	message_begin(MSG_ONE_UNRELIABLE, SVC_TEMPENTITY, _, ID_NVISION)
	write_byte(TE_DLIGHT) // TE id
	write_coord(origin[0]) // x
	write_coord(origin[1]) // y
	write_coord(origin[2]) // z
	write_byte(get_pcvar_num(cvar_nvgsize)) // radius
	
	// Nemesis / Madness / Spectator in nemesis round
	if (g_nemesis[ID_NVISION] || (g_zombie[ID_NVISION] && g_nodamage[ID_NVISION]) || (!g_isalive[ID_NVISION] && g_nemround))
	{
		write_byte(255) // r
		write_byte(0) // g
		write_byte(0) // b
	}
	else if (g_assassin[ID_NVISION] || (!g_isalive[ID_NVISION] && g_assassinround))
	{
		write_byte(255) // r
		write_byte(255) // g
		write_byte(0) // b
	}
	else if (g_alien[ID_NVISION] || (!g_isalive[ID_NVISION] && g_alienround))
	{
		write_byte(100) // r
		write_byte(0) // g
		write_byte(200) // b
	}
	else if (!g_zombie[ID_NVISION] || !g_isalive[ID_NVISION])
	{
		write_byte(Colores[ID_NVISION][3]) // r
		write_byte(Colores[ID_NVISION][4]) // g
		write_byte(Colores[ID_NVISION][5]) // b
	}
	else
	{
		write_byte(Colores[ID_NVISION][6]) // r
		write_byte(Colores[ID_NVISION][7]) // g
		write_byte(Colores[ID_NVISION][8]) // b
	}
	
	write_byte(2) // life
	write_byte(0) // decay rate
	message_end()
}

// Game Nightvision
set_user_gnvision(id, toggle)
{
	if(!is_user_connected(id))
		return
		
	// Toggle NVG message
	message_begin(MSG_ONE, g_msgNVGToggle, _, id)
	write_byte(toggle) // toggle
	message_end()
}

// Custom Flashlight
public set_user_flashlight(taskid)
{
	if(!is_user_alive(ID_FLASH))
		return
		
	// Get player and aiming origins
	static Float:originF[3], Float:destoriginF[3]
	pev(ID_FLASH, pev_origin, originF)
	fm_get_aim_origin(ID_FLASH, destoriginF)
	
	// Max distance check
	if (get_distance_f(originF, destoriginF) > get_pcvar_float(cvar_flashdist))
		return;
	
	// Send to all players?
	if (get_pcvar_num(cvar_flashshowall))
		engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, destoriginF, 0)
	else
		message_begin(MSG_ONE_UNRELIABLE, SVC_TEMPENTITY, _, ID_FLASH)
	
	// Flashlight
	write_byte(TE_DLIGHT) // TE id
	engfunc(EngFunc_WriteCoord, destoriginF[0]) // x
	engfunc(EngFunc_WriteCoord, destoriginF[1]) // y
	engfunc(EngFunc_WriteCoord, destoriginF[2]) // z
	
	// Different flashlight in assassin round ?
	if (g_assassinround)
	{
		write_byte(7) // radius
		write_byte(255) // r
		write_byte(255) // g
		write_byte(0) // b
	}
	else
	{
		write_byte(get_pcvar_num(cvar_flashsize)) // radius
		write_byte(Colores[ID_FLASH][9]) // r
		write_byte(Colores[ID_FLASH][10]) // g
		write_byte(Colores[ID_FLASH][11]) // b
	}
	
	write_byte(3) // life
	write_byte(0) // decay rate
	message_end()
}

// Infection special effects
infection_effects(id)
{
	if(!is_user_alive(id))
		return
	// Screen fade? (unless frozen)
	if (!g_frozen[id])
	{
		message_begin(MSG_ONE_UNRELIABLE, g_msgScreenFade, _, id)
		write_short(UNIT_SECOND) // duration
		write_short(0) // hold time
		write_short(FFADE_IN) // fade type
		if (g_nemesis[id])
		{
			write_byte(255) // r
			write_byte(0) // g
			write_byte(0) // b
		}
		else if (g_assassin[id])
		{
			write_byte(255) // r
			write_byte(255) // g
			write_byte(0) // b
		}
		else if (g_alien[id])
		{
			write_byte(100) // r
			write_byte(0) // g
			write_byte(200) // b
		}
		else
		{
			write_byte(Colores[id][6])
			write_byte(Colores[id][7])
			write_byte(Colores[id][8])
		}
		write_byte (255) // alpha
		message_end()
	}
	
	message_begin(MSG_ONE_UNRELIABLE, g_msgScreenShake, _, id)
	write_short(UNIT_SECOND*75) // amplitude
	write_short(UNIT_SECOND*5) // duration
	write_short(UNIT_SECOND*75) // frequency
	message_end()
	
	message_begin(MSG_ONE_UNRELIABLE, g_msgDamage, _, id)
	write_byte(0) // damage save
	write_byte(0) // damage take
	write_long(DMG_NERVEGAS) // damage type - DMG_RADIATION
	write_coord(0) // x
	write_coord(0) // y
	write_coord(0) // z
	message_end()
	
	// Get player's origin
	static origin[3]
	get_user_origin(id, origin)

	message_begin(MSG_PVS, SVC_TEMPENTITY, origin)
	write_byte(TE_DLIGHT) // TE id
	write_coord(origin[0]) // x
	write_coord(origin[1]) // y
	write_coord(origin[2]) // z
	write_byte(20) // radius
	write_byte(0) // r
	write_byte(255) // g
	write_byte(0) // b
	write_byte(2) // life
	write_byte(0) // decay rate
	message_end()
}
// Nemesis/madness aura task
public zombie_aura(taskid)
{
	// Not nemesis, not in zombie madness
	if (!g_nemesis[ID_AURA] && !g_nodamage[ID_AURA] && !g_assassin[ID_AURA] && !g_alien[ID_AURA])
	{
		// Task not needed anymore
		remove_task(taskid);
		return;
	}
	
	// Get player's origin
	static origin[3]
	get_user_origin(ID_AURA, origin)
	
	// Colored Aura
	message_begin(MSG_PVS, SVC_TEMPENTITY, origin)
	write_byte(TE_DLIGHT) // TE id
	write_coord(origin[0]) // x
	write_coord(origin[1]) // y
	write_coord(origin[2]) // z
	write_byte(get_pcvar_num(cvar_nemauraradius)) // radius
	
	// Different aura color for assassin
	if (g_assassin[ID_AURA])
	{
		write_byte(255) // r
		write_byte(255) // g
		write_byte(0) // b
	}
	else if (g_alien[ID_AURA])
	{
		write_byte(100) // r
		write_byte(0) // g
		write_byte(200) // b
	}
	else if(g_nemesis[ID_AURA])// Aura color for nemesis
	{
		write_byte(255) // r
		write_byte(0) // g
		write_byte(0) // b
	}
	else
	{
		write_byte(255) // r
		write_byte(0) // g
		write_byte(0) // b
	}		
	
	write_byte(2) // life
	write_byte(0) // decay rate
	message_end()
}

// Survivor/Sniper aura task
public human_aura(taskid)
{
	// Not survivor or sniper
	if (is_human(ID_AURA))
	{
		// Task not needed anymore
		remove_task(taskid);
		return;
	}
	
	// Get player's origin
	static origin[3]
	get_user_origin(ID_AURA, origin)
	
	// Colored Aura
	message_begin(MSG_PVS, SVC_TEMPENTITY, origin)
	write_byte(TE_DLIGHT) // TE id
	write_coord(origin[0]) // x
	write_coord(origin[1]) // y
	write_coord(origin[2]) // z
	
	if (g_l4d[ID_AURA][3] || g_l4d[ID_AURA][2] || g_l4d[ID_AURA][1] || g_l4d[ID_AURA][0] || g_ninja[ID_AURA])
	{
		write_byte(35) // radius
		write_byte(200) // r
		write_byte(160) // g
		write_byte(50) // b
	}
	else if (g_depre[ID_AURA] || g_wesker[ID_AURA])
	{
		write_byte(35) // radius
		write_byte(255) // r
		write_byte(255) // g
		write_byte(255) // b
	}
	else if (g_sniper[ID_AURA])
	{
		write_byte(35) // radius
		write_byte(0) // r
		write_byte(100) // g
		write_byte(180) // b
	}
	else if (g_survivor[ID_AURA]) // Set it for survivor
	{
		write_byte(35) // radius
		write_byte(0) // r
		write_byte(0) // g
		write_byte(255) // b
	}
		
	write_byte(2) // life
	write_byte(0) // decay rate
	message_end()
}

// Make zombies leave footsteps and bloodstains on the floor
public make_blood(taskid)
{
	// Only bleed when moving on ground
	if (fm_get_speed(ID_BLOOD) < 80 || !(pev(ID_BLOOD, pev_flags) & FL_ONGROUND))
		return;
	
	// Get user origin
	static Float:originF[3]
	pev(ID_BLOOD, pev_origin, originF);
	
	// If ducking set a little lower
	if (pev(ID_BLOOD, pev_bInDuck))
		originF[2] -= 18.0
	else
		originF[2] -= 36.0
	
	// Send the decal message
	engfunc(EngFunc_MessageBegin, MSG_PAS, SVC_TEMPENTITY, originF, 0)
	write_byte(TE_WORLDDECAL) // TE id
	engfunc(EngFunc_WriteCoord, originF[0]) // x
	engfunc(EngFunc_WriteCoord, originF[1]) // y
	engfunc(EngFunc_WriteCoord, originF[2]) // z
	write_byte(zombie_decals[random_num(0, sizeof zombie_decals - 1)] + (g_czero*12)) // random decal number (offsets +12 for CZ)
	message_end()
}

// Flare Lighting Effects
flare_lighting(entity, duration)
{
	// Get origin and color
	static Float:originF[3], color[3]
	pev(entity, pev_origin, originF)
	pev(entity, PEV_FLARE_COLOR, color)
	
	if (g_assassinround)
	{	
		// Lighting in assassin round is different
		engfunc(EngFunc_MessageBegin, MSG_PAS, SVC_TEMPENTITY, originF, 0)
		write_byte(TE_DLIGHT) // TE id
		engfunc(EngFunc_WriteCoord, originF[0]) // x
		engfunc(EngFunc_WriteCoord, originF[1]) // y
		engfunc(EngFunc_WriteCoord, originF[2]) // z
		write_byte(get_pcvar_num(cvar_flaresize2)) // radius
		write_byte(color[0]) // r
		write_byte(color[1]) // g
		write_byte(color[2]) // b
		write_byte(51) //life
		write_byte((duration < 2) ? 3 : 0) //decay rate
		message_end()
	}
	else
	{
		static id; id = pev(entity, pev_owner)
		// Lighting
		engfunc(EngFunc_MessageBegin, MSG_PAS, SVC_TEMPENTITY, originF, 0)
		write_byte(TE_DLIGHT) // TE id
		engfunc(EngFunc_WriteCoord, originF[0]) // x
		engfunc(EngFunc_WriteCoord, originF[1]) // y
		engfunc(EngFunc_WriteCoord, originF[2]) // z
		write_byte(get_pcvar_num(cvar_flaresize)) // radius
		write_byte(Colores[id][12]) // r
		write_byte(Colores[id][13]) // g
		write_byte(Colores[id][14]) // b
		write_byte(51) //life
		write_byte((duration < 2) ? 3 : 0) //decay rate
		message_end()
	}
	
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
	write_byte(TE_IMPLOSION)
	engfunc(EngFunc_WriteCoord, originF[0]) 
	engfunc(EngFunc_WriteCoord, originF[1]) 
	engfunc(EngFunc_WriteCoord, originF[2]) 
	write_byte(128) 
	write_byte(20) 
	write_byte(3) 
	message_end()
	
	// Sparks
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
	write_byte(TE_SPARKS) // TE id
	engfunc(EngFunc_WriteCoord, originF[0]) // x
	engfunc(EngFunc_WriteCoord, originF[1]) // y
	engfunc(EngFunc_WriteCoord, originF[2]) // z
	message_end()
}

// Burning Flames
public burning_flame(taskid)
{
	// Get player origin and flags
	static origin[3], flags
	get_user_origin(ID_BURN, origin)
	flags = pev(ID_BURN, pev_flags)
	
	if(g_nemesis[ID_BURN] || g_antifuego[ID_BURN] || g_assassin[ID_BURN] || g_alien[ID_BURN])
		return;
	
	// Madness mode - in water - burning stopped
	if (g_nodamage[ID_BURN] || (flags & FL_INWATER) || g_burning_duration[ID_BURN] < 1)
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
	
	// Randomly play burning zombie scream sounds (not for nemesis, assassin or alien)
	if (!random_num(0, 20))
	{
		emit_sound(ID_BURN, CHAN_VOICE, grenade_fire_player[random_num(0, sizeof grenade_fire_player - 1)], 1.0, ATTN_NORM, 0, PITCH_NORM)
	}
	
	// Fire slow down, unless nemesis
	if ((flags & FL_ONGROUND) && get_pcvar_float(cvar_fireslowdown) > 0.0)
	{
		static Float:velocity[3]
		pev(ID_BURN, pev_velocity, velocity)
		xs_vec_mul_scalar(velocity, get_pcvar_float(cvar_fireslowdown), velocity)
		set_pev(ID_BURN, pev_velocity, velocity)
	}
	
	// Get player's health
	static health
	health = pev(ID_BURN, pev_health)
	
	// Take damage from the fire
	if (health - floatround(get_pcvar_float(cvar_firedamage), floatround_ceil) > 0)
		fm_set_user_health(ID_BURN, health - floatround(get_pcvar_float(cvar_firedamage), floatround_ceil))
	
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
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_DLIGHT)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2])
	write_byte(18)
	write_byte(0)
	write_byte(100)
	write_byte(200)
	write_byte(100)
	write_byte(15)
	message_end()
	
	// Decrease burning duration counter
	g_burning_duration[ID_BURN]--
}

// Infection Bomb: Blast
create_blast(const Float:originF[3])
{
	// Smallest ring
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
	write_byte(0) // red
	write_byte(250) // green
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
	write_short(g_exploSpr) // sprite
	write_byte(0) // startframe
	write_byte(0) // framerate
	write_byte(4) // life
	write_byte(60) // width
	write_byte(0) // noise
	write_byte(0) // red
	write_byte(250) // green
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
	write_short(g_exploSpr) // sprite
	write_byte(0) // startframe
	write_byte(0) // framerate
	write_byte(4) // life
	write_byte(60) // width
	write_byte(0) // noise
	write_byte(0) // red
	write_byte(250) // green
	write_byte(0) // blue
	write_byte(200) // brightness
	write_byte(0) // speed
	message_end()
}

// Fire Grenade: Fire Blast
create_blast2(const Float:originF[3])
{
	// Smallest ring
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
	write_byte(0) // red
	write_byte(100) // green
	write_byte(200) // blue
	write_byte(255) // brightness
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
	write_short(g_exploSpr) // sprite
	write_byte(0) // startframe
	write_byte(0) // framerate
	write_byte(4) // life
	write_byte(60) // width
	write_byte(0) // noise
	write_byte(200) // red
	write_byte(50) // green
	write_byte(0) // blue
	write_byte(255) // brightness
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
	write_short(g_exploSpr) // sprite
	write_byte(0) // startframe
	write_byte(0) // framerate
	write_byte(4) // life
	write_byte(60) // width
	write_byte(0) // noise
	write_byte(0) // red
	write_byte(100) // green
	write_byte(200) // blue
	write_byte(255) // brightness
	write_byte(0) // speed
	message_end()

	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
	write_byte(TE_SPRITETRAIL)
	engfunc(EngFunc_WriteCoord, originF[0]) // X
	engfunc(EngFunc_WriteCoord, originF[1]) // Y
	engfunc(EngFunc_WriteCoord, originF[2]) // Z
	engfunc(EngFunc_WriteCoord, originF[0]) // X
	engfunc(EngFunc_WriteCoord, originF[1]) // Y
	engfunc(EngFunc_WriteCoord, originF[2]) // Z
	write_short(g_flameSpr) //Sprite que usaremos
	write_byte(40) //Cantidades de sprites que generara
	write_byte(2)  //Vida
	write_byte(4)  //Tama�o
	write_byte(60) //Velocidad
	write_byte(60) //Velocidad
	message_end()
}
// Frost Grenade: Freeze Blast
create_blast3(const Float:originF[3])
{
	// Smallest ring
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
	write_byte(0) // red
	write_byte(100) // green
	write_byte(200) // blue
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
	write_short(g_exploSpr) // sprite
	write_byte(0) // startframe
	write_byte(0) // framerate
	write_byte(4) // life
	write_byte(60) // width
	write_byte(0) // noise
	write_byte(0) // red
	write_byte(100) // green
	write_byte(200) // blue
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
	write_short(g_exploSpr) // sprite
	write_byte(0) // startframe
	write_byte(0) // framerate
	write_byte(4) // life
	write_byte(60) // width
	write_byte(0) // noise
	write_byte(0) // red
	write_byte(100) // green
	write_byte(200) // blue
	write_byte(200) // brightness
	write_byte(0) // speed
	message_end()
	
	// TE_SPRITETRAIL
	engfunc(EngFunc_MessageBegin, MSG_BROADCAST ,SVC_TEMPENTITY, originF, 0)
	write_byte(TE_SPRITETRAIL) // TE ID
	engfunc(EngFunc_WriteCoord, originF[0]) // x axis
	engfunc(EngFunc_WriteCoord, originF[1]) // y axis
	engfunc(EngFunc_WriteCoord, originF[2]+70) // z axis
	engfunc(EngFunc_WriteCoord, originF[0]) // x axis
	engfunc(EngFunc_WriteCoord, originF[1]) // y axis
	engfunc(EngFunc_WriteCoord, originF[2]) // z axis
	write_short(g_frost_gib) // Sprite Index
	write_byte(80) // Count
	write_byte(20) // Life
	write_byte(2) // Scale
	write_byte(50) // Velocity Along Vector
	write_byte(10) // Rendomness of Velocity
	message_end();	

         // TE_EXPLOSION 
	engfunc(EngFunc_MessageBegin, MSG_BROADCAST,SVC_TEMPENTITY, originF, 0)
	write_byte(TE_EXPLOSION)
	engfunc(EngFunc_WriteCoord, originF[0]) // x axis
	engfunc(EngFunc_WriteCoord, originF[1]) // y axis
	engfunc(EngFunc_WriteCoord, originF[2]+75) // z axis
	write_short(g_frost_explode)
	write_byte(22)
	write_byte(35)
	write_byte(TE_EXPLFLAG_NOSOUND)
	message_end()
}

// Fix Dead Attrib on scoreboard
FixDeadAttrib(id)
{
	message_begin(MSG_BROADCAST, g_msgScoreAttrib)
	write_byte(id) // id
	write_byte(0) // attrib
	message_end()
}

// Send Death Message for infections
SendDeathMsg(attacker, victim)
{
	message_begin(MSG_BROADCAST, g_msgDeathMsg)
	write_byte(attacker) // killer
	write_byte(victim) // victim
	write_byte(1) // headshot flag
	write_string("Infeccion") // killer's weapon
	message_end()
}

// Plays a sound on clients
stock PlaySound(sound[128])
{
	if (equal(sound[strlen(sound)-4], ".mp3"))
	{
		format(sound, charsmax(sound), "sound/%s", sound)
		if(file_exists(sound)) client_cmd(0, "mp3 play ^"%s^"", sound)
	}
	else
	{
		static sound2[128]
		format(sound2, charsmax(sound2), "sound/%s", sound)
		if(file_exists(sound2))
			client_cmd(0, "spk ^"%s^"", sound)
	}
}

// Prints a colored message to target (use 0 for everyone), supports ML formatting.
// Note: I still need to make something like gungame's LANG_PLAYER_C to avoid unintended
// argument replacement when a function passes -1 (it will be considered a LANG_PLAYER)
zp_colored_print(target, const message[], any:...)
{
	static buffer[512], i, argscount
	argscount = numargs()
	
	// Send to everyone
	if (!target)
	{
		static player
		for (player = 1; player <= g_maxplayers; player++)
		{
			// Not connected
			if (!g_isconnected[player])
				continue;
			
			// Remember changed arguments
			static changed[5], changedcount // [5] = max LANG_PLAYER occurencies
			changedcount = 0
			
			// Replace LANG_PLAYER with player id
			for (i = 2; i < argscount; i++)
			{
				if (getarg(i) == LANG_PLAYER)
				{
					setarg(i, 0, player)
					changed[changedcount] = i
					changedcount++
				}
			}
			
			// Format message for player
			vformat(buffer, charsmax(buffer), message, 3)
			
			// Send it
			message_begin(MSG_ONE_UNRELIABLE, g_msgSayText, _, player)
			write_byte(player)
			write_string(buffer)
			message_end()
			
			// Replace back player id's with LANG_PLAYER
			for (i = 0; i < changedcount; i++)
				setarg(changed[i], 0, LANG_PLAYER)
		}
	}
	// Send to specific target
	else
	{
		// Format message for player
		vformat(buffer, charsmax(buffer), message, 3)
		
		// Send it
		message_begin(MSG_ONE, g_msgSayText, _, target)
		write_byte(target)
		write_string(buffer)
		message_end()
	}
}

/*================================================================================
 [Stocks]
=================================================================================*/

// Set an entity's key value (from fakemeta_util)
stock fm_set_kvd(entity, const key[], const value[], const classname[])
{
	set_kvd(0, KV_ClassName, classname)
	set_kvd(0, KV_KeyName, key)
	set_kvd(0, KV_Value, value)
	set_kvd(0, KV_fHandled, 0)

	dllfunc(DLLFunc_KeyValue, entity, 0)
}

// Set entity's rendering type (from fakemeta_util)
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

// Get entity's speed (from fakemeta_util)
stock fm_get_speed(entity)
{
	static Float:velocity[3]
	pev(entity, pev_velocity, velocity)
	
	return floatround(vector_length(velocity));
}

// Get entity's aim origins (from fakemeta_util)
stock fm_get_aim_origin(id, Float:origin[3])
{
	static Float:origin1F[3], Float:origin2F[3]
	pev(id, pev_origin, origin1F)
	pev(id, pev_view_ofs, origin2F)
	xs_vec_add(origin1F, origin2F, origin1F)

	pev(id, pev_v_angle, origin2F);
	engfunc(EngFunc_MakeVectors, origin2F)
	global_get(glb_v_forward, origin2F)
	xs_vec_mul_scalar(origin2F, 9999.0, origin2F)
	xs_vec_add(origin1F, origin2F, origin2F)

	engfunc(EngFunc_TraceLine, origin1F, origin2F, 0, id, 0)
	get_tr2(0, TR_vecEndPos, origin)
}

// Find entity by its owner (from fakemeta_util)
stock fm_find_ent_by_owner(entity, const classname[], owner)
{
	while ((entity = engfunc(EngFunc_FindEntityByString, entity, "classname", classname)) && pev(entity, pev_owner) != owner) { /* keep looping */ }
	return entity;
}

// Set player's health (from fakemeta_util)
stock fm_set_user_health(id, health)
{
	(health > 0) ? set_pev(id, pev_health, float(health)) : dllfunc(DLLFunc_ClientKill, id);
}

stock Float:fm_get_user_maxspeed(index){
	new Float:speed;
	pev(index, pev_maxspeed, speed);

	return speed;
}

stock Float:fm_get_user_gravity(index){
	new Float:gravity;
	pev(index, pev_gravity, gravity);

	return gravity;
}

stock fm_set_user_armor(id, armor){
	set_pev(id, pev_armorvalue, float(armor));

	return 1;
}

// Give an item to a player (from fakemeta_util)
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

// Strip user weapons (from fakemeta_util)
stock fm_strip_user_weapons(id)
{
	static ent
	ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "player_weaponstrip"))
	if (!pev_valid(ent)) return;
	
	dllfunc(DLLFunc_Spawn, ent)
	dllfunc(DLLFunc_Use, ent, id)
	engfunc(EngFunc_RemoveEntity, ent)
}

// Collect random spawn points
stock load_spawns()
{
	// Check for CSDM spawns of the current map
	new cfgdir[32], mapname[32], filepath[100], linedata[64]
	get_configsdir(cfgdir, charsmax(cfgdir))
	get_mapname(mapname, charsmax(mapname))
	formatex(filepath, charsmax(filepath), "%s/csdm/%s.spawns.cfg", cfgdir, mapname)
	
	// Load CSDM spawns if present
	if (file_exists(filepath))
	{
		new csdmdata[10][6], file = fopen(filepath,"rt")
		
		while (file && !feof(file))
		{
			fgets(file, linedata, charsmax(linedata))
			
			// invalid spawn
			if (!linedata[0] || str_count(linedata,' ') < 2) continue;
			
			// get spawn point data
			parse(linedata,csdmdata[0],5,csdmdata[1],5,csdmdata[2],5,csdmdata[3],5,csdmdata[4],5,csdmdata[5],5,csdmdata[6],5,csdmdata[7],5,csdmdata[8],5,csdmdata[9],5)
			
			// origin
			g_spawns[g_spawnCount][0] = floatstr(csdmdata[0])
			g_spawns[g_spawnCount][1] = floatstr(csdmdata[1])
			g_spawns[g_spawnCount][2] = floatstr(csdmdata[2])
			
			// increase spawn count
			g_spawnCount++
			if (g_spawnCount >= sizeof g_spawns) break;
		}
		if (file) fclose(file)
	}
	else
	{
		// Collect regular spawns
		collect_spawns_ent("info_player_start")
		collect_spawns_ent("info_player_deathmatch")
	}
	
	// Collect regular spawns for non-random spawning unstuck
	collect_spawns_ent2("info_player_start")
	collect_spawns_ent2("info_player_deathmatch")
}

// Collect spawn points from entity origins
stock collect_spawns_ent(const classname[])
{
	new ent = -1
	while ((ent = engfunc(EngFunc_FindEntityByString, ent, "classname", classname)) != 0)
	{
		// get origin
		new Float:originF[3]
		pev(ent, pev_origin, originF)
		g_spawns[g_spawnCount][0] = originF[0]
		g_spawns[g_spawnCount][1] = originF[1]
		g_spawns[g_spawnCount][2] = originF[2]
		
		// increase spawn count
		g_spawnCount++
		if (g_spawnCount >= sizeof g_spawns) break;
	}
}

// Collect spawn points from entity origins
stock collect_spawns_ent2(const classname[])
{
	new ent = -1
	while ((ent = engfunc(EngFunc_FindEntityByString, ent, "classname", classname)) != 0)
	{
		// get origin
		new Float:originF[3]
		pev(ent, pev_origin, originF)
		g_spawns2[g_spawnCount2][0] = originF[0]
		g_spawns2[g_spawnCount2][1] = originF[1]
		g_spawns2[g_spawnCount2][2] = originF[2]
		
		// increase spawn count
		g_spawnCount2++
		if (g_spawnCount2 >= sizeof g_spawns2) break;
	}
}

// Drop primary/secondary weapons
stock drop_weapons(id, dropwhat)
{
	// Get user weapons
	static weapons[32], num, i, weaponid
	num = 0 // reset passed weapons count (bugfix)
	get_user_weapons(id, weapons, num)
	
	// Loop through them and drop primaries or secondaries
	for (i = 0; i < num; i++)
	{
		// Prevent re-iding the array
		weaponid = weapons[i]
		
		if ((dropwhat == 1 && ((1<<weaponid) & PRIMARY_WEAPONS_BIT_SUM)) || (dropwhat == 2 && ((1<<weaponid) & SECONDARY_WEAPONS_BIT_SUM)) || (dropwhat == 3 && ((1<<weaponid) & TERCIARY_WEAPONS_BIT_SUM)))
		{
			// Get weapon entity
			static wname[32], weapon_ent
			get_weaponname(weaponid, wname, charsmax(wname))
			weapon_ent = fm_find_ent_by_owner(-1, wname, id)
			
			// Hack: store weapon bpammo on PEV_ADDITIONAL_AMMO
			set_pev(weapon_ent, PEV_ADDITIONAL_AMMO, cs_get_user_bpammo(id, weaponid))
			
			// Player drops the weapon and looses his bpammo
			engclient_cmd(id, "drop", wname)
			cs_set_user_bpammo(id, weaponid, 0)
		}
	}
}

// Stock by (probably) Twilight Suzuka -counts number of chars in a string
stock str_count(const str[], searchchar)
{
	new count, i, len = strlen(str)
	
	for (i = 0; i <= len; i++)
	{
		if (str[i] == searchchar)
			count++
	}
	
	return count;
}

// Checks if a space is vacant (credits to VEN)
stock is_hull_vacant(Float:origin[3], hull)
{
	engfunc(EngFunc_TraceHull, origin, origin, 0, hull, 0, 0)
	
	if (!get_tr2(0, TR_StartSolid) && !get_tr2(0, TR_AllSolid) && get_tr2(0, TR_InOpen))
		return true;
	
	return false;
}

// Check if a player is stuck (credits to VEN)
stock is_player_stuck(id)
{
	static Float:originF[3]
	pev(id, pev_origin, originF)
	
	engfunc(EngFunc_TraceHull, originF, originF, 0, (pev(id, pev_flags) & FL_DUCKING) ? HULL_HEAD : HULL_HUMAN, id, 0)
	
	if (get_tr2(0, TR_StartSolid) || get_tr2(0, TR_AllSolid) || !get_tr2(0, TR_InOpen))
		return true;
	
	return false;
}

// Simplified get_weaponid (CS only)
stock cs_weapon_name_to_id(const weapon[])
{
	static i
	for (i = 0; i < sizeof WEAPONENTNAMES; i++)
	{
		if (equal(weapon, WEAPONENTNAMES[i]))
			return i;
	}
	
	return 0;
}

// Get User Current Weapon Entity
stock fm_cs_get_current_weapon_ent(id)
{
	// Prevent server crash if entity's private data not initalized
	if (pev_valid(id) != PDATA_SAFE)
		return -1;
	
	return get_pdata_cbase(id, OFFSET_ACTIVE_ITEM, OFFSET_LINUX);
}

// Get Weapon Entity's Owner
stock fm_cs_get_weapon_ent_owner(ent)
{
	// Prevent server crash if entity's private data not initalized
	if (pev_valid(ent) != PDATA_SAFE)
		return -1;
	
	return get_pdata_cbase(ent, OFFSET_WEAPONOWNER, OFFSET_LINUX_WEAPONS);
}

// Set User Deaths
stock fm_cs_set_user_deaths(id, value)
{
	// Prevent server crash if entity's private data not initalized
	if (pev_valid(id) != PDATA_SAFE)
		return;
	
	set_pdata_int(id, OFFSET_CSDEATHS, value, OFFSET_LINUX)
}

// Get User Team
stock fm_cs_get_user_team(id)
{
	// Prevent server crash if entity's private data not initalized
	if (pev_valid(id) != PDATA_SAFE)
		return FM_CS_TEAM_UNASSIGNED;
	
	return get_pdata_int(id, OFFSET_CSTEAMS, OFFSET_LINUX);
}

// Set a Player's Team
stock fm_cs_set_user_team(id, team)
{
	// Prevent server crash if entity's private data not initalized
	if (pev_valid(id) != PDATA_SAFE)
		return;
	
	set_pdata_int(id, OFFSET_CSTEAMS, team, OFFSET_LINUX)
}

// Set User Money
stock fm_cs_set_user_money(id, value)
{
	// Prevent server crash if entity's private data not initalized
	if (pev_valid(id) != PDATA_SAFE)
		return;
	
	set_pdata_int(id, OFFSET_CSMONEY, value, OFFSET_LINUX)
}

// Set User Flashlight Batteries
stock fm_cs_set_user_batteries(id, value)
{
	// Prevent server crash if entity's private data not initalized
	if (pev_valid(id) != PDATA_SAFE)
		return;
	
	set_pdata_int(id, OFFSET_FLASHLIGHT_BATTERY, value, OFFSET_LINUX)
}

// Update Player's Team on all clients (adding needed delays)
stock fm_user_team_update(id)
{
	static Float:current_time
	current_time = get_gametime()
	
	if (current_time - g_teams_targettime >= 0.1)
	{
		set_task(0.1, "fm_cs_set_user_team_msg", id+TASK_TEAM)
		g_teams_targettime = current_time + 0.1
	}
	else
	{
		set_task((g_teams_targettime + 0.1) - current_time, "fm_cs_set_user_team_msg", id+TASK_TEAM)
		g_teams_targettime = g_teams_targettime + 0.1
	}
}

// Send User Team Message
public fm_cs_set_user_team_msg(taskid)
{
	// Note to self: this next message can now be received by other plugins
	
	// Set the switching team flag
	g_switchingteam = true
	
	// Tell everyone my new team
	emessage_begin(MSG_ALL, g_msgTeamInfo)
	ewrite_byte(ID_TEAM) // player
	ewrite_string(CS_TEAM_NAMES[fm_cs_get_user_team(ID_TEAM)]) // team
	emessage_end()
	
	// Done switching team
	g_switchingteam = false
}

// Remove Custom Model Entities
stock fm_remove_model_ents(id)
{
	if (pev_valid(g_ent_weaponmodel[id]))
	{
		engfunc(EngFunc_RemoveEntity, g_ent_weaponmodel[id])
		g_ent_weaponmodel[id] = 0
	}
}

// Get User Model -model passed byref-
stock fm_cs_get_user_model(player, model[], len)
{
	get_user_info(player, "model", model, len)
}

public Spawn(iEnt)
{
	if(pev_valid(iEnt))
	{
		static szClassName[32]
		pev(iEnt, pev_classname, szClassName, charsmax(szClassName))
		
		if(!TrieKeyExists(g_tClassWesker, szClassName))
		{
			RegisterHam(Ham_TraceAttack, szClassName, "TraceAttack", 1)
			TrieSetCell(g_tClassWesker, szClassName, 1)
		}
	}
}

public ElectroSound(iOrigin[3])
{
	new Entity = create_entity("info_target")
	
	new Float:flOrigin[3]
	IVecFVec(iOrigin, flOrigin)
	
	entity_set_origin(Entity, flOrigin)
	
	emit_sound(Entity, CHAN_WEAPON, "buttons/spark6.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	
	remove_entity(Entity)
}

// Frost Effect Ring
ElectroRing(const Float:originF3[3])
{
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF3, 0)
	write_byte(TE_BEAMCYLINDER) 
	engfunc(EngFunc_WriteCoord, originF3[0]) 
	engfunc(EngFunc_WriteCoord, originF3[1]) 
	engfunc(EngFunc_WriteCoord, originF3[2]) 
	engfunc(EngFunc_WriteCoord, originF3[0])
	engfunc(EngFunc_WriteCoord, originF3[1]) 
	engfunc(EngFunc_WriteCoord, originF3[2]+100.0)
	write_short(ElectroSpr) 
	write_byte(0)
	write_byte(0)
	write_byte(4)
	write_byte(60)
	write_byte(0)
	write_byte(0)
	write_byte(80)
	write_byte(255)
	write_byte(200)
	write_byte(0)
	message_end()
}

// Frost Effect Ring
ElectroRing2(const Float:originF3[3])
{
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF3, 0)
	write_byte(TE_BEAMCYLINDER) 
	engfunc(EngFunc_WriteCoord, originF3[0]) 
	engfunc(EngFunc_WriteCoord, originF3[1]) 
	engfunc(EngFunc_WriteCoord, originF3[2]) 
	engfunc(EngFunc_WriteCoord, originF3[0])
	engfunc(EngFunc_WriteCoord, originF3[1]) 
	engfunc(EngFunc_WriteCoord, originF3[2]+100.0)
	write_short(ElectroSpr) 
	write_byte(0)
	write_byte(0)
	write_byte(4)
	write_byte(60)
	write_byte(0)
	write_byte(255)
	write_byte(204)
	write_byte(0)
	write_byte(255)
	write_byte(0)
	message_end()
}

Subir_Nivel_Efecto(id)
{
	// Not alive
	if (!g_isalive[id] || g_zombie[id])
		return;
	
	static origin[3]
	get_user_origin(id , origin, 0)
	
	message_begin(MSG_ONE,SVC_TEMPENTITY,origin,id)
	write_byte(21)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2])
	write_coord(origin[0])
	write_coord(origin[1] - 50)
	write_coord(origin[2] + 200)
	write_short(white)
	write_byte(0) // startframe
	write_byte(6) // framerate
	write_byte(12) // 3 life 2
	write_byte(2) // width 16
	write_byte(1) // noise
	write_byte(100) // r
	write_byte(100) // g
	write_byte(255) // b
	write_byte(255) //brightness
	write_byte(0) // speed
	message_end()
}

public Menu_Reset(id)
{
	
	new menu = menu_create("\yMenu Resetear Cuenta^n\wRequisitos:^n\y- Nivel:\r300^n\wBeneficios:^n\y- Se Te Entregaran\r 8.000\y APs\y &\r 150\y Puntos^n- Podras Acceder a Armas Por Reset^nContras:^n\y- Se Te Reiniciara\r Exp, Nivel, AmmoPacks\w,\r Puntos & Mejoras", "Menu_Reset_Cases")
	
	if (g_level[id] >= 300)
		menu_additem(menu, "\y Resetear Cuenta", "1", 0);
	else
		menu_additem(menu, "\d Resetear Cuenta ", "1", 0);
	
	menu_setprop(menu, MPROP_EXITNAME, "Salir");
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
	menu_display(id, menu, 0)
	return PLUGIN_HANDLED;
}

public Menu_Reset_Cases(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		Menu_Perfil(id)
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	
	new data[6], iName[64];
	new access, callback;
	menu_item_getinfo(menu, item, access, data, 5, iName, 63, callback);
	new key = str_to_num(data);
	switch(key)
	{
		case 1:
		{
			if (g_isalive[id])
			{
				zp_colored_print(id, "%s Para^x03 resetear^x03 debes estar muerto,^x01 para evitar^x04 BUGS.", TAG)
				Menu_Reset(id)
			}
			else if(g_level[id] < 300)
			{
				zp_colored_print(id, "%s Para^x03 resetear^x01 necesitas ser Nivel:^x04 300", TAG)
				Menu_Reset(id)
			}
			else if (g_level[id] >= 300 && !g_isalive[id])
			{
				g_level[id] = 1
				g_reset[id]++
				g_ammopacks[id] = 8000
				g_puntos[id] = 150
				for (new i = 0; i < 4; i++) g_mejoras[id][i] = 0
				g_exp[id] = 0
				g_save_weapons[id][0] = false
				g_save_weapons[id][1] = -1
				g_save_weapons[id][2] = -1
				g_save_weapons[id][3] = -1
				g_save_weapons[id][4] = -1
				zp_colored_print(id, "%s Acabas de resetear, ahora tienes^x03 %d Reset^x01 y Tendras Acceso a^x04 Mas Armas!", TAG, g_reset[id])

				Menu_Perfil(id)
			}
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public fw_knife_PrimaryAttack_Post(knife) 
{
	new id = get_pdata_cbase(knife, 41, 4)
	if(g_isalive[id] && g_ninjasable[id]) 
	{
		set_pdata_float(knife, 46, 0.1, 4)
		set_pdata_float(knife, 46, 0.1, 4)
		set_pdata_float(knife, 46, 0.1, 4)
	}
	else if(g_isalive[id] && g_depreknife[id] || g_zombiefuria[id])
	{
		set_pdata_float(knife, 46, 0.25, 4)
		set_pdata_float(knife, 46, 0.25, 4)
		set_pdata_float(knife, 46, 0.25, 4)
	}
	return HAM_IGNORED
}

public fw_m249_PrimaryAttack_Post(m249) 
{
	new id = get_pdata_cbase(m249, 41, 4)
	if(g_isalive[id] && g_arma_prim[id] == ARMA_MINIGUN) 
	{
		static Float:flRate 
		flRate = 0.08
		
		set_pdata_float(m249, 46, flRate, 4)
		set_pdata_float(m249, 46, flRate, 4)
		set_pdata_float(m249, 46, flRate, 4)
	}
	return HAM_IGNORED
}

public fw_m3_PrimaryAttack_Post(m3) 
{
	new id = get_pdata_cbase(m3, 41, 4)
	if(g_isalive[id] && g_arma_prim[id] == ARMA_SPAS) 
	{
		set_pdata_float(m3, 46, 0.2, 4)
		set_pdata_float(m3, 46, 0.2, 4)
		set_pdata_float(m3, 46, 0.2, 4)
	}
}

public fw_deagle_PrimaryAttack_Post(deagle) 
{
	new id = get_pdata_cbase(deagle, 41, 4)
	if(g_isalive[id] && g_arma_sec[id]== 20) 
	{
		set_pdata_float(deagle, 46, 0.1, 4)
		set_pdata_float(deagle, 46, 0.1, 4)
		set_pdata_float(deagle, 46, 0.1, 4)
	}
}

public fw_elite_PrimaryAttack_Post(elite) 
{
	new id = get_pdata_cbase(elite, 41, 4)
	if(g_isalive[id] && g_arma_sec[id]== 21) 
	{
		set_pdata_float(elite, 46, 0.1, 4)
		set_pdata_float(elite, 46, 0.1, 4)
		set_pdata_float(elite, 46, 0.1, 4)
		
		new iEndOrigin[3]
		get_user_origin(id, iEndOrigin, 3)
		/*	
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY, iEndOrigin) 
		write_byte(TE_EXPLOSION)	
		write_coord(iEndOrigin[0]) 
		write_coord(iEndOrigin[1]) 
		write_coord(iEndOrigin[2]) 
		write_short(g_molotovSpr)	
		write_byte(60)	// scale in 0.1's	
		write_byte(20)	// framerate			
		write_byte(TE_EXPLFLAG_NONE)	
		message_end() */
			
		// Beam Cylinder
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY, iEndOrigin) 
		write_byte(TE_BEAMCYLINDER)
		write_coord(iEndOrigin[0])
		write_coord(iEndOrigin[1])
		write_coord(iEndOrigin[2])
		write_coord(iEndOrigin[0])
		write_coord(iEndOrigin[1])
		write_coord(iEndOrigin[2]+200)
		write_short(white)
		write_byte(0)
		write_byte(1)
		write_byte(6)
		write_byte(8)
		write_byte(1)
		write_byte(255)
		write_byte(255)
		write_byte(192)
		write_byte(128)
		write_byte(5)
		message_end()
	}
	return HAM_IGNORED
}

public fw_awp_PrimaryAttack_Post(awp) 
{
	new id = get_pdata_cbase(awp, 41, 4)
	
	if(g_isalive[id] && g_arma_prim[id] == ARMA_ELECTRUCUTADORAAWP)
	{	
		new iEndOrigin[3]
		get_user_origin(id, iEndOrigin, 3)
		
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY, iEndOrigin) 
		write_byte(TE_EXPLOSION)	
		write_coord(iEndOrigin[0]) 
		write_coord(iEndOrigin[1]) 
		write_coord(iEndOrigin[2] +10) 
		write_short(thunder)	
		write_byte(90)		
		write_byte(60)		
		write_byte(TE_EXPLFLAG_NONE)	
		message_end() 
		
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY, iEndOrigin) 
		write_byte(TE_EXPLOSION)	
		write_coord(iEndOrigin[0]) 
		write_coord(iEndOrigin[1]) 
		write_coord(iEndOrigin[2]+20) 
		write_short(thunder)	
		write_byte(60)	
		write_byte(20)		
		write_byte(TE_EXPLFLAG_NONE)	
		message_end() 
		
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY, iEndOrigin) 
		write_byte(TE_EXPLOSION)	
		write_coord(iEndOrigin[0]) 
		write_coord(iEndOrigin[1]) 
		write_coord(iEndOrigin[2] +30) 
		write_short(thunder)	
		write_byte(60)		
		write_byte(20)			
		write_byte(TE_EXPLFLAG_NONE)	
		message_end() 
		
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY, iEndOrigin) 
		write_byte(TE_BEAMCYLINDER)
		write_coord(iEndOrigin[0])
		write_coord(iEndOrigin[1])
		write_coord(iEndOrigin[2])
		write_coord(iEndOrigin[0])
		write_coord(iEndOrigin[1])
		write_coord(iEndOrigin[2]+200)
		write_short(hotflarex)
		write_byte(0)
		write_byte(1)
		write_byte(6)
		write_byte(8)
		write_byte(1)
		write_byte(255)
		write_byte(255)
		write_byte(192)
		write_byte(128)
		write_byte(5)
		message_end()
		
		message_begin(MSG_ONE_UNRELIABLE, g_msgScreenShake, _, id)
		write_short((1<<10)*5)
		write_short((1<<10)*5)
		write_short((1<<10)*5)
		message_end() 
		
		set_pdata_float(awp, 46, 2.0, 4)
		set_pdata_float(awp, 46, 2.0, 4)
		set_pdata_float(awp, 46, 2.0, 4)
	}
	
	if(g_isalive[id] && g_arma_prim[id] == ARMA_GAUSS)
	{	
		set_pdata_float(awp, 46, 2.3, 4)
		set_pdata_float(awp, 46, 2.3, 4)
		set_pdata_float(awp, 46, 2.3, 4)
		
		new iEndOrigin[3]
		get_user_origin(id, iEndOrigin, 3)
			
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY, iEndOrigin) 
		write_byte(TE_EXPLOSION)	
		write_coord(iEndOrigin[0]) 
		write_coord(iEndOrigin[1]) 
		write_coord(iEndOrigin[2]) 
		write_short(g_molotovSpr)	
		write_byte(60)	// scale in 0.1's	
		write_byte(20)	// framerate			
		write_byte(TE_EXPLFLAG_NONE)	
		message_end() 
			
		// Beam Cylinder
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY, iEndOrigin) 
		write_byte(TE_BEAMCYLINDER)
		write_coord(iEndOrigin[0])
		write_coord(iEndOrigin[1])
		write_coord(iEndOrigin[2])
		write_coord(iEndOrigin[0])
		write_coord(iEndOrigin[1])
		write_coord(iEndOrigin[2]+200)
		write_short(white)
		write_byte(0)
		write_byte(1)
		write_byte(6)
		write_byte(8)
		write_byte(1)
		write_byte(255)
		write_byte(255)
		write_byte(192)
		write_byte(128)
		write_byte(5)
		message_end()
	}
	
	return HAM_IGNORED
}

public server_frame()
{
	static weapon
	
	for (new id = 1; id <= g_maxplayers; id++)  
	{
		weapon= get_user_weapon(id)
		
		if(!g_isalive[id] || g_zombie[id])
			continue
			
		if(g_l4d[id][0] || g_l4d[id][1] || g_l4d[id][2] || g_l4d[id][3])
			set_pev(id, pev_punchangle, { 0.0, 0.0, 0.0 });			
			
		else if(weapon == gArmasOptimizadas[g_arma_prim[id]][gWeapon] && gArmasOptimizadas[g_arma_prim[id]][Recoil] != INACTIVE)
			set_pev(id, pev_punchangle, gArmasOptimizadas[g_arma_prim[id]][Recoil], gArmasOptimizadas[g_arma_prim[id]][Recoil], gArmasOptimizadas[g_arma_prim[id]][Recoil]);
			
		else if(weapon == gArmasOptimizadas[g_arma_sec[id]][gWeapon] && gArmasOptimizadas[g_arma_sec[id]][Recoil] != INACTIVE)
			set_pev(id, pev_punchangle, gArmasOptimizadas[g_arma_sec[id]][Recoil], gArmasOptimizadas[g_arma_sec[id]][Recoil], gArmasOptimizadas[g_arma_sec[id]][Recoil]);
	}
}

public Menu_Perfil(id)
{
	new menu = menu_create("\r-------------------^n\yTu Perfil en el Juego^n\r-------------------^n", "Menu_Perfil_Cases")
	
	menu_additem(menu, "Tus Estadisticas", "1", 0)
	menu_additem(menu, "Personaliza tu Perfil", "2", 0)
	menu_additem(menu, "Mejorar Habilidades \r(\wPuntos\r)", "3", 0)
	menu_additem(menu, "Resetear Cuenta", "4", 0)
	menu_additem(menu, "SISTEMA DE CUENTAS (CAMBIO DE PASSWORD)", "5", 0)
	
	menu_setprop(menu, MPROP_EXITNAME, "Salir")
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL)
	menu_display(id, menu, 0)
	return PLUGIN_HANDLED
}

public Menu_Perfil_Cases(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		Menu_Principal_Juego(id)
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	
	new data[6], iName[64];
	new access, callback;
	menu_item_getinfo(menu, item, access, data, 5, iName, 63, callback);
	new key = str_to_num(data);
	switch(key)
	{
		case 1:Menu_Estadisticas(id)
		case 2:Menu_Personalizar_Juego(id)
		case 3:Menu_Mejoras_Hm(id)
		case 4:Menu_Reset(id)
		case 5:MainMenu(id)
	}
		
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
	
public Menu_Estadisticas(id)
{
	new menu = menu_create("\r---------------------^n\yEstadisticas En \rZombie Killer Galaxy Beta^n\r---------------------", "Menu_Estadisticas_Cases")
	
	menu_additem(menu, "Ranking en el Servidor", "1", 0);
	menu_additem(menu, "Top 10 Jugadores", "2", 0);
	
	menu_setprop(menu, MPROP_EXITNAME, "Salir");
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
	menu_display(id, menu, 0)
	return PLUGIN_HANDLED;
}

public Menu_Estadisticas_Cases(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		Menu_Perfil(id)
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	
	new data[6], iName[64];
	new access, callback;
	menu_item_getinfo(menu, item, access, data, 5, iName, 63, callback);
	
	new key = str_to_num(data);
	
	switch(key)
	{
		case 1:
		{
			Menu_Estadisticas(id)
			client_cmd(id, "say /rank")
		}
		case 2:
		{
			Menu_Estadisticas(id)
			client_cmd(id, "say /top15")
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public Menu_Personalizar_Juego(id)
{
	new menu = menu_create("\r-----------^n\yConfigura tu Pefil^n\r-----------", "Menu_Personalizar_Juego_Cases")
	
	menu_additem(menu, "Elegir Color\r HUD", "1", 0);
	menu_additem(menu, "Elegir Posicion\r HUD", "2", 0);
	menu_additem(menu, "Elegir Color\r Nightvision\y Humano", "3", 0);
	menu_additem(menu, "Elegir Color\r Nightvision\y Zombie", "4", 0);
	menu_additem(menu, "Elegir Color\r Bengala", "5", 0);
	menu_additem(menu, "Elegir Color\r Linterna", "6", 0);
	menu_additem(menu, "Elegir Color\r Chat", "7", 0);
	
	menu_setprop(menu, MPROP_EXITNAME, "Salir");
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
	menu_display(id, menu, 0)
	return PLUGIN_HANDLED;
}

public Menu_Personalizar_Juego_Cases(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		Menu_Perfil(id)
		return PLUGIN_HANDLED;
	}
	
	new data[6], iName[64];
	new access, callback;
	menu_item_getinfo(menu, item, access, data, 5, iName, 63, callback);
	
	new key = str_to_num(data);
	
	switch(key)
	{
		case 1:Menu_HUD_Color(id)
		case 2:Menu_HUD_Posicion(id)
		case 3:Menu_NVG_Humano_Color(id)
		case 4:Menu_NVG_Zombie_Color(id)
		case 5:Menu_Bengala_Color(id)
		case 6:Menu_Linterna_Color(id)
		case 7:Menu_Chat_Colores(id)
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public Menu_HUD_Color(id)
{
	new menu1[200]
	formatex(menu1, 149, "\yColor HUD^n\wR: \r%d \wG: \r%d \wB: \r%d", Colores[id][0], Colores[id][1], Colores[id][2])
	new menu6 = menu_create(menu1, "Menu_HUD_Color_Cases")
	
	static i, num_color[10]
	for (i = 0; i < 10; i++)
	{
		num_to_str(i, num_color, charsmax(num_color))
		menu_additem(menu6, COLOR_NAMES[i], num_color)
	}
	
	menu_setprop(menu6,MPROP_EXITNAME,"Salir")
	menu_setprop(menu6, MPROP_EXIT, MEXIT_ALL)
	menu_display(id, menu6, 0)
	return PLUGIN_HANDLED
}

public Menu_HUD_Color_Cases(id, menu6, item)
{
	
	if (item == MENU_EXIT)
	{
		menu_destroy(menu6)		
		Menu_Personalizar_Juego(id)
		return PLUGIN_HANDLED;
	}
	
	new Data[6], Name[64]
	new Access, Callback
	menu_item_getinfo(menu6, item, Access, Data, sizeof(Data)-1, Name, sizeof(Name)-1, Callback)
	
	static Key; Key = (str_to_num(Data))
	
	new i, z
	for( i = 0 , z = 0 ; i < 3 , z < 3 ; i++ , z++ )
		Colores[id][z] = COLOR_RGB[Key][i]
	
	menu_destroy(menu6)	
	Menu_HUD_Color(id)	
	return PLUGIN_HANDLED;
}

public Menu_HUD_Posicion(id)
{
	new menu[190], menu1[190], pos[15], i
	
	formatex(menu1, 149, "\yPosicion De HUD^n\yX: \r%.3f \yY: \r%.3f", g_hud_pos[id][0], g_hud_pos[id][1]) 
	new menuid = menu_create(menu1, "Menu_HUD_Posicion_Cases")
	
	for (i = 0; i < sizeof hud_stuff; i++)
	{
		num_to_str(i, pos, 14)
		menu_additem(menuid, hud_stuff[i], pos)
	}

	formatex(menu, charsmax(menu), "Efecto\y: \r[%s]\w", (g_efecto[id] & (1 << 0)) ? "Si" : "No")
	menu_additem(menuid, menu, "8")
	
	menu_setprop(menuid,MPROP_EXITNAME,"Salir")
	menu_setprop(menuid, MPROP_EXIT, MEXIT_ALL)
	menu_display(id, menuid, 0)
	
	return PLUGIN_HANDLED	
}

public Menu_HUD_Posicion_Cases(id, menuid, item)
{
	if (item == MENU_EXIT)
	{
		menu_destroy(menuid)		
		Menu_Personalizar_Juego(id)		
		return PLUGIN_HANDLED;
	}
	
	new Data[6], Name[64]
	new Access, Callback
	menu_item_getinfo(menuid, item, Access, Data, sizeof(Data)-1, Name, sizeof(Name)-1, Callback)
	
	switch (str_to_num(Data))
	{
		case 0:
		{
			g_hud_pos[id][0] -= 0.01
			if(g_hud_pos[id][0] < 0.03)
				g_hud_pos[id][0] = 1.0
			
		}
			
		case 1: 
		{
			g_hud_pos[id][0] += 0.01
			if(g_hud_pos[id][0] > 0.97)
				g_hud_pos[id][0] = 0.0
			
		}
		case 2: 
		{
			g_hud_pos[id][1] -= 0.01
			if(g_hud_pos[id][1] < 0.03)
				g_hud_pos[id][1] = 1.0
			
		}
		case 3: 
		{
			g_hud_pos[id][1] += 0.01
			if(g_hud_pos[id][1] > 0.97)
				g_hud_pos[id][1] = 0.0
			
		}
		case 4:
		{
			g_hud_pos[id][0] = -1.0
			g_hud_pos[id][1] = -1.0
			
		}
		case 5:
		{
			g_hud_pos[id][0] = 0.00
			g_hud_pos[id][1] = 0.00
			
		}
		case 6:
		{
			g_hud_pos[id][0] = 0.929
			g_hud_pos[id][1] = 0.00
			
		}
		case 8:
		{
			g_efecto[id] = (g_efecto[id] ^ (1 << 0))
			
		}	
	}
	
	menu_destroy(menuid)	
	remove_task(id+TASK_SHOWHUD)	
	ShowHUD(id+TASK_SHOWHUD)
	set_task(1.0, "ShowHUD", id+TASK_SHOWHUD, _, _, "b")	
	Menu_HUD_Posicion(id)
	
	return PLUGIN_HANDLED;
}

public Menu_NVG_Humano_Color(id)
{
	new menu1[150]
	formatex(menu1, 149, "\yColor Vision Nocturna Humano^n\wR: \r%d \wG: \r%d \B: \r%d", Colores[id][3], Colores[id][4], Colores[id][5])
	new menu6 = menu_create(menu1, "Menu_NVG_Humano_Color_Cases")
	
	static i, num_color[10]
	for (i = 0; i < 10; i++)
	{
		num_to_str(i, num_color, charsmax(num_color))
		menu_additem(menu6, COLOR_NAMES[i], num_color)
	}
	
	menu_setprop(menu6,MPROP_EXITNAME,"Salir")
	menu_setprop(menu6, MPROP_EXIT, MEXIT_ALL)
	menu_display(id, menu6, 0)
	return PLUGIN_HANDLED
}

public Menu_NVG_Humano_Color_Cases(id, menu6, item)
{
	
	if (item == MENU_EXIT)
	{
		menu_destroy(menu6)		
		Menu_Personalizar_Juego(id)
		return PLUGIN_HANDLED;
	}
	
	new Data[6], Name[64]
	new Access, Callback
	menu_item_getinfo(menu6, item, Access, Data, sizeof(Data)-1, Name, sizeof(Name)-1, Callback)
	
	static Key; Key = (str_to_num(Data))
	new i, z
	for( i = 0 , z = 3 ; i < 3 , z < 6 ; i++ , z++ )
		Colores[id][z] = COLOR_RGB[Key][i]
	
	menu_destroy(menu6)	
	Menu_NVG_Humano_Color(id)	
	return PLUGIN_HANDLED;
}

public Menu_NVG_Zombie_Color(id)
{
	new menu1[200]
	formatex(menu1, 149, "\yColor Vision Nocturna Zombie^n\wR: \r%d \wG: \r%d \wB: \r%d", Colores[id][6], Colores[id][7], Colores[id][8])
	new menu6 = menu_create(menu1, "Menu_NVG_Zombie_Color_Cases")
	
	static i, num_color[10]
	for (i = 0; i < 10; i++)
	{
		num_to_str(i, num_color, charsmax(num_color))
		menu_additem(menu6, COLOR_NAMES[i], num_color)
	}
	
	menu_setprop(menu6,MPROP_EXITNAME,"Salir")
	menu_setprop(menu6, MPROP_EXIT, MEXIT_ALL)
	menu_display(id, menu6, 0)
	return PLUGIN_HANDLED
}

public Menu_NVG_Zombie_Color_Cases(id, menu6, item)
{
	
	if (item == MENU_EXIT)
	{
		menu_destroy(menu6)		
		Menu_Personalizar_Juego(id)
		return PLUGIN_HANDLED;
	}
	
	new Data[6], Name[64]
	new Access, Callback
	menu_item_getinfo(menu6, item, Access, Data, sizeof(Data)-1, Name, sizeof(Name)-1, Callback)
	
	static Key; Key = (str_to_num(Data))
	new i , z
	for( i = 0 , z = 6 ; i < 3 , z < 9 ; i++ , z++ )
		Colores[id][z] = COLOR_RGB[Key][i]
	
	menu_destroy(menu6)	
	Menu_NVG_Zombie_Color(id)	
	return PLUGIN_HANDLED;
}

public Menu_Bengala_Color(id)
{
	new menu, menu1[100]
	formatex(menu1, 49, "\yBengala Color^n\yR: \r%d \yG: \r%d \yB: \r%d^n", Colores[id][12], Colores[id][13], Colores[id][14])
	
	menu = menu_create(menu1, "Menu_Bengala_Color_Cases")
	
	new pos[10]
	for (new i = 0; i < 10; i++)
	{
		num_to_str(i, pos, 9)
		menu_additem(menu, COLOR_NAMES[i], pos)
	}
	menu_setprop(menu,MPROP_EXITNAME,"Salir")
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL)
	menu_display(id, menu, 0)
	return PLUGIN_HANDLED
}

public Menu_Bengala_Color_Cases(id, menu, item)
{
	if (item == MENU_EXIT)
	{
		menu_destroy(menu)		
		Menu_Personalizar_Juego(id)		
		return PLUGIN_HANDLED;
	}
	
	new Data[6], Name[64]
	new Access, Callback
	menu_item_getinfo(menu, item, Access, Data, sizeof(Data)-1, Name, sizeof(Name)-1, Callback)
	
	new Key; Key = str_to_num(Data)
	new i, z
	for( i = 0 , z = 12 ; i < 3 , z < 15 ; i++ , z++ )
		Colores[id][z] = COLOR_RGB[Key][i]
		
	menu_destroy(menu)	
	Menu_Bengala_Color(id)	
	return PLUGIN_HANDLED;
}

public Menu_Linterna_Color(id)
{
	new menu, menu1[150]
	formatex(menu1, 49, "\yColor de la Linterna^n\yR: \r%d \yG: \r%d \yB: \r%d", Colores[id][9], Colores[id][10], Colores[id][11])
	
	menu = menu_create(menu1, "Menu_Linterna_Color_Cases")
	
	new i, pos[10]
	for (i = 0; i < 10; i++)
	{
		num_to_str(i, pos, 9)
		menu_additem(menu, COLOR_NAMES[i], pos)
	}
	menu_setprop(menu,MPROP_EXITNAME,"Salir")
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL)
	menu_display(id, menu, 0)
	return PLUGIN_HANDLED
}
public Menu_Linterna_Color_Cases(id, menu, item)
{
	if (item == MENU_EXIT)
	{
		menu_destroy(menu)		
		Menu_Personalizar_Juego(id)		
		return PLUGIN_HANDLED;
	}
	
	new Data[6], Name[64]
	new Access, Callback
	menu_item_getinfo(menu, item, Access, Data, sizeof(Data)-1, Name, sizeof(Name)-1, Callback)
	
	new Key; Key = str_to_num(Data)
	
	new i , z
	for( i = 0 , z = 9 ; i < 3 , z < 12 ; i++ , z++ )
		Colores[id][z] = COLOR_RGB[Key][i]
		
	menu_destroy(menu)	
	Menu_Linterna_Color(id)	
	return PLUGIN_HANDLED;
}

public Menu_Chat_Colores(id)
{
	new menu, menu1[150]
	formatex(menu1, 49, "\r----------------^n\yColor Del Chat^n\r----------------")
	
	menu = menu_create(menu1, "Menu_Chat_Colores_Cases")
	
	menu_additem(menu, "Original", "1", 0)
	menu_additem(menu, "Amarillo", "2", 0)
	menu_additem(menu, "Verde Agua", "3", 0)
	menu_additem(menu, "Verde Limon", "4", 0)
	menu_additem(menu, "Turqueza", "5", 0)
	menu_additem(menu, "Cafe", "6", 0)
	menu_additem(menu, "Lila", "7", 0)
	menu_additem(menu, "Rosado", "8", 0)
	menu_additem(menu, "Purpura", "9", 0)
	menu_additem(menu, "Blanco", "10", 0)
	
	menu_setprop(menu, MPROP_BACKNAME, "Anterior")
	menu_setprop(menu, MPROP_NEXTNAME, "Siguiente")
	menu_setprop(menu, MPROP_EXITNAME, "Salir")
	menu_display(id, menu, 0)
}

public Menu_Chat_Colores_Cases(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		Menu_Personalizar_Juego(id)
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}
	
	new data[6], iName[64], access, callback
	menu_item_getinfo(menu, item, access, data, 5, iName, 63, callback)
	
	switch(str_to_num(data))
	{
		case 1:client_cmd(id, "con_color ^"255 180 30^"");
		case 2:client_cmd(id, "con_color ^"255 255 0^"");
		case 3:client_cmd(id, "con_color ^"0 255 128^"");
		case 4:client_cmd(id, "con_color ^"128 255 0^"");	
		case 5:client_cmd(id, "con_color ^"0 128 128^"");
		case 6:client_cmd(id, "con_color ^"128 64 0^"");
		case 7:client_cmd(id, "con_color ^"128 128 255^"");
		case 8:client_cmd(id, "con_color ^"255 128 255^"");
		case 9:client_cmd(id, "con_color ^"255 0 255^"");
		case 10:client_cmd(id, "con_color ^"255 255 255^"");
	}
	Menu_Chat_Colores(id)
	return PLUGIN_HANDLED
}

public fw_CmdStart_Post(id, handle) 
{
	if(!g_isalive[id] || !g_survivor[id])
		return FMRES_IGNORED;
		
	static iButton;iButton = get_uc(handle, UC_Buttons)
	if(g_survround || g_plagueround || g_synapsisround)
	{
		if (iButton & IN_RELOAD)
		{
			iButton &= ~IN_RELOAD
			set_uc(handle, UC_Buttons, iButton)
			if (Inmu_Usado[id] < 1)
			{
				Inmunidad(id)
			}
		}
	}
	return FMRES_IGNORED;
}

public Inmunidad(id) 
{
	if(g_zombie[id])
		return;
	set_task(15.0, "Inmunidad_off", id)
	set_task(0.1, "Particulas", id + TASK_PARTICULAS, _, _, "b")
	set_hudmessage(128 , 128, 128, -1.0, 0.17, 1, 0.0, 4.0, 1.0, 1.0, -1)
	g_nodamage[id] = true
	zp_colored_print(id, "%s Inmunidad Se Acaba En 15 Segundos", TAG)
	emit_sound(id, CHAN_ITEM, "zpre4/inmunidad_on.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
	Inmu_Usado[id]++
} 

public Inmunidad_off(id)
{
	g_nodamage[id] = false
	set_hudmessage(128 , 128, 128, -1.0, 0.17, 1, 0.0, 4.0, 1.0, 1.0, -1)
	zp_colored_print(id, "%s Tu^x03 Inmunidad^x01 Se Acabo", TAG)
	emit_sound(id, CHAN_ITEM, "ambience/xtal_down1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
	remove_task(id+TASK_PARTICULAS)
} 
public Reglas(id)
{
	show_motd(id, "reglas.txt", "Reglas del Server");
	Menu_Informacion(id)
	return PLUGIN_HANDLED;
}

public Reglas_VIP(id)
{
	show_motd(id, "reglas_vip.txt", "Reglas VIP y ADMIN");
	Menu_Informacion(id)
	return PLUGIN_HANDLED;
}

public Comprar_VIP(id)
{
	show_motd(id, "vip.txt", "Beneficios VIP");
	Menu_Informacion(id)
	return PLUGIN_HANDLED;
}

public Creditos(id)
{
	show_motd(id, "creditos.txt", "Creditos");
	Menu_Informacion(id)
	return PLUGIN_HANDLED;
}

public cmdConsejo(id)
{
	 client_cmd(id, "messagemode Escribe_Tu_Recomendacion")
	 zp_colored_print(id, "%s Escribe tu Recomendacion^x03 AHORA!", TAG)
	 set_hudmessage(255, 0, 0, -1.0, -1.0, 0, 6.0, 8.0)
	 show_hudmessage(id, "Puedes Recomendar:^n- Mapas - Extra Items - Modos - Modelos, Etc..^n Lo que se te Ocurra Lo recibiremos")
	 return PLUGIN_HANDLED;
}

public Consejo_ASD(id)
{
	static szName[32], szTime[15], szForm[220], szArgs[190];
	read_args(szArgs, charsmax(szArgs))
	remove_quotes(szArgs)
	
	if(strlen(szArgs) < 15)
	{
		zp_colored_print(id, "%s Tu mensaje debe tener minimo^x03 15^x01 letras", TAG)
		cmdConsejo(id)
		return PLUGIN_CONTINUE
	}
	
	get_time("%H:%M:%S %p", szTime, charsmax(szTime))
	get_user_name(id, szName, charsmax(szName))
	formatex(szForm, charsmax(szForm), "(%s) Nombre Consejante: (%s) Consejo: (%s)", szTime, szName, szArgs)
	log_to_file("recomendaciones.txt", szForm)
	Menu_Informacion(id)
	zp_colored_print(id, "%s Tu^x03 Recomendacion^x01 ha sido enviada^x03 EXITOSAMENTE!", TAG)
	return PLUGIN_HANDLED;
} 

public cmdREPORT(id)
{
	//zp_colored_print(id, "%s Opcion Deshabilitada Momentaneamente", TAG)
	client_cmd(id, "messagemode Escribe_Tu_Denuncia")
	set_hudmessage(0, 255, 0, -1.0, -1.0, 0, 6.0, 8.0)
	show_hudmessage(id, "Escribe el nombre del denunciado^ny acontinuacion escribe^ntu denuncia")
	zp_colored_print(id, "%s Basta Con Que denuncies^x04 solo una vez^x01 al que rompe las reglas.", TAG)
	return PLUGIN_HANDLED;
}

public ReportSAY(id)
{
	static szName[32], szTime[15], szForm[220], szArgs[190];
	read_args(szArgs, charsmax(szArgs))
	remove_quotes(szArgs)
	
	if(strlen(szArgs) < 15)
	{
		zp_colored_print(id, "%s Tu denuncia debe tener minimo^x03 15^x01 letras", TAG)
		cmdREPORT(id)
		return PLUGIN_CONTINUE
	}
	
	get_time("%H:%M:%S %p", szTime, charsmax(szTime))
	get_user_name(id, szName, charsmax(szName))
	formatex(szForm, charsmax(szForm), "(%s) Nombre Denunciante: (%s) Denuncia: (%s)", szTime, szName, szArgs)
	log_to_file("denuncias.txt", szForm)
	Menu_Informacion(id)
	zp_colored_print(id, "%s Tu^x03 Denuncia^x01 ha sido enviada^x03 EXITOSAMENTE!", TAG)
	return PLUGIN_HANDLED;
}

public Menu_Informacion(id)
{
	new menu = menu_create("\yInformaciones & Mas", "Menu_Informacion_Cases")
	
	menu_additem(menu, "Beneficios VIP", "1", 0)
	menu_additem(menu, "Reglas VIP", "2", 0);
	menu_additem(menu, "Reglas Generales", "3", 0);
	menu_additem(menu, "Denunciar a un Jugador", "4", 0);
	menu_additem(menu, "Enviar Consejos Al Servidor", "5", 0);
	menu_additem(menu, "Informacion Plugin", "6", 0);
	menu_additem(menu, "Creditos", "7", 0);
	
	menu_setprop(menu, MPROP_EXITNAME, "Salir");
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
	menu_display(id, menu, 0)
	return PLUGIN_HANDLED;
}

public Menu_Informacion_Cases(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		Menu_Principal_Juego(id)
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	
	new data[6], iName[64];
	new access, callback;
	menu_item_getinfo(menu, item, access, data, 5, iName, 63, callback);
	new key = str_to_num(data);
	switch(key)
	{
		case 1: Comprar_VIP(id)
		case 2: Reglas_VIP(id)
		case 3: Reglas(id)
		case 4: cmdREPORT(id)
		case 5: cmdConsejo(id)
		case 6:
		{
			Menu_Informacion(id)
			zp_colored_print(id, "%s Opcion Deshabilitada Momentaneamente!", TAG)
		}
		case 7: Creditos(id)
	}
		
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
	
public Menu_Seleccion_Armas(id)
{
	if(!is_user_alive(id))
	{
		return PLUGIN_HANDLED
	}
	if(!is_human(id))
		return PLUGIN_HANDLED
		
	new menu_selec_arm = menu_create("Weapon Arsenal" , "handler_selec_arm")
	new menu2[64]
	formatex(menu2, charsmax(menu2), "\w|\y Weapon Arsenal \w|")
	menu_setprop(menu_selec_arm, MPROP_TITLE, menu2)
	
	if(g_save_weapons[id][1] != -1)
		formatex(menu2, charsmax(menu2), "Arsenal Primario: \d[\y %s \d]", gArmasOptimizadas[g_save_weapons[id][1]][gWeaponName])
	else
		formatex(menu2, charsmax(menu2), "Arsenal Primario: \d[\w ... \d]")
	
	menu_additem(menu_selec_arm , menu2)
	
	if(g_save_weapons[id][2] != -1)
		formatex(menu2, charsmax(menu2), "Arsenal Secundario:\d [\y %s \d]", gPistolasOptimizadas[g_save_weapons[id][2]][gWeaponName])
	else
		formatex(menu2, charsmax(menu2), "Arsenal Secundario: \d[\w ... \d]")
	
	menu_additem(menu_selec_arm , menu2)
	
	if(g_save_weapons[id][4] != -1)
		formatex(menu2, charsmax(menu2), "Knifes:\d [\y %s \d]", gCuchillosOptimizadas[g_save_weapons[id][4]][Nombre_Cuchi])
	else
		formatex(menu2, charsmax(menu2), "Knifes: \d[\w ... \d]")
		
	menu_additem(menu_selec_arm , menu2)
	
	if(g_save_weapons[id][3] != -1)
		formatex(menu2, charsmax(menu2), "Granadas:\d [\y %s \d]^n", gGranadasOptimizadas[g_save_weapons[id][3]][WeaponName])
	else
		formatex(menu2, charsmax(menu2), "Granadas: \d[\w ... \d]^n")
	
	menu_additem(menu_selec_arm , menu2)
	
	if(g_save_weapons[id][1] != -1 && g_save_weapons[id][2] != -1 && g_save_weapons[id][3] != -1 && g_save_weapons[id][4] != -1)
		menu_additem(menu_selec_arm , "|\y Load Arsenal!! \w|^n" , "5")
	else
		menu_additem(menu_selec_arm , "|\d Load Arsenal!! \w|^n" , "5")
		
	menu_setprop(menu_selec_arm , MPROP_EXITNAME,"\ySalir")
	menu_display(id, menu_selec_arm , 0)
    
	return PLUGIN_HANDLED
}

public handler_selec_arm(id , menu_selec_arm , item)
{
	if(item == MENU_EXIT || !is_user_alive(id) || !is_human(id))
	{
		menu_destroy(menu_selec_arm)
		return PLUGIN_HANDLED
	}
        
	switch(item)
	{
		case 0: {
			menu_destroy(menu_selec_arm)
			Menu_Armas(id, 0)
		}
		case 1: {
			menu_destroy(menu_selec_arm)
			Menu_Pistolas(id, 0)
		}
		case 2: {
			menu_destroy(menu_selec_arm)
			Menu_Cuchillos(id, 0)
		}
		case 3: {
			menu_destroy(menu_selec_arm)
			Menu_Granadas(id, 0)
		}
		case 4 :
		{
			menu_destroy(menu_selec_arm);
			if(g_save_weapons[id][1] != -1 && g_save_weapons[id][2] != -1 && g_save_weapons[id][3] != -1 && g_save_weapons[id][4] != -1)
				GiveArsenal(id, g_save_weapons[id][1], g_save_weapons[id][2], g_save_weapons[id][3], g_save_weapons[id][4])
			else
				Menu_Seleccion_Armas(id)
		}
	}
	return PLUGIN_HANDLED;
}

public GiveArsenal(id, prim, sec, gra, kni)
{
	g_save_weapons[id][0] = true
	g_arma_prim[id] = prim
	drop_weapons(id , 1)
		
	fm_give_item(id , gArmasOptimizadas[prim][gWeaponClass])
	ExecuteHamB(Ham_GiveAmmo, id, MAXBPAMMO[gArmasOptimizadas[prim][gWeapon]], AMMOTYPE[gArmasOptimizadas[prim][gWeapon]], MAXBPAMMO[gArmasOptimizadas[prim][gWeapon]])
	
	g_canbuy[id]= false
	
	g_arma_sec[id] = sec
	drop_weapons(id , 2)
	fm_give_item(id , gPistolasOptimizadas[sec][gWeaponClass])
	ExecuteHamB(Ham_GiveAmmo, id, MAXBPAMMO[gPistolasOptimizadas[sec][gWeapon]], AMMOTYPE[gPistolasOptimizadas[sec][gWeapon]], MAXBPAMMO[gPistolasOptimizadas[sec][gWeapon]])
	g_canbuy_sec[id] = false
	
	g_arma_tri[id] = gra
	fm_give_item(id, "weapon_hegrenade")
	fm_give_item(id, "weapon_flashbang")
	fm_give_item(id, "weapon_smokegrenade")
	cs_set_user_bpammo(id, CSW_HEGRENADE, gGranadasOptimizadas[gra][Granada_1])
	cs_set_user_bpammo(id, CSW_FLASHBANG, gGranadasOptimizadas[gra][Granada_2])
	cs_set_user_bpammo(id, CSW_SMOKEGRENADE, gGranadasOptimizadas[gra][Granada_3])
	g_canbuy_tri[id] = false
	if(gra == 4)
		has_molotov[id]++
	if(gra == 5)
	{
		has_burbuja[id]++
		has_molotov[id]++
	}
	if(gra == 6)
	{
		has_burbuja[id]++
		has_molotov[id] = 2
	}
	if(gra == 7)
	{
		has_burbuja[id] = 2
		has_molotov[id] = 2
	}
	if(gra == 8)
	{
		has_burbuja[id] = 2
		has_molotov[id] = 3
	}
	if(gra == 9)
	{
		has_burbuja[id] = 3
		has_molotov[id] = 3
	}
	
	g_arma_four[id] = kni
	g_canbuy_four[id] = false
	fm_give_item(id, "weapon_knife")
	client_cmd(id, "slot3")
	if(g_currentweapon[id] != CSW_KNIFE)
		client_cmd(id, "slot3")
}

public Menu_Armas(taskid , page)
{
	new id = taskid
	
	new len[999] , temp[22]
	
	if(can_buy(id))
		return PLUGIN_HANDLED
		
	if(!g_canbuy[id])
		return PLUGIN_HANDLED
		
	new menu_armas = menu_create("\yElige Armamento Principal" , "Menu_Armas_Cases")
	
	for(new i = 0 ; i < sizeof gArmasOptimizadas ; i++)
	{
		if (g_level[id] >= gArmasOptimizadas[i][gNivelReq] && g_reset[id] >= gArmasOptimizadas[i][gResetReq])
			formatex(len, charsmax(len), "%s \y[Disponible]", gArmasOptimizadas[i][gWeaponName])
		else
			formatex(len, charsmax(len), "%s \r[Nivel:\y %d\w |\r RT:\y %d\r]", gArmasOptimizadas[i][gWeaponName], gArmasOptimizadas[i][gNivelReq], gArmasOptimizadas[i][gResetReq])
			
		num_to_str(i,temp, 2)
		menu_additem(menu_armas , len , temp)
	}
			
	menu_setprop(menu_armas , MPROP_BACKNAME,"Atras")
	menu_setprop(menu_armas , MPROP_NEXTNAME,"Siguiente")
	menu_setprop(menu_armas , MPROP_EXITNAME,"Salir")
	menu_display(id, menu_armas , page)
	
	return PLUGIN_HANDLED
}

public Menu_Armas_Cases(id , menu_armas , item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu_armas)
		Menu_Seleccion_Armas(id)
		return PLUGIN_HANDLED
	}

	if(can_buy(id)){
		menu_destroy(menu_armas)
		return PLUGIN_HANDLED
	}

	if(!g_canbuy[id])
	{
		zp_colored_print(id , "%s Ya Haz Comprado Tu^x04 Armamento Primario" , TAG)
		menu_destroy(menu_armas)
		return PLUGIN_HANDLED
	}
		
	new page , armas_2
	player_menu_info(id , menu_armas , armas_2 , page)
	
	if(g_level[id] < gArmasOptimizadas[item][gNivelReq])
	{	
		zp_colored_print(id, "%s Para elegir la^x04 %s^x01 necesitas ser^x04 Nivel^x01:^x04 %d^x01.", TAG, gArmasOptimizadas[item][gWeaponName], gArmasOptimizadas[item][gNivelReq])
		menu_destroy(menu_armas)
		Menu_Armas(id , page)        
		return PLUGIN_HANDLED
	}
	if(g_reset[id] < gArmasOptimizadas[item][gResetReq])
	{	
		zp_colored_print(id, "%s Para elegir la^x04 %s^x01 necesitas tener^x01:^x04 %d^x03 Resets.", TAG, gArmasOptimizadas[item][gWeaponName], gArmasOptimizadas[item][gResetReq])
		menu_destroy(menu_armas)
		Menu_Armas(id , page)        
		return PLUGIN_HANDLED
	}
	
	g_save_weapons[id][1] = item
	menu_destroy(menu_armas)
	Menu_Seleccion_Armas(id)
	
	return PLUGIN_HANDLED
}

can_buy(id)
{
	if(!is_user_alive(id))
	{
		zp_colored_print(id , "%s Debes Estar Vivo Para Elegir Las Armas." , TAG)
		return PLUGIN_HANDLED
	}
	if(!is_human(id))
	{
		zp_colored_print(id , "%s Para Elegir Armamento Debes Ser Humano." , TAG)
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}

public Menu_Pistolas(taskid , page)
{
	new id = taskid
	new len[999] , temp[22]
	
	if(can_buy(id) || !g_canbuy_sec[id])
		return PLUGIN_HANDLED
	
	new menu_pistolas = menu_create("\yElige Armamento Secundario" , "Menu_Pistolas_Cases")
	
	for(new i = 0 ; i < sizeof gPistolasOptimizadas ; i++)
	{
		if (g_level[id] >= gPistolasOptimizadas[i][gNivelReq] && g_reset[id] >= gPistolasOptimizadas[i][gResetReq])
			formatex(len, charsmax(len), "%s \y[Disponible]", gPistolasOptimizadas[i][gWeaponName])
		else
			formatex(len, charsmax(len), "%s \r[Nivel:\y %d\w |\r RT:\y %d\r]", gPistolasOptimizadas[i][gWeaponName], gPistolasOptimizadas[i][gNivelReq], gPistolasOptimizadas[i][gResetReq])
			
		num_to_str(i,temp, 2)
		menu_additem(menu_pistolas , len , temp)
	}
			
	menu_setprop(menu_pistolas , MPROP_BACKNAME,"Atras")
	menu_setprop(menu_pistolas , MPROP_NEXTNAME,"Siguiente")
	menu_setprop(menu_pistolas , MPROP_EXITNAME,"Salir")
	menu_display(id, menu_pistolas , page)
	
	return PLUGIN_HANDLED
}

public Menu_Pistolas_Cases(id , menu_pistolas , item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu_pistolas)
		Menu_Seleccion_Armas(id)
		return PLUGIN_HANDLED
	}
	
	if(can_buy(id)){
		menu_destroy(menu_pistolas)
		return PLUGIN_HANDLED
	}
		
	if(!g_canbuy_sec[id])
	{
		menu_destroy(menu_pistolas)
		zp_colored_print(id , "%s Ya Haz Comprado Tu^x04 Armamento Secundario" , TAG)
		return PLUGIN_HANDLED
	}
		
	new page , armas_2
	player_menu_info(id , menu_pistolas , armas_2 , page)
	
	if(g_level[id] < gPistolasOptimizadas[item][gNivelReq])
	{	
		zp_colored_print(id, "%s Para elegir la^x04 %s^x01 necesitas ser^x04 Nivel^x01:^x04 %d^x01.", TAG, gPistolasOptimizadas[item][gWeaponName], gPistolasOptimizadas[item][gNivelReq])
		menu_destroy(menu_pistolas)
		Menu_Pistolas(id , page)  
		return PLUGIN_HANDLED
	}
	if(g_reset[id] < gPistolasOptimizadas[item][gResetReq])
	{	
		zp_colored_print(id, "%s Para elegir la^x04 %s^x01 necesitas tener^x01:^x04 %d^x03 Resets.", TAG, gPistolasOptimizadas[item][gWeaponName], gPistolasOptimizadas[item][gResetReq])
		menu_destroy(menu_pistolas)
		Menu_Pistolas(id , page)  
		return PLUGIN_HANDLED
	}
	g_save_weapons[id][2] = item
	menu_destroy(menu_pistolas)
	Menu_Seleccion_Armas(id)
	
	return PLUGIN_HANDLED
}

public Menu_Granadas(taskid , page)
{
	new id = taskid
	new len[999] , temp[22]
	
	if(can_buy(id) || !g_canbuy_tri[id])
		return PLUGIN_HANDLED;
	
	new menu_granadas = menu_create("\yElige Armamento Extra" , "Menu_Granadas_Cases")
	
	for(new i = 0 ; i < sizeof gGranadasOptimizadas ; i++)
	{
		if (g_level[id] >= gGranadasOptimizadas[i][NivelReq] && g_reset[id] >= gGranadasOptimizadas[i][ResetReq])
			formatex(len, charsmax(len), "[%s] \y[Disponible]", gGranadasOptimizadas[i][WeaponName])
		else
			formatex(len, charsmax(len), "[%s] \r[Nivel:\y %d\w |\r RT:\y %d\r]", gGranadasOptimizadas[i][WeaponName], gGranadasOptimizadas[i][NivelReq], gGranadasOptimizadas[i][ResetReq])
			
		num_to_str(i,temp, 2)
		menu_additem(menu_granadas , len , temp)
	}
			
	menu_setprop(menu_granadas , MPROP_BACKNAME,"Atras")
	menu_setprop(menu_granadas , MPROP_NEXTNAME,"Siguiente")
	menu_setprop(menu_granadas , MPROP_EXITNAME,"Salir")
	menu_display(id, menu_granadas , page)
	
	return PLUGIN_HANDLED
}

public Menu_Granadas_Cases(id , menu_granadas , item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu_granadas)
		Menu_Seleccion_Armas(id)
		return PLUGIN_HANDLED
	}
	
	if(can_buy(id))
	{
		menu_destroy(menu_granadas)
		return PLUGIN_HANDLED
	}
	if(!g_canbuy_tri[id])
	{
		menu_destroy(menu_granadas)
		zp_colored_print(id , "%s Ya Haz Comprado Tu^x04 Armamento Extra" , TAG)
		return PLUGIN_HANDLED
	}
		
	new page , armas_2
	player_menu_info(id , menu_granadas , armas_2 , page)
	
	if(g_level[id] < gGranadasOptimizadas[item][NivelReq])
	{	
		zp_colored_print(id, "%s Para elegir la^x04 %s^x01 necesitas ser^x04 Nivel^x01:^x04 %d^x01.", TAG, gGranadasOptimizadas[item][WeaponName], gGranadasOptimizadas[item][NivelReq])
		menu_destroy(menu_granadas)
		Menu_Granadas(id , page)  
		return PLUGIN_HANDLED
	}
	if(g_reset[id] < gGranadasOptimizadas[item][ResetReq])
	{	
		zp_colored_print(id, "%s Para elegir la^x04 %s^x01 necesitas tener^x01:^x04 %d^x03 Resets.", TAG, gGranadasOptimizadas[item][WeaponName], gGranadasOptimizadas[item][ResetReq])
		menu_destroy(menu_granadas)
		Menu_Granadas(id , page)  
		return PLUGIN_HANDLED
	}
	
	g_save_weapons[id][3] = item
	
	menu_destroy(menu_granadas)
	Menu_Seleccion_Armas(id)
	return PLUGIN_HANDLED
}


public Menu_Cuchillos(taskid , page)
{
	new id = taskid
	new len[999] , temp[22]
	
	if(can_buy(id) || !g_canbuy_four[id])
		return PLUGIN_HANDLED
	
	new menu_cuchillos = menu_create("\yElige Cuchillos" , "Menu_Cuchillos_Cases")

	for(new i = 0 ; i < sizeof gCuchillosOptimizadas ; i++)
	{
		if (g_level[id] >= gCuchillosOptimizadas[i][Nivel_Cuchi] && g_reset[id] >= gCuchillosOptimizadas[i][Reset_Cuchi])
			formatex(len, charsmax(len), "%s \y[Disponible]", gCuchillosOptimizadas[i][Nombre_Cuchi])
		else
			formatex(len, charsmax(len), "%s \r[Nivel:\y %d\w |\r RT:\y %d\r]", gCuchillosOptimizadas[i][Nombre_Cuchi], gCuchillosOptimizadas[i][Nivel_Cuchi], gCuchillosOptimizadas[i][Reset_Cuchi])
			
		num_to_str(i,temp, 2)
		menu_additem(menu_cuchillos , len , temp)
	}
			
	menu_setprop(menu_cuchillos , MPROP_BACKNAME,"Atras")
	menu_setprop(menu_cuchillos , MPROP_NEXTNAME,"Siguiente")
	menu_setprop(menu_cuchillos , MPROP_EXITNAME,"Salir")
	menu_display(id, menu_cuchillos , page)
	
	return PLUGIN_HANDLED
}

public Menu_Cuchillos_Cases(id , menu_cuchillos , item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu_cuchillos)
		Menu_Seleccion_Armas(id)
		return PLUGIN_HANDLED
	}
	
	if(can_buy(id))
	{
		menu_destroy(menu_cuchillos)
		return PLUGIN_HANDLED
	}
		
	if(!g_canbuy_four[id])
	{
		menu_destroy(menu_cuchillos)
		zp_colored_print(id , "%s Ya Haz Comprado Tu^x04 Armamento Extra" , TAG)
		return PLUGIN_HANDLED
	}
		
	new page , armas_2
	player_menu_info(id , menu_cuchillos , armas_2 , page)
	
	if(g_level[id] < gCuchillosOptimizadas[item][Nivel_Cuchi])
	{	
		zp_colored_print(id, "%s Para elegir^x04 %s^x01 necesitas ser^x04 Nivel^x01:^x04 %d^x01.", TAG, gCuchillosOptimizadas[item][Nombre_Cuchi], gCuchillosOptimizadas[item][Nivel_Cuchi])
		menu_destroy(menu_cuchillos)
		Menu_Cuchillos(id , page)  
		return PLUGIN_HANDLED
	}
	if(g_reset[id] < gCuchillosOptimizadas[item][Reset_Cuchi])
	{	
		zp_colored_print(id, "%s Para elegir^x04 %s^x01 necesitas tener^x01:^x04 %d^x03 Resets.", TAG, gCuchillosOptimizadas[item][Nombre_Cuchi], gCuchillosOptimizadas[item][Reset_Cuchi])
		menu_destroy(menu_cuchillos)
		Menu_Cuchillos(id , page)  
		return PLUGIN_HANDLED
	}

	g_save_weapons[id][4] = item
	menu_destroy(menu_cuchillos)
	Menu_Seleccion_Armas(id)
	
	return PLUGIN_HANDLED;
}

// LA PARTE DEL TRAIL
public TraceAttack(victim, attacker, Float:damage, Float:direction[3], iTr, damage_type)
{
	// Non-player damage or self damage
	if (!is_user_valid_connected(attacker))
		return HAM_IGNORED
	
	if(!is_human(attacker))
		return HAM_SUPERCEDE
	
	new weapon = get_user_weapon(attacker)
	
	if(weapon == CSW_KNIFE)
		return HAM_IGNORED
		
	new Float:vecEndPos[3]
	get_tr2(iTr, TR_vecEndPos, vecEndPos)
	
	if(weapon == gArmasOptimizadas[g_arma_prim[attacker]][gWeapon])
	{
		engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecEndPos, 0)
		write_byte(TE_BEAMENTPOINT)
		write_short(attacker | 0x1000)
		engfunc(EngFunc_WriteCoord, vecEndPos[0]) // x
		engfunc(EngFunc_WriteCoord, vecEndPos[1]) // y
		engfunc(EngFunc_WriteCoord, vecEndPos[2]) // z
		write_short(gTracerDepre)
		write_byte(0) // framerate
		write_byte(0) // framerate
		write_byte(1) // life
		write_byte(gArmasOptimizadas[g_arma_prim[attacker]][Ancho])  // width
		write_byte(0)   // noise
		write_byte(gArmasOptimizadas[g_arma_prim[attacker]][Red])
		write_byte(gArmasOptimizadas[g_arma_prim[attacker]][Green])
		write_byte(gArmasOptimizadas[g_arma_prim[attacker]][Blue])
		write_byte(255)
		write_byte(0) // speed 
		message_end()
	}
	if(weapon == gPistolasOptimizadas[g_arma_sec[attacker]][gWeapon])
	{
		engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecEndPos, 0)
		write_byte(TE_BEAMENTPOINT)
		write_short(attacker | 0x1000)
		engfunc(EngFunc_WriteCoord, vecEndPos[0]) // x
		engfunc(EngFunc_WriteCoord, vecEndPos[1]) // y
		engfunc(EngFunc_WriteCoord, vecEndPos[2]) // z
		write_short(gTracerDepre)
		write_byte(0) // framerate
		write_byte(0) // framerate
		write_byte(1) // life
		write_byte(gPistolasOptimizadas[g_arma_sec[attacker]][Ancho])  // width
		write_byte(0)   // noise
		write_byte(gPistolasOptimizadas[g_arma_sec[attacker]][Red])
		write_byte(gPistolasOptimizadas[g_arma_sec[attacker]][Green])
		write_byte(gPistolasOptimizadas[g_arma_sec[attacker]][Blue])
		write_byte(255)
		write_byte(0) // speed 
		message_end()
	}

	return HAM_HANDLED
}

public make_tracer(id)
{
	if(!is_human(id))
		return HAM_SUPERCEDE
		
	static clip, ammo
	new wpnid = get_user_weapon(id,clip,ammo)
	new laser1[3], laser2[3]
	get_user_origin(id, laser1, 1)
	get_user_origin(id, laser2, 4)

	if(wpnid == gArmasOptimizadas[g_arma_prim[id]][gWeapon])
	{
		new vec1[3], vec2[3]
		get_user_origin(id, vec1, 1) // origin; your camera point.
		get_user_origin(id, vec2, 3) // termina; where your bullet goes (4 is cs-only)
		
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
		write_byte (0)     //TE_BEAMENTPOINTS 
		write_coord(vec1[0])
		write_coord(vec1[1])
		write_coord(vec1[2])
		write_coord(vec2[0])
		write_coord(vec2[1])
		write_coord(vec2[2])
		write_short(gTracerSpr)
		write_byte(1) // framestart
		write_byte(5) // framerate
		write_byte(2) // life
		write_byte(12) // width
		write_byte(0) // noise
		write_byte(gArmasOptimizadas[g_arma_prim[id]][Red2])
		write_byte(gArmasOptimizadas[g_arma_prim[id]][Green2])
		write_byte(gArmasOptimizadas[g_arma_prim[id]][Blue2])
		write_byte(255) // brightness
		write_byte(150) // speed
		message_end()
	}
	if(wpnid == gPistolasOptimizadas[g_arma_sec[id]][gWeapon])
	{
		new vec1[3], vec2[3]
		get_user_origin(id, vec1, 1) // origin; your camera point.
		get_user_origin(id, vec2, 3) // termina; where your bullet goes (4 is cs-only)
		
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
		write_byte (0)     //TE_BEAMENTPOINTS 
		write_coord(vec1[0])
		write_coord(vec1[1])
		write_coord(vec1[2])
		write_coord(vec2[0])
		write_coord(vec2[1])
		write_coord(vec2[2])
		write_short(gTracerSpr)
		write_byte(1) // framestart
		write_byte(5) // framerate
		write_byte(2) // life
		write_byte(12) // width
		write_byte(0) // noise
		write_byte(gPistolasOptimizadas[g_arma_sec[id]][Red2])
		write_byte(gPistolasOptimizadas[g_arma_sec[id]][Green2])
		write_byte(gPistolasOptimizadas[g_arma_sec[id]][Blue2])
		write_byte(255) // brightness
		write_byte(150) // speed
		message_end()
	}
	if(g_arma_prim[id] == 45 && g_currentweapon[id])
	{			
		if (wpnid == CSW_AWP) 
		{	
			message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
			write_byte (1)    
			write_short(id | 0x1000) 
			write_coord (laser2[0]) 
			write_coord (laser2[1])
			write_coord (laser2[2])
			write_short(gTracerDepre)
			write_byte(1) 
			write_byte(5) 
			write_byte(1) 
			write_byte(80) 
			write_byte(20) 
			write_byte(0)    
			write_byte(52)       
			write_byte(255)      
			write_byte(255) 
			write_byte(150)
			message_end()
			
			message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
			write_byte(TE_DLIGHT) 
			write_coord(laser1[0]) 
			write_coord(laser1[1]) 
			write_coord(laser1[2]) 
			write_byte(13)
			write_byte(254)
			write_byte(0)
			write_byte(0)
			write_byte(100)
			write_byte(10)
			message_end()
			
			message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
			write_byte(TE_SPRITETRAIL)
			write_coord(laser1[0])
			write_coord(laser1[1])
			write_coord(laser1[2])
			write_coord(laser1[0])
			write_coord(laser1[1])
			write_coord(laser1[2])
			write_short(hotflarex)
			write_byte(5)
			write_byte(1) 
			write_byte(3) 
			write_byte(34)
			write_byte(43)
			message_end()
			emit_sound(id, CHAN_AUTO, "weapons/electro4.wav", VOL_NORM, ATTN_NORM , 0, PITCH_NORM)	
		}
	}
	if(g_arma_prim[id] == ARMA_FNPLAYBOY)
	{			
		if (wpnid == CSW_P90) 
		{
			message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
			write_byte (1)    
			write_short(id | 0x1000) 
			write_coord (laser2[0]) 
			write_coord (laser2[1])
			write_coord (laser2[2])
			write_short(gRayoLevelSpr)
			write_byte(1) 
			write_byte(5) 
			write_byte(1) 
			write_byte(80) 
			write_byte(20) 
			write_byte(255)
			write_byte(61) 
			write_byte(216)    
			write_byte(255) 
			write_byte(150)
			message_end()
			
			message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
			write_byte(TE_DLIGHT)
			write_coord(laser1[0])
			write_coord(laser1[1])
			write_coord(laser1[2])
			write_byte(13)
			write_byte(255)
			write_byte(61)
			write_byte(216)
			write_byte(100)
			write_byte(15)
			message_end()
		}
	}
	if(g_arma_prim[id] == ARMA_SUPERAK47DORADA)
	{			
		if (wpnid == CSW_AK47) 
		{
			message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
			write_byte(TE_DLIGHT)
			write_coord(laser1[0])
			write_coord(laser1[1])
			write_coord(laser1[2])
			write_byte(13)
			write_byte(255)
			write_byte(204)
			write_byte(0)
			write_byte(100)
			write_byte(15)
			message_end()
		}
	}
	if(g_arma_sec[id] == 7)
	{
		if (wpnid == CSW_DEAGLE)
		{
			message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
			write_byte(TE_DLIGHT)
			write_coord(laser1[0])
			write_coord(laser1[1])
			write_coord(laser1[2])
			write_byte(13)
			write_byte(254)
			write_byte(0)
			write_byte(0)
			write_byte(100)
			write_byte(19)
			message_end()
		}
	}
	if(g_arma_sec[id] == 17)
	{
		if (wpnid == CSW_DEAGLE)
		{
			message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
			write_byte(TE_DLIGHT)
			write_coord(laser1[0])
			write_coord(laser1[1])
			write_coord(laser1[2])
			write_byte(20)
			write_byte(254)
			write_byte(204)
			write_byte(0)
			write_byte(100)
			write_byte(19)
			message_end()
		}
	}
	if(g_arma_sec[id] == 20)
	{			
		if (wpnid == CSW_DEAGLE) 
		{
			message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
			write_byte (1)    
			write_short(id | 0x1000) 
			write_coord (laser2[0]) 
			write_coord (laser2[1])
			write_coord (laser2[2])
			write_short(gRayoLevelSpr)
			write_byte(1) 
			write_byte(5) 
			write_byte(1) 
			write_byte(80) 
			write_byte(20) 
			write_byte(255)
			write_byte(255) 
			write_byte(0)    
			write_byte(255) 
			write_byte(150)
			message_end()
			
			message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
			write_byte(TE_DLIGHT)
			write_coord(laser1[0])
			write_coord(laser1[1])
			write_coord(laser1[2])
			write_byte(13)
			write_byte(255)
			write_byte(255)
			write_byte(0)
			write_byte(100)
			write_byte(15)
			message_end()
		}
	}
	if(g_arma_sec[id] == 21)
	{			
		if (wpnid == CSW_ELITE) 
		{
			message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
			write_byte(TE_DLIGHT)
			write_coord(laser1[0])
			write_coord(laser1[1])
			write_coord(laser1[2])
			write_byte(13)
			write_byte(255)
			write_byte(0)
			write_byte(0)
			write_byte(100)
			write_byte(19)
			message_end()
		}
	}
	if(g_arma_prim[id] == ARMA_SPAS)
	{
		if (wpnid == CSW_M3) 
		{
			/*static Float:vecEnd[ 3 ], Float:vecCalc[ 3 ], tr
			get_tr2(tr, TR_vecEndPos, vecEnd)
			FX_SpriteTrail(vecEnd, vecCalc, 8, 15, 3, 25, 25)*/
			message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
			write_byte(TE_DLIGHT)
			write_coord(laser1[0])
			write_coord(laser1[1])
			write_coord(laser1[2])
			write_byte(13)
			write_byte(10)
			write_byte(100)
			write_byte(200)
			write_byte(100)
			write_byte(24)
			message_end()
		}
	}
	return HAM_HANDLED
}

dead_efect(const Float:originF[3])
{
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
	write_byte(TE_PARTICLEBURST) 
	engfunc(EngFunc_WriteCoord, originF[0])
	engfunc(EngFunc_WriteCoord, originF[1]) 
	engfunc(EngFunc_WriteCoord, originF[2]+10) 
	write_short(250) 
	write_byte(70) 
	write_byte(55) 
	message_end()
	
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)			
	write_byte(TE_PARTICLEBURST) 
	engfunc(EngFunc_WriteCoord, originF[0])
	engfunc(EngFunc_WriteCoord, originF[1]) 
	engfunc(EngFunc_WriteCoord, originF[2]+10)
	write_short(250) 
	write_byte(70) 
	write_byte(55) 
	message_end()

	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)			
	write_byte(TE_PARTICLEBURST)
	engfunc(EngFunc_WriteCoord, originF[0]) 
	engfunc(EngFunc_WriteCoord, originF[1]) 
	engfunc(EngFunc_WriteCoord, originF[2]+10)
	write_short(250)
	write_byte(83) 
	write_byte(55)
	message_end()
	
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
	write_byte(TE_IMPLOSION)
	engfunc(EngFunc_WriteCoord, originF[0]) 
	engfunc(EngFunc_WriteCoord, originF[1]) 
	engfunc(EngFunc_WriteCoord, originF[2]+10) 
	write_byte(random_num(100, 300))
	write_byte(20) 
	write_byte(3) 
	message_end()
}


public fw_Weapon_PrimaryAttack_Post(entity)
{
	new id = pev(entity, pev_owner)
	
	if (g_habilidad[id] == HAB_RECOIL && is_human(id))
	{
		new Float: push[3]
		pev(id, pev_punchangle, push)
		xs_vec_sub(push, cl_pushangle[id], push)
		xs_vec_mul_scalar(push, 0.3 , push)
		xs_vec_add(push, cl_pushangle[id], push)
		set_pev(id, pev_punchangle, push)
		return HAM_IGNORED;
	}
	return HAM_IGNORED;
}

public Menu_Habilidades(id)
{	
	new temp[4] , len[999] , menu_hclass = menu_create("Eleccion de Clases Humanas:" , "Menu_Habilidades_Cases")
	
	for (new i = 0; i < sizeof gHabilidadesHumanas ; i++)
	{
		
		if(g_habilidadnext[id] == i)
			formatex(len , sizeof len - 1, "\d Humano %s \y-\r[\wElegido\r]" , gHabilidadesHumanas[i][Nombre_Clase])
		else if(g_level[id] >= gHabilidadesHumanas[i][Nivel_Hab] && g_reset[id] >= gHabilidadesHumanas[i][Reset_Hab])
			formatex(len , sizeof len - 1, "\y Humano %s \r[\y%s\r]" , gHabilidadesHumanas[i][Nombre_Clase], gHabilidadesHumanas[i][Nombre_Hab])
		else
			formatex(len , sizeof len - 1, "\dHumano %s \r[\wNivel:\y %d\r]" , gHabilidadesHumanas[i][Nombre_Clase], gHabilidadesHumanas[i][Nivel_Hab])
		
		num_to_str(i,temp, 2);	
		menu_additem(menu_hclass , len , temp)
	}
	
	menu_setprop(menu_hclass , MPROP_NEXTNAME , "\wSiguiente")
	menu_setprop(menu_hclass , MPROP_BACKNAME , "\wAnterior")
	menu_setprop(menu_hclass , MPROP_EXITNAME,"\wSalir")
	menu_setprop(menu_hclass , MPROP_EXIT, MEXIT_ALL)
	menu_display(id, menu_hclass , 0)

	return PLUGIN_HANDLED
}

public Menu_Habilidades_Cases(id, menu_hclass, item)
{
	if (item == MENU_EXIT)
	{
		Menu_Principal_Juego(id)
		menu_destroy(menu_hclass)
		return PLUGIN_HANDLED
	}
	
	new iData[6];
	new iAccess;
	new iCallback;
	new iName[64];
	menu_item_getinfo(menu_hclass , item, iAccess, iData, 5, iName, 63, iCallback)
	
	if(g_level[id] < gHabilidadesHumanas[item][Nivel_Hab])
	{	
		zp_colored_print(id, "%s Para elegir esta^x04 Clase^x01 necesitas ser^x04 Nivel^x01:^x04 %d^x01.", TAG, gHabilidadesHumanas[item][Nivel_Hab])
		Menu_Habilidades(id)
		return PLUGIN_HANDLED;
	}
	if(g_reset[id] < gHabilidadesHumanas[item][Reset_Hab])
	{	
		zp_colored_print(id, "%s Para elegir esta^x04 Clase^x01 necesitas tener:^x04 %d^x03 Resets.", TAG, gHabilidadesHumanas[item][Reset_Hab])
		Menu_Habilidades(id)
		return PLUGIN_HANDLED;
	}
	
	g_classcounter2[id]++
	g_habilidadnext[id] = item
	zp_colored_print(id, "%s El Proximo Round Tendras La Clase:^x03 %s", TAG, gHabilidadesHumanas[item][Nombre_Hab])
	Menu_Principal_Juego(id)
	return PLUGIN_HANDLED
}

public radar_scan_detecta_zombies()
{	
	new zombie_count = 0;
	new zombie_list[32];
	new ZombieCoords[3];
		
	for (new id = 1 ; id <= get_maxplayers() ; id++)
	{
		if(!is_user_valid_alive(id) || !is_zombie(id))
			continue

		zombie_count++;
		zombie_list[zombie_count]=id;
	}
	
	for (new id = 1 ; id <= get_maxplayers() ; id++)
	{
		if(!g_isalive[id] || g_zombie[id])
			continue
			
		if(g_radar_detecta_zombies[id] || g_habilidad[id] == HAB_RADAR)
		{	
			for (new i = 1 ; i <= zombie_count ; i++)
			{
				get_user_origin(zombie_list[i], ZombieCoords)
				message_begin(MSG_ONE_UNRELIABLE, g_msgHostageAdd, {0,0,0}, id) 
				write_byte(id)
				write_byte(i)		
				write_coord(ZombieCoords[0])
				write_coord(ZombieCoords[1])
				write_coord(ZombieCoords[2])
				message_end()
				
				message_begin(MSG_ONE_UNRELIABLE, g_msgHostageDel, {0,0,0}, id)
				write_byte(i)
				message_end()
			}
		}
	}
}

public radar_scan_detecta_humanos()
{	
	new zombie_count = 0;
	new zombie_list[32];
	new ZombieCoords[3];
	
	for (new id = 1 ; id <= g_maxplayers  ; id++)
	{
		if(!is_user_valid_alive(id) || !is_human(id))
			continue

		zombie_count++;
		zombie_list[zombie_count]=id;
	}
	
	for (new id = 1 ; id <= g_maxplayers ; id++)
	{
		if(!g_isalive[id] || !g_zombie[id])
			continue
			
		if(!g_radar_detecta_humanos[id])
			continue
			
		for (new i = 1 ; i <= zombie_count ; i++)
		{
			get_user_origin(zombie_list[i], ZombieCoords)
			message_begin(MSG_ONE_UNRELIABLE, g_msgHostageAdd, {0,0,0}, id) 
			write_byte(id)
			write_byte(i)		
			write_coord(ZombieCoords[0])
			write_coord(ZombieCoords[1])
			write_coord(ZombieCoords[2])
			message_end()
			
			message_begin(MSG_ONE_UNRELIABLE, g_msgHostageDel, {0,0,0}, id)
			write_byte(i)
			message_end()
		}
	}
}

public create_cure(taskid)
{
	new id = ID_CURE
	if(g_survivor[id] || g_sniper[id] || g_wesker[id] || g_depre[id] || g_ninja[id] || g_l4d[id][2] || g_l4d[id][0]
	|| g_l4d[id][1] || g_l4d[id][3] || g_zombie[id] || g_habilidad[id] != HAB_MEDICO) 
	{
		remove_task(id+TASK_CURE)
		return PLUGIN_HANDLED
	}
	
	if (get_user_health(id) < 300)
		fm_set_user_health(id , min(get_user_health(id) + 10 , 200))
	return PLUGIN_HANDLED
}

public fw_GrenadeTouch(const entity, const e_World)
{
	// La molotov explota instantaneamente cuando rebota
	if (pev(entity, PEV_NADE_TYPE) == NADE_TYPE_MOLOTOV)
	{
		set_pev(entity, pev_dmgtime, 0.0)
		
		return HAM_HANDLED;
	}

	return HAM_IGNORED;
}

public effect_molotov_fire(entity)
{
	if (!pev_valid(entity))
	{
		remove_task(entity)
		return;
	}
	
	new Float:rx, Float:ry, Float:rz, Float:originF[3]

	rx = random_float(-5.0, 5.0)
	ry = random_float(-5.0, 5.0)
	rz = random_float(-5.0, 5.0)
	
	pev(entity, pev_origin, originF)

	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
	write_byte(17)
	engfunc(EngFunc_WriteCoord, originF[0] + rx) 		// x
	engfunc(EngFunc_WriteCoord, originF[1] + ry) 		// y
	engfunc(EngFunc_WriteCoord, originF[2] + rz) 		// z
	write_short(g_MolotovTrail)
	write_byte(10) 						// byte (scale in 0.1's) 188 - era 65
	write_byte(200) 					// byte (framerate)
	message_end()
	
	//Smoke
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
	//message_begin(MSG_BROADCAST, SVC_TEMPENTITY, korigin)
	write_byte(5)
	engfunc(EngFunc_WriteCoord, originF[0]) 	// x
	engfunc(EngFunc_WriteCoord, originF[1]) 	// y
	engfunc(EngFunc_WriteCoord, originF[2]) 	// z
	write_short(g_smokeSpr)				// short (sprite id)
	write_byte(20) 					// byte (scale in 0.1's)
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

public Glow_Off(victim)
	fm_set_rendering(victim, kRenderFxGlowShell, 0, 0, 0, kRenderNormal, 10);

// Funcion de las Particulas:
public Particulas(id)
{
	id -= TASK_PARTICULAS
	if (!g_isalive[id])
		return
		
	static Float:Origin[3]
	pev(id, pev_origin, Origin)
	
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, Origin, 0) // Abrmios la Funcion
	write_byte(TE_IMPLOSION) // TE Id
	engfunc(EngFunc_WriteCoord, Origin[0]) // Posicion del Player
	engfunc(EngFunc_WriteCoord, Origin[1]) // Posicion 'Y'
	engfunc(EngFunc_WriteCoord, Origin[2]) // Posicion 'X'
	write_byte(128) // Radio de las Particulas
	write_byte(48) // Particulas por Segundo
	write_byte(2) // Delay Rate = Tiempo que tarda en desaparecer las Particulas.
	message_end() // Cerramos la Funcion.
}

public message_DeathMsg(msg_id, msg_dest, id)
{
	static szTruncatedWeapon[33], attacker, victim
	
	// Get truncated weapon
	get_msg_arg_string(4, szTruncatedWeapon, charsmax(szTruncatedWeapon))
	
	// Get attacker and victim
	attacker = get_msg_arg_int(1)
	victim = get_msg_arg_int(2)
	
	// Non-player attacker or self kill
	if(!g_isconnected[attacker] || attacker == victim)
		return PLUGIN_CONTINUE
		
	// Killed by world, usually executing Ham_Killed and attacker has a Gauss
	if(equal(szTruncatedWeapon, "world") && get_user_weapon(attacker) == CSW_AWP && g_arma_prim[id] == ARMA_GAUSS)
		set_msg_arg_string(4, "gauss_beam")
		
	return PLUGIN_CONTINUE
}

/*================================================================================
 [Internal Functions]
=================================================================================*/

FX_BloodStream(iOrigin[3], count)
{
	for(new i = 1; i <= count; i++)
	{
		message_begin(MSG_PVS, SVC_TEMPENTITY, iOrigin) 
		write_byte(TE_BLOODSTREAM)
		write_coord(iOrigin[0])
		write_coord(iOrigin[1])
		write_coord(iOrigin[2]+40)
		write_coord(random_num(-30,30)) // x
		write_coord(random_num(-30,30)) // y
		write_coord(random_num(80,300)) // z
		write_byte(70) // color
		write_byte(random_num(100,200)) // speed
		message_end()
	}
}

FX_BloodSpurt(iOrigin[3])
{
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY) 
	write_byte(TE_LAVASPLASH)
	write_coord(iOrigin[0]) 
	write_coord(iOrigin[1]) 
	write_coord(iOrigin[2]-26) 
	message_end()
}

FX_Particles_Large(iOrigin[3])
{
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_IMPLOSION) 
	write_coord(iOrigin[0]) 
	write_coord(iOrigin[1]) 
	write_coord(iOrigin[2]) 
	write_byte(200) 
	write_byte(40) 
	write_byte(45) 
	message_end()
	
	// Sound by a new entity
	new iEnt = create_entity("info_target")
	
	// Integer vector into a Float Vector
	new Float:flOrigin[3]
	IVecFVec(iOrigin, flOrigin)
	
	// Set player's origin
	entity_set_origin(iEnt, flOrigin)
	
	// Sound
	emit_sound(iEnt, CHAN_WEAPON, "ambience/particle_suck2.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	
	// Remove entity
	remove_entity(iEnt)
}

FX_Particles(iOrigin[3], count)
{
	for(new i = 1; i <= count; i++)
	{
		message_begin(MSG_PVS, SVC_TEMPENTITY, iOrigin)
		write_byte(TE_IMPLOSION)
		write_coord(iOrigin[0]) 
		write_coord(iOrigin[1]) 
		write_coord(iOrigin[2]) 
		write_byte(random_num(100, 300))
		write_byte(20) 
		write_byte(3) 
		message_end()
	}
}

// Frost Effect
public FrostEffect(id)
{
	// Only effect alive unfrozen zombies
	if (!g_isalive[id] || !g_zombie[id] || g_frozen[id] || g_antihielo[id] || g_nodamage[id])
		return;
	
	message_begin(MSG_ONE_UNRELIABLE, g_msgDamage, _, id)
	write_byte(0) // damage save
	write_byte(0) // damage take
	write_long(DMG_DROWN) // damage type - DMG_FREEZE
	write_coord(0) // x
	write_coord(0) // y
	write_coord(0) // z
	message_end()
	
	// Add a blue tint to their screen
	message_begin(MSG_ONE, g_msgScreenFade, _, id)
	write_short(0) // duration
	write_short(0) // hold time
	write_short(FFADE_STAYOUT) // fade type
	write_byte(0) // red
	write_byte(50) // green
	write_byte(200) // blue
	write_byte(100) // alpha
	message_end()
	
	fm_set_rendering(id, kRenderFxGlowShell, 0, 100, 200, kRenderNormal, 100)

	g_frozen[id] = true
	set_task(4.0, "remove_freeze", id)
}

// Frost Effect Sound
public FrostEffectSound(iOrigin[3])
{
	new Entity = create_entity("info_target")
	
	new Float:flOrigin[3]
	IVecFVec(iOrigin, flOrigin)
	
	entity_set_origin(Entity, flOrigin)
	
	emit_sound(Entity, CHAN_WEAPON, "warcraft3/impalehit.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	
	remove_entity(Entity)
}

// Frost Effect Ring
FrostEffectRing(const Float:originF3[3])
{
	// Largest ring
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF3, 0)
	write_byte(TE_BEAMCYLINDER) // TE id
	engfunc(EngFunc_WriteCoord, originF3[0]) // x
	engfunc(EngFunc_WriteCoord, originF3[1]) // y
	engfunc(EngFunc_WriteCoord, originF3[2]) // z
	engfunc(EngFunc_WriteCoord, originF3[0]) // x axis
	engfunc(EngFunc_WriteCoord, originF3[1]) // y axis
	engfunc(EngFunc_WriteCoord, originF3[2]+100.0) // z axis
	write_short(g_exploSpr) // sprite
	write_byte(0) // startframe
	write_byte(0) // framerate
	write_byte(4) // life
	write_byte(60) // width
	write_byte(0) // noise
	write_byte(41) // red
	write_byte(138) // green
	write_byte(255) // blue
	write_byte(200) // brightness
	write_byte(0) // speed
	message_end()
}

// Frost Effect Ring
FuegoEffectRing(const Float:originF3[3])
{
	// Largest ring
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF3, 0)
	write_byte(TE_BEAMCYLINDER) // TE id
	engfunc(EngFunc_WriteCoord, originF3[0]) // x
	engfunc(EngFunc_WriteCoord, originF3[1]) // y
	engfunc(EngFunc_WriteCoord, originF3[2]) // z
	engfunc(EngFunc_WriteCoord, originF3[0]) // x axis
	engfunc(EngFunc_WriteCoord, originF3[1]) // y axis
	engfunc(EngFunc_WriteCoord, originF3[2]+100.0) // z axis
	write_short(g_exploSpr) // sprite
	write_byte(0) // startframe
	write_byte(0) // framerate
	write_byte(4) // life
	write_byte(60) // width
	write_byte(0) // noise
	write_byte(255) // red
	write_byte(143) // green
	write_byte(31) // blue
	write_byte(255) // brightness
	write_byte(0) // speed
	message_end()
}

/*================================================================================
[Hora Feliz]
=================================================================================*/

public clcmd_hf(id)
{
	new current_time[3][3]
	
	format_time(current_time[0], charsmax(current_time[]), "%H")
	format_time(current_time[1], charsmax(current_time[]), "%M")
	format_time(current_time[2], charsmax(current_time[]), "%S")
	
	new start, end
	
	start = str_to_num(current_time[0])
	
	if (HF_MULTIPLIER > 1)
	{
		end = get_pcvar_num(gCvarsPlugin[TERMINO_HORAFELIZ][gCvarValor])
	}
	else
	{
		end = get_pcvar_num(gCvarsPlugin[EMPIEZO_HORAFELIZ][gCvarValor])
	}
	
	new h, m, s
	while (start != end)
	{
		start++
		h++
		
		if (start == 24)
			start = 0
	}
	
	m = str_to_num(current_time[1])
	s = str_to_num(current_time[2])
	
	if (m)
	{
		h--
		m = 60 - m
		
		if (s) s = 60 - s
		
	}
	else if (s)
	{
		h--
		s = 60 - s
	}
	new hours[16], minuts[16], seconds[16]
	
	if (h > 0) formatex(hours, charsmax(hours), "^4%d ^1Horas, ", h)
	if (m > 0) formatex(minuts, charsmax(minuts), "^4%d ^1Minutos ", m)
	if (s > 0) formatex(seconds, charsmax(seconds), "^4%d ^1Segundos", s)
	
	if (h <= 0 && m <= 0 && s <= 0)
	{
		zp_colored_print(id, "%s En la siguiente ronda %s la ^x04HORA FELIZ^x01", TAG, HF_MULTIPLIER > 1 ? "TERMINARA" : "EMPEZARA")
	}
	else
	{
		zp_colored_print(id, "%s Faltan %s%s%s para que %s la ^x04HORA FELIZ^x01", TAG, hours, minuts, seconds, HF_MULTIPLIER > 1 ? "termine" : "empieze")
	}
}

is_hf() {
	static szhour[4], hour
	format_time(szhour, charsmax(szhour), "%H")
	
	hour = str_to_num(szhour)
	
	new start, end
	
	start = get_pcvar_num(gCvarsPlugin[EMPIEZO_HORAFELIZ][gCvarValor])
	end = get_pcvar_num(gCvarsPlugin[TERMINO_HORAFELIZ][gCvarValor])
	
	new bool:_hf
	while (start != end)
	{
		if (start == 24)
			start = 0
		
		if (start == hour)
		{
			_hf = true
			break;
		}
		start++
	} 
	
	if (_hf)
	{
		if (!announce_HF[0])
		{
			announce_HF[0] = true
			zp_colored_print(0, "%s^x03 La hora feliz ha empezado, Ammopacks, Exp y Puntos^x01 (^x04x%d^x01)^x03.", TAG, get_pcvar_num(gCvarsPlugin[MULTI_HORAFELIZ][gCvarValor]))
		}
		else{
			zp_colored_print(0, "%s^x04 Estas en la hora feliz disfruta mientras ganas Ammopacks, Exp y Puntos^x01 (^x03x%d^x01)^x04.", TAG, get_pcvar_num(gCvarsPlugin[MULTI_HORAFELIZ][gCvarValor]))
			HF_MULTIPLIER = get_pcvar_num(gCvarsPlugin[MULTI_HORAFELIZ][gCvarValor])
			
			return;  
		}
	}
	else if(gCvarsPlugin[TERMINO_HORAFELIZ][gCvarValor] == hour)
	{
		if (!announce_HF[1])
		{
			announce_HF[1] = true
			zp_colored_print(0, "%s^x04 La hora feliz ha terminado^x01.", TAG)
		}
	}  
	HF_MULTIPLIER = 1
}  

/*
FX_SpriteTrail(Float:vecStart[ ], Float:vecDest[ ], iCount, iLife, iScale, iVel, iRnd)
{
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_BEAMSPRITE) // Sprite trail
	engfunc(EngFunc_WriteCoord, vecStart[ 0 ]) // Position X
	engfunc(EngFunc_WriteCoord, vecStart[ 1 ]) // Position Y
	engfunc(EngFunc_WriteCoord, vecStart[ 2 ]) // Position Z
	engfunc(EngFunc_WriteCoord, vecDest[ 0 ]) // Position X
	engfunc(EngFunc_WriteCoord, vecDest[ 1 ]) // Position Y
	engfunc(EngFunc_WriteCoord, vecDest[ 2 ]) // Position Z
	write_short(g_iBalls) // SPrite id
	write_byte(iCount) // Amount
	write_byte(iLife) // Life
	write_byte(iScale) // Scale
	write_byte(iVel) // Velocity along vector
	write_byte(iRnd) // Randomness of velocity
	message_end()
}
*/

public Menu_Mejoras_Hm(id) 
{    
	new len[99] , temp[2] 
	
	new menu2 = menu_create("Sistema De Puntos Para Mejorar Capacidades^nPara Conseguir Puntos Mata Especies", "Menu_Mejoras_Hm_Cases") 
	
	for(new i = 0; i < sizeof gMejoras; i++) 
	{ 
		if(g_mejoras[id][i] <= gMejoras[i][MEJORA_MAX]) 
		{ 
			if(g_puntos[id] >= costo(g_mejoras[id][i])) 
				formatex(len , charsmax(len) , "\yAumentar \w%s \r[\w%d\y/\w%d\r] (\w%d\y Punto%s\r)", gMejoras[i][MEJORA_NAME],g_mejoras[id][i], gMejoras[i][MEJORA_MAX], costo(g_mejoras[id][i]), costo(g_mejoras[id][i]) == 1 ? "" : "s")  
			else 
				formatex(len , charsmax(len) , "\dAumentar %s\r [\w%d\y/\w%d\r] (\w%d\y Punto%s\r)", gMejoras[i][MEJORA_NAME], g_mejoras[id][i], gMejoras[i][MEJORA_MAX], costo(g_mejoras[id][i]), costo(g_mejoras[id][i]) == 1 ? "" : "s") 
		}
		num_to_str(i,temp, 2) 
		menu_additem(menu2 , len , temp) 
	} 
     
	menu_setprop(menu2 , MPROP_BACKNAME,"\yAtras") 
	menu_setprop(menu2 , MPROP_NEXTNAME,"\ySiguiente") 
	menu_setprop(menu2 , MPROP_EXITNAME,"\ySalir") 
	menu_display(id, menu2 , 0)     
	return PLUGIN_HANDLED 
} 


public Menu_Mejoras_Hm_Cases(id, menu, item)
{
	if (item == MENU_EXIT)
	{
		Menu_Perfil(id)
		menu_destroy(menu)
		return
	}
     
	if(g_puntos[id] < costo(g_mejoras[id][item])) 
	{ 
		zp_colored_print(id, "%s Nesecitas^x03 %d^x01 puntos para mejorar^x03 %s^x01.",TAG, costo(g_mejoras[id][item]), gMejoras[item][MEJORA_NAME]) 
		Menu_Mejoras_Hm(id) 
		return
	} 
     
	if(g_mejoras[id][item] >= gMejoras[item][MEJORA_MAX]) 
	{ 
		zp_colored_print(id, "%s Subistes el maximo de puntos para la mejora:^x03 %s^x01.",TAG, gMejoras[item][MEJORA_NAME]) 
		Menu_Mejoras_Hm(id) 
		return
	} 
     
	g_puntos[id] -= costo(g_mejoras[id][item])
	g_mejoras[id][item]++  
	zp_colored_print(id,"%s Subistes la mejora:^x03 %s^x01 ahora tienes^x03 %d^x01/^x03%d^x01 completada de ella. ",TAG, gMejoras[item][MEJORA_NAME], g_mejoras[id][item], gMejoras[item][MEJORA_MAX]) 
	Menu_Mejoras_Hm(id)
}

public countdown()
{
	set_task(2.0, "ten", TASK_COUNTDOWN)
	set_task(3.0, "nine", TASK_COUNTDOWN)
	set_task(4.0, "eight", TASK_COUNTDOWN)
	set_task(5.0, "seven", TASK_COUNTDOWN)
	set_task(6.0, "six", TASK_COUNTDOWN)
	set_task(7.0, "five", TASK_COUNTDOWN)
	set_task(8.0, "four", TASK_COUNTDOWN)
	set_task(9.0, "three", TASK_COUNTDOWN)
	set_task(10.0, "two", TASK_COUNTDOWN)
	set_task(11.0, "one", TASK_COUNTDOWN)
}

public ten()
{
	if(g_newround)
	{
		set_dhudmessage(0, 180, 255, -1.0, 0.28, 2, 0.02, 1.0, 0.01, 0.1)
		show_dhudmessage(0, "Habra una mutacion en: 10")
		client_cmd(0, "spk fvox/ten.wav")
	}
}

public nine()
{
	if(g_newround)
	{
		set_dhudmessage(0, 180, 255, -1.0, 0.28, 2, 0.02, 1.0, 0.01, 0.1)
		show_dhudmessage(0, "Habra una mutacion en: 9")
		client_cmd(0, "spk fvox/nine.wav")
	}
}

public eight()
{
	if(g_newround)
	{
		set_dhudmessage(0, 180, 255, -1.0, 0.28, 2, 0.02, 1.0, 0.01, 0.1)
		show_dhudmessage(0, "Habra una mutacion en: 8")
		client_cmd(0, "spk fvox/eight.wav")
	}
}

public seven()
{
	if(g_newround)
	{
		set_dhudmessage(0, 180, 255, -1.0, 0.28, 2, 0.02, 1.0, 0.01, 0.1)
		show_dhudmessage(0, "Habra una mutacion en: 7")
		client_cmd(0, "spk fvox/seven.wav")
	}
}

public six()
{
	if(g_newround)
	{
		set_dhudmessage(255, 255, 0, -1.0, 0.28, 2, 0.02, 1.0, 0.01, 0.1)
		show_dhudmessage(0, "Habra una mutacion en: 6")
		client_cmd(0, "spk fvox/six.wav")
	}
}

public five()
{
	if(g_newround)
	{
		set_dhudmessage(255, 200, 0, -1.0, 0.28, 2, 0.02, 1.0, 0.01, 0.1)
		show_dhudmessage(0, "Habra una mutacion en: 5")
		client_cmd(0, "spk fvox/five.wav")
	}
}

public four()
{
	if(g_newround)
	{
		set_dhudmessage(255, 150, 0, -1.0, 0.28, 2, 0.02, 1.0, 0.01, 0.1)
		show_dhudmessage(0, "Habra una mutacion en: 4")
		client_cmd(0, "spk fvox/four.wav")
	}
}

public three()
{
	if(g_newround)
	{
		set_dhudmessage(255, 100, 0, -1.0, 0.28, 2, 0.02, 1.0, 0.01, 0.1)
		show_dhudmessage(0, "Habra una mutacion en: 3")
		client_cmd(0, "spk fvox/three.wav")
	}
}

public two()
{
	if(g_newround)
	{
		set_dhudmessage(255, 50, 0, -1.0, 0.28, 2, 0.02, 1.0, 0.01, 0.1)
		show_dhudmessage(0, "Habra una mutacion en: 2")
		client_cmd(0, "spk fvox/two.wav")
	}
}

public one()
{
	if(g_newround)
	{
		set_dhudmessage(255, 0, 0, -1.0, 0.28, 2, 0.02, 1.0, 0.01, 0.1)
		show_dhudmessage(0, "Habra una mutacion en: 1")
		client_cmd(0, "spk fvox/one.wav")
	}
}

stock te_sprite(id, Float:origin[3], sprite, scale, brightness)
{
	if(!is_user_alive(id))
		return
		
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

public Comprar_HP_y_Armor(id)
{
	if(!g_isalive[id] || !is_human(id))
		return
		
	if(!(g_level[id] >= 18))
	{
		zp_colored_print(id, "%s No Tienes Nivel Suficiente Para Comprar^x03 Primeros Auxilios.", TAG)
		return;	
	}
	if(g_ammopacks[id] >= 34)
	{
		new Float:chaleco
		pev(id, pev_armorvalue, chaleco)
		set_pev(id, pev_armorvalue, chaleco+150.0)
		fm_set_user_health(id, get_user_health(id) + 150)
		zp_colored_print(id, "%s Haz Comprado^x04 Primeros Auxilios^x03 +150 Vida^x04 +150 Chaleco.", TAG)
		g_ammopacks[id] -= 34
		return;
	}
	else
	{
		zp_colored_print(id, "%s No Tienes Ammopacks Suficientes Para Comprar^x03 Primeros Auxilios.", TAG)
		return;
	}
}

public Comprar_HP(id)
{
	if(!g_isalive[id] || !is_human(id))
		return
	if(!(g_level[id] >= 15))
	{
		zp_colored_print(id, "%s No Tienes Nivel Suficiente Para Comprar^x03 +100 HP.", TAG)
		return
	}
	if(g_ammopacks[id] >= 15)
	{
		fm_set_user_health(id, get_user_health(id) + 100)
		zp_colored_print(id, "%s Haz Comprado^x04 +100 HP.", TAG)
		g_ammopacks[id] -= 15
		return;
	}
	else
	{
		zp_colored_print(id, "%s No Tienes Ammopacks Suficientes Para Comprar^x03 +100 HP.", TAG)
		return;
	}
}
		
public Comprar_Armor(id)
{
	if(!g_isalive[id] || !is_human(id))
		return
		
	if(!(g_level[id] >= 15))
	{
		zp_colored_print(id, "%s No Tienes Nivel Suficiente Para Comprar^x03 +100 Chaleco.", TAG)
		return
	}
	if(g_ammopacks[id] >= 15)
	{
		new Float:chaleco
		pev(id, pev_armorvalue, chaleco)
		set_pev(id, pev_armorvalue, chaleco+100.0)
		zp_colored_print(id, "%s Haz Comprado^x04 +100 Chaleco.", TAG)
		g_ammopacks[id] -= 15
		return;
	}
	else
	{
		zp_colored_print(id, "%s No Tienes Ammopacks Suficientes Para Comprar^x03 +100 Chaleco.", TAG)
		return;
	}
}	

UpdateFrags(attacker, victim, frags, deaths, scoreboard)
{
	// Set attacker frags
	set_pev(attacker, pev_frags, float(pev(attacker, pev_frags) + frags))
	
	// Set victim deaths
	fm_cs_set_user_deaths(victim, cs_get_user_deaths(victim) + deaths)
	
	// Update scoreboard with attacker and victim info
	if (scoreboard)
	{
		message_begin(MSG_BROADCAST, g_msgScoreInfo)
		write_byte(attacker) // id
		write_short(pev(attacker, pev_frags)) // frags
		write_short(cs_get_user_deaths(attacker)) // deaths
		write_short(0) // class?
		write_short(fm_cs_get_user_team(attacker)) // team
		message_end()
		
		message_begin(MSG_BROADCAST, g_msgScoreInfo)
		write_byte(victim) // id
		write_short(pev(victim, pev_frags)) // frags
		write_short(cs_get_user_deaths(victim)) // deaths
		write_short(0) // class?
		write_short(fm_cs_get_user_team(victim)) // team
		message_end()
	}
}
	
public switch_to_knife(id)
{
	if (!g_isalive[id]) return;
	
	if (has_baz[id] && CanShoot[id])
	{
		set_pev(id, pev_viewmodel2, gModelsManos[MODEL_VBAZOOKA]);
		set_pev(id, pev_weaponmodel2, gModelsManos[MODEL_PBAZOOKA]);
	}
}

public fw_prethink(id)
{
	static button;
	button = pev(id, pev_button);
	if(button & IN_ATTACK )
		fire_call(id);
}
public fire_call(id)
{
	if (g_isalive[id] && has_baz[id] && CanShoot[id])
	{
		new weapon = get_user_weapon(id);
		if ( weapon == CSW_KNIFE ) fire_rocket(id);
	}
}

fire_rocket(id)
{
	if ( !CanShoot[id] ) return;
	
	CanShoot[id] = false;
	set_task(get_pcvar_float(pcvar_delay), "rpg_reload", id);
	engclient_cmd(id, "weapon_knife")

	new Float:StartOrigin[3], Float:Angle[3];
	pev(id, pev_origin, StartOrigin);
	pev(id, pev_v_angle, Angle);

	Angle[0] *= -1.0;
	new ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"));
	set_pev(ent, pev_classname, "rpgrocket");
	engfunc(EngFunc_SetModel, ent, gModelsManos[MODEL_XBAZOOKA])
	set_pev(ent, pev_mins, {-1.0, -1.0, -1.0});
	set_pev(ent, pev_maxs, {1.0, 1.0, 1.0});
	engfunc(EngFunc_SetOrigin, ent, StartOrigin);
	set_pev(ent, pev_v_angle, Angle);


	set_pev(ent, pev_solid, 2);
	set_pev(ent, pev_movetype, 5);
	set_pev(ent, pev_owner, id);

	new Float:nVelocity[3];
	velocity_by_aim(id, 1500, nVelocity);
	set_pev(ent, pev_velocity, nVelocity);

	emit_sound(ent, CHAN_WEAPON, "weapons/rocketfire1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
	emit_sound(ent, CHAN_VOICE, "weapons/nuke_fly.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);

	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(22);
	write_short(ent);
	write_short(rocketsmoke);
	write_byte(30);
	write_byte(3);
	write_byte(255);
	write_byte(255);
	write_byte(255);
	write_byte(255);
	message_end();
}
public rpg_reload(id)
{
	CanShoot[id] = true;
	if ( get_user_weapon(id) == CSW_KNIFE ) switch_to_knife(id);	//sets our model
}

public fw_touch(ent, touched)
{
	if ( !pev_valid(ent) ) return FMRES_IGNORED;
	static entclass[32];
	pev(ent, pev_classname, entclass, 31);
	if ( equali(entclass, "rpg_temp") )
	{
		static touchclass[32];
		pev(touched, pev_classname, touchclass, 31);
		if ( !equali(touchclass, "player") ) return FMRES_IGNORED;
		
		if( !g_isalive[touched] || g_zombie[touched] ) return FMRES_IGNORED;
			
		emit_sound(touched, CHAN_VOICE, "items/gunpickup2.wav", 1.0, ATTN_NORM, 0, PITCH_NORM);
		has_baz[touched] = true;
		
		engfunc(EngFunc_RemoveEntity, ent);
	
		return FMRES_HANDLED;
	}
	else if ( equali(entclass, "rpgrocket") )
	{
		new Float:EndOrigin[3];
		pev(ent, pev_origin, EndOrigin);
		new NonFloatEndOrigin[3];
		NonFloatEndOrigin[0] = floatround(EndOrigin[0]);
		NonFloatEndOrigin[1] = floatround(EndOrigin[1]);
		NonFloatEndOrigin[2] = floatround(EndOrigin[2]);
	
		emit_sound(ent, CHAN_WEAPON, "weapons/mortarhit.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
		emit_sound(ent, CHAN_VOICE, "weapons/mortarhit.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
	
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
		write_byte(17);
		write_coord(NonFloatEndOrigin[0]);
		write_coord(NonFloatEndOrigin[1]);
		write_coord(NonFloatEndOrigin[2] + 128);
		write_short(explosion);
		write_byte(60);
		write_byte(255);
		message_end();
	
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
		write_byte(5);
		write_coord(NonFloatEndOrigin[0]);
		write_coord(NonFloatEndOrigin[1]);
		write_coord(NonFloatEndOrigin[2] + 256);
		write_short(bazsmoke);
		write_byte(125);
		write_byte(5);
		message_end();
	
		new maxdamage = get_pcvar_num(pcvar_maxdmg);
		new damageradius = get_pcvar_num(pcvar_radius);
	
		new PlayerPos[3], distance, damage;
		for (new i = 1; i <= 32; i++) {
			if (g_isalive[i] && g_zombie[i]) {
				get_user_origin(i, PlayerPos);
	
				distance = get_distance(PlayerPos, NonFloatEndOrigin);
				if (distance <= damageradius) {	
					message_begin(MSG_ONE, g_msgScreenShake, {0,0,0}, i);
					write_short(1<<14);
					write_short(1<<14);
					write_short(1<<14);
					message_end();
		
					damage = maxdamage - floatround(floatmul(float(maxdamage), floatdiv(float(distance), float(damageradius))));
					new attacker = pev(ent, pev_owner);
		
					baz_damage(i, attacker, damage, "Bazooka");
				}
			}
		}
	
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
		write_byte(21);
		write_coord(NonFloatEndOrigin[0]);
		write_coord(NonFloatEndOrigin[1]);
		write_coord(NonFloatEndOrigin[2]);
		write_coord(NonFloatEndOrigin[0]);
		write_coord(NonFloatEndOrigin[1]);
		write_coord(NonFloatEndOrigin[2] + 320);
		write_short(white);
		write_byte(0);
		write_byte(0);
		write_byte(16);
		write_byte(128);
		write_byte(0);
		write_byte(255);
		write_byte(255);
		write_byte(192);
		write_byte(128);
		write_byte(0);
		message_end();
	
		engfunc(EngFunc_RemoveEntity, ent);
		
		return FMRES_HANDLED;
	}
	return FMRES_IGNORED;
}
//---------------------------------------------------------------------------------------
public drop_call(id)
{
	if ( has_baz[id] && get_user_weapon(id) == CSW_KNIFE )
	{
		drop_rpg_temp(id);
		return PLUGIN_HANDLED;	//attempt to block can't drop knife message
	}
	return PLUGIN_CONTINUE;
}

drop_rpg_temp(id)
{
	new Float:fAim[3] , Float:fOrigin[3];
	velocity_by_aim(id , 64 , fAim);
	pev(id , pev_origin , fOrigin);

	fOrigin[0] += fAim[0];
	fOrigin[1] += fAim[1];

	new rpg = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"));

	set_pev(rpg, pev_classname, "rpg_temp");
	engfunc(EngFunc_SetModel, rpg, gModelsManos[MODEL_WBAZOOKA])

	set_pev(rpg, pev_mins, { -16.0, -16.0, -16.0 } )
	set_pev(rpg, pev_maxs, { 16.0, 16.0, 16.0 } )

	set_pev(rpg , pev_solid , 1);
	set_pev(rpg , pev_movetype , 6);

	engfunc(EngFunc_SetOrigin, rpg, fOrigin);

	has_baz[id] = false;
}
baz_damage(id, attacker, damage, weaponDescription[])
{
	if ( pev(id, pev_takedamage) == DAMAGE_NO ) return;
	if ( damage <= 0 ) return;

	if(!is_user_alive(id))
		return
		
	new userHealth = get_user_health(id);
	if (userHealth - damage <= 0 )
	{
		dmgcount[attacker] += userHealth - damage;
		set_msg_block(g_msgDeathMsg, BLOCK_SET);
		ExecuteHamB(Ham_Killed, id, attacker, 2);
		set_msg_block(g_msgDeathMsg, BLOCK_NOT);
	
		
		message_begin(MSG_BROADCAST, g_msgDeathMsg);
		write_byte(attacker);
		write_byte(id);
		write_byte(0);
		write_string(weaponDescription);
		message_end();
		
		set_pev(attacker, pev_frags, float(get_user_frags(attacker) + 1));
			
		new kname[32], vname[32], kauthid[32], vauthid[32], kteam[10], vteam[10];
	
		get_user_name(attacker, kname, 31);
		get_user_team(attacker, kteam, 9);
		get_user_authid(attacker, kauthid, 31);
	 
		get_user_name(id, vname, 31);
		get_user_team(id, vteam, 9);
		get_user_authid(id, vauthid, 31);
			
		log_message("^"%s<%d><%s><%s>^" Asesino ^"%s<%d><%s><%s>^" Con ^"%s^"", 
		kname, get_user_userid(attacker), kauthid, kteam, 
	 	vname, get_user_userid(id), vauthid, vteam, weaponDescription);
	}
	else 
	{
		dmgcount[attacker] += damage;
		new origin[3];
		get_user_origin(id, origin);
		
		message_begin(MSG_ONE,g_msgDamage,{0,0,0},id);
		write_byte(21);
		write_byte(20);
		write_long(DMG_BLAST);
		write_coord(origin[0]);
		write_coord(origin[1]);
		write_coord(origin[2]);
		message_end();
		
		set_pev(id, pev_health, pev(id, pev_health) - float(damage));
	}
}

public give_bazooka(id,level,cid)
{
	if (!cmd_access(id,level,cid,1)){
		console_print(id,"No Tienes Acceso A Este Comando");
		return;
	}
	if (read_argc() > 2) {
		console_print(id,"Demasiados Argumentos Suministrados.");
		return;
	}
	new arg1[32];
	read_argv(1, arg1, sizeof(arg1) - 1);
	new player = cmd_target(id, arg1, 10);
	if ( !player ) {
		if ( arg1[0] == '@' ) {
			for ( new i = 1; i <= 32; i++ ) {
				if (g_isconnected[i] && !has_baz[i] && !g_zombie[i] ) {
					has_baz[i] = true;
					CanShoot[i] = true;
					zp_colored_print(id, "%s Haz Comprado Una^x04 Bazooka^x01, Para Usarla Apreta^x03 CLICK DERECHO^x01 del Knife, Tardar^x04 %2.1f^x01 En Recargar", TAG, get_pcvar_float(pcvar_delay))

				}
			}
		} else {
			zp_colored_print(id, "%s No Hay un jugador de Ese team", TAG)
			return;
		}
	} else if ( !has_baz[player] && !g_zombie[player] ) {
		has_baz[player] = true;
		CanShoot[player] = true;
		zp_colored_print(id, "%s Haz Comprado Una^x04 Bazooka^x01, Para Usarla Apreta^x03 CLICK DERECHO^x01 del Knife, Tardar^x04 %2.1f^x01 En Recargar", TAG, get_pcvar_float(pcvar_delay))
	}
}

// Save player's stats into the database
save_stats(id)
{
	// Check whether there is another record already in that slot
	if (db_name[id][0] && !equal(g_playername[id], db_name[id]))
	{
		// If DB size is exceeded, write over old records
		if (db_slot_i >= sizeof db_name)
			db_slot_i = g_maxplayers+1
		
		// Move previous record onto an additional save slot
		copy(db_name[db_slot_i], charsmax(db_name[]), db_name[id])
		db_modcount[db_slot_i] = db_modcount[id]
		db_modenabled[db_slot_i] = db_modenabled[id]
		db_slot_i++
	}
	
	// Now save the current player stats
	copy(db_name[id], charsmax(db_name[]), g_playername[id]) // name
	db_modcount[id] = g_modcount[id] // zombie class
	db_modenabled[id] = g_modenabled[id] // zombie class
}

// Load player's stats from database (if a record is found)
load_stats(id)
{
	// Look for a matching record
	static i
	for (i = 0; i < sizeof db_name; i++)
	{
		if (equal(g_playername[id], db_name[i]))
		{
			g_modcount[id] = db_modcount[i]
			g_modenabled[id] = db_modenabled[i]
			return;
		}
	}
}


public L4D(id)
{
	zp_get_user_pipe(id)
	
	// Set Health [0 = auto]
	if (get_pcvar_num(cvar_l4dhp) == 0)
	{
		if (get_pcvar_num(cvar_l4dbasehp) == 0)
			fm_set_user_health(id, 100 * fnGetAlive())
		else
			fm_set_user_health(id, get_pcvar_num(cvar_l4dbasehp) * fnGetAlive())
	}
	else
		fm_set_user_health(id, get_pcvar_num(cvar_l4dhp))
		
	// Set gravity, unless frozen
	if (!g_frozen[id]) set_pev(id, pev_gravity, get_pcvar_float(cvar_l4dgravity))
	
	// Give deagle his own weapon and fill the ammo
	fm_strip_user_weapons(id)
	fm_give_item(id, "weapon_knife")
	fm_give_item(id, "weapon_m3")
	fm_give_item(id, "weapon_mp5navy")
	fm_give_item(id, "weapon_smokegrenade")
	fm_give_item(id, "weapon_m4a1")
	fm_give_item(id, "weapon_usp")
	fm_give_item(id, "weapon_g3sg1")
	ExecuteHamB(Ham_GiveAmmo, id, MAXBPAMMO[CSW_M3], AMMOTYPE[CSW_M3], MAXBPAMMO[CSW_M3])
	ExecuteHamB(Ham_GiveAmmo, id, MAXBPAMMO[CSW_MP5NAVY], AMMOTYPE[CSW_MP5NAVY], MAXBPAMMO[CSW_MP5NAVY])
	ExecuteHamB(Ham_GiveAmmo, id, MAXBPAMMO[CSW_M4A1], AMMOTYPE[CSW_M4A1], MAXBPAMMO[CSW_M4A1])
	ExecuteHamB(Ham_GiveAmmo, id, MAXBPAMMO[CSW_USP], AMMOTYPE[CSW_USP], MAXBPAMMO[CSW_USP])
	ExecuteHamB(Ham_GiveAmmo, id, MAXBPAMMO[CSW_G3SG1], AMMOTYPE[CSW_G3SG1], MAXBPAMMO[CSW_G3SG1])
	fm_set_rendering(id, kRenderFxGlowShell, 252, 202, 3, kRenderNormal, 8)
	turn_off_flashlight(id)
		
	// Give the l4d a nice aura
	if (get_pcvar_num(cvar_l4daura))
		set_task(0.1, "human_aura", id+TASK_AURA, _, _, "b")
		
	g_has_unlimited_clip[id] = true
	g_arma_prim[id] = ARMA_ESCOPETARECORTADA
}


public menu_admin(id)
{
	iFlags = get_user_flags(id)
	
	if (!(iFlags &ADMIN || iFlags & CREADOR))
		return PLUGIN_HANDLED
			
	new menu_administradores
		
	menu_administradores = menu_create("\yMenu MODERACION del servidor", "administrador")
		
	menu_additem(menu_administradores, "\yKick Menu", "1", 0);
	menu_additem(menu_administradores, "\yVoteMap Menu", "2", 0)
	menu_additem(menu_administradores, "\yCambiar Mapa", "3", 0)
	menu_additem(menu_administradores, "\yBan Menu", "4", 0)
	menu_additem(menu_administradores, "\yReiniciar Ronda", "5", 0)
	
	menu_setprop(menu_administradores , MPROP_EXITNAME,"Salir")
	menu_display(id, menu_administradores , 0)
	
	return PLUGIN_HANDLED
}


public administrador(id, menu_administradores, item)
{

	if( item == MENU_EXIT )
	{
		menu_destroy(menu_administradores);
		return PLUGIN_HANDLED;
	}
	iFlags = get_user_flags(id)
	
	if (!(iFlags &ADMIN || iFlags & CREADOR))
		return PLUGIN_HANDLED
		
	switch(item)
	{
		case 0:client_cmd(id , "amx_kickmenu")
		case 1: client_cmd(id , "amx_votemapmenu")
		case 2:client_cmd(id , "amx_mapmenu")
		case 3:client_cmd(id , "amx_banmenu")
		case 4:
		{
			server_cmd("sv_restart ^"1^"")
			zp_colored_print(id, "%s^x03 %s^x04 ha reiniciado la ronda^x01.", TAG, g_playername[id])
		}
	}
	return PLUGIN_HANDLED;
}

stock AddPuntos(number)
{
	new str[15], strpointed[15], len
	num_to_str(number, str, 14)
	len = strlen(str)
	new c
	for (new i = 0; i < len; i++)
	{
		if (i != 0 && ((len-i) %3 == 0))
		{
			add(strpointed, 14, ".", 1)
			c++
			add(strpointed[i+c], 1, str[i], 1)
		}
		else
			add(strpointed[i+c], 1, str[i], 1)
	}
	return strpointed;
}
public ambience_sound_effects(taskid)
{
	new sound[128]
	ArrayGetString(sound_ambience, random_num(0, ArraySize(sound_ambience) - 1), sound, charsmax(sound))
	PlaySound(sound)
	set_task(17.0, "ambience_sound_effects", TASK_AMBIENCESOUNDS)
}

public ambience_sound_stop()
	client_cmd(0, "stopsound")
	
public lighting_effects()
{
	// Lighting style ["a"-"z"]
	static lights[2]
	get_pcvar_string(cvar_lighting, lights, sizeof lights - 1)
	strtolower(lights)
	
	// Lighting disabled? ["0"]
	if (lights[0] == '0')
	{
		remove_task(TASK_LIGHTING)
		return;
	}
	
	engfunc(EngFunc_LightStyle, 0, lights)
}


public Menu_Extra_Items_Humanos(id)
{	
	new len[999] , temp[22], menu_extras
	
	if(!g_isalive[id])
	{
		zp_colored_print(id, "%s Tienes Que^x04 Estar Vivo^x01 Para Comprar Extra Items" , TAG)
		return PLUGIN_HANDLED
	}
	
	if(!is_human(id))
	{
		zp_colored_print(id, "%s El menu de Extra Items^x04 No Esta Disponible^x01 Para Tu Clase", TAG)
		return PLUGIN_HANDLED
	}
	
	menu_extras = menu_create("Menu Extra Items \r[\yHumanos\r]" , "Menu_Extra_Items_Cases_Humanos")
	
	for(new i = 0 ; i < sizeof gExtraItemsHumanos ; i++)
	{
		if(g_level[id] >= gExtraItemsHumanos[i][NIVEL])
		{
			if(g_ammopacks[id] >= gExtraItemsHumanos[i][COSTO])
				formatex(len , charsmax(len) , "%s \r[\yAmmopacks:\w%d\r]", gExtraItemsHumanos[i][NOMBRE], gExtraItemsHumanos[i][COSTO])
			else
				formatex(len , charsmax(len) , "\d%s \r[\yAmmopacks:\w%d\r]", gExtraItemsHumanos[i][NOMBRE], gExtraItemsHumanos[i][COSTO])
		}
		else
			formatex(len , charsmax(len) , "\d%s \r[\yNivel:\w%d\r]", gExtraItemsHumanos[i][NOMBRE], gExtraItemsHumanos[i][NIVEL])
			
		num_to_str(i,temp, 2)
		menu_additem(menu_extras , len , temp)
	}
	
	menu_setprop(menu_extras , MPROP_BACKNAME,"Atras")
	menu_setprop(menu_extras , MPROP_NEXTNAME,"Siguiente")
	menu_setprop(menu_extras , MPROP_EXITNAME,"Salir")
	menu_display(id, menu_extras , 0)
	
	return PLUGIN_HANDLED
}

public Menu_Extra_Items_Cases_Humanos(id , menu_extras , item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu_extras)
		return PLUGIN_HANDLED
	}
	
	if(!g_isalive[id])
	{
		Menu_Extra_Items_Humanos(id)
		menu_destroy(menu_extras)
		return PLUGIN_HANDLED
	}
	
	if(!is_human(id))
	{
		zp_colored_print(id, "%s El menu de Extra Items^x04 No Esta Disponible^x01 Para Tu Clase", TAG)
		menu_destroy(menu_extras)
		return PLUGIN_HANDLED
	}
	
	
	if(g_level[id] >= gExtraItemsHumanos[item][NIVEL])
	{
		if(g_ammopacks[id] >= gExtraItemsHumanos[item][COSTO])
		{
			g_ammopacks[id] -= gExtraItemsHumanos[item][COSTO]
		}
		else
		{
			zp_colored_print(id, "%s Te Faltan^x04 %d^x01 Ammopacks Para Comprar^x04 %s^x01.", TAG, gExtraItemsHumanos[item][COSTO] - g_ammopacks[id], gExtraItemsHumanos[item][NOMBRE])
			Menu_Extra_Items_Humanos(id)
			return PLUGIN_HANDLED
		}
	}
	else
	{
		zp_colored_print(id, "%s Para Comprar^x04 %s^x01 Tienes que ser Nivel^x04 %d^x01.", TAG, gExtraItemsHumanos[item][NOMBRE], gExtraItemsHumanos[item][NIVEL])
		Menu_Extra_Items_Humanos(id)
		return PLUGIN_HANDLED
	}
	
	new Chaleco = get_user_armor(id)
	new Vida = get_user_health(id)
	switch(item)
	{
		case EXTRA_NVISION: // Night Vision
		{
			if(!g_nvision[id])
			{	
				g_nvision[id] = true
				g_nvisionenabled[id] = true
					
				// Custom nvg?
				if (get_pcvar_num(cvar_customnvg))
				{
					remove_task(id+TASK_NVISION)
					set_task(0.1, "set_user_nvision", id+TASK_NVISION, _, _, "b")
				}
				else
					set_user_gnvision(id, 1)
			}
			else
			{
				g_ammopacks[id] += gExtraItemsHumanos[item][COSTO]
				zp_colored_print(id, "%s Lo Sentimos, Ya Haz Comprado Vision Nocturna.", TAG)
				return PLUGIN_HANDLED
			}
		}
		case EXTRA_LASERMINES:
		{
			zp_get_user_laser(id)
		}
		case EXTRA_ELEGIR:
		{
			g_canbuy[id] = true
			g_canbuy_sec[id] = true
			g_canbuy_tri[id] = true
			g_canbuy_four[id] = true
			Menu_Seleccion_Armas(id)
			zp_colored_print(id, "%s Elige Nuevamente Las Armas.", TAG)
		}
		case EXTRA_INFAMMO:
		{
			if(!g_has_unlimited_clip[id])
			{
				g_has_unlimited_clip[id] = true
				zp_colored_print(id, "%s Haz Comprado Balas Infinitas Por Una Ronda.", TAG)
			}
			else
			{
				g_ammopacks[id] += gExtraItemsHumanos[item][COSTO]
				zp_colored_print(id, "%s Lo Sentimos, Ya Haz Comprado Balas Infinitas Esta Ronda.", TAG)
				return PLUGIN_HANDLED
			}
		}
		case EXTRA_LUZ:
		{
			if (user_has_weapon(id, CSW_SMOKEGRENADE))
			{
				cs_set_user_bpammo(id, CSW_SMOKEGRENADE, cs_get_user_bpammo(id, CSW_SMOKEGRENADE) + 1)
				emit_sound(id, CHAN_ITEM, "items/9mmclip1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
				return PLUGIN_HANDLED
			}
			fm_give_item(id, "weapon_smokegrenade")
		}
		case EXTRA_FUEGO:
		{
			if (user_has_weapon(id, CSW_HEGRENADE))
			{
				cs_set_user_bpammo(id, CSW_HEGRENADE, cs_get_user_bpammo(id, CSW_HEGRENADE) + 1)
				emit_sound(id, CHAN_ITEM, "items/9mmclip1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
				return PLUGIN_HANDLED
			}
			fm_give_item(id, "weapon_hegrenade")
		}
		case EXTRA_HIELO:
		{
			if (user_has_weapon(id, CSW_FLASHBANG))
			{
				cs_set_user_bpammo(id, CSW_FLASHBANG, cs_get_user_bpammo(id, CSW_FLASHBANG) + 1)
				emit_sound(id, CHAN_ITEM, "items/9mmclip1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
				return PLUGIN_HANDLED
			}
			fm_give_item(id, "weapon_flashbang")
		}
		case EXTRA_SG550:
		{
			drop_weapons(id , 1)
			fm_give_item(id, "weapon_sg550")
			ExecuteHamB(Ham_GiveAmmo, id, MAXBPAMMO[CSW_SG550], AMMOTYPE[CSW_SG550], MAXBPAMMO[CSW_SG550])
		}
		case EXTRA_G3SG1:
		{
			drop_weapons(id , 1)
			g_arma_prim[id] = ARMA_G3SG1
			fm_give_item(id, "weapon_g3sg1")
			ExecuteHamB(Ham_GiveAmmo, id, MAXBPAMMO[CSW_G3SG1], AMMOTYPE[CSW_G3SG1], MAXBPAMMO[CSW_G3SG1])
		}
		case EXTRA_M249:
		{
			drop_weapons(id , 1)
			g_arma_prim[id] = ARMA_MINIGUN
			fm_give_item(id, "weapon_m249")
			ExecuteHamB(Ham_GiveAmmo, id, MAXBPAMMO[CSW_M249], AMMOTYPE[CSW_M249], MAXBPAMMO[CSW_M249])
		}
		case EXTRA_MOLOTOV :
		{
			if (user_has_weapon(id, CSW_HEGRENADE) && has_molotov[id])
			{
				cs_set_user_bpammo(id, CSW_HEGRENADE, cs_get_user_bpammo(id, CSW_HEGRENADE) + 1)
				
				message_begin(MSG_ONE_UNRELIABLE, g_msgAmmoPickup, _, id)
				write_byte(AMMOID[CSW_HEGRENADE]) // ammo id
				write_byte(1) // ammo amount
				message_end()
				
				emit_sound(id, CHAN_ITEM, "items/9mmclip1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
				
				return PLUGIN_HANDLED
			}
			has_molotov[id]++
			fm_give_item(id, "weapon_hegrenade")
		}
		case EXTRA_BURBUJA :
		{
			if (user_has_weapon(id, CSW_SMOKEGRENADE) && has_burbuja[id])
			{
				cs_set_user_bpammo(id, CSW_SMOKEGRENADE, cs_get_user_bpammo(id, CSW_SMOKEGRENADE) + 1)
				
				message_begin(MSG_ONE_UNRELIABLE, g_msgAmmoPickup, _, id)
				write_byte(AMMOID[CSW_SMOKEGRENADE]) // ammo id
				write_byte(1) // ammo amount
				message_end()
				
				emit_sound(id, CHAN_ITEM, "items/9mmclip1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
				
				return PLUGIN_HANDLED
			}
			has_burbuja[id]++
			fm_give_item(id, "weapon_smokegrenade")
		}
		case EXTRA_INFRAGOOGLES:
		{
			if(!g_ThermalOn[id])
			{
				fw_PlayerPreThink2(id)
				g_ThermalOn[id] = true
				engfunc(EngFunc_EmitSound, id, CHAN_BODY, "items/nvg_on.wav", 1.0, ATTN_NORM, 0, PITCH_NORM) 
			}
			else
			{
				zp_colored_print(id, "%s Ya Compraste^x04 Gafas Infra-Rojas!!!", TAG)
				g_ammopacks[id] += gExtraItemsHumanos[item][COSTO]
			}
		}
		case EXTRA_HAB_RADAR_HM:
		{
			if(!g_radar_detecta_zombies[id])
			{
				g_radar_detecta_zombies[id] = true
				zp_colored_print(id, "%s Mira El Radar de tu pantalla ubicado En La Esquina Superior Izquierda^x03 (Los puntos rojos).", TAG)
			}
			else
			{
				zp_colored_print(id, "%s Ya Compraste^x04 Un Radar Detecta-Zombies^x03 (Mira El Radar De Arribita)^x01.", TAG)
				g_ammopacks[id] += gExtraItemsHumanos[item][COSTO]
			}
		}
		case EXTRA_CHALECO :
		{
			fm_set_user_armor(id, Chaleco + 100)
			zp_colored_print(id, "%s Ahora Tienes^x03 +100 Chaleco.", TAG)
		}
		case EXTRA_VIDA :
		{
			fm_set_user_health(id, Vida + 100)
			zp_colored_print(id, "%s Ahora Tienes^x03 +100 HP.", TAG)
		}
		case EXTRA_AUX:
		{
			fm_set_user_health(id, Vida + 150)
			fm_set_user_armor(id, Chaleco + 150)
			zp_colored_print(id, "%s Haz Comprado^x04 Primeros Auxilios^x03 +150 Vida^x04 +150 Chaleco.", TAG)
		}
		case EXTRA_ANTIBOMB_INF :
		{
			g_antinfeccion[id] = true
			zp_colored_print(id, "%s Eres^x04 Inmune Al Las Bombas de Infeccion^x01 Por Una Ronda.", TAG)
		}
		case EXTRA_INMUNIDAD :
		{
			if(!g_nodamage[id])
			{
				Inmunidad(id)
				zp_colored_print(id, "%s Haz Comprado^x03 Inmunidad", TAG)
			}
			else
			{
				zp_colored_print(id, "%s Ya Tienes Activada La^x04 Inmunidad!!!", TAG)
				g_ammopacks[id] += gExtraItemsHumanos[item][COSTO]
			}
		}
		case EXTRA_SACOS:
		{
			zp_get_user_sacos(id)
		}
		case EXTRA_BAZOOKA:
		{
			if(!bazuka[id])
			{
				has_baz[id] = true
				bazuka[id] = true
				CanShoot[id] = true
				zp_colored_print(id, "%s Haz Comprado Una^x04 Bazooka^x01, Para Usarla Apreta^x03 CLICK DERECHO^x01 del Knife, Tardar^x04 %2.1f^x01 En Recargar", TAG, get_pcvar_float(pcvar_delay))
				g_VecesAntidote[id]++
			}
			else
			{
				zp_colored_print(id, "%s Una Bazooka Por Ronda Bugueador CTM!!!", TAG)
				g_ammopacks[id] += 50
			}
		}
		case EXTRA_ANTIDOTEBOMB:
		{
			if(g_allowinfection)
			{
				if(!g_VecesAntidote[id])
				{
					g_antidotebomb[id]++
					fm_give_item(id, "weapon_hegrenade")
					zp_colored_print(id, "%s Tirala^x04 Cerca de Los Zombies^x01 Para Curarlos En Un Rango de 240", TAG)
					
					return PLUGIN_HANDLED
				}
				else
				{
					zp_colored_print(id, "%s Es una sola Granada Antidoto Por Ronda", TAG)
					g_ammopacks[id] += 120
				}
			}
			else
			{
				zp_colored_print(id, "%s Granadas antidotos solo en ronda infeccion.", TAG)
				g_ammopacks[id] += 120
			}
		}
		case EXTRA_PIPE: 
		{
			if(!g_VecesPipe[id]) {
				zp_get_user_pipe(id)
				zp_colored_print(id, "%s Haz comprado una Pipe Bomb.", TAG)
				g_VecesPipe[id]++
			}
			else
			{
				zp_colored_print(id, "%s Es una sola Pipe Bomb Por Ronda", TAG)
				g_ammopacks[id] += 100
			}
				
		}
		case EXTRA_MULTISALTOS:
		{
			if(g_habilidad[id] != HAB_SALTOS)
			{
				if(g_SaltosMax[id] == 2)
				{
					g_SaltosMax[id]++
					client_print(id, print_center, "Haz comprado +1 salto, ahora puedes saltar %d veces en el aire", g_SaltosMax[id])
				}
				else
				{
					zp_colored_print(id, "%s Lo sentimos, son maximo^x04 2^x01 multisaltos.", TAG)
					g_ammopacks[id] += 15						
				}
			}
			else
			{
				zp_colored_print(id, "%s No puedes comprar saltos ya que eres^x04 Humano Saltarin^x01.", TAG)
				g_ammopacks[id] += 15				
			}
		}
	}
	return PLUGIN_HANDLED
}

public Menu_Extra_Items_Zombies(id)
{	
	new len[999] , temp[22], menu_extras
	
	if(!g_isalive[id])
	{
		zp_colored_print(id, "%s Tienes Que^x04 Estar Vivo^x01 Para Comprar Extra Items" , TAG)
		return PLUGIN_HANDLED
	}
	
	if(!is_zombie(id))
	{
		zp_colored_print(id, "%s El menu de Extra Items^x04 No Esta Disponible^x01 Para Tu Clase", TAG)
		return PLUGIN_HANDLED
	}
	
	menu_extras = menu_create("Menu Extra Items \r[\yZombies\r]" , "Menu_Extra_Items_Cases_Zombies")
	
	for(new i = 0 ; i < sizeof gExtraItemsZombies ; i++)
	{
		if(g_level[id] >= gExtraItemsZombies[i][NIVEL])
		{
			if(g_ammopacks[id] >= gExtraItemsZombies[i][COSTO])
				formatex(len , charsmax(len) , "%s \r[\yAmmopacks:\w%d\r]", gExtraItemsZombies[i][NOMBRE], gExtraItemsZombies[i][COSTO])
			else
				formatex(len , charsmax(len) , "\d%s \r[\yAmmopacks:\w%d\r]", gExtraItemsZombies[i][NOMBRE], gExtraItemsZombies[i][COSTO])
		}
		else
			formatex(len , charsmax(len) , "\d%s \r[\yNivel:\w%d\r]", gExtraItemsZombies[i][NOMBRE], gExtraItemsZombies[i][NIVEL])
			
		num_to_str(i,temp, 2)
		menu_additem(menu_extras , len , temp)
	}
	
	menu_setprop(menu_extras , MPROP_BACKNAME,"Atras")
	menu_setprop(menu_extras , MPROP_NEXTNAME,"Siguiente")
	menu_setprop(menu_extras , MPROP_EXITNAME,"Salir")
	menu_display(id, menu_extras , 0)
	
	return PLUGIN_HANDLED
}

public Menu_Extra_Items_Cases_Zombies(id , menu_extras , item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu_extras)
		return PLUGIN_HANDLED
	}
	
	if(!g_isalive[id])
	{
		Menu_Extra_Items_Zombies(id)
		menu_destroy(menu_extras)
		return PLUGIN_HANDLED
	}
	
	if(!is_zombie(id))
	{
		zp_colored_print(id, "%s El menu de Extra Items^x04 No Esta Disponible^x01 Para Tu Clase", TAG)
		menu_destroy(menu_extras)
		return PLUGIN_HANDLED
	}
	if(g_level[id] >= gExtraItemsZombies[item][NIVEL])
	{
		if(g_ammopacks[id] >= gExtraItemsZombies[item][COSTO])
		{
			g_ammopacks[id] -= gExtraItemsZombies[item][COSTO]
		}
		else
		{
			zp_colored_print(id, "%s Te Faltan^x04 %d^x01 Ammopacks Para Comprar^x04 %s^x01.", TAG, gExtraItemsZombies[item][COSTO] - g_ammopacks[id], gExtraItemsZombies[item][NOMBRE])
			Menu_Extra_Items_Zombies(id)
			return PLUGIN_HANDLED
		}
	}
	else
	{
		zp_colored_print(id, "%s Para Comprar^x04 %s^x01 Tienes que ser Nivel^x04 %d^x01.", TAG, gExtraItemsZombies[item][NOMBRE], gExtraItemsZombies[item][NIVEL])
		Menu_Extra_Items_Zombies(id)
		return PLUGIN_HANDLED
	}
	// Check for hard coded items with special conditions
	if ((item == EXTRA_ANTIDOTE_ZM && (g_endround || !g_allowinfection || fnGetZombies() <= 1 || fnGetZombies() < fnGetHumans()) || (get_pcvar_num(cvar_deathmatch) && !get_pcvar_num(cvar_respawnafterlast) && fnGetHumans() == 1))
	|| (item == EXTRA_INFBOMB_ZM && (!g_allowinfection || g_endround) || (get_pcvar_num(cvar_deathmatch) && !get_pcvar_num(cvar_respawnafterlast) && fnGetHumans() == 1)))
	{
		g_ammopacks[id] += gExtraItemsZombies[item][COSTO]
		zp_colored_print(id, "%s Lo Sentimos, No Puedes Usar Este Item En Este Momento.", TAG)
		return PLUGIN_HANDLED
	}
	switch(item)
	{
		case EXTRA_ANTIDOTE_ZM: // Antidote
		{
			if(g_antidotecounter[id] >= get_pcvar_num(cvar_antidotelimit))
			{
				zp_colored_print(id, "%s Lo Sentimos, son^x04 Solo %d Antidotos^x01 por ronda.", TAG, get_pcvar_num(cvar_antidotelimit))
				g_ammopacks[id] += gExtraItemsZombies[item][COSTO]
				return PLUGIN_HANDLED
			}

			g_antidotecounter[id]++
			humanme(id, 0, 0)
		}
		case EXTRA_MADNESS_ZM: // Zombie Madness
		{
			if(g_zombiefuria[id])
			{
				zp_colored_print(id, "%s Ya Tienes Activada Tu^x01 Furia Zombie.", TAG)
				g_ammopacks[id] += 30
				return PLUGIN_HANDLED
			}
			if(g_madnesscounter[id] >= get_pcvar_num(cvar_madnesslimit))
			{
				zp_colored_print(id, "%s Lo Sentimos, es^x04 Solo %d Furia^x01 por ronda.", TAG, get_pcvar_num(cvar_madnesslimit))
				g_ammopacks[id] += gExtraItemsZombies[item][COSTO]
				return PLUGIN_HANDLED
			}
			g_madnesscounter[id]++
			g_zombiefuria[id] = true
			g_nodamage[id] = true
			set_task(0.1, "zombie_aura", id+TASK_AURA, _, _, "b")
			set_task(get_pcvar_float(cvar_madnessduration), "madness_over", id+TASK_BLOOD)
			emit_sound(id, CHAN_AUTO, "zpre4/zombie_madness.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		}
		case EXTRA_ANTIFUEGO_ZM: 
		{
			if(!g_antifuego[id])
			{
				g_antifuego[id] = true
				zp_colored_print(id, "%s Eres^x04 Inmune Al Fuego^x01 Por Una Ronda.", TAG)
			}
			else
			{
				g_ammopacks[id] += gExtraItemsZombies[item][COSTO]
				zp_colored_print(id, "%s Lo Sentimos, Ya Eres^x04 Inmune Al Fuego^x01.", TAG)
				return PLUGIN_HANDLED
			}
		}
		case EXTRA_ANTIHIELO_ZM: 
		{
			if(!g_antihielo[id])
			{
				g_antihielo[id] = true
				zp_colored_print(id, "%s Eres^x04 Inmune Al Hielo^x01 Por Una Ronda.", TAG)
			}
			else
			{
				g_ammopacks[id] += gExtraItemsZombies[item][COSTO]
				zp_colored_print(id, "%s Lo Sentimos, Ya Eres^x04 Inmune Al Hielo^x01.", TAG)
				return PLUGIN_HANDLED
			}
		}
		case EXTRA_HAB_RADAR_ZM: 
		{
			if(!g_radar_detecta_humanos[id])
			{
				g_radar_detecta_humanos[id] = true
				zp_colored_print(id, "%s Mira El Radar de tu pantalla ubicado En La Esquina Superior Izquierda^x03 (Los puntos rojos).", TAG)
			}
			else
			{
				g_ammopacks[id] += gExtraItemsZombies[item][COSTO]
				zp_colored_print(id, "%s Lo Sentimos, Ya Eres^x04 Inmune Al Hielo^x01.", TAG)
				return PLUGIN_HANDLED
			}
		}
		case EXTRA_VIDA_ZM: 
		{
			fm_set_user_health(id, get_user_health(id) + 1000)	
			zp_colored_print(id, "%s Ahora Tienes^x03 +1000 de Salud Extra.", TAG)
		}
		case EXTRA_GRAVEDAD_ZM: 
		{
			set_pev(id, pev_gravity, 0.1)
			zp_colored_print(id, "%s Ahora Podras Saltar Hasta Las Nubes, Hasta Que Mueras.", TAG)
		}
		case EXTRA_ANTILASER_ZM: 
		{
			if(!g_antilaser[id])
			{
				g_antilaser[id] = true
				zp_colored_print(id, "%s Eres^x04 Inmune Al Laser^x01 Por Una Ronda.", TAG)
			}
			else
			{
				g_ammopacks[id] += gExtraItemsZombies[item][COSTO]
				zp_colored_print(id, "%s Lo Sentimos, Ya Eres^x04 Inmune Al Laser^x01.", TAG)
				return PLUGIN_HANDLED
			}
		}
		case EXTRA_CONFBOMB_ZM:
		{
			zp_get_user_conf(id)
		}
		case EXTRA_STRIPBOMB_ZM:
		{
			zp_get_user_strip(id)
		}
		case EXTRA_INFBOMB_ZM: // Infection Bomb
		{
			if(g_infbombcounter[id] >= get_pcvar_num(cvar_infbomblimit) && !is_user_admin(id))
			{
				zp_colored_print(id, "%s Lo Sentimos, son^x04 Solo %d Bombas de Infeccion^x01 por ronda.", TAG, get_pcvar_num(cvar_infbomblimit))
				g_ammopacks[id] += gExtraItemsZombies[item][COSTO]
				return PLUGIN_HANDLED
			}
			if (user_has_weapon(id, CSW_HEGRENADE))
			{
				cs_set_user_bpammo(id, CSW_HEGRENADE, cs_get_user_bpammo(id, CSW_HEGRENADE) + 1)
				emit_sound(id, CHAN_ITEM, "items/9mmclip1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
				return PLUGIN_HANDLED
			}
			fm_give_item(id, "weapon_hegrenade")
			g_infbombcounter[id]++
		}
	}
	return PLUGIN_HANDLED
}

public native_override_user_model(id, const newmodel[]) 
{ 
	if (!g_pluginenabled) 
		return false; 
     
	if (!is_user_valid_connected(id)) 
	{ 
		log_error(AMX_ERR_NATIVE, "%s Invalid Player (%d)", TAG, id) 
		return false; 
	} 
	
	param_convert(2) 

	cs_set_player_model(id, g_playermodel[id]) 
	return true; 
} 

public Modelos(id)
{
	iFlags = get_user_flags(id)
	new iRand
	if (iFlags & CREADOR)
	{
		iRand = random_num(0, ArraySize(model_creador) - 1)
		ArrayGetString(model_creador, iRand, g_playermodel[id], charsmax(g_playermodel[]))
	}
	else if (iFlags & ADMIN)
	{
		iRand = random_num(0, ArraySize(model_moderador) - 1)
		ArrayGetString(model_moderador, iRand, g_playermodel[id], charsmax(g_playermodel[]))
	}
	else if (iFlags & VIPORO)
	{
		iRand = random_num(0, ArraySize(model_vipgold) - 1)
		ArrayGetString(model_vipgold, iRand, g_playermodel[id], charsmax(g_playermodel[]))
	}
	else if (iFlags & VIP)
	{
		iRand = random_num(0, ArraySize(model_vip) - 1)
		ArrayGetString(model_vip, iRand, g_playermodel[id], charsmax(g_playermodel[]))
	}
	else{
		iRand = random_num(0, ArraySize(model_human) - 1)
		ArrayGetString(model_human, iRand, g_playermodel[id], charsmax(g_playermodel[]))
	}
	cs_set_player_model(id, g_playermodel[id])
	
	return PLUGIN_CONTINUE;
}

public Armas(id)
{
	if(!is_human(id))
		return
	
	set_task(0.5, "Menu_Seleccion_Armas", id)
}

// Make Zombie Task
public make_zombie_task()
{
	// Call make a zombie with no specific mode
	make_a_zombie(MODE_NONE, 0)
}

// Make a Zombie Function
make_a_zombie(mode, id)
{
	// Get alive players count
	static iPlayersnum
	iPlayersnum = fnGetAlive()
	
	new sound[128]
	
	// Not enough players, come back later!
	if (iPlayersnum < 1)
	{
		set_task(2.0, "make_zombie_task", TASK_MAKEZOMBIE)
		return;
	}
	
	// Round started!
	g_newround = false
	
	// Set up some common vars
	static forward_id, iZombies, iMaxZombies, iMaxAliens, iAliens, ids, iSurvivors, iMaxSurvivors
	
	if ((mode == MODE_NONE && (!get_pcvar_num(cvar_preventconsecutive) || g_lastmode != MODE_SURVIVOR) && random_num(1, get_pcvar_num(cvar_survchance)) == get_pcvar_num(cvar_surv) && iPlayersnum >= get_pcvar_num(cvar_survminplayers)) || mode == MODE_SURVIVOR)
	{
		// Survivor Mode
		g_survround = true
		g_lastmode = MODE_SURVIVOR
		g_allowinfection = false
		set_pcvar_num(cvar_deathmatch, 0)
		set_pcvar_num(cvar_respawnzomb, 0)
		// Choose player randomly?
		if (mode == MODE_NONE)
			id = fnGetRandomAlive(random_num(1, iPlayersnum))
		
		// Remember id for calling our forward later
		forward_id = id
		
		// Turn player into a survivor
		humanme(id, 1, 0)
		
		// Turn the remaining players into zombies
		for (id = 1; id <= g_maxplayers; id++)
		{
			// Not alive
			if (!g_isalive[id])
				continue;
			
			// Survivor or already a zombie
			if (g_survivor[id] || g_zombie[id])
				continue;
			
			// Turn into a zombie
			zombieme(id, 0, 0, 1, 0)
		}
		
		ArrayGetString(sound_survivor, random_num(0, ArraySize(sound_survivor) - 1), sound, charsmax(sound))
		PlaySound(sound)
		
		// Show Survivor HUD notice
		set_dhudmessage(0, 10, 255, -1.0, 0.17, 1, 0.0, 7.0, 1.0, 1.0)
		show_dhudmessage(0, "%L", LANG_PLAYER, "NOTICE_SURVIVOR", g_playername[forward_id])
		
		// Mode fully started!
		g_modestarted = true
		
		// Round start forward
		ExecuteForward(g_fwRoundStart, g_fwDummyResult, MODE_SURVIVOR, forward_id);
	}
	else if ((mode == MODE_NONE && (!get_pcvar_num(cvar_preventconsecutive) || g_lastmode != MODE_SWARM) && random_num(1, get_pcvar_num(cvar_swarmchance)) == get_pcvar_num(cvar_swarm) && iPlayersnum >= get_pcvar_num(cvar_swarmminplayers)) || mode == MODE_SWARM)
	{
		g_swarmround = true
		g_lastmode = MODE_SWARM
		g_allowinfection = false
		
		set_pcvar_num(cvar_deathmatch, 0)
		set_pcvar_num(cvar_respawnhum, 0)
		set_pcvar_num(cvar_respawnzomb, 0)
		
		if (!fnGetAliveTs())
		{
			id = fnGetRandomAlive(random_num(1, iPlayersnum))
			remove_task(id+TASK_TEAM)
			fm_cs_set_user_team(id, FM_CS_TEAM_T)
			fm_user_team_update(id)
		}
		else if (!fnGetAliveCTs())
		{
			id = fnGetRandomAlive(random_num(1, iPlayersnum))
			remove_task(id+TASK_TEAM)
			fm_cs_set_user_team(id, FM_CS_TEAM_CT)
			fm_user_team_update(id)
		}
		
		for (id = 1; id <= g_maxplayers; id++)
		{
			if (!g_isalive[id])
				continue;
			
			if (fm_cs_get_user_team(id) != FM_CS_TEAM_T)
				continue;
			
			zombieme(id, 0, 0, 1, 0)
		}
		
		ArrayGetString(sound_swarm, random_num(0, ArraySize(sound_swarm) - 1), sound, charsmax(sound))
		PlaySound(sound)
		
		set_dhudmessage(20, 255, 20, -1.0, 0.17, 1, 0.0, 7.0, 1.0, 1.0)
		show_dhudmessage(0, "%L", LANG_PLAYER, "NOTICE_SWARM")
		
		g_modestarted = true
		
		ExecuteForward(g_fwRoundStart, g_fwDummyResult, MODE_SWARM, 0);
	}
	else if ((mode == MODE_NONE && (!get_pcvar_num(cvar_preventconsecutive) || g_lastmode != MODE_MULTI) && random_num(1, get_pcvar_num(cvar_multichance)) == get_pcvar_num(cvar_multi) && floatround(iPlayersnum*get_pcvar_float(cvar_multiratio), floatround_ceil) >= 2 && floatround(iPlayersnum*get_pcvar_float(cvar_multiratio), floatround_ceil) < iPlayersnum && iPlayersnum >= get_pcvar_num(cvar_multiminplayers)) || mode == MODE_MULTI)
	{
		// Multi Infection Mode
		g_lastmode = MODE_MULTI
		g_allowinfection = true
		set_pcvar_num(cvar_deathmatch, 2)
		set_pcvar_num(cvar_spawndelay, 5)
		
		// iMaxZombies is rounded up, in case there aren't enough players
		iMaxZombies = floatround(iPlayersnum*get_pcvar_float(cvar_multiratio), floatround_ceil)
		iZombies = 0
		
		// Randomly turn iMaxZombies players into zombies
		while (iZombies < iMaxZombies)
		{
			// Keep looping through all players
			if (++id > g_maxplayers) id = 1
			
			// Dead or already a zombie
			if (!g_isalive[id] || g_zombie[id])
				continue;
			
			// Random chance
			if (random_num(0, 1))
			{
				// Turn into a zombie
				zombieme(id, 0, 0, 1, 0)
				iZombies++
			}
		}
		
		// Turn the remaining players into humans
		for (id = 1; id <= g_maxplayers; id++)
		{
			// Only those of them who aren't zombies
			if (!g_isalive[id] || g_zombie[id])
				continue;
			
			// Switch to CT
			if (fm_cs_get_user_team(id) != FM_CS_TEAM_CT) // need to change team?
			{
				remove_task(id+TASK_TEAM)
				fm_cs_set_user_team(id, FM_CS_TEAM_CT)
				fm_user_team_update(id)
			}
		}
				
		ArrayGetString(sound_multipleinfeccion, random_num(0, ArraySize(sound_multipleinfeccion) - 1), sound, charsmax(sound))
		PlaySound(sound)
		
		// Show Multi Infection HUD notice
		set_dhudmessage(200, 50, 0, -1.0, 0.17, 1, 0.0, 7.0, 1.0, 1.0)
		show_dhudmessage(0, "%L", LANG_PLAYER, "NOTICE_MULTI")
		
		// Mode fully started!
		g_modestarted = true
		
		// Round start forward
		ExecuteForward(g_fwRoundStart, g_fwDummyResult, MODE_MULTI, 0);
	}
	else if ((mode == MODE_NONE && (!get_pcvar_num(cvar_preventconsecutive) || g_lastmode != MODE_PLAGUE) && random_num(1, get_pcvar_num(cvar_plaguechance)) == get_pcvar_num(cvar_plague) && floatround((iPlayersnum-(get_pcvar_num(cvar_plaguenemnum)+get_pcvar_num(cvar_plaguesurvnum)))*get_pcvar_float(cvar_plagueratio), floatround_ceil) >= 1
	&& iPlayersnum-(get_pcvar_num(cvar_plaguesurvnum)+get_pcvar_num(cvar_plaguenemnum)+floatround((iPlayersnum-(get_pcvar_num(cvar_plaguenemnum)+get_pcvar_num(cvar_plaguesurvnum)))*get_pcvar_float(cvar_plagueratio), floatround_ceil)) >= 1 && iPlayersnum >= get_pcvar_num(cvar_plagueminplayers)) || mode == MODE_PLAGUE)
	{
		g_plagueround = true
		g_lastmode = MODE_PLAGUE
		g_allowinfection = false
		iMaxSurvivors = get_pcvar_num(cvar_plaguesurvnum)
		iSurvivors = 0
		set_pcvar_num(cvar_deathmatch, 0)
		set_pcvar_num(cvar_respawnhum, 0)
		set_pcvar_num(cvar_respawnzomb, 0)		
		while (iSurvivors < iMaxSurvivors)
		{
			id = fnGetRandomAlive(random_num(1, iPlayersnum))
			
			if (g_survivor[id])
				continue;
			
			humanme(id, 1, 0)
			iSurvivors++
			
			fm_set_user_health(id, floatround(float(pev(id, pev_health)) * get_pcvar_float(cvar_plaguesurvhpmulti)))
		}
		
		static iNemesis, iMaxNemesis
		iMaxNemesis = get_pcvar_num(cvar_plaguenemnum)
		iNemesis = 0
		
		while (iNemesis < iMaxNemesis)
		{
			id = fnGetRandomAlive(random_num(1, iPlayersnum))
			if (g_survivor[id] || g_nemesis[id])
				continue;
			
			zombieme(id, 0, 1, 0, 0)
			iNemesis++
			fm_set_user_health(id, floatround(float(pev(id, pev_health)) * get_pcvar_float(cvar_plaguenemhpmulti)))
		}
		
		iMaxZombies = floatround((iPlayersnum-(get_pcvar_num(cvar_plaguenemnum)+get_pcvar_num(cvar_plaguesurvnum)))*get_pcvar_float(cvar_plagueratio), floatround_ceil)
		iZombies = 0
		
		while (iZombies < iMaxZombies)
		{
			if (++id > g_maxplayers) id = 1
			
			if (!g_isalive[id] || g_zombie[id] || g_survivor[id])
				continue;
			
			if (random_num(0, 1))
			{
				zombieme(id, 0, 0, 1, 0)
				iZombies++
			}
		}
		for (id = 1; id <= g_maxplayers; id++)
		{
			if (!g_isalive[id] || g_zombie[id] || g_survivor[id])
				continue;
			
			if (fm_cs_get_user_team(id) != FM_CS_TEAM_CT) // need to change team?
			{
				remove_task(id+TASK_TEAM)
				fm_cs_set_user_team(id, FM_CS_TEAM_CT)
				fm_user_team_update(id)
			}
		}
		
		ArrayGetString(sound_plague, random_num(0, ArraySize(sound_plague) - 1), sound, charsmax(sound))
		PlaySound(sound)
		
		set_dhudmessage(0, 50, 200, -1.0, 0.17, 1, 0.0, 7.0, 1.0, 1.0)
		show_dhudmessage(0, "%L", LANG_PLAYER, "NOTICE_PLAGUE")
		
		g_modestarted = true
		
		ExecuteForward(g_fwRoundStart, g_fwDummyResult, MODE_PLAGUE, 0);
	}
	else if ((mode == MODE_NONE && (!get_pcvar_num(cvar_preventconsecutive) || g_lastmode != MODE_ALIEN) && random_num(1, get_pcvar_num(cvar_alienchance)) == get_pcvar_num(cvar_alien) &&
	floatround(iPlayersnum*get_pcvar_float(cvar_alienratio), floatround_ceil) >= 2 && floatround(iPlayersnum*get_pcvar_float(cvar_alienratio), floatround_ceil) < iPlayersnum && iPlayersnum >= get_pcvar_num(cvar_alienminplayers))
	|| mode == MODE_ALIEN)
	{
		g_alienround = true
		g_lastmode = MODE_ALIEN
		g_allowinfection = false
		iMaxAliens = floatround(iPlayersnum*get_pcvar_float(cvar_alienratio), floatround_ceil)
		iAliens = 0
		
		set_pcvar_num(cvar_deathmatch, 4)
		set_pcvar_num(cvar_infammo, 2)
		set_pcvar_num(cvar_spawndelay, 1)
		set_pcvar_num(cvar_respawnalien, 1)
		set_pcvar_num(cvar_respawnzomb, 0)
		set_pcvar_num(cvar_spawnprotection, 5)
		
		while (iAliens < iMaxAliens)
		{
			if (++id > g_maxplayers) id = 1
			
			if (!g_isalive[id] || g_alien[id])
				continue;
			
			if (random_num(0, 1))
			{
				zombieme(id, 0, 3, 0, 0)
				iAliens++
			}
		}
		
		for (id = 1; id <= g_maxplayers; id++)
		{
			if (!g_isalive[id])
				continue;
				
			g_has_unlimited_clip[id] = true
			
			if(g_alien[id])
				continue
				
			if (fm_cs_get_user_team(id) != FM_CS_TEAM_CT)
			{
				remove_task(id+TASK_TEAM)
				fm_cs_set_user_team(id, FM_CS_TEAM_CT)
				fm_user_team_update(id)
			}
		}
		ArrayGetString(sound_plague, random_num(0, ArraySize(sound_plague) - 1), sound, charsmax(sound))
		PlaySound(sound)
		
		set_dhudmessage(255, 150, 20, -1.0, 0.17, 1, 0.0, 7.0, 1.0, 1.0)
		show_dhudmessage(0, "%L", LANG_PLAYER, "NOTICE_ALIEN")
		
		set_hudmessage(0, 120, 210, -1.0, 0.7, 2, 0.02, 8.0, 0.02, 0.02, -1)
		ShowSyncHudMsg(0, g_MsgSync, "Los Humanos Tienen Balas Infinitas!!")
		
		g_modestarted = true
		
		ExecuteForward(g_fwRoundStart, g_fwDummyResult, MODE_ALIEN, forward_id);
	}
	else if ((mode == MODE_NONE && (!get_pcvar_num(cvar_preventconsecutive) || g_lastmode != MODE_LNJ) && random_num(1, get_pcvar_num(cvar_lnjchance)) == get_pcvar_num(cvar_lnj) &&
	iPlayersnum >= get_pcvar_num(cvar_lnjminplayers) && floatround(iPlayersnum*get_pcvar_float(cvar_lnjratio), floatround_ceil) >= 1 && floatround(iPlayersnum*get_pcvar_float(cvar_multiratio), floatround_ceil) < iPlayersnum)
	|| mode == MODE_LNJ)
	{
		g_lnjround = true
		g_lastmode = MODE_LNJ
		g_allowinfection = false
		iMaxZombies = floatround((iPlayersnum * get_pcvar_float(cvar_lnjratio)), floatround_ceil)
		ids = 0
		
		set_pcvar_num(cvar_deathmatch, 0)
		set_pcvar_num(cvar_auratodos, 0)
		set_pcvar_num(cvar_survaura, 0)
		
		// Randomly turn iMaxZombies players into Nemesis
		while (ids < iMaxZombies)
		{
			// Keep looping through all players
			if (++id > g_maxplayers) id = 1
			
			// Dead or already a zombie or survivor
			if (!g_isalive[id] || g_zombie[id] || g_survivor[id])
				continue;
			
			// Random chance
			if (random_num(0, 1))
			{
				// Turn into a Nemesis
				zombieme(id, 0, 1, 0, 0)
				fm_set_user_health(id, floatround(float(pev(id, pev_health)) * get_pcvar_float(cvar_lnjnemhpmulti)))
				ids++
			}
		}
		
		// Turn the remaining players into survivors
		for (id = 1; id <= g_maxplayers; id++)
		{
			// Only those of them who arent zombies or survivor
			if (!g_isalive[id] || g_zombie[id] || g_survivor[id])
				continue;
			
			// Turn into a Survivor
			humanme(id, 1, 0)
			fm_set_user_health(id, floatround(float(pev(id, pev_health)) * get_pcvar_float(cvar_lnjsurvhpmulti)))
		}
		
		ArrayGetString(sound_armageddon, random_num(0, ArraySize(sound_armageddon) - 1), sound, charsmax(sound))
		PlaySound(sound)
		set_dhudmessage(181 , 62, 244, -1.0, 0.17, 1, 0.0, 7.0, 1.0, 1.0)
		show_dhudmessage(0, "%L", LANG_PLAYER, "NOTICE_LNJ")
		g_modestarted = true
		ExecuteForward(g_fwRoundStart, g_fwDummyResult, MODE_LNJ, 0);
	}
	else if ((mode == MODE_NONE && (!get_pcvar_num(cvar_preventconsecutive) || g_lastmode != MODE_TORNEO) && random_num(1, get_pcvar_num(cvar_torneochance)) == get_pcvar_num(cvar_torneo) && iPlayersnum >= get_pcvar_num(cvar_torneominplayers)) || mode == MODE_TORNEO)
	{	
		// Tournament Mode
		g_torneoround = true
		g_lastmode = MODE_TORNEO
		g_allowinfection = false
		set_pcvar_num(cvar_deathmatch, 4)
		set_pcvar_num(cvar_infammo, 2)
		set_pcvar_num(cvar_spawndelay, 1)
		set_pcvar_num(cvar_respawnhum, 1)
		set_pcvar_num(cvar_respawnzomb, 1)		
		// Make sure there are alive players on both teams (BUGFIX)
		if (!fnGetAliveTs())
		{
			// Move random player to T team
			id = fnGetRandomAlive(random_num(1, iPlayersnum))
			remove_task(id+TASK_TEAM)
			fm_cs_set_user_team(id, FM_CS_TEAM_T)
			fm_user_team_update(id)
		}
		else if (!fnGetAliveCTs())
		{
			// Move random player to CT team
			id = fnGetRandomAlive(random_num(1, iPlayersnum))
			remove_task(id+TASK_TEAM)
			fm_cs_set_user_team(id, FM_CS_TEAM_CT)
			fm_user_team_update(id)
		}
		
		
		// Turn every T into a zombie
		for (id = 1; id <= g_maxplayers; id++)
		{
			// Not alive
			if (!g_isalive[id])
				continue;
				
			g_has_unlimited_clip[id] = true
			
			// Not a Terrorist
			if (fm_cs_get_user_team(id) != FM_CS_TEAM_T)
				continue;
			
			// Turn into a zombie
			zombieme(id, 0, 0, 1, 0)
		}
		
		ArrayGetString(sound_torneo, random_num(0, ArraySize(sound_torneo) - 1), sound, charsmax(sound))
		PlaySound(sound)
		
		set_dhudmessage(102, 51, 0, -1.0, 0.17, 1, 0.0, 7.0, 1.0, 1.0)
		show_dhudmessage(0, "%L", LANG_PLAYER, "NOTICE_TORNEO")
		
		set_hudmessage(0, 120, 210, -1.0, 0.7, 2, 0.02, 8.0, 0.02, 0.02, -1)
		ShowSyncHudMsg(0, g_MsgSync, "Los Humanos Tienen Balas Infinitas!!")
		
		set_task(7.0, "TorneoHud", TASK_TORNEOHUD)
		
		g_modestarted = true
		
		ExecuteForward(g_fwRoundStart, g_fwDummyResult, MODE_TORNEO, 0);
	}
	else if ((mode == MODE_NONE && (!get_pcvar_num(cvar_preventconsecutive) || g_lastmode != MODE_SYNAPSIS) && random_num(1, get_pcvar_num(cvar_synapsischance)) == get_pcvar_num(cvar_synapsis) && iPlayersnum >= get_pcvar_num(cvar_synapsisminplayers))
	|| mode == MODE_SYNAPSIS)
	{		
		// Synapsis Mode
		g_synapsisround = true
		g_lastmode = MODE_SYNAPSIS
		g_allowinfection = false
		static iSurvivors, iMaxSurvivors
		iMaxSurvivors = 3
		iSurvivors = 0
		set_pcvar_num(cvar_deathmatch, 0)
		set_pcvar_num(cvar_respawnhum, 0)
		set_pcvar_num(cvar_respawnzomb, 0)
		
		while (iSurvivors < iMaxSurvivors)
		{
			// Choose random guy
			id = fnGetRandomAlive(random_num(1, iPlayersnum))
			
			// Already a survivor?
			if (g_survivor[id] || !g_isalive[id])
				continue;
			
			// If not, turn him into one
			humanme(id, 1, 0)
			iSurvivors++
		
			// Apply survivor health multiplier
			fm_set_user_health(id, floatround(float(get_user_health(id)) * get_pcvar_float(cvar_synapsissurvhpmulti)))
		}
		
		static iNemesis, iMaxNemesis
		iMaxNemesis = 1
		iNemesis = 0
		
		while (iNemesis < iMaxNemesis)
		{
			// Choose random guy
			id = fnGetRandomAlive(random_num(1, iPlayersnum))
			
			// Already a survivor or nemesis?
			if (!g_isalive[id] || g_survivor[id])
				continue;
			
			// If not, turn him into one
			zombieme(id, 0, 1, 0, 0)
			iNemesis++
			
			// Apply nemesis health multiplier
			fm_set_user_health(id, floatround(float(get_user_health(id)) * get_pcvar_float(cvar_synapsisnemhpmulti)))
		}
		
		static iAssassins, iMaxAssassins
		iMaxAssassins = 1
		iAssassins = 0
		
		while (iAssassins < iMaxAssassins)
		{
			// Choose random guy
			id = fnGetRandomAlive(random_num(1, iPlayersnum))
			
			// Already a survivor or nemesis?
			if (!g_isalive[id] || g_survivor[id] || g_nemesis[id])
				continue;
			
			// If not, turn him into one
			zombieme(id, 0, 2, 0, 0)
			iAssassins++
			
			// Apply nemesis health multiplier
			fm_set_user_health(id, floatround(float(get_user_health(id)) * get_pcvar_float(cvar_synapsisnemhpmulti)))
		}
		
		static iAlien, iMaxAlien
		iMaxAlien = 1
		iAlien = 0
		
		while (iAlien < iMaxAlien)
		{
			// Choose random guy
			id = fnGetRandomAlive(random_num(1, iPlayersnum))
			
			// Already a survivor or nemesis?
			if (!g_isalive[id] || g_survivor[id] || g_nemesis[id] || g_assassin[id])
				continue;
			
			// If not, turn him into one
			zombieme(id, 0, 3, 0, 0)
			iAlien++
			
			// Apply nemesis health multiplier
			fm_set_user_health(id, floatround(float(get_user_health(id)) * get_pcvar_float(cvar_synapsisnemhpmulti)))
		}
		
		// Turn the remaining players into humans
		for (id = 1; id <= g_maxplayers; id++)
		{
			// Only those of them who arent zombies or survivor
			if (!g_isalive[id] || g_zombie[id] || g_survivor[id])
				continue;
			
			// Switch to CT
			if (fm_cs_get_user_team(id) != FM_CS_TEAM_CT) // need to change team?
			{
				remove_task(id+TASK_TEAM)
				fm_cs_set_user_team(id, FM_CS_TEAM_CT)
				fm_user_team_update(id)
			}
		}
		
		ArrayGetString(sound_synapsis, random_num(0, ArraySize(sound_synapsis) - 1), sound, charsmax(sound))
		PlaySound(sound)
		set_dhudmessage(210, 48, 150, -1.0, 0.17, 1, 0.0, 7.0, 1.0, 1.0)
		show_dhudmessage(0, "%L", LANG_PLAYER, "NOTICE_SYNAPSIS")
		g_modestarted = true
		ExecuteForward(g_fwRoundStart, g_fwDummyResult, MODE_SYNAPSIS, 0);
	}
	else if ((mode == MODE_NONE && (!get_pcvar_num(cvar_preventconsecutive) || g_lastmode != MODE_L4D) && random_num(1, get_pcvar_num(cvar_l4dchance)) == get_pcvar_num(cvar_l4d) && floatround((iPlayersnum-2)*get_pcvar_float(cvar_l4dratio), floatround_ceil) >= 1 && iPlayersnum >= get_pcvar_num(cvar_l4dminplayers))
	|| mode == MODE_L4D)
	{
		// L4D Mode
		g_l4dround = true
		g_lastmode = MODE_L4D
		g_allowinfection = false
		set_pcvar_num(cvar_infammo, 2)
		set_pcvar_num(cvar_respawnl4d, 1)		
		if (mode == MODE_NONE)
			id = fnGetRandomAlive(random_num(1, iPlayersnum))
		
		// Remember id for calling our forward later
		forward_id = id
		
		// Turn the remaining players into zombies
		for (id = 1; id <= g_maxplayers; id++)
		{
			// Not alive
			if (!g_isalive[id])
				continue;
			
			// Already a zombie
			if (g_zombie[id])
				continue;
			
			// Turn into a zombie
			zombieme(id, 0, 0, 1, 0)
		}
		
		id = fnGetRandomAlive(random_num(1, iPlayersnum))
		humanme(id, 7, 0)
		id = fnGetRandomAlive(random_num(1, iPlayersnum))
		if (g_zombie[id])
		{
			humanme(id, 8, 0)
		}
		id = fnGetRandomAlive(random_num(1, iPlayersnum))
		if (g_zombie[id])
		{
			humanme(id, 9, 0)
		}
		id = fnGetRandomAlive(random_num(1, iPlayersnum))
		if (g_zombie[id])
		{
			humanme(id, 10, 0)
		}
		
		ArrayGetString(sound_l4d, random_num(0, ArraySize(sound_l4d) - 1), sound, charsmax(sound))
		PlaySound(sound)
		set_dhudmessage(150, 100, 0, -1.0, 0.17, 1, 0.0, 5.0, 1.0, 1.0) 
		show_dhudmessage(0, "%L", LANG_PLAYER, "NOTICE_L4D", g_playername[forward_id])
		g_modestarted = true
		ExecuteForward(g_fwRoundStart, g_fwDummyResult, MODE_L4D, forward_id);
	}
	else if ((mode == MODE_NONE && (!get_pcvar_num(cvar_preventconsecutive) || g_lastmode != MODE_SNIPER) && random_num(1, get_pcvar_num(cvar_sniperchance)) == get_pcvar_num(cvar_sniper) && iPlayersnum >= get_pcvar_num(cvar_sniperminplayers))
	|| mode == MODE_SNIPER)
	{
		// Sniper Mode
		g_sniperround = true
		g_lastmode = MODE_SNIPER
		g_allowinfection = false
		set_pcvar_num(cvar_deathmatch, 0)
		if (mode == MODE_NONE)
			id = fnGetRandomAlive(random_num(1, iPlayersnum))
		
		// Remember id for calling our forward later
		forward_id = id
		
		// Make sniper
		humanme(id, 5, 0)
		
		// Turn the remaining players into zombies
		for (id = 1; id <= g_maxplayers; id++)
		{
			// Not alive
			if (!g_isalive[id])
				continue;
			
			// Sniper or already a zombie
			if (g_sniper[id] || g_zombie[id])
				continue;
			
			// Turn into a zombie
			zombieme(id, 0, 0, 1, 0)
		}

		ArrayGetString(sound_sniper, random_num(0, ArraySize(sound_sniper) - 1), sound, charsmax(sound))
		PlaySound(sound)
		set_dhudmessage(0 , 250, 250, -1.0, 0.17, 1, 0.0, 7.0, 1.0, 1.0)
		show_dhudmessage(0, "%L", LANG_PLAYER, "NOTICE_SNIPER", g_playername[forward_id])
		g_modestarted = true
		ExecuteForward(g_fwRoundStart, g_fwDummyResult, MODE_SNIPER, forward_id);
	}
	else if ((mode == MODE_NONE && (!get_pcvar_num(cvar_preventconsecutive) || g_lastmode != MODE_WESKER) && random_num(1, get_pcvar_num(cvar_weskerchance)) == get_pcvar_num(cvar_wesker) && iPlayersnum >= get_pcvar_num(cvar_weskerminplayers))
	|| mode == MODE_WESKER)
	{
		// wesker Mode
		g_weskerround = true
		g_lastmode = MODE_WESKER
		g_allowinfection = false
		set_pcvar_num(cvar_deathmatch, 2)
		set_pcvar_num(cvar_spawndelay, 3)
		set_pcvar_num(cvar_respawnsurv, 1)				
		if (mode == MODE_NONE)
			id = fnGetRandomAlive(random_num(1, iPlayersnum))
		
		// Remember id for calling our forward later
		forward_id = id
		
		// Make wesker
		humanme(id, 6, 0)
		
		// Turn the remaining players into zombies
		for (id = 1; id <= g_maxplayers; id++)
		{
			// Not alive
			if (!g_isalive[id])
				continue;
			
			// wesker or already a zombie
			if (g_wesker[id] || g_zombie[id])
				continue;
			
			// Turn into a zombie
			zombieme(id, 0, 0, 1, 0)
			g_frozen[id] = true
			set_task(20.0, "remove_freeze" , id)
			fm_set_rendering(id, kRenderFxGlowShell, 100 , 100, 255, kRenderNormal, 50)
		}
		
		// Turn 6 into survivor
		for (new i = 0; i < 5; i++)
		{
			id = fnGetRandomAlive(random_num(1, iPlayersnum)) 
			if (g_zombie[id])
			{
				humanme(id, 1, 0)
				remove_freeze(id)
			}
			else
				i--
		}
		
		ArrayGetString(sound_wesker, random_num(0, ArraySize(sound_wesker) - 1), sound, charsmax(sound))
		PlaySound(sound)
		
		set_hudmessage(128 , 128, 128, -1.0, 0.17, 1, 0.0, 21.0, 1.0, 1.0, -1) 
		ShowSyncHudMsg(0, g_MsgSync, "%L", LANG_PLAYER, "NOTICE_WESKER", g_playername[forward_id], g_playername[forward_id], g_playername[forward_id])
		g_modestarted = true
		
		ExecuteForward(g_fwRoundStart, g_fwDummyResult, MODE_WESKER, forward_id);
	}
	else if ((mode == MODE_NONE && (!get_pcvar_num(cvar_preventconsecutive) || g_lastmode != MODE_DEPRE) && random_num(1, get_pcvar_num(cvar_deprechance)) == get_pcvar_num(cvar_depre) && iPlayersnum >= get_pcvar_num(cvar_depreminplayers))
	|| mode == MODE_DEPRE)
	{
		// depre Mode
		g_depreround = true
		g_lastmode = MODE_DEPRE
		g_allowinfection = false
		
		set_pcvar_num(cvar_deathmatch, 0)
		set_pcvar_num(cvar_respawnzomb, 0)
		
		if (mode == MODE_NONE)
			id = fnGetRandomAlive(random_num(1, iPlayersnum))
		
		// Remember id for calling our forward later
		forward_id = id
		
		// Make depre
		humanme(id, 2, 0)
		
		// Turn the remaining players into zombies
		for (id = 1; id <= g_maxplayers; id++)
		{
			// Not alive
			if (!g_isalive[id])
				continue;
			
			// depre or already a zombie
			if (g_depre[id] || g_zombie[id])
				continue;
			
			// Turn into a zombie
			zombieme(id, 0, 0, 1, 0)
		}

		ArrayGetString(sound_depredador, random_num(0, ArraySize(sound_depredador) - 1), sound, charsmax(sound))
		PlaySound(sound)
		
		set_dhudmessage(0 , 128, 128, -1.0, 0.17, 1, 0.0, 7.0, 1.0, 1.0)
		show_dhudmessage(0, "%L", LANG_PLAYER, "NOTICE_DEPRE", g_playername[forward_id])
		
		g_modestarted = true
		
		ExecuteForward(g_fwRoundStart, g_fwDummyResult, MODE_DEPRE, forward_id);
	}
	else if ((mode == MODE_NONE && (!get_pcvar_num(cvar_preventconsecutive) || g_lastmode != MODE_NINJA) && random_num(1, get_pcvar_num(cvar_ninjachance)) == get_pcvar_num(cvar_ninja) && iPlayersnum >= get_pcvar_num(cvar_ninjaminplayers))
	|| mode == MODE_NINJA)
	{
		// Ninja Mode
		g_ninjaround = true
		g_lastmode = MODE_NINJA
		g_allowinfection = false
		set_pcvar_num(cvar_spawndelay, 3)
		if (mode == MODE_NONE)
			id = fnGetRandomAlive(random_num(1, iPlayersnum))
		
		// Remember id for calling our forward later
		forward_id = id
		
		// Make Ninja
		humanme(id, 3, 0)
		
		// Turn the remaining players into zombies
		for (id = 1; id <= g_maxplayers; id++)
		{
			// Not alive
			if (!g_isalive[id])
				continue;
			
			// ninja or already a zombie
			if (g_ninja[id] || g_zombie[id])
				continue;
			
			// Turn into a zombie
			zombieme(id, 0, 0, 1, 0)
		}
		
		ArrayGetString(sound_ninja, random_num(0, ArraySize(sound_ninja) - 1), sound, charsmax(sound))
		PlaySound(sound)
		
		set_dhudmessage(0 , 128, 128, -1.0, 0.17, 1, 0.0, 7.0, 1.0, 1.0)
		show_dhudmessage(0, "%L", LANG_PLAYER, "NOTICE_NINJA", g_playername[forward_id])
		
		g_modestarted = true
		
		ExecuteForward(g_fwRoundStart, g_fwDummyResult, MODE_NINJA, forward_id)
	}
	else
	{
		if (mode == MODE_NONE)
			id = fnGetRandomAlive(random_num(1, iPlayersnum))
		
		forward_id = id
		
		if((mode == MODE_NONE && (!get_pcvar_num(cvar_preventconsecutive) || g_lastmode != MODE_NEMESIS) && random_num(1, get_pcvar_num(cvar_nemchance)) == get_pcvar_num(cvar_nem) && iPlayersnum >= get_pcvar_num(cvar_nemminplayers)) || mode == MODE_NEMESIS)
		{
			g_allowinfection = false
			g_nemround = true
			g_lastmode = MODE_NEMESIS
			zombieme(id, 0, 1, 0, 0)
			set_pcvar_num(cvar_deathmatch, 0)
			set_pcvar_num(cvar_respawnhum, 0)
		}
		else if((mode == MODE_NONE && (!get_pcvar_num(cvar_preventconsecutive) || g_lastmode != MODE_ASSASSIN) && random_num(1, get_pcvar_num(cvar_assassinchance)) == get_pcvar_num(cvar_assassin) && iPlayersnum >= get_pcvar_num(cvar_assassinminplayers)) || mode == MODE_ASSASSIN)
		{
			g_allowinfection = false
			g_assassinround = true
			g_lastmode = MODE_ASSASSIN
			zombieme(id, 0, 2, 0, 0)
			
			set_pcvar_num(cvar_deathmatch, 0)
			set_pcvar_num(cvar_respawnhum, 0)			
			static ent = -1
			while ((ent = engfunc(EngFunc_FindEntityByString, ent, "classname", "light")) != 0)
				dllfunc(DLLFunc_Use, ent, 0);	
				
			message_begin(MSG_ONE, g_msgScreenFade, _, id)
			write_short(UNIT_SECOND*5) // duration
			write_short(0) // hold time
			write_short(FFADE_IN) // fade type
			write_byte(255) // red
			write_byte(255) // green
			write_byte(0) // blue
			write_byte(255) // alpha
			message_end()
			
			message_begin(MSG_ONE_UNRELIABLE, g_msgScreenShake, _, id)
			write_short(UNIT_SECOND*75) // amplitude
			write_short(UNIT_SECOND*7) // duration
			write_short(UNIT_SECOND*75) // frequency
			message_end()
		}
		else
		{
			g_allowinfection = true
			g_lastmode = MODE_INFECTION
			zombieme(id, 0, 0, 0, 0)
		}
		for (id = 1; id <= g_maxplayers; id++)
		{
			if (!g_isalive[id])
				continue;
			
			if (g_zombie[id])
				continue;
			
			// Switch to CT
			if (fm_cs_get_user_team(id) != FM_CS_TEAM_CT) // need to change team?
			{
				remove_task(id+TASK_TEAM)
				fm_cs_set_user_team(id, FM_CS_TEAM_CT)
				fm_user_team_update(id)
			}
		}
		if (g_nemround)
		{
			ArrayGetString(sound_nemesis, random_num(0, ArraySize(sound_nemesis) - 1), sound, charsmax(sound))
			PlaySound(sound)
			
			set_dhudmessage(255, 20, 20, -1.0, 0.17, 1, 0.0, 7.0, 1.0, 1.0)
			show_dhudmessage(0, "%s Es La Amenaza Nemesis", g_playername[forward_id])
			
			g_modestarted = true
			
			ExecuteForward(g_fwRoundStart, g_fwDummyResult, MODE_NEMESIS, forward_id);
		}
		else if(g_assassinround)
		{
			ArrayGetString(sound_assassin, random_num(0, ArraySize(sound_assassin) - 1), sound, charsmax(sound))
			PlaySound(sound)

			
			set_dhudmessage(255, 150, 20, -1.0, 0.17, 1, 0.0, 7.0, 1.0, 1.0)
			show_dhudmessage(0, "%s Es Un Assassin", g_playername[forward_id])
			
			g_modestarted = true
			
			ExecuteForward(g_fwRoundStart, g_fwDummyResult, MODE_ASSASSIN, forward_id);
		}	
		else
		{
			// Show First Zombie HUD notice
			set_hudmessage(255, 0, 0, -1.0, 0.17, 0, 0.0, 5.0, 1.0, 1.0, -1)
			ShowSyncHudMsg(0, g_MsgSync, "%s Es El Primer Contagiado", g_playername[forward_id])
			
			g_modestarted = true
			set_pcvar_num(cvar_deathmatch, 2)
			set_pcvar_num(cvar_spawndelay, 5)
			
			ExecuteForward(g_fwRoundStart, g_fwDummyResult, MODE_INFECTION, forward_id);
		}
	}
	g_currentmod = g_lastmode
	remove_task(TASK_SHOWHUD)
	new sGamePlayName2[32]
	formatex(sGamePlayName2, charsmax(sGamePlayName2), g_sGamePlayModes[g_currentmod][sGamePlayName])
	remove_task(123456)
	set_task(1.0, "hud_gameplaymod", 123456, sGamePlayName2, charsmax(sGamePlayName2), "b")
	
	remove_task(TASK_AMBIENCESOUNDS)
	set_task(2.0, "ambience_sound_effects", TASK_AMBIENCESOUNDS)
}

public MakeFire(id)
{
	new Float:Origin[3]
	new Float:vAngle[3]
	new Float:flVelocity[3]
	
	get_user_eye_position(id, Origin)
	
	// Get View Angles
	entity_get_vector(id, EV_VEC_v_angle, vAngle)
	
	new NewEnt = create_entity("info_target")
	
	entity_set_string(NewEnt, EV_SZ_classname, "Canon")
	
	entity_set_model(NewEnt, Modelo_Disparo)
	
	entity_set_size(NewEnt, Float:{ -1.5, -1.5, -1.5 }, Float:{ 1.5, 1.5, 1.5 })
	
	entity_set_origin(NewEnt, Origin)
	
	make_vector(vAngle)
	entity_set_vector(NewEnt, EV_VEC_angles, vAngle)
	
	entity_set_int(NewEnt, EV_INT_solid, SOLID_BBOX)
	
	entity_set_float(NewEnt, EV_FL_scale, 0.3)
	entity_set_int(NewEnt, EV_INT_spawnflags, SF_SPRITE_STARTON)
	entity_set_float(NewEnt, EV_FL_framerate, 25.0)
	set_rendering(NewEnt, kRenderFxNone, 0, 0, 0, kRenderTransAdd, 255)
	
	entity_set_int(NewEnt, EV_INT_movetype, MOVETYPE_FLY)
	entity_set_edict(NewEnt, EV_ENT_owner, id)
	
	velocity_by_aim(id, get_pcvar_num(cvar_depredador_firespeed), flVelocity)
	entity_set_vector(NewEnt, EV_VEC_velocity, flVelocity)
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_BEAMFOLLOW) // TE id
	write_short(NewEnt) // entity
	write_short(gTracerDepre) // sprite
	write_byte(5) // life
	write_byte(12) // width
	write_byte(0) // r
	write_byte(120) // g
	write_byte(220) // b
	write_byte(255) // brightness
	message_end()
	
	set_task(0.2, "Efecto_Disparo", NewEnt, _, _, "b") 
	
	emit_sound(id, CHAN_ITEM, "zpre4/depredador_fire.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	emit_sound(NewEnt, CHAN_ITEM, "zpre4/depredador_fire2.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
}

public Efecto_Disparo(entity)
{
	if (!pev_valid(entity))
	{
		remove_task(entity)
		return;
	}
	
	// Get origin
	static Float:originF[3]
	pev(entity, pev_origin, originF)
	
	// Colored Aura
	engfunc(EngFunc_MessageBegin, MSG_PAS, SVC_TEMPENTITY, originF, 0)
	write_byte(TE_DLIGHT) 			// TE id
	engfunc(EngFunc_WriteCoord, originF[0])	// x
	engfunc(EngFunc_WriteCoord, originF[0])	// y
	engfunc(EngFunc_WriteCoord, originF[0])	// z
	write_byte(10) 				// radius
	write_byte(0) 			// r
	write_byte(120) 			// g
	write_byte(220) 				// b
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
	
	if(equal(class, "Canon"))
	{
		attacker = entity_get_edict(ent, EV_ENT_owner)
		Depredador(ent)
		remove_entity(ent)
		return PLUGIN_HANDLED
	}
	return PLUGIN_HANDLED
}

public Depredador(ent)
{
	if (!pev_valid(ent)) 
		return;
	
	// Get origin
	static Float:originF[3]
	pev(ent, pev_origin, originF)
	
	// Explosion
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
	write_byte(TE_EXPLOSION)
	engfunc(EngFunc_WriteCoord, originF[0])
	engfunc(EngFunc_WriteCoord, originF[1])
	engfunc(EngFunc_WriteCoord, originF[2])
	write_short(Depre_Efecto)
	write_byte(40)
	write_byte(25)
	write_byte(TE_EXPLFLAG_NOSOUND)
	message_end()
	
	emit_sound(ent, CHAN_ITEM, "zpre4/depredador_explode.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	
	static victim
	victim = -1
	
	while ((victim = engfunc(EngFunc_FindEntityInSphere, victim, originF, get_pcvar_float(cvar_depredador_fireradius))) != 0)
	{
		if (!is_user_valid_alive(victim) || !g_zombie[victim])
			continue;
			
		static origin[3]
		get_user_origin(victim, origin)
			
		if(get_user_health(victim) > get_pcvar_num(cvar_depredador_damage))
		{
			fm_set_user_health(victim, get_user_health(victim) -get_pcvar_num(cvar_depredador_damage))
			
			message_begin(MSG_PVS, SVC_TEMPENTITY, origin)
			write_byte(TE_SPARKS)
			write_coord(origin[0])
			write_coord(origin[1])
			write_coord(origin[2])
			message_end()
		}
		else
		{
			death_message(attacker, victim, "Canon", 1)
			
			Campo_Effect(originF)
			
			message_begin(MSG_PVS, SVC_TEMPENTITY, origin)
			write_byte(TE_LAVASPLASH)
			write_coord(origin[0])
			write_coord(origin[1])
			write_coord(origin[2])
			message_end()
		}
	}
	engfunc(EngFunc_RemoveEntity, ent)
}

Campo_Effect(const Float:originF3[3])
{
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF3, 0)
	write_byte(TE_BEAMCYLINDER) 
	engfunc(EngFunc_WriteCoord, originF3[0]) 
	engfunc(EngFunc_WriteCoord, originF3[1]) 
	engfunc(EngFunc_WriteCoord, originF3[2]) 
	engfunc(EngFunc_WriteCoord, originF3[0])
	engfunc(EngFunc_WriteCoord, originF3[1]) 
	engfunc(EngFunc_WriteCoord, originF3[2]+100.0)
	write_short(ElectroSpr) 
	write_byte(0)
	write_byte(0)
	write_byte(4)
	write_byte(60)
	write_byte(0)
	write_byte(0)
	write_byte(120)
	write_byte(220)
	write_byte(255)
	write_byte(0)
	message_end()
}

public death_message(Killer, Victim, const Weapon [], ScoreBoard)
{
	// Block death msg
	set_msg_block(get_user_msgid("DeathMsg"), BLOCK_SET)
	ExecuteHamB(Ham_Killed, Victim, Killer, 0)
	set_msg_block(get_user_msgid("DeathMsg"), BLOCK_NOT)
	
	// Death
	make_deathmsg(Killer, Victim, 0, Weapon)
	
	// Update score board
	if (ScoreBoard)
	{
		message_begin(MSG_BROADCAST, get_user_msgid("ScoreInfo"))
		write_byte(Killer) // id
		write_short(pev(Killer, pev_frags)) // frags
		write_short(cs_get_user_deaths(Killer)) // deaths
		write_short(0) // class?
		write_short(get_user_team(Killer)) // team
		message_end()
		
		message_begin(MSG_BROADCAST, get_user_msgid("ScoreInfo"))
		write_byte(Victim) // id
		write_short(pev(Victim, pev_frags)) // frags
		write_short(cs_get_user_deaths(Victim)) // deaths
		write_short(0) // class?
		write_short(get_user_team(Victim)) // team
		message_end()
	}
}

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


public Resetear_Armas(id)
{
	g_ninjasable[id] = false
	g_depreknife[id] = false
	g_zombiefuria[id] = false
	g_nodamage[id] = false
	has_burbuja[id] = 0
	has_molotov[id] = 0
	g_antidotebomb[id] = 0
	Inmu_Usado[id] = 0
	g_SaltosMax[id] = 0
}

// Custom game mode menu
public show_menu_game_mode(id)
{
	// Player disconnected
	if (!g_isconnected[id])
		return;
	
	// No custom game modes registered ?
	if (g_gamemodes_i == MAX_GAME_MODES)
	{
		// Print a message
		zp_colored_print(id, "%sNo hay modos extras disponibles.", TAG)
		Menu_Admin2(id)
		return;
	}
	
	
	// Create vars necessary for displaying the game modes menu
	static menuid, menu[128], game,  buffer[32]
	
	// Title
	formatex(menu, charsmax(menu), "\r[\yMenu modo extras\r]\y Te quedan\r %d\y modos", g_modcount[id])
	menuid = menu_create(menu, "menu_mode")
	
	// Game mode List
	for (game = MAX_GAME_MODES; game < g_gamemodes_i; game++)
	{
		// Retrieve the game mode's name
		ArrayGetString(g_gamemode_name, (game - MAX_GAME_MODES), buffer, charsmax(buffer))
		
		// Check for access flags and other conditions
		if ((get_user_flags(id) & ArrayGetCell(g_gamemode_flag, (game - MAX_GAME_MODES))) && allowed_custom_game())
			formatex(menu, charsmax(menu), "Empezar %s ", buffer)
		else
			formatex(menu, charsmax(menu), "\dEmpezar %s", buffer)
			
		// Add the item to the menu
		buffer[0] = game
		buffer[1] = 0
		menu_additem(menuid, menu, buffer)
	}
	
	// Back - Next - Exit
	formatex(menu, charsmax(menu), "%L", id, "MENU_BACK")
	menu_setprop(menuid, MPROP_BACKNAME, menu)
	formatex(menu, charsmax(menu), "%L", id, "MENU_NEXT")
	menu_setprop(menuid, MPROP_NEXTNAME, menu)
	formatex(menu, charsmax(menu), "%L", id, "MENU_EXIT")
	menu_setprop(menuid, MPROP_EXITNAME, menu)
	
	menu_display(id, menuid)
	
}
// Custom game mode menu
public menu_mode(id, menuid, item)
{
	// Player wants to exit the menu
	if (item == MENU_EXIT)
	{
		menu_destroy(menuid)
		Menu_Admin0(id)
		return PLUGIN_HANDLED;
	}
	
	// Create some necassary vars
	static buffer[2], dummy , gameid
	
	// Retrieve the id of the game mode which was chosen
	menu_item_getinfo(menuid, item, dummy, buffer, charsmax(buffer), _, _, dummy)
	gameid = buffer[0]
	iFlags = get_user_flags(id)
	
	if (!g_modcount[id])
	{
		zp_colored_print(id, "%s Agotaste el maximo de modos que puedes enviar.", TAG)
		return PLUGIN_HANDLED
	}
	
	if (g_modenabled[id])
	{
		zp_colored_print(id, "%s Tienes que esperar^x04 %d^x01 rondas para volver a tirar un modo.", TAG, g_modenabled[id])
		return PLUGIN_HANDLED
	}
	
	if (iFlags & VIP || iFlags & ADMIN || iFlags & CREADOR)
	{
		if (allowed_custom_game())
		{
			command_custom_game(gameid, id)
			g_modcount[id]--
			g_modenabled[id] = 3
		}
		else
			zp_colored_print(id, "%s %L", TAG, id, "CMD_NOT")
			
		show_menu_game_mode(id)
		return PLUGIN_HANDLED;
	}

	zp_colored_print(id, "%s %L", TAG, id, "CMD_NOT_ACCESS")
	menu_destroy(menuid);
	return PLUGIN_HANDLED;
}
// Admin command for a custom game mode
command_custom_game(gameid, id)
{
	// Retrieve the game mode name as it will be used
	static buffer[32]
	ArrayGetString(g_gamemode_name, (gameid - MAX_GAME_MODES), buffer, charsmax(buffer))
	
	// Show activity?
	switch (get_pcvar_num(cvar_showactivity))
	{
		case 1: client_print(0, print_chat, "ADMIN - Comenzar %s", buffer)
		case 2: client_print(0, print_chat, "ADMIN %s - Comenzar %s", g_playername[id], buffer)
	}
	
	// Log to Zombie Plague Advance log file?
	if (get_pcvar_num(cvar_logcommands))
	{
		static logdata[100], authid[32], ip[16] 
		get_user_authid(id, authid, charsmax(authid))
		get_user_ip(id, ip, charsmax(ip), 1)
		formatex(logdata, charsmax(logdata), "ADMIN %s <%s><%s> - Comenzar %s (Players: %d/%d)", g_playername[id], authid, ip, buffer, fnGetPlaying(), g_maxplayers)
		log_to_file("zombie_galaxy.log", logdata)
	}
	
	// Remove make a zombie task
	remove_task(TASK_MAKEZOMBIE)
	
	// No more a new round
	g_newround = false
	
	// Current game mode and last game mode are equal to the game mode id
	g_lastmode = gameid
	
	// Check whether or not to allow infection during this game mode
	g_allowinfection = false
	g_custom = true
	set_pcvar_num(cvar_deathmatch, 4)
	set_pcvar_num(cvar_respawnassassin, 1)
	set_pcvar_num(cvar_respawnalien, 1)
	set_pcvar_num(cvar_respawnnem, 1)
	set_pcvar_num(cvar_respawnsurv, 1)
	set_pcvar_num(cvar_respawnsniper, 1)
	set_pcvar_num(cvar_respawndepre, 1)	
	// Our custom game mode has fully started
	g_modestarted = true
	
	// Execute our round start forward with the game mode id [BUGFIX]
	ExecuteForward(g_fwRoundStart, g_fwDummyResult, gameid, 0)
	
	// Execute our game mode selected forward
	ExecuteForward(g_fwGameModeSelected, g_fwDummyResult, gameid, id)
}

// Native: zp_register_game_mode
public native_register_game_mode( const name[], flags, chance, allow, dm_mode)
{
	// ZPA disabled
	if (!g_pluginenabled)
		return -1;
	
	// Arrays not yet initialized
	if (!g_arrays_created)
		return -1;
		
	// Strings passed byref
	param_convert(1)
	
	// Add the game mode
	ArrayPushString(g_gamemode_name, name)
	ArrayPushCell(g_gamemode_flag, flags)
	ArrayPushCell(g_gamemode_chance, chance)
	ArrayPushCell(g_gamemode_allow, allow)
	ArrayPushCell(g_gamemode_dm, dm_mode)
	
	// Increase registered game modes counter
	g_gamemodes_i++
	
	// Return id under which we registered the game mode
	return (g_gamemodes_i-1);
}


// Checks if a custom game mode is allowed
allowed_custom_game()
{
	if (g_endround || !g_newround || task_exists(TASK_WELCOMEMSG) || fnGetAlive() < 2)
		return false;
	
	return true;
}/*

// Start custom game mode
start_custom_mode()
{
	// No custom game modes registered
	if(g_gamemodes_i == MAX_GAME_MODES)
	{
		// Start our infection mode 
		start_infection_mode(0, MODE_NONE)
		return;
	}
	
	// No more a new round
	g_newround = false
	
	// Loop through every custom game mode present
	// This is to ensure that every game mode is given a chance
	static game
	for (game = MAX_GAME_MODES; game < g_gamemodes_i; game++)
	{
		// Apply chance level and check if the last played mode was not the same as this one
		if ((random_num(1, ArrayGetCell(g_gamemode_chance, (game - MAX_GAME_MODES))) == 1) && (!get_pcvar_num(cvar_preventconsecutive) || g_lastmode != game))
		{
			// Execute our round start pre forward
			// This is were the game mode will decide whether to run itself or block it self
			ExecuteForward(g_fwRoundStart_pre, g_fwDummyResult, game)
			
			// The game mode didnt accept some conditions
			if (g_fwDummyResult >= ZP_PLUGIN_HANDLED)
			{
				// Give other game modes a chance
				continue;
			}
			// Game mode has accepted the conditions
			else
			{
				// Current game mode and last game mode are equal to the game mode id
				g_currentmode = game
				g_lastmode = game
				
				// Check whether or not to allow infection during this game mode
				g_allowinfection = (ArrayGetCell(g_gamemode_allow, (game - MAX_GAME_MODES)) == 1) ? true : false
				
				// Check the death match mode required by the game mode
				g_deathmatchmode = ArrayGetCell(g_gamemode_dm, (game - MAX_GAME_MODES))
				
				// Our custom game mode has fully started
				g_modestarted = true
				
				// Execute our round start forward with the game mode id
				ExecuteForward(g_fwRoundStart, g_fwDummyResult, game, 0)
				
				// Turn the remaining players into humans [BUGFIX]
				static id
				for (id = 1; id <= g_maxplayers; id++)
				{
					// Only those of them who arent zombies or survivor
					if (!g_isalive[id] || g_zombie[id] || g_survivor[id] || g_sniper[id])
						continue;
					
					// Switch to CT
					if (fm_cs_get_user_team(id) != FM_CS_TEAM_CT) // need to change team?
					{
						remove_task(id+TASK_TEAM)
						fm_cs_set_user_team(id, FM_CS_TEAM_CT)
						fm_user_team_update(id)
					}
				}
				
				// Stop the loop and prevent other game modes from being given a chance [BUGFIX]
				break;
			}
		}
		
		// The game mode was not given a chance then continue the loop
		else continue;
	}
	
	// No game mode has started then start our good old infection mode [BUGFIX]
	if (!g_modestarted)
		start_infection_mode(0, MODE_NONE)
}*/

public CheckEXP(id, EXP, POINT, const modo[])
{
	if(!EXP) return 0;
	
	if((g_exp[id] + EXP) >= Exp_Level(MAX_LEVEL))
	{
		g_exp[id] = Exp_Level(MAX_LEVEL)
		g_level[id] = MAX_LEVEL
		zp_colored_print(id, "%s ^x04No Ganas EXP^x01, Haz Llegado al^x03 Maximo Nivel^x01 (^x03%d^x01)^x01, Resetea tu cuenta para seguir avanzando^x01.", TAG, MAX_LEVEL)
		return 0;
	}

	g_exp[id] += EXP
	g_puntos[id] += POINT
	zp_colored_print(id, "%s Ganaste ^x04%d^x01 de^x03 EXP^x01 &^x04 %d^x03 Puntos^x01 Por:^x04 %s^x01.", TAG, EXP, POINT, modo)

	while(g_exp[id] >= Exp_Level(g_level[id]))
	{
		g_level[id]++
		zp_colored_print(id, "%sHaz Subido al^x04 Nivel^x01:^x03 ^"^x04%d^x03^"^x01.", TAG, g_level[id])
		client_cmd(id, "spk zpre4/subir_nivel1.wav")
		Subir_Nivel_Efecto(id)
	}
	
	return 1;
}
public ProcessExp(r, g, b)
{
	static EXP, POINT, modo[35]
	
	for(new id = 1; id <= g_maxplayers; id++)
	{
		if(!g_isalive[id])
			continue
			
		switch(g_lastmode)
		{
			case MODE_SURVIVOR:
			{
				modo = "Ganar El Modo Survivor"
				EXP = get_pcvar_num(gCvarsPlugin[EXP_GANAR_SURVIVOR][gCvarValor])
				POINT = get_pcvar_num(gCvarsPlugin[POINT_GANAR_SURVIVOR][gCvarValor])
			}
			case MODE_SNIPER:
			{
				modo = "Ganar El Modo Sniper"
				EXP = get_pcvar_num(gCvarsPlugin[EXP_GANAR_SNIPER][gCvarValor])	
				POINT = get_pcvar_num(gCvarsPlugin[POINT_GANAR_SNIPER][gCvarValor])
			}
			case MODE_DEPRE:
			{
				modo = "Ganar El Modo Depredador"
				EXP = get_pcvar_num(gCvarsPlugin[EXP_GANAR_DEPRE][gCvarValor])	
				POINT = get_pcvar_num(gCvarsPlugin[POINT_GANAR_DEPRE][gCvarValor])
			}
			case MODE_NINJA:
			{
				modo = "Ganar El Modo Ninja"
				EXP = get_pcvar_num(gCvarsPlugin[EXP_GANAR_NINJA][gCvarValor])	
				POINT = get_pcvar_num(gCvarsPlugin[POINT_GANAR_NINJA][gCvarValor])
			}
			case MODE_WESKER:
			{
				modo = "Ganar El Modo Wesker"
				EXP = get_pcvar_num(gCvarsPlugin[EXP_GANAR_WESKER][gCvarValor])	
				POINT = get_pcvar_num(gCvarsPlugin[POINT_GANAR_WESKER][gCvarValor])
			}
			case MODE_L4D:
			{
				modo = "Ganar El Modo Left 4 Dead"
				EXP = get_pcvar_num(gCvarsPlugin[EXP_GANAR_L4D][gCvarValor])	
				POINT = get_pcvar_num(gCvarsPlugin[POINT_GANAR_L4D][gCvarValor])
			}
			case MODE_MULTI:
			{
				modo = "Ganar El Modo Multiple Infeccion"
				EXP = get_pcvar_num(gCvarsPlugin[EXP_GANAR_MULTI][gCvarValor])	
				POINT = get_pcvar_num(gCvarsPlugin[POINT_GANAR_MULTI][gCvarValor])
			}
			case MODE_SWARM:
			{
				modo = "Ganar El Modo Swarm"
				EXP = get_pcvar_num(gCvarsPlugin[EXP_GANAR_SWARM][gCvarValor])	
				POINT = get_pcvar_num(gCvarsPlugin[POINT_GANAR_SWARM][gCvarValor])
			}
			case MODE_PLAGUE:
			{
				modo = "Ganar El Modo Plague"
				EXP = get_pcvar_num(gCvarsPlugin[EXP_GANAR_PLAGUE][gCvarValor])	
				POINT = get_pcvar_num(gCvarsPlugin[POINT_GANAR_PLAGUE][gCvarValor])
			}
			case MODE_ALIEN:
			{
				modo = "Ganar El Modo Alien"
				EXP = get_pcvar_num(gCvarsPlugin[EXP_GANAR_ALIEN][gCvarValor])	
				POINT = get_pcvar_num(gCvarsPlugin[POINT_GANAR_ALIEN][gCvarValor])
			}
			case MODE_LNJ:
			{
				modo = "Ganar El Modo Nemesis vs Survivors"
				EXP = get_pcvar_num(gCvarsPlugin[EXP_GANAR_LNJ][gCvarValor])	
				POINT = get_pcvar_num(gCvarsPlugin[POINT_GANAR_LNJ][gCvarValor])
			}
			case MODE_TORNEO:
			{
				modo = "Ganar El Modo Torneo"
				EXP = get_pcvar_num(gCvarsPlugin[EXP_GANAR_TORNEO][gCvarValor])	
				POINT = get_pcvar_num(gCvarsPlugin[POINT_GANAR_TORNEO][gCvarValor])
				remove_task(TASK_TORNEOHUD)
			}
			case MODE_SYNAPSIS:
			{
				modo = "Ganar El Modo Synapsis"
				EXP = get_pcvar_num(gCvarsPlugin[EXP_GANAR_SYNAPSIS][gCvarValor])
				POINT = get_pcvar_num(gCvarsPlugin[POINT_GANAR_SYNAPSIS][gCvarValor])
			}
			case MODE_NEMESIS:
			{
				modo = "Ganar El Modo Nemesis"
				EXP = get_pcvar_num(gCvarsPlugin[EXP_GANAR_NEMESIS][gCvarValor])
				POINT = get_pcvar_num(gCvarsPlugin[POINT_GANAR_NEMESIS][gCvarValor])
			}
			case MODE_ASSASSIN:
			{
				modo = "Ganar El Modo Assassin"
				EXP = get_pcvar_num(gCvarsPlugin[EXP_GANAR_ASSASSIN][gCvarValor])
				POINT = get_pcvar_num(gCvarsPlugin[POINT_GANAR_ASSASSIN][gCvarValor])
			}
			case MODE_INFECTION:
			{
				modo = "Ganar La Ronda"
				EXP = get_pcvar_num(gCvarsPlugin[EXP_GANAR_NORMAL][gCvarValor])
				POINT = get_pcvar_num(gCvarsPlugin[POINT_GANAR_NORMAL][gCvarValor])
			}
			/*case MODE_CUSTOM:
			{
				modo = "Ganar Ronda Versus"
				EXP = get_pcvar_num(gCvarsPlugin[EXP_GANAR_NORMAL][gCvarValor])
				POINT = get_pcvar_num(gCvarsPlugin[POINT_GANAR_NORMAL][gCvarValor])			
			}*/
		}
		CheckEXP(id, EXP * HF_MULTIPLIER * g_access_double[id], POINT * HF_MULTIPLIER * g_access_double[id], modo)
		
		set_dhudmessage(r, g, b, -1.0, 0.17, 0, 0.0, 3.0, 2.0, 1.0)
		show_dhudmessage(id, "Felicidades! por %s^n^nHaz Ganado %d de EXP & %d Puntos", modo, EXP * HF_MULTIPLIER * g_access_double[id], POINT * HF_MULTIPLIER * g_access_double[id])
	}
		
}

public Privilegios(id, Spawn)
{
	static PRIV[25], VIDA, CHALECO, PACKS
	iFlags = get_user_flags(id)
	
	if(iFlags & CREADOR)
	{
		PRIV = "*** Creador ***"
		VIDA = get_pcvar_num(gCvarsPlugin[VIDA_ADMINGENERAL][gCvarValor])
		CHALECO = get_pcvar_num(gCvarsPlugin[CHALECO_ADMINGENERAL][gCvarValor])
		PACKS = get_pcvar_num(gCvarsPlugin[PACKS_ADMINGENERAL][gCvarValor])
	}
	else if(iFlags & ADMIN)
	{
		PRIV = "*** Moderador ***"
		VIDA = get_pcvar_num(gCvarsPlugin[VIDA_ADMIN][gCvarValor])
		CHALECO = get_pcvar_num(gCvarsPlugin[CHALECO_ADMIN][gCvarValor])
		PACKS = get_pcvar_num(gCvarsPlugin[PACKS_ADMIN][gCvarValor])
	}
	else if(iFlags & VIPORO)
	{
		PRIV = "*** VIP ORO ***"
		VIDA = get_pcvar_num(gCvarsPlugin[VIDA_VIPORO][gCvarValor])
		CHALECO = get_pcvar_num(gCvarsPlugin[CHALECO_VIPORO][gCvarValor])
		PACKS = get_pcvar_num(gCvarsPlugin[PACKS_VIPORO][gCvarValor])
	}
	else if(iFlags & VIP)
	{
		PRIV = "*** VIP ***"
		VIDA = get_pcvar_num(gCvarsPlugin[VIDA_VIP][gCvarValor])
		CHALECO = get_pcvar_num(gCvarsPlugin[CHALECO_VIP][gCvarValor])
		PACKS = get_pcvar_num(gCvarsPlugin[PACKS_VIP][gCvarValor])
	}
	else
	{
		PRIV = "Player"
		VIDA = get_pcvar_num(gCvarsPlugin[VIDA_PLAYER][gCvarValor])
		CHALECO = get_pcvar_num(gCvarsPlugin[CHALECO_PLAYER][gCvarValor])
		PACKS = get_pcvar_num(gCvarsPlugin[PACKS_PLAYER][gCvarValor])
	}
	
	if(Spawn)
		g_ammopacks[id] += PACKS
	
	fm_set_user_health(id, VIDA + ammount_health(g_mejoras[id][0]))
	fm_set_user_armor(id, CHALECO + ammount_armor(g_mejoras[id][2]))
	set_pev(id, pev_gravity, 1.0 - ammount_gravity(g_mejoras[id][3]))
	
	zp_colored_print(id, "%s^x03 Recibes^x04 %d^x03 AmmoPacks^x03 y Tus Privilegios Tipo^x04 %s^x01.", TAG, Spawn ? PACKS : 0, PRIV)
}

public TorneoHud(taskid)
{
	static szHud[50], R, G, B
	
	if (g_zombiescore > g_humanscore)
	{
		R = 128
		G = 0
		B = 0
		szHud = "Los Zombies van ganando el Torneo"
	}
	else if (g_humanscore > g_zombiescore)
	{
		R = 0
		G = 0
		B = 150
		szHud = "Los Humanos van ganando el Torneo"
	}
	else
	{
		R = 150
		G = 150
		B = 150
		szHud = "Hay un empate en el Torneo"
	}
	set_dhudmessage(R, G, B, -1.0, 0.25, 1, 0.0, 1.0, 1.0, 1.0)
	show_dhudmessage(0, "%s^n^nZombies Matados: %d | Humanos Matados: %d", szHud, g_humanscore, g_zombiescore)
	set_task(1.9, "TorneoHud", TASK_TORNEOHUD)
}

public Init_MYSQL()
{
	new get_type[ 12 ];
	
	SQL_SetAffinity( "sqlite" );
	
	SQL_GetAffinity( get_type, sizeof get_type );

	if( !equali( get_type, "sqlite" ) )
	{
		log_to_file( "SQLITE_ERROR.txt", "Error de conexion" );
		return pause( "a" );
	}
	
	static iLen; iLen = 0;
	
	iLen += formatex(query[iLen], charsmax(query) - iLen, "CREATE TABLE IF NOT EXISTS `%s` (`Nombre` VARCHAR NOT NULL  UNIQUE, \
	`Password` VARCHAR, `Ammopacks` INTEGER DEFAULT '50', `Nivel` INTEGER DEFAULT '0', ", TABLA)
	
	iLen += formatex(query[iLen], charsmax(query) - iLen, "`Exp` INTEGER DEFAULT '0', \
	`Zclass` INTEGER DEFAULT '0', `Hclass` INTEGER DEFAULT '0', `Puntos` INTEGER DEFAULT '0', \
	`Mejora1` INTEGER DEFAULT '0', `Mejora2` INTEGER DEFAULT '0', `Mejora3` INTEGER DEFAULT '0', `Mejora4` INTEGER DEFAULT '0', `Resets` INTEGER DEFAULT '0')")
	
	g_sqltuple = SQL_MakeDbTuple("", "", "", g_db)
	
	SQL_ThreadQuery(g_sqltuple, "QueryCreateTable", query)
	
	return PLUGIN_CONTINUE
}  

public QueryCreateTable(failstate, Handle:query, error[], errcode, data[], datasize, Float:queuetime)
{
	if(failstate == TQUERY_CONNECT_FAILED)
	{
		set_fail_state("[SQL CONNECCION] No se pudo conectar a la database!")
	}
	else if(failstate == TQUERY_QUERY_FAILED)
	{
		set_fail_state("[SQL CONNECCION] Query Fallo!")
	}
	else if(errcode)
	{
		server_print("%s Error en la query: %s", TAG, error)
	}
	else
	{
		server_print("[SIST CUENTAS] SISTEMA DE CUENTAS CARGADO CORRECTAMENTE (BY: LA BANDA)!")

		data_ready = true

		for(new i = 1 ; i <= g_maxplayers ; i++)
		{
			if(!is_user_connecting(i) && !is_user_connected(i))
				continue

			CheckClient(i)
		}
		
	}	
}

public plugin_end()
{
	TrieDestroy(g_tClassWesker);
	TrieDestroy(gSayChannels)
}

public client_connect(id)
{
	static sound[64]
	ArrayGetString(sound_entrar, random_num(0, ArraySize(sound_entrar) - 1), sound, charsmax(sound))
	if (equal(sound[strlen(sound)-4], ".mp3"))
		client_cmd(id, "mp3 play sound/%s", sound)
	else
		client_cmd(id, "spk %s", sound)
		
	disable_minmodels(id)
	Resetear_Armas(id)
	reset_vars(id, 1)
	get_user_name(id, g_playername[id], charsmax(g_playername[]))
	
	if(equal(g_playername[id], "Player"))
		server_cmd("kick #%i ^"Nombre no permitido, cambiate de nombre.^"", get_user_userid(id))
	
	set_task(1.0, "ShowHUD", id+TASK_SHOWHUD, _, _, "b")	
	
	if(data_ready)
	{
		ShowMsg(id)
		CheckClient(id)
	}
}

#if AMXX_VERSION_NUM < 183
public client_disconnect(id)
#else
public client_disconnected(id)
#endif
{
	save_stats(id)
	Save(id)
	remove_tasks(id)

	if (is_user_alive(id)) check_round(id)
	
	g_canRespawn[id] = false
	g_nodamage[id] = false
	g_ThermalOn[id] = false
	changing_name[id] = false

	remove_task(id+TASK_TEAM)
	remove_task(id+TASK_FLASH)
	remove_task(id+TASK_CHARGE)
	remove_task(id+TASK_SPAWN)
	remove_task(id+TASK_BLOOD)
	remove_task(id+TASK_AURA)
	remove_task(id+TASK_BURN)
	remove_task(id+TASK_PARTICULAS)
	remove_task(id+TASK_NVISION)
	remove_task(id+TASK_SHOWHUD)
	
	fm_remove_model_ents(id)
	
	g_isconnected[id] = false
	g_isalive[id] = false
	fnCheckLastZombie()
	g_Estado[id] = -1
}

public CheckClient(id)
{
	if(!get_pcvar_num(gCvarsPlugin[CUENTAS_ON][gCvarValor]) || is_user_bot(id) || !data_ready)
		return PLUGIN_HANDLED

	remove_tasks(id)

	new name[32];
	get_user_name(id, name, charsmax(name))

	if(get_pcvar_num(gCvarsPlugin[CUENTAS_GUARDAR][gCvarValor]))
	{
		new data[1]
		data[0] = id
		
		formatex(query, charsmax(query), "SELECT `Password`, `Ammopacks`, `Nivel`, `Exp`, `Zclass`, `Hclass`, `Puntos`, \
		`Mejora1`, `Mejora2`, `Mejora3`, `Mejora4`, `Resets`  FROM `%s` WHERE `Nombre` = ^"%s^";", TABLA, name)
		
		SQL_ThreadQuery(g_sqltuple, "QuerySelectData", query, data, 1)
	}
	return PLUGIN_CONTINUE
}

public QuerySelectData(FailState, Handle:Query, error[], errorcode, data[], datasize, Float:fQueueTime)
{ 
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED)
	{
		log_amx("%s", error)
		return
	}
	else
	{
		new id = data[0];

		while(SQL_MoreResults(Query)) 
		{
			SQL_ReadResult(Query, 0, check_pass, charsmax(check_pass))
			
			static szInfo[32]
			static szInfo2[32]
			
			if(equal(check_pass, "pw"))
			{
				get_user_info(id, "_zpgalaxy", szInfo, charsmax(szInfo))
				if(equal(szInfo, "pw"))
				{
					client_cmd(id, "setinfo _zpgalaxy ^"^"")
					server_cmd("kick #%i ^"Ha sido removido tu Ban... Ahora vuelve a entrar al servidor ZKG Beta.^"", get_user_userid(id))
					return
				}
			}
			
			get_user_info(id, "_zpgalaxy", szInfo2, charsmax(szInfo2))
			
			if(equal(check_pass, "cuenta_baneada_galaxy") || equal(szInfo2, "pw"))
			{
				static ip[20]
				get_user_ip(id, ip, charsmax(ip), 1)
				if(equal(szInfo2, "")) client_cmd(id, "setinfo _zpgalaxy ^"pw^"")
				server_cmd("kick #%i ^"Tu estas en la blacklist del servidor, por hacer trampa...^"", get_user_userid(id))
				server_cmd("addip 0.0 %s", ip)
				return
			}
			g_Estado[id] = Registrado
			password[id] = check_pass
			
			if (g_Estado[id] >= Conectado)
			{
				user_silentkill(id)
				fm_cs_set_user_team(id, FM_CS_TEAM_UNASSIGNED)
				ShowMsg(id)
			}
				
			g_ammopacks[id] = SQL_ReadResult(Query, 1)	
			g_level[id] = SQL_ReadResult(Query, 2)	
			g_exp[id] = SQL_ReadResult(Query, 3)		
			g_zombieclass[id] = SQL_ReadResult(Query, 4)	
			g_zombieclassnext[id] = SQL_ReadResult(Query, 4)	
			g_habilidad[id] = SQL_ReadResult(Query, 5)	
			g_puntos[id] = SQL_ReadResult(Query, 6)	
			g_mejoras[id][0] = SQL_ReadResult(Query, 7)	
			g_mejoras[id][1] = SQL_ReadResult(Query, 8)	
			g_mejoras[id][2] = SQL_ReadResult(Query, 9)	
			g_mejoras[id][3] = SQL_ReadResult(Query, 10)	
			g_reset[id] = SQL_ReadResult(Query, 11)	
			
			SQL_NextRow(Query)
			
			iFlags = get_user_flags(id)
			
			if(iFlags & CREADOR)
			{
				g_access_double[id] = get_pcvar_num(gCvarsPlugin[MULTIPLICACION_ADMINGENERAL][gCvarValor])
				g_modcount[id] = get_pcvar_num(gCvarsPlugin[MODOS_ADMINGENERAL][gCvarValor])
				g_modenabled[id] = 0
				load_stats(id)
			}
			else if(iFlags & ADMIN)
			{
				g_access_double[id] = get_pcvar_num(gCvarsPlugin[MULTIPLICACION_ADMIN][gCvarValor])
				g_modcount[id] = get_pcvar_num(gCvarsPlugin[MODOS_ADMIN][gCvarValor])
				g_modenabled[id] = 0
				load_stats(id)
			}
			else if (iFlags & VIPORO)
			{
				g_access_double[id] = get_pcvar_num(gCvarsPlugin[MULTIPLICACION_VIPORO][gCvarValor])
				g_modcount[id] = get_pcvar_num(gCvarsPlugin[MODOS_VIPORO][gCvarValor])
				g_modenabled[id] = 0
				load_stats(id)
			}
			else if (iFlags & VIP)
			{
				g_access_double[id] = get_pcvar_num(gCvarsPlugin[MULTIPLICACION_VIP][gCvarValor])
				g_modcount[id] = get_pcvar_num(gCvarsPlugin[MODOS_VIP][gCvarValor])
				g_modenabled[id] = 0
				load_stats(id)
			}
		}
	}
}

public ShowMsg(id)
{
	if(!get_pcvar_num(gCvarsPlugin[CUENTAS_ON][gCvarValor]))
		return PLUGIN_HANDLED
		
	remove_tasks(id)

	set_task(5.0, "Messages", id+TASK_MESS)

	params[0] = id

	switch(g_Estado[id])
	{
		case Conectado, Registrado: 
		{
			CreateMainMenuTask(id+TASK_MENU)
		}
	}
	return PLUGIN_CONTINUE
}

public Messages(id)
{
	id -= TASK_MESS

	if(g_Estado[id] == Conectado)
	{
		if(get_pcvar_float(gCvarsPlugin[CUENTAS_REGTIME][gCvarValor]) != 0)
		{
			zp_colored_print(id, "%sTienes^x04 %d^x03 segundos para registrarse!", TAG, get_pcvar_num(gCvarsPlugin[CUENTAS_REGTIME][gCvarValor]))
		}
	}
	else if(g_Estado[id] == Registrado)
	{
		zp_colored_print(id, "%sTienes^x04 %d^x03 segundos para iniciar la sesion!", TAG, get_pcvar_num(gCvarsPlugin[CUENTAS_LOGTIME][gCvarValor]))
	}
}

public CreateMainMenuTask(id)
{
	id -= TASK_MENU

	if((g_Estado[id] == Conectado && get_pcvar_float(gCvarsPlugin[CUENTAS_REGTIME][gCvarValor])) || (g_Estado[id] == Registrado))
	{
		MainMenu(id)
		set_task(MENU_TASK_TIME, "CreateMainMenuTask", id+TASK_MENU)
	}
}

public MainMenu(id)
{
	if(!get_pcvar_num(gCvarsPlugin[CUENTAS_ON][gCvarValor]) || g_Estado[id] < Conectado || !data_ready)
		return PLUGIN_HANDLED

	new szData[170]
	length = 0
	
	switch(g_Estado[id])
	{
		case Conectado:
		{
			keys = MENU_KEY_1|MENU_KEY_0
			formatex(szData, charsmax(szData), "^n\r(1) \wREGISTRAR CUENTA^n^n^n^n\r(0)\w Desconectarse")
		}
		case Registrado:
		{
			keys = MENU_KEY_1|MENU_KEY_0
			formatex(szData, charsmax(szData), "^n\r(1) \wCONECTARSE^n^n^n\r(0)\w Desconectarse")
		}
		case Logueado:
		{
			keys = MENU_KEY_1|MENU_KEY_4|MENU_KEY_6|MENU_KEY_0
			formatex(szData, charsmax(szData), "^n\r(1) \wDesconectarse^n\r(4)\w Cambiar contraseña^n\r(6)\w TOP 15^n^n^n\r(0)\w Salir")
		}
	}

	length += formatex(Menu[length], charsmax(Menu) - length, "\r[\w%s\r]^n^n\wSistema de cuentas by:\r LA BANDA\r ^n^nRegistro y guardado de datos^n^n\yNombre:\w %s \r[%s]^n\w%s^n", PLUGIN_NAME, g_playername[id], ESTADOS[g_Estado[id]][Tipo], szData)
	
	show_menu(id, keys, Menu, -1, "Register System Main Menu")

	return PLUGIN_CONTINUE
}

public HandlerMainMenu(id, key)
{
	switch(key)
	{
		case 0:
		{
			switch(g_Estado[id])
			{
				case Conectado: client_cmd(id, "messagemode REGISTRA_TU_PASSWORD")
				case Registrado: client_cmd(id, "messagemode ESCRIBE_TU_PASSWORD")
				case Logueado:
				{
					params[0] = id
					params[1] = 4
					set_task(2.0, "KickPlayer", id+TASK_KICK, params, sizeof params)
					
					zp_colored_print(id, "%sTe haz logueado con exito :D!", TAG)
					g_Estado[id] = Registrado				
				}
			}
		}
		case 3:
		{
			if(g_Estado[id] < Logueado)
				return PLUGIN_HANDLED

			client_cmd(id, "messagemode NUEVA_PASSWORD")
			MainMenu(id)
		}
		case 5:
		{
			load_top15() // load top 15
			show_motd_top15(id) // show top 15
			MainMenu(id)
		}
		case 9:
		{
			if(g_Estado[id] < Logueado)
			{
				client_cmd(id, "disconnect")
				return PLUGIN_HANDLED
			}
			Menu_Principal_Juego(id)
			return PLUGIN_HANDLED
		}
	}
	return PLUGIN_HANDLED
}

public Login(id)
{
	if(!get_pcvar_num(gCvarsPlugin[CUENTAS_ON][gCvarValor]) || !data_ready)
		return PLUGIN_HANDLED

	if(g_Estado[id] == Conectado)
	{	
		zp_colored_print(id, "%s Debes registrarte antes de poder identificarse!", TAG)
		return PLUGIN_HANDLED
	}

	if(g_Estado[id] >= Logueado)
	{
		zp_colored_print(id, "%s Ya te haz logueado!", TAG);
		return PLUGIN_HANDLED
	}
	
	read_args(typedpass, charsmax(typedpass))
	remove_quotes(typedpass)

	if(equal(typedpass, ""))
		return PLUGIN_HANDLED

	hashCompatible(typedpass, hash);
	
	if(!equal(hash, password[id]))
	{	
		zp_colored_print(id, "%s Contraseña no valida, intente nuevamente.", TAG)
		
		client_cmd(id, "messagemode ESCRIBE_TU_PASSWORD")
		
		return PLUGIN_HANDLED
	}
	else
	{
		g_Estado[id] = Logueado
		remove_task(id+TASK_KICK)
		zp_colored_print(id, "%s Ahora estas conectado!", TAG)
		MainMenu(id)
		client_cmd(id, "jointeam")
	}
	return PLUGIN_CONTINUE
}

public Register(id)
{
	if(!get_pcvar_num(gCvarsPlugin[CUENTAS_ON][gCvarValor]) || !data_ready)
		return PLUGIN_HANDLED

	read_args(typedpass, charsmax(typedpass))
	remove_quotes(typedpass)

	new passlength = strlen(typedpass)

	if(equal(typedpass, ""))
		return PLUGIN_HANDLED
	
	if(g_Estado[id] == Registrado)
	{
		zp_colored_print(id, "%sLo sentimos, pero el jugador con ese nombre ya existe!", TAG)
		return PLUGIN_HANDLED
	}

	if(passlength < get_pcvar_num(gCvarsPlugin[CUENTAS_PASSCHAR][gCvarValor]))
	{
		zp_colored_print(id, "%sLo sentimos, pero la contraseña debe tener al menos %d caracteres!", TAG, get_pcvar_num(gCvarsPlugin[CUENTAS_PASSCHAR][gCvarValor]))
		client_cmd(id, "messagemode REGISTRA_TU_PASSWORD")
		return PLUGIN_HANDLED
	}

	new_pass[id] = typedpass
	remove_task(id+TASK_MENU)
	ConfirmPassword(id)
	return PLUGIN_CONTINUE
}

public ChangePasswordNew(id)
{
	if(!get_pcvar_num(gCvarsPlugin[CUENTAS_ON][gCvarValor]) || g_Estado[id] == Conectado || !data_ready)
		return PLUGIN_HANDLED

	read_args(typedpass, charsmax(typedpass))
	remove_quotes(typedpass)

	new passlenght = strlen(typedpass)

	if(equal(typedpass, ""))
		return PLUGIN_HANDLED

	if(passlenght < get_pcvar_num(gCvarsPlugin[CUENTAS_PASSCHAR][gCvarValor]))
	{
		zp_colored_print(id, "%s^x03Lo sentimos, pero la contraseña debe tener al menos^x04 %d^x03 letras!", TAG, get_pcvar_num(gCvarsPlugin[CUENTAS_PASSCHAR][gCvarValor]))
		client_cmd(id, "messagemode NUEVA_PASSWORD")
		return PLUGIN_HANDLED
	}

	new_pass[id] = typedpass
	client_cmd(id, "messagemode PASSWORD_ANTIGUA")
	return PLUGIN_CONTINUE
}

public ChangePasswordOld(id)
{
	if(!get_pcvar_num(gCvarsPlugin[CUENTAS_ON][gCvarValor]) || g_Estado[id] < Logueado || !data_ready)
		return PLUGIN_HANDLED

	read_args(typedpass, charsmax(typedpass))
	remove_quotes(typedpass)

	if(equal(typedpass, "") || equal(new_pass[id], ""))
		return PLUGIN_HANDLED

	hashCompatible(typedpass, hash);

	if(!equali(hash, password[id]))
	{
		zp_colored_print(id, "%sContraseña no valida intente nuevamente.", TAG)

		client_cmd(id, "messagemode PASSWORD_ANTIGUA")
		return PLUGIN_HANDLED
	}

	ConfirmPassword(id)
	return PLUGIN_CONTINUE
}

public ConfirmPassword(id)
{
	if(!get_pcvar_num(gCvarsPlugin[CUENTAS_ON][gCvarValor]) || g_Estado[id] < Conectado)
		return PLUGIN_HANDLED

	length = 0
		
	formatex(Menu, charsmax(Menu) - length, "\wConfirmar Contraseña:... \r %s ^n ^n \r1 \w Confirmar ^n \r2 \w Volver a escribir la contraseña ^n ^n ^n \r0 \w Cancelar", new_pass[id])
	keys = MENU_KEY_1|MENU_KEY_2|MENU_KEY_0

	show_menu(id, keys, Menu, -1, "Password Menu")
	return PLUGIN_CONTINUE
}

hashCompatible(inputString[32], outputString[34]){
	#if AMXX_VERSION_NUM < 183
	md5(inputString, outputString);
	#else
	hash_string(inputString, HashType:Hash_Md5, outputString, sizeof(outputString) - 1);
	#endif
}

public HandlerConfirmPasswordMenu(id, key)
{
	switch(key)
	{
		case 0:
		{
			hashCompatible(new_pass[id], hash);

			new name[32];
			get_user_name(id, name, charsmax(name))

			if(g_Estado[id] >= Logueado)
			{
				if(get_pcvar_num(gCvarsPlugin[CUENTAS_GUARDAR][gCvarValor]))
				{
					formatex(text, charsmax(text), "UPDATE `%s` SET Password = ^"%s^" WHERE Nombre = ^"%s^";", TABLA, hash, name)
					SQL_ThreadQuery(g_sqltuple, "QuerySetData", text)
				}

				password[id] = hash
				zp_colored_print(id, "%sHaz cambiado correctamente la contraseña! Nueva contraseña:^x04 %s", TAG, new_pass[id])

				if(get_pcvar_num(gCvarsPlugin[CUENTAS_LOGCAMBIARPASS][gCvarValor]))
				{
					log_to_file(log_file, "%s ha cambiado su contraseña", name)
				}

				MainMenu(id)
			}
			else if(g_Estado[id] == Conectado)
			{
				if(get_pcvar_num(gCvarsPlugin[CUENTAS_GUARDAR][gCvarValor]))
				{
					formatex(text, charsmax(text), "INSERT INTO `%s` (`Nombre`, `Password`) VALUES (^"%s^", ^"%s^");", TABLA, name, hash)
					SQL_ThreadQuery(g_sqltuple, "QuerySetData", text)
				}

				g_Estado[id] = Registrado
				password[id] = hash
				new_pass[id] = ""
				
				g_ammopacks[id] = 50
				g_level[id] = 0
				g_exp[id] = 0
				g_zombieclass[id] = 0
				g_habilidad[id] = 0
				g_puntos[id] = 50
				for (new i = 0; i < 4; i++) g_mejoras[id][i] = 0
				g_reset[id] = 0
				
				
				if(get_pcvar_num(gCvarsPlugin[CUENTAS_LOGREG][gCvarValor]))
				{
					log_to_file(log_file, "%s se ha registrado", name)
				}
				
				user_silentkill(id)
				fm_cs_set_user_team(id, FM_CS_TEAM_UNASSIGNED)
				ShowMsg(id)
			}
		}
		case 1:
		{
			if(g_Estado[id] >= Logueado)
			{
				client_cmd(id, "messagemode NUEVA_PASSWORD")
			}
			else if(g_Estado[id] == Conectado)
			{
				client_cmd(id, "messagemode REGISTRA_TU_PASSWORD")
				CreateMainMenuTask(id+TASK_MENU)
			}
		}
		case 9:
		{
			MainMenu(id)
			CreateMainMenuTask(id+TASK_MENU)
			return PLUGIN_HANDLED
		}
	}
	return PLUGIN_HANDLED
}

public QuerySetData(FailState, Handle:Query, error[],errcode, data[], datasize)
{
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED)
	{
		log_amx("%s", error)
		return
	}
}
/*==============================================================================
	End of Confirming Register's or Change Password's password function
================================================================================*/

/*==============================================================================
	Start of Jointeam menus and commands functions
================================================================================*/
public HookTeamCommands(id)
{
	if(!get_pcvar_num(gCvarsPlugin[CUENTAS_ON][gCvarValor]) || g_Estado[id] < Conectado)
		return PLUGIN_CONTINUE
		
	if(!data_ready)
		return PLUGIN_HANDLED
		
	switch(g_Estado[id])
	{
		case Conectado:
		{
			if(get_pcvar_float(gCvarsPlugin[CUENTAS_REGTIME][gCvarValor]))
			{
				MainMenu(id)
				return PLUGIN_HANDLED
			}
		}
		case Registrado:
		{
			MainMenu(id)
			return PLUGIN_HANDLED
		}
		case Logueado:
		{
			if(fm_cs_get_user_team(id) != FM_CS_TEAM_UNASSIGNED)
			{
				Menu_Principal_Juego(id)
				return PLUGIN_HANDLED;
			}
			return PLUGIN_CONTINUE;			
		}
	}
	return PLUGIN_CONTINUE
}

public TextMenu(msgid, dest, id)
{
	if(!get_pcvar_num(gCvarsPlugin[CUENTAS_ON][gCvarValor]) || g_Estado[id] < Conectado)
		return PLUGIN_CONTINUE

	if(!data_ready)
		return PLUGIN_HANDLED

	new menu_text[64];

	get_msg_arg_string(4, menu_text, charsmax(menu_text))

	if(equal(menu_text, JOIN_TEAM_MENU_FIRST) || equal(menu_text, JOIN_TEAM_MENU_FIRST_SPEC))
	{
		if((g_Estado[id] == Conectado && get_pcvar_float(gCvarsPlugin[CUENTAS_REGTIME][gCvarValor])) || g_Estado[id] == Registrado)
		{
			MainMenu(id)
			return PLUGIN_HANDLED
		}
		else if((get_pcvar_num(gCvarsPlugin[CUENTAS_AUTOTEAM][gCvarValor]) && fm_cs_get_user_team(id) == FM_CS_TEAM_UNASSIGNED) && !task_exists(TASK_AJC))
		{
			SetAutoJoinTask(id, msgid)
			return PLUGIN_HANDLED
		}		
	}
	else if(equal(menu_text, JOIN_TEAM_MENU_INGAME) || equal(menu_text, JOIN_TEAM_MENU_INGAME_SPEC))
	{
		if((g_Estado[id] == Conectado && get_pcvar_float(gCvarsPlugin[CUENTAS_REGTIME][gCvarValor])) || g_Estado[id] == Registrado)
		{
			MainMenu(id)
			return PLUGIN_HANDLED
		}
		else if(get_pcvar_num(gCvarsPlugin[CUENTAS_ELEGIREQUIPO][gCvarValor]))
		{
			return PLUGIN_HANDLED
		}	
	}
	return PLUGIN_CONTINUE
}

public VGUIMenu(msgid, dest, id)
{
	if(!get_pcvar_num(gCvarsPlugin[CUENTAS_ON][gCvarValor]) || get_msg_arg_int(1) != JOIN_TEAM_VGUI_MENU || g_Estado[id] < Conectado)
		return PLUGIN_CONTINUE

	if(!data_ready)
		return PLUGIN_HANDLED

	if((g_Estado[id] == Conectado && get_pcvar_float(gCvarsPlugin[CUENTAS_REGTIME][gCvarValor])) || g_Estado[id] == Registrado)
	{
		MainMenu(id)
		return PLUGIN_HANDLED
	}	
	else if(get_pcvar_num(gCvarsPlugin[CUENTAS_AUTOTEAM][gCvarValor]))
	{
		if(fm_cs_get_user_team(id) == FM_CS_TEAM_UNASSIGNED && !task_exists(TASK_AJC))
		{
			SetAutoJoinTask(id, msgid)
			return PLUGIN_HANDLED
		}
		else if(get_pcvar_num(gCvarsPlugin[CUENTAS_ELEGIREQUIPO][gCvarValor]))
		{
			return PLUGIN_HANDLED
		}
	}
	else if(get_pcvar_num(gCvarsPlugin[CUENTAS_ELEGIREQUIPO][gCvarValor]))
	{
		return PLUGIN_HANDLED
	}	
	return PLUGIN_CONTINUE
}
/*==============================================================================
	End of Jointeam menus and commands functions
================================================================================*/

/*==============================================================================
	Start of Auto Join function
================================================================================*/
public AutoJoin(parameters[])
{
	new id = parameters[0]

	if(g_Estado[id] != Logueado)
		return PLUGIN_HANDLED
	
	if(fm_cs_get_user_team(id) != FM_CS_TEAM_UNASSIGNED)
		return PLUGIN_HANDLED

	new g_team[2], g_team_num = get_pcvar_num(gCvarsPlugin[CUENTAS_AUTOTEAM][gCvarValor])

	if(g_team_num == 6)
	{
		num_to_str(g_team_num, g_team, charsmax(g_team))
		engclient_cmd(id, "jointeam", g_team)
		return PLUGIN_CONTINUE
	}

	if(g_team_num == 5)
	{
		g_team_num = random_num(1, 2)
	}
	else if(g_team_num != 1 && g_team_num != 2)
		return PLUGIN_HANDLED

	new g_class_num = get_pcvar_num(g_ajc_class[g_team_num - 1])
	num_to_str(g_team_num, g_team, charsmax(g_team))
	
	if(g_class_num == 5)
	{
		g_class_num = random_num(1, 4)
	}

	if(g_class_num == 0 || (g_class_num != 1 && g_class_num != 2 && g_class_num != 3 && g_class_num != 4))
	{
		engclient_cmd(id, "jointeam", g_team)
		return PLUGIN_CONTINUE
	}	

	new g_class[2], msg_block = get_msg_block(parameters[1])

	num_to_str(g_class_num, g_class, charsmax(g_class))

	set_msg_block(parameters[1], BLOCK_SET)
	engclient_cmd(id, "jointeam", g_team)
	engclient_cmd(id, "joinclass", g_class)
	set_msg_block(parameters[1], msg_block)

	return PLUGIN_CONTINUE
}
/*==============================================================================
	End of Auto Join functions
================================================================================*/

/*==============================================================================
	Start of Hook Client's commands
================================================================================*/
public client_command1(id)
{
	if(!data_ready || g_Estado[id] < Conectado)
		return PLUGIN_HANDLED

	if(get_pcvar_num(gCvarsPlugin[CUENTAS_BLOQUEARSAY][gCvarValor]))
	{
		switch(g_Estado[id])
		{
			case Conectado, Registrado:
			{
				console_print(id, "No se puede utilizar este comando hasta que ingreses a tu cuenta!")
				zp_colored_print(id, "%sNo se puede utilizar este comando hasta que ingreses a tu cuenta!", TAG)
				return PLUGIN_HANDLED				
			}
		}
	}
	return PLUGIN_CONTINUE
}

public PlayerPreThink(id)
{
	if(is_user_connected(id))
		return PLUGIN_HANDLED
		
	if(!get_pcvar_num(gCvarsPlugin[CUENTAS_ON][gCvarValor]) || !get_pcvar_num(gCvarsPlugin[CUENTAS_OSCURECER][gCvarValor]) || g_Estado[id] < Conectado)
		return PLUGIN_HANDLED

	if((g_Estado[id] == Conectado && get_pcvar_float(gCvarsPlugin[CUENTAS_REGTIME][gCvarValor])) || g_Estado[id] == Registrado)
	{
		message_begin(MSG_ONE_UNRELIABLE, g_screenfade, {0,0,0}, id)
		write_short(1<<12)
		write_short(1<<12)
		write_short(0x0000)
		write_byte(0)
		write_byte(0)
		write_byte(0)
		write_byte(255)
		message_end()
	}

	return PLUGIN_CONTINUE
}
/*==============================================================================
	End of Player PreThink function for the blind function
================================================================================*/

/*==============================================================================
	Start of Client Info Change function for hooking name change of clients
================================================================================*/
public ClientInfoChanged(id) 
{
	if(!get_pcvar_num(gCvarsPlugin[CUENTAS_ON][gCvarValor]) || g_Estado[id] < Conectado)
		return FMRES_IGNORED
	
	new oldname[32], newname[32];
		
	get_user_name(id, oldname, charsmax(oldname))
	get_user_info(id, "name", newname, charsmax(newname))

	if(!equal(oldname, newname))
	{
		replace_all(newname, charsmax(newname), "%", " ")

		changing_name[id] = false

		if(!g_isalive[id])
		{
			changing_name[id] = true
		}
		else
		{
			if(g_Estado[id] >= Logueado)
			{
				set_user_info(id, "name", oldname)
				zp_colored_print(id, "%sLo sentimos, pero el cambio de nombre no esta permitido para los jugadores registrados!", TAG)
				return FMRES_HANDLED
			}
	
			set_task(1.0, "CheckClient", id)
		}
	}
	return FMRES_IGNORED
}
/*==============================================================================
	End of Client Info Change function for hooking name change of clients
================================================================================*/

/*==============================================================================
	Start of Kick Player function
================================================================================*/
public KickPlayer(parameters[])
{
	new id = parameters[0]
	new reason = parameters[1]

	if(!is_user_connecting(id) && g_Estado[id] < Conectado)
		return PLUGIN_HANDLED

	new userid = get_user_userid(id)

	switch(reason)
	{
		case 1:
		{
			if(g_Estado[id] >= Registrado)
				return PLUGIN_HANDLED

			console_print(id, "^n * Usted ha sido kickeado por el Sistema de Cuentas!")
			server_cmd("kick #%i ^"Debe registrar su nombre. Por favor, vuelva a intentar a registrarlo.^"", userid)
		}
		case 2:
		{
			if(g_Estado[id] >= Logueado)
				return PLUGIN_HANDLED

			console_print(id, "^n * Usted ha sido kickeado por el Sistema de Cuentas!")
			server_cmd("kick #%i ^"Este nombre esta registrado. Por favor, vuelva a intentar e inicie sesion.^"", userid)
		}
		case 3:
		{
			
		}
		case 4:
		{
			console_print(id, "^n * Usted ha sido kickeado por el Sistema de Cuentas!")
			server_cmd("kick #%i ^"Incio de sesion correcto! Recuerda visitar: www.facebook.com/groups/zombiekillergalaxy/^"", userid)
		}
	}
	return PLUGIN_CONTINUE
}

/*==============================================================================
	Start of Plugin's stocks
================================================================================*/

stock SetAutoJoinTask(id, menu_msgid)
{
	params[0] = id
	params[1] = menu_msgid

	set_task(AJC_TASK_TIME, "AutoJoin", id+TASK_AJC, params, sizeof params)
}

stock remove_tasks(const id)
{
	remove_task(id+TASK_MESS)
	remove_task(id+TASK_KICK)
	remove_task(id+TASK_MENU)
	remove_task(id+TASK_TIMER)
	remove_task(id+TASK_AJC)
	remove_task(id)
}
/*==============================================================================
	End of Plugin's stocks
================================================================================*/

public Save(id)
{
	if(g_Estado[id] < Logueado || is_user_bot(id))
		return PLUGIN_HANDLED
		
	new name[32];
	get_user_name(id, name, charsmax(name))

	if(get_pcvar_num(gCvarsPlugin[CUENTAS_GUARDAR][gCvarValor]))
	{
		static iLen; iLen = 0;
	
		iLen += formatex(query[iLen], charsmax(query) - iLen, "UPDATE `%s` SET `Ammopacks` = ^"%d^", `Nivel` = ^"%d^", `Exp` = ^"%d^", ", TABLA, g_ammopacks[id], g_level[id], g_exp[id])
		
		iLen += formatex(query[iLen], charsmax(query) - iLen, "`Zclass` = ^"%d^", `Hclass` = ^"%d^", `Puntos` = ^"%d^", \
		`Mejora1` = ^"%d^", `Mejora2` = ^"%d^", `Mejora3` = ^"%d^", ", g_zombieclassnext[id], g_habilidad[id], g_puntos[id], g_mejoras[id][0], g_mejoras[id][1], g_mejoras[id][2])
		
		iLen += formatex(query[iLen], charsmax(query) - iLen, "`Mejora4` = ^"%d^", `Resets` = ^"%d^" WHERE Nombre = ^"%s^";", g_mejoras[id][3], g_reset[id], name)
		SQL_ThreadQuery(g_sqltuple, "QuerySetData", query)
	}
	return PLUGIN_CONTINUE;
}


stock get_time_played(iTime, &iYear, &iMonth, &iDay, &iHour, &iMinute, &iSecond) 
{  
	iTime -= 31536000 * (iYear = iTime / 31536000)  
	iTime -= 2678400 * (iMonth = iTime / 2678400)  
	iTime -= 86400 * (iDay = iTime / 86400)  
	iTime -= 3600 * (iHour = iTime / 3600)  
	iTime -= 60 * (iMinute = iTime / 60)  
	iSecond = iTime 
     
	return 1 
}

public clcmd_saytop15(id)
{
	load_top15() // load top 15
	show_motd_top15(id) // show top 15
	
	return PLUGIN_HANDLED; // don't show the command on chat
}

load_top15()
{
	new ErrorCode, Handle:SqlConnection = SQL_Connect(g_sqltuple, ErrorCode, error, charsmax(error))
	if (SqlConnection != Empty_Handle)
	{
		new Handle:query = SQL_PrepareQuery(SqlConnection, "SELECT `Nombre`, `Resets`, `Nivel`, `Exp`, `Ammopacks` FROM `%s` ORDER BY `Resets` DESC, `Nivel` DESC, `Exp` DESC LIMIT 15", TABLA)
		SQL_Execute(query)
	
		if (SQL_NumResults(query))
		{
			g_top15_clear = false
		
			static len; len = 0
			len += formatex(g_MenuChar[len], charsmax(g_MenuChar), "<body bgcolor=#000000><font color=#FFB000><pre><center><h2>%s</h2></center>^n^n", PLUGIN_NAME)
			len += formatex(g_MenuChar[len], charsmax(g_MenuChar), "<b><u>%5s  %29s %7s %10s  %10s %10s</u></b>^n", "Lugar", "Nombre", "Resets", "Nivel", "Exp", "Ammopacks")

			new iPosition, szName[32], iRango, iZMExp, iHMExp, iAp
				
			while (SQL_MoreResults(query))
			{
				++iPosition

				SQL_ReadResult(query, 0, szName, charsmax(szName))
				iRango = SQL_ReadResult(query, 1)
				iHMExp = SQL_ReadResult(query, 2)
				iZMExp = SQL_ReadResult(query, 3)
				iAp = SQL_ReadResult(query, 4)
				
				len += formatex(g_MenuChar[len], charsmax(g_MenuChar), "%5d   %29s  %3d  %7d  %10d  %10d^n", iPosition, szName, iRango, iHMExp, iZMExp, iAp)

				SQL_NextRow(query)
			}
		}
		else
			g_top15_clear = true
		
		SQL_FreeHandle(query)
	}
}

show_motd_top15(id)
{
	if (g_top15_clear)
	{
		zp_colored_print(id, "%sEl TOP 15 esta sin datos.", TAG)
		return;
	}

	// Show top 15 motd
	show_motd(id, g_MenuChar, "[Zombie Killer Galaxy Beta] Top 15");
}

public block(id)
{
	if(get_user_flags(id) & CREADOR)
		return PLUGIN_CONTINUE
		
	return PLUGIN_HANDLED
}

public MessageScoreAttrib( iMsgID, iDest, iReceiver ) 
{
	new iPlayer = get_msg_arg_int( 1 );
	
	if( is_user_connected( iPlayer) && (get_user_flags( iPlayer ) & VIP))
		set_msg_arg_int( 2, ARG_BYTE, is_user_alive( iPlayer ) ? SCOREATTRIB_VIP : SCOREATTRIB_DEAD );
}

public client_kill()
	return PLUGIN_HANDLED;
	
public fw_PlayerJump( id )
{
	if(is_human(id))
	{
		static flags; flags = get_entity_flags( id )
		static button; button = get_user_button( id )
		static oldbutton; oldbutton = get_user_oldbutton( id )
		
		if( ( button & IN_JUMP ) && !( flags & FL_ONGROUND ) && !( oldbutton & IN_JUMP ) )
		{        
			if( ++g_Saltos[ id ] <= g_SaltosMax[id])
			{
				static Float:Velocity[ 3 ]    
				entity_get_vector( id, EV_VEC_velocity, Velocity )
	
				Velocity[ 2 ] = random_float( 265.0, 285.0 )
				entity_set_vector( id, EV_VEC_velocity, Velocity )
			}
		}
	    
		if( flags & FL_ONGROUND )
			g_Saltos[ id ] = 0
	}
} 

stock precache_player_model(const modelname[]) 
{ 
	static longname[128]
	formatex(longname, charsmax(longname), "models/player/%s/%s.mdl", modelname, modelname) 
	precache_model(longname) 
         
	copy(longname[strlen(longname)-4], charsmax(longname) - (strlen(longname)-4), "T.mdl") 
	if (file_exists(longname)) precache_model(longname) 
}
/*
public Message_SayText(msgId,msgDest,msgEnt) 
{ 
	new id = get_msg_arg_int(1); 
	
	if( is_user_connected(id)) 
	{ 
		iFlags = get_user_flags(id); 
		for(new i; i<sizeof(AdminsDatas); i++) 
		{ 
			if(iFlags & AdminsDatas[i][m_iFlag] ) 
			{ 
				new szChannel[64]; 
				get_msg_arg_string(2, szChannel, charsmax(szChannel)); 

				if( equal(szChannel, "#Cstrike_Chat_All") ) 
				{ 
					formatex(szChannel, charsmax(szChannel), "^4[%s] ^3%%s1 ^1:  %%s2", AdminsDatas[i][m_szName]); 
					set_msg_arg_string(2, szChannel); 
				} 
				else if( !equal(szChannel, "#Cstrike_Name_Change") ) 
				{ 
					format(szChannel, charsmax(szChannel), "^4[%s] %s", AdminsDatas[i][m_szName], szChannel); 
					set_msg_arg_string(2, szChannel); 
				} 
				break; 
			} 
		} 
	} 
}  */

public client_PreThink(id)
{
	if(!g_isalive[id])
		return
		
	static last_think, i
		
	if (last_think > id)
	{
		for(i = 1; i <= g_maxplayers; i++)
		{
			if (g_isalive[i])
			{
				g_bSolid[i] = entity_get_int(i, EV_INT_solid) == SOLID_SLIDEBOX ? true : false
				entity_get_vector(i, EV_VEC_origin, g_fOrigin[i])
			}
			else g_bSolid[i] = false
		}
	}
	
	last_think = id
	
	if (g_bSolid[id])
	{
		for(i = 1; i <= g_maxplayers; i++)
		{
			if (g_bSolid[i] && get_distance_f(g_fOrigin[id], g_fOrigin[i]) <= SEMICLIP_DISTANCE && i != id)
			{
				if (g_zombie[id] == g_zombie[i])
				{
					entity_set_int(i, EV_INT_solid, SOLID_NOT)
					g_bHasSemiclip[i] = true
				}
			}
		}
	}
}

public client_PostThink(plr)
{
	static id
		
	for(id = 1; id <= g_maxplayers; id++)
	{
		if (g_bHasSemiclip[id])
		{
			entity_set_int(id, EV_INT_solid, SOLID_SLIDEBOX)
			g_bHasSemiclip[id] = false
		}
	}
}

public fw_AddToFullPack_Post(es_handle, e, ent, host, hostflags, player, pSet) 
{ 
	if(!player) 
		return FMRES_IGNORED; 
	
	if (g_bSolid[host] && g_bSolid[ent] && get_distance_f(g_fOrigin[host], g_fOrigin[ent]) <= SEMICLIP_DISTANCE)
	{
		if (g_zombie[host] == g_zombie[ent])
		{
			set_es(es_handle, ES_Solid, SOLID_NOT)
			set_es(es_handle, ES_RenderMode, kRenderTransAlpha)
			set_es(es_handle, ES_RenderAmt, SEMICLIP_TRANSAMOUNT)
		}
	}
	return FMRES_IGNORED; 
}


load_customization_from_files()
{
	// Build customization file path
	new path[64]
	get_configsdir(path, charsmax(path))
	format(path, charsmax(path), "%s/%s", path, ZP_CUSTOMIZATION_FILE)
	
	// File not present
	if (!file_exists(path))
	{
		new error[100]
		formatex(error, charsmax(error), "Archivo %s NO ENCONTRADO!", path)
		set_fail_state(error)
		return;
	}
	
	// Set up some vars to hold parsing info
	new linedata[1024], key[64], value[960], section
	
	// Open customization file for reading
	new file = fopen(path, "rt")
	
	while (file && !feof(file))
	{
		// Read one line at a time
		fgets(file, linedata, charsmax(linedata))
		
		// Replace newlines with a null character to prevent headaches
		replace(linedata, charsmax(linedata), "^n", "")
		
		// Blank line or comment
		if (!linedata[0] || linedata[0] == ';') continue;
		
		// New section starting
		if (linedata[0] == '[')
		{
			section++
			continue;
		}
		
		strtok(linedata, key, charsmax(key), value, charsmax(value), '=')
		
		trim(key)
		trim(value)
		
		switch (section)
		{
			case SECTION_SERVER:
			{
				if (equal(key, "NOMBRE DE PARTIDA"))
					copy(PLUGIN_NAME, charsmax(PLUGIN_NAME), value)
				else if (equal(key, "PREFIJO TAG"))
				{
					copy(TAG, charsmax(TAG), value)
					format(TAG, charsmax(TAG), "^x04%s^x01", TAG)
				}
				else if (equal(key, "MUSICAS CUANDO ENTRAN AL SERVIDOR"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(sound_entrar, key)
					}
				}
			}
			case SECTION_PLAYER_MODELS:
			{
				if (equal(key, "HUMAN MODELS"))
				{
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						trim(key)
						trim(value)

						ArrayPushString(model_human, key)
					}
				}
				else if (equal(key, "NEMESIS MODELS"))
				{
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						trim(key)
						trim(value)

						ArrayPushString(model_nemesis, key)
					}
				}
				else if (equal(key, "ASSASSIN MODELS"))
				{
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						trim(key)
						trim(value)

						ArrayPushString(model_assassin, key)
					}
				}
				else if (equal(key, "ALIEN MODELS"))
				{
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						trim(key)
						trim(value)

						ArrayPushString(model_alien, key)
					}
				}
				else if (equal(key, "SURVIVOR MODELS"))
				{
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						trim(key)
						trim(value)

						ArrayPushString(model_survivor, key)
					}
				}
				else if (equal(key, "SNIPER MODELS"))
				{
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						trim(key)
						trim(value)

						ArrayPushString(model_sniper, key)
					}
				}
				else if (equal(key, "DEPREDADOR MODELS"))
				{
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						trim(key)
						trim(value)

						ArrayPushString(model_depredador, key)
					}
				}
				else if (equal(key, "WESKER MODELS"))
				{
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						trim(key)
						trim(value)

						ArrayPushString(model_wesker, key)
					}
				}
				else if (equal(key, "NINJA MODELS"))
				{
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						trim(key)
						trim(value)

						ArrayPushString(model_ninja, key)
					}
				}
				else if (equal(key, "BILL MODELS"))
				{
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						trim(key)
						trim(value)

						ArrayPushString(model_bill, key)
					}
				}
				else if (equal(key, "FRANCIS MODELS"))
				{
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						trim(key)
						trim(value)

						ArrayPushString(model_francis, key)
					}
				}
				else if (equal(key, "LOUIS MODELS"))
				{
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						trim(key)
						trim(value)

						ArrayPushString(model_louis, key)
					}
				}
				else if (equal(key, "ZOEY MODELS"))
				{
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						trim(key)
						trim(value)

						ArrayPushString(model_zoey, key)
					}
				}
				else if (equal(key, "VIP MODELS"))
				{
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						trim(key)
						trim(value)

						ArrayPushString(model_vip, key)
					}
				}
				else if (equal(key, "VIP GOLD MODELS"))
				{
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						trim(key)
						trim(value)

						ArrayPushString(model_vipgold, key)
					}
				}
				else if (equal(key, "MODERADOR MODELS"))
				{
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						trim(key)
						trim(value)

						ArrayPushString(model_moderador, key)
					}
				}
				else if (equal(key, "ADMIN ROOT MODELS"))
				{
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						trim(key)
						trim(value)

						ArrayPushString(model_creador, key)
					}
				}
			}
			case SECTION_HANDS_MODELS:
			{	
				for(new i = 0; i < e_HandsModels; i++)
				{
					if(equal(key, gConstNombresManos[i]))
					{
						formatex(gModelsManos[i], charsmax(gModelsManos[]), value)
					}
				}
			}
			case SECTION_SOUNDS:
			{
				if (equal(key, "SONIDOS GANAN ZOMBIES"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						ArrayPushString(sound_win_zombies, key)
					}
				}
				else if (equal(key, "SONIDOS GANAN HUMANOS"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(sound_win_humans, key)
					}
				}
				else if (equal(key, "SONIDOS NADIE GANO"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(sound_win_no_one, key)
					}
				}	
				else if (equal(key, "SONIDOS DEL AMBIENTE"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(sound_ambience, key)
					}
				}
				else if (equal(key, "SONIDOS EMPIEZA RONDA WESKER"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(sound_wesker, key)
					}
				}
				else if (equal(key, "SONIDOS EMPIEZA RONDA L4D"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(sound_l4d, key)
					}
				}
				else if (equal(key, "SONIDOS EMPIEZA RONDA SYNAPSIS"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(sound_synapsis, key)
					}
				}
				else if (equal(key, "SONIDOS EMPIEZA RONDA ARMAGEDDON"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(sound_armageddon, key)
					}
				}
				else if (equal(key, "SONIDOS EMPIEZA RONDA DEPREDADOR"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(sound_depredador, key)
					}
				}
				else if (equal(key, "SONIDOS EMPIEZA RONDA NINJA"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(sound_ninja, key)
					}
				}
				else if (equal(key, "SONIDOS EMPIEZA RONDA ASSASSIN"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(sound_assassin, key)
					}
				}
				else if (equal(key, "SONIDOS EMPIEZA RONDA TORNEO"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(sound_torneo, key)
					}
				}
				else if (equal(key, "SONIDOS EMPIEZA RONDA SURVIVOR"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(sound_survivor, key)
					}
				}
				else if (equal(key, "SONIDOS EMPIEZA RONDA NEMESIS"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(sound_nemesis, key)
					}
				}
				else if (equal(key, "SONIDOS EMPIEZA RONDA SNIPER"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(sound_sniper, key)
					}
				}
				else if (equal(key, "SONIDOS EMPIEZA RONDA SWARM"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(sound_swarm, key)
					}
				}
				else if (equal(key, "SONIDOS EMPIEZA RONDA MULTIPLE INFECCION"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(sound_multipleinfeccion, key)
					}
				}
				else if (equal(key, "SONIDOS EMPIEZA RONDA PLAGUE"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(sound_plague, key)
					}
				}
				else if (equal(key, "SONIDOS EMPIEZA RONDA ALIEN"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(sound_alien, key)
					}
				}
			}
		}
	}
	if (file) fclose(file)
}

stock precache_sound2(buffer[128])
{
	static sound2[128]
	formatex(sound2, charsmax(sound2), "sound/%s", buffer)
	if (equal(buffer[strlen(buffer)-4], ".mp3"))
	{
		/*if(file_exists(sound2))*/precache_generic(sound2)/*
		else
		{
			formatex(g_LogsSize, charsmax(g_LogsSize), "Archivo de sonido mp3 NO encontrado: %s", sound2)
			log_to_file("zkg_errores.log", g_LogsSize)
		}*/
	}
	else 
	{
		
		/*if(file_exists(sound2))*/ precache_sound(buffer)
		/*else
		{
			formatex(g_LogsSize, charsmax(g_LogsSize), "Archivo de sonido NO encontrado: %s", buffer)
			log_to_file("zkg_errores.log", g_LogsSize)
		}*/
	}
}

public message_saytext(msgId,msgDest,msgEnt) 
{ 
	new id = get_msg_arg_int(1)
	
	if(!is_user_connected(id)) 
		return PLUGIN_CONTINUE
		
	new szChannel[32]
	get_msg_arg_string(2, szChannel, charsmax(szChannel))
		
	if(equal(szChannel, "#Cstrike_Name_Change")) 
		return PLUGIN_CONTINUE
		
	if(!TrieGetString(gSayChannels, szChannel, szChannel, charsmax(szChannel)))
		return PLUGIN_CONTINUE
		
	if(!is_user_admin(id))
		return PLUGIN_CONTINUE
		
	new szMessage[256], szPlayerPrivName[32], szName[32];
	read_args(szMessage, charsmax(szMessage));
	get_user_name(id, szName, charsmax(szName))
	
	if(get_user_flags(id) & CREADOR)
		formatex(szPlayerPrivName, charsmax(szPlayerPrivName), "^4[Admin Panel]^3")
	else if(get_user_flags(id) & ADMIN)
		formatex(szPlayerPrivName, charsmax(szPlayerPrivName), "^4[Admin]^3")
	else if(get_user_flags(id) & VIPORO)
		formatex(szPlayerPrivName, charsmax(szPlayerPrivName), "^4[VIP ORO]^3")
	else if(get_user_flags(id) & VIP)
		formatex(szPlayerPrivName, charsmax(szPlayerPrivName), "^4[VIP]^3")
		
	replace(szMessage, charsmax(szMessage), "^"", "");
	format(szMessage, charsmax(szMessage), "%s%s %s ^1--->^4 %s", szChannel, szPlayerPrivName, szName, szMessage);
	
	set_msg_arg_string(2, szMessage)
	return PLUGIN_CONTINUE
}

public native_get_user_l4d(id, clase)
{
	return g_l4d[id][clase]
}


public hud_gameplaymod(sGamePlayName2[])
{
	// Happy Hour indicator
	set_hudmessage(g_sGamePlayModes[g_currentmod][vGamePlayColor][0], g_sGamePlayModes[g_currentmod][vGamePlayColor][1], g_sGamePlayModes[g_currentmod][vGamePlayColor][2], 0.0, 0.91, 0, 6.0, 1.1, 0.0, 0.0, -1)
	ShowSyncHudMsg(0, g_MsgSync4, "[Modo: %s] - Hora Feliz: %s", g_currentmod > MODE_NONE ? sGamePlayName2 : "Esperando nuevo modo...", HF_MULTIPLIER > 1 ? "Activada" : "Desactivada")	
}
