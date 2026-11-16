#//Name: RePruning v0.0.1 Alpha 
#//Author: DeRoPEN_DEv
#//Platforms: HLDS and ReHLDS
#//Mandatory: ReHLDS 3.15.0.896-dev + ReAPI v5.29.0.359-dev + Metamod-R 1.3.0.149 + AMXModX 1.10+ + ReGameDLL 5.30.0.814-dev
#//Description: A plugin for removing, cleaning up, or disabling various features on CS 1.6 servers
#//Reminder: Use 0 to disable the feature, and 1 to enable it
#//Sites: github.com/DeRoPEN31 and deropen.fun

#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <reapi>

#define PLUGIN  "RePruning"
#define VERSION "0.1.0 Alpha"
#define AUTHOR  "DeRoPEN_DEv"

#define DROP_SCAN_PERIOD    2.0

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
}

public plugin_cfg()
{
    new szCfgDir[96], szCfgFile[128];
    get_localinfo("amxx_configsdir", szCfgDir, charsmax(szCfgDir));
    formatex(szCfgFile, charsmax(szCfgFile), "%s/pruning.cfg", szCfgDir);

    if (file_exists(szCfgFile)) {
        server_cmd("exec %s", szCfgFile);
        server_exec();
    } else {
        server_print("[RePruning] WARNING: configs/pruning.cfg not found, using defaults");
    }

    PerformCleanup();
    ApplyFileChecks();

    set_task(DROP_SCAN_PERIOD, "Task_ScanDrops", _, _, _, "b");

    server_print("[RePruning] v%s loaded", VERSION);
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
    if (!get_pcvar_num(g_pFiles))
        return;

    new szFile[128];
    get_localinfo("amxx_configsdir", szFile, charsmax(szFile));
    add(szFile, charsmax(szFile), "/pruning_files.cfg");

    if (!file_exists(szFile)) {
        server_print("[RePruning] WARNING: pruning_files=1, but configs/pruning_files.cfg not found");
        return;
    }

    new fp = fopen(szFile, "rt");
    if (!fp)
        return;

    new szLine[256], szCmd[32], szPath[192];
    new iCount = 0;

    while (!feof(fp)) {
        fgets(fp, szLine, charsmax(szLine));
        trim(szLine);

        if (!szLine[0] || szLine[0] == ';' || (szLine[0] == '/' && szLine[1] == '/'))
            continue;

        if (parse(szLine, szCmd, charsmax(szCmd), szPath, charsmax(szPath)) < 2)
            continue;

        if (!equal(szCmd, "exactfile"))
            continue;

        force_unmodified(force_exactfile, { 0, 0, 0 }, { 0, 0, 0 }, szPath);
        iCount++;
        server_print("[RePruning] file check active: %s", szPath);
    }

    fclose(fp);
    server_print("[RePruning] file checks active: %d", iCount);
}

public inconsistent_file(id, const filename[], reason[64])
{
    new szAuth[36];
    get_user_authid(id, szAuth, charsmax(szAuth));

    log_amx("[RePruning] inconsistent file on client #%d (%s): %s (%s)",
        is_user_connected(id) ? get_user_userid(id) : 0, szAuth, filename, reason);

    if (get_pcvar_num(g_pFilesKick) && is_user_connected(id))
        server_cmd("kick #%d ^"file mismatch: %s^"", get_user_userid(id), filename);
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
    log_amx("[RePruning] config reloaded by admin #%d", (id > 0 && is_user_connected(id)) ? get_user_userid(id) : 0);
    return PLUGIN_HANDLED;
}
