#include <amxmodx>
#include <amxmisc>
#include <fakemeta_util>
#include <hamsandwich>
#include <reapi>
#include <cstrike>

#define AMBIENCE_FOG
#define AMBIENCE_RAIN

#define HUD_REFRESH	0.7
#define CENTER_REFRESH 0.2
#define TIMER_REFRESH 0.5

#define PLAYER_THINK 0.2
#define SENTRY_THINK 0.2
#define DISPENSER_THINK 0.2
#define TELEIN_THINK 0.1
#define TELEOUT_THINK 0.1

#define PICKUP_DELAY 0.5
#define CAPTURE_DELAY 0.6
#define CHECK_END 10.0
#define TELE_DELAY 0.6
#define SPAWN_DELAY	0.2
#define STICKYBOMB_DELAY 0.1
#define SPAWN_PROTECT 4.0
#define SAVE_DELAY 60.0
#define MAX_GIBTYPE 8
#define STATUS_CHANNEL 1
#define CENTER_CHANNEL 2
#define TIMER_CHANNEL 3
#define BUILD_CHANNEL 4
#define CP_MAXPOINTS 6
#define MAX_STICKYBOMB 8
#define SMOKETRAIL_RATE 0.2

#define BUILD_OWNER pev_iuser1
#define ITEM_TYPE pev_iuser4
#define PROJECTILE_CRITICAL pev_iuser2
#define PROJECTILE_REFLECT pev_iuser3
#define MAP_DISPATCH pev_iuser1
#define MAP_DISPATCH2 pev_iuser2
#define MAP_DISPATCH3 pev_iuser3
#define MAP_CPNUMS pev_iuser4
#define MAP_CPSTATUS pev_sequence
#define MAP_PLNUMS pev_iuser4

#define set_user_name(%1,%2) engfunc(EngFunc_SetClientKeyValue, %1, engfunc(EngFunc_GetInfoKeyBuffer, %1), "name", %2)
#define rg_get_user_team(%1) get_member(%1, m_iTeam)

stock const radio_scout_medic[3][] =
{
	"tfm/scout_medic01.wav",
	"tfm/scout_medic02.wav",
	"tfm/scout_medic03.wav",
}
stock const radio_soldier_medic[3][] =
{
	"tfm/soldier_medic01.wav",
	"tfm/soldier_medic02.wav",
	"tfm/soldier_medic03.wav",
}
stock const radio_demoman_medic[3][] =
{
	"tfm/demoman_medic01.wav",
	"tfm/demoman_medic02.wav",
	"tfm/demoman_medic03.wav",
}
stock const radio_heavy_medic[3][] =
{
	"tfm/heavy_medic01.wav",
	"tfm/heavy_medic02.wav",
	"tfm/heavy_medic03.wav",
}
stock const radio_engineer_medic[3][] =
{
	"tfm/engineer_medic01.wav",
	"tfm/engineer_medic02.wav",
	"tfm/engineer_medic03.wav",
}
stock const radio_medic_medic[3][] =
{
	"tfm/medic_medic01.wav",
	"tfm/medic_medic02.wav",
	"tfm/medic_medic03.wav",
}
stock const radio_sniper_medic[2][] =
{
	"tfm/sniper_medic01.wav",
	"tfm/sniper_medic02.wav",
}
stock const radio_pyro_medic[1][] =
{
	"tfm/pyro_medic01.wav",
}
stock const radio_spy_medic[3][] =
{
	"tfm/spy_medic01.wav",
	"tfm/spy_medic02.wav",
	"tfm/spy_medic03.wav",
}

enum { pistol_scout_idle = 0, pistol_scout_fire1, pistol_scout_fire2, pistol_scout_fire3, pistol_scout_fire4, pistol_scout_reload, pistol_scout_draw }

new const Snd_draw[] = { "tf2/draw_sound.wav" }
new const Snd_win[] = { "tf2/win_sound.wav" }
new const Snd_lose[] = { "tf2/lose_sound.wav" }

new const Snd_scattergun_shoot[] = { "tf2/scattergun_shoot.wav" }
new const Snd_scattergun_shoot_crit[] = { "tf2/scattergun_shoot_crit.wav" }
new const Snd_scattergun_reload[] = { "tf2/scattergun_reload.wav" }

new const Snd_pistol_scout_shoot[] = { "tf2/scout/secondary_shoot.wav" }

new const Snd_sniper_shoot[] = { "tf2/weapon/tf2_sniper/sniper_shoot.wav" }

new const Snd_minigun_spining[] = { "tf2/minigun_spining.wav" }
new const Snd_minigun_spinup[] = { "tf2/minigun_spinup.wav" }
new const Snd_minigun_spindown[] = { "tf2/minigun_spindown.wav" }
new const Snd_minigun_shoot[] = { "tf2/minigun_shoot.wav" }
new const Snd_minigun_shoot_crit[] = { "tf2/minigun_shoot_crit.wav" }

new const Snd_rocket_shoot[] = { "tf2/rocket_shoot.wav" }
new const Snd_rocket_shoot_crit[] = { "tf2/rocket_shoot_crit.wav" }
new const Snd_rocket_reload[] = { "tf2/rocket_reload.wav" }

new const Snd_smg_shoot[] = { "tf2/smg_shoot.wav"}
new const Snd_smg_shoot_crit[] = { "tf2/smg_shoot_crit.wav"}
new const Snd_smg_clipin[] = { "tf2/smg_clipin.wav"}
new const Snd_smg_clipout[] = { "tf2/smg_clipout.wav"}

new const Snd_medicgun_heal[] = { "tf2/medicgun_heal.wav" }
new const Snd_medicgun_chargeon[] = { "tf2/medicgun_chargeon.wav" }
new const Snd_medicgun_chargeoff[] = { "tf2/medicgun_chargeoff.wav" }

new const Snd_shotgun_shoot[] = { "tf2/shotgun_shoot.wav" }
new const Snd_shotgun_shoot_crit[] = { "tf2/shotgun_shoot_crit.wav" }
new const Snd_shotgun_reload[] = { "tf2/shotgun_reload.wav" }

new const Snd_syringegun_shoot[] = { "tf2/syringegun_shoot.wav" }
new const Snd_syringegun_shoot_crit[] = { "tf2/syringegun_shoot_crit.wav" }

new const Snd_grenade_shoot[] = { "tf2/grenade_shoot.wav" }
new const Snd_grenade_shoot_crit[] = { "tf2/grenade_shoot_crit.wav" }
new const Snd_grenade_reload[] = { "tf2/grenade_reload.wav" }

new const Snd_stickybomb_shoot[] = { "tf2/stickybomb_shoot.wav" }
new const Snd_stickybomb_shoot_crit[] = { "tf2/stickybomb_shoot_crit.wav" }
new const Snd_stickybomb_reload[] = { "tf2/stickybomb_reload.wav" }
new const Snd_stickybomb_charge[] = { "tf2/stickybomb_charge.wav" }
new const Snd_stickybomb_det[] = { "tf2/stickybomb_det.wav" }

new const Snd_explode[] = { "tf2/explode.wav" }

new const Snd_crit_hit[] = { "tf2/crit_hit.wav" }

new const Snd_crit_shoot[] = { "tf2/crit_shoot.wav" }

new const Snd_sentry_rocket[] = { "tf2/sentry_rocket.wav" }
new const Snd_sentry_shoot[] = { "tf2/sentry_shoot.wav" }
new const Snd_sentry_scan[] = { "tf2/sentry_scan.wav" }

new const Snd_dispenser_heal[] = { "tf2/dispenser_heal.wav" }

enum { KNIFE_BAT = 0, KNIFE_SHOVEL, KNIFE_FIRE_AXE, KNIFE_BOTTLE, KNIFE_FIST, KNIFE_WRENCH, KNIFE_BONESAW, KNIFE_KUKRI, KNIFE_KNIFE, MAX_KNIFES }
enum _handKnif { KnifeHit[64], KnifeWall[64], KnifeCritical[64] }

//	{ "(Knife HIT)", "(Knife Wall)", "(Knife Critical)" }
new const Snd_Knifes[MAX_KNIFES][_handKnif] = {
	{ "tf2/melee_hit/bat_hit.wav", "tf2/melee_wall/bat_wall.wav", "tf2/melee_critical/bat_critical.wav" }, // Bat
	{ "tf2/melee_hit/shovel_hit.wav", "tf2/melee_wall/shovel_wall.wav", "tf2/melee_critical/shovel_critical.wav" }, // Shovel
	{ "tf2/melee_hit/fire_axe_hit.wav", "tf2/melee_wall/fire_axe_wall.wav", "tf2/melee_critical/fire_axe_critical.wav" }, // Fire axe
	{ "tf2/melee_hit/bottle_hit.wav", "tf2/melee_wall/bottle_wall.wav", "tf2/melee_critical/bottle_critical.wav" }, // Bottle
	{ "tf2/melee_hit/fist_hit.wav", "tf2/melee_wall/fist_wall.wav", "tf2/melee_critical/fists_critical.wav" }, // Fist
	{ "tf2/melee_hit/wrench_hit.wav", "tf2/melee_wall/wrench_wall.wav", "tf2/melee_critical/wrench_critical.wav" }, // Wrench
	{ "tf2/melee_hit/bonesaw_hit.wav", "tf2/melee_wall/bonesaw_wall.wav", "tf2/melee_critical/bonesaw_critical.wav" }, // Bonesaw
	{ "tf2/melee_hit/kukri_hit.wav", "tf2/melee_wall/kukri_wall.wav", "tf2/melee_critical/kukri_critical.wav" }, // Kukri
	{ "tf2/melee_hit/knife_hit.wav", "tf2/melee_wall/knife_wall.wav", "tf2/melee_critical/knife_critical.wav" } // Knife
}

new const Bullet_medic_primary[] = { "models/tfm/bullets_syringes.mdl" }
new const Bullet_soldier_primary[] = { "models/tfm/bullets_rockets.mdl" }
new const Bullet_demoman_primary[] = { "models/tfm/bullets_grenades.mdl" }
new const Bullet_demoman_secondary[] = { "models/tfm/bullets_stickybombs.mdl" }

new const Mdl_v_toolbox[] = { "models/v_knife.mdl" }
new const Mdl_p_toolbox[] = { "models/p_knife.mdl" }

new const Mdl_v_pda[] = { "models/v_knife.mdl" }
new const Mdl_p_pda[] = { "models/p_knife.mdl" }

new const Mdl_sentry_base[] = { "models/tfm/w_sentry_base.mdl" }
new const Mdl_sentry_level1[] = { "models/tfm/w_sentry1.mdl" }
new const Mdl_sentry_level2[] = { "models/v_knife.mdl" }
new const Mdl_sentry_level3[] = { "models/v_knife.mdl" }

new const Mdl_dispenser[] = { "models/v_knife.mdl" }

new const Mdl_teleporter[] = { "models/v_knife.mdl" }

new const Dcl_blood[] = { 190, 191, 192, 193, 194, 195, 196, 197, 204, 205 }
new const Dcl_exp[] = { 46, 47, 48 }

new const g_wpn_name[][] = { "worldspawn", "p228", "unknow", "scout", "grenade", "xm1014", "c4", "mac10", "aug", "smokegrenade", "elite", "fiveseven", "ump45", "sg550", "galil", "famas", 
"usp", "glock18", "awp", "mp5navy", "m249", "m3", "m4a1", "tmp", "g3sg1", "flashbang", "deagle", "sg552", "ak47", "knife", "p90", "vest", "vesthelm", 
"xm1014", "m3", "minigun", "rpg_rocket", "mp5navy", "medicgun", "syringegun", "knife", "grenade", "grenade", "hammer", 
"toolbox", "pda", "sentry", "sentry_rocket", "reflect_rocket", "grenade" }

new const SentryBase_ClassName[] = "sentry_base"
new const SentryTurret_ClassName[] = "sentry_turret"
new const Dispenser_ClassName[] = "dispenser"
new const Telein_ClassName[] = "telein"
new const Teleout_ClassName[] = "teleout"

//new mdl_gib_player1, mdl_gib_player2, mdl_gib_player3, mdl_gib_player4, mdl_gib_player5, mdl_gib_player6

enum { CLASS_SCOUT = 0, CLASS_SOLDIER, CLASS_DEMOMAN, CLASS_HEAVY, CLASS_ENGINEER, CLASS_MEDIC, CLASS_SNIPER, CLASS_PYRO, CLASS_SPY, MAX_CLASS }

enum _handWpn
{
	Pri_ViewModelRed[64], Pri_WpnModelRed[64], Pri_ViewModelBlue[64], Pri_WpnModelBlue[64], 
	Sec_ViewModelRed[64], Sec_WpnModelRed[64], Sec_ViewModelBlue[64], Sec_WpnModelBlue[64], 
	Melee_ViewModelRed[64], Melee_WpnModelRed[64], Melee_ViewModelBlue[64], Melee_WpnModelBlue[64],
}

new const WpnModels[MAX_CLASS][_handWpn] =
{
	{ 	"models/tfm/v_scattergun_scout.mdl", "models/tfm/p_scattergun_scout.mdl", "models/tfm/v_scattergun_scout.mdl", "models/tfm/p_scattergun_scout.mdl", 
		"models/tfm/v_pistol_scout.mdl", "models/tfm/p_pistol_all.mdl", "models/tfm/v_pistol_scout.mdl", "models/tfm/p_pistol_all.mdl", 
		"models/tfm/v_bat_scout.mdl", "models/tfm/p_bat_scout.mdl", "models/tfm/v_bat_scout.mdl", "models/tfm/p_bat_scout.mdl" 
	}, 
	{ 	"models/tfm/v_rocket_launcher_soldier_red.mdl", "models/tfm/p_rocket_launcher_soldier.mdl", "models/tfm/v_rocket_launcher_soldier_blue.mdl", "models/tfm/p_rocket_launcher_soldier.mdl", 
		"models/tfm/v_shotgun_soldier_red.mdl", "models/tfm/p_shotgun_all.mdl", "models/tfm/v_shotgun_soldier_blue.mdl", "models/tfm/p_shotgun_all.mdl", 
		"models/tfm/v_shovel_soldier.mdl", "models/tfm/p_shovel_soldier.mdl", "models/tfm/v_shovel_soldier.mdl", "models/tfm/p_shovel_soldier.mdl" 
	}, 
	{ 	"models/v_knife.mdl", "models/tfm/p_grenade_launcher_demoman.mdl", "models/v_knife.mdl", "models/tfm/p_grenade_launcher_demoman.mdl", 
		"models/tfm/v_stickybomb_launcher_red.mdl", "models/tfm/p_stickybomb_launcher_demoman.mdl", "models/tfm/v_stickybomb_launcher_red.mdl", "models/tfm/p_stickybomb_launcher_demoman.mdl", 
		"models/v_knife.mdl", "models/tfm/p_bottle_demoman_red.mdl", "models/v_knife.mdl", "models/tfm/p_bottle_demoman_blue.mdl" 
	}, 
	{ 	"models/tfm/v_minigun_heavy.mdl", "models/tfm/p_minigun_heavy.mdl", "models/tfm/v_minigun_heavy.mdl", "models/tfm/p_minigun_heavy.mdl", 
		"models/v_knife.mdl", "models/tfm/p_shotgun_all.mdl", "models/v_knife.mdl", "models/tfm/p_shotgun_all.mdl", 
		"models/tfm/v_fist_heavy.mdl", "models/tfm/p_fist_heavy.mdl", "models/tfm/v_fist_heavy.mdl", "models/tfm/p_fist_heavy.mdl" 
	}, 
	{ 	"models/tfm/v_shotgun_engineer.mdl", "models/tfm/p_shotgun_all.mdl", "models/tfm/v_shotgun_engineer.mdl", "models/tfm/p_shotgun_all.mdl", 
		"models/v_knife.mdl", "models/tfm/p_pistol_all.mdl", "models/v_knife.mdl", "models/tfm/p_pistol_all.mdl", 
		"models/tfm/v_wrench_engineer_red.mdl", "models/tfm/p_wrench_engineer.mdl", "models/tfm/v_wrench_engineer_blue.mdl", "models/tfm/p_wrench_engineer.mdl" 
	}, 
	{ 	"models/tfm/v_medi_gun_medic_red.mdl", "models/tfm/p_medi_gun_medic_red.mdl", "models/tfm/v_medi_gun_medic_blue.mdl", "models/tfm/p_medi_gun_medic_blue.mdl", 
		"models/tfm/v_syringe_gun_medic_red.mdl", "models/tfm/p_syringe_gun_medic_red.mdl", "models/tfm/v_syringe_gun_medic_blue.mdl", "models/tfm/p_syringe_gun_medic_blue.mdl", 
		"models/tfm/v_bonesaw_medic_red.mdl", "models/tfm/p_bonesaw_medic.mdl", "models/tfm/v_bonesaw_medic_blue.mdl", "models/tfm/p_bonesaw_medic.mdl" 
	}, 
	{ 	"models/tfm/v_sniper_rifle_red.mdl", "models/tfm/p_sniper_rifle_sniper.mdl", "models/tfm/v_sniper_rifle_blue.mdl", "models/tfm/p_sniper_rifle_sniper.mdl", 
		"models/v_knife.mdl", "models/tfm/p_smg_sniper.mdl", "models/v_knife.mdl", "models/tfm/p_smg_sniper.mdl", 
		"models/tfm/v_kukri_red.mdl", "models/tfm/p_kukri_sniper.mdl", "models/tfm/v_kukri_blue.mdl", "models/tfm/p_kukri_sniper.mdl" 
	}, 
	{ 	"models/v_knife.mdl", "models/tfm/p_flame_thrower_pyro_red.mdl", "models/v_knife.mdl", "models/tfm/p_flame_thrower_pyro_blue.mdl", 
		"models/v_knife.mdl", "models/tfm/p_shotgun_all.mdl", "models/v_knife.mdl", "models/tfm/p_shotgun_all.mdl", 
		"models/v_knife.mdl", "models/p_knife.mdl", "models/v_knife.mdl", "models/p_knife.mdl" 
	}, 
	{ 	"models/v_knife.mdl", "models/p_knife.mdl", "models/v_knife.mdl", "models/p_knife.mdl", 
		"models/v_knife.mdl", "models/p_knife.mdl", "models/v_knife.mdl", "models/p_knife.mdl", 
		"models/v_knife.mdl", "models/p_knife.mdl", "models/v_knife.mdl", "models/p_knife.mdl" 
	}
}

enum _handler {	ClassName[32], PlayerModel[32], Default_Health, Float:Default_Speed }

// 	{ "Nome da Classe", "Player_Model", HP, Velocidade }
new const ClassConfig[MAX_CLASS][_handler] =
{
	{ "Scout", "tf2_scout", 125, 330.0 },
	{ "Soldier", "tf2_soldier", 200, 200.0 },
	{ "Demoman", "tf2_demoman", 175, 232.0 },
	{ "Heavy", "tf2_heavy", 300, 192.0 },
	{ "Engineer", "tf2_engineer", 125, 250.0 },
	{ "Medic", "tf2_medic", 150, 270.0 },
	{ "Sniper", "tf2_sniper", 125, 250.0 },
	{ "Pyro", "tf2_pyro", 125, 250.0 },
	{ "Spy", "tf2_spy", 125, 250.0 },
}

enum
{ 
	TF2_RED = 0,
	TF2_BLUE,
}

enum
{ 
	WIN_NO = 0,
	WIN_RED,
	WIN_BLUE,
}

enum
{
	TFM_SCATTERGUN = 33,
	TFM_SHOTGUN,
	TFM_MINIGUN,
	TFM_ROCKET,
	TFM_SMG,
	TFM_SYRINGEGUN,
	TFM_AMERK,
	TFM_GRENADE, 
	TFM_STICKYBOMB,
	TFM_HAMMER,
	TFM_TOOLBOX,
	TFM_PDA,
	TFM_SENTRY,
	TFM_SENTRYROCKET,
	TFM_REFLECTROCKET,
	TFM_REFLECTGRENADE,
}

enum (+= 50)
{
	TASK_SPAWN = 500,
	TASK_PLAYER_THINK,
	TASK_MEDICGUN,
	TASK_SHOWHUD,
	TASK_SHOWCENTER,
	TASK_CRITICAL,
	TASK_HIDEMONEY,
	TASK_RESPAWN,
	TASK_CHECK_END,
	TASK_ROUND_TIMER,
	DEATHMSG_SENTRY,
	DEATHMSG_DISPENSER,
	DEATHMSG_TELEIN,
	DEATHMSG_TELEOUT,
}

#define ID_SHOWHUD (taskid - TASK_SHOWHUD)
#define ID_PLAYER_THINK (taskid - TASK_PLAYER_THINK)
#define ID_SHOWCENTER (taskid - TASK_SHOWCENTER)

#if cellbits == 32
const OFFSET_CSMONEY = 115
const OFFSET_CSDEATHS = 444
#else
const OFFSET_CSMONEY = 140
const OFFSET_CSDEATHS = 493
#endif

const OFFSET_LINUX = 5
const KEYSMENU = (1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<5)|(1<<6)|(1<<7)|(1<<8)|(1<<9)
const HIDE_MONEY = (1<<5)

const m_iId = 43
const m_fKnown = 44
const m_iPrimaryAmmoType = 49
const m_iClip = 51
const m_fInReload = 54
const m_fInSpecialReload = 55

const XO_CBASEPLAYERWEAPON = 4;

const m_flNextAttack = 83
const m_rgAmmo_player_Slot0 = 376

stock const g_iDftMaxClip[CSW_P90+1] = { -1, 13, -1, 10, 1, 7, 1, 30, 30, 1, 30, 20, 25, 30, 35, 25, 12, 20, 10, 30, 100, 8, 30, 30, 20, 2, 7, 30, 30, -1, 50 }
stock const Float:g_fDelay[CSW_P90+1] = { 0.00, 2.70, 0.00, 2.00, 0.00, 0.55, 0.00, 3.15, 3.30, 0.00, 4.50, 2.70, 3.50, 3.35, 2.45, 3.30, 2.70, 2.20, 2.50, 2.63, 4.70, 0.55, 3.05, 2.12, 3.50, 0.00, 2.20, 3.00, 2.45, 0.00, 3.40 }
stock const g_iReloadAnims[CSW_P90+1] = { -1, 5, -1, 3, -1, 6, -1, 1, 1, -1, 14, 4, 2, 3, 1, 1, 13, 7, 4, 1, 3, 6, 11, 1, 3, -1, 4, 1, 1, -1, 1 }

new spr_beam, spr_critical, spr_trail, spr_rocketlaunch, spr_rocketsmoke, spr_explode, spr_blood_spray, spr_blood_drop, Mdl_gib_build[4]
new g_curmodel[33][32], g_class[33], g_willbeclass[33], g_score[33], g_death[33], g_speed[33], g_aiming[33], g_aiming_at_building[33]
new g_lastatk[2][33], g_critical[33], Float:g_nextfire[33], g_blockfire[33], bool:g_critical_on[33], bool:g_jumping[33]
new bool:g_cansecondjump[33], bool:g_secondjump[33], Float:g_pickup[33], Float:g_capture[33], bool:g_switching_name[33], g_critkilled[33]

enum { STATS_KILL = 0, STATS_ASSIST, STATS_CAPTURE, STATS_DEFEND, STATS_DESTORY, STATS_TELEPORT, STATS_BACKSTAB, STATS_HEADSHOT, STATS_SHIELD, MAX_STATS }
new g_stats[MAX_STATS][33], Float:g_stats_lastdie[33], Float:g_stats_lastspawn[33], Float:g_spawns[128][3]
new g_score_team[3], g_nodamage[33], g_noweapon[33], g_hudsync, g_hudcenter, g_hudbuild, g_hudtimer, g_text1[128], g_text2[128], g_text3[128]
new g_roundtime, g_setuptime, g_mapname[64], g_gamemode, g_round, g_fwEntitySpawn, g_fwKeyValue, g_spawnCount, g_modname[32], g_ItemFile[512], g_nametemp[33][32], g_wpnametemp[33][32], g_join_spawned[33], g_delay_spawned[33], Float:g_spawntime

new g_msgTeamInfo, g_msgScoreInfo, g_msgRoundTime, g_msgHideWeapon, g_msgTeamScore, g_msgScreenFade, g_msgSayText, g_msgCurWeapon, g_msgAmmoPickup
new const g_load_remove[][] = { "func_bomb_target", "info_bomb_target", "info_vip_start", "func_vip_safetyzone", "func_escapezone", "hostage_entity", "monster_scientist", "func_hostage_rescue", "info_hostage_rescue", "func_vehicle", "func_vehiclecontrols", "player_weaponstrip", "game_player_equip"}

enum { RpgRocket_ClassName = 0, SentryRocket_Classname, DemoGren_Classname, DemoStick_Classname, MedicSyringe_Classname, WeaponBox_Classname, MAX_CLASSNAMES }
new const g_EntityClassnames[MAX_CLASSNAMES][] = { "rpg_rocket", "sentry_rocket", "demo_grenade", "demo_stickybomb", "medic_syringe", "weaponbox"}

new g_cp_points[2][CP_MAXPOINTS], g_cp_pointnums[2], g_cp_progress[2][CP_MAXPOINTS], g_cp_local[2], g_wpn_traced[33]
new g_minigun_clip[33], g_minigun_status[33], Float:g_minigun_spindelay[33], Float:g_minigun_time[33] // Minigun
new g_rocket_clip[33], g_rocket_ammo[33], g_rocket_status[33], Float:g_rocket_time[33] // Rocket Launcher
new g_smg_clip[33], g_smg_ammo[33], g_smg_status[33], Float:g_smg_time[33] // SMG
new g_awp_clip[33], g_awp_ammo[33] // sniper
new g_shotgun_clip[33], g_shotgun_ammo[33], g_shotgun_status[33], Float:g_shotgun_time[33] // Shotgun
new g_medicgun_target[33], g_medicgun_using[33], g_healed_by[33] // Medicgun
new g_syringegun_clip[33], g_syringegun_ammo[33], g_syringegun_status[33], Float:g_syringegun_time[33] // Syringegun
new Float:g_medic_charge[33], g_charge_shield[33] // Medic
new Float:g_sniper_charge[33], Float:g_sniper_time[33], g_sniper_zoom[33] // AWP
new g_grenade_clip[33], g_grenade_ammo[33], g_grenade_status[33], Float:g_grenade_time[33] // Grenade Launcher
new g_stickybomb_clip[33], g_stickybomb_ammo[33], g_stickybomb_status[33], Float:g_stickybomb_time[33], Float:g_stickybomb_charge[33], g_stickybomb_entity[33][MAX_STICKYBOMB], g_stickybomb_num[33] // Stickybomb

// scout
new g_scattergun_clip[33], g_scattergun_ammo[33], Float:g_scattergun_time[33], g_scattergun_status[33]

new g_usp_clip[33], g_usp_ammo[33]

new g_sentry_base[33], g_sentry_turret[33], g_sentry_building[33], g_sentry_percent[33], g_sentry_level[33], g_sentry_strength[33], g_sentry_ammo[33], g_sentry_upgrade[33], Float:g_sentry_time[33], bool:g_havesentry[33]
new bool:g_havedispenser[33], g_dispenser[33], g_dispenser_building[33], g_dispenser_percent[33], g_dispenser_upgrade[33], g_dispenser_level[33], g_dispenser_strength[33], g_dispenser_ammo[33], Float:g_dispenser_rescan[33], Float:g_dispenser_respawn[33]

new bool:g_havetelein[33], g_telein[33], g_telein_building[33], g_telein_percent[33], g_telein_strength[33]
new bool:g_haveteleout[33], g_teleout[33], g_teleout_building[33], g_teleout_percent[33], g_teleout_strength[33]
new gtele_upgrade[33], gtele_level[33], g_tele_reload[33], g_tele_stand[33], Float:g_tele_timer[33], g_engineer_c4[33], g_engineer_metal[33]

new cvar_class_hp[MAX_CLASS], cvar_class_speed[MAX_CLASS]
new cvar_scattergun_mindmg, cvar_scattergun_maxdmg, cvar_scattergun_burst, cvar_scattergun_scatter, cvar_scattergun_clip, cvar_scattergun_ammo, cvar_scattergun_rof, cvar_scattergun_reload, cvar_scattergun_force, cvar_scattergun_draw
new cvar_shotgun_mindmg, cvar_shotgun_maxdmg, cvar_shotgun_burst, cvar_shotgun_scatter, cvar_shotgun_clip, cvar_shotgun_ammo, cvar_shotgun_rof, cvar_shotgun_reload, cvar_shotgun_force, cvar_shotgun_draw
new cvar_minigun_mindmg, cvar_minigun_maxdmg, cvar_minigun_burst, cvar_minigun_scatter, cvar_minigun_clip, cvar_minigun_rof, cvar_minigun_force, cvar_minigun_spinup, cvar_minigun_spindown, cvar_minigun_spining, /*cvar_minigun_slowdown,*/ cvar_minigun_draw
new cvar_rocket_dmg, cvar_rocket_mindmg, cvar_rocket_maxdmg, cvar_rocket_radius, cvar_rocket_clip, cvar_rocket_ammo
new cvar_rocket_rof, cvar_rocket_reload, cvar_rocket_force, cvar_rocket_multidmg, cvar_rocket_velocity, cvar_rocket_draw
new cvar_awp_mindmg, cvar_awp_maxdmg, cvar_awp_clip, cvar_awp_ammo, cvar_awp_rof, cvar_awp_headshot, cvar_awp_force, cvar_awp_chargedmg, cvar_awp_chargerate, cvar_awp_slowdown
new cvar_medicgun_minheal, cvar_medicgun_maxheal, cvar_medicgun_maxhealth, cvar_medicgun_rof, cvar_medicgun_charge, cvar_medicgun_range
new cvar_syringegun_mindmg, cvar_syringegun_maxdmg, cvar_syringegun_clip, cvar_syringegun_ammo, cvar_syringegun_rof, cvar_syringegun_reload, cvar_syringegun_force
new cvar_syringegun_draw, cvar_syringegun_vampiric, cvar_syringegun_velocity
new cvar_smg_mindmg, cvar_smg_maxdmg, cvar_smg_scatter, cvar_smg_clip, cvar_smg_ammo, cvar_smg_rof, cvar_smg_reload, cvar_smg_force, cvar_smg_draw
new cvar_usp_mindmg, cvar_usp_maxdmg, cvar_usp_clip, cvar_usp_ammo, cvar_usp_force
new cvar_knife_mindmg, cvar_knife_maxdmg, cvar_knife_rof, cvar_knife_force
new cvar_hammer_mindmg, cvar_hammer_maxdmg, cvar_hammer_rof, cvar_hammer_force
new cvar_amerk_mindmg, cvar_amerk_maxdmg, cvar_amerk_rof, cvar_amerk_force

new cvar_grenade_dmg, cvar_grenade_mindmg, cvar_grenade_maxdmg, cvar_grenade_radius, cvar_grenade_clip, cvar_grenade_ammo, cvar_grenade_rof, cvar_grenade_reload, cvar_grenade_force
new cvar_grenade_draw, cvar_grenade_velocity, cvar_grenade_delay

new cvar_stickybomb_dmg, cvar_stickybomb_mindmg, cvar_stickybomb_maxdmg, cvar_stickybomb_radius, cvar_stickybomb_clip, cvar_stickybomb_ammo, cvar_stickybomb_rof, cvar_stickybomb_reload, cvar_stickybomb_force
new cvar_stickybomb_draw, cvar_stickybomb_chargerate, cvar_stickybomb_chargevelo, cvar_stickybomb_velocity

new cvar_sentry_strength[3], cvar_sentry_ammo[3], cvar_sentry_cost[3], cvar_sentry_mindmg[3], cvar_sentry_maxdmg[3], cvar_sentry_radius[3]
new cvar_sentry_rocket_cost, cvar_sentry_rocket_rof, cvar_sentry_rocket_dmg, cvar_sentry_rocket_mindmg, cvar_sentry_rocket_maxdmg, cvar_sentry_rocket_radius, cvar_sentry_rocket_velocity
new cvar_sentry_rocket_force, cvar_sentry_force, cvar_sentry_scatter

new cvar_dispenser_strength[3], cvar_dispenser_ammo[3], cvar_dispenser_cost[3], cvar_dispenser_radius[3], cvar_dispenser_heal[3], cvar_dispenser_rsp[3], cvar_dispenser_rescan, cvar_dispenser_supply
new cvar_telein_strength[3], cvar_telein_cost, cvar_teleout_cost, cvar_teleout_strength[3], cvar_tele_cost[2], cvar_tele_reload[3], cvar_tele_trans[3]

new cvar_critical_dmg, cvar_critical_percent, cvar_global_gib_amount, cvar_global_gib_time, cvar_global_blood
new cvar_critical_tracered, cvar_critical_traceblue, cvar_critical_tracelen, cvar_critical_tracetime, cvar_critical_tracevelo, cvar_global_respawn
new cvar_roundtime_default, cvar_roundtime_capture, cvar_roundtime_ctflag, cvar_roundtime_payload

const PRIMARY_WEAPONS = (1<<CSW_SCOUT)|(1<<CSW_XM1014)|(1<<CSW_MAC10)|(1<<CSW_AUG)|(1<<CSW_UMP45)|(1<<CSW_SG550)|(1<<CSW_GALIL)|(1<<CSW_FAMAS)|(1<<CSW_AWP)|(1<<CSW_MP5NAVY)|(1<<CSW_M249)|(1<<CSW_M3)|(1<<CSW_M4A1)|(1<<CSW_M3)|(1<<CSW_G3SG1)|(1<<CSW_SG552)|(1<<CSW_AK47)|(1<<CSW_P90)
const SECONDARY_WEAPONS = (1<<CSW_P228)|(1<<CSW_ELITE)|(1<<CSW_FIVESEVEN)|(1<<CSW_USP)|(1<<CSW_GLOCK18)|(1<<CSW_DEAGLE)

enum { scattergun_idle = 0, scattergun_fire, scattergun_draw, scattergun_reload_start, scattergun_reload_loop, scattergun_reload_end } // scattergun status
enum { minigun_idle = 0, minigun_fire, minigun_draw, minigun_spool_up, minigun_spool_idle, minigun_spool_down } // minigun status
enum { rocket_idle = 0, rocket_reload, rocket_draw } // rocket status
enum { shotgun_idle = 0, shotgun_draw, shotgun_fire, shotgun_reload_start, shotgun_reload_loop, shotgun_reload_end  } // shotgun status
enum { syringegun_idle = 0, syringegun_reload, syringegun_draw, syringegun_shoot } // syringegun status
enum { smg_idle = 0, smg_reload, smg_draw } // smg status
enum { grenade_idle = 0, grenade_reload, grenade_draw } // grenade status

enum { anim_scattergun_idle = 0, anim_scattergun_shoot, anim_scattergun_draw, anim_scattergun_reload_start, anim_scattergun_reload_loop, anim_scattergun_reload_end } // scattergun anim
enum { anim_minigun_idle = 0, anim_minigun_shoot, anim_minigun_draw, anim_minigun_spool_up, anim_minigun_spool_idle, anim_minigun_spool_down } // minigun anim
enum { anim_rocket_idle = 0, anim_rocket_draw, anim_rocket_shoot, anim_rocket_reload } // rocket anim
enum { anim_shotgun_idle = 0, anim_shotgun_draw, anim_shotgun_fire, anim_shotgun_reload_start, anim_shotgun_reload_loop, anim_shotgun_reload_end } // shotgun anim
enum { anim_smg_idle = 0, anim_smg_reload, anim_smg_draw, anim_smg_shoot } // smg anim
enum { anim_medicgun_idle = 0, anim_medicgun_draw } // medicgun anim
enum { anim_syringegun_idle = 0, anim_syringegun_reload, anim_syringegun_draw, anim_syringegun_shoot } // syringegun anim
enum { anim_grenade_idle = 0, anim_grenade_reload, anim_grenade_draw, anim_grenade_shoot } // grenade anim

enum
{
	sb_idle = 0,
	sb_fire,
	sb_draw,
	sb_auto_fire,
	sb_reload_start,
	sb_reload_loop,
	sb_reload_end,
}

enum
{
	anim_sb_idle = 0,
	anim_sb_fire,
	anim_sb_draw,
	anim_sb_auto_fire,
	anim_sb_reload_start,
	anim_sb_reload_loop,
	anim_sb_reload_end,
}

enum { anim_sniper_rifle_idle = 0, anim_sniper_rifle_fire, anim_sniper_rifle_draw } // sniper_rifle anim

enum { round_setup = 0, round_normal, round_end }
enum { mode_normal = 0, mode_capture, mode_ctflag, mode_payload }
enum { cp_normal = 0, cp_defending, cp_capturing, cp_uncapturing }

new CS_Teams[][] = { "UNASSIGNED", "TERRORIST", "CT", "SPECTATOR" }

public CBasePlayerWeapon_DefaultReload(const this, iClipSize, iAnim, Float:fDelay)
{   
    if (get_member(this, m_Weapon_iClip) != iClipSize)
    {
        new iPlayerId = get_member(this, m_pPlayer)
        new iWeaponId = get_member(this, m_iId)

        if ((1 << iWeaponId) & (SECONDARY_WEAPONS))
        {
            new Float:flReloadTime

            if((1 << iWeaponId) & (SECONDARY_WEAPONS))
            {
                switch(g_class[iPlayerId])
				{
					case CLASS_SCOUT:
					{
						flReloadTime = 1.0
					}
				}
            }
            if(flReloadTime > 0.0)
            {
                set_member(iPlayerId, m_flNextAttack, flReloadTime)
                set_member(this, m_Weapon_flTimeWeaponIdle, flReloadTime)
            }
        }
    }
}

public plugin_precache()
{
	spr_trail = engfunc(EngFunc_PrecacheModel, "sprites/laserbeam.spr")
	spr_beam = engfunc(EngFunc_PrecacheModel, "sprites/tf2/medicbeam.spr")
	spr_critical = engfunc(EngFunc_PrecacheModel, "sprites/tf2/ft_critical.spr")
	spr_rocketlaunch = engfunc(EngFunc_PrecacheModel, "sprites/tf2/rocketlaunch.spr")
	spr_rocketsmoke = engfunc(EngFunc_PrecacheModel, "sprites/tf2/rocketsmoke.spr")
	spr_explode = engfunc(EngFunc_PrecacheModel, "sprites/tf2/explode.spr")
	spr_blood_spray = engfunc(EngFunc_PrecacheModel, "sprites/bloodspray.spr")
	spr_blood_drop = engfunc(EngFunc_PrecacheModel, "sprites/blood.spr")

	Mdl_gib_build[0] = engfunc(EngFunc_PrecacheModel, "models/mbarrel.mdl")
	Mdl_gib_build[1] = engfunc(EngFunc_PrecacheModel, "models/computergibs.mdl")
	Mdl_gib_build[2] = engfunc(EngFunc_PrecacheModel, "models/metalplategibs.mdl")
	Mdl_gib_build[3] = engfunc(EngFunc_PrecacheModel, "models/cindergibs.mdl")
	
	static i;
	for(i = 0; i < MAX_CLASS; i++) {
		precache_player_model(ClassConfig[i][PlayerModel])
		engfunc(EngFunc_PrecacheModel, WpnModels[i][Pri_ViewModelRed])
		engfunc(EngFunc_PrecacheModel, WpnModels[i][Pri_WpnModelRed])
		engfunc(EngFunc_PrecacheModel, WpnModels[i][Pri_ViewModelBlue])
		engfunc(EngFunc_PrecacheModel, WpnModels[i][Pri_WpnModelBlue])
		engfunc(EngFunc_PrecacheModel, WpnModels[i][Sec_ViewModelRed])
		engfunc(EngFunc_PrecacheModel, WpnModels[i][Sec_WpnModelRed])
		engfunc(EngFunc_PrecacheModel, WpnModels[i][Sec_ViewModelBlue])
		engfunc(EngFunc_PrecacheModel, WpnModels[i][Sec_WpnModelBlue])
		engfunc(EngFunc_PrecacheModel, WpnModels[i][Melee_ViewModelRed])
		engfunc(EngFunc_PrecacheModel, WpnModels[i][Melee_WpnModelRed])
		engfunc(EngFunc_PrecacheModel, WpnModels[i][Melee_ViewModelBlue])
		engfunc(EngFunc_PrecacheModel, WpnModels[i][Melee_WpnModelBlue])
	}
	
	engfunc(EngFunc_PrecacheModel, Mdl_v_toolbox)
	engfunc(EngFunc_PrecacheModel, Mdl_p_toolbox)

	engfunc(EngFunc_PrecacheModel, Mdl_v_pda)
	engfunc(EngFunc_PrecacheModel, Mdl_p_pda)

	engfunc(EngFunc_PrecacheModel, Bullet_medic_primary)
	engfunc(EngFunc_PrecacheModel, Bullet_demoman_primary)
	engfunc(EngFunc_PrecacheModel, Bullet_demoman_secondary)
	engfunc(EngFunc_PrecacheModel, Bullet_soldier_primary)

	engfunc(EngFunc_PrecacheModel, Mdl_sentry_base)
	engfunc(EngFunc_PrecacheModel, Mdl_sentry_level1)
	engfunc(EngFunc_PrecacheModel, Mdl_sentry_level2)
	engfunc(EngFunc_PrecacheModel, Mdl_sentry_level3)

	engfunc(EngFunc_PrecacheModel, Mdl_dispenser)

	engfunc(EngFunc_PrecacheModel, Mdl_teleporter)

	engfunc(EngFunc_PrecacheSound, "debris/bustmetal1.wav")
	engfunc(EngFunc_PrecacheSound, "debris/bustmetal2.wav")
	engfunc(EngFunc_PrecacheGeneric, "events/train.sc")

	engfunc(EngFunc_PrecacheSound, Snd_draw)
	engfunc(EngFunc_PrecacheSound, Snd_win)
	engfunc(EngFunc_PrecacheSound, Snd_lose)

	precache_sound(radio_scout_medic[0])
	precache_sound(radio_scout_medic[1])
	precache_sound(radio_scout_medic[2])

	precache_sound(radio_soldier_medic[0])
	precache_sound(radio_soldier_medic[1])
	precache_sound(radio_soldier_medic[2])

	precache_sound(radio_demoman_medic[0])
	precache_sound(radio_demoman_medic[1])
	precache_sound(radio_demoman_medic[2])

	precache_sound(radio_heavy_medic[0])
	precache_sound(radio_heavy_medic[1])
	precache_sound(radio_heavy_medic[2])

	precache_sound(radio_engineer_medic[0])
	precache_sound(radio_engineer_medic[1])
	precache_sound(radio_engineer_medic[2])

	precache_sound(radio_medic_medic[0])
	precache_sound(radio_medic_medic[1])
	precache_sound(radio_medic_medic[2])

	precache_sound(radio_sniper_medic[0])
	precache_sound(radio_sniper_medic[1])

	precache_sound(radio_pyro_medic[0])

	precache_sound(radio_spy_medic[0])
	precache_sound(radio_spy_medic[1])
	precache_sound(radio_spy_medic[2])

	engfunc(EngFunc_PrecacheSound, Snd_scattergun_shoot)
	engfunc(EngFunc_PrecacheSound, Snd_scattergun_shoot_crit)
	engfunc(EngFunc_PrecacheSound, Snd_scattergun_reload)

	engfunc(EngFunc_PrecacheSound, Snd_pistol_scout_shoot)
	engfunc(EngFunc_PrecacheSound, Snd_sniper_shoot)

	engfunc(EngFunc_PrecacheSound, Snd_minigun_spining)
	engfunc(EngFunc_PrecacheSound, Snd_minigun_spinup)
	engfunc(EngFunc_PrecacheSound, Snd_minigun_spindown)
	engfunc(EngFunc_PrecacheSound, Snd_minigun_shoot)
	engfunc(EngFunc_PrecacheSound, Snd_minigun_shoot_crit)

	engfunc(EngFunc_PrecacheSound, Snd_rocket_shoot)
	engfunc(EngFunc_PrecacheSound, Snd_rocket_shoot_crit)
	engfunc(EngFunc_PrecacheSound, Snd_rocket_reload)

	engfunc(EngFunc_PrecacheSound, Snd_smg_shoot)
	engfunc(EngFunc_PrecacheSound, Snd_smg_shoot_crit)
	engfunc(EngFunc_PrecacheSound, Snd_smg_clipin)
	engfunc(EngFunc_PrecacheSound, Snd_smg_clipout)

	engfunc(EngFunc_PrecacheSound, Snd_medicgun_heal)
	engfunc(EngFunc_PrecacheSound, Snd_medicgun_chargeon)
	engfunc(EngFunc_PrecacheSound, Snd_medicgun_chargeoff)

	engfunc(EngFunc_PrecacheSound, Snd_shotgun_shoot)
	engfunc(EngFunc_PrecacheSound, Snd_shotgun_shoot_crit)
	engfunc(EngFunc_PrecacheSound, Snd_shotgun_reload)

	engfunc(EngFunc_PrecacheSound, Snd_syringegun_shoot)
	engfunc(EngFunc_PrecacheSound, Snd_syringegun_shoot_crit)

	engfunc(EngFunc_PrecacheSound, Snd_grenade_shoot)
	engfunc(EngFunc_PrecacheSound, Snd_grenade_shoot_crit)
	engfunc(EngFunc_PrecacheSound, Snd_grenade_reload)

	engfunc(EngFunc_PrecacheSound, Snd_stickybomb_shoot)
	engfunc(EngFunc_PrecacheSound, Snd_stickybomb_shoot_crit)
	engfunc(EngFunc_PrecacheSound, Snd_stickybomb_reload)
	engfunc(EngFunc_PrecacheSound, Snd_stickybomb_charge)
	engfunc(EngFunc_PrecacheSound, Snd_stickybomb_det)

	engfunc(EngFunc_PrecacheSound, Snd_explode)
	engfunc(EngFunc_PrecacheSound, Snd_crit_hit)
	engfunc(EngFunc_PrecacheSound, Snd_crit_shoot)
	engfunc(EngFunc_PrecacheSound, Snd_sentry_rocket)
	engfunc(EngFunc_PrecacheSound, Snd_sentry_shoot)
	engfunc(EngFunc_PrecacheSound, Snd_sentry_scan)
	engfunc(EngFunc_PrecacheSound, Snd_dispenser_heal)

	for(i = 0; i < MAX_KNIFES; i++)
	{
		engfunc(EngFunc_PrecacheSound, Snd_Knifes[i][KnifeHit])
		engfunc(EngFunc_PrecacheSound, Snd_Knifes[i][KnifeWall])
		engfunc(EngFunc_PrecacheSound, Snd_Knifes[i][KnifeCritical])
	}
	engfunc(EngFunc_PrecacheSound, "items/gunpickup3.wav")

	#if defined AMBIENCE_FOG
	static ent
	ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "env_fog"))
	if(pev_valid(ent)) {
		fm_set_kvd(ent, "density", "0.0005", "env_fog")
		fm_set_kvd(ent, "rendercolor", "0 0 0", "env_fog")
	}
	#endif

	#if defined AMBIENCE_RAIN
		engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "env_rain"))
	#endif

	g_fwEntitySpawn = register_forward(FM_Spawn, "fw_EntitySpawn")
	g_fwKeyValue = register_forward(FM_KeyValue, "fw_KeyValue")
}

public event_playerdie() {
	new enemy = read_data(1)
	new id = read_data(2)
	if(!(1 <= id <= MaxClients)) return; 
	new wpname[32], bool:cswpn = false
	read_data(4, wpname, 31)

	if(g_round != round_end) set_task(get_pcvar_float(cvar_global_respawn), "task_respawn", id+TASK_RESPAWN)

	set_task(0.1, "check_end")

	for(new i = 0; i < g_stickybomb_num[id]; i++) {
		if(pev_valid(g_stickybomb_entity[id][i]))
			set_pev(g_stickybomb_entity[id][i], pev_flags, pev(g_stickybomb_entity[id][i], pev_flags) | FL_KILLME)
	}

	for(new i=0; i <= CSW_VESTHELM; i++) {
		if(equal(wpname, g_wpn_name[i])) {
			cswpn = true; 
			break; 
		}
	}
	if(cswpn) {
		g_critkilled[id] = 1
		if((!(1 <= enemy <= MaxClients) || enemy == id)) {
			ck_fakekill_msg(id, id, wpname)
		}
		else if(equal(wpname, g_wpn_name[CSW_KNIFE])) {
			switch(g_class[enemy]) {
				case CLASS_SCOUT: ck_fakekill_msg(id, enemy, g_wpn_name[CSW_KNIFE])
				case CLASS_HEAVY: ck_fakekill_msg(id, enemy, g_wpn_name[CSW_KNIFE])
				case CLASS_SOLDIER: ck_fakekill_msg(id, enemy, g_wpn_name[CSW_KNIFE])
				case CLASS_SNIPER: ck_fakekill_msg(id, enemy, g_wpn_name[CSW_KNIFE])
				case CLASS_MEDIC: ck_fakekill_msg(id, enemy, g_wpn_name[TFM_AMERK])
				case CLASS_ENGINEER: ck_fakekill_msg(id, enemy, g_wpn_name[TFM_HAMMER])
				case CLASS_DEMOMAN: ck_fakekill_msg(id, enemy, g_wpn_name[CSW_KNIFE])
				case CLASS_SPY: ck_fakekill_msg(id, enemy, g_wpn_name[CSW_KNIFE])
				case CLASS_PYRO: ck_fakekill_msg(id, enemy, g_wpn_name[CSW_KNIFE])
			}
		}
		else {
			ck_fakekill_msg(id, enemy, wpname)
		}
	}
	FX_UpdateScore(id)
	g_stats_lastdie[id] = get_gametime()
}

public Ham_Knife_Deploy(const iEntity)
{
    set_member(iEntity, m_Weapon_flNextSecondaryAttack, 9999.9)    
}

public Ham_Knife_PrimaryAttack_Post(const iEntity)
{
    set_member(iEntity, m_Weapon_flNextSecondaryAttack, 9999.9)    
}

public ck_fakekill_msg(id, enemy, const wpname[]) {
	new build
	if(id > MaxClients) {
		if(is_user_connected(id - DEATHMSG_SENTRY)) {
			build = 1
			id -= DEATHMSG_SENTRY
		} else if(is_user_connected(id - DEATHMSG_DISPENSER)) {
			build = 2
			id -= DEATHMSG_DISPENSER
		} else if(is_user_connected(id - DEATHMSG_TELEIN)) {
			build = 3
			id -= DEATHMSG_TELEIN
		} else if(is_user_connected(id - DEATHMSG_TELEOUT)) {
			build = 4
			id -= DEATHMSG_TELEOUT
		} else {
			return; 
		}
	} else if(!is_user_connected(id)) {
		return; 
	}
	
	static TeamName:EnemyTeam, TeamName:UserTeam, TeamName:LastAtkTeam, Team_Color; 
	UserTeam = rg_get_user_team(id)
	EnemyTeam = rg_get_user_team(enemy)
	LastAtkTeam = is_user_connected(g_lastatk[1][id]) ? rg_get_user_team(g_lastatk[1][id]) : 0

	if(id == enemy || !(1 <= enemy <= MaxClients)) {
		ck_deathmsg(id, 0, id, 0, wpname)
		g_death[id]++
		return
	} 
	else if(UserTeam != EnemyTeam) 
	{
		Team_Color = (EnemyTeam == TEAM_TERRORIST) ? TF2_RED : TF2_BLUE
		g_stats[STATS_KILL][enemy]++
		g_score[enemy]++
		g_score_team[Team_Color]++
		switch(build) {
			case 0: g_death[id]++; 
			case 1: id += DEATHMSG_SENTRY; 
			case 2: id += DEATHMSG_DISPENSER; 
			case 3: id += DEATHMSG_TELEIN; 
			case 4: id += DEATHMSG_TELEOUT;
		}
		new assist = ck_get_user_assistance(enemy)
		if(is_user_alive(assist)) {
			g_stats[STATS_ASSIST][assist]++
			g_score[assist]++
			ck_deathmsg(enemy, assist, id, g_critkilled[id], wpname)
			FX_UpdateScore(enemy)
			FX_UpdateScore(assist)
		} else if(g_lastatk[0][id] == enemy && is_user_alive(g_lastatk[1][id]) && g_lastatk[1][id] != enemy && EnemyTeam == LastAtkTeam) {
			assist = g_lastatk[1][id]
			g_stats[STATS_ASSIST][assist]++
			ck_deathmsg(enemy, assist, id, g_critkilled[id], wpname)
			FX_UpdateScore(enemy)
		} else if(g_lastatk[1][id] == enemy && is_user_alive(g_lastatk[0][id]) && g_lastatk[0][id] != enemy && EnemyTeam == LastAtkTeam) {
			assist = g_lastatk[0][id]
			g_stats[STATS_ASSIST][assist]++
			ck_deathmsg(enemy, assist, id, g_critkilled[id], wpname)
			FX_UpdateScore(enemy)
		} else {
			ck_deathmsg(enemy, 0, id, g_critkilled[id], wpname)
			FX_UpdateScore(enemy)
		}
	}
}

public task_respawn(taskid) {
	static id
	if(taskid > MaxClients)
		id = taskid - TASK_RESPAWN
	else
		id = taskid

	if(!is_user_connected(id))
		return;

	remove_task(id + TASK_RESPAWN, 0)
	if(g_round == round_end) return; 
	if(!(1 <= id <= MaxClients)) return; 
	if(is_user_alive(id)) return; 

	static TeamName:userTeam
	userTeam = rg_get_user_team(id)
	if(userTeam == TEAM_SPECTATOR || userTeam == TEAM_UNASSIGNED) return; 
	ExecuteHamB(Ham_CS_RoundRespawn, id)
}

public event_damage(id) {
	if(is_user_alive(id)) 
		ck_showhud_status(id)
}

public fw_TraceAttack_Building(id, enemy, Float:damage, Float:direction[3], tracehandle, damagetype) {
	if(!(1 <= enemy <= MaxClients))
		return HAM_IGNORED
	static weapon, owner, SameTeam, blockdamage, fakebuildId
	weapon = get_user_weapon(enemy)
	owner = pev(id, BUILD_OWNER)
	SameTeam = isSameTeam(owner, enemy); 
	blockdamage = false; 
	fakebuildId = 0; 
	
	if(SameTeam && weapon == CSW_KNIFE) {
		static heavyknife
		heavyknife = (damage <= 50.0) ? 0 : 1; 
		if(FClassnameIs(id, SentryBase_ClassName) || FClassnameIs(id, SentryTurret_ClassName)) {
			if(enemy == owner && g_class[enemy] == CLASS_ENGINEER)
				ck_sentry_repair(enemy, heavyknife ? 2 : 1)
			else if(g_class[enemy] == g_class[owner] && g_class[owner] == CLASS_ENGINEER && owner != enemy)
				ck_sentry_repair_help(owner, enemy, heavyknife ? 2 : 1)

			fakebuildId = 1
			blockdamage = true; 
		} 
		else if(FClassnameIs(id, Dispenser_ClassName)) 
		{
			if(enemy == owner && g_class[enemy] == CLASS_ENGINEER)
				ck_dispenser_repair(enemy, heavyknife ? 2 : 1)
			else if(g_class[enemy] == g_class[owner] && g_class[owner] == CLASS_ENGINEER && owner != enemy)
				ck_dispenser_repair_help(owner, enemy, heavyknife ? 2 : 1)

			fakebuildId = 2
			blockdamage = true; 
		} 
		else if(FClassnameIs(id, Telein_ClassName)) 
		{
			if(enemy == owner && g_class[enemy] == CLASS_ENGINEER)
				ck_telein_repair(enemy, heavyknife ? 2 : 1)
			else if(g_class[enemy] == g_class[owner] && g_class[owner] == CLASS_ENGINEER && owner != enemy)
				ck_telein_repair_help(owner, enemy, heavyknife ? 2 : 1)

			fakebuildId = 3
			blockdamage = true; 
		} 
		else if(FClassnameIs(id, Teleout_ClassName)) {
			if(enemy == owner && g_class[enemy] == CLASS_ENGINEER)
				ck_teleout_repair(enemy, heavyknife ? 2 : 1)
			else if(g_class[enemy] == g_class[owner] && g_class[owner] == CLASS_ENGINEER && owner != enemy)
				ck_teleout_repair_help(owner, enemy, heavyknife ? 2 : 1)

			fakebuildId = 4
			blockdamage = true; 
		}
	}
	else if(!SameTeam && fakebuildId > 0) {
		switch(weapon) {
			case CSW_KNIFE: {
				switch(g_class[enemy]) {
					case CLASS_ENGINEER: {
						damage = random_float(get_pcvar_float(cvar_hammer_mindmg), get_pcvar_float(cvar_hammer_maxdmg))
						weapon = TFM_HAMMER
					}
					case CLASS_MEDIC: {
						damage = random_float(get_pcvar_float(cvar_amerk_mindmg), get_pcvar_float(cvar_amerk_maxdmg))
						weapon = TFM_AMERK
					}
					default:damage = random_float(get_pcvar_float(cvar_knife_mindmg), get_pcvar_float(cvar_knife_maxdmg))
				}
			}
			case WEAPON_AWP: {
				damage = random_float(get_pcvar_float(cvar_awp_mindmg), get_pcvar_float(cvar_awp_maxdmg))
				if(g_sniper_charge[enemy] > 0.0)
					damage = (1.0 + (g_sniper_charge[enemy] / 100.0 * get_pcvar_float(cvar_awp_chargedmg))) * damage
			}
			case WEAPON_P228: {
				damage = random_float(get_pcvar_float(cvar_usp_mindmg), get_pcvar_float(cvar_usp_maxdmg))
			}
		}
		ck_fakedamage_build(owner, enemy, floatround(damage), weapon, fakebuildId)
		blockdamage = true; 
	}
		
	return blockdamage ? HAM_SUPERCEDE : HAM_IGNORED
}

public fw_Think_Building(entity) {
	if(!pev_valid(entity)) return
	if(FClassnameIs(entity, SentryBase_ClassName)) {
		fw_Think_SentryBase(entity)
	} else if(FClassnameIs(entity, Dispenser_ClassName)) {
		fw_Think_Dispenser(entity)
	} else if(FClassnameIs(entity, Telein_ClassName)) {
		fw_Think_Telein(entity)
	} else if(FClassnameIs(entity, Teleout_ClassName)) {
		fw_Think_Teleout(entity)
	}
}

public fw_TraceAttack(id, enemy, Float:damage, Float:direction[3], tracehandle, damagetype) {
	if(!is_user_connected(enemy))
		return HAM_IGNORED;
	
	if(damagetype & DMG_FALL) {
		if((g_charge_shield[g_healed_by[id]] && ck_get_user_assistance(id) > 0) || g_charge_shield[id])
			return HAM_SUPERCEDE
		
		damage /= 2.0
		if(damage > 500.0)
			damage = 500.0
		SetHamParamFloat(3, damage)
		return HAM_IGNORED
	}
	if(id == enemy || !(1 <= enemy <= MaxClients))
		return HAM_IGNORED

	if(g_nodamage[id] || g_charge_shield[id] || isSameTeam(enemy, id) || (g_charge_shield[g_healed_by[id]] && ck_get_user_assistance(id) > 0))
		return HAM_SUPERCEDE

	static weapon, crit, Float:force
	weapon = get_user_weapon(enemy)
	crit = 0
	switch(weapon) {
		case CSW_KNIFE: {
			switch(g_class[enemy]) {
				case CLASS_ENGINEER: {
					damage = random_float(get_pcvar_float(cvar_hammer_mindmg), get_pcvar_float(cvar_hammer_maxdmg))
					force = damage * get_pcvar_float(cvar_hammer_force)
				}
				case CLASS_MEDIC: {
					damage = random_float(get_pcvar_float(cvar_amerk_mindmg), get_pcvar_float(cvar_amerk_maxdmg))
					force = damage * get_pcvar_float(cvar_amerk_force)
					if(is_back_face(enemy, id)) {
						damage *= get_pcvar_float(cvar_critical_dmg)
						FX_Critical(enemy, id)
						crit = 1
					}
				}
				default: {
					damage = random_float(get_pcvar_float(cvar_knife_mindmg), get_pcvar_float(cvar_knife_maxdmg))
					force = damage * get_pcvar_float(cvar_knife_force)
				}
			}
			if(g_critical_on[enemy] && !crit) {
				damage *= get_pcvar_float(cvar_critical_dmg)
				FX_Critical(enemy, id)
				crit = 1
			}
			SetHamParamFloat(3, damage)
			ck_knockback(id, enemy, force)
		}
		case WEAPON_AWP: {
			damage = random_float(get_pcvar_float(cvar_awp_mindmg), get_pcvar_float(cvar_awp_maxdmg))
			if(get_tr2(tracehandle, TR_iHitgroup) == HIT_HEAD && g_sniper_charge[enemy] > 10.0) {
				g_stats[STATS_HEADSHOT][enemy]++
				damage *= get_pcvar_float(cvar_awp_headshot)
				FX_Critical(enemy, id)
				crit = 1
			}
			if(g_sniper_charge[enemy] > 0.0) damage = (1.0 + (g_sniper_charge[enemy] / 100.0 * get_pcvar_float(cvar_awp_chargedmg))) * damage
			force = damage * get_pcvar_float(cvar_awp_force)
			SetHamParamFloat(3, damage)
			ck_knockback(id, enemy, force)
		}
		case WEAPON_P228: {
			damage = random_float(get_pcvar_float(cvar_usp_mindmg), get_pcvar_float(cvar_usp_maxdmg))
			if(g_critical_on[enemy] && !crit) {
				damage *= get_pcvar_float(cvar_critical_dmg)
				FX_Critical(enemy, id)
				crit = 1
			}
			force = damage * get_pcvar_float(cvar_usp_force)
			SetHamParamFloat(3, damage)
			ck_knockback(id, enemy, force)
		}
	}

	static TeamName:LastATKTeam[2], TeamName:EnemyTeam; 
	LastATKTeam[0] = is_user_connected(g_lastatk[0][id]) ? rg_get_user_team(g_lastatk[0][id]) : 0;
	LastATKTeam[1] = is_user_connected(g_lastatk[1][id]) ? rg_get_user_team(g_lastatk[1][id]) : 0;
	EnemyTeam = rg_get_user_team(enemy)

	if(!is_user_connected(g_lastatk[0][id]) || LastATKTeam[0] != EnemyTeam) {
		g_lastatk[0][id] = enemy
	} else if(!is_user_connected(g_lastatk[1][id]) || LastATKTeam[1] != EnemyTeam) {
		g_lastatk[1][id] = enemy
	} else if(g_lastatk[0][id] != enemy && g_lastatk[1][id] != enemy) {
		g_lastatk[1][id] = enemy
	} else if(g_lastatk[0][id] != enemy && g_lastatk[1][id] == enemy) {
		g_lastatk[1][id] = g_lastatk[0][id]
		g_lastatk[0][id] = enemy
	}

	if(crit) {
		set_tr2(tracehandle, TR_iHitgroup, HIT_HEAD)
		SetHamParamTraceResult(5, tracehandle); 
	} else {
		set_tr2(tracehandle, TR_iHitgroup, HIT_CHEST)
		SetHamParamTraceResult(5, tracehandle); 
	}
	return HAM_IGNORED
}

stock FX_Smoke(Float:Origin[3]) {
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, Origin)
	write_byte(TE_SMOKE)
	for(new i = 0; i < 3; i++) engfunc(EngFunc_WriteCoord, Origin[i])
	write_short(spr_rocketsmoke)
	write_byte(10)
	write_byte(6)
	message_end()
}

stock FX_Explode(Float:Origin[3], anim, scale, rate, flags) {
	static iorigin[3], i
	FVecIVec(Origin, iorigin)
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_EXPLOSION)
	for(i = 0; i < 3; i++) write_coord(iorigin[i])
	write_short(anim)
	write_byte(scale)
	write_byte(rate)
	write_byte(flags)
	message_end()
}

stock FX_NewExplode(Float:origin[3]) {
	static iorigin[3], i
	FVecIVec(origin, iorigin)

	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, origin, 0)
	write_byte(TE_SPARKS)
	for(i = 0; i < 3; i++) engfunc(EngFunc_WriteCoord, origin[i])
	message_end()

	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, origin, 0)
	write_byte(TE_EXPLOSION)
	engfunc(EngFunc_WriteCoord, origin[0]+random_float(-5.0, 5.0)) // x
	engfunc(EngFunc_WriteCoord, origin[1]+random_float(-5.0, 5.0)) // y
	engfunc(EngFunc_WriteCoord, origin[2]+random_float(-5.0, 10.0)) // z
	write_short(spr_explode)
	write_byte(random_num(15, 25))
	write_byte(random_num(10, 20))
	write_byte(TE_EXPLFLAG_NOSOUND)
	message_end()
}

stock FX_Critical(id, target) {
	if(!is_user_alive(id) || !is_user_alive(target)) return; 
	engfunc(EngFunc_EmitSound, id, CHAN_STATIC, Snd_crit_hit, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	engfunc(EngFunc_EmitSound, target, CHAN_STATIC, Snd_crit_hit, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	static iorigin[3], Float:forigin[3]
	pev(target, pev_origin, forigin)
	FVecIVec(forigin, iorigin)
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_BUBBLES)
	write_coord(iorigin[0])
	write_coord(iorigin[1])
	write_coord(iorigin[2] + 16)
	write_coord(iorigin[0])
	write_coord(iorigin[1])
	write_coord(iorigin[2] + 32)
	write_coord(192)
	write_short(spr_critical)
	write_byte(1)
	write_coord(30)
	message_end()
}

stock FX_Healbeam(from, to, r, g, b, time) {
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_BEAMENTS)
	write_short(from)
	write_short(to)
	write_short(spr_beam)
	write_byte(0)
	write_byte(0)
	write_byte(time)
	write_byte(30)
	write_byte(0)
	write_byte(r)
	write_byte(g)
	write_byte(b)
	write_byte(100)
	write_byte(0)
	message_end()
}

stock FX_Blood(id, level) {
	if(level > 3 || level < 1) return; 
	static origin[3], Float:forigin[3]
	pev(id, pev_origin, forigin)
	FVecIVec(forigin, origin)
	static x, y, z, i
	for(i = 1; i <= level; i++) {
		x = random_num(-50, 50)
		y = random_num(-50, 50)
		z = random_num(0, 50)
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(TE_BLOODSPRITE)
		write_coord(origin[0]+x)
		write_coord(origin[1]+y)
		write_coord(origin[2]+z)
		write_short(spr_blood_spray)
		write_short(spr_blood_drop)
		write_byte(229) // color index
		write_byte(15) // size
		message_end()
	}
}

stock FX_BloodDecal(id) {
	static Float:origin[3], i
	pev(id, pev_origin, origin)
	origin[2] -= (pev(id, pev_bInDuck)) ? 18.0 : 36.0;

	engfunc(EngFunc_MessageBegin, MSG_PAS, SVC_TEMPENTITY, origin, 0)
	write_byte(TE_WORLDDECAL)
	for(i = 0; i < 3; i++) engfunc(EngFunc_WriteCoord, origin[i])
	write_byte(Dcl_blood[random_num(0, charsmax(Dcl_blood))])
	message_end()
}

stock FX_ExpDecal(Float:origin[3]) {
	engfunc(EngFunc_MessageBegin, MSG_PAS, SVC_TEMPENTITY, origin, 0)
	write_byte(TE_WORLDDECAL)
	for(new i = 0; i < 3; i++) engfunc(EngFunc_WriteCoord, origin[i]);
	write_byte(Dcl_exp[random_num(0, charsmax(Dcl_exp))])
	message_end()
}

stock FX_Demolish(build) {
	if(!pev_valid(build)) return; 
	static Float:forigin[3], iorigin[3], i, y
	pev(build, pev_origin, forigin)
	FVecIVec(forigin, iorigin)

	for(y = 0; y < 4; y++) {
		for(i = 1; i <= get_pcvar_num(cvar_global_gib_amount); i++) {
			message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
			write_byte(TE_MODEL)
			write_coord(iorigin[0])
			write_coord(iorigin[1])
			write_coord(iorigin[2])
			write_coord(random_num(-150, 150))
			write_coord(random_num(-150, 150))
			write_coord(random_num(150, 350))
			write_angle(random_num(0, 360))
			write_short(Mdl_gib_build[y])
			write_byte(0)
			write_byte(get_pcvar_num(cvar_global_gib_time)) // life
			message_end()
		}
	}
}

stock FX_Trace(const Float:idorigin[3], const Float:targetorigin[3]) {
	static id[3], target[3], i
	FVecIVec(idorigin, id)
	FVecIVec(targetorigin, target)
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(6)
	for(i = 0; i < 3; i++) write_coord(id[i])
	for(i = 0; i < 3; i++) write_coord(target[i])
	message_end()
}

stock FX_ColoredTrace(id, target) {
	if(!pev_valid(id) || !pev_valid(target) || !is_user_connected(id)) return; 
	static Float:idfloat[3], Float:targetfloat[3], Float:velfloat[3]
	pev(id, pev_origin, idfloat)
	pev(target, pev_origin, targetfloat)
	get_speed_vector(idfloat, targetfloat, get_pcvar_float(cvar_critical_tracevelo), velfloat)
	static id[3], vel[3], i
	FVecIVec(idfloat, id)
	FVecIVec(velfloat, vel)
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_USERTRACER)
	for(i = 0; i < 3; i++) write_coord(id[i]);
	for(i = 0; i < 3; i++) write_coord(vel[i]);
	write_byte(get_pcvar_num(cvar_critical_tracetime))
	write_byte(get_pcvar_num((rg_get_user_team(id) == TEAM_TERRORIST) ? cvar_critical_tracered : cvar_critical_traceblue))
	write_byte(get_pcvar_num(cvar_critical_tracelen))
	message_end()
}

stock FX_ColoredTrace_Point(id, const Float:idorigin[3], const Float:targetorigin[3]) {
	if(!is_user_connected(id))
		return

	static Float:velocity[3], TeamName:userTeam, i
	userTeam = rg_get_user_team(id); 
	get_speed_vector(idorigin, targetorigin, get_pcvar_float(cvar_critical_tracevelo), velocity)
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_USERTRACER)
	for(i = 0; i < 3; i++) write_coord(floatround(idorigin[i]));
	for(i = 0; i < 3; i++) write_coord(floatround(velocity[i]));
	write_byte(get_pcvar_num(cvar_critical_tracetime))
	write_byte(get_pcvar_num((userTeam == TEAM_TERRORIST) ? cvar_critical_tracered : cvar_critical_traceblue))
	write_byte(get_pcvar_num(cvar_critical_tracelen))
	message_end()
}

public check_end() {
	remove_task(TASK_CHECK_END, 0)
	set_task(CHECK_END, "check_end", TASK_CHECK_END)
	if(g_round == round_end) return; 
	switch(g_gamemode) {
		case mode_normal: {
			if(g_roundtime <= 0) {
				if(g_score_team[TF2_RED] > g_score_team[TF2_BLUE])
					end_round(WIN_RED)
				else if(g_score_team[TF2_RED] < g_score_team[TF2_BLUE])
					end_round(WIN_BLUE)
				else
					end_round(WIN_NO)
				return; 
			}
		}
		case mode_capture: {
			if(g_cp_local[TF2_RED] >= 100)
				end_round(WIN_RED)
			else if(g_cp_local[TF2_BLUE] >= 100)
				end_round(WIN_BLUE)
			else if(g_roundtime <= 0)
				end_round(WIN_NO)
		}
	}
}

public task_critical(taskid) {
	static id
	if(taskid > MaxClients)
		id = taskid - TASK_CRITICAL
	else
		id = taskid
	if(!(1 <= id <= MaxClients)) return; 
	if(!is_user_alive(id)) return; 
	if(g_critical_on[id]) {
		g_critical_on[id] = false
		remove_task(id + TASK_CRITICAL)
		task_critical(id)
		return; 
	}
	new critical = random_num(1, 100)
	if(critical <= g_critical[id]) {
		g_critical_on[id] = true
		remove_task(id+TASK_CRITICAL)
		set_task(random_float(3.0, 6.0), "task_critical", id+TASK_CRITICAL)
	} else {
		g_critical_on[id] = false
		remove_task(id+TASK_CRITICAL)
		set_task(5.0, "task_critical", id+TASK_CRITICAL)
	}
}

public show_menu_main(id) {
	static menu[256]

	formatex(menu, charsmax(menu), "\y%L^n^n", id, "MENU_MAIN")
	strcat(menu, fmt("\r1.\w %L^n", id, "MENU_MAIN_CLASS"), charsmax(menu))
	strcat(menu, fmt("\r2.\w %L^n", id, "MENU_MAIN_TEAM"), charsmax(menu))
	strcat(menu, fmt("\r3.\w %L^n", id, "MENU_MAIN_STATS"), charsmax(menu))
	strcat(menu, fmt("^n^n\r0.\w %L", id, "EXIT"), charsmax(menu))
	show_menu(id, KEYSMENU, menu, -1, "Main Menu")
	return PLUGIN_HANDLED; 
}

public menu_main(id, key)
{
	switch(key)
	{
		case 0: show_menu_class(id)
		case 1: show_menu_team(id)
		case 2: show_menu_stats(id)
	}
	return PLUGIN_HANDLED; 
}

public show_menu_class(id) {
	new class[16], willbe[16], i
	ck_get_user_classname(id, class, charsmax(class))
	ck_get_user_classname_willbe(id, willbe, charsmax(willbe))

	new const MENU_CLASS_LANG[MAX_CLASS][] = { 
		"MENU_CLASS_SCOUT", 
		"MENU_CLASS_SOLDIER", 
		"MENU_CLASS_DEMOMAN", 
		"MENU_CLASS_HEAVY", 
		"MENU_CLASS_ENGINEER", 
		"MENU_CLASS_MEDIC", 
		"MENU_CLASS_SNIPER", 
		"MENU_CLASS_PYRO", 
		"MENU_CLASS_SPY"
	}

	static menu
	menu = menu_create(fmt("\y%L^n\w%L^n%L", id, "MENU_CLASS", id, "MENU_CLASS_CURRENT", class, id, "MENU_RESPAWN_WILLBE", willbe), "menu_class")

	for(i = 0; i < MAX_CLASS; i++)
		menu_additem(menu, fmt("\w%L", id, MENU_CLASS_LANG[i], get_pcvar_num(cvar_class_hp[i]), get_pcvar_num(cvar_class_speed[i])), fmt("%d", i))

	menu_setprop(menu, MPROP_EXITNAME, fmt("%L", id, "EXIT"))
	menu_display(id, menu, 0)
	return PLUGIN_HANDLED; 
}

public menu_class(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu)
		return PLUGIN_HANDLED; 
	}
	static data[6], iName[64], access, callback, class[16]
	menu_item_getinfo(menu, item, access, data, charsmax(data), iName, charsmax(iName), callback)
	g_willbeclass[id] = str_to_num(data)
	ck_get_user_classname_willbe(id, class, charsmax(class))
	client_print_color(id, print_team_default, "^4%L ^1%L", id, "MSG_TITLE", id, "MSG_WILL_BE", class)

	menu_destroy(menu)
	return PLUGIN_HANDLED; 
}

public show_menu_team(id) {
	static menu[256]
	formatex(menu, charsmax(menu), "\y%L^n^n", id, "MENU_TEAM")
	strcat(menu, fmt("\r1.\w %L^n", id, "MENU_TEAM_RED"), charsmax(menu))
	strcat(menu, fmt("\r2.\w %L^n", id, "MENU_TEAM_BLUE"), charsmax(menu))
	strcat(menu, fmt("\r3.\w %L^n", id, "MENU_TEAM_SPECTATOR"), charsmax(menu))
	strcat(menu, fmt("^n^n\r0.\w %L", id, "EXIT"), charsmax(menu))
	show_menu(id, KEYSMENU, menu, -1, "Team Menu")
	return PLUGIN_HANDLED; 
}

public menu_team(id, key) {
	if(!is_user_connected(id))
		return PLUGIN_HANDLED
	
	static TeamName:team; team = rg_get_user_team(id)
	switch(key) {
		case 0: {
			switch(team) {
				case TEAM_UNASSIGNED, TEAM_SPECTATOR: {
					client_print(id, print_center, "%L", id, "MSG_TEAM_JOINED")
					rg_set_user_team(id, TEAM_TERRORIST)
					set_task(get_pcvar_float(cvar_global_respawn), "task_respawn", id+TASK_RESPAWN)
				}
				case TEAM_TERRORIST: client_print(id, print_center, "%L", id, "MSG_TEAM_ALREADY")
				case TEAM_CT: {
					client_print(id, print_center, "%L", id, "MSG_TEAM_JOINED")
					if(is_user_alive(id)) dllfunc(DLLFunc_ClientKill, id)
					rg_set_user_team(id, TEAM_TERRORIST)
					set_task(get_pcvar_float(cvar_global_respawn), "task_respawn", id+TASK_RESPAWN)
				}
			}
		}
		case 1: {
			switch(team) {
				case TEAM_UNASSIGNED, TEAM_SPECTATOR: {
					client_print(id, print_center, "%L", id, "MSG_TEAM_JOINED")
					rg_set_user_team(id, TEAM_CT)
					set_task(get_pcvar_float(cvar_global_respawn), "task_respawn", id+TASK_RESPAWN)
				}
				case TEAM_CT: client_print(id, print_center, "%L", id, "MSG_TEAM_ALREADY")
				case TEAM_TERRORIST:
				{
					client_print(id, print_center, "%L", id, "MSG_TEAM_JOINED")
					if(is_user_alive(id)) dllfunc(DLLFunc_ClientKill, id)
					rg_set_user_team(id, TEAM_CT)
					set_task(get_pcvar_float(cvar_global_respawn), "task_respawn", id+TASK_RESPAWN)
				}
			}
		}
		case 2: {
			switch(team) {
				case TEAM_UNASSIGNED, TEAM_SPECTATOR:  client_print(id, print_center, "%L", id, "MSG_TEAM_ALREADY")
				case TEAM_TERRORIST, TEAM_CT: {
					client_print(id, print_center, "%L", id, "MSG_TEAM_JOINED")
					if(is_user_alive(id)) dllfunc(DLLFunc_ClientKill, id)
					remove_task(id + TASK_RESPAWN, 0)
					rg_set_user_team(id, TEAM_SPECTATOR)
				}
			}
		}
		case 8: show_menu_main(id)
		case 9: return PLUGIN_HANDLED
		default: show_menu_team(id)
	}
	return PLUGIN_HANDLED; 
}

public show_menu_stats(id) {
	static menu[512]
	formatex(menu, charsmax(menu), "\y%L^n^n", id, "MENU_STATS")
	strcat(menu, fmt("\r1.\d %L %L^n", id, "MENU_STATS_KILL", g_stats[STATS_KILL][id], id, "MENU_STATS_ASSIST", g_stats[STATS_ASSIST][id]), charsmax(menu))
	strcat(menu, fmt("\r2.\d %L %L^n", id, "MENU_STATS_CAPTURE", g_stats[STATS_CAPTURE][id], id, "MENU_STATS_DEFEND", g_stats[STATS_DEFEND][id]), charsmax(menu))
	strcat(menu, fmt("\r3.\d %L %L^n", id, "MENU_STATS_DESTORY", g_stats[STATS_DESTORY][id], id, "MENU_STATS_TELEPORT", g_stats[STATS_TELEPORT][id]), charsmax(menu))
	strcat(menu, fmt("\r4.\d %L %L^n", id, "MENU_STATS_BACKSTAB", g_stats[STATS_BACKSTAB][id], id, "MENU_STATS_HEADSHOT", g_stats[STATS_HEADSHOT][id]), charsmax(menu))
	strcat(menu, fmt("\r5.\d %L^n", id, "MENU_STATS_SHIELD", g_stats[STATS_SHIELD][id]), charsmax(menu))
	new Float:timeminutes = (g_stats_lastdie[id] - g_stats_lastspawn[id]) / 60.0
	new Float:timeseconds = (g_stats_lastdie[id] - g_stats_lastspawn[id]) - timeminutes * 60.0
	strcat(menu, fmt("\r6.\d %L^n", id, "MENU_STATS_LIFETIME", timeminutes, timeseconds), charsmax(menu))
	strcat(menu, fmt("\r7.\d %L^n", id, "MENU_STATS_SCORE", g_score[id]), charsmax(menu))
	strcat(menu, fmt("\r8.\d %L^n", id, "MENU_STATS_DEATH", g_death[id]), charsmax(menu))
	strcat(menu, fmt("^n^n\r0.\w %L", id, "EXIT"), charsmax(menu))
	show_menu(id, KEYSMENU, menu, -1, "Stats Menu")
	return PLUGIN_HANDLED; 
}

public menu_stats(id, key) {
	if(!(1 <= id <= MaxClients))
		return PLUGIN_HANDLED; 
	switch(key) {
		case 8: show_menu_main(id)
		case 9: return PLUGIN_HANDLED
		default: show_menu_stats(id)
	}
	return PLUGIN_HANDLED; 
}

public show_menu_build(id) {
	if(!(1 <= id <= MaxClients))
		return PLUGIN_HANDLED; 
	if(g_class[id] != CLASS_ENGINEER)
		return PLUGIN_HANDLED; 
	if(rg_get_user_active_weapon(id) != WEAPON_C4 || g_engineer_c4[id] != TFM_TOOLBOX)
		return PLUGIN_HANDLED; 

	static menu[256]
	formatex(menu, charsmax(menu), "\y%L^n^n", id, "MENU_BUILD")
	strcat(menu, fmt("\r1. %s %L^n", g_havesentry[id] ? "\d" : "\w", id, "MENU_BUILD_1", get_pcvar_num(cvar_sentry_cost[0])), charsmax(menu))
	strcat(menu, fmt("\r2. %s %L^n", g_havedispenser[id] ? "\d" : "\w", id, "MENU_BUILD_2", get_pcvar_num(cvar_dispenser_cost[0])), charsmax(menu))
	strcat(menu, fmt("\r3. %s %L^n", g_havetelein[id] ? "\d" : "\w", id, "MENU_BUILD_3", get_pcvar_num(cvar_telein_cost)), charsmax(menu))
	strcat(menu, fmt("\r4. %s %L^n", g_haveteleout[id] ? "\d" : "\w", id, "MENU_BUILD_4", get_pcvar_num(cvar_teleout_cost)), charsmax(menu))

	strcat(menu, fmt("^n^n\r0.\w %L", id, "EXIT"), charsmax(menu))

	show_menu(id, KEYSMENU, menu, -1, "Build Menu")
	return PLUGIN_HANDLED; 
}

public menu_build(id, key) {
	if(!(1 <= id <= MaxClients))
		return PLUGIN_HANDLED; 
	if(g_class[id] != CLASS_ENGINEER)
		return PLUGIN_HANDLED; 
	if(rg_get_user_active_weapon(id) != WEAPON_C4 || g_engineer_c4[id] != TFM_TOOLBOX)
		return PLUGIN_HANDLED; 
	switch(key)
	{
		case 0: sentry_build(id); 
		case 1: dispenser_build(id); 
		case 2: telein_build(id); 
		case 3: teleout_build(id); 
		case 9: return PLUGIN_HANDLED; 
	}
	show_menu_build(id)
	return PLUGIN_HANDLED; 
}

public show_menu_demolish(id) {
	if(!(1 <= id <= MaxClients))
		return PLUGIN_HANDLED; 
	if(g_class[id] != CLASS_ENGINEER)
		return PLUGIN_HANDLED; 
	if(rg_get_user_active_weapon(id) != WEAPON_C4 || g_engineer_c4[id] != TFM_PDA)
		return PLUGIN_HANDLED; 

	static menu[256]
	formatex(menu, charsmax(menu), "\y%L^n^n", id, "MENU_DEMOLISH")
	strcat(menu, fmt("\r1.%s %L^n", !g_havesentry[id] ? "\d" : "\w", id, "MENU_DEMOLISH_1"), charsmax(menu))
	strcat(menu, fmt("\r2.%s %L^n", !g_havedispenser[id] ? "\d" : "\w", id, "MENU_DEMOLISH_2"), charsmax(menu))
	strcat(menu, fmt("\r3.%s %L^n", !g_havetelein[id] ? "\d" : "\w", id, "MENU_DEMOLISH_3"), charsmax(menu))
	strcat(menu, fmt("\r4.%s %L^n", !g_haveteleout[id] ? "\d" : "\w", id, "MENU_DEMOLISH_4"), charsmax(menu))
	strcat(menu, fmt("^n^n\r0.\w %L", id, "EXIT"), charsmax(menu))

	show_menu(id, KEYSMENU, menu, -1, "Demolish Menu")
	return PLUGIN_HANDLED; 
}

public menu_demolish(id, key) {
	if(!(1 <= id <= MaxClients))
		return PLUGIN_HANDLED; 
	if(g_class[id] != CLASS_ENGINEER)
		return PLUGIN_HANDLED; 
	if(rg_get_user_active_weapon(id) != WEAPON_C4 || g_engineer_c4[id] != TFM_PDA)
		return PLUGIN_HANDLED; 

	switch(key) {
		case 0: {
			if(g_havesentry[id])
				ck_sentry_destory(id)
			else
				client_print_color(id, print_team_default, "^4%L ^1%L", id, "MSG_TITLE", id, "MSG_BUILD_DONTHAVE")
		}
		case 1:	{
			if(g_havedispenser[id])
				ck_dispenser_destory(id)
			else
				client_print_color(id, print_team_default, "^4%L ^1%L", id, "MSG_TITLE", id, "MSG_BUILD_DONTHAVE")
		}
		case 2:	{
			if(g_havetelein[id])
				ck_telein_destory(id, 0)
			else
				client_print_color(id, print_team_default, "^4%L ^1%L", id, "MSG_TITLE", id, "MSG_BUILD_DONTHAVE")
		}
		case 3:	{
			if(g_haveteleout[id])
				ck_teleout_destory(id, 0)
			else
				client_print_color(id, print_team_default, "^4%L ^1%L", id, "MSG_TITLE", id, "MSG_BUILD_DONTHAVE")
		}
		case 9:return PLUGIN_HANDLED
	}
	show_menu_demolish(id)
	return PLUGIN_HANDLED; 
}

public CBasePlayer_Spawn(id)
{
	if(!is_user_alive(id))
		return; 
	
	if(!g_delay_spawned[id])
	{
		g_delay_spawned[id] = 1
		g_spawntime += SPAWN_DELAY
		if(g_spawntime > 10.0) g_spawntime = 10.0
		remove_task(id+TASK_SPAWN, 0)
		set_task(g_spawntime, "task_spawn", id+TASK_SPAWN)
		if(!is_user_bot(id)) show_menu_main(id)
	}
	else
	{
		set_task(0.1, "task_spawn", id+TASK_SPAWN)
	}
}

public task_spawn(taskid) {
	static id, TeamName:team
	if(taskid > MaxClients)
		id = taskid - TASK_SPAWN
	else
		id = taskid
	if(!is_user_connected(id)) return; 

	team = rg_get_user_team(id);
	if(!is_user_alive(id) || team == TEAM_SPECTATOR || team == TEAM_UNASSIGNED) return; 
	client_cmd(id, "stopsound")
	g_class[id] = g_willbeclass[id]
	formatex(g_curmodel[id], charsmax(g_curmodel[]), "%s", ClassConfig[g_class[id]][PlayerModel])

	set_pev(id, pev_effects, (pev(id, pev_effects) & ~EF_NODRAW))
	
	if(g_class[id] != CLASS_ENGINEER) {
		ck_sentry_destory(id)
		ck_dispenser_destory(id)
		ck_telein_destory(id, 1)
		ck_teleout_destory(id, 1)
	}
	set_task(HUD_REFRESH, "ck_showhud_status", id+TASK_SHOWHUD)
	set_task(CENTER_REFRESH, "ck_showhud_center", id+TASK_SHOWCENTER)
	set_task(PLAYER_THINK, "think_Player", id+TASK_PLAYER_THINK)
	set_task(1.5, "task_critical", id+TASK_CRITICAL)
	
	rg_remove_item(id, "weapon_c4")
	rg_give_item(id, "weapon_knife")
	rg_give_item(id, "weapon_m3")
	rg_give_item(id, "weapon_p228")

	switch(g_class[id])
	{
		case CLASS_SCOUT:
		{
			g_scattergun_clip[id] = get_pcvar_num(cvar_scattergun_clip)
			g_scattergun_ammo[id] = get_pcvar_num(cvar_scattergun_ammo)
			rg_set_user_ammo(id, WEAPON_M3, g_scattergun_clip[id])
			rg_set_user_bpammo(id, WEAPON_M3, g_scattergun_ammo[id])

			g_usp_clip[id] = get_pcvar_num(cvar_usp_clip)
			g_usp_ammo[id] = get_pcvar_num(cvar_usp_ammo)
			rg_set_user_ammo(id, WEAPON_P228, g_usp_clip[id])
			rg_set_user_bpammo(id, WEAPON_P228, g_usp_ammo[id])
		}
		case CLASS_SOLDIER:
		{
			g_rocket_clip[id] = get_pcvar_num(cvar_rocket_clip)
			g_rocket_ammo[id] = get_pcvar_num(cvar_rocket_ammo)
			rg_set_user_ammo(id, WEAPON_M3, g_rocket_clip[id])
			rg_set_user_bpammo(id, WEAPON_M3, g_rocket_ammo[id])

			g_shotgun_clip[id] = get_pcvar_num(cvar_shotgun_clip)
			g_shotgun_ammo[id] = get_pcvar_num(cvar_shotgun_ammo)
			rg_set_user_ammo(id, WEAPON_P228, g_shotgun_clip[id])
			rg_set_user_bpammo(id, WEAPON_P228, g_shotgun_ammo[id])
		}
		case CLASS_DEMOMAN:
		{
			g_grenade_clip[id] = get_pcvar_num(cvar_grenade_clip)
			g_grenade_ammo[id] = get_pcvar_num(cvar_grenade_ammo)
			rg_set_user_ammo(id, WEAPON_M3, g_grenade_clip[id])
			rg_set_user_bpammo(id, WEAPON_M3, g_grenade_ammo[id])

			g_stickybomb_clip[id] = get_pcvar_num(cvar_stickybomb_clip)
			g_stickybomb_ammo[id] = get_pcvar_num(cvar_stickybomb_ammo)
			rg_set_user_ammo(id, WEAPON_P228, g_stickybomb_clip[id])
			rg_set_user_bpammo(id, WEAPON_P228, g_stickybomb_ammo[id])

			g_stickybomb_num[id] = 0
		}
		case CLASS_HEAVY:
		{
			g_minigun_clip[id] = get_pcvar_num(cvar_minigun_clip)
			rg_set_user_ammo(id, WEAPON_M3, 0)
			rg_set_user_bpammo(id, WEAPON_M3, g_minigun_clip[id])

			g_shotgun_clip[id] = get_pcvar_num(cvar_shotgun_clip)
			g_shotgun_ammo[id] = get_pcvar_num(cvar_shotgun_ammo)
			rg_set_user_ammo(id, WEAPON_P228, g_shotgun_clip[id])
			rg_set_user_bpammo(id, WEAPON_P228, g_shotgun_ammo[id])
		}
		case CLASS_ENGINEER:
		{
			rg_give_item(id, "weapon_c4")
			g_shotgun_clip[id] = get_pcvar_num(cvar_shotgun_clip)
			g_shotgun_ammo[id] = get_pcvar_num(cvar_shotgun_ammo)
			rg_set_user_ammo(id, WEAPON_M3, g_shotgun_clip[id])
			rg_set_user_bpammo(id, WEAPON_M3, g_shotgun_ammo[id])

			g_usp_clip[id] = get_pcvar_num(cvar_usp_clip)
			g_usp_ammo[id] = get_pcvar_num(cvar_usp_ammo)
			rg_set_user_ammo(id, WEAPON_P228, g_usp_clip[id])
			rg_set_user_bpammo(id, WEAPON_P228, g_usp_ammo[id])

			g_engineer_c4[id] = TFM_TOOLBOX
			g_engineer_metal[id] = 100
			rg_set_user_bpammo(id, WEAPON_C4, 100)
		}
		case CLASS_MEDIC:
		{
			g_medic_charge[id] = 0.0
			rg_set_user_ammo(id, WEAPON_M3, 0)
			rg_set_user_bpammo(id, WEAPON_M3, floatround(g_medic_charge[id]))

			g_syringegun_clip[id] = get_pcvar_num(cvar_syringegun_clip)
			g_syringegun_ammo[id] = get_pcvar_num(cvar_syringegun_ammo)
			rg_set_user_ammo(id, WEAPON_P228, g_syringegun_clip[id])
			rg_set_user_bpammo(id, WEAPON_P228, g_syringegun_ammo[id])
		}
		case CLASS_SNIPER:
		{
			g_awp_clip[id] = get_pcvar_num(cvar_awp_clip)
			g_awp_ammo[id] = get_pcvar_num(cvar_awp_ammo)
			rg_set_user_ammo(id, WEAPON_P228, g_awp_clip[id])
			rg_set_user_bpammo(id, WEAPON_P228, g_awp_ammo[id])

			g_smg_clip[id] = get_pcvar_num(cvar_smg_clip)
			g_smg_ammo[id] = get_pcvar_num(cvar_smg_ammo)
			rg_set_user_ammo(id, WEAPON_P228, g_smg_clip[id])
			rg_set_user_bpammo(id, WEAPON_P228, g_smg_ammo[id])
			
		}
		case CLASS_PYRO:
		{
		}
		case CLASS_SPY:
		{
		}
	}

	g_speed[id] = get_pcvar_num(cvar_class_speed[g_class[id]])
	fm_set_user_health(id, get_pcvar_num(cvar_class_hp[g_class[id]]))
	if(g_curmodel[id][0]) cs_set_user_model(id, g_curmodel[id])
	set_entvar(id, var_skin, (team == TEAM_TERRORIST) ? TF2_RED : TF2_BLUE)
	g_critkilled[id] = 0
	g_stats_lastspawn[id] = 0.0
	g_nodamage[id] = 1
	g_noweapon[id] = 0
	g_critical[id] = get_pcvar_num(cvar_critical_percent)
	g_jumping[id] = false
	g_cansecondjump[id] = false
	g_secondjump[id] = false
	set_task(SPAWN_PROTECT, "task_spawn_protect", id)
	FX_UpdateScore(id)
}

public event_round_start() {
	g_round = round_setup
	set_task(1.0, "round_timer", TASK_ROUND_TIMER)
	static ent, i

	for(i = 1; i <= MaxClients; i++) {
		ck_sentry_destory(i)
		ck_dispenser_destory(i)
		ck_telein_destory(i, 1)
		ck_teleout_destory(i, 1)
	}
	switch(g_gamemode) {
		case mode_normal: {
			g_roundtime = get_pcvar_num(cvar_roundtime_default)
			g_setuptime = 30
		}
		case mode_capture: {
			g_roundtime = get_pcvar_num(cvar_roundtime_capture)
			g_setuptime = 30

			for(i = 0; i < g_cp_pointnums[TF2_RED]; i++)
				g_cp_progress[TF2_RED][i] = 0
			for(i = 0; i < g_cp_pointnums[TF2_BLUE]; i++)
				g_cp_progress[TF2_BLUE][i] = 0
 			g_cp_local[TF2_RED] = 0
			g_cp_local[TF2_BLUE] = 0
		}
		case mode_ctflag: {
			g_roundtime = get_pcvar_num(cvar_roundtime_ctflag)
			g_setuptime = 30
		}
		case mode_payload: {
			g_roundtime = get_pcvar_num(cvar_roundtime_payload)
			g_setuptime = 30
		}
	}
	
	for (i = 0; i < sizeof g_EntityClassnames; i++)
		while ((ent = engfunc(EngFunc_FindEntityByString, ent, "classname", g_EntityClassnames[i])) != 0)
			engfunc(EngFunc_RemoveEntity, ent)

	format(g_text3, charsmax(g_text3), "")
	format(g_text2, charsmax(g_text2), "")
	format(g_text1, charsmax(g_text1), "")
}

public event_round_end() {
	if(g_round == round_end) return; 
	g_round = round_end
	g_cp_local[TF2_RED] = 0
	g_cp_local[TF2_BLUE] = 0
	g_spawntime = 0.0
	server_cmd("sv_restart 10")
	set_task(1.0, "round_timer", TASK_ROUND_TIMER)
	for(new i = 1; i <= MaxClients; i++) {
		g_delay_spawned[i] = 0
	}
	if(g_gamemode == mode_normal && (g_score_team[TF2_RED] > 100 || g_score_team[TF2_BLUE] > 100))
		server_cmd("amx_map %s", g_mapname)
}
public end_round(team) {
	if(g_round == round_end) return; 

	static TeamName:userTeam, i
	g_text3 = ""; 
	g_text2 = ""; 

	if(team == WIN_RED || team == WIN_BLUE) {
		format(g_text1, charsmax(g_text1), "%L", LANG_PLAYER, team == WIN_RED  ? "MSG_WIN_RED" : "MSG_WIN_BLUE")
		for(i = 1; i <= MaxClients; i++) {
			if(!is_user_connected(i))
				continue; 

			userTeam = rg_get_user_team(i); 
			if(userTeam == TEAM_TERRORIST && team == WIN_RED || userTeam == TEAM_CT && team == WIN_BLUE) {
				PlaySound(i, Snd_win)
				g_critical_on[i] = true
				g_critical[i] = 100
			}
			else {
				PlaySound(i, Snd_lose)
				fm_strip_user_weapons(i)
				g_noweapon[i] = 1
			}
		}
	}
	event_round_end()
}

public task_spawn_protect(id) {
	g_nodamage[id] = 0
}

public client_putinserver(id)
{
	ck_reset_user_var(id)
	client_cmd(id, "cl_minmodels 0")
	client_cmd(id, "cl_shadows 1")
	set_task(HUD_REFRESH, "ck_showhud_status", id+TASK_SHOWHUD)
	set_task(CENTER_REFRESH, "ck_showhud_center", id+TASK_SHOWCENTER)
	set_task(PLAYER_THINK, "think_Player", id+TASK_PLAYER_THINK)
}

public client_connect(id) {
	for(new i = 0; i < MAX_STATS; i++) 
		g_stats[i][id] = 0

	g_stats_lastdie[id] = 0.0
	g_stats_lastspawn[id] = 0.0
	g_join_spawned[id] = 0
	g_delay_spawned[id] = 0
}

public client_disconnected(id)
{
	for(new i = 0; i < g_stickybomb_num[id]; i++)
	{
		if(pev_valid(g_stickybomb_entity[id][i]))
			set_pev(g_stickybomb_entity[id][i], pev_flags, pev(g_stickybomb_entity[id][i], pev_flags) | FL_KILLME)
	}

	ck_sentry_destory(id)
	ck_dispenser_destory(id)
	ck_telein_destory(id, 1)
	ck_teleout_destory(id, 1)
	set_task(0.5, "check_end")
}

public fw_Jump(id) {
	if(!is_user_alive(id))
		return HAM_IGNORED
	static buttons, flags, Float:velocity[3]
	buttons = pev(id, pev_button)
	flags = pev(id, pev_flags)
	pev(id, pev_velocity, velocity)
	if(!g_jumping[id] && !(flags & FL_ONGROUND)) {
		g_cansecondjump[id] = false
		g_jumping[id] = true
	}
	if(g_jumping[id] && !g_secondjump[id] && g_cansecondjump[id] && (buttons & IN_JUMP)) {
		if(g_class[id] == CLASS_SCOUT) {
			static Float:targetOrigin[3], Float:id_origin[3], Float:fw, Float:rg
			pev(id, pev_origin, id_origin)
			if(buttons & IN_FORWARD) {
				fw += 100.0
			}else if(buttons & IN_BACK) {
				fw -= 100.0
			}if(buttons & IN_MOVELEFT) {
				rg -= 100.0
			}else if(buttons & IN_MOVERIGHT) {
				rg += 100.0
			}
			ck_get_user_startpos(id, fw, rg, 0.0, targetOrigin)
			if(rg == 0.0 && fw == 0.0) {
				velocity[0] = 0.0
				velocity[1] = 0.0
			} else {
				get_speed_vector(id_origin, targetOrigin, float(g_speed[id]), velocity)
			}
			velocity[2] = 256.0
			set_pev(id, pev_velocity, velocity)
			g_secondjump[id] = true
			g_cansecondjump[id] = false
		}
	}
	return HAM_IGNORED
}

public fw_CmdStart(id, uc_handle, seed) {
	if(!is_user_alive(id))
		return FMRES_IGNORED
	static Float:GameTime, WeaponIdType:wpn, buttons, oldbuttons, Float:rof
	wpn = rg_get_user_active_weapon(id)
	buttons = get_uc(uc_handle, UC_Buttons)
	oldbuttons = pev(id, pev_oldbuttons)

	GameTime = get_gametime()

	if(g_noweapon[id])
	{
		buttons &= ~IN_ATTACK
		buttons &= ~IN_ATTACK2
		buttons &= ~IN_RELOAD
		set_uc(uc_handle, UC_Buttons, buttons)
		return FMRES_IGNORED
	}

	new players[32], team_count, tid, bool:print = false;

	switch( cs_get_user_team(id) )
	{
		case CS_TEAM_T: { get_players(players, team_count, "aec", "TERRORIST" ); print = true; }
		case CS_TEAM_CT: { get_players(players, team_count, "aec", "CT" ); print = true; }
	}
	if((buttons & IN_USE) && !(oldbuttons & IN_USE))
	{
		switch(g_class[id])
		{
			case CLASS_SCOUT:
			{
				if( print )
				{
					for( new i; i < team_count; i++)
					{
						tid = players[i];
						
						client_cmd(tid, "spk ^"%s^"", radio_scout_medic[random_num(0,2)])
						client_print_color(tid, print_team_default, "^3(Voz) %n^1: MEDIC!", id)
					}
				}
			}
			case CLASS_SOLDIER:
			{
				if( print )
				{
					for( new i; i < team_count; i++)
					{
						tid = players[i];
						
						client_cmd(tid, "spk ^"%s^"", radio_soldier_medic[random_num(0,2)])
						client_print_color(tid, print_team_default, "^3(Voz) %n^1: MEDIC!", id)
					}
				}
			}
			case CLASS_DEMOMAN:
			{
				if( print )
				{
					for( new i; i < team_count; i++)
					{
						tid = players[i];
						
						client_cmd(tid, "spk ^"%s^"", radio_demoman_medic[random_num(0,2)])
						client_print_color(tid, print_team_default, "^3(Voz) %n^1: MEDIC!", id)
					}
				}
			}
			case CLASS_HEAVY:
			{
				if( print )
				{
					for( new i; i < team_count; i++)
					{
						tid = players[i];
						
						client_cmd(tid, "spk ^"%s^"", radio_heavy_medic[random_num(0,2)])
						client_print_color(tid, print_team_default, "^3(Voz) %n^1: MEDIC!", id)
					}
				}
			}
			case CLASS_ENGINEER:
			{
				if( print )
				{
					for( new i; i < team_count; i++)
					{
						tid = players[i];
						
						client_cmd(tid, "spk ^"%s^"", radio_engineer_medic[random_num(0,2)])
						client_print_color(tid, print_team_default, "^3(Voz) %n^1: MEDIC!", id)
					}
				}
			}
			case CLASS_MEDIC:
			{
				if( print )
				{
					for( new i; i < team_count; i++)
					{
						tid = players[i];
						
						client_cmd(tid, "spk ^"%s^"", radio_medic_medic[random_num(0,2)])
						client_print_color(tid, print_team_default, "^3(Voz) %n^1: MEDIC!", id)
					}
				}
			}
			case CLASS_SNIPER:
			{
				if( print )
				{
					for( new i; i < team_count; i++)
					{
						tid = players[i];
						
						client_cmd(tid, "spk ^"%s^"", radio_sniper_medic[random_num(0,1)])
						client_print_color(tid, print_team_default, "^3(Voz) %n^1: MEDIC!", id)
					}
				}
			}
			case CLASS_PYRO:
			{
				if( print )
				{
					for( new i; i < team_count; i++)
					{
						tid = players[i];
						
						client_cmd(tid, "spk ^"%s^"", radio_pyro_medic[0])
						client_print_color(tid, print_team_default, "^3(Voz) %n^1: MEDIC!", id)
					}
				}
			}
			case CLASS_SPY:
			{
				if( print )
				{
					for( new i; i < team_count; i++)
					{
						tid = players[i];
						
						client_cmd(tid, "spk ^"%s^"", radio_spy_medic[random_num(0,2)])
						client_print_color(tid, print_team_default, "^3(Voz) %n^1: MEDIC!", id)
					}
				}
			}
		}
	
	}
	if(wpn == WEAPON_M3) {
		switch(g_class[id]) {
			case CLASS_SCOUT: { // Scattergun
				if(buttons & IN_ATTACK)
				{
					rof = get_pcvar_float(cvar_scattergun_rof)
					if(g_scattergun_time[id] + rof < GameTime)
					{
						wpn_scattergun_shoot(id)
					}
					if(g_scattergun_status[id] == scattergun_reload_loop && g_scattergun_clip[id])
					{
						wpn_scattergun_shoot(id)
						g_scattergun_status[id] = scattergun_idle
					}
				}
				if(buttons & IN_RELOAD || !g_scattergun_clip[id])
				{
					wpn_scattergun_reload_start(id)
				}
			}
			// minigun heavy
			case CLASS_HEAVY:
			{ 
				if(buttons & IN_ATTACK && g_minigun_status[id] == minigun_spool_idle)
				{
					rof = get_pcvar_float(cvar_minigun_rof)
					if(g_minigun_time[id] + rof < GameTime)
						wpn_minigun_shoot(id)
				}
				if(buttons & IN_ATTACK2)
				{
					switch(g_minigun_status[id])
					{
						case minigun_idle:
						{
							g_minigun_status[id] = minigun_spool_up
							g_minigun_spindelay[id] = GameTime + get_pcvar_float(cvar_minigun_spinup)
							fm_set_user_anim(id, anim_minigun_spool_up)
							engfunc(EngFunc_EmitSound, id, CHAN_WEAPON, Snd_minigun_spinup, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
						}
						case anim_minigun_spool_up:
						{
							if(g_minigun_spindelay[id] < GameTime)
							{
								g_minigun_status[id] = minigun_spool_idle
								fm_set_user_anim(id, anim_minigun_spool_idle)
								engfunc(EngFunc_EmitSound, id, CHAN_WEAPON, Snd_minigun_spining, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
							}
						}
						case anim_minigun_spool_down:
						{
							if(g_minigun_spindelay[id] < GameTime)
							{
								g_minigun_status[id] = minigun_idle
								fm_set_user_anim(id, anim_minigun_idle)
							}
						}
						case anim_minigun_spool_idle:
						{
							if(g_minigun_spindelay[id] < GameTime)
							{
								g_minigun_status[id] = minigun_spool_idle
								g_minigun_spindelay[id] = GameTime + get_pcvar_float(cvar_minigun_spining)
								fm_set_user_anim(id, anim_minigun_spool_idle)
								engfunc(EngFunc_EmitSound, id, CHAN_WEAPON, Snd_minigun_spining, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
							}
						}
					}
				}
			}
			case CLASS_SOLDIER: {
				if(buttons & IN_ATTACK)
				{
					rof = get_pcvar_float(cvar_rocket_rof)
					if(g_rocket_time[id] + rof < GameTime)
					{
						wpn_rocket_shoot(id)
					}
					if(g_rocket_status[id] == rocket_reload && g_rocket_clip[id])
					{
						wpn_rocket_shoot(id)
						g_rocket_status[id] = rocket_idle
					}
				}
				if(buttons & IN_RELOAD || !g_rocket_clip[id])
				{
					wpn_rocket_reload_start(id)
				}
			}
			case CLASS_MEDIC:
			{
				if(!(buttons & IN_ATTACK) && g_medicgun_using[id])
				{
					g_medicgun_using[id] = 0
					g_healed_by[g_medicgun_target[id]] = 0
					g_medicgun_target[id] = 0
				}
				else if(buttons & IN_ATTACK)
				{
					new target, bodypart
					get_user_aiming(id, target, bodypart)
					if(is_user_alive(target))
					{
						new Float:id_origin[3], Float:target_origin[3]
						pev(id, pev_origin, id_origin)
						pev(target, pev_origin, target_origin)
						new Float:distance = vector_distance(id_origin, target_origin)
						if(distance <= get_pcvar_float(cvar_medicgun_range))
						{
							if(!g_medicgun_using[id] && isSameTeam(id, target))
							{
								g_medicgun_target[id] = target
								g_medicgun_using[id] = 1
								engfunc(EngFunc_EmitSound, id, CHAN_WEAPON, Snd_medicgun_heal, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
								remove_task(id+TASK_MEDICGUN, 0)
								set_task(get_pcvar_float(cvar_medicgun_rof), "wpn_medicgun_heal", id+TASK_MEDICGUN)
							}
						}
					}
				}
				if(buttons & IN_ATTACK2)
				{
					wpn_medicgun_charge(id)
				}
			}
			case CLASS_ENGINEER:
			{
				if(buttons & IN_ATTACK)
				{
					rof = get_pcvar_float(cvar_shotgun_rof)
					if(g_shotgun_time[id] + rof < GameTime)
					{
						wpn_shotgun_shoot(id)
					}
					if(g_shotgun_status[id] == shotgun_reload_loop && g_shotgun_clip[id])
					{
						wpn_shotgun_shoot(id)
						g_shotgun_status[id] = shotgun_idle
					}
				}
				if(buttons & IN_RELOAD || !g_shotgun_clip[id])
				{
					wpn_shotgun_reload_start(id)
				}
			}
			// grenade Launcher demoman
			case CLASS_DEMOMAN:
			{ 
				if(buttons & IN_ATTACK)
				{
					rof = get_pcvar_float(cvar_grenade_rof)
					if(g_grenade_time[id] + rof < GameTime)
					{
						wpn_grenade_shoot(id)
					}
					if(g_grenade_status[id] == grenade_reload && g_grenade_clip[id])
					{
						wpn_grenade_shoot(id)
						g_shotgun_status[id] = grenade_idle
					}
				}
				if(buttons & IN_RELOAD || !g_grenade_clip[id])
				{
					wpn_grenade_reload_start(id)
				}
			}
			// sniper rifle sniper
			case CLASS_SNIPER:
			{
				if((buttons & IN_ATTACK) && !(oldbuttons & IN_ATTACK))
				{
					fm_set_user_anim(id, anim_sniper_rifle_fire)
					engfunc(EngFunc_EmitSound, id, CHAN_WEAPON, Snd_sniper_shoot, 1.0, ATTN_NORM, 0, PITCH_NORM)
				}
			}
		}
	}
	if(wpn == WEAPON_P228)
	{
		switch(g_class[id])
		{
			// pistol scout
			case CLASS_SCOUT:
			{
				if((buttons & IN_ATTACK) && !(oldbuttons & IN_ATTACK))
				{
					fm_set_user_anim(id, pistol_scout_fire1)
					engfunc(EngFunc_EmitSound, id, CHAN_WEAPON, Snd_pistol_scout_shoot, 1.0, ATTN_NORM, 0, PITCH_NORM)
				}
			}
			// shotgun heavy/soldier
			case CLASS_HEAVY, CLASS_SOLDIER:
			{ 
				if(buttons & IN_ATTACK)
				{
					rof = get_pcvar_float(cvar_shotgun_rof)
					if(g_shotgun_time[id] + rof < GameTime)
					{
						wpn_shotgun_shoot(id)
					}
					if(g_shotgun_status[id] == shotgun_reload_loop && g_shotgun_clip[id])
					{
						wpn_shotgun_shoot(id)
						g_shotgun_status[id] = shotgun_idle
					}
				}
				if(buttons & IN_RELOAD || !g_shotgun_clip[id])
				{
					wpn_shotgun_reload_start(id)
				}
			}
			// smg sniper
			case CLASS_SNIPER:
			{
				if(buttons & IN_ATTACK)
				{
					rof = get_pcvar_float(cvar_smg_rof)
					if(g_smg_time[id] + rof < GameTime)
						wpn_smg_shoot(id)
				}
				if(buttons & IN_RELOAD || !g_smg_clip[id])
				{
					wpn_smg_reload_start(id)
				}
			}
			// syringegun medic
			case CLASS_MEDIC:
			{ 
				if(buttons & IN_ATTACK)
				{
					rof = get_pcvar_float(cvar_syringegun_rof)
					if(g_syringegun_time[id] + rof < GameTime)
						wpn_syringegun_shoot(id)
				}
				if(buttons & IN_RELOAD || !g_syringegun_clip[id])
				{
					wpn_syringegun_reload_start(id)
				}
			}
			// stickybomb launcher demoman
			case CLASS_DEMOMAN:
			{ 
				if(!(buttons & IN_ATTACK) && g_stickybomb_status[id] == sb_auto_fire)
				{
					wpn_stickybomb_shoot(id)
					g_stickybomb_charge[id] = 0.0
				}
				if(buttons & IN_ATTACK)
				{
				 	switch(g_stickybomb_status[id])
					{
						case sb_idle: {
							rof = get_pcvar_float(cvar_stickybomb_rof)
							if(g_stickybomb_time[id] + rof < GameTime)
							{
								g_stickybomb_time[id] = GameTime
								g_stickybomb_status[id] = sb_auto_fire
								g_stickybomb_charge[id] += get_pcvar_float(cvar_stickybomb_chargerate)
								engfunc(EngFunc_EmitSound, id, CHAN_WEAPON, Snd_stickybomb_charge, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
							}
						}
						case sb_auto_fire:
						{
							if(g_stickybomb_time[id] + 0.1 < GameTime)
							{
								g_stickybomb_charge[id] += get_pcvar_float(cvar_stickybomb_chargerate)
								g_stickybomb_time[id] = GameTime
							}
							if(g_stickybomb_charge[id] >= 100.0)
							{
								wpn_stickybomb_shoot(id)
								g_stickybomb_charge[id] = 0.0
							}
						}
						case sb_reload_loop:
						{
							if(g_stickybomb_clip[id])
							{
								g_stickybomb_status[id] = sb_auto_fire
								g_stickybomb_charge[id] += get_pcvar_float(cvar_stickybomb_chargerate)
								engfunc(EngFunc_EmitSound, id, CHAN_WEAPON, Snd_stickybomb_charge, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
							}
						}
					}
				}
				if(buttons & IN_ATTACK2)
				{
					rof = get_pcvar_float(cvar_stickybomb_rof)
					if(g_stickybomb_time[id] + rof < GameTime)
					{
						wpn_stickybomb_det(id)
					}
					if(g_stickybomb_status[id] == sb_reload_start)
					{
						wpn_stickybomb_det(id)
						g_stickybomb_status[id] = sb_idle
					}
				}
				if(buttons & IN_RELOAD || !g_stickybomb_clip[id])
				{
					wpn_stickybomb_reload_start(id)
				}
			}
		}
	}
	else if(buttons & IN_RELOAD && (wpn == WEAPON_AWP))
	{
		if(rg_get_user_ammo(id, WEAPON_AWP) >= get_pcvar_num(cvar_awp_clip))
		{
			buttons &= ~IN_RELOAD
			set_uc(uc_handle, UC_Buttons, buttons)
		}
	}
	else if(buttons & IN_RELOAD && (wpn == WEAPON_P228))
	{
		if(rg_get_user_ammo(id, WEAPON_P228) >= get_pcvar_num(cvar_usp_clip))
		{
			buttons &= ~IN_RELOAD
			set_uc(uc_handle, UC_Buttons, buttons)
		}
	}
	else if((buttons & IN_ATTACK2) && !(oldbuttons & IN_ATTACK2) && (wpn == WEAPON_C4))
	{
		wpn_toolbox_switch(id)
	}
	return FMRES_IGNORED
}

public fw_PreThink(id) {
	if(!is_user_alive(id)) return; 
	static Float:GameTime, WeaponIdType:wpn, buttons, flags; 
	buttons = pev(id, pev_button)
	flags = pev(id, pev_flags)
	set_pev(id, pev_maxspeed, float(g_speed[id]))
	if(flags & FL_ONGROUND) {
		g_jumping[id] = false
		g_secondjump[id] = false
		g_cansecondjump[id] = false
	}
	if(g_jumping[id]) {
		if(!(buttons & IN_JUMP) && !g_cansecondjump[id])
			g_cansecondjump[id] = true
	}
	wpn = rg_get_user_active_weapon(id)
	GameTime = get_gametime(); 
	if(wpn == WEAPON_M3) {
		switch(g_class[id]) {
			case CLASS_SCOUT: {
				switch(g_scattergun_status[id]) {
					case scattergun_draw: {
						if(g_scattergun_time[id] + get_pcvar_float(cvar_scattergun_draw) < GameTime)
							wpn_scattergun_draw(id)
					}
					case scattergun_reload_loop: {
						if(g_scattergun_time[id] + get_pcvar_float(cvar_scattergun_reload) < GameTime)
							wpn_scattergun_reload_end(id)
					}
				}
			}
			case CLASS_HEAVY: {
				if(g_minigun_status[id] == minigun_draw) {
					if(g_minigun_time[id] + get_pcvar_float(cvar_minigun_draw) < GameTime)
						wpn_minigun_draw(id)
				} else if(g_minigun_status[id] != minigun_idle) {
					g_speed[id] = get_pcvar_num(cvar_class_speed[CLASS_HEAVY])
				} else {
					g_speed[id] = get_pcvar_num(cvar_class_speed[CLASS_HEAVY])
				}
				if(!(buttons & IN_ATTACK2)) {
					switch(g_minigun_status[id]) {
						case minigun_spool_idle: {
							g_minigun_status[id] = minigun_spool_down
							g_minigun_spindelay[id] = GameTime + get_pcvar_float(cvar_minigun_spindown)
							g_speed[id] = get_pcvar_num(cvar_class_speed[CLASS_HEAVY])
							fm_set_user_anim(id, anim_minigun_spool_down)
							engfunc(EngFunc_EmitSound, id, CHAN_WEAPON, Snd_minigun_spindown, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
						}
						case minigun_spool_up: {
							if(g_minigun_spindelay[id] < GameTime) {
								g_minigun_status[id] = minigun_spool_down
								g_minigun_spindelay[id] = GameTime + get_pcvar_float(cvar_minigun_spindown)
								g_speed[id] = get_pcvar_num(cvar_class_speed[CLASS_HEAVY])
								fm_set_user_anim(id, anim_minigun_spool_down)
								engfunc(EngFunc_EmitSound, id, CHAN_WEAPON, Snd_minigun_spindown, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
							}
						}
						case minigun_spool_down: {
							if(g_minigun_spindelay[id] < GameTime) {
								g_minigun_status[id] = minigun_idle
								g_speed[id] = get_pcvar_num(cvar_class_speed[CLASS_HEAVY])
								fm_set_user_anim(id, anim_minigun_idle)
							}
						}
					}
				}// !attack2
			}// case class_heavy
			case CLASS_SOLDIER: {
				switch(g_rocket_status[id]) {
					case rocket_draw: {
						if(g_rocket_time[id] + get_pcvar_float(cvar_rocket_draw) < GameTime)
							wpn_rocket_draw(id)
					}
					case rocket_reload: {
						if(g_rocket_time[id] + get_pcvar_float(cvar_rocket_reload) < GameTime)
							wpn_rocket_reload_end(id)
					}
				}
			}
			case CLASS_ENGINEER: {
				switch(g_shotgun_status[id]) {
					case shotgun_draw: {
						if(g_shotgun_time[id] + get_pcvar_float(cvar_shotgun_draw) < GameTime)
							wpn_shotgun_draw(id)
					}
					case shotgun_reload_loop: {
						if(g_shotgun_time[id] + get_pcvar_float(cvar_shotgun_reload) < GameTime)
							wpn_shotgun_reload_end(id)
					}
				}
			}
			case CLASS_DEMOMAN: {
				switch(g_grenade_status[id]) {
					case grenade_draw: {
						if(g_grenade_time[id] + get_pcvar_float(cvar_grenade_draw) < GameTime)
							wpn_grenade_draw(id)
					}
					case grenade_reload: {
						if(g_grenade_time[id] + get_pcvar_float(cvar_grenade_reload) < GameTime)
							wpn_grenade_reload_end(id)
					}
				}
			}
		}
	} else if(wpn == WEAPON_P228) {
		switch(g_class[id]) {
			case CLASS_SOLDIER, CLASS_HEAVY: {
				switch(g_shotgun_status[id]) {
					case shotgun_draw: {
						if(g_shotgun_time[id] + get_pcvar_float(cvar_shotgun_draw) < GameTime)
							wpn_shotgun_draw(id)
					}
					case shotgun_reload_loop: {
						if(g_shotgun_time[id] + get_pcvar_float(cvar_shotgun_reload) < GameTime)
							wpn_shotgun_reload_end(id)
					}
				}
			}
			case CLASS_SNIPER: {
				switch(g_smg_status[id]) {
					case smg_draw: {
						if(g_smg_time[id] + get_pcvar_float(cvar_smg_draw) < GameTime)
							wpn_smg_draw(id)
					}
					case smg_reload: {
						if(g_smg_time[id] + get_pcvar_float(cvar_smg_reload) < GameTime)
							wpn_smg_reload_end(id)
					}
				}
			}
			case CLASS_MEDIC: {
				switch(g_syringegun_status[id]) {
					case syringegun_draw: {
						if(g_syringegun_time[id] + get_pcvar_float(cvar_syringegun_draw) < GameTime)
							wpn_syringegun_draw(id)
					}
					case syringegun_reload: {
						if(g_syringegun_time[id] + get_pcvar_float(cvar_syringegun_reload) < GameTime)
							wpn_syringegun_reload_end(id)
					}
				}
			}
			case CLASS_DEMOMAN: {
				switch(g_stickybomb_status[id]) {
					case sb_draw: {
						if(g_stickybomb_time[id] + get_pcvar_float(cvar_stickybomb_draw) < GameTime)
							wpn_stickybomb_draw(id)
					}
					case sb_reload_end: {
						if(g_stickybomb_time[id] + get_pcvar_float(cvar_stickybomb_reload) < GameTime)
							wpn_stickybomb_reload_end(id)
					}
				}
			}
		}
	} else if(wpn == WEAPON_AWP) {
		if(g_blockfire[id]) {
			buttons &= ~IN_ATTACK
			buttons &= ~IN_ATTACK2
			set_pev(id, pev_button, buttons)
			fm_set_user_anim(id, 0)
		} else if(g_sniper_zoom[id]) {
			if(g_sniper_time[id] + 0.1 < GameTime) {
				g_sniper_time[id] = GameTime
				g_sniper_charge[id] += get_pcvar_float(cvar_awp_chargerate)
				if(g_sniper_charge[id] > 100.0) g_sniper_charge[id] = 100.0
				g_speed[id] = get_pcvar_num(cvar_class_speed[CLASS_SNIPER]) * get_pcvar_num(cvar_awp_slowdown)
				ck_showhud_status(id)
			}
		} else {
			g_speed[id] = get_pcvar_num(cvar_class_speed[CLASS_SNIPER])
		}
	} else if(wpn == WEAPON_P228) {
		if(g_blockfire[id]) {
			buttons &= ~IN_ATTACK
			buttons &= ~IN_ATTACK2
			set_pev(id, pev_button, buttons)
			fm_set_user_anim(id, 0)
		}
	}
	else if(wpn == WEAPON_KNIFE)
	{
		if(g_class[id] == CLASS_ENGINEER)
		{
			if(!g_aiming_at_building[id])
			{
				buttons &= ~IN_ATTACK2
				set_pev(id, pev_button, buttons)
			}
		}
		else
		{
			buttons &= ~IN_ATTACK2
			set_pev(id, pev_button, buttons)
		}
	}
}

public fw_WeaponDraw_awp(wpn)
{
	static id; id = pev(wpn, pev_owner)
	if(!is_user_alive(id)) return HAM_IGNORED

	static TeamName:userTeam
	userTeam = rg_get_user_team(id)
	set_entvar(id, var_viewmodel, WpnModels[g_class[id]][(userTeam == TEAM_TERRORIST) ? Pri_ViewModelRed : Pri_ViewModelBlue])
	set_entvar(id, var_weaponmodel, WpnModels[g_class[id]][(userTeam == TEAM_TERRORIST) ? Pri_WpnModelRed : Pri_WpnModelBlue])
	return HAM_IGNORED
}

public fw_WeaponDraw_m3(wpn)
{
	static id; id = pev(wpn, pev_owner)
	if(!is_user_alive(id)) return HAM_IGNORED

	static Float:GameTime, TeamName:userTeam; 
	GameTime = get_gametime(); 
	userTeam = rg_get_user_team(id)
	set_entvar(id, var_viewmodel, WpnModels[g_class[id]][(userTeam == TEAM_TERRORIST) ? Pri_ViewModelRed : Pri_ViewModelBlue])
	set_entvar(id, var_weaponmodel, WpnModels[g_class[id]][(userTeam == TEAM_TERRORIST) ? Pri_WpnModelRed : Pri_WpnModelBlue])

	switch(g_class[id])	{
		case CLASS_SCOUT: { 
			g_scattergun_status[id] = scattergun_draw
			g_scattergun_time[id] = GameTime
			fm_set_user_anim(id, anim_scattergun_draw)
			rg_set_user_ammo(id, WEAPON_M3, g_scattergun_clip[id])
			rg_set_user_bpammo(id, WEAPON_M3, g_scattergun_ammo[id])
		}
		case CLASS_HEAVY: {
			g_minigun_status[id] = minigun_draw
			g_minigun_time[id] = GameTime
			fm_set_user_anim(id, anim_minigun_draw)
			rg_set_user_bpammo(id, WEAPON_M3, g_minigun_clip[id])
		}
		case CLASS_SOLDIER: {
			g_rocket_status[id] = rocket_draw
			g_rocket_time[id] = GameTime
			fm_set_user_anim(id, anim_rocket_draw)
			rg_set_user_ammo(id, WEAPON_M3, g_rocket_clip[id])
			rg_set_user_bpammo(id, WEAPON_M3, g_rocket_ammo[id])
		}
		case CLASS_MEDIC: {
			fm_set_user_anim(id, anim_medicgun_draw)
		}

		case CLASS_ENGINEER: {
			g_shotgun_status[id] = shotgun_draw
			g_shotgun_time[id] = GameTime
			fm_set_user_anim(id, anim_shotgun_draw)
			rg_set_user_ammo(id, WEAPON_M3, g_shotgun_clip[id])
			rg_set_user_bpammo(id, WEAPON_M3, g_shotgun_ammo[id])
		}
		case CLASS_DEMOMAN: {
			g_grenade_status[id] = grenade_draw
			g_grenade_time[id] = GameTime
			fm_set_user_anim(id, anim_grenade_draw)
			rg_set_user_ammo(id, WEAPON_M3, g_grenade_clip[id])
			rg_set_user_bpammo(id, WEAPON_M3, g_grenade_ammo[id])
		}
		case CLASS_SNIPER: { 
			g_scattergun_status[id] = scattergun_draw
			g_scattergun_time[id] = GameTime
			fm_set_user_anim(id, anim_scattergun_draw); 
			rg_set_user_ammo(id, WEAPON_M3, g_scattergun_clip[id])
			rg_set_user_bpammo(id, WEAPON_M3, g_scattergun_ammo[id])
		}
	}
	return HAM_IGNORED
}

public fw_WeaponHolster_M3(wpn) {
	static id; id = pev(wpn, pev_owner)
	if(!is_user_alive(id)) return HAM_IGNORED
	switch(g_class[id]) {
		case CLASS_SCOUT: {
			g_scattergun_status[id] = scattergun_idle
		}
		case CLASS_HEAVY: {
			g_minigun_status[id] = minigun_idle
			g_speed[id] = get_pcvar_num(cvar_class_speed[CLASS_HEAVY])
		}
		case CLASS_SOLDIER: {
			g_rocket_status[id] = rocket_idle
		}
		case CLASS_MEDIC: {
			g_medicgun_using[id] = 0
			g_healed_by[g_medicgun_target[id]] = 0
			g_medicgun_target[id] = 0
		}
		case CLASS_ENGINEER: {
			g_shotgun_status[id] = shotgun_idle
		}
		case CLASS_DEMOMAN: {
			g_grenade_status[id] = grenade_idle
		}
	}
	return HAM_IGNORED
}

public fw_WeaponDraw_p228(wpn)
{
	static id; id = pev(wpn, pev_owner)
	if(!is_user_alive(id)) return HAM_IGNORED

	static Float:GameTime, TeamName:userTeam; 
	GameTime = get_gametime()
	userTeam = rg_get_user_team(id)
	set_entvar(id, var_viewmodel, WpnModels[g_class[id]][(userTeam == TEAM_TERRORIST) ? Sec_ViewModelRed : Sec_ViewModelBlue])
	set_entvar(id, var_weaponmodel, WpnModels[g_class[id]][(userTeam == TEAM_TERRORIST) ? Sec_WpnModelRed : Sec_WpnModelBlue])

	switch(g_class[id]) {
		case CLASS_HEAVY: {
			g_shotgun_status[id] = shotgun_draw
			g_shotgun_time[id] = GameTime
			fm_set_user_anim(id, anim_shotgun_draw)
			rg_set_user_ammo(id, WEAPON_P228, g_shotgun_clip[id])
			rg_set_user_bpammo(id, WEAPON_P228, g_shotgun_ammo[id])
		}
		case CLASS_SOLDIER: {
			g_shotgun_status[id] = shotgun_draw
			g_shotgun_time[id] = GameTime
			fm_set_user_anim(id, anim_shotgun_draw)
			rg_set_user_ammo(id, WEAPON_P228, g_shotgun_clip[id])
			rg_set_user_bpammo(id, WEAPON_P228, g_shotgun_ammo[id])
		}
		case CLASS_SNIPER: {
			g_smg_status[id] = smg_draw
			g_smg_time[id] = GameTime
			fm_set_user_anim(id, anim_smg_draw)
			rg_set_user_ammo(id, WEAPON_P228, g_smg_clip[id])
			rg_set_user_bpammo(id, WEAPON_P228, g_smg_ammo[id])
		}
		case CLASS_MEDIC: {
			g_syringegun_status[id] = syringegun_draw
			g_syringegun_time[id] = GameTime
			fm_set_user_anim(id, anim_syringegun_draw)
			rg_set_user_ammo(id, WEAPON_P228, g_syringegun_clip[id])
			rg_set_user_bpammo(id, WEAPON_P228, g_syringegun_ammo[id])
		}
		case CLASS_DEMOMAN: {
			g_stickybomb_status[id] = sb_draw
			g_stickybomb_time[id] = GameTime
			fm_set_user_anim(id, anim_sb_draw)
			rg_set_user_ammo(id, WEAPON_P228, g_stickybomb_clip[id])
			rg_set_user_bpammo(id, WEAPON_P228, g_stickybomb_ammo[id])
		}
	}
	return HAM_IGNORED
}

public fw_WeaponHolster_P228(wpn)
{
	static id; id = pev(wpn, pev_owner)
	if(!is_user_alive(id)) return HAM_IGNORED
	switch(g_class[id]) {
		case CLASS_HEAVY: g_shotgun_status[id] = shotgun_idle;
		case CLASS_SOLDIER: g_shotgun_status[id] = shotgun_idle;
		case CLASS_SNIPER: g_smg_status[id] = shotgun_idle;
		case CLASS_MEDIC: g_syringegun_status[id] = syringegun_idle;
		case CLASS_DEMOMAN: g_grenade_status[id] = grenade_idle;
	}
	return HAM_IGNORED
}

public fw_WeaponDraw_knife(wpn)
{
	static id; id = pev(wpn, pev_owner)

	if(!is_user_alive(id))
		return HAM_IGNORED

	static TeamName:userTeam; 
	userTeam = rg_get_user_team(id)
	set_entvar(id, var_viewmodel, WpnModels[g_class[id]][(userTeam == TEAM_TERRORIST) ? Melee_ViewModelRed : Melee_ViewModelBlue])
	set_entvar(id, var_weaponmodel, WpnModels[g_class[id]][(userTeam == TEAM_TERRORIST) ? Melee_WpnModelRed : Melee_WpnModelBlue])
	return HAM_IGNORED; 
}

public fw_WeaponDraw_c4(wpn) {
	static id; id = pev(wpn, pev_owner)
	if(!is_user_alive(id)) return HAM_IGNORED
	switch(g_class[id]) {
		case CLASS_ENGINEER: {
			switch(g_engineer_c4[id]) {
				case TFM_TOOLBOX: {
					set_entvar(id, var_viewmodel, Mdl_v_toolbox)
					set_entvar(id, var_weaponmodel, Mdl_p_toolbox)
				}
				case TFM_PDA: {
					set_entvar(id, var_viewmodel, Mdl_v_pda)
					set_entvar(id, var_weaponmodel, Mdl_p_pda)
				}
			}
		}
	}
	return HAM_IGNORED
}

public fw_WeaponFire_C4(wpn) {
	static id; id = pev(wpn, pev_owner)
	if(!is_user_alive(id)) return HAM_IGNORED
	if(is_user_bot(id) || g_class[id] != CLASS_ENGINEER) return HAM_IGNORED
	
	switch(g_engineer_c4[id]) {
		case TFM_TOOLBOX: show_menu_build(id)
		case TFM_PDA: show_menu_demolish(id)
	}
	return HAM_IGNORED
}

public fw_WeaponHolster_AWP(wpn) {
	static id; id = pev(wpn, pev_owner)
	if(!is_user_alive(id)) return HAM_IGNORED
	g_sniper_charge[id] = 0.0
	g_sniper_zoom[id] = 0
	return HAM_IGNORED
}

public fw_WeaponFire_AWP(wpn) {
	static id; id = pev(wpn, pev_owner)
	if(!is_user_alive(id)) return HAM_IGNORED
	set_task(0.1, "task_sniper_stopcharge", id)
	return HAM_IGNORED
}

public task_sniper_stopcharge(id) {
	if(!is_user_alive(id)) return
	g_sniper_zoom[id] = 0
	g_sniper_charge[id] = 0.0
}
// scattergun shoot
public wpn_scattergun_shoot(id) {
	if(g_scattergun_clip[id] <= 0 || g_scattergun_status[id] == scattergun_draw) 
		return

	static Float:id_origin[3], Float:target_origin[3], Float:hit_origin[3], Float:scatter
	scatter = get_pcvar_float(cvar_scattergun_scatter)
	ck_get_user_startpos(id, 16.0, 2.0, 4.0, id_origin)

	static target, dmg, Float:force, crit, mindmg, maxdmg, i, SameTeam, owner; 
	mindmg = get_pcvar_num(cvar_scattergun_mindmg)
	maxdmg = get_pcvar_num(cvar_scattergun_maxdmg)
	crit = 0

	for(i = 1; i <= get_pcvar_num(cvar_scattergun_burst); i++) {
		ck_get_user_startpos(id, 4096.0, random_float(-scatter, scatter), random_float(-scatter, scatter), target_origin)
		target = fm_trace_line(id, id_origin, target_origin, hit_origin)
		owner = pev(target, BUILD_OWNER)
		SameTeam = isSameTeam(id, owner)

		if(FClassnameIs(target, SentryBase_ClassName) || FClassnameIs(target, Dispenser_ClassName) || FClassnameIs(target, Telein_ClassName) || FClassnameIs(target, Teleout_ClassName)) {
			if(!SameTeam) {
				dmg = random_num(mindmg, maxdmg)

				static target_class[32]; pev(target, pev_classname, target_class, charsmax(target_class))
				switch(target_class[0]) {
					case 's': ck_fakedamage_build(owner, id, dmg, TFM_SCATTERGUN, 1); 
					case 'd': ck_fakedamage_build(owner, id, dmg, TFM_SCATTERGUN, 2); 
					case 't': {
						if(FClassnameIs(target, Telein_ClassName))
							ck_fakedamage_build(owner, id, dmg, TFM_SCATTERGUN, 3)
						else
							ck_fakedamage_build(owner, id, dmg, TFM_SCATTERGUN, 4)
					}
				}
			}
		} 
		else if(is_user_alive(target) && !SameTeam) {
			dmg = random_num(mindmg, maxdmg)
			force = float(dmg) * get_pcvar_float(cvar_scattergun_force)
			ck_knockback(target, id, force)
			if(g_critical_on[id]) {
				dmg *= get_pcvar_num(cvar_critical_dmg)
				ck_fakedamage(target, id, TFM_SCATTERGUN, dmg, 0, 1)
				crit = 1
			} else {
				ck_fakedamage(target, id, TFM_SCATTERGUN, dmg, 0, 0)
			}
		}

		if(!g_critical_on[id]) FX_Trace(id_origin, hit_origin)
		else FX_ColoredTrace_Point(id, id_origin, hit_origin)
	}
	engfunc(EngFunc_EmitSound, id, CHAN_WEAPON, g_critical_on[id] ? Snd_scattergun_shoot_crit : Snd_scattergun_shoot, 1.0, ATTN_NORM, 0, PITCH_NORM)

	if(crit) 
		FX_Critical(id, target)

	fm_set_user_anim(id, anim_scattergun_shoot)
	g_scattergun_status[id] = scattergun_idle
	g_scattergun_time[id] = get_gametime()
	g_scattergun_clip[id]--
	rg_set_user_ammo(id, WEAPON_M3, g_scattergun_clip[id])
}
// scattergun reload start
public wpn_scattergun_reload_start(id) {
	if(!g_scattergun_ammo[id]) return
	if(g_scattergun_clip[id] >= get_pcvar_num(cvar_scattergun_clip)) return
	if(g_scattergun_status[id] != scattergun_idle) return
	if(g_scattergun_time[id] + get_pcvar_float(cvar_scattergun_rof) > get_gametime()) return
	fm_set_user_anim(id, anim_scattergun_reload_start)
	g_scattergun_status[id] = scattergun_reload_loop
	g_scattergun_time[id] = get_gametime()
}
// scattergun reload end
public wpn_scattergun_reload_end(id) {
	if(!g_scattergun_ammo[id]) return
	if(g_scattergun_clip[id] >= get_pcvar_num(cvar_scattergun_clip)) return
	if(g_scattergun_status[id] != scattergun_reload_loop) return
	fm_set_user_anim(id, anim_scattergun_idle)
	g_scattergun_status[id] = scattergun_idle
	g_scattergun_clip[id]++
	g_scattergun_ammo[id]--
	rg_set_user_ammo(id, WEAPON_M3, g_scattergun_clip[id])
	rg_set_user_bpammo(id, WEAPON_M3, g_scattergun_ammo[id])
	if(g_scattergun_clip[id] < get_pcvar_num(cvar_scattergun_clip))
		wpn_scattergun_reload_start(id)
}
// scattergun draw
public wpn_scattergun_draw(id) {
	if(g_scattergun_status[id] != scattergun_draw) return
	g_scattergun_status[id] = scattergun_idle
	fm_set_user_anim(id, anim_scattergun_idle)
}
// minigun shoot
public wpn_minigun_shoot(id) {
	if(g_minigun_clip[id] <= 0) return
	if(g_minigun_status[id] != minigun_spool_idle) return

	static Float:id_origin[3], Float:target_origin[3], Float:hit_origin[3], Float:scatter
	scatter = get_pcvar_float(cvar_minigun_scatter)
	ck_get_user_startpos(id, 12.0, 2.0, 8.0, id_origin)

	static target, dmg, Float:force, crit, mindmg, maxdmg, owner, SameTeam, i; 
	mindmg = get_pcvar_num(cvar_minigun_mindmg)
	maxdmg = get_pcvar_num(cvar_minigun_maxdmg)

	for(i = 1; i <= get_pcvar_num(cvar_minigun_burst); i++) {
		ck_get_user_startpos(id, 4096.0, random_float(-scatter, scatter), random_float(-scatter, scatter), target_origin)
		target = fm_trace_line(id, id_origin, target_origin, hit_origin)
		static target_class[32]; pev(target, pev_classname, target_class, charsmax(target_class))
		owner = pev(target, BUILD_OWNER)
		SameTeam = isSameTeam(id, owner)
		if(FClassnameIs(target, SentryBase_ClassName) || FClassnameIs(target, Dispenser_ClassName) || FClassnameIs(target, Telein_ClassName) || FClassnameIs(target, Teleout_ClassName)) {
			if(!SameTeam) {
				dmg = random_num(mindmg, maxdmg)
				switch(target_class[0]) {
					case 's': ck_fakedamage_build(owner, id, dmg, TFM_MINIGUN, 1)
					case 'd': ck_fakedamage_build(owner, id, dmg, TFM_MINIGUN, 2)
					case 't': {
						if(FClassnameIs(target, Telein_ClassName))
							ck_fakedamage_build(owner, id, dmg, TFM_MINIGUN, 3)
						else
							ck_fakedamage_build(owner, id, dmg, TFM_MINIGUN, 4)
					}
				}
			}
		} 
		else if(is_user_alive(target) && !SameTeam) {
			dmg = random_num(mindmg, maxdmg)
			force = float(dmg) * get_pcvar_float(cvar_minigun_force)
			ck_knockback(target, id, force)
			if(g_critical_on[id]) {
				dmg *= get_pcvar_num(cvar_critical_dmg)
				ck_fakedamage(target, id, TFM_MINIGUN, dmg, 0, 1)
				crit = 1
			} else {
				ck_fakedamage(target, id, TFM_MINIGUN, dmg, 0, 0)
			}
		}
		if(!g_wpn_traced[id]) {
			if(!g_critical_on[id]) FX_Trace(id_origin, hit_origin)
			else FX_ColoredTrace_Point(id, id_origin, hit_origin)
			g_wpn_traced[id] = 1
		} 
		else {
			g_wpn_traced[id] = 0
		}
	}
	
	engfunc(EngFunc_EmitSound, id, CHAN_WEAPON, g_critical_on[id] ? Snd_minigun_shoot_crit : Snd_minigun_shoot, 1.0, ATTN_NORM, 0, PITCH_NORM)
	
	if(crit)
		FX_Critical(id, target)

	fm_set_user_anim(id, anim_minigun_shoot)
	g_minigun_time[id] = get_gametime()
	
	g_minigun_clip[id]--
	rg_set_user_ammo(id, WEAPON_M3, 0)
	rg_set_user_bpammo(id, WEAPON_M3, g_minigun_clip[id])
}
// minigun draw
public wpn_minigun_draw(id) {
	if(g_minigun_status[id] != minigun_draw) return
	g_minigun_status[id] = minigun_idle
	fm_set_user_anim(id, anim_minigun_idle)
}
// rocket launcher shoot
public wpn_rocket_shoot(id) {
	if(!is_user_connected(id))
		return
	if(g_rocket_clip[id] <= 0) return
	if(g_rocket_status[id] == rocket_draw) return
	new Float:start_origin[3], Float:angle[3]
	pev(id, pev_v_angle, angle)
	angle[0] *= -1.0
	ck_get_user_startpos(id, 24.0, 6.0, 8.0, start_origin)

	new rocket = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "grenade"))
	set_pev(rocket, pev_angles, angle)
	set_pev(rocket, pev_origin, start_origin)
	set_pev(rocket, pev_classname, g_EntityClassnames[RpgRocket_ClassName])
	set_pev(rocket, PROJECTILE_REFLECT, 0)
	engfunc(EngFunc_SetModel, rocket, Bullet_soldier_primary)
	new critical = random_num(1, 100)
	if(critical <= g_critical[id] || g_critical_on[id]) {
		set_pev(rocket, PROJECTILE_CRITICAL, 1)
		engfunc(EngFunc_EmitSound, id, CHAN_WEAPON, Snd_rocket_shoot_crit, 1.0, ATTN_NORM, 0, PITCH_NORM)
		if(rg_get_user_team(id) == TEAM_TERRORIST) fm_set_rendering(rocket, kRenderFxGlowShell, 225, 50, 0, kRenderNormal, 128)
		else fm_set_rendering(rocket, kRenderFxGlowShell, 0, 50, 225, kRenderNormal, 128)
	} else {
		set_pev(rocket, PROJECTILE_CRITICAL, 0)
		engfunc(EngFunc_EmitSound, id, CHAN_WEAPON, Snd_rocket_shoot, 1.0, ATTN_NORM, 0, PITCH_NORM)
		fm_set_rendering(rocket, kRenderFxGlowShell, 250, 128, 0, kRenderNormal, 64)
	}

	set_entvar(rocket, var_mins, { -1.0, -1.0, -1.0 })
	set_entvar(rocket, var_maxs, { 1.0, 1.0, 1.0 })
	set_entvar(rocket, var_solid, SOLID_TRIGGER)
	set_entvar(rocket, var_movetype, MOVETYPE_FLYMISSILE)
	set_entvar(rocket, var_owner, id)

	new Float:velocity[3]
	velocity_by_aim(id, get_pcvar_num(cvar_rocket_velocity), velocity)

	set_entvar(rocket, var_velocity, velocity)

	ck_get_user_startpos(id, 35.0, 6.0, 8.0, start_origin)
	FX_Explode(start_origin, spr_rocketlaunch, 6, 30, TE_EXPLFLAG_NOSOUND)
	ck_get_user_startpos(id, -30.0, 6.0, 8.0, start_origin)
	FX_Smoke(start_origin)

	g_rocket_clip[id]--
	fm_set_user_anim(id, anim_rocket_shoot)
	g_rocket_time[id] = get_gametime()

	rg_set_user_ammo(id, WEAPON_M3, g_rocket_clip[id])

	set_entvar(rocket, var_nextthink, get_gametime() + SMOKETRAIL_RATE)

	ck_showhud_status(id)
}

// explode

public wpn_rocket_explode(rocket) {
	if(!pev_valid(rocket))
		return; 

	new enemy = pev(rocket, pev_owner)
	engfunc(EngFunc_EmitSound, rocket, CHAN_STATIC, Snd_explode, 1.0, ATTN_NORM, 0, PITCH_NORM)

	new Float:origin[3]
	pev(rocket, pev_origin, origin)

	FX_NewExplode(origin)
	// FX_Smoke(origin)
	FX_ExpDecal(origin)

	static dmg, victim, Float:victim_origin[3], Float:distance, Float:force, victim_class[48]
	while((victim = engfunc(EngFunc_FindEntityInSphere, victim, origin, get_pcvar_float(cvar_rocket_radius))) != 0) {
		pev(victim, pev_classname, victim_class, charsmax(victim_class))
		if(FClassnameIs(victim, SentryBase_ClassName) || FClassnameIs(victim, Dispenser_ClassName) || FClassnameIs(victim, Telein_ClassName) || FClassnameIs(victim, Teleout_ClassName)) {
			new owner = pev(victim, BUILD_OWNER)
			if(enemy == owner)
				continue
			if(isSameTeam(enemy, owner))
				continue
			distance = fm_distance_to_boxent(rocket, victim)
			dmg = get_pcvar_num(cvar_rocket_dmg) - floatround(floatmul(float(get_pcvar_num(cvar_rocket_dmg)), floatdiv(distance, get_pcvar_float(cvar_rocket_radius))))
			if(dmg < get_pcvar_num(cvar_rocket_mindmg)) dmg = get_pcvar_num(cvar_rocket_mindmg)
			else if(dmg > get_pcvar_num(cvar_rocket_maxdmg)) dmg = get_pcvar_num(cvar_rocket_maxdmg)
			switch(victim_class[0]) {
				case 's':ck_fakedamage_build(owner, enemy, dmg, TFM_ROCKET, 1)
				case 'd':ck_fakedamage_build(owner, enemy, dmg, TFM_ROCKET, 2)
				case 't': {
					if(FClassnameIs(victim, Telein_ClassName))
						ck_fakedamage_build(owner, enemy, dmg, TFM_ROCKET, 3)
					else
						ck_fakedamage_build(owner, enemy, dmg, TFM_ROCKET, 4)
				}
			}
		} else if(FClassnameIs(victim, "player")) {
			if(!is_user_alive(victim)) continue
			if(isSameTeam(enemy, victim)) continue
			pev(victim, pev_origin, victim_origin)
			distance = vector_distance(origin, victim_origin)
			dmg = get_pcvar_num(cvar_rocket_dmg) - floatround(floatmul(float(get_pcvar_num(cvar_rocket_dmg)), floatdiv(distance, get_pcvar_float(cvar_rocket_radius))))
			if(dmg < get_pcvar_num(cvar_rocket_mindmg)) dmg = get_pcvar_num(cvar_rocket_mindmg)
			else if(dmg > get_pcvar_num(cvar_rocket_maxdmg)) dmg = get_pcvar_num(cvar_rocket_maxdmg)
			if(enemy != victim) {
				force = (1.0 - distance / get_pcvar_float(cvar_rocket_radius)) * get_pcvar_float(cvar_rocket_force)
				if(pev(rocket, PROJECTILE_CRITICAL)) {
					dmg *= get_pcvar_num(cvar_critical_dmg)
					FX_Critical(enemy, victim)
				}
			} else {
				dmg *= get_pcvar_num(cvar_rocket_multidmg)
				force = (1.0 - distance / get_pcvar_float(cvar_rocket_radius)) * get_pcvar_float(cvar_rocket_force)
				if(!(pev(victim, pev_flags) & FL_ONGROUND))
					force *= 1.5
				if(pev(victim, pev_flags) & FL_DUCKING)
					force *= 1.5
			}
			ck_knockback_explode(victim, origin, force)
			if(g_charge_shield[g_healed_by[victim]] && ck_get_user_assistance(victim) > 0)
				continue
			if(g_charge_shield[victim])
				continue
			if(pev(rocket, PROJECTILE_REFLECT)) {
				if(pev(rocket, PROJECTILE_CRITICAL))
					ck_fakedamage(victim, enemy, TFM_REFLECTROCKET, dmg, 1, 1)
				else
					ck_fakedamage(victim, enemy, TFM_REFLECTROCKET, dmg, 1, 0)
			} else {
				if(pev(rocket, PROJECTILE_CRITICAL))
					ck_fakedamage(victim, enemy, TFM_ROCKET, dmg, 1, 1)
				else
					ck_fakedamage(victim, enemy, TFM_ROCKET, dmg, 1, 0)
			}
		}
	}
	engfunc(EngFunc_RemoveEntity, rocket)
}

// reload

public wpn_rocket_reload_start(id) {
	if(!g_rocket_ammo[id]) return
	if(g_rocket_clip[id] >= get_pcvar_num(cvar_rocket_clip)) return
	if(g_rocket_status[id] != rocket_idle) return
	if(g_rocket_time[id] + get_pcvar_float(cvar_rocket_rof) > get_gametime()) return
	fm_set_user_anim(id, anim_rocket_reload)
	g_rocket_status[id] = rocket_reload
	g_rocket_time[id] = get_gametime()
}

public wpn_rocket_reload_end(id) {
	if(!g_rocket_ammo[id]) return
	if(g_rocket_clip[id] >= get_pcvar_num(cvar_rocket_clip)) return
	if(g_rocket_status[id] != rocket_reload) return
	fm_set_user_anim(id, anim_rocket_idle)
	g_rocket_status[id] = rocket_idle
	g_rocket_clip[id]++
	g_rocket_ammo[id]--
	rg_set_user_ammo(id, WEAPON_M3, g_rocket_clip[id])
	rg_set_user_bpammo(id, WEAPON_M3, g_rocket_ammo[id])
	if(g_rocket_clip[id] < get_pcvar_num(cvar_rocket_clip))
		wpn_rocket_reload_start(id)
}

// draw

public wpn_rocket_draw(id) {
	if(g_rocket_status[id] != rocket_draw) return
	g_rocket_status[id] = rocket_idle
	fm_set_user_anim(id, anim_rocket_idle)
}

// Medicgun

// heal

public wpn_medicgun_heal(taskid) {
	static id
	if(taskid > MaxClients)
		id = taskid - TASK_MEDICGUN
	else
		id = taskid
	new target = g_medicgun_target[id]
	if(!g_medicgun_using[id]) return; 
	if(!is_user_alive(id) || !is_user_alive(target)) {
		g_medicgun_using[id] = 0
		g_healed_by[target] = 0
		return
	}
	if(rg_get_user_active_weapon(id) != WEAPON_M3) {
		g_medicgun_using[id] = 0
		g_healed_by[target] = 0
		return
	}
	if(!isSameTeam(id, target)) {
		g_medicgun_using[id] = 0
		g_healed_by[target] = 0
		return
	}
	if(g_healed_by[target] && g_healed_by[target] != id) {
		g_medicgun_using[id] = 0
		return
	}
	if(rg_get_user_team(id) == TEAM_TERRORIST) {
		if(g_charge_shield[id]) fm_set_rendering(target, kRenderFxGlowShell, 255, 0, 0, kRenderNormal, 16)
		else fm_set_rendering(id, kRenderFxNone, 0, 0, 0, kRenderNormal, 255)
		FX_Healbeam(id, target, 225, 25, 25, 2)
	} else {
		if(g_charge_shield[id]) fm_set_rendering(target, kRenderFxGlowShell, 0, 0, 255, kRenderNormal, 16)
		else fm_set_rendering(id, kRenderFxNone, 0, 0, 0, kRenderNormal, 255)
		FX_Healbeam(id, target, 25, 25, 225, 2)
	}
	new Float:id_origin[3], Float:target_origin[3]
	pev(id, pev_origin, id_origin)
	pev(target, pev_origin, target_origin)
	new Float:distance = vector_distance(id_origin, target_origin)
	if(distance > get_pcvar_float(cvar_medicgun_range)) {
		g_medicgun_using[id] = 0
		g_healed_by[target] = 0
		return
	}
	new heal = random_num(get_pcvar_num(cvar_medicgun_minheal), get_pcvar_num(cvar_medicgun_maxheal))
	g_healed_by[target] = id
	g_medic_charge[id] += get_pcvar_float(cvar_medicgun_charge)
	new maxhealth = ck_get_user_maxhealth(target)
	maxhealth *= get_pcvar_num(cvar_medicgun_maxhealth)
	if(get_user_health(target) + heal <= maxhealth) {
		fm_set_user_health(g_medicgun_target[id], get_user_health(target) + heal)
		if(g_medic_charge[id] + get_pcvar_float(cvar_medicgun_charge) <= 100.0) g_medic_charge[id] += get_pcvar_float(cvar_medicgun_charge)
		else g_medic_charge[id] = 100.0
	}
	ck_showhud_status(target)
	rg_set_user_bpammo(id, WEAPON_M3, floatround(g_medic_charge[id]))
	remove_task(id+TASK_MEDICGUN, 0)
	set_task(get_pcvar_float(cvar_medicgun_rof), "wpn_medicgun_heal", id+TASK_MEDICGUN)
}

// medicgun charge
public wpn_medicgun_charge(id) {
	if(!g_medicgun_using[id]) return; 
	if(g_charge_shield[id]) return; 
	if(g_medic_charge[id] < 100.0) return; 
	g_charge_shield[id] = 1
	g_stats[STATS_SHIELD][id]++
	engfunc(EngFunc_EmitSound, id, CHAN_STATIC, Snd_medicgun_chargeon, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	ck_showhud_status(id)
}

// syringegun shoot
public wpn_syringegun_shoot(id) {
	if(!g_syringegun_clip[id]) return
	if(g_syringegun_status[id] == syringegun_draw) return
	if(g_syringegun_status[id] == syringegun_reload) return
	if(!is_user_connected(id))
		return
	new Float:start_origin[3], Float:angle[3]

	ck_get_user_startpos(id, 24.0, 6.0, 8.0, start_origin)

	pev(id, pev_v_angle, angle)
	angle[0] *= -1.0

	new syringe = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "grenade"))
	set_entvar(syringe, var_angles, angle)
	set_entvar(syringe, var_origin, start_origin)
	set_entvar(syringe, var_classname, g_EntityClassnames[MedicSyringe_Classname])
	set_pev(syringe, PROJECTILE_REFLECT, 0)

	engfunc(EngFunc_SetModel, syringe, Bullet_medic_primary)
	static TeamName:team; team = rg_get_user_team(id)
	set_entvar(syringe, var_skin, team == TEAM_TERRORIST ? TF2_RED : TF2_BLUE)

	new critical = random_num(1, 100)
	if(critical <= g_critical[id] || g_critical_on[id]) {
		set_pev(syringe, PROJECTILE_CRITICAL, 1)
		engfunc(EngFunc_EmitSound, id, CHAN_STATIC, Snd_syringegun_shoot_crit, 1.0, ATTN_NORM, 0, PITCH_NORM)
		if(team == TEAM_TERRORIST) fm_set_rendering(syringe, kRenderFxGlowShell, 255, 0, 0, kRenderNormal, 16)
		else fm_set_rendering(syringe, kRenderFxGlowShell, 0, 0, 255, kRenderNormal, 16)
	} else {
		set_pev(syringe, PROJECTILE_CRITICAL, 0)
		engfunc(EngFunc_EmitSound, id, CHAN_WEAPON, Snd_syringegun_shoot, 1.0, ATTN_NORM, 0, PITCH_NORM)
	}
	set_entvar(syringe, var_mins, { -1.0, -1.0, -1.0 })
	set_entvar(syringe, var_maxs, { 1.0, 1.0, 1.0 })
	
	set_entvar(syringe, var_movetype, MOVETYPE_TOSS)
	set_entvar(syringe, var_solid, SOLID_TRIGGER)
	
	set_entvar(syringe, var_owner, id)

	new Float:velocity[3]
	velocity_by_aim(id, get_pcvar_num(cvar_syringegun_velocity), velocity)
	set_entvar(syringe, var_velocity, velocity)

	fm_set_user_anim(id, anim_syringegun_shoot)
	g_syringegun_status[id] = syringegun_idle
	g_syringegun_time[id] = get_gametime()
	g_syringegun_clip[id]--
	rg_set_user_ammo(id, WEAPON_P228, g_syringegun_clip[id])
}

// reload

public wpn_syringegun_reload_start(id) {
	if(!g_syringegun_ammo[id]) return
	if(g_syringegun_clip[id] >= get_pcvar_num(cvar_syringegun_clip)) return
	if(g_syringegun_status[id] != syringegun_idle) return
	fm_set_user_anim(id, anim_syringegun_reload)
	g_syringegun_status[id] = syringegun_reload
	g_syringegun_time[id] = get_gametime()
}

public wpn_syringegun_reload_end(id) {
	if(!g_syringegun_ammo[id]) return
	if(g_syringegun_clip[id] >= get_pcvar_num(cvar_syringegun_clip)) return
	if(g_syringegun_status[id] != syringegun_reload) return
	fm_set_user_anim(id, anim_syringegun_idle)
	g_syringegun_status[id] = syringegun_idle
	if(g_syringegun_ammo[id] >= get_pcvar_num(cvar_syringegun_clip) - g_syringegun_clip[id]) {
		g_syringegun_ammo[id] -= get_pcvar_num(cvar_syringegun_clip) - g_syringegun_clip[id]
		g_syringegun_clip[id] = get_pcvar_num(cvar_syringegun_clip)
	} else {
		g_syringegun_clip[id] += g_syringegun_ammo[id]
		g_syringegun_ammo[id] = 0
	}
	rg_set_user_ammo(id, WEAPON_P228, g_syringegun_clip[id])
	rg_set_user_bpammo(id, WEAPON_P228, g_syringegun_ammo[id])
}

// draw

public wpn_syringegun_draw(id) {
	if(g_syringegun_status[id] != syringegun_draw) return
	g_syringegun_status[id] = syringegun_idle
	fm_set_user_anim(id, anim_syringegun_idle)
}

// Shotgun

// shoot

public wpn_shotgun_shoot(id) {
	if(!g_shotgun_clip[id] || g_shotgun_status[id] == shotgun_draw) return

	static Float:id_origin[3], Float:target_origin[3], Float:hit_origin[3], Float:scatter
	scatter = get_pcvar_float(cvar_shotgun_scatter)
	ck_get_user_startpos(id, 12.0, 2.0, 12.0, id_origin)

	static target, dmg, Float:force, crit, mindmg, maxdmg, i, SameTeam, owner; 
	mindmg = get_pcvar_num(cvar_shotgun_mindmg)
	maxdmg = get_pcvar_num(cvar_shotgun_maxdmg)

	for(i = 1; i <= get_pcvar_num(cvar_shotgun_burst); i++) {
		ck_get_user_startpos(id, 4096.0, random_float(-scatter, scatter), random_float(-scatter, scatter), target_origin)
		target = fm_trace_line(id, id_origin, target_origin, hit_origin)
		static target_class[32]; pev(target, pev_classname, target_class, charsmax(target_class))
		owner = pev(target, BUILD_OWNER)
		SameTeam = isSameTeam(id, owner)
		if(FClassnameIs(target, SentryBase_ClassName) || FClassnameIs(target, Dispenser_ClassName) || FClassnameIs(target, Telein_ClassName) || FClassnameIs(target, Teleout_ClassName)) {
			if(!SameTeam) {
				dmg = random_num(mindmg, maxdmg)
				switch(target_class[0]) {
					case 's':ck_fakedamage_build(owner, id, dmg, TFM_SHOTGUN, 1)
					case 'd':ck_fakedamage_build(owner, id, dmg, TFM_SHOTGUN, 2)
					case 't': {
						if(FClassnameIs(target, Telein_ClassName))
							ck_fakedamage_build(owner, id, dmg, TFM_SHOTGUN, 3)
						else
							ck_fakedamage_build(owner, id, dmg, TFM_SHOTGUN, 4)
					}
				}
			}
		} else if(is_user_alive(target) && !SameTeam) {
			dmg = random_num(mindmg, maxdmg)
			force = float(dmg) * get_pcvar_float(cvar_shotgun_force)
			ck_knockback(target, id, force)
			if(g_critical_on[id]) {
				dmg *= get_pcvar_num(cvar_critical_dmg)
				ck_fakedamage(target, id, TFM_SHOTGUN, dmg, 0, 1)
				crit = 1
			} else {
				ck_fakedamage(target, id, TFM_SHOTGUN, dmg, 0, 0)
			}
		}
		if(!g_critical_on[id]) FX_Trace(id_origin, hit_origin)
		else FX_ColoredTrace_Point(id, id_origin, hit_origin)
	}
	engfunc(EngFunc_EmitSound, id, CHAN_WEAPON, g_critical_on[id] ? Snd_shotgun_shoot_crit : Snd_shotgun_shoot, 1.0, ATTN_NORM, 0, PITCH_NORM)
	if(crit)
		FX_Critical(id, target)

	fm_set_user_anim(id, anim_shotgun_fire)
	g_shotgun_status[id] = shotgun_idle
	g_shotgun_time[id] = get_gametime()
	g_shotgun_clip[id]--
	rg_set_user_ammo(id, rg_get_user_active_weapon(id), g_shotgun_clip[id])
}
// reload shotgun start
public wpn_shotgun_reload_start(id)
{
	if(!g_shotgun_ammo[id]) return
	if(g_shotgun_clip[id] >= get_pcvar_num(cvar_shotgun_clip) || g_shotgun_status[id] != shotgun_idle) return
	if(g_shotgun_time[id] + get_pcvar_float(cvar_shotgun_rof) > get_gametime()) return
	fm_set_user_anim(id, anim_shotgun_reload_loop)
	g_shotgun_status[id] = shotgun_reload_loop
	g_shotgun_time[id] = get_gametime()
}
// reload shotgun end
public wpn_shotgun_reload_end(id)
{
	if(!g_shotgun_ammo[id]) return
	if(g_shotgun_clip[id] >= get_pcvar_num(cvar_shotgun_clip)) return
	if(g_shotgun_status[id] != shotgun_reload_loop) return
	fm_set_user_anim(id, anim_shotgun_idle)
	g_shotgun_status[id] = shotgun_idle
	g_shotgun_clip[id]++
	g_shotgun_ammo[id]--
	
	static WeaponIdType:UserWpn;
	UserWpn = rg_get_user_active_weapon(id)
	rg_set_user_ammo(id, UserWpn, g_shotgun_clip[id])
	rg_set_user_bpammo(id, UserWpn, g_shotgun_ammo[id])

	if(g_shotgun_clip[id] < get_pcvar_num(cvar_shotgun_clip))
		wpn_shotgun_reload_start(id)
}
// draw shotgun
public wpn_shotgun_draw(id)
{
	if(g_shotgun_status[id] != shotgun_draw) return
	g_shotgun_status[id] = shotgun_idle
	fm_set_user_anim(id, anim_shotgun_idle)
}
// smg shoot
public wpn_smg_shoot(id) {
	if(!g_smg_clip[id] || g_smg_status[id] == smg_draw || g_smg_status[id] == smg_reload) 
		return
	
	static Float:id_origin[3], Float:target_origin[3], Float:hit_origin[3], Float:scatter
	scatter = get_pcvar_float(cvar_smg_scatter)
	ck_get_user_startpos(id, 12.0, 2.0, 12.0, id_origin)

	static target, dmg, Float:force, mindmg, maxdmg, SameTeam, owner; 
	mindmg = get_pcvar_num(cvar_smg_mindmg)
	maxdmg = get_pcvar_num(cvar_smg_maxdmg)

	ck_get_user_startpos(id, 4096.0, random_float(scatter * -1.0, scatter), random_float(scatter * -1.0, scatter), target_origin)
	target = fm_trace_line(id, id_origin, target_origin, hit_origin)
	owner = pev(target, BUILD_OWNER)
	SameTeam = isSameTeam(id, owner)

	static target_class[32]; pev(target, pev_classname, target_class, charsmax(target_class))
	if(FClassnameIs(target, SentryBase_ClassName) || FClassnameIs(target, Dispenser_ClassName) || FClassnameIs(target, Telein_ClassName) || FClassnameIs(target, Teleout_ClassName)) {
		
		if(!SameTeam) {
			dmg = random_num(mindmg, maxdmg)
			switch(target_class[0]) {
				case 's':ck_fakedamage_build(owner, id, dmg, TFM_SMG, 1)
				case 'd':ck_fakedamage_build(owner, id, dmg, TFM_SMG, 2)
				case 't': {
					if(FClassnameIs(target, Telein_ClassName))
						ck_fakedamage_build(owner, id, dmg, TFM_SMG, 3)
					else
						ck_fakedamage_build(owner, id, dmg, TFM_SMG, 4)
				}
			}
		}
	} else if(is_user_alive(target) && !SameTeam) {
		dmg = random_num(mindmg, maxdmg)
		force = float(dmg) * get_pcvar_float(cvar_smg_force)
		ck_knockback(target, id, force)
		if(g_critical_on[id]) {
			dmg *= get_pcvar_num(cvar_critical_dmg)
			ck_fakedamage(target, id, TFM_SMG, dmg, 0, 1)
			FX_Critical(id, target)
		} else {
			ck_fakedamage(target, id, TFM_SMG, dmg, 0, 0)
		}
	}
	if(!g_wpn_traced[id]) {
		if(!g_critical_on[id]) FX_Trace(id_origin, hit_origin)
		else FX_ColoredTrace_Point(id, id_origin, hit_origin)
		g_wpn_traced[id] = 1
	} else {
		g_wpn_traced[id] = 0
	}
	
	engfunc(EngFunc_EmitSound, id, CHAN_WEAPON, g_critical_on[id] ? Snd_smg_shoot_crit : Snd_smg_shoot, 1.0, ATTN_NORM, 0, PITCH_NORM)
	fm_set_user_anim(id, anim_smg_shoot)
	g_smg_status[id] = smg_idle
	g_smg_time[id] = get_gametime()
	g_smg_clip[id]--
	rg_set_user_ammo(id, WEAPON_P228, g_smg_clip[id])
}

// reload

public wpn_smg_reload_start(id) {
	if(!g_smg_ammo[id] || g_smg_status[id] != smg_idle) return
	if(g_smg_clip[id] >= get_pcvar_num(cvar_smg_clip)) return
	fm_set_user_anim(id, anim_smg_reload)
	g_smg_status[id] = smg_reload
	g_smg_time[id] = get_gametime()
}

public wpn_smg_reload_end(id) {
	if(!g_smg_ammo[id] || g_smg_status[id] != smg_reload) return

	static SmgClip; 
	SmgClip = get_pcvar_num(cvar_smg_clip)
	if(g_smg_clip[id] >= SmgClip) return
	fm_set_user_anim(id, anim_smg_idle)
	g_smg_status[id] = smg_idle
	if(g_smg_ammo[id] >= SmgClip - g_smg_clip[id]) {
		g_smg_ammo[id] -= SmgClip - g_smg_clip[id]
		g_smg_clip[id] = SmgClip
	} else {
		g_smg_clip[id] += g_smg_ammo[id]
		g_smg_ammo[id] = 0
	}
	rg_set_user_ammo(id, WEAPON_P228, g_smg_clip[id])
	rg_set_user_bpammo(id, WEAPON_P228, g_smg_ammo[id])
}

// draw

public wpn_smg_draw(id) {
	if(g_smg_status[id] != smg_draw) return
	g_smg_status[id] = smg_idle
	fm_set_user_anim(id, anim_smg_idle)
}

// Grenade Launcher

// shoot

public wpn_grenade_shoot(id) {
	if(!g_grenade_clip[id] || g_grenade_status[id] == grenade_draw) return
	if(!is_user_connected(id))
		return

	static Float:id_origin[3], Float:angle[3], grenade, critical, TeamName:userTeam, rgb[3], Float:velocity[3]; 
	userTeam = rg_get_user_team(id)
	rgb = (userTeam == TEAM_TERRORIST) ? {255, 50, 0} : {0, 50, 255}

	pev(id, pev_angles, angle)
	ck_get_user_startpos(id, 16.0, 2.0, 14.0, id_origin)

	grenade = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "grenade"))
	set_pev(grenade, pev_angles, angle)
	set_pev(grenade, pev_origin, id_origin)
	set_pev(grenade, pev_classname, g_EntityClassnames[DemoGren_Classname])
	set_pev(grenade, PROJECTILE_REFLECT, 0)

	critical = random_num(1, 100)
	if(critical <= g_critical[id] || g_critical_on[id]) {
		set_pev(grenade, PROJECTILE_CRITICAL, 1)
		engfunc(EngFunc_EmitSound, id, CHAN_WEAPON, Snd_grenade_shoot_crit, 1.0, ATTN_NORM, 0, PITCH_NORM)
		fm_set_rendering(grenade, kRenderFxGlowShell, rgb[0], rgb[1], rgb[2], kRenderNormal, 32)
	} else {
		set_pev(grenade, PROJECTILE_CRITICAL, 0)
		engfunc(EngFunc_EmitSound, id, CHAN_WEAPON, Snd_grenade_shoot, 1.0, ATTN_NORM, 0, PITCH_NORM)
	}

	engfunc(EngFunc_SetModel, grenade, Bullet_demoman_primary)
	static TeamName:team; team = rg_get_user_team(id)
	set_entvar(grenade, var_skin, team == TEAM_TERRORIST ? TF2_RED : TF2_BLUE)

	set_entvar(grenade, var_mins, { -4.0, -4.0, -4.0 })
	set_entvar(grenade, var_maxs, { 4.0, 4.0, 4.0 })
	set_entvar(grenade, var_solid, SOLID_TRIGGER)
	set_entvar(grenade, var_movetype, MOVETYPE_TOSS)
	set_entvar(grenade, var_owner, id)

	velocity_by_aim(id, get_pcvar_num(cvar_grenade_velocity), velocity)
	set_entvar(grenade, var_velocity, velocity)

	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_BEAMFOLLOW); 
	write_short(grenade);
	write_short(spr_trail);
	write_byte(8);
	write_byte(5);
	write_byte(rgb[0]);
	write_byte(rgb[1]);
	write_byte(rgb[2]);
	write_byte(200);
	message_end(); 

	fm_set_user_anim(id, anim_grenade_shoot)
	g_grenade_time[id] = get_gametime()
	g_grenade_status[id] = grenade_idle
	g_grenade_clip[id]--
	rg_set_user_ammo(id, WEAPON_M3, g_grenade_clip[id])
	set_pev(grenade, pev_nextthink, get_gametime() + get_pcvar_float(cvar_grenade_delay))
}

// explode

public wpn_grenade_explode(grenade) {
	static enemy
	enemy = pev(grenade, pev_owner)
	engfunc(EngFunc_EmitSound, grenade, CHAN_STATIC, Snd_explode, 1.0, ATTN_NORM, 0, PITCH_NORM)

	static Float:origin[3], Float:CvarDamage, Float:CvarRadius, CvarMinDmg, CvarMaxDmg
	pev(grenade, pev_origin, origin)

	FX_NewExplode(origin)
	FX_ExpDecal(origin)

	CvarDamage = get_pcvar_float(cvar_grenade_dmg)
	CvarRadius = get_pcvar_float(cvar_grenade_radius)
	CvarMinDmg = get_pcvar_num(cvar_grenade_mindmg)
	CvarMaxDmg = get_pcvar_num(cvar_grenade_maxdmg)

	static dmg, victim, Float:victim_origin[3], Float:distance, Float:force, victim_class[48], owner
	while((victim = engfunc(EngFunc_FindEntityInSphere, victim, origin, CvarRadius)) != 0) {
		
		if(FClassnameIs(victim, SentryBase_ClassName) || FClassnameIs(victim, Dispenser_ClassName) || FClassnameIs(victim, Telein_ClassName) || FClassnameIs(victim, Teleout_ClassName)) {
			owner = pev(victim, BUILD_OWNER)
			if(enemy == owner)
				continue

			if(isSameTeam(enemy, owner))
				continue
	
			distance = fm_distance_to_boxent(grenade, victim)
			dmg = floatround(CvarDamage - (floatmul(CvarDamage, floatdiv(distance, CvarRadius))))

			if(dmg < CvarMinDmg) 
				dmg = CvarMinDmg
			else if(dmg > CvarMaxDmg) 
				dmg = CvarMaxDmg

			pev(victim, pev_classname, victim_class, charsmax(victim_class))
			switch(victim_class[0]) {
				case 's':ck_fakedamage_build(owner, enemy, dmg, TFM_GRENADE, 1)
				case 'd':ck_fakedamage_build(owner, enemy, dmg, TFM_GRENADE, 2)
				case 't': {
					if(FClassnameIs(victim, Telein_ClassName))
						ck_fakedamage_build(owner, enemy, dmg, TFM_GRENADE, 3)
					else
						ck_fakedamage_build(owner, enemy, dmg, TFM_GRENADE, 4)
				}
			}
		} else if(is_user_connected(victim)) {
			if(!is_user_alive(victim)) continue; 
			if(isSameTeam(enemy, victim)) continue; 

			pev(victim, pev_origin, victim_origin)
			distance = vector_distance(origin, victim_origin)
			dmg = floatround(CvarDamage - (floatmul(CvarDamage, floatdiv(distance, CvarRadius))))
			if(dmg < CvarMinDmg) dmg = CvarMinDmg
			else if(dmg > CvarMaxDmg) dmg = CvarMaxDmg
		
			force = (1.0 - distance / CvarRadius) * get_pcvar_float(cvar_grenade_force)
			if(enemy != victim) {
				if(pev(grenade, PROJECTILE_CRITICAL)) {
					dmg *= get_pcvar_num(cvar_critical_dmg)
					FX_Critical(enemy, victim)
				}
			} else {
				if(!(pev(victim, pev_flags) & FL_ONGROUND) || pev(victim, pev_flags) & FL_DUCKING)
					force *= 1.5
			}
			ck_knockback_explode(victim, origin, force)
			if(g_charge_shield[g_healed_by[victim]] && ck_get_user_assistance(victim) > 0)
				continue

			if(g_charge_shield[victim])
				continue
			
			ck_fakedamage(victim, enemy, pev(grenade, PROJECTILE_REFLECT) ? TFM_REFLECTGRENADE : TFM_GRENADE, dmg, 1, pev(grenade, PROJECTILE_CRITICAL) ? 1 : 0)
		}
	}
	engfunc(EngFunc_RemoveEntity, grenade)
}

// reload

public wpn_grenade_reload_start(id) {
	if(!g_grenade_ammo[id] || g_grenade_status[id] != grenade_idle) return
	if(g_grenade_clip[id] >= get_pcvar_num(cvar_grenade_clip)) return
	if(g_grenade_time[id] + get_pcvar_float(cvar_grenade_rof) > get_gametime()) return
	fm_set_user_anim(id, anim_grenade_reload)
	g_grenade_status[id] = grenade_reload
	g_grenade_time[id] = get_gametime()
}
public wpn_grenade_reload_end(id) {
	if(!g_grenade_ammo[id] || g_grenade_status[id] != grenade_reload) return
	if(g_grenade_clip[id] >= get_pcvar_num(cvar_grenade_clip)) return
	fm_set_user_anim(id, anim_grenade_idle)
	g_grenade_status[id] = grenade_idle
	g_grenade_clip[id]++
	g_grenade_ammo[id]--
	rg_set_user_ammo(id, WEAPON_M3, g_grenade_clip[id])
	rg_set_user_bpammo(id, WEAPON_M3, g_grenade_ammo[id])
	if(g_grenade_clip[id] < get_pcvar_num(cvar_grenade_clip))
		wpn_grenade_reload_start(id)
}

// draw

public wpn_grenade_draw(id) {
	if(g_grenade_status[id] != grenade_draw) return
	g_grenade_status[id] = grenade_idle
	fm_set_user_anim(id, anim_grenade_idle)
}

// Stickybomb Launcher

// shoot

public wpn_stickybomb_shoot(id) {
	if(!g_stickybomb_clip[id] || g_stickybomb_status[id] == sb_draw) return
	if(!is_user_connected(id))
		return

	static Float:id_origin[3], Float:angle[3], stickybomb, rgb[3], TeamName:userTeam, critical
	pev(id, pev_angles, angle)
	ck_get_user_startpos(id, 16.0, 2.0, 14.0, id_origin)
	userTeam = rg_get_user_team(id); 
	rgb = (userTeam == TEAM_TERRORIST) ? {255, 50, 0} : {0, 50, 255}

	stickybomb = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "grenade"))
	set_pev(stickybomb, pev_angles, angle)
	set_pev(stickybomb, pev_origin, id_origin)
	set_pev(stickybomb, pev_classname, g_EntityClassnames[DemoGren_Classname])
	set_pev(stickybomb, PROJECTILE_REFLECT, 0)
	
	critical = random_num(1, 100)
	if(critical <= g_critical[id] || g_critical_on[id]) {
		set_pev(stickybomb, PROJECTILE_CRITICAL, 1)
		engfunc(EngFunc_EmitSound, id, CHAN_WEAPON, Snd_stickybomb_shoot_crit, 1.0, ATTN_NORM, 0, PITCH_NORM)
		fm_set_rendering(stickybomb, kRenderFxGlowShell, rgb[0], rgb[1], rgb[2], kRenderNormal, 32)
	} else {
		set_pev(stickybomb, PROJECTILE_CRITICAL, 0)
		engfunc(EngFunc_EmitSound, id, CHAN_WEAPON, Snd_stickybomb_shoot, 1.0, ATTN_NORM, 0, PITCH_NORM)
	}

	engfunc(EngFunc_SetModel, stickybomb, Bullet_demoman_secondary);
	static TeamName:team; team = rg_get_user_team(id);
	set_entvar(stickybomb, var_skin, team == TEAM_TERRORIST ? TF2_RED : TF2_BLUE);

	set_pev(stickybomb, pev_mins, { -5.0, -5.0, -5.0 })
	set_pev(stickybomb, pev_maxs, { 5.0, 5.0, 5.0 })
	set_pev(stickybomb, pev_solid, SOLID_TRIGGER)
	set_pev(stickybomb, pev_movetype, MOVETYPE_TOSS)
	set_pev(stickybomb, pev_owner, id)

	static Float:velocity[3], force
	force = floatround(get_pcvar_float(cvar_stickybomb_velocity) * (1.0 + get_pcvar_float(cvar_stickybomb_chargevelo) * g_stickybomb_charge[id] / 100.0))
	
	velocity_by_aim(id, force, velocity)
	set_pev(stickybomb, pev_velocity, velocity)

	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_BEAMFOLLOW);
	write_short(stickybomb);
	write_short(spr_trail);
	write_byte(12);
	write_byte(5);
	write_byte(rgb[0]);
	write_byte(rgb[1]);
	write_byte(rgb[2]);
	write_byte(200);
	message_end(); 

	fm_set_user_anim(id, anim_sb_fire)
	g_stickybomb_time[id] = get_gametime()
	g_stickybomb_status[id] = sb_idle
	g_stickybomb_charge[id] = 0.0
	g_stickybomb_clip[id]--

	static deployed, i
	deployed = g_stickybomb_num[id]
	if(deployed >= MAX_STICKYBOMB) {
		wpn_stickybomb_explode(g_stickybomb_entity[id][0])
		for(i = 1; i < MAX_STICKYBOMB; i++)
			g_stickybomb_entity[id][i - 1] = g_stickybomb_entity[id][i]
		g_stickybomb_entity[id][MAX_STICKYBOMB - 1] = stickybomb
	} else {
		g_stickybomb_entity[id][deployed] = stickybomb
		g_stickybomb_num[id]++
	}
	rg_set_user_ammo(id, WEAPON_P228, g_stickybomb_clip[id])
}

// stickybomb reload
public wpn_stickybomb_reload_start(id) {
	if(!g_stickybomb_ammo[id] || g_stickybomb_status[id] != sb_idle) return
	if(g_stickybomb_clip[id] >= get_pcvar_num(cvar_stickybomb_clip)) return
	if(g_stickybomb_time[id] + get_pcvar_float(cvar_stickybomb_rof) > get_gametime()) return
	fm_set_user_anim(id, anim_sb_reload_start)
	g_stickybomb_status[id] = sb_reload_start
	g_stickybomb_time[id] = get_gametime()
}
public wpn_stickybomb_reload_end(id) {
	if(!g_stickybomb_ammo[id] || g_stickybomb_status[id] != sb_reload_start) return
	if(g_stickybomb_clip[id] >= get_pcvar_num(cvar_stickybomb_clip)) 
		return
	fm_set_user_anim(id, anim_sb_idle)
	g_stickybomb_status[id] = sb_idle
	g_stickybomb_clip[id]++
	g_stickybomb_ammo[id]--
	rg_set_user_ammo(id, WEAPON_P228, g_stickybomb_clip[id])
	rg_set_user_bpammo(id, WEAPON_P228, g_stickybomb_ammo[id])
	if(g_stickybomb_clip[id] < get_pcvar_num(cvar_stickybomb_clip))
		wpn_stickybomb_reload_start(id)
}

// stickybomb draw
public wpn_stickybomb_draw(id) {
	if(g_stickybomb_status[id] != sb_draw) return
	g_stickybomb_status[id] = sb_idle
	fm_set_user_anim(id, anim_sb_idle)
}

// det

public wpn_stickybomb_det(id) {
	if(g_stickybomb_status[id] == sb_draw) return
	if(!g_stickybomb_num[id]) return
	for(new i = 0; i < g_stickybomb_num[id]; i++) {
		if(pev_valid(g_stickybomb_entity[id][i]))
			set_pev(g_stickybomb_entity[id][i], pev_nextthink, get_gametime() + float(i+1) * STICKYBOMB_DELAY)
	}
	g_stickybomb_num[id] = 0
	g_stickybomb_time[id] = get_gametime()
	g_stickybomb_status[id] = sb_idle
	engfunc(EngFunc_EmitSound, id, CHAN_STATIC, Snd_stickybomb_det, 1.0, ATTN_NORM, 0, PITCH_NORM)

}
// explode

public wpn_stickybomb_explode(stickybomb) {
	new enemy = pev(stickybomb, pev_owner)
	engfunc(EngFunc_EmitSound, stickybomb, CHAN_STATIC, Snd_explode, 1.0, ATTN_NORM, 0, PITCH_NORM)

	static Float:origin[3], Float:CvarDamage, Float:CvarRadius, CvarMinDmg, CvarMaxDmg
	pev(stickybomb, pev_origin, origin)

	FX_NewExplode(origin)
	FX_ExpDecal(origin)

	CvarDamage = get_pcvar_float(cvar_stickybomb_dmg)
	CvarRadius = get_pcvar_float(cvar_stickybomb_radius)
	CvarMinDmg = get_pcvar_num(cvar_stickybomb_mindmg)
	CvarMaxDmg = get_pcvar_num(cvar_stickybomb_maxdmg)

	static dmg, victim, Float:victim_origin[3], Float:distance, Float:force, victim_class[48], owner
	while((victim = engfunc(EngFunc_FindEntityInSphere, victim, origin, get_pcvar_float(cvar_stickybomb_radius))) != 0) {
		pev(victim, pev_classname, victim_class, charsmax(victim_class))

		if(FClassnameIs(victim, SentryBase_ClassName) || FClassnameIs(victim, Dispenser_ClassName) || FClassnameIs(victim, Telein_ClassName) || FClassnameIs(victim, Teleout_ClassName)) {
			owner = pev(victim, BUILD_OWNER)
			if(enemy == owner)
				continue
			if(isSameTeam(enemy, owner))
				continue
			distance = fm_distance_to_boxent(stickybomb, victim)
			dmg = floatround(CvarDamage - (floatmul(CvarDamage, floatdiv(distance, CvarRadius))))
			if(dmg < get_pcvar_num(cvar_stickybomb_mindmg)) dmg = get_pcvar_num(cvar_stickybomb_mindmg)
			else if(dmg > get_pcvar_num(cvar_stickybomb_maxdmg)) dmg = get_pcvar_num(cvar_stickybomb_maxdmg)
			switch(victim_class[0]) {
				case 's':ck_fakedamage_build(owner, enemy, dmg, TFM_STICKYBOMB, 1)
				case 'd':ck_fakedamage_build(owner, enemy, dmg, TFM_STICKYBOMB, 2)
				case 't': {
					if(FClassnameIs(victim, Telein_ClassName))
						ck_fakedamage_build(owner, enemy, dmg, TFM_STICKYBOMB, 3)
					else
						ck_fakedamage_build(owner, enemy, dmg, TFM_STICKYBOMB, 4)
				}
			}
		} else if(is_user_connected(victim)) {
			if(!is_user_alive(victim)) continue
			if(isSameTeam(enemy, victim)) continue
			pev(victim, pev_origin, victim_origin)
			distance = vector_distance(origin, victim_origin)
			dmg = floatround(CvarDamage - (floatmul(CvarDamage, floatdiv(distance, CvarRadius))))
			if(dmg < CvarMinDmg) dmg = CvarMinDmg
			else if(dmg > CvarMaxDmg) dmg = CvarMaxDmg
			
			force = (1.0 - distance / CvarRadius) * get_pcvar_float(cvar_stickybomb_force)

			if(enemy != victim) {
				if(pev(stickybomb, PROJECTILE_CRITICAL)) {
					dmg *= get_pcvar_num(cvar_critical_dmg)
					FX_Critical(enemy, victim)
				}
			} else {
				if(!(pev(victim, pev_flags) & FL_ONGROUND) || pev(victim, pev_flags) & FL_DUCKING)
					force *= 1.5
			}

			ck_knockback_explode(victim, origin, force)
			if(g_charge_shield[g_healed_by[victim]] && ck_get_user_assistance(victim) > 0)
				continue
			if(g_charge_shield[victim])
				continue

			ck_fakedamage(victim, enemy, TFM_STICKYBOMB, dmg, 1, pev(stickybomb, PROJECTILE_CRITICAL) ? 1 : 0)
		}
	}
	engfunc(EngFunc_RemoveEntity, stickybomb)
}

// Toolbox

public wpn_toolbox_switch(id) {
	switch(g_engineer_c4[id]) {
		case TFM_TOOLBOX: {
			g_engineer_c4[id] = TFM_PDA
			set_entvar(id, var_viewmodel, Mdl_v_pda)
			set_entvar(id, var_weaponmodel, Mdl_p_pda)
		}
		case TFM_PDA: {
			g_engineer_c4[id] = TFM_TOOLBOX
			set_entvar(id, var_viewmodel, Mdl_v_toolbox)
			set_entvar(id, var_weaponmodel, Mdl_p_toolbox)
		}
	}
	engfunc(EngFunc_EmitSound, id, CHAN_WEAPON, "items/gunpickup3.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	ck_showhud_status(id)
}

// from weapons_maxclip.sma
public fw_ItemAttachToPlayer_AWP(entity, id) {
	if(get_pdata_int(entity, m_fKnown, 4)) return
	set_pdata_int(entity, m_iClip, get_pcvar_num(cvar_awp_clip), 4)
}

public fw_ItemAttachToPlayer_P228(entity, id) {
	if(get_pdata_int(entity, m_fKnown, 4)) return
	set_pdata_int(entity, m_iClip, get_pcvar_num(cvar_usp_clip), 4)
}

public fw_ItemPostFrame_AWP(entity) {
	static id ; id = get_member(entity, m_pPlayer)
	static fInReload ; fInReload = get_pdata_int(entity, m_fInReload, 4)
	static Float:flNextAttack ; flNextAttack = get_member(id, m_flNextAttack)

	static iAmmoType ; iAmmoType = m_rgAmmo_player_Slot0 + get_pdata_int(entity, m_iPrimaryAmmoType, 4)
	static iClip ; iClip = get_pdata_int(entity, m_iClip, 4)
	static iBpAmmo ; iBpAmmo = get_pdata_int(id, iAmmoType, 5)

	if(fInReload && flNextAttack <= 0.0)
	{
		new i = min(get_pcvar_num(cvar_awp_clip) - iClip, iBpAmmo)
		set_pdata_int(entity, m_iClip, iClip + i, 4)
		set_pdata_int(id, iAmmoType, iBpAmmo - i, 5)

		set_pdata_int(entity, m_fInReload, 0, 4)
	}
}

public fw_ItemPostFrame_P228(entity) {
	static id ; id = get_member(entity, m_pPlayer)
	static fInReload ; fInReload = get_pdata_int(entity, m_fInReload, 4)
	static Float:flNextAttack ; flNextAttack = get_member(id, m_flNextAttack)

	static iAmmoType ; iAmmoType = m_rgAmmo_player_Slot0 + get_pdata_int(entity, m_iPrimaryAmmoType, 4)
	static iClip ; iClip = get_pdata_int(entity, m_iClip, 4)
	static iBpAmmo ; iBpAmmo = get_pdata_int(id, iAmmoType, 5)

	if(fInReload && flNextAttack <= 0.0)
	{
		new i = min(get_pcvar_num(cvar_usp_clip) - iClip, iBpAmmo)
		set_pdata_int(entity, m_iClip, iClip + i, 4)
		set_pdata_int(id, iAmmoType, iBpAmmo - i, 5)

		set_pdata_int(entity, m_fInReload, 0, 4)
	}
}

public fw_Touch_CapturePoint_Red(entity, id) {
	return xTouch_CapturePoint(entity, id, TEAM_TERRORIST); 
}
public fw_Touch_CapturePoint_Blue(entity, id) {
	return xTouch_CapturePoint(entity, id, TEAM_CT); 
}
stock xTouch_CapturePoint(entity, id, TeamName:team) {
	if(!pev_valid(entity))
		return HAM_IGNORED; 

	if(!(1 <= id <= MaxClients)) 
		return HAM_SUPERCEDE
	if(!is_user_alive(id)) 
		return HAM_SUPERCEDE

	if(g_capture[id] + pev(entity, MAP_DISPATCH3) < get_gametime()) 
		return HAM_SUPERCEDE

	static need, status, cp_num, progress, local, color
	color = (team == TEAM_TERRORIST) ? TF2_RED : TF2_BLUE

	g_capture[id] = get_gametime()
	need = pev(entity, MAP_DISPATCH2)
	status = pev(entity, MAP_CPSTATUS)
	if(rg_get_user_team(id) == TEAM_TERRORIST) {
		cp_num = pev(entity, MAP_CPNUMS)
		progress = g_cp_progress[color][cp_num]
		if(progress >= 100) {
			status = cp_uncapturing
			set_pev(entity, MAP_CPSTATUS, status)
			g_cp_progress[color][cp_num]--
		} else if(status == cp_uncapturing && progress > 0) {
			g_cp_progress[color][cp_num]--
		} else if(status == cp_uncapturing && !progress) {
			g_cp_progress[color][cp_num] = 0
			status = cp_normal
			set_pev(entity, MAP_CPSTATUS, status)
		} else if(status == cp_capturing) {
			status = cp_defending
			set_pev(entity, MAP_CPSTATUS, status)
		}
	}	
	else 
	{
		if(need > g_cp_local[color] || status == cp_defending || status == cp_uncapturing) 
			return HAM_SUPERCEDE
		cp_num = pev(entity, MAP_CPNUMS)
		progress = g_cp_progress[color][cp_num]
		if(progress >= 100) 
			return HAM_SUPERCEDE
		
		local = pev(entity, MAP_DISPATCH)
		if(!progress) {
			status = cp_capturing
			set_pev(entity, MAP_CPSTATUS, status)
			g_cp_progress[color][cp_num]++
		} else if(progress > 0 && progress < 100) {
			g_cp_progress[color][cp_num]++
		} else if(progress >= 100) {
			g_cp_local[color] += local
			check_end()
		}
	}
	return HAM_SUPERCEDE
}

public fw_Think_CapturePoint(entity) {
	if(!pev_valid(entity)) return HAM_SUPERCEDE
	new status = pev(entity, MAP_CPSTATUS)
	switch(status) {
		case cp_capturing, cp_uncapturing, cp_defending: set_pev(entity, MAP_CPSTATUS, cp_normal)
	}
	set_pev(entity, pev_nextthink, get_gametime() + 2.0)
	return HAM_SUPERCEDE
}

public fw_Touch_SupplyDoor_Red(entity, id) {
	if(!(1 <= id <= MaxClients)) return HAM_SUPERCEDE
	if(!is_user_alive(id)) return HAM_SUPERCEDE
	if(rg_get_user_team(id) == TEAM_TERRORIST) return HAM_SUPERCEDE
	return HAM_IGNORED
}

public fw_Touch_SupplyDoor_Blue(entity, id) {
	if(!(1 <= id <= MaxClients)) return HAM_SUPERCEDE
	if(!is_user_alive(id)) return HAM_SUPERCEDE
	if(rg_get_user_team(id) == TEAM_CT) return HAM_SUPERCEDE
	return HAM_IGNORED
}

public fw_Think_Projectile(entity) {
	if(!pev_valid(entity)) return
	if(FClassnameIs(entity, g_EntityClassnames[RpgRocket_ClassName])) {
		static Float:origin[3]; pev(entity, pev_origin, origin)
		engfunc(EngFunc_PlaybackEvent, 0, entity, 26, 0.0, origin, Float: {0.0, 0.0, 0.0}, 5.0, 5.0, 0, 2, 0, 0); 
		set_pev(entity, pev_nextthink, get_gametime() + SMOKETRAIL_RATE)
	}
	else if(FClassnameIs(entity, g_EntityClassnames[DemoGren_Classname]))
		wpn_grenade_explode(entity)
	else if(FClassnameIs(entity, g_EntityClassnames[DemoGren_Classname]))
		wpn_stickybomb_explode(entity)
}

public fw_Touch_Projectile(entity, touched) {
	if(!pev_valid(entity)) return
	static owner; owner = pev(entity, pev_owner)
	if(owner == touched) return

	if(FClassnameIs(entity, g_EntityClassnames[RpgRocket_ClassName]))
		fw_Touch_RPGRocket(entity, touched)
	else if(FClassnameIs(entity, g_EntityClassnames[SentryRocket_Classname]))
		fw_Touch_SentryRocket(entity, touched)
	else if(FClassnameIs(entity, g_EntityClassnames[DemoGren_Classname]))
		fw_Touch_Grenade(entity, touched)
	else if(FClassnameIs(entity, g_EntityClassnames[DemoGren_Classname]))
		fw_Touch_Stickybomb(entity, touched)
	else if(FClassnameIs(entity, g_EntityClassnames[MedicSyringe_Classname]))
		fw_Touch_Syringe(entity, touched)
}

public fw_Touch_RPGRocket(entity, touched) {
	if(!pev_valid(entity)) return
	if(is_user_alive(touched)) {
		new owner = pev(entity, pev_owner)
		if(owner == touched) return
	}
	wpn_rocket_explode(entity)
}

public fw_Touch_SentryRocket(rocket, touched) {
	if(!pev_valid(rocket)) return
	static enemy 
	enemy = pev(rocket, pev_owner)
	engfunc(EngFunc_EmitSound, rocket, CHAN_STATIC, Snd_explode, 1.0, ATTN_NORM, 0, PITCH_NORM)

	static Float:origin[3], Float:CvarDamage, Float:CvarRadius, CvarMinDmg, CvarMaxDmg
	pev(rocket, pev_origin, origin)

	FX_NewExplode(origin)
	FX_ExpDecal(origin)

	CvarDamage = get_pcvar_float(cvar_sentry_rocket_dmg)
	CvarRadius = get_pcvar_float(cvar_sentry_rocket_radius)
	CvarMinDmg = get_pcvar_num(cvar_sentry_rocket_mindmg)
	CvarMaxDmg = get_pcvar_num(cvar_sentry_rocket_maxdmg)

	static dmg, victim, Float:victim_origin[3], Float:distance, Float:force, victim_class[48]
	victim = -1
	while((victim = engfunc(EngFunc_FindEntityInSphere, victim, origin, get_pcvar_float(cvar_sentry_rocket_radius))) != 0) {
		pev(victim, pev_classname, victim_class, charsmax(victim_class))
		if(FClassnameIs(victim, SentryBase_ClassName) || FClassnameIs(victim, Dispenser_ClassName) || FClassnameIs(victim, Telein_ClassName) || FClassnameIs(victim, Teleout_ClassName)) {
			new owner = pev(victim, BUILD_OWNER)
			if(enemy == owner)
				continue
			if(isSameTeam(enemy, owner))
				continue
			distance = fm_distance_to_boxent(rocket, victim)

			dmg = floatround(CvarDamage - (floatmul(CvarDamage, floatdiv(distance, CvarRadius))))

			if(dmg < CvarMinDmg) 
				dmg = CvarMinDmg
			else if(dmg > CvarMaxDmg) 
				dmg = CvarMaxDmg

			switch(victim_class[0]) {
				case 's':ck_fakedamage_build(owner, enemy, dmg, TFM_SENTRYROCKET, 1)
				case 'd':ck_fakedamage_build(owner, enemy, dmg, TFM_SENTRYROCKET, 2)
				case 't': {
					if(FClassnameIs(victim, Telein_ClassName))
						ck_fakedamage_build(owner, enemy, dmg, TFM_SENTRYROCKET, 3)
					else
						ck_fakedamage_build(owner, enemy, dmg, TFM_SENTRYROCKET, 4)
				}
			}
		} else if(FClassnameIs(victim, "player")) {
			if(!is_user_alive(victim)) continue
			pev(victim, pev_origin, victim_origin)
			distance = vector_distance(origin, victim_origin)
			dmg = floatround(CvarDamage - (floatmul(CvarDamage, floatdiv(distance, CvarRadius))))

			if(dmg < CvarMinDmg) 
				dmg = CvarMinDmg
			else if(dmg > CvarMaxDmg) 
				dmg = CvarMaxDmg

			if(isSameTeam(enemy, victim)) continue

			force = (1.0 - distance / CvarRadius) * get_pcvar_float(cvar_sentry_rocket_force)
			if(enemy != victim) {
				if(pev(rocket, PROJECTILE_CRITICAL)) {
					dmg *= get_pcvar_num(cvar_critical_dmg)
					FX_Critical(enemy, victim)
				}
			} else {
				if(!(pev(victim, pev_flags) & FL_ONGROUND) || pev(victim, pev_flags) & FL_DUCKING)
					force *= 1.5
			}

			ck_knockback_explode(victim, origin, force)
			if(g_charge_shield[g_healed_by[victim]] && ck_get_user_assistance(victim) > 0)
				continue
			if(g_charge_shield[victim])
				continue

			ck_fakedamage(victim, enemy, TFM_REFLECTROCKET, dmg, 1, pev(rocket, PROJECTILE_CRITICAL) ? 1 : 0)

		}
	}
	engfunc(EngFunc_RemoveEntity, rocket)
}

public fw_Touch_Grenade(entity, touched) {
	if(!pev_valid(entity)) return
	new owner = pev(entity, pev_owner)
	if(!is_user_alive(touched)) return
	if(get_user_team(owner) == get_user_team(touched)) return
	wpn_grenade_explode(entity)
}

public fw_Touch_Stickybomb(entity, touched) {
	if(!pev_valid(entity)) return
	if(pev_valid(touched)) return
	set_pev(entity, pev_movetype, MOVETYPE_NONE)
	set_pev(entity, pev_velocity, Float: {0.0, 0.0, 0.0})
}

public fw_Touch_Syringe(entity, touched) {
	if(!pev_valid(entity)) return

	if(!is_user_alive(touched)) {
		engfunc(EngFunc_RemoveEntity, entity)
		return; 
	}
	static id; 
	id = pev(entity, pev_owner)
	
	if(isSameTeam(id, touched)) 
		return; 

	static maxhealth, vam, Float:dmg, Float:force
	dmg = random_float(get_pcvar_float(cvar_syringegun_mindmg), get_pcvar_float(cvar_syringegun_maxdmg))
	force = dmg * get_pcvar_float(cvar_syringegun_force)
	ck_knockback(touched, id, force)
	maxhealth = ck_get_user_maxhealth(id)
	vam = get_pcvar_num(cvar_syringegun_vampiric)

	if(g_critical_on[id]) {
		dmg *= get_pcvar_num(cvar_critical_dmg)
		ck_fakedamage(touched, id, TFM_SYRINGEGUN, floatround(dmg), 0, 1)
		FX_Critical(id, touched)
	} else {
		ck_fakedamage(touched, id, TFM_SYRINGEGUN, floatround(dmg), 0, 0)
	}
	
	if(get_user_health(id) + vam > maxhealth)
		fm_set_user_health(id, maxhealth)
	else
		fm_set_user_health(id, get_user_health(id) + vam)
}

public clcmd_block(id) {
	return PLUGIN_HANDLED
}
public fw_Block() {
	return HAM_SUPERCEDE
}

public fw_EntitySpawn(entity) {
	if(!pev_valid(entity))
		return FMRES_IGNORED
	static classname[32]
	pev(entity, pev_classname, classname, charsmax(classname))

	static i
	for (i = 0; i < sizeof g_load_remove; i++) {
		if(FClassnameIs(entity, g_load_remove[i])) {
			engfunc(EngFunc_RemoveEntity, entity)
			return FMRES_SUPERCEDE
		}
	}
	return FMRES_IGNORED
}

public fw_KeyValue(i_Entid, i_Kvdid) {
	if(!pev_valid(i_Entid)) return FMRES_IGNORED; 
	new s_KeyName[32], s_KeyValue[32]
	get_kvd (i_Kvdid, KV_KeyName, s_KeyName, charsmax(s_KeyName)); 
	get_kvd (i_Kvdid, KV_Value, s_KeyValue, charsmax(s_KeyValue)); 
	if(equal(s_KeyName, "map_dispatch")) {
		set_pev(i_Entid, MAP_DISPATCH, str_to_num(s_KeyValue))
	} else if(equal(s_KeyName, "map_dispatch2")) {
		set_pev(i_Entid, MAP_DISPATCH2, str_to_num(s_KeyValue))
	} else if(equal(s_KeyName, "map_dispatch3")) {
		set_pev(i_Entid, MAP_DISPATCH3, s_KeyValue)
	} else if(equal(s_KeyName, "map_obj")) {
		if(equal(s_KeyValue, "capture_red") && g_cp_pointnums[TF2_RED] < CP_MAXPOINTS - 1) {
			init_CapturePoint(i_Entid, TF2_RED)
		}else if(equal(s_KeyValue, "supplydoor_red")) {
			init_SupplyDoor(i_Entid, TF2_RED)
		}else if(equal(s_KeyValue, "capture_blue") && g_cp_pointnums[TF2_BLUE] < CP_MAXPOINTS - 1) {
			init_CapturePoint(i_Entid, TF2_BLUE)
		}else if(equal(s_KeyValue, "supplydoor_blue")) {
			init_SupplyDoor(i_Entid, TF2_BLUE)
		}
	}
	return FMRES_IGNORED;
}

stock drop_weapons(id, dropwhat) {
	static weapons[32], num, i
	num = 0
	get_user_weapons(id, weapons, num)
	for (i = 0; i < num; i++) {
		if((dropwhat == 1 && ((1<<weapons[i]) & PRIMARY_WEAPONS)) || (dropwhat == 2 && ((1<<weapons[i]) & SECONDARY_WEAPONS))) {
			static wname[32]; get_weaponname(weapons[i], wname, charsmax(wname))
			engclient_cmd(id, "drop", wname)
		}
	}
}

stock fm_set_user_anim(const pPlayer, const iAnimNum, bool:bSkipLocal = false)
{
	static aPlayers[32], iCount, pClient
	get_players(aPlayers, iCount, "ch") // skip bot's & hltv
	
	for (--iCount; iCount >= 0; iCount--)
	{
		pClient = aPlayers[iCount]

		if ((!bSkipLocal && pPlayer == pClient) 
			|| (get_entvar(pClient, var_iuser2) == pPlayer && get_entvar(pClient, var_iuser1) == OBS_IN_EYE))
		{
			set_entvar(pClient, var_weaponanim, iAnimNum)

			message_begin(MSG_ONE, SVC_WEAPONANIM, .player = pClient)
			write_byte(iAnimNum)
			write_byte(0)
			message_end()
		}
	}
}

stock fm_get_user_model(id, model[], len) {
	//return engfunc(EngFunc_InfoKeyValue, engfunc(EngFunc_GetInfoKeyBuffer, id), "model", model, len)
	get_user_info(id, "model", model, len)	
}

stock fm_set_user_money(index, money, show = false) {
	set_pdata_int(index, OFFSET_CSMONEY, money); 
	if(show) {
		message_begin(MSG_ONE, get_user_msgid("Money"), {0, 0, 0}, index); 
		write_long(money); 
		write_byte(1); 
		message_end(); 
	}
}

stock fm_set_entity_view(entity, Float:Target[3]) {
	new Float:Origin[3], Float:Angles[3]
	pev(entity, pev_origin, Origin)
	Target[0] -= Origin[0]
	Target[1] -= Origin[1]
	Target[2] -= Origin[2]
	vector_to_angle(Target, Angles)
	Angles[0] = 360.0 - Angles[0]
	set_pev(entity, pev_v_angle, Angles)
	Angles[0] *= -1
	set_pev(entity, pev_angles, Angles)
	set_pev(entity, pev_fixangle, 1)
}
stock PlaySound(id, const snd[]) {
	client_cmd(id, "spk ^"%s^"", snd)
}

public message_weappickup(msg_id, msg_dest, id) {
	return PLUGIN_HANDLED; 
}
public message_ammopickup(msg_id, msg_dest, id) {
	return PLUGIN_HANDLED; 
}
public message_scoreinfo(msg_id, msg_dest, id) {
	if(!is_user_connected(id)) return; 
	set_msg_arg_int(2, get_msg_argtype(2), g_score[id])
	set_msg_arg_int(3, get_msg_argtype(3), g_death[id])
}
public message_teamscore() {
	static team[2]
	get_msg_arg_string(1, team, charsmax(team))
	switch (team[0]) {
		case 'C': set_msg_arg_int(2, get_msg_argtype(2), g_score_team[TF2_BLUE])
		case 'T': set_msg_arg_int(2, get_msg_argtype(2), g_score_team[TF2_RED])
	}
}
public message_curweapon(msg_id, msg_dest, id) {
	if(!is_user_alive(id) || get_msg_arg_int(1) != 1) return; 
	new weapon = get_msg_arg_int(2)

	if(weapon == CSW_M3)
	{
		switch(g_class[id]) {
			case CLASS_SCOUT: {
				set_msg_arg_int(3, get_msg_argtype(3), g_scattergun_clip[id])
				rg_set_user_bpammo(id, WEAPON_M3, g_scattergun_ammo[id])
			}
			case CLASS_HEAVY: {
				set_msg_arg_int(3, get_msg_argtype(3), 0)
				rg_set_user_bpammo(id, WEAPON_M3, g_minigun_clip[id])
			}
			case CLASS_SOLDIER: {
				set_msg_arg_int(3, get_msg_argtype(3), g_rocket_clip[id])
				rg_set_user_bpammo(id, WEAPON_M3, g_rocket_ammo[id])
			}
			case CLASS_MEDIC: {
				set_msg_arg_int(3, get_msg_argtype(3), 0)
				rg_set_user_bpammo(id, WEAPON_M3, floatround(g_medic_charge[id]))
			}
			case CLASS_ENGINEER: {
				set_msg_arg_int(3, get_msg_argtype(3), g_shotgun_clip[id])
				rg_set_user_bpammo(id, WEAPON_M3, g_shotgun_ammo[id])
			}
			case CLASS_DEMOMAN: {
				set_msg_arg_int(3, get_msg_argtype(3), g_grenade_clip[id])
				rg_set_user_bpammo(id, WEAPON_M3, g_grenade_ammo[id])
			}
		}
	}
	else if(weapon == CSW_P228)
	{
		switch(g_class[id])
		{
			case CLASS_HEAVY: {
				set_msg_arg_int(3, get_msg_argtype(3), g_shotgun_clip[id])
				rg_set_user_bpammo(id, WEAPON_P228, g_shotgun_ammo[id])
			}
			case CLASS_SOLDIER: {
				set_msg_arg_int(3, get_msg_argtype(3), g_shotgun_clip[id])
				rg_set_user_bpammo(id, WEAPON_P228, g_shotgun_ammo[id])
			}
			case CLASS_SNIPER: {
				set_msg_arg_int(3, get_msg_argtype(3), g_smg_clip[id])
				rg_set_user_bpammo(id, WEAPON_P228, g_smg_ammo[id])
			}
			case CLASS_MEDIC: {
				set_msg_arg_int(3, get_msg_argtype(3), g_syringegun_clip[id])
				rg_set_user_bpammo(id, WEAPON_P228, g_syringegun_ammo[id])
			}
			case CLASS_DEMOMAN: {
				set_msg_arg_int(3, get_msg_argtype(3), g_stickybomb_clip[id])
				rg_set_user_bpammo(id, WEAPON_P228, g_stickybomb_ammo[id])
			}
		}
	}
}
public message_money(msg_id, msg_dest, id) {
	set_pdata_int(id, OFFSET_CSMONEY, 0, OFFSET_LINUX); 
	return PLUGIN_HANDLED; 
}
public message_health(msg_id, msg_dest, msg_entity) {
	static health
	health = get_msg_arg_int(1)

	if(health < 256) return; 

	if(floatfract(float(health)/256.0) == 0.0)
		fm_set_user_health(msg_entity, health-1)

	set_msg_arg_int(1, get_msg_argtype(1), 255)
}
public message_status(iMsgId, msg_dest, id) {
	return PLUGIN_HANDLED
}
public message_hideweapon() {
	set_msg_arg_int(1, get_msg_argtype(1), get_msg_arg_int(1) | (1<<5)); 
}
public message_textmsg() {
	static textmsg[32]
	get_msg_arg_string(2, textmsg, charsmax(textmsg))
	if(equal(textmsg, "#Hostages_Not_Rescued") || equal(textmsg, "#Round_Draw") ||
	equal(textmsg, "#Terrorists_Win") || equal(textmsg, "#CTs_Win") ||
	equal(textmsg, "#C4_Arming_Cancelled") || equal(textmsg, "#C4_Plant_At_Bomb_Spot") ||
	equal(textmsg, "#Killed_Hostage") || equal(textmsg, "#Game_will_restart_in"))
		return PLUGIN_HANDLED
	return PLUGIN_CONTINUE
}
public message_saytext() {
	static text[64]
	get_msg_arg_string(2, text, charsmax(text))
	if(equal(text, "#Cstrike_Name_Change"))
		return PLUGIN_HANDLED
	return PLUGIN_CONTINUE
}
public message_teaminfo(msg_id, msg_dest) {
	if(msg_dest != MSG_ALL && msg_dest != MSG_BROADCAST) return PLUGIN_CONTINUE
	if(g_gamemode != mode_normal) return PLUGIN_CONTINUE
	if(g_round == round_end) return PLUGIN_CONTINUE
	new id = get_msg_arg_int(1)
	static team[2]
	get_msg_arg_string(2, team, charsmax(team))
	if(team[0] == 'U' || team[0] == 'S') return PLUGIN_CONTINUE

	new red = get_team_num(TEAM_TERRORIST)
	new blue = get_team_num(TEAM_CT)
	if(!red && !blue) {
		check_end()
	} else {
		client_cmd(id, "say !spawn")
	}

	return PLUGIN_CONTINUE
}
public message_corpse() {
	set_msg_arg_string(1, g_curmodel[get_msg_arg_int(12)])
	return PLUGIN_HANDLED
}
public message_hostagepos() {
	return PLUGIN_HANDLED; 
}
public message_deathmsg(msg_id, msg_dest, id) {
	static killed; killed = get_msg_arg_int(2)
	if(get_msg_arg_int(3))
		g_critkilled[killed] = 1
	else
		g_critkilled[killed] = 0
	return PLUGIN_HANDLED
}

stock ck_get_user_classname(id, classname[], len) {
	if(!(1 <= id <= MaxClients)) return;
	strtoupper(ClassConfig[g_class[id]][ClassName])
	format(classname, len, "%L", id, fmt("NAME_CLASS_%s", ClassConfig[g_class[id]][ClassName]))
	return; 
}

stock ck_get_user_classname_willbe(id, classname[], len) {
	if(!(1 <= id <= MaxClients)) return;
	strtoupper(ClassConfig[g_willbeclass[id]][ClassName])
	format(classname, len, "%L", id, fmt("NAME_CLASS_%s", ClassConfig[g_willbeclass[id]][ClassName]))
	return;
}

stock ck_get_user_weapon_name(id, classname[], len) {
	if(!is_user_alive(id)) return
	
	strtoupper(ClassConfig[g_class[id]][ClassName])
	switch(rg_get_user_active_weapon(id)) {
		case WEAPON_M3: format(classname, len, " %L ", id, fmt("NAME_PRIMARY_%s", ClassConfig[g_class[id]][ClassName])); 
		case WEAPON_P228: format(classname, len, " %L ", id, fmt("NAME_SECONDARY_%s", ClassConfig[g_class[id]][ClassName])); 
		case WEAPON_KNIFE: format(classname, len, " %L ", id, fmt("NAME_MELEE_%s", ClassConfig[g_class[id]][ClassName])); 

		case WEAPON_C4: {
			if(g_class[id] == CLASS_ENGINEER) 
				format(classname, len, "%L", id, (g_engineer_c4[id] == TFM_TOOLBOX) ? "NAME_CONSTRUCTION_PDA" : "NAME_DESTRUCTION_PDA")
			else 
				format(classname, len, "%L", id, "NAME_WEAPON_UNKNOW")
		}
	}
	return
}

stock ck_get_user_assistance(id) {
	if(!is_user_alive(id)) return 0
	static assistant
	if(g_healed_by[id])
		assistant = g_healed_by[id]
	else
		assistant = 0
	return assistant
}

stock FX_UpdateScore(id) {
	if(!(1 <= id <= MaxClients)) return

	set_pev(id, pev_frags, float(g_score[id])); 
	set_pdata_int(id, OFFSET_CSDEATHS, g_death[id]); 

	static team; team = get_user_team(id)

	message_begin(MSG_ALL, g_msgScoreInfo)
	write_byte(id)
	write_short(g_score[id])
	write_short(g_death[id])
	write_short(0)
	write_short(team)
	message_end()

	if(team == 0 || team == 3) return
	message_begin(MSG_ALL, g_msgTeamScore); 
	write_string(CS_Teams[team]); 
	write_short(g_score_team[team]); 
	message_end(); 
}

stock ck_reset_user_var(id) {
	g_sniper_charge[id] = 0.0
	g_medic_charge[id] = 0.0
	g_engineer_metal[id] = 100
	g_stickybomb_num[id] = 0
	g_critical[id] = get_pcvar_num(cvar_critical_percent)

}

stock bool:is_back_face(enemy, id) {
	new Float:anglea[3], Float:anglev[3]
	pev(enemy, pev_v_angle, anglea)
	pev(id, pev_v_angle, anglev)
	new Float:angle = anglea[1] - anglev[1]
	if(angle < -180.0) angle += 360.0
	if(angle <= 90.0 && angle >= -90.0) return true
	return false
}

stock ck_get_user_maxhealth(id) {
	if(!is_user_alive(id))
		return 0
	static maxhealth
	maxhealth = get_pcvar_num(cvar_class_hp[g_class[id]])
	return maxhealth
}

stock bool:ck_give_user_health(id, percent) {
	if(!is_user_alive(id))
		return false
	if(percent > 100)
		percent = 100
	if(percent <= 0)
		return false
	static userhealth, givehealth, maxhealth
	maxhealth = ck_get_user_maxhealth(id)
	givehealth = maxhealth * percent / 100
	userhealth = get_user_health(id)
	if(userhealth >= maxhealth) {
		return false
	} else if(userhealth + givehealth > maxhealth) {
		fm_set_user_health(id, maxhealth)
	} else if(userhealth + givehealth <= maxhealth) {
		fm_set_user_health(id, userhealth + givehealth)
	} else {
		return false
	}
	return true
}
stock bool:ck_give_user_health_amount(id, amount) {
	if(!is_user_alive(id))
		return false
	if(amount <= 0)
		return false
	static maxhealth, userhealth
	maxhealth = ck_get_user_maxhealth(id)
	userhealth = get_user_health(id)
	if(userhealth >= maxhealth) {
		return false
	} else if(userhealth + amount > maxhealth) {
		fm_set_user_health(id, maxhealth)
	} else if(userhealth + amount <= maxhealth) {
		fm_set_user_health(id, userhealth + amount)
	} else {
		return false
	}
	return true
}
stock ck_get_user_ammo(id) {
	if(!is_user_alive(id))
		return -1
	static percent, clip, ammo, wpn
	wpn = get_user_weapon(id, clip, ammo)
	switch(wpn) {
		case CSW_M3: {
			switch(g_class[id]) {
				case CLASS_SCOUT: percent = g_scattergun_ammo[id] * 100 / get_pcvar_num(cvar_scattergun_ammo)
				case CLASS_HEAVY: percent = g_minigun_clip[id] * 100 / get_pcvar_num(cvar_minigun_clip)
				case CLASS_SOLDIER: percent = g_rocket_ammo[id] * 100 / get_pcvar_num(cvar_rocket_ammo)
				case CLASS_MEDIC: percent = -1
				case CLASS_ENGINEER: percent = g_shotgun_ammo[id] * 100 / get_pcvar_num(cvar_shotgun_ammo)
				case CLASS_DEMOMAN: percent = g_grenade_ammo[id] * 100 / get_pcvar_num(cvar_grenade_ammo)
				default: return -1
			}
		}
		case CSW_P228: {
			switch(g_class[id]) {
				case CLASS_SCOUT: percent = g_usp_ammo[id] * 100 / get_pcvar_num(cvar_usp_ammo)
				case CLASS_HEAVY: percent = g_shotgun_ammo[id] * 100 / get_pcvar_num(cvar_shotgun_ammo)
				case CLASS_SOLDIER: percent = g_shotgun_ammo[id] * 100 / get_pcvar_num(cvar_shotgun_ammo)
				case CLASS_SNIPER: percent = g_smg_ammo[id] * 100 / get_pcvar_num(cvar_smg_ammo)
				case CLASS_MEDIC: percent = g_syringegun_ammo[id] * 100 / get_pcvar_num(cvar_syringegun_ammo)
				case CLASS_DEMOMAN: percent = g_stickybomb_ammo[id] * 100 / get_pcvar_num(cvar_stickybomb_ammo)
				default: return -1
			}
		}
		case CSW_C4: {
			switch(g_class[id]) {
				case CLASS_ENGINEER: percent = g_engineer_metal[id]
				default: return -1
			}
		}
		case CSW_AWP: percent = ammo * 100 / get_pcvar_num(cvar_awp_ammo)
		case CSW_KNIFE: {
			switch(g_class[id]) {
				case CLASS_ENGINEER: percent = g_engineer_metal[id]
				default: return -1
			}
		}
		default: percent = -1
	}
	return percent
}

stock bool:ck_give_user_ammo(id, percent) {
	if(!is_user_alive(id))
		return false
	if(percent > 100)
		percent = 100
	else if(percent < 0)
		return false
	static maxammo, giveammo, ammo
	switch(rg_get_user_active_weapon(id)) {
		case WEAPON_M3: {
			switch(g_class[id]) {
				case CLASS_SCOUT: {
					maxammo = get_pcvar_num(cvar_scattergun_ammo)
					giveammo = maxammo * percent / 100
					if(giveammo < 1)
						giveammo = 1
					else if(g_scattergun_ammo[id] >= maxammo)
						return false
					else if(g_scattergun_ammo[id] > maxammo - giveammo && g_scattergun_ammo[id] < maxammo)
						g_scattergun_ammo[id] = maxammo
					else if(g_scattergun_ammo[id] <= maxammo - giveammo)
						g_scattergun_ammo[id] += giveammo
					rg_set_user_bpammo(id, WEAPON_M3, g_scattergun_ammo[id])
				}
				case CLASS_HEAVY: {
					maxammo = get_pcvar_num(cvar_minigun_clip)
					giveammo = maxammo * percent / 100
					if(giveammo < 1)
						giveammo = 1
					else if(g_minigun_clip[id] >= maxammo)
						return false
					else if(g_minigun_clip[id] > maxammo - giveammo && g_minigun_clip[id] < maxammo)
						g_minigun_clip[id] = maxammo
					else if(g_minigun_clip[id] <= maxammo - giveammo)
						g_minigun_clip[id] += giveammo
					rg_set_user_bpammo(id, WEAPON_M3, g_minigun_clip[id])
				}
				case CLASS_SOLDIER: {
					maxammo = get_pcvar_num(cvar_rocket_ammo)
					giveammo = maxammo * percent / 100
					if(giveammo < 1)
						giveammo = 1
					else if(g_rocket_ammo[id] >= maxammo)
						return false
					else if(g_rocket_ammo[id] > maxammo - giveammo && g_rocket_ammo[id] < maxammo)
						g_rocket_ammo[id] = maxammo
					else if(g_rocket_ammo[id] <= maxammo - giveammo)
						g_rocket_ammo[id] += giveammo
					rg_set_user_bpammo(id, WEAPON_M3, g_rocket_ammo[id])
				}
				case CLASS_MEDIC: percent = -1
				case CLASS_ENGINEER: {
					maxammo = get_pcvar_num(cvar_shotgun_ammo)
					giveammo = maxammo * percent / 100
					if(giveammo < 1)
						giveammo = 1
					else if(g_shotgun_ammo[id] >= maxammo)
						return false
					else if(g_shotgun_ammo[id] > maxammo - giveammo && g_shotgun_ammo[id] < maxammo)
						g_shotgun_ammo[id] = maxammo
					else if(g_shotgun_ammo[id] <= maxammo - giveammo)
						g_shotgun_ammo[id] += giveammo
					rg_set_user_bpammo(id, WEAPON_M3, g_shotgun_ammo[id])
				}
				case CLASS_DEMOMAN: {
					maxammo = get_pcvar_num(cvar_grenade_ammo)
					giveammo = maxammo * percent / 100
					if(giveammo < 1)
						giveammo = 1
					else if(g_grenade_ammo[id] >= maxammo)
						return false
					else if(g_grenade_ammo[id] > maxammo - giveammo && g_grenade_ammo[id] < maxammo)
						g_grenade_ammo[id] = maxammo
					else if(g_grenade_ammo[id] <= maxammo - giveammo)
						g_grenade_ammo[id] += giveammo
					rg_set_user_bpammo(id, WEAPON_M3, g_grenade_ammo[id])
				}
				default: return false
			}
		}
		case WEAPON_P228: {
			switch(g_class[id]) {
				case CLASS_SCOUT: {
					maxammo = get_pcvar_num(cvar_usp_ammo)
					giveammo = maxammo * percent / 100
					ammo = rg_get_user_bpammo(id, WEAPON_P228)
					if(giveammo < 1)
						giveammo = 1
					else if(ammo >= maxammo)
						return false
					else if(ammo > maxammo - giveammo && ammo < maxammo)
						rg_set_user_bpammo(id, WEAPON_P228, maxammo)
					else if(ammo <= maxammo - giveammo)
						rg_set_user_bpammo(id, WEAPON_P228, ammo + giveammo)
				}
				case CLASS_HEAVY: {
					maxammo = get_pcvar_num(cvar_shotgun_ammo)
					giveammo = maxammo * percent / 100
					if(giveammo < 1)
						giveammo = 1
					else if(g_shotgun_ammo[id] >= maxammo)
						return false
					else if(g_shotgun_ammo[id] > maxammo - giveammo && g_shotgun_ammo[id] < maxammo)
						g_shotgun_ammo[id] = maxammo
					else if(g_shotgun_ammo[id] <= maxammo - giveammo)
						g_shotgun_ammo[id] += giveammo
					rg_set_user_bpammo(id, WEAPON_P228, g_shotgun_ammo[id])
				}
				case CLASS_SOLDIER: {
					maxammo = get_pcvar_num(cvar_shotgun_ammo)
					giveammo = maxammo * percent / 100
					if(giveammo < 1)
						giveammo = 1
					else if(g_shotgun_ammo[id] >= maxammo)
						return false
					else if(g_shotgun_ammo[id] > maxammo - giveammo && g_shotgun_ammo[id] < maxammo)
						g_shotgun_ammo[id] = maxammo
					else if(g_shotgun_ammo[id] <= maxammo - giveammo)
						g_shotgun_ammo[id] += giveammo
					rg_set_user_bpammo(id, WEAPON_P228, g_shotgun_ammo[id])
				}
				case CLASS_SNIPER: {
					maxammo = get_pcvar_num(cvar_smg_ammo)
					giveammo = maxammo * percent / 100
					if(giveammo < 1)
						giveammo = 1
					else if(g_smg_ammo[id] >= maxammo)
						return false
					else if(g_smg_ammo[id] > maxammo - giveammo && g_smg_ammo[id] < maxammo)
						g_smg_ammo[id] = maxammo
					else if(g_smg_ammo[id] <= maxammo - giveammo)
						g_smg_ammo[id] += giveammo
					rg_set_user_bpammo(id, WEAPON_P228, g_smg_ammo[id])
				}
				case CLASS_MEDIC: {
					maxammo = get_pcvar_num(cvar_syringegun_ammo)
					giveammo = maxammo * percent / 100
					if(giveammo < 1)
						giveammo = 1
					else if(g_syringegun_ammo[id] >= maxammo)
						return false
					else if(g_syringegun_ammo[id] > maxammo - giveammo && g_syringegun_ammo[id] < maxammo)
						g_syringegun_ammo[id] = maxammo
					else if(g_syringegun_ammo[id] <= maxammo - giveammo)
						g_syringegun_ammo[id] += giveammo
					rg_set_user_bpammo(id, WEAPON_P228, g_syringegun_ammo[id])
				}
				case CLASS_DEMOMAN: {
					maxammo = get_pcvar_num(cvar_stickybomb_ammo)
					giveammo = maxammo * percent / 100
					if(giveammo < 1)
						giveammo = 1
					else if(g_stickybomb_ammo[id] >= maxammo)
						return false
					else if(g_stickybomb_ammo[id] > maxammo - giveammo && g_stickybomb_ammo[id] < maxammo)
						g_stickybomb_ammo[id] = maxammo
					else if(g_stickybomb_ammo[id] <= maxammo - giveammo)
						g_stickybomb_ammo[id] += giveammo
					rg_set_user_bpammo(id, WEAPON_P228, g_stickybomb_ammo[id])
				}
				default: return false
			}
		}
		case WEAPON_AWP: {
			maxammo = get_pcvar_num(cvar_awp_ammo)
			giveammo = maxammo * percent / 100
			ammo = rg_get_user_bpammo(id, WEAPON_AWP)
			if(giveammo < 1)
				giveammo = 1
			else if(ammo >= maxammo)
				return false
			else if(ammo > maxammo - giveammo && ammo < maxammo)
				rg_set_user_bpammo(id, WEAPON_AWP, maxammo)
			else if(ammo <= maxammo - giveammo)
				rg_set_user_bpammo(id, WEAPON_AWP, ammo + giveammo)
		}
		case WEAPON_KNIFE, WEAPON_C4: {
			switch(g_class[id]) {
				case CLASS_ENGINEER: {
					if(g_engineer_metal[id] >= 100)
						return false
					else if(g_engineer_metal[id] + percent > 100 && g_engineer_metal[id] < 100)
						g_engineer_metal[id] = 100
					else if(g_engineer_metal[id] + percent <= 100)
						g_engineer_metal[id] += percent
				}
				default: return false
			}
		}
	}
	return true
}
stock get_team_num(TeamName:team) {
	new num = 0 , i, TeamName:userTeam
	for (i = 1; i <= MaxClients; i++) {
		if(!is_user_alive(i))
			continue
		
		userTeam = rg_get_user_team(i)
		if(userTeam == team)
			num++
	}
	return num
}

public ck_knockback(id, enemy, Float:force) {
	if(!is_user_alive(id) || !is_user_alive(enemy)) return
	if(force == 0.0) return
	new Float:old_velocity[3], Float:velocity[3], Float:output[3]
	velocity_by_aim(enemy, floatround(force), velocity)
	pev(id, pev_velocity, old_velocity)
	xs_vec_add(velocity, old_velocity, output)
	set_pev(id, pev_velocity, output)
}

public ck_knockback_explode(id, const Float:exp_origin[3], Float:force) {
	if(!is_user_alive(id)) return
	if(force == 0.0) return
	new Float:old_velocity[3], Float:velocity[3], Float:id_origin[3], Float:output[3]
	pev(id, pev_origin, id_origin); 
	get_speed_vector(exp_origin, id_origin, force, velocity); 
	pev(id, pev_velocity, old_velocity); 
	xs_vec_add(velocity, old_velocity, output)
	set_pev(id, pev_velocity, output)
}

stock ck_deathmsg(killer, assistant, killed, headshot, const weapon[]) {
	new build
	if(killed > MaxClients) {
		if(is_user_connected(killed - DEATHMSG_SENTRY)) {
			build = 1
			killed -= DEATHMSG_SENTRY
		} else if(is_user_connected(killed - DEATHMSG_DISPENSER)) {
			build = 2
			killed -= DEATHMSG_DISPENSER
		} else if(is_user_connected(killed - DEATHMSG_TELEIN)) {
			build = 3
			killed -= DEATHMSG_TELEIN
		} else if(is_user_connected(killed - DEATHMSG_TELEOUT)) {
			build = 4
			killed -= DEATHMSG_TELEOUT
		} else {
			return; 
		}
	} else if(!is_user_connected(killed)) {
		return; 
	}
	new killername[32], assistantname[32], killedname[32]
	get_user_name(killed, killedname, charsmax(killedname))
	if(is_user_alive(killer) && is_user_connected(assistant) && !g_switching_name[killer]) {
		get_user_name(killer, killername, charsmax(killername))
		get_user_name(assistant, assistantname, charsmax(assistantname))
		static formated[128], parm[2]
		parm[0] = killer
		parm[1] = killed
		copy(g_nametemp[killed], charsmax(g_nametemp[]), killedname)
		copy(g_wpnametemp[killer], charsmax(g_wpnametemp[]), weapon)
		format(formated, charsmax(formated), "%s + %s", killername, assistantname)
		set_user_name(killer, formated)
		set_task(0.1, "deathmsg_showassist", 0, parm, charsmax(parm))
		g_switching_name[killer] = true
		return; 
	} else if(is_user_alive(killer) && !is_user_connected(assistant) && !g_switching_name[killed]) {
		if(build > 0) {
			new formated[128], parm[2]
			parm[0] = killer
			parm[1] = killed
			copy(g_nametemp[killed], charsmax(g_nametemp[]), killedname)
			copy(g_wpnametemp[killer], charsmax(g_wpnametemp[]), weapon)
			switch(build) {
				case 1: formatex(formated, charsmax(formated), "Sentry(%s)", killedname)
				case 2: formatex(formated, charsmax(formated), "Dispenser(%s)", killedname)
				case 3: formatex(formated, charsmax(formated), "Entrance(%s)", killedname)
				case 4: formatex(formated, charsmax(formated), "Exit(%s)", killedname)
			}
			set_user_name(killed, formated)
			set_task(0.1, "deathmsg_showbuild", 0, parm, 2)
			g_switching_name[killed] = true
			return; 
		} else {
			make_deathmsg(killer, killed, headshot, weapon)
			return; 
		}
	} else if(!is_user_connected(killer) || killer == killed) {
		make_deathmsg(killed, killed, headshot, weapon)
		return; 
	}
}

public deathmsg_showassist(parm[]) {
	if(!is_user_connected(parm[0])) return; 
	if(is_user_connected(parm[1]))
		make_deathmsg(parm[0], parm[1], 0, g_wpnametemp[parm[0]])

	set_user_name(parm[0], g_nametemp[parm[0]])
	g_switching_name[parm[0]] = false
}

public deathmsg_showbuild(parm[]) {
	if(!is_user_connected(parm[0])) return; 
	if(!is_user_connected(parm[1])) return
	make_deathmsg(parm[0], parm[1], 0, g_wpnametemp[parm[0]])

	set_user_name(parm[1], g_nametemp[parm[1]])
	g_switching_name[parm[1]] = false
}

public think_Player(taskid) {
	static id
	if(taskid > MaxClients)
		id = ID_PLAYER_THINK
	else
		id = taskid
	if(!(1 <= id <= MaxClients)) return; 
	remove_task(id+TASK_PLAYER_THINK, 0)
	set_task(PLAYER_THINK, "think_Player", id+TASK_PLAYER_THINK)
	if(!is_user_connected(id)) return; 
	if(g_class[id] == CLASS_ENGINEER) {
		if(g_sentry_building[id] && g_sentry_percent[id] + 2 < 100) {
			g_sentry_percent[id] += 2
			g_sentry_strength[id] += get_pcvar_num(cvar_sentry_strength[0]) / 100
			if(g_sentry_strength[id] > get_pcvar_num(cvar_sentry_strength[0]) * g_sentry_percent[id] / 100)
				g_sentry_strength[id] = get_pcvar_num(cvar_sentry_strength[0]) * g_sentry_percent[id] / 100
		} else if(g_sentry_building[id] && g_sentry_percent[id] + 2 >= 100) {
			ck_sentry_build_turret(g_sentry_base[id], id)
		}
		if(g_dispenser_building[id] && g_dispenser_percent[id] < 100) {
			g_dispenser_percent[id]++
			g_dispenser_strength[id] += get_pcvar_num(cvar_dispenser_strength[0]) / 100
			if(g_dispenser_strength[id] > get_pcvar_num(cvar_dispenser_strength[0]) * g_dispenser_percent[id] / 100)
				g_dispenser_strength[id] = get_pcvar_num(cvar_dispenser_strength[0]) * g_dispenser_percent[id] / 100
		} else if(g_dispenser_building[id] && g_dispenser_percent[id] >= 100) {
			ck_dispenser_completed(id)
		}
		if(g_telein_building[id] && g_telein_percent[id] < 100) {
			g_telein_percent[id]++
			g_telein_strength[id] += get_pcvar_num(cvar_telein_strength[0]) / 100
			if(g_telein_strength[id] > get_pcvar_num(cvar_telein_strength[0]) * g_telein_percent[id] / 100)
				g_telein_strength[id] = get_pcvar_num(cvar_telein_strength[0]) * g_telein_percent[id] / 100
		} else if(g_telein_building[id] && g_telein_percent[id] >= 100) {
			ck_telein_completed(id)
		}
		if(g_teleout_building[id] && g_teleout_percent[id] < 100) {
			g_teleout_percent[id] += 2
			g_teleout_strength[id] += get_pcvar_num(cvar_teleout_strength[0]) / 100
			if(g_teleout_strength[id] > get_pcvar_num(cvar_teleout_strength[0]) * g_teleout_percent[id] / 100)
				g_teleout_strength[id] = get_pcvar_num(cvar_teleout_strength[0]) * g_teleout_percent[id] / 100
		} else if(g_teleout_building[id] && g_teleout_percent[id] >= 100) {
			ck_teleout_completed(id)
		}
	}
	switch(g_class[id]) {
		case CLASS_HEAVY: {
			if(g_minigun_status[id] == minigun_idle) g_speed[id] = get_pcvar_num(cvar_class_speed[CLASS_HEAVY])
			if(rg_get_user_active_weapon(id) != WEAPON_SCOUT) g_speed[id] = get_pcvar_num(cvar_class_speed[CLASS_HEAVY])
		}
		case CLASS_MEDIC: {
			if(get_user_health(id) < get_pcvar_num(cvar_class_hp[CLASS_MEDIC]))
				fm_set_user_health(id, get_user_health(id) + 1)
		}
	}
	if(!g_healed_by[id]) {
		fm_set_rendering(id, kRenderFxNone, 0, 0, 0, kRenderNormal, 0)
		new maxhealth = ck_get_user_maxhealth(id)
		if(get_user_health(id) > maxhealth)
			fm_set_user_health(id, get_user_health(id) - 1)
	}
	if(g_charge_shield[id]) {
		g_medic_charge[id] -= 2.0
		fm_set_rendering(id, kRenderFxGlowShell, 250, 125, 0, kRenderNormal, 24)
	}
	if(g_medic_charge[id] <= 0.0 && g_charge_shield[id]) {
		g_charge_shield[id] = 0
		g_medic_charge[id] = 0.0
		engfunc(EngFunc_EmitSound, id, CHAN_STATIC, Snd_medicgun_chargeoff, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	}
}

stock init_CollectSpawns(const classname[]) {
	static ent, i
	ent = -1; 
	while ((ent = engfunc(EngFunc_FindEntityByString, ent, "classname", classname)) != 0) {
		static Float:originF[3]
		pev(ent, pev_origin, originF); 
		for(i= 0; i < 3; i++) 
			g_spawns[g_spawnCount][i] = originF[i]; 
		
		g_spawnCount++; 

		if(g_spawnCount >= sizeof g_spawns) break; 
	}
}

stock init_CapturePoint(entity, color) {
	if(!pev_valid(entity)) return; 
	RegisterHamFromEntity(Ham_Touch, entity, (color == TF2_RED) ? "fw_Touch_CapturePoint_Red" : "fw_Touch_CapturePoint_Blue")
	RegisterHamFromEntity(Ham_Think, entity, "fw_Think_CapturePoint")
	set_pev(entity, pev_nextthink, get_gametime() + 10.0)
	g_cp_points[color][g_cp_pointnums[color]] = entity
	g_cp_progress[color][g_cp_pointnums[color]] = 0
	set_pev(entity, MAP_CPNUMS, g_cp_pointnums[color])
	g_cp_pointnums[color]++
}

stock init_SupplyDoor(entity, color) {
	if(!pev_valid(entity)) return; 
	RegisterHamFromEntity(Ham_Touch, entity, (color == TF2_RED) ? "fw_Touch_SupplyDoor_Red" : "fw_Touch_SupplyDoor_Blue")
}

stock is_hull_vacant(Float:origin[3], hull) {
	engfunc(EngFunc_TraceHull, origin, origin, 0, hull, 0, 0); 

	if(!get_tr2(0, TR_StartSolid) && !get_tr2(0, TR_AllSolid) && get_tr2(0, TR_InOpen))
		return true; 

	return false; 
}

public ck_showhud_center(taskid) {
	static id
	if(taskid > MaxClients)
		id = ID_SHOWCENTER
	else
		id = taskid
	remove_task(id+TASK_SHOWCENTER, 0)
	set_task(CENTER_REFRESH, "ck_showhud_center", id+TASK_SHOWCENTER)
	if(!is_user_connected(id)) return; 
	if(is_user_bot(id) || !(1 <= id <= MaxClients)) return; 
	static target, status[256], name[32], ammo
	status = ""; 
	set_hudmessage(250, 0, 0, -1.0, 0.5, 0, 6.0, CENTER_REFRESH + 1.0, 0.0, 0.0, CENTER_CHANNEL)
	if(g_healed_by[id] != 0) {
		target = g_healed_by[id]
		get_user_name(target, name, charsmax(name))
		strcat(status, fmt("%L %L^n", id, "HUD_HEALED", name, id, "HUD_STATUS_CHARGE", floatround(g_medic_charge[g_healed_by[id]])), charsmax(status))
		if(g_charge_shield[target])
			strcat(status, fmt("%L", id, "HUD_STATUS_SHIELD"), charsmax(status))
		ShowSyncHudMsg(id, g_hudcenter, "%s", status)
	} else if(g_medicgun_using[id]) {
		target = g_medicgun_target[id]
		get_user_name(target, name, charsmax(name))
		ammo = ck_get_user_ammo(target)
		if(ammo != -1)
			strcat(status, fmt("%L^n", id, "HUD_HEALING", name, get_user_health(target), ammo), charsmax(status))
		else
			strcat(status, fmt("%L^n", id, "HUD_HEALING_NOAMMO", name, get_user_health(target)), charsmax(status))
		if(g_class[target] == CLASS_MEDIC)
			strcat(status, fmt("%L", id, "HUD_STATUS_CHARGE", floatround(g_medic_charge[target])), charsmax(status))
		if(g_charge_shield[id])
			strcat(status, fmt("%L", id, "HUD_STATUS_SHIELD"), charsmax(status))
		ShowSyncHudMsg(id, g_hudcenter, "%s", status)
	} else if(is_user_alive(g_aiming[id]) && !g_aiming_at_building[id]) {
		target = g_aiming[id]
		get_user_name(target, name, charsmax(name))
		ammo = ck_get_user_ammo(target)
		if(ammo != -1)
			strcat(status, fmt("%L^n", id, "HUD_AIM", name, get_user_health(target), ammo), charsmax(status))
		else
			strcat(status, fmt("%L^n", id, "HUD_AIM_NOAMMO", name, get_user_health(target)), charsmax(status))
		if(g_class[target] == CLASS_MEDIC)
			strcat(status, fmt("%L", id, "HUD_STATUS_CHARGE", floatround(g_medic_charge[target])), charsmax(status))
		if(g_charge_shield[target] || g_charge_shield[g_healed_by[target]])
			strcat(status, fmt("%L", id, "HUD_STATUS_SHIELD"), charsmax(status))
		ShowSyncHudMsg(id, g_hudcenter, "%s", status)
	} else if((1 <= g_aiming[id] <= MaxClients) && g_aiming_at_building[id] == 1) {
		target = g_aiming[id]
		get_user_name(target, name, charsmax(name))
		if(g_sentry_building[target])
			strcat(status, fmt("%L%L%L", id, "HUD_SENTRY", id, "HUD_BUILD_OWNER", name, id, "HUD_BUILD_ING", g_sentry_percent[target]), charsmax(status))
		if(!g_sentry_building[target]) {
			strcat(status, fmt("%L%L%L^n", id, "HUD_SENTRY", id, "HUD_BUILD_OWNER", name, id, "HUD_BUILD_LEVEL", g_sentry_level[target]), charsmax(status))
			switch(g_sentry_level[target]) {
				case 1: {
					strcat(status, fmt("%L", id, "HUD_BUILD_UPGRADE", g_sentry_upgrade[target], get_pcvar_num(cvar_sentry_cost[1])), charsmax(status))
					strcat(status, fmt("%L", id, "HUD_BUILD_HEALTH", g_sentry_strength[target], get_pcvar_num(cvar_sentry_strength[0])), charsmax(status))
					strcat(status, fmt("%L", id, "HUD_BUILD_AMMO", g_sentry_ammo[target], get_pcvar_num(cvar_sentry_ammo[0])), charsmax(status))
				}
				case 2: {
					strcat(status, fmt("%L", id, "HUD_BUILD_UPGRADE", g_sentry_upgrade[target], get_pcvar_num(cvar_sentry_cost[2])), charsmax(status))
					strcat(status, fmt("%L", id, "HUD_BUILD_HEALTH", g_sentry_strength[target], get_pcvar_num(cvar_sentry_strength[1])), charsmax(status))
					strcat(status, fmt("%L", id, "HUD_BUILD_AMMO", g_sentry_ammo[target], get_pcvar_num(cvar_sentry_ammo[1])), charsmax(status))
				}
				case 3: {
					strcat(status, fmt("%L", id, "HUD_BUILD_HEALTH", g_sentry_strength[target], get_pcvar_num(cvar_sentry_strength[2])), charsmax(status))
					strcat(status, fmt("%L", id, "HUD_BUILD_AMMO", g_sentry_ammo[target], get_pcvar_num(cvar_sentry_ammo[2])), charsmax(status))
				}
			}
		}
		ShowSyncHudMsg(id, g_hudcenter, "%s", status)
	} else if((1 <= g_aiming[id] <= MaxClients) && g_aiming_at_building[id] == 2) {
		target = g_aiming[id]
		get_user_name(target, name, charsmax(name))
		if(g_dispenser_building[target])
			strcat(status, fmt("%L%L%L", id, "HUD_DISPENSER", id, "HUD_BUILD_OWNER", name, id, "HUD_BUILD_ING", g_dispenser_percent[target]), charsmax(status))
		if(!g_dispenser_building[target]) {
			strcat(status, fmt("%L%L%L^n", id, "HUD_DISPENSER", id, "HUD_BUILD_OWNER", name, id, "HUD_BUILD_LEVEL", g_dispenser_level[target]), charsmax(status))
			switch(g_dispenser_level[target]) {
				case 1: {
					strcat(status, fmt("%L", id, "HUD_BUILD_UPGRADE", g_dispenser_upgrade[target], get_pcvar_num(cvar_dispenser_cost[1])), charsmax(status))
					strcat(status, fmt("%L", id, "HUD_BUILD_HEALTH", g_dispenser_strength[target], get_pcvar_num(cvar_dispenser_strength[0])), charsmax(status))
					strcat(status, fmt("%L", id, "HUD_BUILD_AMMO", g_dispenser_ammo[target], get_pcvar_num(cvar_dispenser_ammo[0])), charsmax(status))
				}
				case 2: {
					strcat(status, fmt("%L", id, "HUD_BUILD_UPGRADE", g_dispenser_upgrade[target], get_pcvar_num(cvar_dispenser_cost[2])), charsmax(status))
					strcat(status, fmt("%L", id, "HUD_BUILD_HEALTH", g_dispenser_strength[target], get_pcvar_num(cvar_dispenser_strength[1])), charsmax(status))
					strcat(status, fmt("%L", id, "HUD_BUILD_AMMO", g_dispenser_ammo[target], get_pcvar_num(cvar_dispenser_ammo[1])), charsmax(status))
				}
				case 3: {
					strcat(status, fmt("%L", id, "HUD_BUILD_HEALTH", g_dispenser_strength[target], get_pcvar_num(cvar_dispenser_strength[2])), charsmax(status))
					strcat(status, fmt("%L", id, "HUD_BUILD_AMMO", g_dispenser_ammo[target], get_pcvar_num(cvar_dispenser_ammo[2])), charsmax(status))
				}
			}
		}
		ShowSyncHudMsg(id, g_hudcenter, "%s", status)
	} else if((1 <= g_aiming[id] <= MaxClients) && g_aiming_at_building[id] == 3) {
		target = g_aiming[id]
		get_user_name(target, name, charsmax(name))
		if(g_telein_building[target])
			strcat(status, fmt("%L%L%L", id, "HUD_TELEIN", id, "HUD_BUILD_OWNER", name, id, "HUD_BUILD_ING", g_telein_percent[target]), charsmax(status))
		if(!g_telein_building[target]) {
			strcat(status, fmt("%L%L%L^n", id, "HUD_TELEIN", id, "HUD_BUILD_OWNER", name, id, "HUD_BUILD_LEVEL", gtele_level[target]), charsmax(status))
			switch(gtele_level[target]) {
				case 1: {
					strcat(status, fmt("%L", id, "HUD_BUILD_UPGRADE", gtele_upgrade[target], get_pcvar_num(cvar_tele_cost[0])), charsmax(status))
					strcat(status, fmt("%L", id, "HUD_BUILD_HEALTH", g_telein_strength[target], get_pcvar_num(cvar_telein_strength[0])), charsmax(status))
				}
				case 2: {
					strcat(status, fmt("%L", id, "HUD_BUILD_UPGRADE", gtele_upgrade[target], get_pcvar_num(cvar_tele_cost[1])), charsmax(status))
					strcat(status, fmt("%L", id, "HUD_BUILD_HEALTH", g_telein_strength[target], get_pcvar_num(cvar_telein_strength[1])), charsmax(status))
				}
				case 3: {
					strcat(status, fmt("%L", id, "HUD_BUILD_HEALTH", g_telein_strength[target], get_pcvar_num(cvar_telein_strength[2])), charsmax(status))
				}
			}
			strcat(status, fmt("%L", id, "HUD_BUILD_RELOAD", g_tele_reload[target]), charsmax(status))
		}
		ShowSyncHudMsg(id, g_hudcenter, "%s", status)
	} else if((1 <= g_aiming[id] <= MaxClients) && g_aiming_at_building[id] == 4) {
		target = g_aiming[id]
		get_user_name(target, name, charsmax(name))
		if(g_teleout_building[target])
			strcat(status, fmt("%L%L%L", id, "HUD_TELEOUT", id, "HUD_BUILD_OWNER", name, id, "HUD_BUILD_ING", g_teleout_percent[target]), charsmax(status))
		if(!g_teleout_building[target]) {
			strcat(status, fmt("%L%L%L^n", id, "HUD_TELEOUT", id, "HUD_BUILD_OWNER", name, id, "HUD_BUILD_LEVEL", gtele_level[target]), charsmax(status))
			switch(gtele_level[target]) {
				case 1: {
					strcat(status, fmt("%L", id, "HUD_BUILD_UPGRADE", gtele_upgrade[target], get_pcvar_num(cvar_tele_cost[0])), charsmax(status))
					strcat(status, fmt("%L", id, "HUD_BUILD_HEALTH", g_teleout_strength[target], get_pcvar_num(cvar_teleout_strength[0])), charsmax(status))
				}
				case 2: {
					strcat(status, fmt("%L", id, "HUD_BUILD_UPGRADE", gtele_upgrade[target], get_pcvar_num(cvar_tele_cost[1])), charsmax(status))
					strcat(status, fmt("%L", id, "HUD_BUILD_HEALTH", g_teleout_strength[target], get_pcvar_num(cvar_teleout_strength[1])), charsmax(status))
				}
				case 3: {
					strcat(status, fmt("%L", id, "HUD_BUILD_HEALTH", g_teleout_strength[target], get_pcvar_num(cvar_teleout_strength[2])), charsmax(status))
				}
			}
			strcat(status, fmt("%L", id, "HUD_BUILD_RELOAD", g_tele_reload[target]), charsmax(status))
		}
		ShowSyncHudMsg(id, g_hudcenter, "%s", status)
	}
}

public ck_showhud_status(taskid) {
	static id
	if(taskid > MaxClients)
		id = ID_SHOWHUD
	else
		id = taskid
	remove_task(id+TASK_SHOWHUD, 0)
	set_task(HUD_REFRESH, "ck_showhud_status", id+TASK_SHOWHUD)
	if(!(1 <= id <= MaxClients)) return; 
	if(is_user_bot(id)) return; 
	new bool:spec, spectator
	if(!is_user_alive(id)) {
		spectator = id
		id = pev(id, pev_iuser2)
		spec = true
		if(!is_user_alive(id)) 
			return; 
	}
	static hudstatus[512]
	hudstatus = ""
	if(spec)
		set_hudmessage(200, 250, 0, 0.02, 0.77, 0, 6.0, HUD_REFRESH + 1.0, 0.0, 0.0, STATUS_CHANNEL)
	else
		set_hudmessage(200, 250, 0, 0.02, 0.85, 0, 6.0, HUD_REFRESH + 1.0, 0.0, 0.0, STATUS_CHANNEL)

	strcat(hudstatus, fmt("%L", id, fmt("HUD_%s", ClassConfig[g_class[id]][ClassName]), get_user_health(id)), charsmax(hudstatus))

	if(g_charge_shield[g_healed_by[id]] || g_charge_shield[id])
		strcat(hudstatus, fmt("%L", id, "HUD_STATUS_SHIELD"), charsmax(hudstatus))
	strcat(hudstatus, fmt("^n%L", id, "HUD_WEAPON"), charsmax(hudstatus))
	
	static wpname[16], clip, ammo, wpn; 
	wpn = get_user_weapon(id, clip, ammo)
	ck_get_user_weapon_name(id, wpname, charsmax(wpname))
	strcat(hudstatus, fmt("%s", wpname), charsmax(hudstatus))

	switch(wpn) {
		case CSW_M3: {
			switch(g_class[id]) {
				case CLASS_SCOUT: strcat(hudstatus, fmt("%L", id, "HUD_AMMO", g_scattergun_clip[id], g_scattergun_ammo[id]), charsmax(hudstatus))
				case CLASS_HEAVY: strcat(hudstatus, fmt("%L", id, "HUD_CLIP", g_minigun_clip[id]), charsmax(hudstatus))
				case CLASS_SOLDIER: strcat(hudstatus, fmt("%L", id, "HUD_AMMO", g_rocket_clip[id], g_rocket_ammo[id]), charsmax(hudstatus))
				case CLASS_ENGINEER: strcat(hudstatus, fmt("%L", id, "HUD_AMMO", g_shotgun_clip[id], g_shotgun_ammo[id]), charsmax(hudstatus))
				case CLASS_DEMOMAN: strcat(hudstatus, fmt("%L", id, "HUD_AMMO", g_grenade_clip[id], g_grenade_ammo[id]), charsmax(hudstatus))
			}
		}
		case CSW_P228: {
			switch(g_class[id]) {
				case CLASS_SCOUT: strcat(hudstatus, fmt("%L", id, "HUD_AMMO", clip, ammo), charsmax(hudstatus))
				case CLASS_HEAVY: strcat(hudstatus, fmt("%L", id, "HUD_AMMO", g_shotgun_clip[id], g_shotgun_ammo[id]), charsmax(hudstatus))
				case CLASS_SOLDIER: strcat(hudstatus, fmt("%L", id, "HUD_AMMO", g_shotgun_clip[id], g_shotgun_ammo[id]), charsmax(hudstatus))
				case CLASS_SNIPER: strcat(hudstatus, fmt("%L", id, "HUD_AMMO", g_smg_clip[id], g_smg_ammo[id]), charsmax(hudstatus))
				case CLASS_MEDIC: strcat(hudstatus, fmt("%L", id, "HUD_AMMO", g_syringegun_clip[id], g_syringegun_ammo[id]), charsmax(hudstatus))
				case CLASS_DEMOMAN: strcat(hudstatus, fmt("%L", id, "HUD_AMMO", g_stickybomb_clip[id], g_stickybomb_ammo[id]), charsmax(hudstatus))
			}
		}
		case CSW_AWP: strcat(hudstatus, fmt("%L", id, "HUD_AMMO", clip, ammo), charsmax(hudstatus))
	}

	switch(g_class[id]) {
		case CLASS_SNIPER: strcat(hudstatus, fmt("%L", id, "HUD_SNIPERCHARGE", g_sniper_charge[id]), charsmax(hudstatus))
		case CLASS_MEDIC: strcat(hudstatus, fmt("%L", id, "HUD_CHARGE", g_medic_charge[id]), charsmax(hudstatus))
		case CLASS_ENGINEER: strcat(hudstatus, fmt("%L", id, "HUD_METAL", g_engineer_metal[id]), charsmax(hudstatus))
	}
	if(spec) {
		new specname[48]
		get_user_name(id, specname, charsmax(specname))
		ShowSyncHudMsg(spectator, g_hudsync, "%L^n%s", LANG_PLAYER, "HUD_SPECTATOR", specname, hudstatus)
	} else {
		ShowSyncHudMsg(id, g_hudsync, "%s", hudstatus)
	}
	if(g_class[id] != CLASS_ENGINEER) {
		ClearSyncHud(id, g_hudbuild)
		return; 
	}
	static buildstatus[256]
	buildstatus = ""; 
	set_hudmessage(200, 100, 0, -1.0, 0.07, 0, 6.0, HUD_REFRESH + 1.0, 0.0, 0.0, BUILD_CHANNEL)
	if(!g_havesentry[id] && !g_sentry_building[id])
		strcat(buildstatus, fmt("%L%L^n", id, "HUD_SENTRY", id, "HUD_BUILD_NO"), charsmax(buildstatus))
	if(g_havesentry[id] && g_sentry_building[id])
		strcat(buildstatus, fmt("%L%L^n", id, "HUD_SENTRY", id, "HUD_BUILD_ING", g_sentry_percent[id]), charsmax(buildstatus))
	if(g_havesentry[id] && !g_sentry_building[id]) {
		strcat(buildstatus, fmt("%L", id, "HUD_SENTRY"), charsmax(buildstatus))
		strcat(buildstatus, fmt("%L", id, "HUD_BUILD_LEVEL", g_sentry_level[id]), charsmax(buildstatus))
		if(g_sentry_level[id]) {
			if(g_sentry_level[id] < 3) strcat(buildstatus, fmt("%L", id, "HUD_BUILD_UPGRADE", g_sentry_upgrade[id], get_pcvar_num(cvar_sentry_cost[g_sentry_level[id]])), charsmax(buildstatus))
			strcat(buildstatus, fmt("%L", id, "HUD_BUILD_HEALTH", g_sentry_strength[id], get_pcvar_num(cvar_sentry_strength[g_sentry_level[id]-1])), charsmax(buildstatus))
			strcat(buildstatus, fmt("%L^n", id, "HUD_BUILD_AMMO", g_sentry_ammo[id], get_pcvar_num(cvar_sentry_ammo[g_sentry_level[id]-1])), charsmax(buildstatus))
		}
	}
	if(!g_havedispenser[id] && !g_dispenser_building[id])
		strcat(buildstatus, fmt("%L%L^n", id, "HUD_DISPENSER", id, "HUD_BUILD_NO"), charsmax(buildstatus))
	if(g_havedispenser[id] && g_dispenser_building[id])
		strcat(buildstatus, fmt("%L%L^n", id, "HUD_DISPENSER", id, "HUD_BUILD_ING", g_dispenser_percent[id]), charsmax(buildstatus))
	if(g_havedispenser[id] && !g_dispenser_building[id]) {
		strcat(buildstatus, fmt("%L", id, "HUD_DISPENSER"), charsmax(buildstatus))
		strcat(buildstatus, fmt("%L", id, "HUD_BUILD_LEVEL", g_dispenser_level[id]), charsmax(buildstatus))
		if(g_dispenser_level[id]) {
			if(g_dispenser_level[id] < 3) strcat(buildstatus, fmt("%L", id, "HUD_BUILD_UPGRADE", g_dispenser_upgrade[id], get_pcvar_num(cvar_dispenser_cost[g_dispenser_level[id]])), charsmax(buildstatus))
			strcat(buildstatus, fmt("%L", id, "HUD_BUILD_HEALTH", g_dispenser_strength[id], get_pcvar_num(cvar_dispenser_strength[g_dispenser_level[id]-1])), charsmax(buildstatus))
			strcat(buildstatus, fmt("%L^n", id, "HUD_BUILD_AMMO", g_dispenser_ammo[id], get_pcvar_num(cvar_dispenser_ammo[g_dispenser_level[id]-1])), charsmax(buildstatus))
		}
	}
	if(!g_havetelein[id] && !g_telein_building[id])
		strcat(buildstatus, fmt("%L%L^n", id, "HUD_TELEIN", id, "HUD_BUILD_NO"), charsmax(buildstatus))
	if(g_havetelein[id] && g_telein_building[id])
		strcat(buildstatus, fmt("%L%L^n", id, "HUD_TELEIN", id, "HUD_BUILD_ING", g_telein_percent[id]), charsmax(buildstatus))
	if(g_havetelein[id] && !g_telein_building[id]) {
		strcat(buildstatus, fmt("%L", id, "HUD_TELEIN"), charsmax(buildstatus))
		strcat(buildstatus, fmt("%L", id, "HUD_BUILD_LEVEL", gtele_level[id]), charsmax(buildstatus))
		strcat(buildstatus, fmt("%L^n", id, "HUD_BUILD_HEALTH", g_telein_strength[id], get_pcvar_num(cvar_telein_strength[gtele_level[id]-1])), charsmax(buildstatus))
		if(!(g_haveteleout[id] && !g_teleout_building[id])) {
			strcat(buildstatus, fmt("%L", id, "HUD_BUILD_LEVEL", gtele_level[id]), charsmax(buildstatus))
			if(gtele_level[id] == 1)
				strcat(buildstatus, fmt("%L", id, "HUD_BUILD_UPGRADE", gtele_upgrade[id], get_pcvar_num(cvar_tele_cost[0])), charsmax(buildstatus))
			else if(gtele_level[id] == 2)
				strcat(buildstatus, fmt("%L", id, "HUD_BUILD_UPGRADE", gtele_upgrade[id], get_pcvar_num(cvar_tele_cost[1])), charsmax(buildstatus))
			strcat(buildstatus, fmt("%L^n", id, "HUD_BUILD_RELOAD", g_tele_reload[id]), charsmax(buildstatus))
		}
	}
	if(!g_haveteleout[id] && !g_teleout_building[id])
		strcat(buildstatus, fmt("%L%L^n", id, "HUD_TELEOUT", id, "HUD_BUILD_NO"), charsmax(buildstatus))
	if(g_haveteleout[id] && g_teleout_building[id])
		strcat(buildstatus, fmt("%L%L^n", id, "HUD_TELEOUT", id, "HUD_BUILD_ING", g_teleout_percent[id]), charsmax(buildstatus))
	if(g_haveteleout[id] && !g_teleout_building[id]) {
		strcat(buildstatus, fmt("%L", id, "HUD_TELEOUT"), charsmax(buildstatus))
		strcat(buildstatus, fmt("%L", id, "HUD_BUILD_HEALTH", g_teleout_strength[id], get_pcvar_num(cvar_teleout_strength[gtele_level[id]-1])), charsmax(buildstatus))
		if(!(g_havetelein[id] && !g_telein_building[id])) {
			strcat(buildstatus, fmt("%L", id, "HUD_BUILD_LEVEL", gtele_level[id]), charsmax(buildstatus))
			if(gtele_level[id] == 1)
				strcat(buildstatus, fmt("%L", id, "HUD_BUILD_UPGRADE", gtele_upgrade[id], get_pcvar_num(cvar_tele_cost[0])), charsmax(buildstatus))
			else if(gtele_level[id] == 2)
				strcat(buildstatus, fmt("%L", id, "HUD_BUILD_UPGRADE", gtele_upgrade[id], get_pcvar_num(cvar_tele_cost[1])), charsmax(buildstatus))
			strcat(buildstatus, fmt("%L^n", id, "HUD_BUILD_RELOAD", g_tele_reload[id]), charsmax(buildstatus))
		}
	}
	if(g_havetelein[id] && !g_telein_building[id] && g_haveteleout[id] && !g_teleout_building[id]) {
		strcat(buildstatus, fmt("%L", id, "HUD_BUILD_LEVEL", gtele_level[id]), charsmax(buildstatus))
		if(gtele_level[id] == 1)
			strcat(buildstatus, fmt("%L", id, "HUD_BUILD_UPGRADE", gtele_upgrade[id], get_pcvar_num(cvar_tele_cost[0])), charsmax(buildstatus))
		else if(gtele_level[id] == 2)
			strcat(buildstatus, fmt("%L", id, "HUD_BUILD_UPGRADE", gtele_upgrade[id], get_pcvar_num(cvar_tele_cost[1])), charsmax(buildstatus))
		strcat(buildstatus, fmt("%L^n", id, "HUD_BUILD_RELOAD", g_tele_reload[id]), charsmax(buildstatus))
	}
	if(spec) {
		static specname[32]; get_user_name(id, specname, charsmax(specname))
		ShowSyncHudMsg(spectator, g_hudbuild, "%L^n%s", LANG_PLAYER, "HUD_SPECTATOR", specname, buildstatus)
	} else {
		ShowSyncHudMsg(id, g_hudbuild, "%s", buildstatus)
	}
}

public ck_showhud_timer() {
	set_hudmessage(100, 200, 0, -1.0, 0.33, 0, 6.0, TIMER_REFRESH + 1.0, 0.0, 0.0, TIMER_CHANNEL)
	static timeminutes, timeseconds, timemode, map_obj[256], text[256]
	text = ""
	switch(g_round) {
		case round_setup: strcat(text, fmt("[ %L ]", LANG_PLAYER, "NAME_ROUND_SETUP"), charsmax(text))
		case round_normal: strcat(text, fmt("[ %L ]", LANG_PLAYER, "NAME_ROUND_NORMAL"), charsmax(text))
		case round_end: strcat(text, fmt("[ %L ]", LANG_PLAYER, "NAME_ROUND_END"), charsmax(text))
	}
	
	if(g_round != round_end) {
		timemode = (g_round == round_setup) ? g_setuptime : g_roundtime
		timeminutes = g_setuptime / 60
		timeseconds = g_setuptime - timeminutes * 60
		if(timemode < 60) strcat(text, fmt("%L : [ %d ]", LANG_PLAYER, (g_round == round_setup) ? "NAME_SETUP_TIME" : "NAME_ROUND_TIME", timemode), charsmax(text))
		else if(timeseconds < 10) strcat(text, fmt("%L : [ %d : 0%d ]", LANG_PLAYER, (g_round == round_setup) ? "NAME_SETUP_TIME" : "NAME_ROUND_TIME", timeminutes, timeseconds), charsmax(text))
		else strcat(text, fmt("%L : [ %d : %d ]", LANG_PLAYER, (g_round == round_setup) ? "NAME_SETUP_TIME" : "NAME_ROUND_TIME", timeminutes, timeseconds), charsmax(text))

		message_begin(MSG_ALL, g_msgRoundTime)
		write_short(timemode)
		message_end()
	}
	map_obj = ""
	switch(g_gamemode) {
		case mode_normal : strcat(map_obj, fmt("%L^n", LANG_PLAYER, "OBJ_NORMAL_NAME"), charsmax(map_obj))
		case mode_capture : {
			static i, progress, need
			strcat(map_obj, fmt("%L", LANG_PLAYER, "OBJ_CP_NAME"), charsmax(map_obj))
			for(i = 0; i < g_cp_pointnums[TF2_RED]; i++) {
				progress = g_cp_progress[TF2_RED][i]
				need = pev(g_cp_points[TF2_RED][i], MAP_DISPATCH2)
				strcat(map_obj, fmt("^n%L", LANG_PLAYER, "OBJ_CP_POINT_RED", i+1, progress / 10), charsmax(map_obj))
				if(progress >= 100.0)
					strcat(map_obj, fmt("^n%L", LANG_PLAYER, "OBJ_CP_CAPTURED"), charsmax(map_obj))
				else if(need > g_cp_local[TF2_RED])
					strcat(map_obj, fmt("^n%L", LANG_PLAYER, "OBJ_CP_LOCKED"), charsmax(map_obj))
			}
			for(i = 0; i < g_cp_pointnums[TF2_BLUE]; i++) {
				progress = g_cp_progress[TF2_BLUE][i]
				need = pev(g_cp_points[TF2_BLUE][i], MAP_DISPATCH2)
				strcat(map_obj, fmt("^n%L", LANG_PLAYER, "OBJ_CP_POINT_BLUE", i+1, progress / 10), charsmax(map_obj))
				if(progress >= 100.0)
					strcat(map_obj, fmt("^n%L", LANG_PLAYER, "OBJ_CP_CAPTURED"), charsmax(map_obj))
				else if(need > g_cp_local[TF2_BLUE])
					strcat(map_obj, fmt("^n%L", LANG_PLAYER, "OBJ_CP_LOCKED"), charsmax(map_obj))
			}
		}
		case mode_ctflag : strcat(map_obj, fmt("%L", LANG_PLAYER, "OBJ_CTF_NAME"), charsmax(map_obj))
		case mode_payload : strcat(map_obj, fmt("%L", LANG_PLAYER, "OBJ_PL_NAME"), charsmax(map_obj))
	}
	ShowSyncHudMsg(0, g_hudtimer, "%s^n%s^n%s^n^n^n^n^n^n^n^n^n^n^n%s^n^n^n%s", g_text1, g_text2, g_text3, map_obj, text)

	set_task(TIMER_REFRESH, "ck_showhud_timer")
}

public round_timer() {
	switch(g_round) {
		case round_setup: {
			if(g_setuptime <= 0) g_round = round_normal
			else g_setuptime --
		}
		case round_normal: {
			if(g_roundtime <= 0) check_end()
			g_roundtime --
		}
	}
	remove_task(TASK_ROUND_TIMER, 0)
	set_task(1.0, "round_timer", TASK_ROUND_TIMER)
}
stock get_speed_vector(const Float:origin1[3], const Float:origin2[3], Float:force, Float:new_velocity[3]) {
	static Float:num, i
	for(i = 0; i < 3; i++) new_velocity[i] = origin2[i] - origin1[i]
	num = floatsqroot(force*force / (new_velocity[0]*new_velocity[0] + new_velocity[1]*new_velocity[1] + new_velocity[2]*new_velocity[2]))
	for(i = 0; i < 3; i++) new_velocity[i] *= num

	return 1; 
}

public event_SetFOV(id) {
	if(!is_user_alive(id)) return; 
	if(g_class[id] != CLASS_SNIPER) return; 
	new zoom = read_data(1)
	if(zoom == 90) {
		set_task(0.1, "task_sniper_stopcharge", id)
	} else if(zoom < 90) {
		g_sniper_charge[id] = 0.0
		g_sniper_zoom[id] = 1
	}
}

public refresh_message() {
	format(g_text3, charsmax(g_text3), "%s", g_text2)
	format(g_text2, charsmax(g_text2), "%s", g_text1)
	format(g_text1, charsmax(g_text1), "%s", "")
	set_task(10.0, "refresh_message")
}

public sentry_build(id) {
	if(!is_user_alive(id) || g_class[id] != CLASS_ENGINEER)
		return
	if(g_engineer_metal[id] < get_pcvar_num(cvar_sentry_cost[0])) {
		client_print(id, print_center, "%L", id, "MSG_BUILD_ENOUGHMETAL")
		return
	} else if(!(pev(id, pev_flags) & FL_ONGROUND)) {
		client_print(id, print_center, "%L", id, "MSG_BUILD_ONGROUND")
		return
	} else if(pev(id, pev_bInDuck)) {
		client_print(id, print_center, "%L", id, "MSG_BUILD_DUCK")
		return
	} else if(g_havesentry[id] || g_sentry_building[id] || g_sentry_percent[id] > 0) {
		client_print(id, print_center, "%L", id, "MSG_BUILD_HAVE")
		return
	}
	static Float:Origin[3], Float:vNewOrigin[3], Float:vTraceDirection[3], Float:vTraceEnd[3], Float:vTraceResult[3], i
	pev(id, pev_origin, Origin)
	velocity_by_aim(id, 64, vTraceDirection)
	for(i = 0; i < 3; i++) 
		vTraceEnd[i] = vTraceDirection[i] + Origin[i]; 

	fm_trace_line(id, Origin, vTraceEnd, vTraceResult)
	vNewOrigin[0] = vTraceResult[0]
	vNewOrigin[1] = vTraceResult[1]
	vNewOrigin[2] = Origin[2]
	if(!(ck_sentry_build(vNewOrigin, id)))
		client_print(id, print_center, "%L", id, "MSG_BUILD_UNABLE")
}

public ck_sentry_shoot(id, target) {
	if(!g_sentry_ammo[id]) return
	static sentry 
	sentry = g_sentry_turret[id]
	if(!pev_valid(sentry)) return

	static Float:sentryOrigin[3], Float:targetOrigin[3], Float:hitOrigin[3], hit, Float:scatter, i
	pev(sentry, pev_origin, sentryOrigin)
	sentryOrigin[2] += 18.0
	pev(target, pev_origin, targetOrigin)
	
	scatter = get_pcvar_float(cvar_sentry_scatter)
	for(i = 0; i < 3; i++) targetOrigin[i] += random_float(-scatter, scatter); 

	hit = fm_trace_line(sentry, sentryOrigin, targetOrigin, hitOrigin)
	if(hit == g_sentry_base[id]) hit = fm_trace_line(g_sentry_base[id], sentryOrigin, targetOrigin, hitOrigin)
	if(hit == target) {
		static Float:dmg, Float:force
		dmg = random_float(get_pcvar_float(cvar_sentry_mindmg[g_sentry_level[id]-1]), get_pcvar_float(cvar_sentry_maxdmg[g_sentry_level[id]-1]))
		force = dmg * get_pcvar_float(cvar_sentry_force)
		ck_knockback_explode(target, sentryOrigin, force)
		if(g_critical_on[id]) {
			dmg *= get_pcvar_float(cvar_critical_dmg)
			ck_fakedamage(target, id, TFM_SENTRY, floatround(dmg), 0, 1)
			FX_Critical(id, target)
		} else {
			ck_fakedamage(target, id, TFM_SENTRY, floatround(dmg), 0, 0)
		}
	}
	if(!g_critical_on[id])
		FX_Trace(sentryOrigin, hitOrigin)
	else
		FX_ColoredTrace_Point(id, sentryOrigin, hitOrigin)
	engfunc(EngFunc_EmitSound, sentry, CHAN_STATIC, Snd_sentry_shoot, 1.0, ATTN_NORM, 0, PITCH_NORM)
	g_sentry_ammo[id]--
}
stock bool:is_hull_default(Float:origin[3], const Float:BOUNDS) {
	static Float:traceEnds[8][3], Float:traceHit[3], hitEnt, i, j
	traceEnds[0][0] = origin[0] - BOUNDS; traceEnds[0][1] = origin[1] - BOUNDS; traceEnds[0][2] = origin[2] - BOUNDS; 
	traceEnds[1][0] = origin[0] - BOUNDS; traceEnds[1][1] = origin[1] - BOUNDS; traceEnds[1][2] = origin[2] + BOUNDS; 
	traceEnds[2][0] = origin[0] + BOUNDS; traceEnds[2][1] = origin[1] - BOUNDS; traceEnds[2][2] = origin[2] + BOUNDS; 
	traceEnds[3][0] = origin[0] + BOUNDS; traceEnds[3][1] = origin[1] - BOUNDS; traceEnds[3][2] = origin[2] - BOUNDS; 
	traceEnds[4][0] = origin[0] - BOUNDS; traceEnds[4][1] = origin[1] + BOUNDS; traceEnds[4][2] = origin[2] - BOUNDS; 
	traceEnds[5][0] = origin[0] - BOUNDS; traceEnds[5][1] = origin[1] + BOUNDS; traceEnds[5][2] = origin[2] + BOUNDS; 
	traceEnds[6][0] = origin[0] + BOUNDS; traceEnds[6][1] = origin[1] + BOUNDS; traceEnds[6][2] = origin[2] + BOUNDS; 
	traceEnds[7][0] = origin[0] + BOUNDS; traceEnds[7][1] = origin[1] + BOUNDS; traceEnds[7][2] = origin[2] - BOUNDS; 
	for (i = 0; i < 8; i++) {
		if(fm_point_contents(traceEnds[i]) != CONTENTS_EMPTY)
			return true

		hitEnt = fm_trace_line(0, origin, traceEnds[i], traceHit)
		if(hitEnt != 0)
			return true
		for (j = 0; j < 3; j++)
			if(traceEnds[i][j] != traceHit[j])
				return true
	}
	return false
}

stock ck_turntotarget(ent, target) {
	if(!target) 
		return 0;
	
	static Float:closestOrigin[3], Float:sentryOrigin[3], Float:newAngle[3], Float:x, Float:z, Float:radians
	
	pev(target, pev_origin, closestOrigin)
	pev(ent, pev_origin, sentryOrigin)
	
	pev(ent, pev_angles, newAngle)
	x = closestOrigin[0] - sentryOrigin[0]
	z = closestOrigin[1] - sentryOrigin[1]

	radians = floatatan(z/x, radian)
	newAngle[1] = radians * 180.0 / 3.14159
	if(closestOrigin[0] < sentryOrigin[0])
		newAngle[1] -= 180.0

	static Float:degs, Float:RADIUS, Float:degreeByte, Float:tilt, Float:h, Float:b
	h = closestOrigin[2] - sentryOrigin[2]
	b = vector_distance(sentryOrigin, closestOrigin)
	radians = floatatan(h/b, radian)
	degs = radians * 180.0 / 3.14159
	RADIUS = 830.0
	degreeByte = RADIUS/256.0
	tilt = 127.0 - degreeByte * degs
	set_pev(ent, pev_angles, newAngle)
	set_pev(ent, pev_controller_1, floatround(tilt))
	
	return 1;
}

stock bool:ck_sentry_build(Float:origin[3], id) {
	if(fm_point_contents(origin) != CONTENTS_EMPTY || is_hull_default(origin, 24.0))
		return false
	static Float:hitPoint[3], Float:originDown[3], Float:difference, sentry_base
	originDown = origin
	originDown[2] = -5000.0
	fm_trace_line(0, origin, originDown, hitPoint)
	
	difference = 36.0 - (vector_distance(origin, hitPoint))
	if(difference < -1 * 10.0 || difference > 10.0) return false

	sentry_base = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "func_breakable"))
	if(!sentry_base)
		return false
	fm_set_kvd(sentry_base, "health", "10000", "func_breakable")
	fm_set_kvd(sentry_base, "material", "6", "func_breakable")
	fm_DispatchSpawn(sentry_base)

	set_pev(sentry_base, pev_classname, SentryBase_ClassName)
	engfunc(EngFunc_SetModel, sentry_base, Mdl_sentry_base)
	//engfunc(EngFunc_SetSize, sentry_base, { -16.0, -16.0, 0.0 }, { 16.0, 16.0, 32.0 })
	engfunc(EngFunc_SetOrigin, sentry_base, origin)
	pev(id, pev_v_angle, origin)
	origin[0] = 0.0
	origin[1] += 180.0
	origin[2] = 0.0
	set_pev(sentry_base, pev_angles, origin)
	set_pev(sentry_base, pev_solid, SOLID_SLIDEBOX)
	set_pev(sentry_base, pev_movetype, MOVETYPE_TOSS)
	set_pev(sentry_base, BUILD_OWNER, id)
	g_sentry_base[id] = sentry_base
	g_sentry_building[id] = true
	g_sentry_strength[id] = 1
	g_havesentry[id] = true
	g_engineer_metal[id] -= get_pcvar_num(cvar_sentry_cost[0])
	set_pev(sentry_base, pev_nextthink, get_gametime() + SENTRY_THINK)
	return true
}

public ck_sentry_build_turret(sentry_base, id) {
	if(!g_sentry_building[id]) { 
		if(pev_valid(sentry_base)) ck_sentry_destory(id)
		return
	}
	if(!pev_valid(sentry_base)) return
	static Float:origin[3], sentry_turret
	pev(sentry_base, pev_origin, origin)
	
	sentry_turret = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
	if(!sentry_turret) {
		if(pev_valid(sentry_base)) ck_sentry_destory(id)
		return
	}
	engfunc(EngFunc_SetSize, sentry_turret, { -16.0, -16.0, 0.0 }, { 16.0, 16.0, 16.0 })
	set_pev(sentry_turret, pev_classname, SentryTurret_ClassName)

	engfunc(EngFunc_SetModel, sentry_turret, Mdl_sentry_level1)
	origin[2] += 64.0
	engfunc(EngFunc_SetOrigin, sentry_turret, origin)

	pev(sentry_base, pev_angles, origin)
	set_pev(sentry_turret, pev_angles, origin)
	set_pev(sentry_turret, pev_solid, SOLID_SLIDEBOX)
	set_pev(sentry_turret, pev_movetype, MOVETYPE_TOSS)
	set_pev(sentry_turret, pev_controller_1, 127)
	set_pev(sentry_turret, pev_controller_2, 127)
	set_pev(sentry_turret, pev_controller_3, 127)
	set_pev(sentry_turret, BUILD_OWNER, id)
	static topColor, bottomColor, map
	topColor = random_num(0, 255)
	bottomColor = random_num(0, 255)
	map = topColor | (bottomColor<<8)
	set_pev(sentry_turret, pev_colormap, map)

	g_sentry_building[id] = false
	g_havesentry[id] = true
	g_sentry_turret[id] = sentry_turret
	g_sentry_upgrade[id] = 0
	g_sentry_level[id] = 1
	g_sentry_ammo[id] = get_pcvar_num(cvar_sentry_ammo[0])
	g_sentry_strength[id] = get_pcvar_num(cvar_sentry_strength[0])
}

public ck_sentry_destory(id) {
	if(pev_valid(g_sentry_base[id])) {
		if(FClassnameIs(g_sentry_base[id], SentryBase_ClassName)) {
			FX_Demolish(g_sentry_base[id])
			set_pev(g_sentry_base[id], pev_flags, pev(g_sentry_base[id], pev_flags) | FL_KILLME)
		}
	}
	if(pev_valid(g_sentry_turret[id])) {
		if(FClassnameIs(g_sentry_turret[id], SentryTurret_ClassName)) {
			FX_Demolish(g_sentry_turret[id])
			set_pev(g_sentry_turret[id], pev_flags, pev(g_sentry_turret[id], pev_flags) | FL_KILLME)
		}
	}
	g_havesentry[id] = false
	g_sentry_building[id] = false
	g_sentry_upgrade[id] = 0
	g_sentry_level[id] = 0
	g_sentry_base[id] = 0
	g_sentry_turret[id] = 0
	g_sentry_percent[id] = 0
	g_sentry_strength[id] = 0
	g_sentry_ammo[id] = 0
}

stock ck_sentry_find_player(owner) {
	new sentry = g_sentry_turret[owner]
	if(!pev_valid(sentry)) return 0
	static id, hitent, Float:sentryOrigin[3], Float:targetOrigin[3], Float:hitOrigin[3], Float:closest, Float:distance, closestid, base, Float:radius
	base = g_sentry_base[owner]
	pev(sentry, pev_origin, sentryOrigin)
	sentryOrigin[2] += 20.0
	id = 0
	if(g_sentry_level[owner] > 0 && g_sentry_level[owner] < 4)
		radius = get_pcvar_float(cvar_sentry_radius[g_sentry_level[owner]])

	while((id = engfunc(EngFunc_FindEntityInSphere, id, sentryOrigin, radius)) != 0) {
		if(!is_user_alive(id)) continue
		if(isSameTeam(id, owner) || g_round == round_setup) continue
		pev(id, pev_origin, targetOrigin)
		hitent = fm_trace_line(sentry, sentryOrigin, targetOrigin, hitOrigin)
		if(hitent == base)
			hitent = fm_trace_line(base, sentryOrigin, targetOrigin, hitOrigin)
		if(hitent == id) {
			distance = vector_distance(sentryOrigin, targetOrigin)
			if(distance < closest || closest == 0.0) { 
				closestid = id
				closest = distance
			}
		}
	}
	if(closestid != 0)
		id = closestid
	return id
}

stock isSameTeam(ida, idb) {
	if(!is_user_connected(ida) || !is_user_connected(idb))
		return false; 

	static TeamName:Team_A, TeamName:Team_B
	Team_A = rg_get_user_team(ida); 
	Team_B = rg_get_user_team(idb); 

	if(Team_A == Team_B)
		return true; 

	return false; 
}

public fw_Think_SentryTurret(sentry) {
	if(!pev_valid(sentry)) return
	static id; id = pev(sentry, BUILD_OWNER)
	new target = ck_sentry_find_player(id)
	if(is_user_alive(target)) {
		if(g_sentry_ammo[id]) {
			ck_turntotarget(sentry, target)
			ck_sentry_shoot(id, target)
			if(g_sentry_time[id] + get_pcvar_float(cvar_sentry_rocket_rof) < get_gametime())
				ck_sentry_rocket(id, target)
		}
	}
}

public fw_Think_SentryBase(sentry) {
	if(!pev_valid(sentry)) return
	set_pev(sentry, pev_nextthink, get_gametime() + SENTRY_THINK)
	static id; id = pev(sentry, BUILD_OWNER)
	if(!pev_valid(g_sentry_turret[id])) return
	fw_Think_SentryTurret(g_sentry_turret[id])
}

public ck_sentry_repair(id, which) {
	if(!g_havesentry[id] || g_engineer_metal[id] <= 0) return; 
	if(!pev_valid(g_sentry_base[id])) return; 
	static bool:health, bool:ammo
	switch(which) {
		case 1: {
			if(g_sentry_building[id]) {
				if(g_sentry_percent[id] + 2 <= 100) g_sentry_percent[id] += 2
				else g_sentry_percent[id] = 100
			} else {
				health = ck_give_sentry_health(id, 10)
				if(!health)
					ammo = ck_give_sentry_ammo(id, 10)
				if(!ammo && g_sentry_level[id] < 3)
					ck_give_sentry_upgrade(id, 10)
			}
		}
		case 2: {
			if(g_sentry_percent[id] < 100) {
				if(g_sentry_percent[id] + 5 <= 100) g_sentry_percent[id] += 5
				else g_sentry_percent[id] = 100
			} else {
				ck_give_sentry_upgrade(id, 10)
			}
		}
	}
}

public ck_sentry_repair_help(id, helper, which) {
	if(!g_havesentry[id] || g_engineer_metal[helper] <= 0) return; 
	if(!pev_valid(g_sentry_base[id])) return; 
	static bool:health, bool:ammo
	switch(which) {
		case 1: {
			if(g_sentry_building[id]) {
				if(g_sentry_percent[id] + 2 <= 100) g_sentry_percent[id] += 2
				else g_sentry_percent[id] = 100
			} else {
				health = ck_give_sentry_health_help(id, helper, 10)
				if(!health)
					ammo = ck_give_sentry_ammo_help(id, helper, 10)
				if(!ammo && g_sentry_level[id] < 3)
					ck_give_sentry_upgrade_help(id, helper, 10)
			}
		}
		case 2: {
			if(g_sentry_percent[id] < 100) {
				if(g_sentry_percent[id] + 5 <= 100) g_sentry_percent[id] += 5
				else g_sentry_percent[id] = 100
			} else {
				ck_give_sentry_upgrade_help(id, helper, 10)
			}
		}
	}
}


stock bool:ck_give_sentry_health(id, percent) { 
	if(percent <= 0)
		return false
	new maxhealth, givehealth, needmetal
	maxhealth = get_pcvar_num(cvar_sentry_strength[g_sentry_level[id]-1])
	givehealth = maxhealth * percent / 100
	if(givehealth < 1) givehealth = 1
	if(g_sentry_strength[id] >= maxhealth) {
		return false
	} else if(g_sentry_strength[id]+givehealth > maxhealth && g_sentry_strength[id] < maxhealth) {
		needmetal = (maxhealth - g_sentry_strength[id]) * 100 / maxhealth
		if(needmetal < 1) needmetal = 1
		if(g_engineer_metal[id] >= needmetal) {
			g_sentry_strength[id] = maxhealth
			g_engineer_metal[id] -= needmetal
			ck_showhud_status(id)
			return true
		} else if(g_engineer_metal[id] < needmetal && g_engineer_metal[id] > 0) {
			g_sentry_strength[id] += g_engineer_metal[id] * maxhealth / 100
			g_engineer_metal[id] = 0
			ck_showhud_status(id)
			return true
		} else {
			return false
		}
	} else if(g_sentry_strength[id]+givehealth <= maxhealth) {
		needmetal = givehealth * 100 / maxhealth
		if(needmetal < 1) needmetal = 1
		if(g_engineer_metal[id] >= needmetal) {
			g_sentry_strength[id] += givehealth
			g_engineer_metal[id] -= needmetal
			ck_showhud_status(id)
			return true
		} else if(g_engineer_metal[id] < needmetal && g_engineer_metal[id] > 0) {
			g_sentry_strength[id] += g_engineer_metal[id] * maxhealth / 100
			g_engineer_metal[id] = 0
			ck_showhud_status(id)
			return true
		} else {
			return false
		}
	}
	return false
}
stock bool:ck_give_sentry_ammo(id, percent) { 
	if(percent <= 0)
		return false
	static maxammo, needmetal, giveammo
	maxammo = get_pcvar_num(cvar_sentry_ammo[g_sentry_level[id]-1])
	giveammo = maxammo * percent / 100
	if(giveammo < 1) giveammo = 1
	if(g_sentry_ammo[id] >= maxammo) {
		return false
	} else if(g_sentry_ammo[id]+giveammo > maxammo && g_sentry_ammo[id] < maxammo) {
		needmetal = (maxammo - g_sentry_ammo[id]) * 100 / maxammo
		if(needmetal < 1) needmetal = 1
		if(g_engineer_metal[id] >= needmetal) {
			g_sentry_ammo[id] = maxammo
			g_engineer_metal[id] -= needmetal
			ck_showhud_status(id)
			return true
		} else if(g_engineer_metal[id] < needmetal && g_engineer_metal[id] > 0) {
			g_sentry_ammo[id] += g_engineer_metal[id] * maxammo / 100
			g_engineer_metal[id] = 0
			ck_showhud_status(id)
			return true
		} else {
			return false
		}
	} else if(g_sentry_ammo[id]+giveammo <= maxammo) {
		needmetal = giveammo * 100 / maxammo
		if(needmetal < 1) needmetal = 1
		if(g_engineer_metal[id] >= needmetal) {
			g_sentry_ammo[id] += giveammo
			g_engineer_metal[id] -= needmetal
			ck_showhud_status(id)
			return true
		} else if(g_engineer_metal[id] < needmetal && g_engineer_metal[id] > 0) {
			g_sentry_ammo[id] += g_engineer_metal[id] * maxammo / 100
			g_engineer_metal[id] = 0
			ck_showhud_status(id)
			return true
		} else {
			return false
		}
	}
	return false
}
stock ck_give_sentry_upgrade(id, percent) {
	if(percent <= 0)
		return ; 
	static maxupgrade, needmetal, totalupgrade
	switch(g_sentry_level[id]) {
		case 1:maxupgrade = get_pcvar_num(cvar_sentry_cost[1])
		case 2:maxupgrade = get_pcvar_num(cvar_sentry_cost[2])
	}
	totalupgrade = g_sentry_upgrade[id]+percent
	if(totalupgrade > maxupgrade && g_sentry_upgrade[id] < maxupgrade) {
		needmetal = maxupgrade - g_sentry_upgrade[id]
		if(needmetal < 1) needmetal = 1
		if(g_engineer_metal[id] >= needmetal) {
			g_sentry_upgrade[id] = maxupgrade
			g_engineer_metal[id] -= needmetal
			ck_showhud_status(id)
		}
	} else if(totalupgrade <= maxupgrade) {
		needmetal = percent
		if(needmetal < 1) needmetal = 1
		if(g_engineer_metal[id] >= needmetal) {
			g_sentry_upgrade[id] += percent
			g_engineer_metal[id] -= needmetal
			ck_showhud_status(id)
		}
	}
	if(g_engineer_metal[id] < needmetal && g_engineer_metal[id] > 0) {
		g_sentry_upgrade[id] += g_engineer_metal[id]
		g_engineer_metal[id] = 0
		ck_showhud_status(id)
	}
	if(g_sentry_upgrade[id] >= maxupgrade)
		ck_sentry_upgrade(id)
	return; 
}

stock bool:ck_give_sentry_health_help(id, helper, percent) { 
	if(percent <= 0)
		return false
	new maxhealth, givehealth, needmetal
	maxhealth = get_pcvar_num(cvar_sentry_strength[g_sentry_level[id]-1])
	givehealth = maxhealth * percent / 100
	if(givehealth < 1)
		givehealth = 1
	if(g_sentry_strength[id] >= maxhealth) {
		return false
	} else if(g_sentry_strength[id]+givehealth > maxhealth && g_sentry_strength[id] < maxhealth) {
		needmetal = (maxhealth - g_sentry_strength[id]) * 100 / maxhealth
		if(needmetal < 1)
			needmetal = 1
		if(g_engineer_metal[helper] >= needmetal) {
			g_sentry_strength[id] = maxhealth
			g_engineer_metal[helper] -= needmetal
			ck_showhud_status(id)
			return true
		} else if(g_engineer_metal[helper] < needmetal && g_engineer_metal[helper] > 0) {
			g_sentry_strength[id] += g_engineer_metal[helper] * maxhealth / 100
			g_engineer_metal[helper] = 0
			ck_showhud_status(id)
			return true
		} else {
			return false
		}
	} else if(g_sentry_strength[id]+givehealth <= maxhealth) {
		needmetal = givehealth * 100 / maxhealth
		if(needmetal < 1)
			needmetal = 1
		if(g_engineer_metal[helper] >= needmetal) {
			g_sentry_strength[id] += givehealth
			g_engineer_metal[helper] -= needmetal
			ck_showhud_status(id)
			return true
		} else if(g_engineer_metal[helper] < needmetal && g_engineer_metal[helper] > 0) {
			g_sentry_strength[id] += g_engineer_metal[helper] * maxhealth / 100
			g_engineer_metal[helper] = 0
			ck_showhud_status(id)
			return true
		} else {
			return false
		}
	}
	return false
}
stock bool:ck_give_sentry_ammo_help(id, helper, percent) { 
	if(percent <= 0)
		return false
	static maxammo, giveammo, needmetal
	maxammo = get_pcvar_num(cvar_sentry_ammo[g_sentry_level[id]-1])
	giveammo = maxammo * percent / 100
	
	if(giveammo < 1)
		giveammo = 1

	if(g_sentry_ammo[id] >= maxammo) {
		return false
	} else if(g_sentry_ammo[id]+giveammo > maxammo && g_sentry_ammo[id] < maxammo) {
		needmetal = (maxammo - g_sentry_ammo[id]) * 100 / maxammo
		if(needmetal < 1)
			needmetal = 1
		if(g_engineer_metal[helper] >= needmetal) {
			g_sentry_ammo[id] = maxammo
			g_engineer_metal[helper] -= needmetal
			ck_showhud_status(id)
			return true
		} else if(g_engineer_metal[helper] < needmetal && g_engineer_metal[helper] > 0) {
			g_sentry_ammo[id] += g_engineer_metal[helper] * maxammo / 100
			g_engineer_metal[helper] = 0
			ck_showhud_status(id)
			return true
		} else {
			return false
		}
	} else if(g_sentry_ammo[id]+giveammo <= maxammo) {
		needmetal = giveammo * 100 / maxammo
		if(needmetal < 1)
			needmetal = 1
		if(g_engineer_metal[helper] >= needmetal) {
			g_sentry_ammo[id] += giveammo
			g_engineer_metal[helper] -= needmetal
			ck_showhud_status(id)
			return true
		} else if(g_engineer_metal[helper] < needmetal && g_engineer_metal[helper] > 0) {
			g_sentry_ammo[id] += g_engineer_metal[helper] * maxammo / 100
			g_engineer_metal[helper] = 0
			ck_showhud_status(id)
			return true
		} else {
			return false
		}
	}
	return false
}

stock ck_give_sentry_upgrade_help(id, helper, percent) {
	if(percent <= 0)
		return; 
	new maxupgrade
	switch(g_sentry_level[id]) {
		case 1:maxupgrade = get_pcvar_num(cvar_sentry_cost[1])
		case 2:maxupgrade = get_pcvar_num(cvar_sentry_cost[2])
	}
	new giveupgrade = percent
	new needmetal
	if(g_sentry_upgrade[id]+giveupgrade > maxupgrade && g_sentry_upgrade[id] < maxupgrade) {
		needmetal = maxupgrade - g_sentry_upgrade[id]
		if(needmetal < 1)
			needmetal = 1
		if(g_engineer_metal[helper] >= needmetal) {
			g_sentry_upgrade[id] = maxupgrade
			g_engineer_metal[helper] -= needmetal
			ck_showhud_status(id)
		} else if(g_engineer_metal[helper] < needmetal && g_engineer_metal[helper] > 0) {
			g_sentry_upgrade[id] += g_engineer_metal[helper]
			g_engineer_metal[helper] = 0
			ck_showhud_status(id)
		}
	} else if(g_sentry_upgrade[id]+giveupgrade <= maxupgrade) {
		needmetal = giveupgrade
		if(needmetal < 1)
			needmetal = 1
		if(g_engineer_metal[helper] >= needmetal) {
			g_sentry_upgrade[id] += giveupgrade
			g_engineer_metal[helper] -= needmetal
			ck_showhud_status(id)
		} else if(g_engineer_metal[helper] < needmetal && g_engineer_metal[helper] > 0) {
			g_sentry_upgrade[id] += g_engineer_metal[helper]
			g_engineer_metal[helper] = 0
			ck_showhud_status(id)
		}
	}
	if(g_sentry_upgrade[id] >= maxupgrade)
		ck_sentry_upgrade(id)
	return; 
}

stock ck_sentry_upgrade(id) {
	if(!pev_valid(g_sentry_base[id]) || !pev_valid(g_sentry_turret[id]))
		return; 

	if(g_sentry_level[id] > 2)
		return

	engfunc(EngFunc_SetModel, g_sentry_turret[id], (g_sentry_level[id] == 1) ? Mdl_sentry_level2 : Mdl_sentry_level3)
	g_sentry_strength[id] = get_pcvar_num(cvar_sentry_strength[g_sentry_level[id]])
	g_sentry_ammo[id] = get_pcvar_num(cvar_sentry_ammo[g_sentry_level[id]])
	g_sentry_level[id]++
	g_sentry_upgrade[id] = 0
}


public ck_sentry_rocket(id, target) {
	if(!is_user_alive(id) || !is_user_alive(target)) return
	if(g_sentry_ammo[id] < get_pcvar_num(cvar_sentry_rocket_cost) || g_sentry_level[id] < 3) return

	static critical, rocket, sentry, Float:sentry_origin[3], Float:start_origin[3], Float:target_origin[3], Float:hit_origin[3], Float:angle[3], rgb[3]
	sentry = g_sentry_turret[id]

	pev(sentry, pev_origin, sentry_origin)
	pev(sentry, pev_angles, angle)
	pev(target, pev_origin, target_origin)
	ck_get_startpos(sentry, 42.0, 0.0, 18.0, start_origin)

	fm_trace_line(sentry, start_origin, target_origin, hit_origin)

	rocket = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "grenade"))
	set_pev(rocket, pev_origin, start_origin)
	set_pev(rocket, pev_angles, angle)
	engfunc(EngFunc_SetModel, rocket, Bullet_soldier_primary)
	set_pev(rocket, pev_classname, g_EntityClassnames[SentryRocket_Classname])
	set_pev(rocket, PROJECTILE_REFLECT, 0)
	set_pev(rocket, pev_owner, id)
	critical = random_num(1, 100)
	if(critical <= g_critical[id] || g_critical_on[id]) {
		set_pev(rocket, PROJECTILE_CRITICAL, 1)
		rgb = (rg_get_user_team(id) == TEAM_TERRORIST) ? {255, 50, 0} : {0, 50, 255}
		fm_set_rendering(rocket, kRenderFxGlowShell, rgb[0], rgb[1], rgb[2], kRenderNormal, 32)
	}
	else {
		rgb = {100, 100, 100}
	}
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY); 
	write_byte(TE_BEAMFOLLOW); 
	write_short(rocket); 	// entity
	write_short(spr_trail); 	// sprite
	write_byte(10); 		// life
	write_byte(5); 		// width
	write_byte(rgb[0]); 	// r
	write_byte(rgb[1]); 	// g
	write_byte(rgb[2]); 	// b
	write_byte(200); 	// brightness
	message_end(); 

	set_pev(rocket, pev_mins, {-1.0, -1.0, -1.0})
	set_pev(rocket, pev_maxs, {1.0, 1.0, 1.0})

	set_pev(rocket, pev_solid, SOLID_TRIGGER)
	set_pev(rocket, pev_movetype, MOVETYPE_FLYMISSILE)

	static Float:velocity[3]
	get_speed_vector(start_origin, target_origin, float(get_pcvar_num(cvar_sentry_rocket_velocity)), velocity)
	set_pev(rocket, pev_velocity, velocity)

	fm_set_entity_view(rocket, target_origin)

	g_sentry_time[id] = get_gametime()
	g_sentry_ammo[id] -= get_pcvar_num(cvar_sentry_rocket_cost)
	engfunc(EngFunc_EmitSound, sentry, CHAN_STATIC, Snd_sentry_rocket, 1.0, ATTN_NORM, 0, PITCH_NORM)
	ck_showhud_status(id)
}

public dispenser_build(id) {
	if(!is_user_alive(id) || g_class[id] != CLASS_ENGINEER)
		return
	if(g_engineer_metal[id] < get_pcvar_num(cvar_dispenser_cost[0])) {
		client_print(id, print_center, "%L", id, "MSG_BUILD_ENOUGHMETAL")
		return
	} else if(!(pev(id, pev_flags) & FL_ONGROUND)) {
		client_print(id, print_center, "%L", id, "MSG_BUILD_ONGROUND")
		return
	} else if(pev(id, pev_bInDuck)) {
		client_print(id, print_center, "%L", id, "MSG_BUILD_DUCK")
		return
	} else if(g_havedispenser[id] || g_dispenser_building[id] || g_dispenser_percent[id] > 0) {
		client_print(id, print_center, "%L", id, "MSG_BUILD_HAVE")
		return
	}
	static Float:Origin[3], Float:vNewOrigin[3], Float:vTraceDirection[3], Float:vTraceEnd[3], Float:vTraceResult[3]
	pev(id, pev_origin, Origin)
	velocity_by_aim(id, 64, vTraceDirection)
	vTraceEnd[0] = vTraceDirection[0] + Origin[0]
	vTraceEnd[1] = vTraceDirection[1] + Origin[1]
	vTraceEnd[2] = vTraceDirection[2] + Origin[2]
	fm_trace_line(id, Origin, vTraceEnd, vTraceResult)
	vNewOrigin[0] = vTraceResult[0]
	vNewOrigin[1] = vTraceResult[1]
	vNewOrigin[2] = Origin[2]
	if(!(ck_dispenser_build(vNewOrigin, id)))
		client_print(id, print_center, "%L", id, "MSG_BUILD_UNABLE")
}
stock bool:ck_dispenser_build(Float:origin[3], id) {
	if(fm_point_contents(origin) != CONTENTS_EMPTY || is_hull_default(origin, 24.0))
		return false
	new Float:hitPoint[3], Float:originDown[3]
	originDown = origin
	originDown[2] = -5000.0
	fm_trace_line(0, origin, originDown, hitPoint)
	new Float:DistanceFromGround = vector_distance(origin, hitPoint)

	new Float:difference = 36.0 - DistanceFromGround
	if(difference < -1 * 10.0 || difference > 10.0) return false
	new dispenser = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "func_breakable"))
	if(!dispenser)
		return false
	
	fm_set_kvd(dispenser, "health", "10000", "func_breakable")
	fm_set_kvd(dispenser, "material", "6", "func_breakable")
	fm_DispatchSpawn(dispenser)

	set_pev(dispenser, pev_classname, Dispenser_ClassName)
	engfunc(EngFunc_SetModel, dispenser, Mdl_dispenser)
	engfunc(EngFunc_SetSize, dispenser, { -16.0, -16.0, 0.0 }, { 16.0, 16.0, 48.0 })
	engfunc(EngFunc_SetOrigin, dispenser, origin)
	pev(id, pev_v_angle, origin)
	origin[0] = 0.0
	origin[1] += 180.0
	origin[2] = 0.0
	set_pev(dispenser, pev_angles, origin)
	set_pev(dispenser, pev_solid, SOLID_SLIDEBOX)
	set_pev(dispenser, pev_movetype, MOVETYPE_TOSS)
	set_pev(dispenser, BUILD_OWNER, id)
	g_dispenser[id] = dispenser
	g_dispenser_building[id] = true
	g_dispenser_strength[id] = 1
	g_havedispenser[id] = true
	g_engineer_metal[id] -= get_pcvar_num(cvar_dispenser_cost[0])

	// anim criação
	UTIL_SetAnim(dispenser, 0, 0.45)

	return true
}
public ck_dispenser_completed(id) {
	if(!is_user_alive(id)) return
	if(g_class[id] != CLASS_ENGINEER || !g_havedispenser[id]) return
	new dispenser = g_dispenser[id]
	g_dispenser_building[id] = false
	g_dispenser_upgrade[id] = 0
	g_dispenser_level[id] = 1
	g_dispenser_strength[id] = get_pcvar_num(cvar_dispenser_strength[0])
	g_dispenser_ammo[id] = get_pcvar_num(cvar_dispenser_ammo[0])
	set_pev(dispenser, pev_nextthink, get_gametime() + DISPENSER_THINK)
}
public ck_dispenser_destory(id) {
	new class[24]
	if(pev_valid(g_dispenser[id])) {
		pev(g_dispenser[id], pev_classname, class, 23)
		if(equal(class, Dispenser_ClassName)) {
			FX_Demolish(g_dispenser[id])
			set_pev(g_dispenser[id], pev_flags, pev(g_dispenser[id], pev_flags) | FL_KILLME)
		}
	}
	g_havedispenser[id] = false
	g_dispenser_building[id] = false
	g_dispenser[id] = 0
	g_dispenser_upgrade[id] = 0
	g_dispenser_level[id] = 0
	g_dispenser_percent[id] = 0
	g_dispenser_strength[id] = 0
	g_dispenser_ammo[id] = 0
}
public fw_Think_Dispenser(dispenser) {
	if(!pev_valid(dispenser)) return
	static id; id = pev(dispenser, BUILD_OWNER)
	new Float:radius, heal, Float:respawn, Float:GameTime; 
	GameTime = get_gametime(); 
	radius = get_pcvar_float(cvar_dispenser_radius[g_dispenser_level[id]-1])
	heal = get_pcvar_num(cvar_dispenser_heal[g_dispenser_level[id]-1])
	respawn = get_pcvar_float(cvar_dispenser_rsp[g_dispenser_level[id]-1])
	
	if(g_dispenser_respawn[id] + respawn <= GameTime) {
		ck_dispenser_respawn(id, 10)
		g_dispenser_respawn[id] = GameTime

		UTIL_SetAnim(dispenser, 1, 1.0)

	}
	new Float:dispenser_origin[3]
	pev(dispenser, pev_origin, dispenser_origin)
	dispenser_origin[2] += 24.0

	static target, bool:pickup
	while((target = engfunc(EngFunc_FindEntityInSphere, target, dispenser_origin, radius)) != 0) {
		if(!is_user_alive(target))
			continue
		if(!isSameTeam(id, target)) 
			continue
		if(g_dispenser_rescan[id] + get_pcvar_float(cvar_dispenser_rescan) <= GameTime) { // 0.2s:1 0.4:2 3.0:15
			engfunc(EngFunc_EmitSound, id, CHAN_ITEM, Snd_dispenser_heal, 1.0, ATTN_NORM, 0, PITCH_NORM)
			g_dispenser_rescan[id] = GameTime
		}
		ck_give_user_health_amount(target, heal)
		FX_Healbeam(dispenser, target, 225, 25, 25, 6)
		if(g_pickup[target] + PICKUP_DELAY > GameTime)
			continue
		pickup = false
		if(g_dispenser_ammo[id] >= get_pcvar_num(cvar_dispenser_supply))
			pickup = ck_give_user_ammo(target, get_pcvar_num(cvar_dispenser_supply))
		if(pickup) {
			engfunc(EngFunc_EmitSound, target, CHAN_ITEM, "items/gunpickup3.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
			g_dispenser_ammo[id] -= get_pcvar_num(cvar_dispenser_supply)
			ck_showhud_status(id)
			ck_showhud_status(target)
			g_pickup[target] = GameTime
		}
	}
	set_pev(dispenser, pev_nextthink, GameTime + DISPENSER_THINK)
}
public ck_dispenser_repair(id, which) {
	if(!g_havedispenser[id] || g_engineer_metal[id] <= 0) return; 
	new dispenser = g_dispenser[id]
	if(!pev_valid(dispenser)) return; 
	new bool:health, bool:ammo
	switch(which) {
		case 1: {
			if(g_dispenser_building[id]) {
				if(g_dispenser_percent[id] + 2 <= 100) g_dispenser_percent[id] += 2
				else g_dispenser_percent[id] = 100
			} else {
				health = ck_give_disp_health(id, 10)
				if(!health)
					ammo = ck_give_disp_ammo(id, 10)
				if(!ammo && g_dispenser_level[id] < 3)
					ck_give_disp_upgrade(id, 10)
			}
		}
		case 2: {
			if(g_dispenser_percent[id] < 100) {
				if(g_dispenser_percent[id] + 5 <= 100) g_dispenser_percent[id] += 5
				else g_dispenser_percent[id] = 100
			} else {
				ck_give_disp_upgrade(id, 10)
			}
		}
	}
}
public ck_dispenser_repair_help(id, helper, which) {
	if(!g_havedispenser[id] || g_engineer_metal[helper] <= 0) return; 
	new dispenser = g_dispenser[id]
	if(!pev_valid(dispenser)) return; 
	new bool:health, bool:ammo
	switch(which) {
		case 1: {
			if(g_dispenser_building[id]) {
				if(g_dispenser_percent[id] + 2 <= 100) g_dispenser_percent[id] += 2
				else g_dispenser_percent[id] = 100
			} else {
				health = ck_give_disp_health_help(id, helper, 10)
				if(!health)
					ammo = ck_give_disp_ammo_help(id, helper, 10)
				if(!ammo && g_dispenser_level[id] < 3)
					ck_give_disp_upgrade_help(id, helper, 10)
			}
		}
		case 2: {
			if(g_dispenser_percent[id] < 100) {
				if(g_dispenser_percent[id] + 5 <= 100) g_dispenser_percent[id] += 5
				else g_dispenser_percent[id] = 100
			} else {
				ck_give_disp_upgrade_help(id, helper, 10)
			}
		}
	}
}

stock bool:ck_give_disp_health(id, percent) { 
	if(percent <= 0)
		return false
	static maxhealth, givehealth, needmetal
	maxhealth = get_pcvar_num(cvar_dispenser_strength[g_dispenser_level[id]-1])
	
	givehealth = maxhealth * percent / 100
	if(givehealth < 1)
		givehealth = 1

	if(g_dispenser_strength[id] >= maxhealth) {
		return false
	} else if(g_dispenser_strength[id]+givehealth > maxhealth && g_dispenser_strength[id] < maxhealth) {
		needmetal = (maxhealth - g_dispenser_strength[id]) * 100 / maxhealth
		if(needmetal < 1)
			needmetal = 1
		if(g_engineer_metal[id] >= needmetal) {
			g_dispenser_strength[id] = maxhealth
			g_engineer_metal[id] -= needmetal
			ck_showhud_status(id)
			return true
		} else if(g_engineer_metal[id] < needmetal && g_engineer_metal[id] > 0) {
			g_dispenser_strength[id] += g_engineer_metal[id] * maxhealth / 100
			g_engineer_metal[id] = 0
			ck_showhud_status(id)
			return true
		} else {
			return false
		}
	} else if(g_dispenser_strength[id]+givehealth <= maxhealth) {
		needmetal = givehealth * 100 / maxhealth
		if(needmetal < 1)
			needmetal = 1
		if(g_engineer_metal[id] >= needmetal) {
			g_dispenser_strength[id] += givehealth
			g_engineer_metal[id] -= needmetal
			ck_showhud_status(id)
			return true
		} else if(g_engineer_metal[id] < needmetal && g_engineer_metal[id] > 0) {
			g_dispenser_strength[id] += g_engineer_metal[id] * maxhealth / 100
			g_engineer_metal[id] = 0
			ck_showhud_status(id)
			return true
		} else {
			return false
		}
	}
	return false
}
stock bool:ck_give_disp_ammo(id, percent) { 
	if(percent <= 0)
		return false
	static maxammo, giveammo, needmetal
	maxammo = get_pcvar_num(cvar_dispenser_ammo[g_dispenser_level[id]-1])
	giveammo = maxammo * percent / 100
	if(giveammo < 1)
		giveammo = 1
	if(g_dispenser_ammo[id] >= maxammo) {
		return false
	} else if(g_dispenser_ammo[id]+giveammo > maxammo && g_dispenser_ammo[id] < maxammo) {
		needmetal = (maxammo - g_dispenser_ammo[id]) * 100 / maxammo
		if(needmetal < 1)
			needmetal = 1
		if(g_engineer_metal[id] >= needmetal) {
			g_dispenser_ammo[id] = maxammo
			g_engineer_metal[id] -= needmetal
			ck_showhud_status(id)
			return true
		} else if(g_engineer_metal[id] < needmetal && g_engineer_metal[id] > 0) {
			g_dispenser_ammo[id] += g_engineer_metal[id] * maxammo / 100
			g_engineer_metal[id] = 0
			ck_showhud_status(id)
			return true
		} else {
			return false
		}
	} else if(g_dispenser_ammo[id]+giveammo <= maxammo) {
		needmetal = giveammo * 100 / maxammo
		if(needmetal < 1)
			needmetal = 1
		if(g_engineer_metal[id] >= needmetal) {
			g_dispenser_ammo[id] += giveammo
			g_engineer_metal[id] -= needmetal
			ck_showhud_status(id)
			return true
		} else if(g_engineer_metal[id] < needmetal && g_engineer_metal[id] > 0) {
			g_dispenser_ammo[id] += g_engineer_metal[id] * maxammo / 100
			g_engineer_metal[id] = 0
			ck_showhud_status(id)
			return true
		} else {
			return false
		}
	}
	return false
}
stock ck_give_disp_upgrade(id, percent) {
	if(percent <= 0)
		return ; 
	static maxupgrade, giveupgrade, needmetal
	maxupgrade = get_pcvar_num(cvar_dispenser_cost[g_dispenser_level[id]])
	giveupgrade = percent
	if(g_dispenser_upgrade[id]+giveupgrade > maxupgrade && g_dispenser_upgrade[id] < maxupgrade) {
		needmetal = maxupgrade - g_dispenser_upgrade[id]
		if(needmetal < 1)
			needmetal = 1
		if(g_engineer_metal[id] >= needmetal) {
			g_dispenser_upgrade[id] = maxupgrade
			g_engineer_metal[id] -= needmetal
			ck_showhud_status(id)
		} else if(g_engineer_metal[id] < needmetal && g_engineer_metal[id] > 0) {
			g_dispenser_upgrade[id] += g_engineer_metal[id]
			g_engineer_metal[id] = 0
			ck_showhud_status(id)
		}
	} else if(g_dispenser_upgrade[id]+giveupgrade <= maxupgrade) {
		needmetal = giveupgrade
		if(needmetal < 1)
			needmetal = 1
		if(g_engineer_metal[id] >= needmetal) {
			g_dispenser_upgrade[id] += giveupgrade
			g_engineer_metal[id] -= needmetal
			ck_showhud_status(id)
		} else if(g_engineer_metal[id] < needmetal && g_engineer_metal[id] > 0) {
			g_dispenser_upgrade[id] += g_engineer_metal[id]
			g_engineer_metal[id] = 0
			ck_showhud_status(id)
		}
	}
	if(g_dispenser_upgrade[id] >= maxupgrade)
		ck_dispenser_upgrade(id)
	return; 
}

stock bool:ck_give_disp_health_help(id, helper, percent) { 
	if(percent <= 0)
		return false
	new maxhealth, givehealth, needmetal
	maxhealth = get_pcvar_num(cvar_dispenser_strength[g_dispenser_level[id]-1])
	givehealth = maxhealth * percent / 100
	if(givehealth < 1)
		givehealth = 1
	if(g_dispenser_strength[id] >= maxhealth) {
		return false
	} else if(g_dispenser_strength[id]+givehealth > maxhealth && g_dispenser_strength[id] < maxhealth) {
		needmetal = (maxhealth - g_dispenser_strength[id]) * 100 / maxhealth
		if(needmetal < 1)
			needmetal = 1
		if(g_engineer_metal[helper] >= needmetal) {
			g_dispenser_strength[id] = maxhealth
			g_engineer_metal[helper] -= needmetal
			ck_showhud_status(id)
			return true
		} else if(g_engineer_metal[helper] < needmetal && g_engineer_metal[helper] > 0) {
			g_dispenser_strength[id] += g_engineer_metal[helper] * maxhealth / 100
			g_engineer_metal[helper] = 0
			ck_showhud_status(id)
			return true
		} else {
			return false
		}
	} else if(g_dispenser_strength[id]+givehealth <= maxhealth) {
		needmetal = givehealth * 100 / maxhealth
		if(needmetal < 1)
			needmetal = 1
		if(g_engineer_metal[helper] >= needmetal) {
			g_dispenser_strength[id] += givehealth
			g_engineer_metal[helper] -= needmetal
			ck_showhud_status(id)
			return true
		} else if(g_engineer_metal[helper] < needmetal && g_engineer_metal[helper] > 0) {
			g_dispenser_strength[id] += g_engineer_metal[helper] * maxhealth / 100
			g_engineer_metal[helper] = 0
			ck_showhud_status(id)
			return true
		} else {
			return false
		}
	}
	return false
}
stock bool:ck_give_disp_ammo_help(id, helper, percent) { 
	if(percent <= 0)
		return false
	new maxammo
	switch(g_dispenser_level[id]) {
		case 1:maxammo = get_pcvar_num(cvar_dispenser_ammo[0])
		case 2:maxammo = get_pcvar_num(cvar_dispenser_ammo[1])
		case 3:maxammo = get_pcvar_num(cvar_dispenser_ammo[2])
	}
	new giveammo = maxammo * percent / 100
	if(giveammo < 1)
		giveammo = 1
	new needmetal
	if(g_dispenser_ammo[id] >= maxammo) {
		return false
	} else if(g_dispenser_ammo[id]+giveammo > maxammo && g_dispenser_ammo[id] < maxammo) {
		needmetal = (maxammo - g_dispenser_ammo[id]) * 100 / maxammo
		if(needmetal < 1)
			needmetal = 1
		if(g_engineer_metal[helper] >= needmetal) {
			g_dispenser_ammo[id] = maxammo
			g_engineer_metal[helper] -= needmetal
			ck_showhud_status(id)
			return true
		} else if(g_engineer_metal[helper] < needmetal && g_engineer_metal[helper] > 0) {
			g_dispenser_ammo[id] += g_engineer_metal[helper] * maxammo / 100
			g_engineer_metal[helper] = 0
			ck_showhud_status(id)
			return true
		} else {
			return false
		}
	} else if(g_dispenser_ammo[id]+giveammo <= maxammo) {
		needmetal = giveammo * 100 / maxammo
		if(needmetal < 1)
			needmetal = 1
		if(g_engineer_metal[helper] >= needmetal) {
			g_dispenser_ammo[id] += giveammo
			g_engineer_metal[helper] -= needmetal
			ck_showhud_status(id)
			return true
		} else if(g_engineer_metal[helper] < needmetal && g_engineer_metal[helper] > 0) {
			g_dispenser_ammo[id] += g_engineer_metal[helper] * maxammo / 100
			g_engineer_metal[helper] = 0
			ck_showhud_status(id)
			return true
		} else {
			return false
		}
	}
	return false
}
stock ck_give_disp_upgrade_help(id, helper, percent) {
	if(percent <= 0)
		return ; 
	new maxupgrade
	switch(g_dispenser_level[id]) {
		case 1:maxupgrade = get_pcvar_num(cvar_dispenser_cost[1])
		case 2:maxupgrade = get_pcvar_num(cvar_dispenser_cost[2])
	}
	new giveupgrade = percent
	new needmetal
	if(g_dispenser_upgrade[id]+giveupgrade > maxupgrade && g_dispenser_upgrade[id] < maxupgrade) {
		needmetal = maxupgrade - g_dispenser_upgrade[id]
		if(needmetal < 1)
			needmetal = 1
		if(g_engineer_metal[helper] >= needmetal) {
			g_dispenser_upgrade[id] = maxupgrade
			g_engineer_metal[helper] -= needmetal
			ck_showhud_status(id)
		} else if(g_engineer_metal[helper] < needmetal && g_engineer_metal[helper] > 0) {
			g_dispenser_upgrade[id] += g_engineer_metal[helper]
			g_engineer_metal[helper] = 0
			ck_showhud_status(id)
		}
	} else if(g_dispenser_upgrade[id]+giveupgrade <= maxupgrade) {
		needmetal = giveupgrade
		if(needmetal < 1)
			needmetal = 1
		if(g_engineer_metal[helper] >= needmetal) {
			g_dispenser_upgrade[id] += giveupgrade
			g_engineer_metal[helper] -= needmetal
			ck_showhud_status(id)
		} else if(g_engineer_metal[helper] < needmetal && g_engineer_metal[helper] > 0) {
			g_dispenser_upgrade[id] += g_engineer_metal[helper]
			g_engineer_metal[helper] = 0
			ck_showhud_status(id)
		}
	}
	if(g_dispenser_upgrade[id] >= maxupgrade)
		ck_dispenser_upgrade(id)
	return; 
}


stock ck_dispenser_respawn(id, percent) {
	if(percent <= 0)
		return
	new maxammo
	switch(g_dispenser_level[id]) {
		case 1:maxammo = get_pcvar_num(cvar_dispenser_ammo[0])
		case 2:maxammo = get_pcvar_num(cvar_dispenser_ammo[1])
		case 3:maxammo = get_pcvar_num(cvar_dispenser_ammo[2])
	}
	new giveammo = maxammo * percent / 100
	if(giveammo < 1)
		giveammo = 1
	if(g_dispenser_ammo[id] >= maxammo) {
		return
	} else if(g_dispenser_ammo[id]+giveammo > maxammo && g_dispenser_ammo[id] < maxammo) {
		g_dispenser_ammo[id] = maxammo
		ck_showhud_status(id)
		return
	} else if(g_dispenser_ammo[id]+giveammo <= maxammo) {
		g_dispenser_ammo[id] += giveammo
		ck_showhud_status(id)
		return
	}
	return
}
stock ck_dispenser_upgrade(id) {
	new dispenser = g_dispenser[id]
	if(!pev_valid(dispenser))
		return; 
	switch(g_dispenser_level[id]) {
		case 1: {
			g_dispenser_strength[id] = get_pcvar_num(cvar_dispenser_strength[1])
			g_dispenser_ammo[id] = get_pcvar_num(cvar_dispenser_ammo[1])
			g_dispenser_level[id]++
			g_dispenser_upgrade[id] = 0
		}
		case 2: {
			g_dispenser_strength[id] = get_pcvar_num(cvar_dispenser_strength[2])
			g_dispenser_ammo[id] = get_pcvar_num(cvar_dispenser_ammo[2])
			g_dispenser_level[id]++
			g_dispenser_upgrade[id] = 0
		}
	}
	return; 
}

public telein_build(id) {
	if(!is_user_alive(id) || g_class[id] != CLASS_ENGINEER)
		return
	if(g_engineer_metal[id] < get_pcvar_num(cvar_telein_cost)) {
		client_print(id, print_center, "%L", id, "MSG_BUILD_ENOUGHMETAL")
		return
	} else if(!(pev(id, pev_flags) & FL_ONGROUND)) {
		client_print(id, print_center, "%L", id, "MSG_BUILD_ONGROUND")
		return
	} else if(pev(id, pev_bInDuck)) {
		client_print(id, print_center, "%L", id, "MSG_BUILD_DUCK")
		return
	} else if(g_havetelein[id] || g_telein_building[id] || g_telein_percent[id] > 0) {
		client_print(id, print_center, "%L", id, "MSG_BUILD_HAVE")
		return
	}
	new Float:Origin[3]
	pev(id, pev_origin, Origin)
	new Float:vNewOrigin[3]
	new Float:vTraceDirection[3]
	new Float:vTraceEnd[3]
	new Float:vTraceResult[3]
	velocity_by_aim(id, 64, vTraceDirection)
	vTraceEnd[0] = vTraceDirection[0] + Origin[0]
	vTraceEnd[1] = vTraceDirection[1] + Origin[1]
	vTraceEnd[2] = vTraceDirection[2] + Origin[2]
	fm_trace_line(id, Origin, vTraceEnd, vTraceResult)
	vNewOrigin[0] = vTraceResult[0]
	vNewOrigin[1] = vTraceResult[1]
	vNewOrigin[2] = Origin[2]
	if(!(ck_telein_build(vNewOrigin, id)))
		client_print(id, print_center, "%L", id, "MSG_BUILD_UNABLE")
}
stock bool:ck_telein_build(Float:origin[3], id) {
	if(fm_point_contents(origin) != CONTENTS_EMPTY || is_hull_default(origin, 24.0))
		return false
	new Float:hitPoint[3], Float:originDown[3]
	originDown = origin
	originDown[2] = -5000.0
	fm_trace_line(0, origin, originDown, hitPoint)
	new Float:DistanceFromGround = vector_distance(origin, hitPoint)

	new Float:difference = 36.0 - DistanceFromGround
	if(difference < -1 * 10.0 || difference > 10.0) return false
	new telein = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "func_breakable"))
	if(!telein) return false
	
	fm_set_kvd(telein, "health", "10000", "func_breakable")
	fm_set_kvd(telein, "material", "6", "func_breakable")
	fm_DispatchSpawn(telein)

	set_pev(telein, pev_classname, Telein_ClassName)
	engfunc(EngFunc_SetModel, telein, Mdl_teleporter)
	engfunc(EngFunc_SetSize, telein, {-16.0, -16.0, 0.0}, {16.0, 16.0, 12.0})
	engfunc(EngFunc_SetOrigin, telein, origin)
	pev(id, pev_v_angle, origin)
	origin[0] = 0.0
	origin[1] += 180.0
	origin[2] = 0.0
	set_pev(telein, pev_angles, origin)
	set_pev(telein, pev_solid, SOLID_SLIDEBOX)
	set_pev(telein, pev_movetype, MOVETYPE_TOSS)
	set_pev(telein, BUILD_OWNER, id)
	g_telein[id] = telein
	g_telein_building[id] = true
	g_telein_strength[id] = 1
	g_havetelein[id] = true
	g_engineer_metal[id] -= get_pcvar_num(cvar_telein_cost)
	return true
}
public ck_telein_completed(id) {
	if(!is_user_alive(id)) return
	if(g_class[id] != CLASS_ENGINEER || !g_havetelein[id]) return
	if(!(g_haveteleout[id] && !g_teleout_building[id])) {
		gtele_upgrade[id] = 0
		gtele_level[id] = 1
	}
	g_tele_reload[id] = 100
	g_telein_building[id] = false
	g_telein_strength[id] = get_pcvar_num(cvar_telein_strength[0])
	if(pev_valid(g_telein[id]) && g_haveteleout[id] && !g_teleout_building[id]) {
		set_pev(g_telein[id], pev_framerate, float(gtele_level[id]))
		set_pev(g_telein[id], pev_sequence, 1)
	}
	set_pev(g_telein[id], pev_nextthink, get_gametime() + TELEIN_THINK)
}

public ck_telein_destory(id, reset) {
	new class[24]
	if(pev_valid(g_telein[id])) {
		pev(g_telein[id], pev_classname, class, 23)
		if(equal(class, Telein_ClassName)) {
			FX_Demolish(g_telein[id])
			set_pev(g_telein[id], pev_flags, pev(g_telein[id], pev_flags) | FL_KILLME)
		}
	}
	g_havetelein[id] = false
	g_telein_building[id] = false
	g_telein_percent[id] = 0
	g_telein_strength[id] = 0
	g_telein[id] = 0
	if(!g_haveteleout[id] || reset) {
		gtele_upgrade[id] = 0
		gtele_level[id] = 0
	}
	g_tele_reload[id] = 0
	g_tele_stand[id] = 0
	g_tele_timer[id] = 0.0
}
public fw_Think_Telein(telein) {
	if(!pev_valid(telein)) return
	static id; id = pev(telein, BUILD_OWNER)
	if(g_tele_reload[id] < 100) {
		switch(gtele_level[id]) {
			case 1:	g_tele_reload[id] += get_pcvar_num(cvar_tele_reload[0])
			case 2: g_tele_reload[id] += get_pcvar_num(cvar_tele_reload[1])
			case 3:	g_tele_reload[id] += get_pcvar_num(cvar_tele_reload[2])
		}
		if(g_tele_reload[id] > 100) g_tele_reload[id] = 100
	}
	set_pev(telein, pev_framerate, float(g_tele_reload[id]) * float(gtele_level[id]) / 100.0)
	if(g_haveteleout[id] && !g_teleout_building[id]) set_pev(telein, pev_sequence, 1)
	else set_pev(telein, pev_sequence, 0)

	set_pev(telein, pev_nextthink, get_gametime() + TELEIN_THINK)

	if(!(g_haveteleout[id] && !g_teleout_building[id])) return
	if(g_tele_reload[id] < 100) return
	new Float:telein_origin[3], Float:player_origin[3], Float:distance, Float:closest
	new player, closestid
	pev(telein, pev_origin, telein_origin)
	telein_origin[2] += 12.0

	while((player = engfunc(EngFunc_FindEntityInSphere, player, telein_origin, 16.0))) {
		if(!(0 < player <= global_get(glb_maxClients)))
			continue
		if(!is_user_alive(player))
			continue
		if(!(pev(player, pev_flags) & FL_ONGROUND))
			continue
		pev(player, pev_origin, player_origin)
		distance = vector_distance(telein_origin, player_origin)
		if(distance < closest || closest == 0.0) {
			closest = distance
			closestid = player
		}
	}
	if(!closestid) {
		g_tele_stand[id] = 0
		g_tele_timer[id] = 0.0
	} else if(closestid == g_tele_stand[id]) {
		if(get_gametime() - g_tele_timer[id] >= TELE_DELAY) ck_tele_player(id, closestid)
	} else {
		g_tele_stand[id] = closestid
		g_tele_timer[id] = get_gametime()
	}
}
public ck_telein_repair(id, which) {
	if(!g_havetelein[id] || g_engineer_metal[id] <= 0) return; 
	new telein = g_telein[id]
	if(!pev_valid(telein)) return; 
	new bool:health, bool:reload
	switch(which) {
		case 1: {
			if(g_telein_building[id]) {
				if(g_telein_percent[id] + 2 <= 100) g_telein_percent[id] += 2
				else g_telein_percent[id] = 100
			} else {
				health = ck_give_telein_health(id, 10)
				if(!health)
					reload = ck_give_tele_reload(id, 10)
				if(!reload && gtele_level[id] < 3)
					ck_give_tele_upgrade(id, 10)
			}
		}
		case 2: {
			if(g_telein_percent[id] < 100) {
				if(g_telein_percent[id] + 5 <= 100) g_telein_percent[id] += 5
				else g_telein_percent[id] = 100
			} else {
				ck_give_tele_upgrade(id, 10)
			}
		}
	}
}
public ck_telein_repair_help(id, helper, which) {
	if(!g_havetelein[id] || g_engineer_metal[helper] <= 0) return; 
	new telein = g_telein[id]
	if(!pev_valid(telein)) return; 
	new bool:health, bool:reload
	switch(which) {
		case 1: {
			if(g_telein_building[id]) {
				if(g_telein_percent[id] + 2 <= 100) g_telein_percent[id] += 2
				else g_telein_percent[id] = 100
			} else {
				health = ck_give_telein_health_help(id, helper, 10)
				if(!health)
					reload = ck_give_tele_reload_help(id, 10)
				if(!reload && gtele_level[id] < 3)
					ck_give_tele_upgrade_help(id, helper, 10)
			}
		}
		case 2: {
			if(g_telein_percent[id] < 100) {
				if(g_telein_percent[id] + 5 <= 100) g_telein_percent[id] += 5
				else g_telein_percent[id] = 100
			} else {
				ck_give_tele_upgrade_help(id, helper, 10)
			}
		}
	}
}
public ck_teleout_repair(id, which) {
	if(!g_haveteleout[id] || g_engineer_metal[id] <= 0) return; 
	new teleout = g_teleout[id]
	if(!pev_valid(teleout)) return; 
	new bool:health, bool:reload
	switch(which) {
		case 1: {
			if(g_teleout_building[id]) {
				if(g_teleout_percent[id] + 2 <= 100) g_teleout_percent[id] += 2
				else g_teleout_percent[id] = 100
			} else {
				health = ck_give_teleout_health(id, 10)
				if(!health)
					reload = ck_give_tele_reload(id, 10)
				if(!reload && gtele_level[id] < 3)
					ck_give_tele_upgrade(id, 10)
			}
		}
		case 2: {
			if(g_teleout_percent[id] < 100) {
				if(g_teleout_percent[id] + 5 <= 100) g_teleout_percent[id] += 5
				else g_teleout_percent[id] = 100
			} else {
				ck_give_tele_upgrade(id, 10)
			}
		}
	}
}
public ck_teleout_repair_help(id, helper, which) {
	if(!g_haveteleout[id] || g_engineer_metal[helper] <= 0) return; 
	new teleout = g_teleout[id]
	if(!pev_valid(teleout)) return; 
	new bool:health, bool:reload
	switch(which) {
		case 1: {
			if(g_teleout_building[id]) {
				if(g_teleout_percent[id] + 2 <= 100) g_teleout_percent[id] += 2
				else g_teleout_percent[id] = 100
			} else {
				health = ck_give_teleout_health_help(id, helper, 10)
				if(!health)
					reload = ck_give_tele_reload_help(id, 10)
				if(!reload && gtele_level[id] < 3)
					ck_give_tele_upgrade_help(id, helper, 10)
			}
		}
		case 2: {
			if(g_teleout_percent[id] < 100) {
				if(g_teleout_percent[id] + 5 <= 100) g_teleout_percent[id] += 5
				else g_teleout_percent[id] = 100
			} else {
				ck_give_tele_upgrade_help(id, helper, 10)
			}
		}
	}
}

public teleout_build(id) {
	if(!is_user_alive(id) || g_class[id] != CLASS_ENGINEER)
		return
	if(g_engineer_metal[id] < get_pcvar_num(cvar_teleout_cost)) {
		client_print(id, print_center, "%L", id, "MSG_BUILD_ENOUGHMETAL")
		return
	} else if(!(pev(id, pev_flags) & FL_ONGROUND)) {
		client_print(id, print_center, "%L", id, "MSG_BUILD_ONGROUND")
		return
	} else if(pev(id, pev_bInDuck)) {
		client_print(id, print_center, "%L", id, "MSG_BUILD_DUCK")
		return
	} else if(g_haveteleout[id] || g_teleout_building[id] || g_teleout_percent[id] > 0) {
		client_print(id, print_center, "%L", id, "MSG_BUILD_HAVE")
		return
	}
	new Float:Origin[3]
	pev(id, pev_origin, Origin)
	new Float:vNewOrigin[3]
	new Float:vTraceDirection[3]
	new Float:vTraceEnd[3]
	new Float:vTraceResult[3]
	velocity_by_aim(id, 64, vTraceDirection)
	vTraceEnd[0] = vTraceDirection[0] + Origin[0]
	vTraceEnd[1] = vTraceDirection[1] + Origin[1]
	vTraceEnd[2] = vTraceDirection[2] + Origin[2]
	fm_trace_line(id, Origin, vTraceEnd, vTraceResult)
	vNewOrigin[0] = vTraceResult[0]
	vNewOrigin[1] = vTraceResult[1]
	vNewOrigin[2] = Origin[2]
	if(!(ck_teleout_build(vNewOrigin, id)))
		client_print(id, print_center, "%L", id, "MSG_BUILD_UNABLE")
}
stock bool:ck_teleout_build(Float:origin[3], id) {
	if(fm_point_contents(origin) != CONTENTS_EMPTY || is_hull_default(origin, 24.0))
		return false
	new Float:hitPoint[3], Float:originDown[3]
	originDown = origin
	originDown[2] = -5000.0
	fm_trace_line(0, origin, originDown, hitPoint)
	new Float:DistanceFromGround = vector_distance(origin, hitPoint)

	new Float:difference = 36.0 - DistanceFromGround
	if(difference < -1 * 10.0 || difference > 10.0) return false
	new teleout = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "func_breakable"))
	if(!teleout) return false
	
	fm_set_kvd(teleout, "health", "10000", "func_breakable")
	fm_set_kvd(teleout, "material", "6", "func_breakable")
	fm_DispatchSpawn(teleout)

	set_pev(teleout, pev_classname, Teleout_ClassName)
	engfunc(EngFunc_SetModel, teleout, Mdl_teleporter)
	engfunc(EngFunc_SetSize, teleout, {-16.0, -16.0, 0.0}, {16.0, 16.0, 12.0})
	engfunc(EngFunc_SetOrigin, teleout, origin)
	pev(id, pev_v_angle, origin)
	origin[0] = 0.0
	origin[1] += 180.0
	origin[2] = 0.0
	set_pev(teleout, pev_angles, origin)
	set_pev(teleout, pev_solid, SOLID_SLIDEBOX)
	set_pev(teleout, pev_movetype, MOVETYPE_TOSS)
	set_pev(teleout, BUILD_OWNER, id)
	g_teleout[id] = teleout
	g_teleout_building[id] = true
	g_teleout_strength[id] = 1
	g_haveteleout[id] = true
	g_engineer_metal[id] -= get_pcvar_num(cvar_teleout_cost)
	return true
}
public ck_teleout_completed(id) {
	if(!is_user_alive(id)) return
	if(g_class[id] != CLASS_ENGINEER || !g_haveteleout[id]) return
	if(!(g_havetelein[id] && !g_telein_building[id])) {
		gtele_upgrade[id] = 0
		gtele_level[id] = 1
	}
	g_tele_reload[id] = 100
	g_teleout_building[id] = false
	g_teleout_strength[id] = get_pcvar_num(cvar_teleout_strength[0])
	if(pev_valid(g_teleout[id]) && g_havetelein[id] && !g_telein_building[id]) {
		set_pev(g_teleout[id], pev_framerate, float(gtele_level[id]))
		set_pev(g_teleout[id], pev_sequence, 1)
	}
	set_pev(g_teleout[id], pev_nextthink, get_gametime() + TELEOUT_THINK)
}

public ck_teleout_destory(id, reset) {
	new class[24]
	if(pev_valid(g_teleout[id])) {
		pev(g_teleout[id], pev_classname, class, 23)
		if(equal(class, Teleout_ClassName)) {
			FX_Demolish(g_teleout[id])
			set_pev(g_teleout[id], pev_flags, pev(g_teleout[id], pev_flags) | FL_KILLME)
		}
	}
	g_haveteleout[id] = false
	g_teleout_building[id] = false
	g_teleout_percent[id] = 0
	g_teleout_strength[id] = 0
	g_teleout[id] = 0
	if(!g_havetelein[id] || reset) {
		gtele_upgrade[id] = 0
		gtele_level[id] = 0
	}
	g_tele_reload[id] = 0
	g_tele_stand[id] = 0
	g_tele_timer[id] = 0.0
}

public fw_Think_Teleout(teleout) {
	if(!pev_valid(teleout)) return
	static id ; id = pev(teleout, BUILD_OWNER)

	set_pev(teleout, pev_framerate, float(g_tele_reload[id]) * float(gtele_level[id]) / 100.0)
	if(g_havetelein[id] && !g_telein_building[id]) set_pev(teleout, pev_sequence, 1)
	else set_pev(teleout, pev_sequence, 0)

	set_pev(teleout, pev_nextthink, get_gametime() + TELEOUT_THINK)
}

stock ck_tele_player(id, player) {
	if(!is_user_alive(player)) return
	if(!g_havetelein[id] || !g_haveteleout[id] || g_tele_reload[id] < 100) return

	new Float:out_origin[3]
	pev(g_teleout[id], pev_origin, out_origin)
	out_origin[2] += 77.0
	if(!is_hull_vacant(out_origin, HULL_HUMAN)) {
		new outplayer
		new Float:teleout_origin[3]
		pev(g_teleout[id], pev_origin, teleout_origin)
		while((outplayer = engfunc(EngFunc_FindEntityInSphere, outplayer, teleout_origin, 16.0))) {
			if(!(0 < outplayer <= global_get(glb_maxClients)))
				continue
			if(!is_user_alive(outplayer))
				continue
			if(!(pev(outplayer, pev_flags) & FL_ONGROUND))
				continue
			new Float:new_origin[3]
			xs_vec_copy(out_origin, new_origin)
			new_origin[0] += 33.0
			if(is_hull_vacant(new_origin, HULL_HUMAN)) {
				set_pev(outplayer, pev_origin, new_origin)
				return
			}
			new_origin[0] -= 66.0
			if(is_hull_vacant(new_origin, HULL_HUMAN)) {
				set_pev(outplayer, pev_origin, new_origin)
				return
			}
			new_origin[0] += 33.0
			new_origin[1] += 33.0
			if(is_hull_vacant(new_origin, HULL_HUMAN)) {
				set_pev(outplayer, pev_origin, new_origin)
				return
			}
			new_origin[1] -= 66.0
			if(is_hull_vacant(new_origin, HULL_HUMAN)) {
				set_pev(outplayer, pev_origin, new_origin)
				return
			}
			new_origin[1] += 33.0
			new_origin[2] += 73.0
			if(is_hull_vacant(new_origin, HULL_HUMAN)) {
				set_pev(outplayer, pev_origin, new_origin)
				return
			}
		}
		return
	}
	set_pev(player, pev_origin, out_origin)

	message_begin(MSG_ONE, g_msgScreenFade, {0, 0, 0}, player)
	write_short(1<<10) // Duration
	write_short(1<<10) // Hold time
	write_short(1<<12) // Fade type
	write_byte (200)  // Red
	write_byte (200)  // Green
	write_byte (200)  // Blue
	write_byte (255)  // Alpha
	message_end()

	g_tele_reload[id] = 0
	g_tele_stand[id] = 0
	g_tele_timer[id] = 0.0
	g_stats[STATS_TELEPORT][id]++
}

stock bool:ck_give_telein_health(id, percent) { 
	if(percent <= 0)
		return false
	new maxhealth
	switch(gtele_level[id]) {
		case 1:maxhealth = get_pcvar_num(cvar_telein_strength[0])
		case 2:maxhealth = get_pcvar_num(cvar_telein_strength[1])
		case 3:maxhealth = get_pcvar_num(cvar_telein_strength[2])
	}
	new givehealth = maxhealth * percent / 100
	if(givehealth < 1)
		givehealth = 1
	new needmetal
	if(g_telein_strength[id] >= maxhealth) {
		return false
	} else if(g_telein_strength[id]+givehealth > maxhealth && g_telein_strength[id] < maxhealth) {
		needmetal = (maxhealth - g_telein_strength[id]) * 100 / maxhealth
		if(needmetal < 1)
			needmetal = 1
		if(g_engineer_metal[id] >= needmetal) {
			g_telein_strength[id] = maxhealth
			g_engineer_metal[id] -= needmetal
			ck_showhud_status(id)
			return true
		} else if(g_engineer_metal[id] < needmetal && g_engineer_metal[id] > 0) {
			g_telein_strength[id] += g_engineer_metal[id] * maxhealth / 100
			g_engineer_metal[id] = 0
			ck_showhud_status(id)
			return true
		} else {
			return false
		}
	} else if(g_telein_strength[id]+givehealth <= maxhealth) {
		needmetal = givehealth * 100 / maxhealth
		if(needmetal < 1)
			needmetal = 1
		if(g_engineer_metal[id] >= needmetal) {
			g_telein_strength[id] += givehealth
			g_engineer_metal[id] -= needmetal
			ck_showhud_status(id)
			return true
		} else if(g_engineer_metal[id] < needmetal && g_engineer_metal[id] > 0) {
			g_telein_strength[id] += g_engineer_metal[id] * maxhealth / 100
			g_engineer_metal[id] = 0
			ck_showhud_status(id)
			return true
		} else {
			return false
		}
	}
	return false
}
stock bool:ck_give_teleout_health(id, percent) { 
	if(percent <= 0)
		return false
	new maxhealth
	switch(gtele_level[id]) {
		case 1:maxhealth = get_pcvar_num(cvar_teleout_strength[0])
		case 2:maxhealth = get_pcvar_num(cvar_teleout_strength[1])
		case 3:maxhealth = get_pcvar_num(cvar_teleout_strength[2])
	}
	new givehealth = maxhealth * percent / 100
	if(givehealth < 1)
		givehealth = 1
	new needmetal
	if(g_teleout_strength[id] >= maxhealth) {
		return false
	} else if(g_teleout_strength[id]+givehealth > maxhealth && g_teleout_strength[id] < maxhealth) {
		needmetal = (maxhealth - g_teleout_strength[id]) * 100 / maxhealth
		if(needmetal < 1)
			needmetal = 1
		if(g_engineer_metal[id] >= needmetal) {
			g_teleout_strength[id] = maxhealth
			g_engineer_metal[id] -= needmetal
			ck_showhud_status(id)
			return true
		} else if(g_engineer_metal[id] < needmetal && g_engineer_metal[id] > 0) {
			g_teleout_strength[id] += g_engineer_metal[id] * maxhealth / 100
			g_engineer_metal[id] = 0
			ck_showhud_status(id)
			return true
		} else {
			return false
		}
	} else if(g_teleout_strength[id]+givehealth <= maxhealth) {
		needmetal = givehealth * 100 / maxhealth
		if(needmetal < 1)
			needmetal = 1
		if(g_engineer_metal[id] >= needmetal) {
			g_teleout_strength[id] += givehealth
			g_engineer_metal[id] -= needmetal
			ck_showhud_status(id)
			return true
		} else if(g_engineer_metal[id] < needmetal && g_engineer_metal[id] > 0) {
			g_teleout_strength[id] += g_engineer_metal[id] * maxhealth / 100
			g_engineer_metal[id] = 0
			ck_showhud_status(id)
			return true
		} else {
			return false
		}
	}
	return false
}
stock bool:ck_give_tele_reload(id, percent) { 
	if(percent <= 0)
		return false
	new givereload = percent
	if(givereload < 1)
		givereload = 1
	if(g_tele_reload[id] >= 100) {
		return false
	} else if(g_tele_reload[id] + givereload > 100 && g_tele_reload[id] < 100) {
		g_tele_reload[id] = 100
		ck_showhud_status(id)
		return true
	} else if(g_tele_reload[id] + givereload <= 100) {
		g_tele_reload[id] += givereload
		ck_showhud_status(id)
		return true
	}
	return false
}
stock ck_give_tele_upgrade(id, percent) {
	if(percent <= 0) return
	new maxupgrade
	switch(gtele_level[id]) {
		case 1:maxupgrade = get_pcvar_num(cvar_tele_cost[0])
		case 2:maxupgrade = get_pcvar_num(cvar_tele_cost[1])
	}
	new giveupgrade = percent
	new needmetal
	if(gtele_upgrade[id]+giveupgrade > maxupgrade && gtele_upgrade[id] < maxupgrade) {
		needmetal = maxupgrade - gtele_upgrade[id]
		if(needmetal < 1)
			needmetal = 1
		if(g_engineer_metal[id] >= needmetal) {
			gtele_upgrade[id] = maxupgrade
			g_engineer_metal[id] -= needmetal
			ck_showhud_status(id)
		} else if(g_engineer_metal[id] < needmetal && g_engineer_metal[id] > 0) {
			gtele_upgrade[id] += g_engineer_metal[id]
			g_engineer_metal[id] = 0
			ck_showhud_status(id)
		}
	} else if(gtele_upgrade[id]+giveupgrade <= maxupgrade) {
		needmetal = giveupgrade
		if(needmetal < 1)
			needmetal = 1
		if(g_engineer_metal[id] >= needmetal) {
			gtele_upgrade[id] += giveupgrade
			g_engineer_metal[id] -= needmetal
			ck_showhud_status(id)
		} else if(g_engineer_metal[id] < needmetal && g_engineer_metal[id] > 0) {
			gtele_upgrade[id] += g_engineer_metal[id]
			g_engineer_metal[id] = 0
			ck_showhud_status(id)
		}
	}
	if(gtele_upgrade[id] >= maxupgrade)
		ck_tele_upgrade(id)
	return; 
}

stock bool:ck_give_telein_health_help(id, helper, percent) { 
	if(percent <= 0)
		return false
	new maxhealth
	switch(gtele_level[id]) {
		case 1:maxhealth = get_pcvar_num(cvar_telein_strength[0])
		case 2:maxhealth = get_pcvar_num(cvar_telein_strength[1])
		case 3:maxhealth = get_pcvar_num(cvar_telein_strength[2])
	}
	new givehealth = maxhealth * percent / 100
	if(givehealth < 1)
		givehealth = 1
	new needmetal
	if(g_telein_strength[id] >= maxhealth) {
		return false
	} else if(g_telein_strength[id]+givehealth > maxhealth && g_telein_strength[id] < maxhealth) {
		needmetal = (maxhealth - g_telein_strength[id]) * 100 / maxhealth
		if(needmetal < 1)
			needmetal = 1
		if(g_engineer_metal[helper] >= needmetal) {
			g_telein_strength[id] = maxhealth
			g_engineer_metal[helper] -= needmetal
			ck_showhud_status(id)
			return true
		} else if(g_engineer_metal[helper] < needmetal && g_engineer_metal[helper] > 0) {
			g_telein_strength[id] += g_engineer_metal[helper] * maxhealth / 100
			g_engineer_metal[helper] = 0
			ck_showhud_status(id)
			return true
		} else {
			return false
		}
	} else if(g_telein_strength[id]+givehealth <= maxhealth) {
		needmetal = givehealth * 100 / maxhealth
		if(needmetal < 1)
			needmetal = 1
		if(g_engineer_metal[helper] >= needmetal) {
			g_telein_strength[id] += givehealth
			g_engineer_metal[helper] -= needmetal
			ck_showhud_status(id)
			return true
		} else if(g_engineer_metal[helper] < needmetal && g_engineer_metal[helper] > 0) {
			g_telein_strength[id] += g_engineer_metal[helper] * maxhealth / 100
			g_engineer_metal[helper] = 0
			ck_showhud_status(id)
			return true
		} else {
			return false
		}
	}
	return false
}
stock bool:ck_give_teleout_health_help(id, helper, percent) { 
	if(percent <= 0)
		return false
	new maxhealth
	switch(gtele_level[id]) {
		case 1:maxhealth = get_pcvar_num(cvar_teleout_strength[0])
		case 2:maxhealth = get_pcvar_num(cvar_teleout_strength[1])
		case 3:maxhealth = get_pcvar_num(cvar_teleout_strength[2])
	}
	new givehealth = maxhealth * percent / 100
	if(givehealth < 1)
		givehealth = 1
	new needmetal
	if(g_teleout_strength[id] >= maxhealth) {
		return false
	} else if(g_teleout_strength[id]+givehealth > maxhealth && g_teleout_strength[id] < maxhealth) {
		needmetal = (maxhealth - g_teleout_strength[id]) * 100 / maxhealth
		if(needmetal < 1)
			needmetal = 1
		if(g_engineer_metal[helper] >= needmetal) {
			g_teleout_strength[id] = maxhealth
			g_engineer_metal[helper] -= needmetal
			ck_showhud_status(id)
			return true
		} else if(g_engineer_metal[helper] < needmetal && g_engineer_metal[helper] > 0) {
			g_teleout_strength[id] += g_engineer_metal[helper] * maxhealth / 100
			g_engineer_metal[helper] = 0
			ck_showhud_status(id)
			return true
		} else {
			return false
		}
	} else if(g_teleout_strength[id]+givehealth <= maxhealth) {
		needmetal = givehealth * 100 / maxhealth
		if(needmetal < 1)
			needmetal = 1
		if(g_engineer_metal[helper] >= needmetal) {
			g_teleout_strength[id] += givehealth
			g_engineer_metal[helper] -= needmetal
			ck_showhud_status(id)
			return true
		} else if(g_engineer_metal[helper] < needmetal && g_engineer_metal[helper] > 0) {
			g_teleout_strength[id] += g_engineer_metal[helper] * maxhealth / 100
			g_engineer_metal[helper] = 0
			ck_showhud_status(id)
			return true
		} else {
			return false
		}
	}
	return false
}
stock bool:ck_give_tele_reload_help(id, percent) { 
	if(percent <= 0)
		return false
	new givereload = percent
	if(givereload < 1)
		givereload = 1
	if(g_tele_reload[id] >= 100) {
		return false
	} else if(g_tele_reload[id] + givereload > 100 && g_tele_reload[id] < 100) {
		g_tele_reload[id] = 100
		ck_showhud_status(id)
		return true
	} else if(g_tele_reload[id] + givereload <= 100) {
		g_tele_reload[id] += givereload
		ck_showhud_status(id)
		return true
	}
	return false
}
stock ck_give_tele_upgrade_help(id, helper, percent) {
	if(percent <= 0)
		return ; 
	new maxupgrade
	switch(gtele_level[id]) {
		case 1:maxupgrade = get_pcvar_num(cvar_tele_cost[0])
		case 2:maxupgrade = get_pcvar_num(cvar_tele_cost[1])
	}
	new giveupgrade = percent
	new needmetal
	if(gtele_upgrade[id]+giveupgrade > maxupgrade && gtele_upgrade[id] < maxupgrade) {
		needmetal = maxupgrade - gtele_upgrade[id]
		if(needmetal < 1)
			needmetal = 1
		if(g_engineer_metal[helper] >= needmetal) {
			gtele_upgrade[id] = maxupgrade
			g_engineer_metal[helper] -= needmetal
			ck_showhud_status(id)
		} else if(g_engineer_metal[helper] < needmetal && g_engineer_metal[helper] > 0) {
			gtele_upgrade[id] += g_engineer_metal[helper]
			g_engineer_metal[helper] = 0
			ck_showhud_status(id)
		}
	} else if(gtele_upgrade[id]+giveupgrade <= maxupgrade) {
		needmetal = giveupgrade
		if(needmetal < 1)
			needmetal = 1
		if(g_engineer_metal[helper] >= needmetal) {
			gtele_upgrade[id] += giveupgrade
			g_engineer_metal[helper] -= needmetal
			ck_showhud_status(id)
		} else if(g_engineer_metal[helper] < needmetal && g_engineer_metal[helper] > 0) {
			gtele_upgrade[id] += g_engineer_metal[helper]
			g_engineer_metal[helper] = 0
			ck_showhud_status(id)
		}
	}
	if(gtele_upgrade[id] >= maxupgrade)
		ck_tele_upgrade(id)
	return; 
}

stock ck_tele_upgrade(id) {
	new telein = g_telein[id]
	new teleout = g_teleout[id]
	if(!pev_valid(telein) && !pev_valid(teleout))
		return; 
	switch(gtele_level[id]) {
		case 1: {
			g_telein_strength[id] = get_pcvar_num(cvar_telein_strength[1])
			g_teleout_strength[id] = get_pcvar_num(cvar_teleout_strength[1])
			gtele_level[id]++
			gtele_upgrade[id] = 0
		}
		case 2: {
			g_telein_strength[id] = get_pcvar_num(cvar_telein_strength[2])
			g_teleout_strength[id] = get_pcvar_num(cvar_teleout_strength[2])
			gtele_level[id]++
			gtele_upgrade[id] = 0
		}
	}
	return; 
}

stock ck_get_startpos(id, Float:forw, Float:right, Float:up, Float:vStart[]) {
	new Float:vOrigin[3], Float:vAngle[3], Float:vForward[3], Float:vRight[3], Float:vUp[3]

	pev(id, pev_origin, vOrigin)
	pev(id, pev_angles, vAngle)

	engfunc(EngFunc_MakeVectors, vAngle)

	global_get(glb_v_forward, vForward)
	global_get(glb_v_right, vRight)
	global_get(glb_v_up, vUp)

	vStart[0] = vOrigin[0] + vForward[0] * forw + vRight[0] * right + vUp[0] * up
	vStart[1] = vOrigin[1] + vForward[1] * forw + vRight[1] * right + vUp[1] * up
	vStart[2] = vOrigin[2] + vForward[2] * forw + vRight[2] * right + vUp[2] * up

	return 5
}

stock ck_get_user_startpos(id, Float:forw, Float:right, Float:up, Float:vStart[]) {
	new Float:vOrigin[3], Float:vAngle[3], Float:vForward[3], Float:vRight[3], Float:vUp[3]

	pev(id, pev_origin, vOrigin)
	pev(id, pev_v_angle, vAngle)

	engfunc(EngFunc_MakeVectors, vAngle)

	global_get(glb_v_forward, vForward)
	global_get(glb_v_right, vRight)
	global_get(glb_v_up, vUp)

	vStart[0] = vOrigin[0] + vForward[0] * forw + vRight[0] * right + vUp[0] * up
	vStart[1] = vOrigin[1] + vForward[1] * forw + vRight[1] * right + vUp[1] * up
	vStart[2] = vOrigin[2] + vForward[2] * forw + vRight[2] * right + vUp[2] * up

	return 5
}

stock str_count(const str[], searchchar) {
	static count, i
	count = 0
	for (i = 0; i <= strlen(str); i++) {
		if(str[i] == searchchar)
			count++
	}
	return count
}

public ck_fakedamage_build(id, enemy, damage, wpn, build) {
	if(!(1 <= id <= MaxClients) || damage <= 0) return; 
	if(g_round != round_normal) return; 
	new health
	switch(build) {
		case 1: {
			if(!g_havesentry[id]) return; 
			health = g_sentry_strength[id]
			if(health <= 0) return; 
			if(health - damage > 0) {
				g_sentry_strength[id] -= damage
			} else {
				ck_sentry_destory(id)
				ck_fakekill_msg(id + DEATHMSG_SENTRY, enemy, g_wpn_name[wpn])
			}
		}
		case 2: {
			if(!g_havedispenser[id]) return; 
			health = g_dispenser_strength[id]
			if(health <= 0) return; 
			if(health - damage > 0) {
				g_dispenser_strength[id] -= damage
			} else {
				ck_dispenser_destory(id)
				ck_fakekill_msg(id + DEATHMSG_DISPENSER, enemy, g_wpn_name[wpn])
			}
		}
		case 3: {
			if(!g_havetelein[id]) return; 
			health = g_telein_strength[id]
			if(health <= 0) return; 
			if(health - damage > 0) {
				g_telein_strength[id] -= damage
			} else {
				ck_telein_destory(id, 0)
				ck_fakekill_msg(id + DEATHMSG_TELEIN, enemy, g_wpn_name[wpn])
			}
		}
		case 4: {
			if(!g_haveteleout[id]) return; 
			health = g_teleout_strength[id]
			if(health <= 0) return; 
			if(health - damage > 0) {
				g_teleout_strength[id] -= damage
			} else {
				ck_teleout_destory(id, 0)
				ck_fakekill_msg(id + DEATHMSG_TELEOUT, enemy, g_wpn_name[wpn])
			}
		}
	}
}

stock ck_get_weapon_name(weapon, wpname[], len) {
	format(wpname, len, "%s", g_wpn_name[weapon])
	return
}
// old
// stock ck_fakedamage(id, enemy, wpn, dmg, gib, crit) {
	
stock ck_fakedamage(id, enemy, wpn, dmg, gib, crit) {
	if(!is_user_alive(id) || !is_user_alive(enemy) || dmg <= 0) return
	if(g_nodamage[id]) return
	if(g_charge_shield[g_healed_by[id]] && ck_get_user_assistance(id) > 0) return
	if(g_charge_shield[id]) return
	if(isSameTeam(id, enemy)) return
	new health = get_user_health(id)
	new wpname[32]

	if(id == enemy || !(1 <= enemy <= MaxClients)) {
		if(health - dmg > 0) {
			fm_set_user_health(id, health - dmg)
			if(random_num(1, 10) <= get_pcvar_num(cvar_global_blood))
				FX_BloodDecal(id)
			if(random_num(1, 10) <= get_pcvar_num(cvar_global_blood))
				FX_Blood(id, 1)
		} else {
			ck_get_weapon_name(wpn, wpname, charsmax(wpname))
			ck_fakekill_msg(id, id, wpname)
			//if(gib)	FX_Gibs(id)
			ExecuteHamB(Ham_Killed, id, enemy, 0)
		}
		return
	}
	if(health - dmg > 0) {
		fm_set_user_health(id, health - dmg)
		if(random_num(1, 10) <= get_pcvar_num(cvar_global_blood))
			FX_BloodDecal(id)
		if(random_num(1, 10) <= get_pcvar_num(cvar_global_blood)) {
			if(dmg >= 100)
				FX_Blood(id, 3)
			else if(dmg >= 33 && dmg < 100)
				FX_Blood(id, 2)
			else if(dmg >= 0 && dmg < 33)
				FX_Blood(id, 1)
		}
	} else {
		//if(gib) FX_Gibs(id)
		if(crit) g_critkilled[id] = 1
		ExecuteHamB(Ham_Killed, id, enemy, 0)
		ck_get_weapon_name(wpn, wpname, charsmax(wpname))
		ck_fakekill_msg(id, enemy, wpname)
	}
	if(!is_user_alive(g_lastatk[0][id]) || isSameTeam(enemy, g_lastatk[0][id])) {
		g_lastatk[0][id] = enemy
	} else if(!is_user_alive(g_lastatk[1][id]) || isSameTeam(enemy, g_lastatk[1][id])) {
		g_lastatk[1][id] = enemy
	} else if(g_lastatk[0][id] != enemy && g_lastatk[1][id] != enemy) {
		g_lastatk[1][id] = enemy
	} else if(g_lastatk[0][id] != enemy && g_lastatk[1][id] == enemy) {
		g_lastatk[1][id] = g_lastatk[0][id]
		g_lastatk[0][id] = enemy
	}
}

public fw_TraceAttack_Pushable(ent, attacker, Float:damage, Float:direction[3]) {
	if(!(1 <= attacker <= MaxClients)) return;
	static Float:velocity[3]
	pev(ent, pev_velocity, velocity)
	xs_vec_mul_scalar(direction, damage, direction)
	xs_vec_add(velocity, direction, direction)
	direction[2] = velocity[2]
	set_pev(ent, pev_velocity, direction)
}
public fw_Touch_Pushable(ptd, ptr) {
	if(!pev_valid(ptr))
		return HAM_IGNORED
	return HAM_SUPERCEDE
}
public fw_TraceLine_Post(Float:start[3], Float:end[3], noMonsters, id, trace) {
	if(!(1 <= id <= MaxClients))
		return FMRES_IGNORED
	if(!is_user_alive(id))
		return FMRES_IGNORED
	if(is_user_bot(id))
		return FMRES_IGNORED
	new target = get_tr(TR_pHit)
	if(!pev_valid(target)) {
		g_aiming[id] = 0
		g_aiming_at_building[id] = 0
		return FMRES_IGNORED
	}
	new classname[32]
	pev(target, pev_classname, classname, 31)
	g_aiming_at_building[id] = 0
	g_aiming[id] = 0
	if(equal(classname, SentryBase_ClassName) || equal(classname, SentryTurret_ClassName)) {
		g_aiming[id] = pev(target, BUILD_OWNER)
		g_aiming_at_building[id] = 1
	} else if(equal(classname, Dispenser_ClassName)) {
		g_aiming[id] = pev(target, BUILD_OWNER)
		g_aiming_at_building[id] = 2
	} else if(equal(classname, Telein_ClassName)) {
		g_aiming[id] = pev(target, BUILD_OWNER)
		g_aiming_at_building[id] = 3
	} else if(equal(classname, Teleout_ClassName)) {
		g_aiming[id] = pev(target, BUILD_OWNER)
		g_aiming_at_building[id] = 4
	} else if(equal(classname, "player")) {
		if(is_user_alive(target)) {
			g_aiming[id] = target
			g_aiming_at_building[id] = 0
		}
	}
	return FMRES_IGNORED
}

public fw_EmitSound(id, channel, const sample[], Float:volume, Float:attn, flags, pitch)
{
	if(!(1 <= id <= MaxClients))
		return FMRES_IGNORED

	if(sample[8] != 'k' || sample[9] != 'n' || sample[10] != 'i' || sample[14] == 'd' || sample[14] != 'h' || sample[15] != 'i' || sample[16] != 't')
		return FMRES_IGNORED

	switch(g_class[id]) {
		case CLASS_SCOUT: {
			if(sample[17] == 'w') engfunc(EngFunc_EmitSound, id, CHAN_STATIC, Snd_Knifes[KNIFE_BAT][g_critical_on[id] ? KnifeCritical : KnifeWall], volume, attn, flags, pitch)
			else engfunc(EngFunc_EmitSound, id, channel, Snd_Knifes[KNIFE_BAT][g_critical_on[id] ? KnifeCritical : KnifeHit], volume, attn, flags, pitch)
			return FMRES_SUPERCEDE
		}
		case CLASS_SOLDIER: {
			if(sample[17] == 'w') engfunc(EngFunc_EmitSound, id, CHAN_STATIC, Snd_Knifes[KNIFE_SHOVEL][g_critical_on[id] ? KnifeCritical : KnifeWall], volume, attn, flags, pitch)
			else engfunc(EngFunc_EmitSound, id, channel, Snd_Knifes[KNIFE_SHOVEL][g_critical_on[id] ? KnifeCritical : KnifeHit], volume, attn, flags, pitch)
			return FMRES_SUPERCEDE
		}
		case CLASS_PYRO: {
			if(sample[17] == 'w') engfunc(EngFunc_EmitSound, id, CHAN_STATIC, Snd_Knifes[KNIFE_FIRE_AXE][g_critical_on[id] ? KnifeCritical : KnifeWall], volume, attn, flags, pitch)
			else engfunc(EngFunc_EmitSound, id, channel, Snd_Knifes[KNIFE_FIRE_AXE][g_critical_on[id] ? KnifeCritical : KnifeHit], volume, attn, flags, pitch)
			return FMRES_SUPERCEDE
		}
		case CLASS_DEMOMAN: {
			if(sample[17] == 'w') engfunc(EngFunc_EmitSound, id, CHAN_STATIC, Snd_Knifes[KNIFE_BOTTLE][g_critical_on[id] ? KnifeCritical : KnifeWall], volume, attn, flags, pitch)
			else engfunc(EngFunc_EmitSound, id, channel, Snd_Knifes[KNIFE_BOTTLE][g_critical_on[id] ? KnifeCritical : KnifeHit], volume, attn, flags, pitch)
			return FMRES_SUPERCEDE
		}
		case CLASS_HEAVY: {
			if(sample[17] == 'w') engfunc(EngFunc_EmitSound, id, CHAN_STATIC, Snd_Knifes[KNIFE_FIST][g_critical_on[id] ? KnifeCritical : KnifeWall], volume, attn, flags, pitch)
			else engfunc(EngFunc_EmitSound, id, channel, Snd_Knifes[KNIFE_FIST][g_critical_on[id] ? KnifeCritical : KnifeHit], volume, attn, flags, pitch)
			return FMRES_SUPERCEDE
		}
		case CLASS_ENGINEER: {
			if(sample[17] == 'w') engfunc(EngFunc_EmitSound, id, CHAN_STATIC, Snd_Knifes[KNIFE_WRENCH][g_critical_on[id] ? KnifeCritical : KnifeWall], volume, attn, flags, pitch)
			else engfunc(EngFunc_EmitSound, id, channel, Snd_Knifes[KNIFE_WRENCH][g_critical_on[id] ? KnifeCritical : KnifeHit], volume, attn, flags, pitch)
			return FMRES_SUPERCEDE
		}
		case CLASS_MEDIC: {
			if(sample[17] == 'w') engfunc(EngFunc_EmitSound, id, CHAN_STATIC, Snd_Knifes[KNIFE_BONESAW][g_critical_on[id] ? KnifeCritical : KnifeWall], volume, attn, flags, pitch)
			else engfunc(EngFunc_EmitSound, id, channel, Snd_Knifes[KNIFE_BONESAW][g_critical_on[id] ? KnifeCritical : KnifeHit], volume, attn, flags, pitch)
			return FMRES_SUPERCEDE
		}
		case CLASS_SNIPER: {
			if(sample[17] == 'w') engfunc(EngFunc_EmitSound, id, CHAN_STATIC, Snd_Knifes[KNIFE_KNIFE][g_critical_on[id] ? KnifeCritical : KnifeWall], volume, attn, flags, pitch)
			else engfunc(EngFunc_EmitSound, id, channel, Snd_Knifes[KNIFE_KNIFE][g_critical_on[id] ? KnifeCritical : KnifeHit], volume, attn, flags, pitch)
			return FMRES_SUPERCEDE
		}
		case CLASS_SPY: {
			if(sample[17] == 'w') engfunc(EngFunc_EmitSound, id, CHAN_STATIC, Snd_Knifes[KNIFE_KNIFE][g_critical_on[id] ? KnifeCritical : KnifeWall], volume, attn, flags, pitch)
			else engfunc(EngFunc_EmitSound, id, channel, Snd_Knifes[KNIFE_KNIFE][g_critical_on[id] ? KnifeCritical : KnifeHit], volume, attn, flags, pitch)
			return FMRES_SUPERCEDE
		}
	}
	return FMRES_IGNORED
}

public fw_GameDesc()
{
	forward_return(FMV_STRING, g_modname)
	return FMRES_SUPERCEDE
}

public fw_ClientKill(id) {
	if(!is_user_alive(id))
		return FMRES_IGNORED
	client_print_color(id, print_team_default, "^4%L ^1%L", id, "MSG_TITLE", id, "MSG_NOSUICIDE")
	return FMRES_SUPERCEDE
}

public fw_SetClientKeyValue(id, const infobuffer[], const key[]) {
	if(key[0] == 'm' && key[1] == 'o' && key[2] == 'd' && key[3] == 'e' && key[4] == 'l') return FMRES_SUPERCEDE;
	return FMRES_IGNORED;
}

public fw_ClientUserInfoChanged(id) {
	if(!is_user_connected(id) || !g_curmodel[id][0])
		return FMRES_IGNORED

	static model[32]; 
	fm_get_user_model(id, model, charsmax(model))

	if(equal(model, g_curmodel[id])) 
		return FMRES_IGNORED; 
	
	//rg_set_user_model(id, g_curmodel[id], true)
	cs_set_user_model(id, g_curmodel[id])
	set_entvar(id, var_skin, (rg_get_user_team(id) == TEAM_TERRORIST) ? TF2_RED : TF2_BLUE)
	return FMRES_IGNORED;
}

public fw_UpdateClientData_Post(id, sendweapons, cd_handle) {
	if(!is_user_alive(id))
		return FMRES_IGNORED; 
	if(g_noweapon[id]) {
		set_cd(cd_handle, CD_ID, 0)
		return FMRES_HANDLED; 
	}
	static Float:time, WeaponIdType:wpn, Float:rof
	time = get_gametime()
	wpn = rg_get_user_active_weapon(id)
	switch(wpn) {
		case WEAPON_AWP: {
			rof = get_pcvar_float(cvar_awp_rof)
			if(rof <= 0.0) return FMRES_IGNORED; 
			if(g_nextfire[id] + rof <= time) {
				g_blockfire[id] = 1
				set_cd(cd_handle, CD_flNextAttack, time + 0.001)
			} else {
				g_blockfire[id] = 0
				g_nextfire[id] = time
			}
		}
		case WEAPON_KNIFE: {
			new Float:rof
			switch(g_class[id]) {
				case CLASS_MEDIC: rof = get_pcvar_float(cvar_amerk_rof)
				case CLASS_ENGINEER: rof = get_pcvar_float(cvar_hammer_rof)
				default: rof = get_pcvar_float(cvar_knife_rof)
			}
			if(rof <= 0.0) return FMRES_IGNORED; 
			if(g_nextfire[id] + rof <= time) {
				g_blockfire[id] = 1
				set_cd(cd_handle, CD_flNextAttack, time + 0.001)
			} else {
				g_blockfire[id] = 0
				g_nextfire[id] = time
			}
		}
		case WEAPON_M3, WEAPON_P228: {
			set_cd(cd_handle, CD_flNextAttack, time + 0.01)
			return FMRES_HANDLED; 
		}
	}
	return FMRES_IGNORED; 
}

public fw_AddToFullPack_Post(es_handle, e, ent, host, hostflags, player, pSet) {
	if(!pev_valid(ent)) 
		return FMRES_IGNORED

	static SameTeam, owner, renderamt; 
	owner = pev(ent, BUILD_OWNER)
	SameTeam = isSameTeam(host, owner)
	if(g_telein_building[owner] || SameTeam)
		return FMRES_IGNORED

	renderamt = floatround(-2.55*float(g_tele_reload[owner])+255.0)
	if(renderamt > 255) renderamt = 255

	if(g_havetelein[owner] && FClassnameIs(ent, Telein_ClassName) || g_haveteleout[owner] && FClassnameIs(ent, Teleout_ClassName)) {
		set_es(es_handle, ES_RenderMode, kRenderTransTexture)
		if(renderamt < get_pcvar_num(cvar_tele_trans[gtele_level[owner]-1])) 
			renderamt = get_pcvar_num(cvar_tele_trans[gtele_level[owner]-1])

		set_es(es_handle, ES_RenderAmt, renderamt)
		return FMRES_IGNORED
	}
	
	if(!player)
		return FMRES_IGNORED

	return FMRES_IGNORED
}

public clcmd_spawn(id) {
	if(is_user_alive(id)) {
		client_print_color(id, print_team_default, "^4%L ^1%L", id, "MSG_TITLE", id, "MSG_SPAWN_ALIVE")
		return PLUGIN_HANDLED
	}
	if(g_join_spawned[id]) {
		client_print_color(id, print_team_default, "^4%L ^1%L", id, "MSG_TITLE", id, "MSG_SPAWN_ONCE")
		return PLUGIN_HANDLED
	}
	if(g_round == round_end) {
		client_print_color(id, print_team_default, "^4%L ^1%L", id, "MSG_TITLE", id, "MSG_SPAWN_CANT")
		return PLUGIN_HANDLED
	}

	static TeamName:userTeam; 
	userTeam = rg_get_user_team(id)
	if(userTeam != TEAM_TERRORIST && userTeam != TEAM_CT) 
		return PLUGIN_HANDLED

	g_join_spawned[id] = 1
	set_task(0.1, "task_respawn", id+TASK_RESPAWN)
	client_print_color(id, print_team_default, "^4%L ^1%L", id, "MSG_TITLE", id, "MSG_SPAWN_SUCCESS")
	return PLUGIN_HANDLED
}

public clcmd_changeteam(id) {
	if(!is_user_connected(id))
		return PLUGIN_CONTINUE
	if(rg_get_user_team(id) == TEAM_SPECTATOR || rg_get_user_team(id) == TEAM_UNASSIGNED)
		return PLUGIN_CONTINUE
	show_menu_main(id)
	return PLUGIN_HANDLED
}

public task_hidemoney(taskid) {
	static id
	if(taskid > MaxClients)
		id = taskid - TASK_HIDEMONEY
	else
		id = taskid
	if(is_user_alive(id)) return; 

	message_begin(MSG_ONE, g_msgHideWeapon, _, id)
	write_byte(HIDE_MONEY)
	message_end()

	fm_set_user_money(id, 0)
	set_task(10.0, "task_hidemoney", id+TASK_HIDEMONEY)
}

public plugin_init() {
	g_hudcenter = CreateHudSyncObj()
	g_hudsync = CreateHudSyncObj()
	g_hudbuild = CreateHudSyncObj()
	g_hudtimer = CreateHudSyncObj()

	g_msgTeamInfo = get_user_msgid("TeamInfo")
	g_msgScoreInfo = get_user_msgid("ScoreInfo")
	g_msgRoundTime = get_user_msgid("RoundTime")
	g_msgHideWeapon = get_user_msgid("HideWeapon")
	g_msgTeamScore = get_user_msgid("TeamScore")
	g_msgScreenFade = get_user_msgid("ScreenFade")
	g_msgSayText = get_user_msgid("SayText")
	g_msgCurWeapon = get_user_msgid("CurWeapon")
	g_msgAmmoPickup = get_user_msgid("AmmoPickup")

	register_clcmd("say !menu", "show_menu_main")
	register_clcmd("say_team !menu", "show_menu_main")
	register_clcmd("say !class", "show_menu_class")
	register_clcmd("say_team !class", "show_menu_class")
	register_clcmd("say !spawn", "clcmd_spawn")
	register_clcmd("say_team !spawn", "clcmd_spawn")
	register_clcmd("say !stats", "show_menu_stats")
	register_clcmd("say_team !stats", "show_menu_stats")
	register_clcmd("say !team", "show_menu_team")
	register_clcmd("say_team !team", "show_menu_team")

	register_clcmd("buy", "clcmd_block")
	register_clcmd("drop", "clcmd_block")
	register_clcmd("chooseteam", "clcmd_changeteam")
	register_clcmd("jointeam", "clcmd_changeteam")

	register_menu("Main Menu", KEYSMENU, "menu_main")
	register_menu("Team Menu", KEYSMENU, "menu_team")
	register_menu("Stats Menu", KEYSMENU, "menu_stats")
	register_menu("Build Menu", KEYSMENU, "menu_build")
	register_menu("Demolish Menu", KEYSMENU, "menu_demolish")

	register_message(get_user_msgid("Health"), "message_health")
	register_message(get_user_msgid("TextMsg"), "message_textmsg")
	register_message(get_user_msgid("StatusValue"), "message_status")
	register_message(get_user_msgid("StatusText"), "message_status")
	register_message(get_user_msgid("Money"), "message_money")
	register_message(get_user_msgid("HostagePos"), "message_hostagepos")
	register_message(get_user_msgid("ClCorpse"), "message_corpse")
	register_message(get_user_msgid("DeathMsg"), "message_deathmsg")
	register_message(get_user_msgid("WeapPickup"), "message_weappickup")

	register_message(g_msgHideWeapon, "message_hideweapon")
	register_message(g_msgTeamInfo, "message_teaminfo")
	register_message(g_msgSayText, "message_saytext")
	register_message(g_msgCurWeapon, "message_curweapon")
	register_message(g_msgScoreInfo, "message_scoreinfo")
	register_message(g_msgAmmoPickup, "message_ammopickup")
	register_message(g_msgTeamScore, "message_teamscore")

	register_plugin("TF2: Main", "1.0", "hzqst | Perfect Scrash")

	register_event("DeathMsg", "event_playerdie", "a")
	register_event("Damage", "event_damage", "b", "2!0")
	register_event("HLTV", "event_round_start", "a", "1=0", "2=0")
	register_event("SetFOV", "event_SetFOV", "be")

	RegisterHam(Ham_Think, "grenade", "fw_Think_Projectile")
	RegisterHam(Ham_Touch, "grenade", "fw_Touch_Projectile")

	RegisterHam(Ham_TraceAttack, "player", "fw_TraceAttack")
	RegisterHam(Ham_TraceAttack, "func_breakable", "fw_TraceAttack_Building")
	RegisterHam(Ham_Think, "func_breakable", "fw_Think_Building")

	RegisterHookChain(RG_CBasePlayer_Spawn, "CBasePlayer_Spawn", .post = true)

	RegisterHam(Ham_Player_Jump, "player", "fw_Jump")

	RegisterHam(Ham_Item_Deploy, "weapon_m3", "fw_WeaponDraw_m3", 1)
	RegisterHam(Ham_Item_Deploy, "weapon_p228", "fw_WeaponDraw_p228", 1)
	RegisterHam(Ham_Item_Deploy, "weapon_c4", "fw_WeaponDraw_c4", 1)
	RegisterHam(Ham_Item_Deploy, "weapon_knife", "fw_WeaponDraw_knife", 1)
	RegisterHam(Ham_Item_Deploy, "weapon_awp", "fw_WeaponDraw_awp", 1)

	RegisterHookChain(RG_CBasePlayerWeapon_DefaultReload, "CBasePlayerWeapon_DefaultReload", true)

	RegisterHam(Ham_Item_Holster, "weapon_m3", "fw_WeaponHolster_M3", 1)
	RegisterHam(Ham_Item_Holster, "weapon_p228", "fw_WeaponHolster_P228", 1)
	RegisterHam(Ham_Item_Holster, "weapon_awp", "fw_WeaponHolster_AWP", 1)
	
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_awp", "fw_WeaponFire_AWP")
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_c4", "fw_WeaponFire_C4")
	
	//RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_p228", "fw_WeaponFire_P228")

	RegisterHam(Ham_Item_PostFrame, "weapon_awp", "fw_ItemPostFrame_AWP")
	RegisterHam(Ham_Item_PostFrame, "weapon_p228", "fw_ItemPostFrame_P228")
	RegisterHam(Ham_Item_AttachToPlayer, "weapon_awp", "fw_ItemAttachToPlayer_AWP")
	RegisterHam(Ham_Item_AttachToPlayer, "weapon_p228", "fw_ItemAttachToPlayer_P228")

	RegisterHam(Ham_TraceAttack, "func_pushable", "fw_TraceAttack_Pushable")
	RegisterHam(Ham_Touch, "func_pushable", "fw_Touch_Pushable")
	RegisterHam(Ham_Use, "func_pushable", "fw_Block")

	RegisterHam(Ham_Item_Deploy, "weapon_knife", "Ham_Knife_Deploy", true)
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_knife", "Ham_Knife_PrimaryAttack_Post", true)

	register_forward(FM_GetGameDescription, "fw_GameDesc")
	register_forward(FM_TraceLine, "fw_TraceLine_Post", 1)
	register_forward(FM_SetClientKeyValue, "fw_SetClientKeyValue")
	register_forward(FM_ClientUserInfoChanged, "fw_ClientUserInfoChanged")
	register_forward(FM_UpdateClientData, "fw_UpdateClientData_Post", 1)
	register_forward(FM_AddToFullPack, "fw_AddToFullPack_Post", 1)
	register_forward(FM_EmitSound, "fw_EmitSound")
	register_forward(FM_PlayerPreThink, "fw_PreThink")
	register_forward(FM_CmdStart, "fw_CmdStart")
	register_forward(FM_ClientKill, "fw_ClientKill")
	unregister_forward(FM_Spawn, g_fwEntitySpawn)
	unregister_forward(FM_KeyValue, g_fwKeyValue)
	register_logevent("event_round_end", 2, "1=Round_End")
	
	register_dictionary("team_fortress_mod.txt")

	init_CollectSpawns("info_player_start")
	init_CollectSpawns("info_player_deathmatch")
	set_task(10.0, "refresh_message")
	set_task(1.0, "round_timer", TASK_ROUND_TIMER)
	set_task(TIMER_REFRESH, "ck_showhud_timer")
	
	for(new i = 0; i < MAX_CLASS; i++) {
		strtolower(ClassConfig[i][ClassName])
		cvar_class_hp[i] = register_cvar(fmt("tfm_%s_health", ClassConfig[i][ClassName]), fmt("%d", ClassConfig[i][Default_Health]))
		cvar_class_speed[i] = register_cvar(fmt("tfm_%s_speed", ClassConfig[i][ClassName]), fmt("%.0f", ClassConfig[i][Default_Speed]))
	}

	cvar_scattergun_mindmg = register_cvar("tfm_scattergun_mindmg", "16")
	cvar_scattergun_maxdmg = register_cvar("tfm_scattergun_maxdmg", "18")
	cvar_scattergun_burst = register_cvar("tfm_scattergun_burst", "6")
	cvar_scattergun_scatter = register_cvar("tfm_scattergun_scatter", "300.0")
	cvar_scattergun_clip = register_cvar("tfm_scattergun_clip", "6")
	cvar_scattergun_ammo = register_cvar("tfm_scattergun_ammo", "32")
	cvar_scattergun_rof = register_cvar("tfm_scattergun_rof", "0.6")
	cvar_scattergun_reload = register_cvar("tfm_scattergun_reload", "0.6")
	cvar_scattergun_force = register_cvar("tfm_scattergun_force", "6.0")
	cvar_scattergun_draw = register_cvar("tfm_scattergun_draw", "1.0")

	cvar_shotgun_mindmg = register_cvar("tfm_shotgun_mindmg", "12")
	cvar_shotgun_maxdmg = register_cvar("tfm_shotgun_maxdmg", "14")
	cvar_shotgun_burst = register_cvar("tfm_shotgun_burst", "6")
	cvar_shotgun_scatter = register_cvar("tfm_shotgun_scatter", "300.0")
	cvar_shotgun_clip = register_cvar("tfm_shotgun_clip", "6")
	cvar_shotgun_ammo = register_cvar("tfm_shotgun_ammo", "32")
	cvar_shotgun_rof = register_cvar("tfm_shotgun_rof", "0.6")
	cvar_shotgun_reload = register_cvar("tfm_shotgun_reload", "0.6")
	cvar_shotgun_force = register_cvar("tfm_shotgun_force", "3.0")
	cvar_shotgun_draw = register_cvar("tfm_shotgun_draw", "1.0")

	cvar_minigun_mindmg = register_cvar("tfm_minigun_mindmg", "10")
	cvar_minigun_maxdmg = register_cvar("tfm_minigun_maxdmg", "20")
	cvar_minigun_burst = register_cvar("tfm_minigun_burst", "4")
	cvar_minigun_scatter = register_cvar("tfm_minigun_scatter", "300.0")
	cvar_minigun_clip = register_cvar("tfm_minigun_clip", "200")
	cvar_minigun_rof = register_cvar("tfm_minigun_rof", "0.1")
	cvar_minigun_force = register_cvar("tfm_minigun_force", "6.0")
	cvar_minigun_draw = register_cvar("tfm_minigun_draw", "1.2")
	cvar_minigun_spinup = register_cvar("tfm_minigun_spinup", "0.5")
	cvar_minigun_spindown = register_cvar("tfm_minigun_spindown", "0.5")
	cvar_minigun_spining = register_cvar("tfm_minigun_spining", "0.6")
	//cvar_minigun_slowdown = register_cvar("tfm_minigun_slowndown", "0.5")

	cvar_rocket_dmg = register_cvar("tfm_rocket_dmg", "120")
	cvar_rocket_mindmg = register_cvar("tfm_rocket_mindmg", "52")
	cvar_rocket_maxdmg = register_cvar("tfm_rocket_maxdmg", "112")
	cvar_rocket_radius = register_cvar("tfm_rocket_radius", "96.0")
	cvar_rocket_clip = register_cvar("tfm_rocket_clip", "4")
	cvar_rocket_ammo = register_cvar("tfm_rocket_ammo", "16")
	cvar_rocket_rof = register_cvar("tfm_rocket_rof", "0.8")
	cvar_rocket_reload = register_cvar("tfm_rocket_reload", "1.0")
	cvar_rocket_force = register_cvar("tfm_rocket_force", "600.0")
	cvar_rocket_multidmg = register_cvar("tfm_rocket_multidmg", "0.5")
	cvar_rocket_velocity = register_cvar("tfm_rocket_velocity", "800")
	cvar_rocket_draw = register_cvar("tfm_rocket_draw", "1.0")

	cvar_awp_mindmg = register_cvar("tfm_awp_mindmg", "44")
	cvar_awp_maxdmg = register_cvar("tfm_awp_maxdmg", "66")
	cvar_awp_clip = register_cvar("tfm_awp_clip", "25")
	cvar_awp_ammo = register_cvar("tfm_awp_ammo", "0")
	cvar_awp_rof = register_cvar("tfm_awp_rof", "0.0")
	cvar_awp_headshot = register_cvar("tfm_awp_headshot", "2.0")
	cvar_awp_force = register_cvar("tfm_awp_force", "8.0")
	cvar_awp_chargedmg = register_cvar("tfm_awp_chargedmg", "1.0")
	cvar_awp_chargerate = register_cvar("tfm_awp_chargerate", "5.0")
	cvar_awp_slowdown = register_cvar("tfm_awp_slowdown", "0.5")

	cvar_medicgun_minheal = register_cvar("tfm_medicgun_minheal", "2")
	cvar_medicgun_maxheal = register_cvar("tfm_medicgun_maxheal", "4")
	cvar_medicgun_maxhealth = register_cvar("tfm_medicgun_maxhealth", "1.5")
	cvar_medicgun_rof = register_cvar("tfm_medicgun_rof", "0.1")
	cvar_medicgun_charge = register_cvar("tfm_medicgun_charge", "0.2")
	cvar_medicgun_range = register_cvar("tfm_medicgun_range", "325.0")

	cvar_syringegun_mindmg = register_cvar("tfm_syringegun_mindmg", "10")
	cvar_syringegun_maxdmg = register_cvar("tfm_syringegun_maxdmg", "15")
	cvar_syringegun_clip = register_cvar("tfm_syringegun_clip", "50")
	cvar_syringegun_ammo = register_cvar("tfm_syringegun_ammo", "150")
	cvar_syringegun_rof = register_cvar("tfm_syringegun_rof", "0.1")
	cvar_syringegun_reload = register_cvar("tfm_syringegun_reload", "1.5")
	cvar_syringegun_force = register_cvar("tfm_syringegun_force", "2.0")
	cvar_syringegun_velocity = register_cvar("tfm_syringegun_velocity", "1500")
	cvar_syringegun_draw = register_cvar("tfm_syringegun_draw", "0.9")
	cvar_syringegun_vampiric = register_cvar("tfm_syringegun_vampiric", "0.5")

	cvar_smg_mindmg = register_cvar("tfm_smg_mindmg", "12")
	cvar_smg_maxdmg = register_cvar("tfm_smg_maxdmg", "14")
	cvar_smg_scatter = register_cvar("tfm_smg_scatter", "100.0")
	cvar_smg_clip = register_cvar("tfm_smg_clip", "25")
	cvar_smg_ammo = register_cvar("tfm_smg_ammo", "75")
	cvar_smg_rof = register_cvar("tfm_smg_rof", "0.1")
	cvar_smg_reload = register_cvar("tfm_smg_reload", "1.35")
	cvar_smg_force = register_cvar("tfm_smg_force", "2.0")
	cvar_smg_draw = register_cvar("tfm_smg_draw", "1.2")

	cvar_usp_mindmg = register_cvar("tfm_usp_mindmg", "20")
	cvar_usp_maxdmg = register_cvar("tfm_usp_maxdmg", "22")
	cvar_usp_clip = register_cvar("tfm_usp_clip", "12")
	cvar_usp_ammo = register_cvar("tfm_usp_ammo", "36")
	cvar_usp_force = register_cvar("tfm_usp_force", "2.0")

	cvar_knife_mindmg = register_cvar("tfm_knife_mindmg", "43")
	cvar_knife_maxdmg = register_cvar("tfm_knife_maxdmg", "87")
	cvar_knife_rof = register_cvar("tfm_knife_rof", "0.0")
	cvar_knife_force = register_cvar("tfm_knife_force", "10.0")

	cvar_hammer_mindmg = register_cvar("tfm_hammer_mindmg", "43")
	cvar_hammer_maxdmg = register_cvar("tfm_hammer_maxdmg", "87")
	cvar_hammer_rof = register_cvar("tfm_hammer_rof", "0.0")
	cvar_hammer_force = register_cvar("tfm_hammer_force", "10.0")

	cvar_amerk_mindmg = register_cvar("tfm_amerk_mindmg", "37")
	cvar_amerk_maxdmg = register_cvar("tfm_amerk_maxdmg", "64")
	cvar_amerk_rof = register_cvar("tfm_amerk_rof", "0.0")
	cvar_amerk_force = register_cvar("tfm_amerk_force", "10.0")

	cvar_grenade_dmg = register_cvar("tfm_grenade_dmg", "150")
	cvar_grenade_mindmg = register_cvar("tfm_grenade_mindmg", "45")
	cvar_grenade_maxdmg = register_cvar("tfm_grenade_maxdmg", "132")
	cvar_grenade_radius = register_cvar("tfm_grenade_radius", "96.0")
	cvar_grenade_clip = register_cvar("tfm_grenade_clip", "4")
	cvar_grenade_ammo = register_cvar("tfm_grenade_ammo", "16")
	cvar_grenade_rof = register_cvar("tfm_grenade_rof", "0.6")
	cvar_grenade_reload = register_cvar("tfm_grenade_reload", "0.8")
	cvar_grenade_force = register_cvar("tfm_grenade_force", "400.0")
	cvar_grenade_draw = register_cvar("tfm_grenade_draw", "1.2")
	cvar_grenade_velocity = register_cvar("tfm_grenade_velocity", "1200")
	cvar_grenade_delay = register_cvar("tfm_grenade_delay", "3.0")

	cvar_stickybomb_dmg = register_cvar("tfm_stickybomb_dmg", "160")
	cvar_stickybomb_mindmg = register_cvar("tfm_stickybomb_mindmg", "56")
	cvar_stickybomb_maxdmg = register_cvar("tfm_stickybomb_maxdmg", "148")
	cvar_stickybomb_radius = register_cvar("tfm_stickybomb_radius", "128.0")
	cvar_stickybomb_clip = register_cvar("tfm_stickybomb_clip", "6")
	cvar_stickybomb_ammo = register_cvar("tfm_stickybomb_ammo", "24")
	cvar_stickybomb_rof = register_cvar("tfm_stickybomb_rof", "0.8")
	cvar_stickybomb_reload = register_cvar("tfm_stickybomb_reload", "0.8")
	cvar_stickybomb_force = register_cvar("tfm_stickybomb_force", "600.0")
	cvar_stickybomb_draw = register_cvar("tfm_stickybomb_draw", "1.2")
	cvar_stickybomb_velocity = register_cvar("tfm_stickybomb_velocity", "800")
	cvar_stickybomb_chargerate = register_cvar("tfm_stickybomb_chargerate", "5.0")
	cvar_stickybomb_chargevelo = register_cvar("tfm_stickybomb_chargevelo", "2.0")

	cvar_sentry_strength[0] = register_cvar("tfm_sentry_strength_lvl1", "150")
	cvar_sentry_strength[1] = register_cvar("tfm_sentry_strength_lvl2", "180")
	cvar_sentry_strength[2] = register_cvar("tfm_sentry_strength_lvl3", "216")
	cvar_sentry_ammo[0] = register_cvar("tfm_sentry_ammo_lvl1", "200")
	cvar_sentry_ammo[1] = register_cvar("tfm_sentry_ammo_lvl2", "300")
	cvar_sentry_ammo[2] = register_cvar("tfm_sentry_ammo_lvl3", "400")
	cvar_sentry_cost[0] = register_cvar("tfm_sentry_cost_lvl1", "130")
	cvar_sentry_cost[1] = register_cvar("tfm_sentry_cost_lvl2", "330")
	cvar_sentry_cost[2] = register_cvar("tfm_sentry_cost_lvl3", "530")
	cvar_sentry_mindmg[0] = register_cvar("tfm_sentry_mindmg_lvl1", "8")
	cvar_sentry_mindmg[1] = register_cvar("tfm_sentry_mindmg_lvl2", "10")
	cvar_sentry_mindmg[2] = register_cvar("tfm_sentry_mindmg_lvl3", "12")
	cvar_sentry_maxdmg[0] = register_cvar("tfm_sentry_maxdmg_lvl1", "12")
	cvar_sentry_maxdmg[1] = register_cvar("tfm_sentry_maxdmg_lvl2", "14")
	cvar_sentry_maxdmg[2] = register_cvar("tfm_sentry_maxdmg_lvl3", "16")
	cvar_sentry_radius[0] = register_cvar("tfm_sentry_radius_lvl1", "1200.0")
	cvar_sentry_radius[1] = register_cvar("tfm_sentry_radius_lvl2", "1400.0")
	cvar_sentry_radius[2] = register_cvar("tfm_sentry_radius_lvl3", "1600.0")
	cvar_sentry_rocket_cost = register_cvar("tfm_sentry_rocket_cost", "10")
	cvar_sentry_rocket_rof = register_cvar("tfm_sentry_rocket_rof", "4.0")
	cvar_sentry_rocket_dmg = register_cvar("tfm_sentry_rocket_dmg", "100")
	cvar_sentry_rocket_mindmg = register_cvar("tfm_sentry_rocket_mindmg", "48")
	cvar_sentry_rocket_maxdmg = register_cvar("tfm_sentry_rocket_maxdmg", "96")
	cvar_sentry_rocket_radius = register_cvar("tfm_sentry_rocket_radius", "96.0")
	cvar_sentry_rocket_velocity = register_cvar("tfm_sentry_rocket_velocity", "800")
	cvar_sentry_rocket_force = register_cvar("tfm_sentry_rocket_force", "12.0")
	cvar_sentry_force = register_cvar("tfm_sentry_force", "16.0")
	cvar_sentry_scatter = register_cvar("tfm_sentry_scatter", "16.0")

	cvar_dispenser_strength[0] = register_cvar("tfm_dispenser_strength_lvl1", "150")
	cvar_dispenser_strength[1] = register_cvar("tfm_dispenser_strength_lvl2", "200")
	cvar_dispenser_strength[2] = register_cvar("tfm_dispenser_strength_lvl3", "250")
	cvar_dispenser_ammo[0] = register_cvar("tfm_dispenser_ammo_lvl1", "100")
	cvar_dispenser_ammo[1] = register_cvar("tfm_dispenser_ammo_lvl2", "150")
	cvar_dispenser_ammo[2] = register_cvar("tfm_dispenser_ammo_lvl3", "200")
	cvar_dispenser_cost[0] = register_cvar("tfm_dispenser_cost_lvl1", "50")
	cvar_dispenser_cost[1] = register_cvar("tfm_dispenser_cost_lvl2", "100")
	cvar_dispenser_cost[2] = register_cvar("tfm_dispenser_cost_lvl3", "100")
	cvar_dispenser_radius[0] = register_cvar("tfm_dispenser_radius_lvl1", "64.0")
	cvar_dispenser_radius[1] = register_cvar("tfm_dispenser_radius_lvl2", "72.0")
	cvar_dispenser_radius[2] = register_cvar("tfm_dispenser_radius_lvl3", "96.0")
	cvar_dispenser_heal[0] = register_cvar("tfm_dispenser_heal_lvl1", "2")
	cvar_dispenser_heal[1] = register_cvar("tfm_dispenser_heal_lvl2", "3")
	cvar_dispenser_heal[2] = register_cvar("tfm_dispenser_heal_lvl3", "4")
	cvar_dispenser_rsp[0] = register_cvar("tfm_dispenser_respawn_lvl1", "5.0")
	cvar_dispenser_rsp[1] = register_cvar("tfm_dispenser_respawn_lvl2", "4.0")
	cvar_dispenser_rsp[2] = register_cvar("tfm_dispenser_respawn_lvl2", "3.0")
	cvar_dispenser_rescan = register_cvar("tfm_dispenser_rescan", "5.0")
	cvar_dispenser_supply = register_cvar("tfm_dispenser_supply", "10")

	cvar_telein_strength[0] = register_cvar("tfm_telein_strength_lvl1", "150")
	cvar_telein_strength[1] = register_cvar("tfm_telein_strength_lvl2", "200")
	cvar_telein_strength[2] = register_cvar("tfm_telein_strength_lvl2", "250")
	cvar_teleout_strength[0] = register_cvar("tfm_teleout_strength_lvl1", "125")
	cvar_teleout_strength[1] = register_cvar("tfm_teleout_strength_lvl2", "150")
	cvar_teleout_strength[2] = register_cvar("tfm_teleout_strength_lvl2", "175")
	cvar_telein_cost = register_cvar("tfm_telein_cost_lvl1", "60")
	cvar_teleout_cost = register_cvar("tfm_teleout_cost_lvl1", "60")
	cvar_tele_cost[0] = register_cvar("tfm_tele_cost_lvl2", "100")
	cvar_tele_cost[1] = register_cvar("tfm_tele_cost_lvl3", "100")
	cvar_tele_reload[0] = register_cvar("tfm_tele_reload_lvl1", "1")
	cvar_tele_reload[1] = register_cvar("tfm_tele_reload_lvl2", "2")
	cvar_tele_reload[2] = register_cvar("tfm_tele_reload_lvl3", "3")
	cvar_tele_trans[0] = register_cvar("tfm_tele_trans_lvl1", "255")
	cvar_tele_trans[1] = register_cvar("tfm_tele_trans_lvl2", "125")
	cvar_tele_trans[2] = register_cvar("tfm_tele_trans_lvl3", "10")

	cvar_global_gib_amount = register_cvar("tfm_global_gib_amount", "1")
	cvar_global_gib_time = register_cvar("tfm_global_gib_time", "10")
	cvar_global_blood = register_cvar("tfm_global_blood", "5")
	cvar_critical_dmg = register_cvar("tfm_critical_dmg", "2.0")
	cvar_critical_percent = register_cvar("tfm_critical_percent", "15")
	cvar_critical_tracered = register_cvar("tfm_critical_tracered", "1")
	cvar_critical_traceblue = register_cvar("tfm_critical_traceblue", "7")
	cvar_critical_tracelen = register_cvar("tfm_critical_tracelen", "12")
	cvar_critical_tracetime = register_cvar("tfm_critical_tracetime", "12")
	cvar_critical_tracevelo = register_cvar("tfm_critical_tracevelo", "3000.0")
	cvar_global_respawn = register_cvar("tfm_global_respawn", "5.0")

	cvar_roundtime_default = register_cvar("tfm_roundtime_default", "360")
	cvar_roundtime_capture = register_cvar("tfm_roundtime_capture", "1200")
	cvar_roundtime_ctflag = register_cvar("tfm_roundtime_ctflag", "1200")
	cvar_roundtime_payload = register_cvar("tfm_roundtime_payload", "1800")

	formatex(g_modname, charsmax(g_modname), "%L", LANG_PLAYER, "TFM_MODNAME")
	static mapname[32], cfgdir[32], linedata[64]
	get_configsdir(cfgdir, charsmax(cfgdir)); 
	get_mapname(mapname, charsmax(mapname)); 
	formatex(g_ItemFile, charsmax(g_ItemFile), "%s/chicken_fortress/%s_item.cfg", cfgdir, mapname); 
	if(file_exists(g_ItemFile)) {
		static parm[4], data[4][6], Float:time, file, i
		time = 0.2
		file = fopen(g_ItemFile, "rt")
		while (file && !feof(file)) {
			fgets(file, linedata, charsmax(linedata)); 
			if(!linedata[0] || str_count(linedata, ' ') < 2) continue; 
			parse(linedata, data[0], charsmax(data[]), data[1], charsmax(data[]), data[2], charsmax(data[]), data[3], charsmax(data[])); 
			for(i = 0; i < sizeof parm; i++) parm[i] = str_to_num(data[i]);
			set_task(time, "ck_create_item", 0, parm, 4)
			time += 0.2
		}
		if(file) fclose(file); 
	}
	if(equal(mapname[0], "cp_", 3)) {
		g_gamemode = mode_capture
	} else if(equal(mapname[0], "ctf_", 4)) {
		g_gamemode = mode_ctflag
	} else if(equal(mapname[0], "pl_", 3)) {
		g_gamemode = mode_payload
	} else {
		g_gamemode = mode_normal
	}

	format(g_mapname, charsmax(g_mapname), "%s", mapname)
	set_cvar_num("sv_skycolor_r", 0)
	set_cvar_num("sv_skycolor_g", 0)
	set_cvar_num("sv_skycolor_b", 0)
}

precache_player_model(const modelname[]) {
	static longname[128] , index
	formatex(longname, charsmax(longname), "models/player/%s/%s.mdl", modelname, modelname)  	
	index = engfunc(EngFunc_PrecacheModel, longname) 
	
	copy(longname[strlen(longname)-4], charsmax(longname) - (strlen(longname)-4), "T.mdl") 
	if(file_exists(longname)) engfunc(EngFunc_PrecacheModel, longname) 
	
	return index
}

stock UTIL_SetAnim(ent, anim, Float:framerate)
{
	if(!pev_valid(ent))
		return
	
	set_pev(ent, pev_animtime, get_gametime())
	set_pev(ent, pev_framerate, framerate)
	set_pev(ent, pev_sequence, anim)
}

stock WeaponIdType:rg_get_user_active_weapon(const player, &pWeapon = NULLENT) {
	return ((pWeapon = get_member(player, m_pActiveItem)) > 0) ? get_member(pWeapon, m_iId) : WEAPON_NONE
}