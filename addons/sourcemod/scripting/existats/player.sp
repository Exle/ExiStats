#include <sourcemod>

enum ExiPlayer_Info
{
	EP_Id,
	String:EP_Name[MAX_NAME_LENGTH],
	String:EP_Auth[32],
	EP_Exp,
	EP_GameTime,
	EP_LastVisit,
	EP_StartGameTime
};

any ExiPlayer[MAXPLAYERS + 1][ExiPlayer_Info];

Handle	ExiForward_OnClienInfoReceived,
		ExiForward_OnClienExperienceUpdated,
		ExiForward_OnClienNameUpdated;

void ExiPlayer_OnPluginStart()
{
	ExiForward_OnClienInfoReceived		= CreateGlobalForward("ExiStats_OnClienInfoReceived",		ET_Ignore, Param_Cell, Param_Cell, Param_String, Param_Cell, Param_Cell, Param_Cell);
	ExiForward_OnClienExperienceUpdated	= CreateGlobalForward("ExiStats_OnClienExperienceUpdated",	ET_Ignore, Param_Cell, Param_Cell, Param_CellByRef);
	ExiForward_OnClienNameUpdated		= CreateGlobalForward("ExiStats_OnClienNameUpdated",		ET_Ignore, Param_Cell, Param_String, Param_String);
}

void ExiPlayer_OnPluginEnd()
{
	delete ExiForward_OnClienInfoReceived;
	delete ExiForward_OnClienExperienceUpdated;
	delete ExiForward_OnClienNameUpdated;
}

public void OnClientAuthorized(int client, const char[] auth)
{
	ExiPlayer[client][EP_Id] = ExiPlayer[client][EP_Exp] = ExiPlayer[client][EP_GameTime] = ExiPlayer[client][EP_LastVisit] = ExiPlayer[client][EP_StartGameTime] = 0;

	if (IsFakeClient(client) || !ExiVar_Started)
	{
		return;
	}

	GetClientName(client, ExiPlayer[client][EP_Name], MAX_NAME_LENGTH);
	GetClientAuthId(client, AuthId_Steam3, ExiPlayer[client][EP_Auth], 32);

	ExiDB_OnClientAuthorized(client, ExiPlayer[client][EP_Auth]);
}

public void OnClientDisconnect(int client)
{
	if (IsFakeClient(client) || !ExiVar_Started)
	{
		return;
	}

	ExiDB_UpdateAllValues(client);
}

void ExiPlayer_OnClienInfoReceived(int client)
{
	ExiPlayer[client][EP_StartGameTime] = GetTime();

	Call_StartForward(ExiForward_OnClienInfoReceived);
	Call_PushCell(client);
	Call_PushCell(ExiPlayer[client][EP_Id]);
	Call_PushString(ExiPlayer[client][EP_Auth]);
	Call_PushCell(ExiPlayer[client][EP_Exp]);
	Call_PushCell(ExiPlayer[client][EP_GameTime]);
	Call_PushCell(ExiPlayer[client][EP_LastVisit]);
	Call_Finish();
}

int ExiPlayer_GetClientById(int id)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i) || IsFakeClient(i) || id != ExiPlayer[i][EP_Id])
		{
			continue;
		}

		return i;
	}

	return 0;
}

int ExiPlayer_GetClientByAuth(const char[] auth)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i) || IsFakeClient(i) || strcmp(auth, ExiPlayer[i][EP_Auth]) != 0)
		{
			continue;
		}

		return i;
	}

	return 0;
}

// SET FUNCTIONS
bool ExiPlayer_SetValues(ExiPlayer_Info param, int client, int value, bool immediately = false)
{
	if (!(0 < client < MaxClients) || !IsClientInGame(client) || IsFakeClient(client))
	{
		return false;
	}

	if (param == EP_Exp)
	{
		Call_StartForward(ExiForward_OnClienExperienceUpdated);
		Call_PushCell(client);
		Call_PushCell(ExiPlayer[client][param]);
		Call_PushCellRef(value);
		Call_Finish();
	}

	ExiPlayer[client][param] = value;

	if ((!ExiVar_Update || immediately) && ExiVar_Started)
	{
		ExiDB_SetValues(param, client, ExiPlayer[client][param]);
	}

	return true;
}

bool ExiPlayer_SetName(int client, const char[] value, bool immediately = false)
{
	if (!(0 < client < MaxClients) || !IsClientInGame(client) || IsFakeClient(client))
	{
		return false;
	}

	Call_StartForward(ExiForward_OnClienNameUpdated);
	Call_PushCell(client);
	Call_PushString(ExiPlayer[client][EP_Name]);
	Call_PushString(value);
	Call_Finish();

	strcopy(ExiPlayer[client][EP_Name], MAX_NAME_LENGTH, value);

	if ((!ExiVar_Update || immediately) && ExiVar_Started)
	{
		ExiDB_SetString(EP_Name, client, ExiPlayer[client][EP_Name]);
	}

	return true;
}

// GET FUNCTIONS
int ExiPlayer_GetValues(ExiPlayer_Info param, int client)
{
	if (!(0 < client < MaxClients) || !IsClientInGame(client) || IsFakeClient(client) || !ExiVar_Started)
	{
		return -1;
	}

	return ExiPlayer[client][param];
}

int ExiPlayer_GetString(ExiPlayer_Info param, int client, char[] buffer, int maxlength)
{
	if (!(0 < client < MaxClients) || !IsClientInGame(client) || IsFakeClient(client) || !ExiVar_Started)
	{
		return -1;
	}

	int cells;
	if (param == EP_Name)
	{
		cells = strcopy(buffer, maxlength, ExiPlayer[client][EP_Name]);
	}
	else
	{
		cells = strcopy(buffer, maxlength, ExiPlayer[client][EP_Auth]);
	}

	return cells;
}