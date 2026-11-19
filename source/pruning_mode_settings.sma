//Name: RePruning Mode Settings v0.0.3 V1
//Author: DeRoPEN_DEv
//Platform: ReHLDS
//Mandatory: ReHLDS 3.15.0.896-dev + ReAPI v5.29.0.359-dev + Metamod-R 1.3.0.149 + AMXModX 1.10+ + ReGameDLL 5.30.0.814-dev
//Description: Mode presets for RePruning: apply ZM / DeathRun / CSDM / DM / Public / Lasers module sets with one cvar
//Reminder: List this plugin AFTER repruning.amxx in plugins.ini; active mode is set in configs/pruning_mode_settings.cfg
//Sites: github.com/DeRoPEN31 and deropen.fun

#include <amxmodx>

#define PLUGIN  "RePruning Mode Settings"
#define VERSION "v0.0.3 V1"
#define AUTHOR  "DeRoPEN_DEv"

new g_pMode;
new g_iModes;

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR);

    register_cvar("repruning_mode_version", VERSION, FCVAR_SERVER | FCVAR_SPONLY);

    g_pMode = register_cvar("pruning_mode", "");

    register_concmd("amx_pruning_mode",        "ConCmd_Mode",       ADMIN_CFG, " - show the active mode and available presets");
    register_concmd("amx_pruning_mode_reload", "ConCmd_ModeReload", ADMIN_CFG, " - re-read pruning_mode_settings.cfg and re-apply the mode");

    register_library("repruning_mode");
}

public plugin_cfg()
{
    ExecModeSettings();
    DiscoverModes();
    ApplyMode();
}

ExecModeSettings()
{
    new szCfgDir[96], szCfgFile[128];
    get_localinfo("amxx_configsdir", szCfgDir, charsmax(szCfgDir));
    formatex(szCfgFile, charsmax(szCfgFile), "%s/pruning_mode_settings.cfg", szCfgDir);

    if (file_exists(szCfgFile)) {
        server_cmd("exec %s", szCfgFile);
        server_exec();
    } else {
        server_print("[RePruning Mode] configs/pruning_mode_settings.cfg not found — pruning_mode stays on its default value");
    }
}

DiscoverModes()
{
    g_iModes = 0;

    new szCfgDir[96], szFile[64];
    get_localinfo("amxx_configsdir", szCfgDir, charsmax(szCfgDir));

    new dp = open_dir(szCfgDir, szFile, charsmax(szFile));
    if (!dp)
        return;

    while (next_file(dp, szFile, charsmax(szFile))) {
        if (containi(szFile, "pruning_mode_") != 0)
            continue;

        new szName[48];
        copy(szName, charsmax(szName), szFile[13]);

        new iLen = strlen(szName);
        if (iLen <= 4 || !equal(szName[iLen - 4], ".cfg"))
            continue;

        szName[iLen - 4] = EOS;
        if (equal(szName, "settings"))
            continue;

        g_iModes++;
    }
    close_dir(dp);
}

ModeNameValid(const szName[])
{
    for (new i = 0; szName[i] != EOS; i++) {
        new c = szName[i];
        if (c != '_' && (c < 'a' || c > 'z') && (c < '0' || c > '9'))
            return false;
    }
    return true;
}

ApplyMode()
{
    new szMode[32];
    get_pcvar_string(g_pMode, szMode, charsmax(szMode));
    trim(szMode);

    if (!szMode[0]) {
        server_print("[RePruning Mode] pruning_mode is empty — nothing applied");
        return;
    }

    if (!ModeNameValid(szMode)) {
        server_print("[RePruning Mode] invalid mode name ^"%s^" (allowed: a-z 0-9 _)", szMode);
        log_amx("[RePruning Mode] rejected invalid mode name ^"%s^"", szMode);
        return;
    }

    if (equal(szMode, "custom")) {
        server_print("[RePruning Mode] custom mode — no preset applied (manage configs/pruning.cfg manually)");
        return;
    }

    new szCfgDir[96], szCfgFile[160];
    get_localinfo("amxx_configsdir", szCfgDir, charsmax(szCfgDir));
    formatex(szCfgFile, charsmax(szCfgFile), "%s/pruning_mode_%s.cfg", szCfgDir, szMode);

    if (!file_exists(szCfgFile)) {
        server_print("[RePruning Mode] preset %s not found — nothing applied", szCfgFile);
        log_amx("[RePruning Mode] preset ^"%s^" not found", szCfgFile);
        return;
    }

    server_cmd("exec %s", szCfgFile);
    server_exec();

    server_print("[RePruning Mode] mode ^"%s^" applied (%s)", szMode, szCfgFile);
    log_amx("[RePruning Mode] mode ^"%s^" applied", szMode);
}

public ConCmd_Mode(id)
{
    new szMode[32];
    get_pcvar_string(g_pMode, szMode, charsmax(szMode));

    console_print(id, "----------- RePruning Mode Settings v%s -----------", VERSION);
    console_print(id, "Active mode: %s", szMode[0] ? szMode : "(empty)");
    console_print(id, "Preset files found in configs/: %d", g_iModes);
    console_print(id, "Shipped presets: zm, deathrun, csdm, dm, pub, lasers");
    console_print(id, "Custom: set pruning_mode ^"custom^" and manage pruning.cfg by hand");
    console_print(id, "Own preset: create configs/pruning_mode_<name>.cfg and set pruning_mode ^"<name>^"");
    console_print(id, "Reload: amx_pruning_mode_reload");
    console_print(id, "----------------------------------------------------");
    return PLUGIN_HANDLED;
}

public ConCmd_ModeReload(id)
{
    ExecModeSettings();
    DiscoverModes();
    ApplyMode();

    new szMode[32];
    get_pcvar_string(g_pMode, szMode, charsmax(szMode));
    console_print(id, "[RePruning Mode] settings reloaded, active mode: %s", szMode[0] ? szMode : "(empty)");
    return PLUGIN_HANDLED;
}
