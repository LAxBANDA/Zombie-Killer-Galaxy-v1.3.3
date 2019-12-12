/***************************************************************************\
		   ========================================
		    * || [ZPA] Example Game Mode v1.6 || *
		   ========================================

	-------------------
	 *||DESCRIPTION||*
	-------------------

	This is an example game mode in which there are half Nemesiss
	and half Depredadors. You can use this plugin as a guide on how to
	make custom game modes for Zombie Plague Advance.

	-------------
	 *||CVARS||*
	-------------

	- zp_avsm_minplayers 2
		- Minimum players required for this game mode to be
		  activated

	- zp_avsm_depre_hp 1.5
		- Depredadors HP multiplier
	
	- zp_avsm_nemesis_hp 1.0
		- Nemesiss HP multiplier

	- zp_avsm_inf_ratio 0.5
		- Infection ratio of this game mode i.e how many players
		  will turn into nemesiss [Total players * infection ratio]
	
\***************************************************************************/

#include < amxmodx >
#include < fun >
#include < zombiekillergalaxy >

/************************************************************\
|                  Customizations Section                    |
|         You can edit here according to your liking         |
\************************************************************/

// This is the chance value according to which this game mode will be called
// The higher the value the lesser the chance of calling this game mode
new const g_chance = 30

// This is the access flag required to start the game mode
// through the admin menu. Look in users.ini for more details
new const g_access_flag[] = "a"

// This is the sound which is played when the game mode is triggered
// Add as many as you want [Randomly chosen if more than one]
new const g_play_sounds[][] =
{
	"zombie_plague/nemesis1.wav" ,
	"zombie_plague/survivor1.wav"
}

// Comment the following line to disable ambience sounds
// Just add two slashes ( // )
#define AMBIENCE_SOUNDS

#if defined AMBIENCE_SOUNDS
// Ambience Sounds (only .wav and .mp3 formats supported)
// Add as many as you want [Randomly chosen if more than one]
new const g_sound_ambience[][] =
{ 
	"zombie_plague/ambience.wav"
}

// Duration in seconds of each sound
new const Float:g_sound_ambience_duration[] = { 58.0 , 56.0 }
#endif

/************************************************************\
|                  Customizations Ends Here..!!              |
|         You can edit the cvars in the plugin init          |
\************************************************************/

// Variables
new g_gameid, g_maxplayers, cvar_minplayers, cvar_ratio, cvar_deprehp, cvar_nemhp, g_msg_sync

// Ambience sounds task
#define TASK_AMB 3256

public plugin_init( )
{
	// Plugin registeration.
	register_plugin( "[ZP] Nemesis vs Depredadors Mode","1.0", "@bdul!" )
	
	// Register some cvars
	// Edit these according to your liking
	cvar_minplayers = register_cvar("zp_avsm_minplayers", "2")
	cvar_deprehp =	  register_cvar("zp_avsm_depre_hp", "1.5")
	cvar_nemhp =	  register_cvar("zp_avsm_nemesis_hp", "1.0")
	cvar_ratio = 	  register_cvar("zp_avsm_inf_ratio", "0.5")
	
	// Get maxplayers
	g_maxplayers = get_maxplayers( )
	
	// Hud stuff
	g_msg_sync = CreateHudSyncObj()
}

// Game modes MUST be registered in plugin precache ONLY
public plugin_precache( )
{
	// Read the access flag
	new access_flag = read_flags( g_access_flag )
	new i
	
	// Precache the play sounds
	for (i = 0; i < sizeof g_play_sounds; i++)
		precache_sound( g_play_sounds[i] )
	
	// Precache the ambience sounds
	#if defined AMBIENCE_SOUNDS
	new sound[100]
	for (i = 0; i < sizeof g_sound_ambience; i++)
	{
		if (equal(g_sound_ambience[i][strlen(g_sound_ambience[i])-4], ".mp3"))
		{
			formatex(sound, sizeof sound - 1, "sound/%s", g_sound_ambience[i])
			precache_generic( sound )
		}
		else
		{
			precache_sound( g_sound_ambience[i] )
		}
	}
	#endif
	
	// Register our game mode
	g_gameid = zp_register_game_mode( "Nemesis vs Depredadors Mode", access_flag, g_chance, 0, ZP_DM_BALANCE )
}

// Player spawn post
public zp_player_spawn_post( id )
{
	// Check for current mode
	if(zp_get_lastmode() == g_gameid )
	{
		// Check if the player is a zombie
		if( zp_get_user_zombie( id ))
		{
			// Make him an nemesis instead
			zp_make_user_nemesis( id )
			
			// Set his health
			set_user_health( id, floatround(get_user_health(id) * get_pcvar_float(cvar_nemhp)) )
		}
		else
		{
			// Make him a depre
			zp_make_user_depre( id )
			
			// Set his health
			set_user_health( id, floatround(get_user_health(id) * get_pcvar_float(cvar_deprehp)) )
		}
	}
}

public zp_round_started_pre( game )
{
	// Check if it is our game mode
	if( game == g_gameid )
	{
		// Check for min players
		if( fn_get_alive_players() < get_pcvar_num(cvar_minplayers) )
		{
			/**
			 * Note:
			 * This very necessary, you should return ZP_PLUGIN_HANDLED if
			 * some conditions required by your game mode are not met
			 * This will inform the main plugin that you have rejected
			 * the offer and so the main plugin will allow other game modes
			 * to be given a chance
			 */
			return ZP_PLUGIN_HANDLED
		}
		// Start our new mode
		start_avs_mode( )
	}
	// Make the compiler happy =)
	return PLUGIN_CONTINUE
}

public zp_round_started( game, id )
{
	// Check if it is our game mode
	if( game == g_gameid )
	{
		// Show HUD notice
		set_hudmessage(221, 156, 21, -1.0, 0.17, 1, 0.0, 5.0, 1.0, 1.0, -1)
		ShowSyncHudMsg(0, g_msg_sync, "MODO Nemesis vs Depredadors !!!")
		
		// Play the starting sound
		client_cmd(0, "spk ^"%s^"", g_play_sounds[ random_num(0, sizeof g_play_sounds -1) ] )
		
		// Remove ambience task affects
		remove_task( TASK_AMB )
		
		// Set task to start ambience sounds
		#if defined AMBIENCE_SOUNDS
		set_task( 2.0, "start_ambience_sounds", TASK_AMB )
		#endif
	}
}

public zp_game_mode_selected( gameid, id )
{
	// Check if our game mode was called
	if( gameid == g_gameid )
		start_avs_mode( )
	
	// Make the compiler happy again =)
	return PLUGIN_CONTINUE
}

// This function contains the whole code behind this game mode
start_avs_mode( )
{
	// Create and initialize some important vars
	static i_nemesiss, i_max_nemesiss, id, i_alive
	i_alive = fn_get_alive_players()
	id = 0
	
	// Get the no of players we have to turn into nemesiss
	i_max_nemesiss = floatround( ( i_alive * get_pcvar_float( cvar_ratio ) ), floatround_ceil )
	i_nemesiss = 0
	
	// Randomly turn players into Nemesiss
	while (i_nemesiss < i_max_nemesiss)
	{
		// Keep looping through all players
		if ( (++id) > g_maxplayers) id = 1
		
		// Dead
		if ( !is_user_alive(id) )
			continue;
		
		// Random chance
		if (random_num(1, 5) == 1)
		{
			// Make user nemesis
			zp_make_user_nemesis(id)
			
			// Set his health
			set_user_health( id, floatround(get_user_health(id) * get_pcvar_float(cvar_nemhp)) )
			
			// Increase counter
			i_nemesiss++
		}
	}
	
	// Turn the remaining players into depres
	for (id = 1; id <= g_maxplayers; id++)
	{
		// Only those of them who are alive and are not nemesiss
		if ( !is_user_alive(id) || zp_get_user_nemesis(id) )
			continue;
			
		// Turn into a depre
		zp_make_user_depre(id)
		
		// Set his health
		set_user_health( id, floatround(get_user_health(id) * get_pcvar_float(cvar_deprehp)) )
	}
}

#if defined AMBIENCE_SOUNDS
public start_ambience_sounds( )
{
	// Variables
	static amb_sound[64], sound, Float:duration
	
	// Select our ambience sound
	sound = random_num( 0, sizeof g_sound_ambience - 1 )
	copy( amb_sound, sizeof amb_sound - 1 , g_sound_ambience[ sound ] )
	duration = g_sound_ambience_duration[ sound ]
	
	// Check whether it's a wav or mp3, then play it on clients
	if ( equal( amb_sound[ strlen( amb_sound ) - 4 ], ".mp3" ) )
		client_cmd( 0, "mp3 play ^"sound/%s^"", amb_sound )
	else
		client_cmd( 0, "spk ^"%s^"", sound )
	
	// Start the ambience sounds
	set_task( duration, "start_ambience_sounds", TASK_AMB )
}
public zp_round_ended( winteam )
{
	// Stop ambience sounds on round end
	remove_task( TASK_AMB )
}
#endif

// This function returns the no. of alive players
// Feel free to use this in your plugin when you 
// are making your own game modes.
fn_get_alive_players( )
{
	static i_alive, id
	i_alive = 0
	
	for ( id = 1; id <= g_maxplayers; id++ )
	{
		if( is_user_alive( id ) )
			i_alive++
	}
	return i_alive;
}
