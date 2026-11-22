//Name: RePruning v0.0.4
//Author: DeRoPEN_DEv
//Platform: ReHLDS
//Mandatory: ReHLDS 3.15.0.896-dev + ReAPI v5.29.0.359-dev + Metamod-R 1.3.0.149 + AMXModX 1.10+ + ReGameDLL 5.30.0.814-dev
//Description: A plugin for removing, cleaning up, or disabling various features on CS 1.6 servers
//Reminder: Use 0 to disable the feature, and 1 to enable it
//Sites: github.com/DeRoPEN31 and deropen.fun

#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <reapi>

#define PLUGIN  "RePruning"
#define VERSION "v0.0.4"
#define AUTHOR  "DeRoPEN_DEv"

#define LOG_ERROR   1
#define LOG_INFO    2
#define LOG_DEBUG   3

#define CLASS_BUYZONE       "func_buyzone"
#define CLASS_BOMB_TARGET   "func_bomb_target"
#define CLASS_BOMB_TARGET2  "info_bomb_target"
#define CLASS_HOSTAGE       "hostage_entity"
#define CLASS_HOSTAGE_RESC  "func_hostage_rescue"
#define CLASS_VIP_ZONE      "func_vip_safetyzone"
#define CLASS_VIP_START     "info_vip_start"
#define CLASS_WEAPONBOX     "weaponbox"
#define CLASS_WEAPON_C4     "weapon_c4"
#define CLASS_GRENADE       "grenade"
#define CLASS_DEFUSER_DROP  "item_thighpack"

new g_pBuy, g_pBuyZoneRemove, g_pMoney, g_pPlantZone;
new g_pBombGive, g_pBombRemove, g_pIcons;
new g_pRadio, g_pRadioWinSounds;
new g_pHostages, g_pVip;
new g_pEffects, g_pDecals;
new g_pCorpses, g_pDropWeapons;
new g_pConsole, g_pHints;
new g_pFiles, g_pFilesKick;
new g_pFilesFix, g_pFilesMaxFails, g_pFilesBanTime;
new g_pBans, g_pBansTTL, g_pBansCleanup, g_pBansMax, g_pIds;
new g_pLogLevel;

new g_szLogPath[128];
new g_iErrCount;
new g_iClientsConnected;
new g_iRounds;
new g_iFileChecks;
new g_iMismatchTotal, g_iKickTotal, g_iBanTotal;
new g_iStartSystime;
new Trie:g_tMismatch;

new Trie:g_tLang;
new Trie:g_tBanMem;
new g_iLangCount, g_iLangKeys;
new g_iBanMemHits;
new g_iBanExpired, g_iBanInvalid;
new g_pLang;
new g_szBanMemPath[128];
new g_hFwdFlagged, g_hFwdBanned, g_hFwdUnbanned, g_iFwdRet;

new g_iMsgMoney, g_iMsgStatusIcon, g_iMsgSendAudio;
new g_iMsgTextMsg, g_iMsgClCorpse;
new g_iMsgHudText, g_iMsgHudTextPro, g_iMsgHudTextArgs;

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR);

    register_cvar("repruning_version", VERSION, FCVAR_SERVER | FCVAR_SPONLY);

    g_pBuy            = register_cvar("pruning_buy",             "1");
    g_pBuyZoneRemove  = register_cvar("pruning_buyzone_remove",  "1");
    g_pMoney          = register_cvar("pruning_money",           "1");
    g_pPlantZone      = register_cvar("pruning_plantzone",       "1");
    g_pBombGive       = register_cvar("pruning_bomb_give",       "1");
    g_pBombRemove     = register_cvar("pruning_bomb_remove",     "1");
    g_pIcons          = register_cvar("pruning_icons",           "1");
    g_pRadio          = register_cvar("pruning_radio",           "1");
    g_pRadioWinSounds = register_cvar("pruning_radio_winsounds", "1");
    g_pHostages       = register_cvar("pruning_hostages",        "1");
    g_pVip            = register_cvar("pruning_vip",             "1");
    g_pEffects        = register_cvar("pruning_effects",         "1");
    g_pDecals         = register_cvar("pruning_decals",          "1");
    g_pCorpses        = register_cvar("pruning_corpses",         "1");
    g_pDropWeapons    = register_cvar("pruning_dropweapons",     "1");
    g_pConsole        = register_cvar("pruning_console",         "1");
    g_pHints          = register_cvar("pruning_hints",           "1");
    g_pFiles          = register_cvar("pruning_files",           "0");
    g_pFilesKick      = register_cvar("pruning_files_kick",      "1");
    g_pFilesFix       = register_cvar("pruning_files_fix",       "1");
    g_pFilesMaxFails  = register_cvar("pruning_files_maxfails",  "3");
    g_pFilesBanTime   = register_cvar("pruning_files_bantime",   "30");
    g_pBans           = register_cvar("pruning_bans",            "1");
    g_pBansTTL        = register_cvar("pruning_bans_ttl",        "720");
    g_pBansCleanup    = register_cvar("pruning_bans_cleanup",    "1");
    g_pBansMax        = register_cvar("pruning_bans_max",        "500");
    g_pIds            = register_cvar("pruning_ids",             "1");
    g_pLogLevel       = register_cvar("pruning_log_level",       "2");
    g_pLang           = register_cvar("pruning_lang",            "us");

    static const szBuyCmds[][] = {
        "buy", "buyequip",
        "glock", "usp", "p228", "deagle", "elite", "fn57",
        "m3", "xm1014", "mac10", "tmp", "mp5navy", "ump45", "p90",
        "galil", "famas", "ak47", "m4a1", "sg552", "aug",
        "scout", "sg550", "g3sg1", "awp", "m249",
        "vest", "vesthelm", "flash", "hegren", "sgren",
        "defuser", "nvgs", "shield",
        "primammo", "secammo", "buyammo1", "buyammo2",
        "cl_autobuy", "cl_setautobuy", "cl_autorebuy", "cl_setrebuy"
    };
    for (new i = 0; i < sizeof(szBuyCmds); i++)
        register_clcmd(szBuyCmds[i], "ClCmd_Buy");

    register_clcmd("radio1", "ClCmd_Radio");
    register_clcmd("radio2", "ClCmd_Radio");
    register_clcmd("radio3", "ClCmd_Radio");

    RegisterHookChain(RG_CBasePlayer_HasRestrictItem, "OnHasRestrictItem_Pre", false);
    RegisterHookChain(RG_CBasePlayer_MakeBomber,      "OnMakeBomber_Pre",     false);
    RegisterHookChain(RG_CBasePlayer_MakeVIP,         "OnMakeVIP_Pre",        false);
    RegisterHookChain(RG_CBasePlayer_Radio,           "OnRadio_Pre",          false);
    RegisterHookChain(RG_BuyItem,                     "OnBuyItem_Pre",        false);
    RegisterHookChain(RG_BuyWeaponByWeaponID,         "OnBuyWeapon_Pre",      false);
    RegisterHookChain(RG_BuyGunAmmo,                  "OnBuyGunAmmo_Pre",     false);

    RegisterHookChain(RG_CBasePlayer_Spawn,           "OnPlayerSpawn_Post",   true);
    RegisterHookChain(RG_CBasePlayer_Killed,          "OnPlayerKilled_Post",  true);
    RegisterHookChain(RG_CBasePlayer_DropPlayerItem,  "OnPlayerDropItem_Post", true);
    RegisterHookChain(RG_CSGameRules_RestartRound,    "OnRestartRound_Post",  true);
    RegisterHookChain(RG_CSGameRules_CleanUpMap,      "OnCleanUpMap_Post",    true);

    g_iMsgMoney        = get_user_msgid("Money");
    g_iMsgStatusIcon   = get_user_msgid("StatusIcon");
    g_iMsgSendAudio    = get_user_msgid("SendAudio");
    g_iMsgTextMsg      = get_user_msgid("TextMsg");
    g_iMsgClCorpse     = get_user_msgid("ClCorpse");
    g_iMsgHudText      = get_user_msgid("HudText");
    g_iMsgHudTextPro   = get_user_msgid("HudTextPro");
    g_iMsgHudTextArgs  = get_user_msgid("HudTextArgs");

    if (g_iMsgMoney)      register_message(g_iMsgMoney,      "Message_Money");
    if (g_iMsgStatusIcon) register_message(g_iMsgStatusIcon, "Message_StatusIcon");
    if (g_iMsgSendAudio)  register_message(g_iMsgSendAudio,  "Message_SendAudio");

    register_message(SVC_TEMPENTITY, "Message_TempEntity");
    if (g_iMsgTextMsg)     register_message(g_iMsgTextMsg,     "Message_TextMsg");
    if (g_iMsgClCorpse)    register_message(g_iMsgClCorpse,    "Message_ClCorpse");
    if (g_iMsgHudText)     register_message(g_iMsgHudText,     "Message_HudText");
    if (g_iMsgHudTextPro)  register_message(g_iMsgHudTextPro,  "Message_HudText");
    if (g_iMsgHudTextArgs) register_message(g_iMsgHudTextArgs, "Message_HudText");

    register_concmd("amx_pruning_reload", "ConCmd_Reload", ADMIN_CFG, " - reload pruning.cfg, pruning_baning.cfg, languages and ban list");
    register_clcmd("pruninginfo", "ClCmd_PlayerInfo", 0, " - what is removed on this server and your file-check status");
    register_clcmd("pruningid", "ClCmd_MyId", 0, " - show your own identifier");
    register_concmd("pruning_ids", "ConCmd_Ids", ADMIN_BAN, " - identifier table of connected players");

    hook_cvar_change(g_pFiles, "OnFilesToggle");

    g_tMismatch = TrieCreate();
    g_tLang = TrieCreate();
    g_tBanMem = TrieCreate();

    g_hFwdFlagged  = CreateMultiForward("repruning_player_flagged",  ET_IGNORE, FP_CELL, FP_STRING);
    g_hFwdBanned   = CreateMultiForward("repruning_player_banned",   ET_IGNORE, FP_CELL, FP_STRING, FP_CELL);
    g_hFwdUnbanned = CreateMultiForward("repruning_player_unbanned", ET_IGNORE, FP_STRING);
}

public plugin_natives()
{
    // Runs at LOAD time — before the next plugin in plugins.ini is checked against its
    // #pragma reqlib. Registered in plugin_init() it would fire only after every plugin is
    // already loaded, and any plugin using the API would fail with
    // 'Module/Library "repruning" required for plugin. Check modules.ini.'
    register_library("repruning");

    register_native("repruning_is_flagged", "Native_IsFlagged");
    register_native("repruning_get_mismatches", "Native_GetMismatches");
    register_native("repruning_is_banned", "Native_IsBanned");
    register_native("repruning_add_ban", "Native_AddBan");
    register_native("repruning_remove_ban", "Native_RemoveBan");
    register_native("repruning_get_identifier", "Native_GetIdentifier");
    register_native("repruning_server_info", "Native_ServerInfo");
    register_native("repruning_server_data", "Native_ServerData");
    register_native("repruning_get_ban_expiry", "Native_GetBanExpiry");
    register_native("repruning_get_ban_count", "Native_GetBanCount");
    register_native("repruning_get_stat", "Native_GetStat");
}

public plugin_cfg()
{

    new szLogsDir[96], szFmt[192], szMsg[224];
    get_localinfo("amxx_logsdir", szLogsDir, charsmax(szLogsDir));
    formatex(g_szLogPath, charsmax(g_szLogPath), "%s/RePruning.log", szLogsDir);
    g_iStartSystime = get_systime();

    new szCfgDir[96], szCfgFile[128];
    get_localinfo("amxx_configsdir", szCfgDir, charsmax(szCfgDir));

    ExecConfig(szCfgDir, szCfgFile, charsmax(szCfgFile), "pruning.cfg");
    ExecConfig(szCfgDir, szCfgFile, charsmax(szCfgFile), "pruning_baning.cfg");
    ValidateBaningCvars();

    if (get_pcvar_num(g_pFiles))
        FilesLoudWarning("startup");

    PerformCleanup();
    ApplyFileChecks();
    OnDropCleanup();
    LoadLanguages();
    LoadBanList();

    if (get_pcvar_num(g_pBansCleanup))
        set_task(3600.0, "Task_BanCleanup", _, _, _, "b");

    Lang("INIT_1", szMsg, charsmax(szMsg));
    server_print("[RePruning] %s", szMsg);
    Lang("INIT_2", szMsg, charsmax(szMsg));
    server_print("[RePruning] %s", szMsg);
    Lang("INIT_3", szFmt, charsmax(szFmt));
    formatex(szMsg, charsmax(szMsg), szFmt, VERSION);
    server_print("[RePruning] %s", szMsg);
    server_print("[RePruning] API: 7 natives + 3 forwards registered — include <repruning.inc> (library repruning)");

    new szMap[48];
    get_mapname(szMap, charsmax(szMap));
    Pruning_Log(LOG_INFO, "===== RePruning v%s | map %s | log level %d | file checks %d | languages %d | ban list %d =====",
        VERSION, szMap, get_pcvar_num(g_pLogLevel), g_iFileChecks, g_iLangCount, TrieGetSize(g_tBanMem));
    Pruning_Log(LOG_INFO, "api: 7 natives + 3 forwards registered (library repruning, source/repruning.inc)");
}

ExecConfig(const szDir[], szBuf[], iLen, const szName[])
{
    formatex(szBuf, iLen, "%s/%s", szDir, szName);

    if (file_exists(szBuf)) {
        server_cmd("exec %s", szBuf);
        server_exec();
        return 1;
    }

    Pruning_Log(LOG_ERROR, "configs/%s not found — default values are used", szName);
    return 0;
}

ValidateBaningCvars()
{
    new iVal = get_pcvar_num(g_pFilesMaxFails);
    if (iVal < 0 || iVal > 100) {
        set_pcvar_num(g_pFilesMaxFails, (iVal < 0) ? 0 : 100);
        Pruning_Log(LOG_ERROR, "validation: pruning_files_maxfails %d out of range 0..100 — clamped", iVal);
    }

    iVal = get_pcvar_num(g_pFilesBanTime);
    if (iVal < 0) {
        set_pcvar_num(g_pFilesBanTime, 0);
        Pruning_Log(LOG_ERROR, "validation: pruning_files_bantime %d is negative — set to 0", iVal);
    }

    iVal = get_pcvar_num(g_pBansTTL);
    if (iVal < 0 || iVal > 87600) {
        set_pcvar_num(g_pBansTTL, (iVal < 0) ? 0 : 87600);
        Pruning_Log(LOG_ERROR, "validation: pruning_bans_ttl %d out of range 0..87600 hours — clamped", iVal);
    }

    iVal = get_pcvar_num(g_pBansMax);
    if (iVal < 1 || iVal > 10000) {
        set_pcvar_num(g_pBansMax, (iVal < 1) ? 1 : 10000);
        Pruning_Log(LOG_ERROR, "validation: pruning_bans_max %d out of range 1..10000 — clamped", iVal);
    }
}

public OnFilesToggle(const iPcvar, const szOldValue[], const szNewValue[])
{
    if (str_to_num(szNewValue) != 0)
        FilesLoudWarning("cvar change");
}

FilesLoudWarning(const szWhen[])
{
    server_print("===============================================================");
    server_print("[RePruning] WARNING: file checks ENABLED (%s)", szWhen);
    server_print("[RePruning] pruning_files is 1 — client files are compared with reference files");
    server_print("[RePruning] Reference files must exist on THIS server (configs/pruning_files.cfg)");
    server_print("[RePruning] A wrong entry can kick EVERY player — verify before use");
    server_print("===============================================================");
    Pruning_Log(LOG_ERROR, "FILE CHECKS ENABLED (%s) — pruning_files 1, %d checks active, verify configs/pruning_files.cfg",
        szWhen, g_iFileChecks);
}

public ClCmd_Buy(id)
{
    return get_pcvar_num(g_pBuy) ? PLUGIN_HANDLED : PLUGIN_CONTINUE;
}

public OnBuyItem_Pre(const id, iSlot)
{
    if (get_pcvar_num(g_pBuy))
        return HC_SUPERCEDE;
    return HC_CONTINUE;
}

public OnBuyWeapon_Pre(const id, WeaponIdType:weaponID)
{
    if (get_pcvar_num(g_pBuy)) {
        SetHookChainReturn(ATYPE_CLASSPTR, 0);
        return HC_SUPERCEDE;
    }
    return HC_CONTINUE;
}

public OnBuyGunAmmo_Pre(const id, const weaponEnt, const bool:blinkMoney)
{
    if (get_pcvar_num(g_pBuy)) {
        SetHookChainReturn(ATYPE_BOOL, false);
        return HC_SUPERCEDE;
    }
    return HC_CONTINUE;
}

public OnPlayerSpawn_Post(const id)
{
    if (!is_user_connected(id) || !is_user_alive(id))
        return HC_CONTINUE;

    new TeamName:iTeam = get_member(id, m_iTeam);
    if (iTeam != TEAM_TERRORIST && iTeam != TEAM_CT)
        return HC_CONTINUE;

    if (pev(id, pev_iuser1) != 0)
        return HC_CONTINUE;

    if (get_pcvar_num(g_pMoney)) {
        set_member(id, m_iAccount, 0);
        set_member(id, m_iHideHUD, get_member(id, m_iHideHUD) | HIDEHUD_MONEY);
    }

    return HC_CONTINUE;
}

public Message_Money(iMsgId, iDest, iEnt)
{
    if (get_pcvar_num(g_pMoney))
        return PLUGIN_HANDLED;
    return PLUGIN_CONTINUE;
}

public OnHasRestrictItem_Pre(const id, ItemID:item, ItemRestType:type)
{
    if (get_pcvar_num(g_pBombGive) && item == ITEM_C4) {
        SetHookChainReturn(ATYPE_BOOL, true);
        return HC_SUPERCEDE;
    }
    return HC_CONTINUE;
}

public OnMakeBomber_Pre(const id)
{
    if (get_pcvar_num(g_pBombGive)) {
        SetHookChainReturn(ATYPE_BOOL, false);
        return HC_SUPERCEDE;
    }
    return HC_CONTINUE;
}

public OnRadio_Pre(const id, const szMsgId[], const szVerbose[], pitch, const bool:showIcon)
{
    if (get_pcvar_num(g_pRadio))
        return HC_SUPERCEDE;
    return HC_CONTINUE;
}

public ClCmd_Radio(id)
{
    return get_pcvar_num(g_pRadio) ? PLUGIN_HANDLED : PLUGIN_CONTINUE;
}

public Message_SendAudio(iMsgId, iDest, iEnt)
{
    new szSample[64];
    get_msg_arg_string(1, szSample, charsmax(szSample));

    if (szSample[0] != '!')
        return PLUGIN_CONTINUE;

    if (IsRoundWinSound(szSample))
        return get_pcvar_num(g_pRadioWinSounds) ? PLUGIN_CONTINUE : PLUGIN_HANDLED;

    if (get_pcvar_num(g_pRadio))
        return PLUGIN_HANDLED;

    return PLUGIN_CONTINUE;
}

IsRoundWinSound(const szSample[])
{
    if (equal(szSample, "!MRAD_terwin") || equal(szSample, "!MRAD_ctwin"))
        return true;
    if (equal(szSample, "!MRAD_rounddraw"))
        return true;
    return false;
}

public Message_StatusIcon(iMsgId, iDest, iEnt)
{
    if (get_pcvar_num(g_pIcons))
        return PLUGIN_HANDLED;
    return PLUGIN_CONTINUE;
}

public OnMakeVIP_Pre(const id)
{
    if (get_pcvar_num(g_pVip))
        return HC_SUPERCEDE;
    return HC_CONTINUE;
}

public OnRestartRound_Post()
{
    g_iRounds++;
    PerformCleanup();
    OnDropCleanup();

    set_task(1.0, "Task_DelayedClean");
}

public OnCleanUpMap_Post()
{

    PerformCleanup();
}

public Task_DelayedClean()
{
    PerformCleanup();
}

PerformCleanup()
{
    if (get_pcvar_num(g_pBuyZoneRemove))
        RemoveEntitiesByClass(CLASS_BUYZONE);

    if (get_pcvar_num(g_pPlantZone)) {
        RemoveEntitiesByClass(CLASS_BOMB_TARGET);
        RemoveEntitiesByClass(CLASS_BOMB_TARGET2);
    }

    if (get_pcvar_num(g_pHostages)) {
        RemoveEntitiesByClass(CLASS_HOSTAGE);
        RemoveEntitiesByClass(CLASS_HOSTAGE_RESC);
    }

    if (get_pcvar_num(g_pVip)) {

        set_member_game(m_bMapHasVIPSafetyZone, 0);
        RemoveEntitiesByClass(CLASS_VIP_ZONE);
        RemoveEntitiesByClass(CLASS_VIP_START);
    }

    if (get_pcvar_num(g_pBombRemove)) {
        RemoveCarriedC4();
        RemoveBombEntities();
    }
}

RemoveCarriedC4()
{
    new ent = find_ent_by_class(-1, CLASS_WEAPON_C4);

    while (ent > 0) {
        new next = find_ent_by_class(ent, CLASS_WEAPON_C4);
        new owner = pev(ent, pev_owner);

        if (owner >= 1 && owner <= get_maxplayers() && is_user_connected(owner))
            set_member(owner, m_bHasC4, false);

        engfunc(EngFunc_RemoveEntity, ent);
        ent = next;
    }
}

RemoveEntitiesByClass(const szClassname[])
{
    new ent = find_ent_by_class(-1, szClassname);

    while (ent > 0) {
        new next = find_ent_by_class(ent, szClassname);
        engfunc(EngFunc_RemoveEntity, ent);
        ent = next;
    }
}

RemoveBombEntities()
{
    new model[64], ent, next;

    ent = find_ent_by_class(-1, CLASS_WEAPONBOX);
    while (ent > 0) {
        next = find_ent_by_class(ent, CLASS_WEAPONBOX);
        pev(ent, pev_model, model, charsmax(model));
        if (containi(model, "w_backpack") != -1)
            engfunc(EngFunc_RemoveEntity, ent);
        ent = next;
    }

    ent = find_ent_by_class(-1, CLASS_GRENADE);
    while (ent > 0) {
        next = find_ent_by_class(ent, CLASS_GRENADE);
        pev(ent, pev_model, model, charsmax(model));
        if (containi(model, "w_c4") != -1)
            engfunc(EngFunc_RemoveEntity, ent);
        ent = next;
    }
}

public Message_TempEntity(iMsgId, iDest, iEnt)
{
    new iType = get_msg_arg_int(1);

    if (get_pcvar_num(g_pEffects)) {
        static const iFxTypes[] = {
            TE_GUNSHOT,
            TE_SPARKS,
            TE_STREAK_SPLASH,
            TE_BLOODSTREAM,
            TE_BLOOD,
            TE_ARMOR_RICOCHET,
            TE_BLOODSPRITE
        };

        for (new i = 0; i < sizeof(iFxTypes); i++)
            if (iType == iFxTypes[i])
                return PLUGIN_HANDLED;
    }

    if (get_pcvar_num(g_pDecals)) {
        static const iDecalTypes[] = {
            TE_GUNSHOTDECAL,
            TE_DECAL,
            TE_DECALHIGH,
            TE_WORLDDECAL,
            TE_WORLDDECALHIGH
        };

        for (new i = 0; i < sizeof(iDecalTypes); i++)
            if (iType == iDecalTypes[i])
                return PLUGIN_HANDLED;
    }

    return PLUGIN_CONTINUE;
}

public Message_ClCorpse(iMsgId, iDest, iEnt)
{
    if (get_pcvar_num(g_pCorpses))
        return PLUGIN_HANDLED;
    return PLUGIN_CONTINUE;
}

public OnPlayerKilled_Post(const id)
{
    Pruning_Log(LOG_DEBUG, "death event: player #%d — drop cleanup", id);
    OnDropCleanup();
}

public OnPlayerDropItem_Post(const id, const szItemName[])
{
    Pruning_Log(LOG_DEBUG, "drop event: player #%d dropped ^"%s^"", get_user_userid(id), szItemName);
    OnDropCleanup();
}

OnDropCleanup()
{
    if (get_pcvar_num(g_pDropWeapons))
        RemoveGroundWeapons();
}

RemoveGroundWeapons()
{
    new model[64], ent, next;

    ent = find_ent_by_class(-1, CLASS_WEAPONBOX);
    while (ent > 0) {
        next = find_ent_by_class(ent, CLASS_WEAPONBOX);
        pev(ent, pev_model, model, charsmax(model));
        if (containi(model, "w_backpack") == -1)
            engfunc(EngFunc_RemoveEntity, ent);
        ent = next;
    }

    RemoveEntitiesByClass(CLASS_DEFUSER_DROP);
}

public Message_TextMsg(iMsgId, iDest, iEnt)
{
    if (get_pcvar_num(g_pConsole) && get_msg_arg_int(1) == print_console)
        return PLUGIN_HANDLED;
    return PLUGIN_CONTINUE;
}

public Message_HudText(iMsgId, iDest, iEnt)
{
    if (get_pcvar_num(g_pHints))
        return PLUGIN_HANDLED;
    return PLUGIN_CONTINUE;
}

ApplyFileChecks()
{
    g_iFileChecks = 0;

    if (!get_pcvar_num(g_pFiles)) {
        Pruning_Log(LOG_DEBUG, "file checks disabled (pruning_files 0)");
        return;
    }

    new szFile[128];
    get_localinfo("amxx_configsdir", szFile, charsmax(szFile));
    add(szFile, charsmax(szFile), "/pruning_files.cfg");

    if (!file_exists(szFile)) {
        Pruning_Log(LOG_ERROR, "pruning_files 1, but configs/pruning_files.cfg not found — file checks skipped");
        return;
    }

    new fp = fopen(szFile, "rt");
    if (!fp) {
        Pruning_Log(LOG_ERROR, "cannot open configs/pruning_files.cfg — file checks skipped");
        return;
    }

    new szLine[256], szCmd[32], szPath[192];
    new iCount = 0, iLine = 0;

    while (!feof(fp)) {
        fgets(fp, szLine, charsmax(szLine));
        iLine++;
        trim(szLine);

        if (!szLine[0] || szLine[0] == ';' || (szLine[0] == '/' && szLine[1] == '/'))
            continue;

        if (parse(szLine, szCmd, charsmax(szCmd), szPath, charsmax(szPath)) < 2) {
            Pruning_Log(LOG_ERROR, "pruning_files.cfg line %d: malformed, expected: exactfile ^"path^"", iLine);
            continue;
        }

        if (!equal(szCmd, "exactfile")) {
            Pruning_Log(LOG_ERROR, "pruning_files.cfg line %d: unknown command ^"%s^"", iLine, szCmd);
            continue;
        }

        if (!file_exists(szPath)) {
            Pruning_Log(LOG_ERROR, "pruning_files.cfg line %d: reference file missing on server: ^"%s^" — check skipped (paths are relative to the mod dir)", iLine, szPath);
            continue;
        }

        force_unmodified(force_exactfile, { 0, 0, 0 }, { 0, 0, 0 }, szPath);
        iCount++;
        Pruning_Log(LOG_INFO, "file check active: %s", szPath);
    }

    fclose(fp);
    g_iFileChecks = iCount;
    Pruning_Log(LOG_INFO, "file checks active: %d", iCount);
}

public inconsistent_file(id, const filename[], reason[64])
{
    g_iMismatchTotal++;

    new szAuth[36], szName[32];
    GetIdentifier(id, szAuth, charsmax(szAuth));

    if (is_user_connected(id))
        get_user_name(id, szName, charsmax(szName));
    else
        copy(szName, charsmax(szName), "<connecting>");

    new iFails = 0;
    if (g_tMismatch != Invalid_Trie) {
        if (TrieKeyExists(g_tMismatch, szAuth))
            TrieGetCell(g_tMismatch, szAuth, iFails);
        iFails++;
        TrieSetCell(g_tMismatch, szAuth, iFails);
    }

    Pruning_Log(LOG_ERROR, "file mismatch: %s (%s) file ^"%s^" engine reason ^"%s^" — fail #%d",
        szName, szAuth, filename, reason, iFails);

    ExecuteForward(g_hFwdFlagged, g_iFwdRet, id, filename);

    if (get_pcvar_num(g_pFilesFix) && is_user_connected(id) && !is_user_bot(id) && !is_user_hltv(id))
        SendFixGuide(id, filename);

    if (!is_user_connected(id))
        return;

    new iMaxFails = get_pcvar_num(g_pFilesMaxFails);
    new iBanTime  = get_pcvar_num(g_pFilesBanTime);
    if (iMaxFails < 0) iMaxFails = 0;
    if (iBanTime  < 0) iBanTime = 0;

    // A persistent ban (engine banned.cfg + the autonomous ban list) is only allowed for an
    // individual SteamID. A session-only (uid_<userid>) or shared (STEAM_ID_LAN) identifier
    // never reaches the engine or the ban file — punishing by it would hit innocent clients
    // after a restart; such a client is punished for this session only.
    new bBanReached = (iMaxFails > 0 && iBanTime > 0 && iFails >= iMaxFails);
    new bBanStored  = (bBanReached && IsValidAuth(szAuth));

    if (bBanStored) {

        server_cmd("banid %d ^"%s^"; writeid", iBanTime, szAuth);
        if (get_pcvar_num(g_pBans))
            BanListRemember(szAuth, iBanTime);
        g_iBanTotal++;
        Pruning_Log(LOG_INFO, "ban %d min: %s (%s) — %d file mismatches", iBanTime, szName, szAuth, iFails);
        ExecuteForward(g_hFwdBanned, g_iFwdRet, id, szAuth, iBanTime);

        new szTpl[128], szKick[192];
        Lang("KICK_BAN", szTpl, charsmax(szTpl));
        formatex(szKick, charsmax(szKick), szTpl, iBanTime, filename);
        g_iKickTotal++;
        server_cmd("kick #%d ^"%s^"", get_user_userid(id), szKick);
    } else {

        if (bBanReached)
            Pruning_Log(LOG_INFO, "ban skipped: ^"%s^" is not an individual SteamID (session-only or shared) — %s is punished for this session only, nothing is persisted", szAuth, szName);

        if (get_pcvar_num(g_pFilesKick)) {
            g_iKickTotal++;
            new szTpl[128], szKick[192];
            Lang("KICK_MISMATCH", szTpl, charsmax(szTpl));
            formatex(szKick, charsmax(szKick), szTpl, filename);
            server_cmd("kick #%d ^"%s^"", get_user_userid(id), szKick);
        }
    }
}

SendFixGuide(id, const szFile[])
{
    new szTpl[224], szMsg[256], szPart[384], szTitle[64], szMOTD[1920], szKey[16];

    Lang("FILE_MISMATCH", szTpl, charsmax(szTpl));
    formatex(szMsg, charsmax(szMsg), szTpl, szFile);
    client_print(id, print_chat, "[RePruning] %s", szMsg);

    Lang("FIX_OPEN", szTpl, charsmax(szTpl));
    client_print(id, print_chat, "[RePruning] %s", szTpl);

    static const szHead[] = "<html><head><meta http-equiv=^"Content-Type^" content=^"text/html; charset=utf-8^"></head><body bgcolor=^"#181818^" text=^"#dcdcdc^"><font face=^"Trebuchet MS^">";
    static const szFoot[] = "<br><font color=^"#888888^">RePruning — file integrity control</font></font></body></html>";

    copy(szMOTD, charsmax(szMOTD), szHead);
    add(szMOTD, charsmax(szMOTD), "<font color=^"#ff6a6a^"><b>");
    Lang("MOTD_HEAD", szTpl, charsmax(szTpl));
    formatex(szPart, charsmax(szPart), szTpl, szFile);
    add(szMOTD, charsmax(szMOTD), szPart);
    add(szMOTD, charsmax(szMOTD), "</b></font><br><br><b>");
    Lang("MOTD_HOWTO", szTpl, charsmax(szTpl));
    add(szMOTD, charsmax(szMOTD), szTpl);
    add(szMOTD, charsmax(szMOTD), "</b><br>");

    for (new i = 1; i <= 5; i++) {
        formatex(szKey, charsmax(szKey), "MOTD_STEP%d", i);
        Lang(szKey, szTpl, charsmax(szTpl));
        add(szMOTD, charsmax(szMOTD), szTpl);
        add(szMOTD, charsmax(szMOTD), "<br>");
    }
    add(szMOTD, charsmax(szMOTD), "<br>");

    Lang("MOTD_NOTE", szTpl, charsmax(szTpl));
    formatex(szPart, charsmax(szPart), "<font color=^"#88aadd^">%s</font>", szTpl);
    add(szMOTD, charsmax(szMOTD), szPart);
    add(szMOTD, charsmax(szMOTD), szFoot);

    Lang("MOTD_TITLE", szTitle, charsmax(szTitle));
    show_motd(id, szMOTD, szTitle);
    Pruning_Log(LOG_DEBUG, "fix guide sent to client #%d for file ^"%s^"", get_user_userid(id), szFile);
}

LoadLanguages()
{
    TrieClear(g_tLang);
    g_iLangCount = 0;
    g_iLangKeys = 0;

    new szBase[96], szPath[192], szLine[640], szKey[64], szVal[512], szCc[16], szFlat[80];
    get_localinfo("amxx_datadir", szBase, charsmax(szBase));
    add(szBase, charsmax(szBase), "/repruning");

    if (!dir_exists(szBase)) {
        Pruning_Log(LOG_ERROR, "language folder not found: %s — key names will be printed instead of texts", szBase);
        return;
    }

    new dp = open_dir(szBase, szCc, charsmax(szCc));
    if (!dp)
        return;

    while (next_file(dp, szCc, charsmax(szCc))) {
        if (szCc[0] == '.' || szCc[0] == '/')
            continue;

        formatex(szPath, charsmax(szPath), "%s/%s/repruning.txt", szBase, szCc);
        if (!file_exists(szPath))
            continue;

        new fp = fopen(szPath, "rt");
        if (!fp)
            continue;

        new iKeys;
        while (!feof(fp)) {
            fgets(fp, szLine, charsmax(szLine));
            trim(szLine);

            if (!szLine[0] || szLine[0] == ';' || (szLine[0] == '/' && szLine[1] == '/'))
                continue;

            new iPos = contain(szLine, "=");
            if (iPos < 1) {
                Pruning_Log(LOG_ERROR, "lang %s: malformed line ^"%s^"", szPath, szLine);
                continue;
            }

            copy(szKey, iPos, szLine);
            trim(szKey);
            copy(szVal, charsmax(szVal), szLine[iPos + 1]);
            trim(szVal);

            if (!szKey[0] || !szVal[0]) {
                Pruning_Log(LOG_ERROR, "lang %s: malformed line ^"%s^"", szPath, szLine);
                continue;
            }

            formatex(szFlat, charsmax(szFlat), "%s.%s", szCc, szKey);
            TrieSetString(g_tLang, szFlat, szVal);
            iKeys++;
        }
        fclose(fp);

        if (iKeys) {
            g_iLangCount++;
            g_iLangKeys += iKeys;
            Pruning_Log(LOG_INFO, "language loaded: %s — %d keys", szCc, iKeys);
        }
    }
    close_dir(dp);

    if (!g_iLangCount)
        Pruning_Log(LOG_ERROR, "no languages loaded from %s — key names will be printed instead of texts", szBase);
}

Lang(const szKey[], szOut[], iMaxLen)
{
    new szCc[8], szFlat[80];
    get_pcvar_string(g_pLang, szCc, charsmax(szCc));
    if (!szCc[0])
        copy(szCc, charsmax(szCc), "us");

    formatex(szFlat, charsmax(szFlat), "%s.%s", szCc, szKey);
    if (!TrieGetString(g_tLang, szFlat, szOut, iMaxLen)) {
        formatex(szFlat, charsmax(szFlat), "us.%s", szKey);
        if (!TrieGetString(g_tLang, szFlat, szOut, iMaxLen)) {
            copy(szOut, iMaxLen, szKey);
            Pruning_Log(LOG_DEBUG, "lang key not found: %s", szKey);
        }
    }
}

LoadBanList()
{
    TrieClear(g_tBanMem);
    g_iBanExpired = 0;
    g_iBanInvalid = 0;

    get_localinfo("amxx_datadir", g_szBanMemPath, charsmax(g_szBanMemPath));
    add(g_szBanMemPath, charsmax(g_szBanMemPath), "/repruning_bans.txt");

    if (!file_exists(g_szBanMemPath)) {
        Pruning_Log(LOG_DEBUG, "ban list is empty: %s not found yet", g_szBanMemPath);
        return;
    }

    new fp = fopen(g_szBanMemPath, "rt");
    if (!fp) {
        Pruning_Log(LOG_ERROR, "cannot open ban list: %s", g_szBanMemPath);
        return;
    }

    new szLine[160], szAuth[36], szTok1[24], szTok2[24], iLoaded, iNow = get_systime();
    while (!feof(fp)) {
        fgets(fp, szLine, charsmax(szLine));
        trim(szLine);

        if (!szLine[0] || szLine[0] == ';' || (szLine[0] == '/' && szLine[1] == '/'))
            continue;

        new iTok = parse(szLine, szAuth, charsmax(szAuth), szTok1, charsmax(szTok1), szTok2, charsmax(szTok2));
        if (iTok < 2) {
            g_iBanInvalid++;
            Pruning_Log(LOG_ERROR, "ban list validation: malformed line ^"%s^" — dropped", szLine);
            continue;
        }

        new iExpires = (iTok >= 3) ? (str_to_num(szTok2) + str_to_num(szTok1) * 60) : str_to_num(szTok1);
        if (!IsValidAuth(szAuth) || iExpires <= 0) {
            g_iBanInvalid++;
            Pruning_Log(LOG_ERROR, "ban list validation: invalid entry ^"%s^" — dropped", szLine);
            continue;
        }

        if (iExpires <= iNow) {
            g_iBanExpired++;
            Pruning_Log(LOG_INFO, "ban list: expired entry for %s — removed automatically", szAuth);
            continue;
        }

        TrieSetCell(g_tBanMem, szAuth, iExpires);
        iLoaded++;
    }
    fclose(fp);

    if (g_iBanInvalid || g_iBanExpired)
        BanListSave();

    Pruning_Log(LOG_INFO, "ban list loaded: %d active | %d expired auto-removed | %d invalid dropped (%s)",
        iLoaded, g_iBanExpired, g_iBanInvalid, g_szBanMemPath);
}

IsValidAuth(const szAuth[])
{
    // Only an individual SteamID may back a persistent ban. Session-only keys (uid_<userid>,
    // used while the client's SteamID has not arrived yet) reset on every restart, and shared
    // pseudo-authids (STEAM_ID_LAN, HLTV, STEAM_ID_PENDING, STEAM_ID_BOT) match many clients
    // at once — storing or banning by them would punish innocent players.
    if (contain(szAuth, "STEAM_") != 0)
        return 0;
    if (szAuth[6] < '0' || szAuth[6] > '9' || szAuth[7] != ':' || strlen(szAuth) < 11)
        return 0;
    return 1;
}

BanListRemember(const szAuth[], iMinutes)
{
    if (g_tBanMem == Invalid_Trie || !IsValidAuth(szAuth))
        return;

    new iNow = get_systime();
    new iExpires = iNow + iMinutes * 60;

    new iTTL = get_pcvar_num(g_pBansTTL);
    if (iTTL > 0 && iMinutes > iTTL * 60) {
        iExpires = iNow + iTTL * 60;
        Pruning_Log(LOG_ERROR, "validation: ban %d min exceeds pruning_bans_ttl %d h — clamped", iMinutes, iTTL);
    }

    TrieSetCell(g_tBanMem, szAuth, iExpires);
    BanListEvict();
    BanListSave();

    new szStamp[32];
    format_time(szStamp, charsmax(szStamp), "%d.%m.%Y %H:%M", iExpires);
    Pruning_Log(LOG_INFO, "ban list: %s stored until %s (autonomous) — %d entries", szAuth, szStamp, TrieGetSize(g_tBanMem));
}

BanListEvict()
{
    new iMax = get_pcvar_num(g_pBansMax);

    while (TrieGetSize(g_tBanMem) > iMax) {
        new Snapshot:iSnap = TrieSnapshotCreate(g_tBanMem);
        new iDrop = -1, iOldest = 0;

        for (new i = 0; i < TrieSnapshotLength(iSnap); i++) {
            new szKey[36], iExpires;
            TrieSnapshotGetKey(iSnap, i, szKey, charsmax(szKey));
            TrieGetCell(g_tBanMem, szKey, iExpires);
            if (iDrop == -1 || iExpires < iOldest) {
                iDrop = i;
                iOldest = iExpires;
            }
        }

        new szKey[36];
        if (iDrop != -1) {
            TrieSnapshotGetKey(iSnap, iDrop, szKey, charsmax(szKey));
            TrieDeleteKey(g_tBanMem, szKey);
            Pruning_Log(LOG_INFO, "ban list: cap %d reached — earliest-expiring entry %s removed", iMax, szKey);
        }

        TrieSnapshotDestroy(iSnap);

        if (iDrop == -1)
            break;
    }
}

BanListSave()
{
    new fp = fopen(g_szBanMemPath, "wt");
    if (!fp) {
        Pruning_Log(LOG_ERROR, "cannot write ban list: %s", g_szBanMemPath);
        return;
    }

    new Snapshot:iSnap = TrieSnapshotCreate(g_tBanMem);
    for (new i = 0; i < TrieSnapshotLength(iSnap); i++) {
        new szKey[36], iExpires;
        TrieSnapshotGetKey(iSnap, i, szKey, charsmax(szKey));
        TrieGetCell(g_tBanMem, szKey, iExpires);
        fprintf(fp, "%s %d^n", szKey, iExpires);
    }
    TrieSnapshotDestroy(iSnap);
    fclose(fp);
}

BanListCheckExpired(const szAuth[])
{
    new iExpires;
    if (!TrieGetCell(g_tBanMem, szAuth, iExpires))
        return 0;

    if (get_systime() < iExpires)
        return 1;

    TrieDeleteKey(g_tBanMem, szAuth);
    BanListSave();
    g_iBanExpired++;
    Pruning_Log(LOG_INFO, "ban list: entry for %s expired — removed automatically", szAuth);
    ExecuteForward(g_hFwdUnbanned, g_iFwdRet, szAuth);
    return 0;
}

public client_authorized(id)
{
    new szAuth[36];
    get_user_authid(id, szAuth, charsmax(szAuth));

    if (!get_pcvar_num(g_pBans))
        return;

    if (!BanListCheckExpired(szAuth))
        return;

    g_iBanMemHits++;

    new iExpires;
    TrieGetCell(g_tBanMem, szAuth, iExpires);

    new szStamp[40], szTpl[128], szKick[192];
    format_time(szStamp, charsmax(szStamp), "%d.%m.%Y %H:%M", iExpires);
    Lang("BAN_REJECT", szTpl, charsmax(szTpl));
    formatex(szKick, charsmax(szKick), szTpl, szStamp);
    Pruning_Log(LOG_INFO, "ban list hit: %s — kicked on connect (auto-expires %s)", szAuth, szStamp);
    server_cmd("kick #%d ^"%s^"", get_user_userid(id), szKick);
}

public Task_BanCleanup()
{
    if (!get_pcvar_num(g_pBansCleanup) || !get_pcvar_num(g_pBans))
        return;

    new iNow = get_systime(), iRemoved, szKey[36], iExpires;
    new Snapshot:iSnap = TrieSnapshotCreate(g_tBanMem);

    for (new i = 0; i < TrieSnapshotLength(iSnap); i++) {
        TrieSnapshotGetKey(iSnap, i, szKey, charsmax(szKey));
        TrieGetCell(g_tBanMem, szKey, iExpires);

        if (iExpires <= iNow) {
            TrieDeleteKey(g_tBanMem, szKey);
            g_iBanExpired++;
            iRemoved++;
            ExecuteForward(g_hFwdUnbanned, g_iFwdRet, szKey);
        }
    }
    TrieSnapshotDestroy(iSnap);

    if (iRemoved) {
        BanListSave();
        Pruning_Log(LOG_INFO, "ban list cleanup: %d expired entries removed automatically", iRemoved);
    }
}

GetIdentifier(id, szBuf[], iLen)
{
    get_user_authid(id, szBuf, iLen);

    if (!szBuf[0] || equal(szBuf, "STEAM_ID_PENDING"))
        formatex(szBuf, iLen, "uid_%d", get_user_userid(id));
}

public ClCmd_MyId(id)
{
    if (!is_user_connected(id))
        return PLUGIN_HANDLED;

    if (!get_pcvar_num(g_pIds)) {
        console_print(id, "[RePruning] identifier system is disabled (pruning_ids 0)");
        return PLUGIN_HANDLED;
    }

    new szId[36];
    GetIdentifier(id, szId, charsmax(szId));
    console_print(id, "[RePruning] your identifier: %s (uid %d)", szId, get_user_userid(id));
    return PLUGIN_HANDLED;
}

public ConCmd_Ids(id)
{
    if (!get_pcvar_num(g_pIds)) {
        console_print(id, "[RePruning] identifier system is disabled (pruning_ids 0)");
        return PLUGIN_HANDLED;
    }

    new iPlayers[32], iNum;
    get_players(iPlayers, iNum, "ch");

    console_print(id, "------------- RePruning identifiers v%s -------------", VERSION);
    console_print(id, "%-4s %-22s %-20s %s", "uid", "identifier", "name", "status");

    for (new i = 0; i < iNum; i++) {
        new p = iPlayers[i], szId[36], szName[32], szStatus[32], iFails;
        GetIdentifier(p, szId, charsmax(szId));
        get_user_name(p, szName, charsmax(szName));
        TrieGetCell(g_tMismatch, szId, iFails);

        new szAuth[36], iExpires;
        get_user_authid(p, szAuth, charsmax(szAuth));
        new iBanned = (TrieGetCell(g_tBanMem, szAuth, iExpires) && get_systime() < iExpires) ? 1 : 0;

        if (iFails && iBanned)
            formatex(szStatus, charsmax(szStatus), "flagged %d +banned", iFails);
        else if (iFails)
            formatex(szStatus, charsmax(szStatus), "flagged %d", iFails);
        else if (iBanned)
            copy(szStatus, charsmax(szStatus), "banned");
        else
            copy(szStatus, charsmax(szStatus), "clean");

        console_print(id, "%-4d %-22s %-20s %s", get_user_userid(p), szId, szName, szStatus);
    }

    console_print(id, "------------------------------------------------------");
    return PLUGIN_HANDLED;
}

public Native_IsFlagged(iPlugin, iParams)
{
    new id = get_param(1);
    if (id < 1 || id > get_maxplayers() || !is_user_connected(id))
        return 0;

    new szAuth[36];
    GetIdentifier(id, szAuth, charsmax(szAuth));
    return TrieKeyExists(g_tMismatch, szAuth) ? 1 : 0;
}

public Native_GetMismatches(iPlugin, iParams)
{
    new id = get_param(1);
    if (id < 1 || id > get_maxplayers() || !is_user_connected(id))
        return 0;

    new szAuth[36], iFails;
    GetIdentifier(id, szAuth, charsmax(szAuth));
    TrieGetCell(g_tMismatch, szAuth, iFails);
    return iFails;
}

public Native_IsBanned(iPlugin, iParams)
{
    new szAuth[36];
    get_string(1, szAuth, charsmax(szAuth));

    if (!IsValidAuth(szAuth))
        return 0;

    return BanListCheckExpired(szAuth);
}

public Native_AddBan(iPlugin, iParams)
{
    new szAuth[36];
    get_string(1, szAuth, charsmax(szAuth));
    new iMinutes = get_param(2);

    if (!IsValidAuth(szAuth) || iMinutes <= 0 || !get_pcvar_num(g_pBans))
        return 0;

    BanListCheckExpired(szAuth);
    BanListRemember(szAuth, iMinutes);
    return 1;
}

public Native_RemoveBan(iPlugin, iParams)
{
    new szAuth[36];
    get_string(1, szAuth, charsmax(szAuth));

    if (!TrieKeyExists(g_tBanMem, szAuth))
        return 0;

    TrieDeleteKey(g_tBanMem, szAuth);
    BanListSave();
    Pruning_Log(LOG_INFO, "ban list: %s removed by external plugin (native repruning_remove_ban)", szAuth);
    ExecuteForward(g_hFwdUnbanned, g_iFwdRet, szAuth);
    return 1;
}

public Native_GetIdentifier(iPlugin, iParams)
{
    new id = get_param(1);
    if (id < 1 || id > get_maxplayers() || !is_user_connected(id))
        return 0;

    new szId[36];
    GetIdentifier(id, szId, charsmax(szId));
    set_string(2, szId, get_param(3));
    return 1;
}

Pruning_Log(iLevel, const szFmt[], any:...)
{
    new szMsg[384];
    vformat(szMsg, charsmax(szMsg), szFmt, 3);

    if (iLevel == LOG_ERROR)
        g_iErrCount++;

    if (get_pcvar_num(g_pLogLevel) < iLevel)
        return;

    static const szTag[][] = { "", "ERROR", "INFO", "DEBUG" };

    new szStamp[32];
    format_time(szStamp, charsmax(szStamp), "%m/%d/%y - %H:%M:%S");

    new fp = fopen(g_szLogPath, "at");
    if (fp) {
        fprintf(fp, "[%s] [%s] %s^n", szStamp, szTag[iLevel], szMsg);
        fclose(fp);
    }

    if (iLevel == LOG_ERROR)
        log_amx("ERROR: %s", szMsg);
}

RepLine(szOut[], iLen, const szFmt[], any:...)
{
    new szMsg[224];
    vformat(szMsg, charsmax(szMsg), szFmt, 4);
    add(szOut, iLen, szMsg);
    add(szOut, iLen, "^n");
}

BuildServerReport(szOut[], iLen)
{
    new szMap[48], szUptime[16];
    get_mapname(szMap, charsmax(szMap));

    new iUp = get_systime() - g_iStartSystime;
    formatex(szUptime, charsmax(szUptime), "%02d:%02d:%02d", iUp / 3600, (iUp % 3600) / 60, iUp % 60);

    new szCc[8];
    get_pcvar_string(g_pLang, szCc, charsmax(szCc));

    szOut[0] = 0;
    RepLine(szOut, iLen, "--------------- RePruning v%s ---------------", VERSION);
    RepLine(szOut, iLen, "Map: %s | Uptime: %s | Rounds: %d", szMap, szUptime, g_iRounds);
    RepLine(szOut, iLen, "Modules: buy=%d buyzone=%d money=%d plantzone=%d c4give=%d c4remove=%d",
        get_pcvar_num(g_pBuy), get_pcvar_num(g_pBuyZoneRemove), get_pcvar_num(g_pMoney),
        get_pcvar_num(g_pPlantZone), get_pcvar_num(g_pBombGive), get_pcvar_num(g_pBombRemove));
    RepLine(szOut, iLen, "         icons=%d radio=%d winsnd=%d hostages=%d vip=%d fx=%d decals=%d",
        get_pcvar_num(g_pIcons), get_pcvar_num(g_pRadio), get_pcvar_num(g_pRadioWinSounds),
        get_pcvar_num(g_pHostages), get_pcvar_num(g_pVip), get_pcvar_num(g_pEffects),
        get_pcvar_num(g_pDecals));
    RepLine(szOut, iLen, "         corpses=%d drops=%d console=%d hints=%d files=%d",
        get_pcvar_num(g_pCorpses), get_pcvar_num(g_pDropWeapons), get_pcvar_num(g_pConsole),
        get_pcvar_num(g_pHints), get_pcvar_num(g_pFiles));
    RepLine(szOut, iLen, "Files: active checks=%d | clients=%d | mismatches=%d | kicks=%d | bans=%d",
        g_iFileChecks, g_iClientsConnected, g_iMismatchTotal, g_iKickTotal, g_iBanTotal);
    RepLine(szOut, iLen, "Lang: %s | languages=%d | keys=%d | drop cleanup: event-driven (no scan task)",
        szCc, g_iLangCount, g_iLangKeys);
    RepLine(szOut, iLen, "Ban list: %d active | hits=%d | auto-expired=%d | invalid dropped=%d",
        TrieGetSize(g_tBanMem), g_iBanMemHits, g_iBanExpired, g_iBanInvalid);
    RepLine(szOut, iLen, "  bans=%d ttl=%d h cleanup=%d max=%d ids=%d | file: %s",
        get_pcvar_num(g_pBans), get_pcvar_num(g_pBansTTL), get_pcvar_num(g_pBansCleanup),
        get_pcvar_num(g_pBansMax), get_pcvar_num(g_pIds), g_szBanMemPath);
    RepLine(szOut, iLen, "API: library repruning — 11 natives + 3 forwards (source/repruning.inc)");
    RepLine(szOut, iLen, "Errors total: %d | Log level: %d | Log file: %s",
        g_iErrCount, get_pcvar_num(g_pLogLevel), g_szLogPath);
    RepLine(szOut, iLen, "-------------------------------------------------------------");
}

enum RePruningStat
{
    RePruningStat_Mismatches  = 0,
    RePruningStat_Kicks,
    RePruningStat_Bans,
    RePruningStat_Errors,
    RePruningStat_BanListHits,
    RePruningStat_BansExpired,
    RePruningStat_BansInvalid,
    RePruningStat_FileChecks
};

public Native_ServerInfo(iPlugin, iParams)
{
    new iLen = get_param(2), szReport[1280];
    BuildServerReport(szReport, charsmax(szReport));
    set_string(1, szReport, iLen);
    return 1;
}

public Native_ServerData(iPlugin, iParams)
{
    new iMax = get_param(2);
    new szBuf[1024], szMap[48], szLang[16];

    get_mapname(szMap, charsmax(szMap));
    get_pcvar_string(g_pLang, szLang, charsmax(szLang));

    new iLen = copy(szBuf, charsmax(szBuf), "api=1");
    iLen += formatex(szBuf[iLen], charsmax(szBuf) - iLen,
        "^nversion=%s^nmap=%s^nlog_level=%d^nlang=%s^nlang_count=%d^nlang_keys=%d^nfile_checks=%d^nclients=%d",
        VERSION, szMap, get_pcvar_num(g_pLogLevel), szLang, g_iLangCount, g_iLangKeys,
        g_iFileChecks, g_iClientsConnected);
    iLen += formatex(szBuf[iLen], charsmax(szBuf) - iLen,
        "^nban_entries=%d^nban_hits=%d^nban_expired=%d^nban_invalid=%d",
        (g_tBanMem != Invalid_Trie) ? TrieGetSize(g_tBanMem) : 0,
        g_iBanMemHits, g_iBanExpired, g_iBanInvalid);
    iLen += formatex(szBuf[iLen], charsmax(szBuf) - iLen,
        "^nmismatch_total=%d^nkick_total=%d^nban_total=%d^nerrors=%d",
        g_iMismatchTotal, g_iKickTotal, g_iBanTotal, g_iErrCount);

    if (iLen >= iMax)
        return 0;

    set_string(1, szBuf, iMax);
    return 1;
}

public Native_GetBanExpiry(iPlugin, iParams)
{
    new szAuth[36];
    get_string(1, szAuth, charsmax(szAuth));

    if (!IsValidAuth(szAuth))
        return 0;

    BanListCheckExpired(szAuth);

    new iExpires;
    return TrieGetCell(g_tBanMem, szAuth, iExpires) ? iExpires : 0;
}

public Native_GetBanCount(iPlugin, iParams)
{
    return (g_tBanMem != Invalid_Trie) ? TrieGetSize(g_tBanMem) : 0;
}

public Native_GetStat(iPlugin, iParams)
{
    switch (RePruningStat:get_param(1))
    {
        case RePruningStat_Mismatches:  return g_iMismatchTotal;
        case RePruningStat_Kicks:       return g_iKickTotal;
        case RePruningStat_Bans:        return g_iBanTotal;
        case RePruningStat_Errors:      return g_iErrCount;
        case RePruningStat_BanListHits: return g_iBanMemHits;
        case RePruningStat_BansExpired: return g_iBanExpired;
        case RePruningStat_BansInvalid: return g_iBanInvalid;
        case RePruningStat_FileChecks:  return g_iFileChecks;
    }

    return 0;
}

public ClCmd_PlayerInfo(id)
{
    if (!is_user_connected(id))
        return PLUGIN_HANDLED;

    new szAuth[36], iFails;
    GetIdentifier(id, szAuth, charsmax(szAuth));
    TrieGetCell(g_tMismatch, szAuth, iFails);

    console_print(id, "-------------- RePruning v%s --------------", VERSION);

    if (iFails)
        console_print(id, "Your status: FLAGGED — %d file mismatch(es) on this server", iFails);
    else
        console_print(id, "Your status: clean — no file mismatches");

    new szId[36];
    GetIdentifier(id, szId, charsmax(szId));
    console_print(id, "Your identifier: %s", szId);
    console_print(id, "File checks: %s (%d checks)", get_pcvar_num(g_pFiles) ? "ON" : "OFF", g_iFileChecks);

    new szOn[384], szOff[384];
    BuildModuleLists(szOn, charsmax(szOn), szOff, charsmax(szOff));
    console_print(id, "Removed on this server: %s", szOff[0] ? szOff : "(none)");
    console_print(id, "Left as is: %s", szOn[0] ? szOn : "(none)");
    console_print(id, "Full server report: pruning_info (optional plugin pruning_info.amxx)");
    console_print(id, "------------------------------------------------");
    return PLUGIN_HANDLED;
}

BuildModuleLists(szOn[], iOnLen, szOff[], iOffLen)
{
    new iHandles[17];
    iHandles[0] = g_pBuy;
    iHandles[1] = g_pBuyZoneRemove;
    iHandles[2] = g_pMoney;
    iHandles[3] = g_pPlantZone;
    iHandles[4] = g_pBombGive;
    iHandles[5] = g_pBombRemove;
    iHandles[6] = g_pIcons;
    iHandles[7] = g_pRadio;
    iHandles[8] = g_pRadioWinSounds;
    iHandles[9] = g_pHostages;
    iHandles[10] = g_pVip;
    iHandles[11] = g_pEffects;
    iHandles[12] = g_pDecals;
    iHandles[13] = g_pCorpses;
    iHandles[14] = g_pDropWeapons;
    iHandles[15] = g_pConsole;
    iHandles[16] = g_pHints;

    static const szNames[][] = { "buy", "buyzones", "money", "plantzones", "C4 give", "C4", "HUD icons",
        "radio", "win sounds", "hostages", "VIP", "blood/effects", "decals", "corpses", "dropped weapons",
        "console msgs", "hints" };

    for (new i = 0; i < sizeof(iHandles); i++) {
        if (get_pcvar_num(iHandles[i]))
            AddListName(szOff, iOffLen, szNames[i]);
        else
            AddListName(szOn, iOnLen, szNames[i]);
    }
}

AddListName(szList[], iLen, const szName[])
{
    if (szList[0])
        add(szList, iLen, ", ");
    add(szList, iLen, szName);
}

public client_putinserver(id)
{
    g_iClientsConnected++;
    Pruning_Log(LOG_DEBUG, "client #%d connected — passed file checks", get_user_userid(id));
}

public plugin_end()
{
    Pruning_Log(LOG_INFO, "RePruning unloaded (errors total: %d)", g_iErrCount);

    if (g_tMismatch != Invalid_Trie)
        TrieDestroy(g_tMismatch);
    if (g_tLang != Invalid_Trie)
        TrieDestroy(g_tLang);
    if (g_tBanMem != Invalid_Trie)
        TrieDestroy(g_tBanMem);
}

public ConCmd_Reload(id)
{
    new szCfgDir[96], szCfgFile[128];
    get_localinfo("amxx_configsdir", szCfgDir, charsmax(szCfgDir));

    ExecConfig(szCfgDir, szCfgFile, charsmax(szCfgFile), "pruning.cfg");
    ExecConfig(szCfgDir, szCfgFile, charsmax(szCfgFile), "pruning_baning.cfg");
    ValidateBaningCvars();

    PerformCleanup();
    ApplyFileChecks();
    OnDropCleanup();
    LoadLanguages();
    LoadBanList();

    new szMsg[96];
    Lang("RELOADED", szMsg, charsmax(szMsg));
    console_print(id, "[RePruning] %s", szMsg);

    new szName[32];
    if (id > 0 && is_user_connected(id))
        get_user_name(id, szName, charsmax(szName));

    Pruning_Log(LOG_INFO, "config reloaded by admin %s (#%d)", szName,
        (id > 0 && is_user_connected(id)) ? get_user_userid(id) : 0);
    return PLUGIN_HANDLED;
}
