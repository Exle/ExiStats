#include <sourcemod>
#include <existats>

#pragma semicolon 1
#pragma newdecls required

bool ExiVar_Started;

EngineVersion ExiEngine;

#include "existats/convars.sp"
#include "existats/player.sp"
#include "existats/db.sp"
#include "existats/functions.sp"
#include "existats/commands.sp"
#include "existats/native.sp"
#include "existats/events.sp"

public Plugin myinfo =
{
	name		= EXISTATS_NAME ... " Core",
	author		= EXISTATS_AUTHOR,
	description	= EXISTATS_DESCRIPTION,
	version		= EXISTATS_VERSION,
	url			= EXISTATS_URL
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	ExiNative_AskPluginLoad2();

	RegPluginLibrary("existats");

	return APLRes_Success;
}

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("existats.phrases");

	ExiConVar_OnPluginStart();
	ExiDB_OnPluginStart();
	ExiCmd_OnPluginStart();
	ExiPlayer_OnPluginStart();
	ExiEvent_OnPluginStart();

	ExiEngine = GetEngineVersion();
}

public void OnPluginEnd()
{
	ExiDB_OnPluginEnd();
	ExiPlayer_OnPluginEnd();
}

void Exi_State(bool start = true)
{
	if ((ExiVar_Started = start))
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i))
			{
				continue;
			}

			OnClientAuthorized(i, "");
		}
	}
}