#if defined _zombie_plague_advance_included
  #endinput
#endif
#define _zombie_plague_advance_included

/* Teams for zp_register_extra_item() */
#define ZP_TEAM_ZOMBIE (1<<0)
#define ZP_TEAM_HUMAN (1<<1)
#define ZP_TEAM_NEMESIS (1<<2)
#define ZP_TEAM_SURVIVOR (1<<3)
#define ZP_TEAM_SNIPER (1<<4)
#define ZP_TEAM_ASSASSIN (1<<5)

/* Death Match modes for zp_register_game_mode */
enum
{
	ZP_DM_NONE = 0,	// Disable death match during the custom mode round
	ZP_DM_HUMAN, 	// Respawn as human only
	ZP_DM_ZOMBIE, 	// Respawn as zombie only
	ZP_DM_RANDOM,	// Respawn randomly as humans or zombies
	ZP_DM_BALANCE	// Respawn as humans or zombies to keep both team balanced
}

/* Game modes for zp_round_started() */
enum
{
	MODE_NONE = 0,
	MODE_INFECTION,
	MODE_NEMESIS,
	MODE_ASSASSIN,
	MODE_ALIEN,
	MODE_SURVIVOR,
	MODE_SNIPER,
	MODE_WESKER,
	MODE_DEPRE,
	MODE_NINJA,
	MODE_SWARM,
	MODE_MULTI,
	MODE_PLAGUE,
	MODE_LNJ,
	MODE_TORNEO,
	MODE_SYNAPSIS,
	MODE_L4D,
	MAX_GAME_MODES
}


/* Winner teams for zp_round_ended() */
enum
{
	WIN_NO_ONE = 0,
	WIN_ZOMBIES,
	WIN_HUMANS
}

/* Custom forward return values */
#define ZP_PLUGIN_HANDLED 97

native zp_get_user_zombie(id)
native zp_get_user_nemesis(id)
native zp_get_user_survivor(id)
native zp_get_user_first_zombie(id)
native zp_get_user_last_zombie(id)
native zp_get_user_last_human(id)
native zp_get_user_zombie_class(id)
native zp_get_user_next_class(id)
native zp_set_user_zombie_class(id, classid)
native zp_get_user_ammo_packs(id)
native zp_set_user_ammo_packs(id, amount)
native zp_get_zombie_maxhealth(id)
native zp_get_user_batteries(id)
native zp_set_user_batteries(id, charge)
native zp_get_user_nightvision(id)
native zp_set_user_nightvision(id, set)
native zp_infect_user(id, infector = 0, silent = 0, rewards = 0)
native zp_disinfect_user(id, silent = 0)
native zp_make_user_nemesis(id)
native zp_make_user_depre(id)
native zp_make_user_survivor(id)
native zp_get_user_sniper(id)
native zp_make_user_sniper(id)
native zp_respawn_user(id, team)
native zp_force_buy_extra_item(id, itemid, ignorecost = 0)
native zp_get_user_assassin(id)
native zp_make_user_assassin(id)
native zp_get_user_alien(id)
native zp_make_user_alien(id)
native zp_get_user_wesker(id)
native zp_make_user_wesker(id)
native zp_has_round_started()
native zp_get_zombie_count()
native zp_get_human_count()
native zp_get_nemesis_count()
native zp_get_survivor_count()
native zp_is_sniper_round()
native zp_is_assassin_round()
native zp_is_alien_round()
native zp_is_wesker_round()
native zp_is_synapsis_round()
native zp_is_l4d_round()
native zp_is_ninja_round()
native zp_is_depre_round()
native zp_is_nemesis_round()
native zp_is_survivor_round()
native zp_is_swarm_round()
native zp_is_plague_round()
native zp_is_lnj_round()
native zp_get_sniper_count()
native zp_get_assassin_count()
native zp_get_alien_count()
native zp_get_wesker_count()
native zp_get_current_mode()
native zp_get_user_model(id, const model[], maxlen)
native zp_set_user_model(id, const model[])
native zp_get_extra_item_id(const name[])
native zp_get_zombie_class_id(const name[])
native zp_register_game_mode( const name[], flags, chance, allow, dm_mode)
native zp_register_extra_item(const name[], cost, teams, level)
native zp_register_zombie_class(const name[], const info[], const model[], const clawmodel[], hp, speed, Float:gravity, Float:knockback)
forward zp_round_started(gamemode, id)
forward zp_round_started_pre(gameid)
forward zp_round_ended(winteam)
forward zp_user_infected_pre(id, infector, nemesis)
forward zp_user_infected_post(id, infector, nemesis)
forward zp_user_humanized_pre(id, survivor)
forward zp_user_humanized_post(id, survivor)
forward zp_user_humanized_pre(id, sniper)
forward zp_user_humanized_post(id, sniper)
forward zp_user_infect_attempt(id, infector, nemesis)
forward zp_user_humanize_attempt(id, survivor)
forward zp_user_humanize_attempt(id, sniper)
forward zp_game_mode_selected(gameid, id)
forward zp_extra_item_selected(id, itemid)
forward zp_user_unfrozen(id)
forward zp_user_last_zombie(id)
forward zp_user_last_human(id)
forward zp_player_spawn_post(id, resp_zombie)
#define ZP_TEAM_ANY 0
native zp_get_user_depre(id)
native zp_get_user_ninja(id)
native zp_get_user_antifuego(id)
native zp_get_user_noantihielo(id)
native zp_get_user_antihielo(id)
native zp_get_user_noantifuego(id)
native zp_get_user_antilaser(id)
native zp_get_user_nodamage(id)
native zp_set_user_nodamage(id)
native zp_set_user_acabo_nodamage(id)
native zp_set_user_exp(id, amount)
native zp_get_user_exp(id)
native zp_exp_user_update(id)
native zp_get_user_level(id)
native zp_get_user_exp_level(id)
native zp_get_user_pesos(id)
native zp_set_user_pesos(id, amount)
native zp_get_user_double_access(id)
native zp_get_hf()
//native zp_get_user_laser(id)
native zp_set_user_level(id, amount)
native zp_get_user_human_class(id)
native zp_set_user_human_class(id, classid)

native zp_get_user_puntos(id)
native zp_set_user_puntos(id, amount)

native zp_get_user_mejora1(id)
native zp_set_user_mejora1(id, amount)

native zp_get_user_mejora2(id)
native zp_set_user_mejora2(id, amount)

native zp_get_user_mejora3(id)
native zp_set_user_mejora3(id, amount)

native zp_get_user_mejora4(id)
native zp_set_user_mejora4(id, amount)

native zp_set_user_resets(id, amount)

native zp_get_user_resets(id)

native zp_get_lastmode()

enum 
{
	BILL = 0,
	FRANCIS,
	LOUIS,
	ZOEY
}
native zp_get_user_l4d(id, iClase)



stock zp_colored_print(target, const message[], any:...)
{
	static buffer[512], i, argscount
	argscount = numargs()
	
	// Send to everyone
	if (!target)
	{
		static player
		for (player = 1; player <= get_maxplayers(); player++)
		{
			// Not connected
			if (!is_user_connected(player))
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
			message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, player)
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
		message_begin(MSG_ONE, get_user_msgid("SayText"), _, target)
		write_byte(target)
		write_string(buffer)
		message_end()
	}
}