//Name: RePruning v0.0.2 Alpha
//Author: DeRoPEN_DEv
//Platforms: HLDS and ReHLDS
//Mandatory: ReHLDS 3.15.0.896-dev + ReAPI v5.29.0.359-dev + Metamod-R 1.3.0.149 + AMXModX 1.10+ + ReGameDLL 5.30.0.814-dev
//Description: A plugin for removing, cleaning up, or disabling various features on CS 1.6 servers
//Reminder: Use 0 to disable the feature, and 1 to enable it
//Sites: github.com/DeRoPEN31 and deropen.fun

#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <reapi>

#define PLUGIN  "RePruning"
#define VERSION "v0.0.2 Alpha"
#define AUTHOR  "DeRoPEN_DEv"

#define DROP_SCAN_PERIOD    2.0

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
new g_pLogLevel;

new g_szLogPath[128];
new g_iErrCount;
new g_iClientsConnected;
new g_iRounds;
new g_iFileChecks;
new g_iMismatchTotal, g_iKickTotal, g_iBanTotal;
new g_iStartSystime;
new Trie:g_tMismatch;

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
    g_pLogLevel       = register_cvar("pruning_log_level",       "2");

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

    register_concmd("amx_pruning_reload", "ConCmd_Reload", ADMIN_CFG, " - reread configs/pruning.cfg");
    register_concmd("amx_pruning_status", "ConCmd_Status", ADMIN_CFG, " - module status, counters, errors");

    g_tMismatch = TrieCreate();
}

public plugin_cfg()
{

    new szLogsDir[96];
    get_localinfo("amxx_logsdir", szLogsDir, charsmax(szLogsDir));
    formatex(g_szLogPath, charsmax(g_szLogPath), "%s/RePruning.log", szLogsDir);
    g_iStartSystime = get_systime();

    new szCfgDir[96], szCfgFile[128];
    get_localinfo("amxx_configsdir", szCfgDir, charsmax(szCfgDir));
    formatex(szCfgFile, charsmax(szCfgFile), "%s/pruning.cfg", szCfgDir);

    if (file_exists(szCfgFile)) {
        server_cmd("exec %s", szCfgFile);
        server_exec();
    } else {
        Pruning_Log(LOG_ERROR, "configs/pruning.cfg not found — all modules run on default values");
    }

    PerformCleanup();
    ApplyFileChecks();

    set_task(DROP_SCAN_PERIOD, "Task_ScanDrops", _, _, _, "b");

    server_print("[RePruning] v%s loaded", VERSION);

    new szMap[48];
    get_mapname(szMap, charsmax(szMap));
    Pruning_Log(LOG_INFO, "===== RePruning v%s | map %s | log level %d | file checks %d =====",
        VERSION, szMap, get_pcvar_num(g_pLogLevel), g_iFileChecks);
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

public Task_ScanDrops()
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
    get_user_authid(id, szAuth, charsmax(szAuth));
    if (!szAuth[0] || equal(szAuth, "STEAM_ID_PENDING"))
        formatex(szAuth, charsmax(szAuth), "uid_%d", get_user_userid(id));

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

    if (get_pcvar_num(g_pFilesFix) && is_user_connected(id) && !is_user_bot(id) && !is_user_hltv(id))
        SendFixGuide(id, filename);

    if (!is_user_connected(id))
        return;

    new iMaxFails = get_pcvar_num(g_pFilesMaxFails);
    new iBanTime  = get_pcvar_num(g_pFilesBanTime);
    if (iMaxFails < 0) iMaxFails = 0;
    if (iBanTime  < 0) iBanTime = 0;

    if (iMaxFails > 0 && iBanTime > 0 && iFails >= iMaxFails) {

        server_cmd("banid %d ^"%s^"; writeid", iBanTime, szAuth);
        g_iBanTotal++;
        Pruning_Log(LOG_INFO, "ban %d min: %s (%s) — %d file mismatches", iBanTime, szName, szAuth, iFails);
        g_iKickTotal++;
        server_cmd("kick #%d ^"file mismatch, banned %d min: %s^"", get_user_userid(id), iBanTime, filename);
    } else if (get_pcvar_num(g_pFilesKick)) {

        g_iKickTotal++;
        server_cmd("kick #%d ^"file mismatch: %s^"", get_user_userid(id), filename);
    }
}

SendFixGuide(id, const szFile[])
{
    client_print(id, print_chat, "[RePruning] File ^"%s^" failed the MD5 check.", szFile);
    client_print(id, print_chat, "[RePruning] A fix guide (Steam Cloud) is opening now.");

    static const szHead[] = "<html><head><meta http-equiv=^"Content-Type^" content=^"text/html; charset=utf-8^"></head><body bgcolor=^"#181818^" text=^"#dcdcdc^"><font face=^"Trebuchet MS^">";
    static const szFoot[] = "<br><font color=^"#888888^">RePruning — file integrity control</font></font></body></html>";

    new szMOTD[1280];
    copy(szMOTD, charsmax(szMOTD), szHead);
    add(szMOTD, charsmax(szMOTD), "<font color=^"#ff6a6a^"><b>Файл не прошёл проверку: ");
    add(szMOTD, charsmax(szMOTD), szFile);
    add(szMOTD, charsmax(szMOTD), "</b></font><br><br>");
    add(szMOTD, charsmax(szMOTD), "<b>How to fix (Steam Cloud / MD5):</b><br>");
    add(szMOTD, charsmax(szMOTD), "1. Exit the game<br>");
    add(szMOTD, charsmax(szMOTD), "2. Delete the specified file from the cstrike folder (or reinstall the game)<br>");
    add(szMOTD, charsmax(szMOTD), "3. Disable Steam Cloud for CS 1.6: Steam -> Library -> CS 1.6 -> Properties -> General -> uncheck "Keep games saves in the Steam Cloud" — otherwise, Steam will restore the file<br>");
    add(szMOTD, charsmax(szMOTD), "4. Verify the integrity of the files: Properties -> Local Files -> "Verify integrity of game files"<br>");
    add(szMOTD, charsmax(szMOTD), "5. Log in to the server again<br><br>");
    add(szMOTD, charsmax(szMOTD), "<b>How to fix (EN):</b> exit the game, delete the file ");
    add(szMOTD, charsmax(szMOTD), szFile);
    add(szMOTD, charsmax(szMOTD), " from your cstrike folder, disable Steam Cloud sync for CS 1.6 (Steam -> Properties -> General), verify file integrity, reconnect.<br><br>");
    add(szMOTD, charsmax(szMOTD), "<font color=^"#88aadd^">If the file is your personal config (userconfig.cfg), let the admin know: such files legitimately vary from user to user and should not be included in the check list</font>");
    add(szMOTD, charsmax(szMOTD), szFoot);

    show_motd(id, szMOTD, "RePruning: fix guide");
    Pruning_Log(LOG_DEBUG, "fix guide sent to client #%d for file ^"%s^"", get_user_userid(id), szFile);
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

public ConCmd_Status(id)
{
    new szMap[48], szUptime[16];
    get_mapname(szMap, charsmax(szMap));

    new iUp = get_systime() - g_iStartSystime;
    formatex(szUptime, charsmax(szUptime), "%02d:%02d:%02d", iUp / 3600, (iUp % 3600) / 60, iUp % 60);

    console_print(id, "--------------- RePruning v%s ---------------", VERSION);
    console_print(id, "Map: %s | Uptime: %s | Rounds: %d", szMap, szUptime, g_iRounds);
    console_print(id, "Modules: buy=%d buyzone=%d money=%d plantzone=%d c4give=%d c4remove=%d",
        get_pcvar_num(g_pBuy), get_pcvar_num(g_pBuyZoneRemove), get_pcvar_num(g_pMoney),
        get_pcvar_num(g_pPlantZone), get_pcvar_num(g_pBombGive), get_pcvar_num(g_pBombRemove));
    console_print(id, "         icons=%d radio=%d winsnd=%d hostages=%d vip=%d fx=%d decals=%d",
        get_pcvar_num(g_pIcons), get_pcvar_num(g_pRadio), get_pcvar_num(g_pRadioWinSounds),
        get_pcvar_num(g_pHostages), get_pcvar_num(g_pVip), get_pcvar_num(g_pEffects),
        get_pcvar_num(g_pDecals));
    console_print(id, "         corpses=%d drops=%d console=%d hints=%d files=%d",
        get_pcvar_num(g_pCorpses), get_pcvar_num(g_pDropWeapons), get_pcvar_num(g_pConsole),
        get_pcvar_num(g_pHints), get_pcvar_num(g_pFiles));
    console_print(id, "Files: active checks=%d | clients=%d | mismatches=%d | kicks=%d | bans=%d",
        g_iFileChecks, g_iClientsConnected, g_iMismatchTotal, g_iKickTotal, g_iBanTotal);
    console_print(id, "Errors total: %d | Log level: %d | Log file: %s",
        g_iErrCount, get_pcvar_num(g_pLogLevel), g_szLogPath);
    console_print(id, "-------------------------------------------------------------");
    return PLUGIN_HANDLED;
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
}

public ConCmd_Reload(id)
{
    new szCfgDir[96], szCfgFile[128];
    get_localinfo("amxx_configsdir", szCfgDir, charsmax(szCfgDir));
    formatex(szCfgFile, charsmax(szCfgFile), "%s/pruning.cfg", szCfgDir);

    if (file_exists(szCfgFile)) {
        server_cmd("exec %s", szCfgFile);
        server_exec();
    }

    PerformCleanup();
    ApplyFileChecks();
    Task_ScanDrops();

    console_print(id, "[RePruning] Config loaded...");

    new szName[32];
    if (id > 0 && is_user_connected(id))
        get_user_name(id, szName, charsmax(szName));

    Pruning_Log(LOG_INFO, "config reloaded by admin %s (#%d)", szName,
        (id > 0 && is_user_connected(id)) ? get_user_userid(id) : 0);
    return PLUGIN_HANDLED;
}
