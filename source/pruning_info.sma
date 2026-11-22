//Name: RePruning Info v0.0.4
//Author: DeRoPEN_DEv
//Platform: ReHLDS
//Mandatory: ReHLDS 3.15.0.896-dev + Metamod-R 1.3.0.149 + AMXModX 1.10+; optional add-on for repruning.amxx
//Description: Standalone pruning_info / amx_pruning_status report command — reads state only, no hooks, no tasks; safe to enable or remove
//Reminder: load it AFTER repruning.amxx in plugins.ini; without the core plugin it refuses to load instead of half-working
//Sites: github.com/DeRoPEN31 and deropen.fun

#include <amxmodx>
#include <repruning>

public plugin_init()
{
    register_plugin("RePruning Info", "0.0.4", "DeRoPEN_DEv");

    register_concmd("pruning_info", "ConCmd_Info", ADMIN_CFG, " - full RePruning state: modules, file checks, ban list, validation");
    register_concmd("amx_pruning_status", "ConCmd_Info", ADMIN_CFG, " - alias of pruning_info");
}

public ConCmd_Info(id)
{
    new pVersion = get_cvar_pointer("repruning_version");
    if (!pVersion) {
        console_print(id, "[RePruning Info] repruning.amxx is not loaded — enable the core plugin first");
        return PLUGIN_HANDLED;
    }

    new szReport[1536];
    if (!repruning_server_info(szReport, charsmax(szReport))) {
        console_print(id, "[RePruning Info] core plugin did not return the report");
        return PLUGIN_HANDLED;
    }

    new iTotal = strlen(szReport), iStart, iEnd;
    while (iStart < iTotal) {
        iEnd = iStart;
        while (iEnd < iTotal && szReport[iEnd] != 10) // 10 = ^n
            iEnd++;
        szReport[iEnd] = 0;
        console_print(id, "%s", szReport[iStart]);
        iStart = iEnd + 1;
    }

    return PLUGIN_HANDLED;
}
