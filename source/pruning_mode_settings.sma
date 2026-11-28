//Name: RePruning Mode Settings v0.0.6
//Author: DeRoPEN_DEv
//Platform: ReHLDS
//Mandatory: ReHLDS 3.15.0.896-dev + ReAPI v5.29.0.359-dev + Metamod-R 1.3.0.149 + AMXModX 1.10+ + ReGameDLL 5.30.0.814-dev
//Description: Mode presets for RePruning: apply ZM / DeathRun / CSDM / DM / Public / Lasers module sets with one cvar
//Reminder: List this plugin AFTER repruning.amxx in plugins.ini; presets are configs/pruning_mode_<name>.cfg
//Sites: github.com/DeRoPEN31 and deropen.fun

#include <amxmodx>

#define PLUGIN  "RePruning Mode Settings"
#define VERSION "v0.0.6"
#define AUTHOR  "DeRoPEN_DEv"

new g_pMode;
new g_pAuto;
new g_iModes;

// Built-in map prefix -> preset table, the longest matching prefix wins. The server owner can
// add own rules in configs/pruning_mode_settings.cfg with lines: map <prefix> <preset>.
static const g_szMapPrefix[][] = { "ze_", "zm_", "dr_", "deathrun_", "dm_", "csdm_", "de_", "cs_", "fy_", "as_" };
static const g_szMapPreset[][] = { "zm",  "zm",  "deathrun", "deathrun", "dm",  "csdm",  "pub", "pub", "pub", "pub" };

new g_szCustPrefix[32][32];
new g_szCustPreset[32][32];
new g_iCustRules;

// The state of the actually applied mode: what really ran on this map and where it came
// from. The pruning_mode cvar alone does not show it — with auto mode the applied preset
// is picked by the map prefix and may differ from the configured cvar value.
new g_szAppliedMode[32];
new bool:g_bAppliedAuto;
new g_szAutoPrefix[32];

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR);

    register_cvar("repruning_mode_version", VERSION, FCVAR_SERVER | FCVAR_SPONLY);

    g_pMode = register_cvar("pruning_mode", "");
    g_pAuto = register_cvar("pruning_mode_auto", "1");

    register_concmd("amx_pruning_mode",        "ConCmd_Mode",       ADMIN_CFG, " - show the active mode, the auto state and available presets");
    register_concmd("amx_pruning_mode_reload", "ConCmd_ModeReload", ADMIN_CFG, " - re-read pruning_mode_settings.cfg and re-apply the mode");

    register_library("repruning_mode");
}

public plugin_cfg()
{
    // Applied on the next frame like the core plugin: the preset exec flushes the engine
    // command buffer with server_exec(), which must not happen inside the map-load frame.
    set_task(0.1, "Task_ModeCfg");
}

public Task_ModeCfg()
{
    LoadModeSettings();
    DiscoverModes();
    ApplyMode();
}

// The settings file is parsed, not engine-executed: only pruning_mode, pruning_mode_auto and
// map <prefix> <preset> commands are accepted. This keeps a "map" line from being mistaken for
// the engine level-change command and lets the same file carry the map prefix rules.
LoadModeSettings()
{
    g_iCustRules = 0;

    new szCfgDir[96], szPath[160];
    get_localinfo("amxx_configsdir", szCfgDir, charsmax(szCfgDir));
    formatex(szPath, charsmax(szPath), "%s/pruning_mode_settings.cfg", szCfgDir);

    new fp = fopen(szPath, "rt");
    if (!fp) {
        // The settings file is the single source of truth: manual cvar edits from the
        // previous map must not leak, so the registered defaults are restored.
        set_pcvar_string(g_pMode, "");
        set_pcvar_num(g_pAuto, 1);
        server_print("[RePruning Mode] configs/pruning_mode_settings.cfg not found — pruning_mode and pruning_mode_auto are reset to their defaults");
        return;
    }

    new szLine[192], szKey[32], szArg1[48], szArg2[48];
    new bModeLine, bAutoLine;

    while (!feof(fp)) {
        fgets(fp, szLine, charsmax(szLine));
        trim(szLine);

        if (!szLine[0] || szLine[0] == ';' || (szLine[0] == '/' && szLine[1] == '/'))
            continue;

        if (parse(szLine, szKey, charsmax(szKey), szArg1, charsmax(szArg1), szArg2, charsmax(szArg2)) < 2)
            continue;

        if (equal(szKey, "pruning_mode")) {
            set_pcvar_string(g_pMode, szArg1);
            bModeLine = true;
        } else if (equal(szKey, "pruning_mode_auto")) {
            set_pcvar_string(g_pAuto, szArg1);
            bAutoLine = true;
        } else if (equal(szKey, "map")) {
            if (!szArg2[0] || !ModeNameValid(szArg1) || !ModeNameValid(szArg2)) {
                log_amx("[RePruning Mode] bad map rule ^"%s^" — expected: map <prefix> <preset>", szLine);
                continue;
            }

            if (g_iCustRules >= 32) {
                log_amx("[RePruning Mode] map rule limit (32) reached — ^"%s^" ignored", szLine);
                continue;
            }

            MapToLower(szArg1, szArg1, charsmax(szArg1));
            copy(g_szCustPrefix[g_iCustRules], 31, szArg1);
            copy(g_szCustPreset[g_iCustRules], 31, szArg2);
            g_iCustRules++;
        }
    }

    fclose(fp);

    // An option the settings file does not define is restored to its default on every load,
    // so a value set by hand mid-map does not silently survive into the next maps.
    if (!bModeLine)
        set_pcvar_string(g_pMode, "");
    if (!bAutoLine)
        set_pcvar_num(g_pAuto, 1);

    if (g_iCustRules)
        log_amx("[RePruning Mode] %d map prefix rule(s) loaded from pruning_mode_settings.cfg", g_iCustRules);
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

MapToLower(const szIn[], szOut[], iLen)
{
    new i;

    for (i = 0; szIn[i] != EOS && i < iLen - 1; i++)
        szOut[i] = tolower(szIn[i]);

    szOut[i] = EOS;
}

// Picks the preset for the current map by prefix. Returns 1 and fills szPick/szPrefix when a
// prefix matched, 0 otherwise (the static pruning_mode is used then).
AutoModeSelect(szPick[], iPickLen, szPrefix[], iPrefixLen)
{
    new szMap[48], szLow[48];
    get_mapname(szMap, charsmax(szMap));
    MapToLower(szMap, szLow, charsmax(szLow));

    new iBestLen, iSource; // 0 = built-in table, 1 = rule from pruning_mode_settings.cfg

    for (new i = 0; i < sizeof(g_szMapPrefix); i++) {
        new iLen = strlen(g_szMapPrefix[i]);

        if (iLen > iBestLen && contain(szLow, g_szMapPrefix[i]) == 0) {
            iBestLen = iLen;
            iSource = 0;
            copy(szPick, iPickLen, g_szMapPreset[i]);
            copy(szPrefix, iPrefixLen, g_szMapPrefix[i]);
        }
    }

    for (new i = 0; i < g_iCustRules; i++) {
        new iLen = strlen(g_szCustPrefix[i]);

        // >= so a config rule overrides a built-in of the same length
        if (iLen > 0 && iLen >= iBestLen && contain(szLow, g_szCustPrefix[i]) == 0) {
            iBestLen = iLen;
            iSource = 1;
            copy(szPick, iPickLen, g_szCustPreset[i]);
            copy(szPrefix, iPrefixLen, g_szCustPrefix[i]);
        }
    }

    if (!iBestLen)
        return 0;

    server_print("[RePruning Mode] map ^"%s^" matched the %s prefix ^"%s^"", szMap, iSource ? "config" : "built-in", szPrefix);
    log_amx("[RePruning Mode] auto mode ^"%s^" selected by the %s map prefix ^"%s^"", szPick, iSource ? "config" : "built-in", szPrefix);
    return 1;
}

ApplyMode()
{
    g_szAppliedMode[0] = 0;
    g_bAppliedAuto = false;
    g_szAutoPrefix[0] = 0;

    new szMode[32];
    get_pcvar_string(g_pMode, szMode, charsmax(szMode));
    trim(szMode);

    if (get_pcvar_num(g_pAuto)) {
        new szPick[32], szPrefix[32];

        if (AutoModeSelect(szPick, charsmax(szPick), szPrefix, charsmax(szPrefix))) {
            copy(szMode, charsmax(szMode), szPick);
            g_bAppliedAuto = true;
            copy(g_szAutoPrefix, charsmax(g_szAutoPrefix), szPrefix);
        }
    }

    if (!szMode[0]) {
        g_bAppliedAuto = false;
        g_szAutoPrefix[0] = 0;
        server_print("[RePruning Mode] pruning_mode is empty — nothing applied");
        return;
    }

    if (!ModeNameValid(szMode)) {
        g_bAppliedAuto = false;
        g_szAutoPrefix[0] = 0;
        server_print("[RePruning Mode] invalid mode name ^"%s^" (allowed: a-z 0-9 _)", szMode);
        log_amx("[RePruning Mode] rejected invalid mode name ^"%s^"", szMode);
        return;
    }

    if (equal(szMode, "custom")) {
        g_bAppliedAuto = false;
        g_szAutoPrefix[0] = 0;
        server_print("[RePruning Mode] custom mode — no preset applied (manage configs/pruning.cfg manually)");
        return;
    }

    new szCfgDir[96], szCfgFile[160];
    get_localinfo("amxx_configsdir", szCfgDir, charsmax(szCfgDir));
    formatex(szCfgFile, charsmax(szCfgFile), "%s/pruning_mode_%s.cfg", szCfgDir, szMode);

    if (!file_exists(szCfgFile)) {
        g_bAppliedAuto = false;
        g_szAutoPrefix[0] = 0;
        server_print("[RePruning Mode] preset %s not found — nothing applied", szCfgFile);
        log_amx("[RePruning Mode] preset ^"%s^" not found", szCfgFile);
        return;
    }

    server_cmd("exec %s", szCfgFile);
    server_exec();

    copy(g_szAppliedMode, charsmax(g_szAppliedMode), szMode);

    server_print("[RePruning Mode] mode ^"%s^" applied (%s)", szMode, szCfgFile);
    log_amx("[RePruning Mode] mode ^"%s^" applied", szMode);
}

public ConCmd_Mode(id)
{
    new szMode[32];
    get_pcvar_string(g_pMode, szMode, charsmax(szMode));

    console_print(id, "----------- RePruning Mode Settings v%s -----------", VERSION);
    console_print(id, "Configured mode: %s", szMode[0] ? szMode : "(empty)");
    console_print(id, "Active mode: %s", g_szAppliedMode[0] ? g_szAppliedMode : "(nothing applied)");
    if (g_bAppliedAuto)
        console_print(id, "Auto: preset ^"%s^" selected by the map prefix ^"%s^"", g_szAppliedMode, g_szAutoPrefix);
    console_print(id, "Auto mode by map prefix: %s (pruning_mode_auto)", get_pcvar_num(g_pAuto) ? "ON" : "OFF");
    console_print(id, "Map prefixes: %d built-in + %d from the settings file", sizeof(g_szMapPrefix), g_iCustRules);
    console_print(id, "Preset files found in configs/: %d", g_iModes);
    console_print(id, "Shipped presets: zm, deathrun, csdm, dm, pub, lasers");
    console_print(id, "Custom: set pruning_mode ^"custom^" and manage pruning.cfg by hand");
    console_print(id, "Own preset: create configs/pruning_mode_<name>.cfg and set pruning_mode ^"<name>^"");
    console_print(id, "Own map rule: add ^"map <prefix> <preset>^" to pruning_mode_settings.cfg");
    console_print(id, "Reload: amx_pruning_mode_reload");
    console_print(id, "----------------------------------------------------");
    return PLUGIN_HANDLED;
}

public ConCmd_ModeReload(id)
{
    LoadModeSettings();
    DiscoverModes();
    ApplyMode();

    console_print(id, "[RePruning Mode] settings reloaded, active mode: %s%s",
        g_szAppliedMode[0] ? g_szAppliedMode : "(nothing applied)",
        g_bAppliedAuto ? " (auto by map prefix)" : "");
    return PLUGIN_HANDLED;
}
