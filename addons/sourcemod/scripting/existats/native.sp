//#include <sourcemod>

void ExiNative_AskPluginLoad2()
{
	CreateNative("ExiStats_Started",				ExiNative_Started);

	CreateNative("ExiStats_GetDatabase",			ExiNative_GetDatabase);
	CreateNative("ExiStats_GetDatabaseType",		ExiNative_GetDatabaseType);

	CreateNative("ExiStats_Message",				ExiNative_Message);
	CreateNative("ExiStats_MessageAll",				ExiNative_MessageAll);

	CreateNative("ExiStats_GetClientId",			ExiNative_GetClientId);
	CreateNative("ExiStats_GetClientAuth",			ExiNative_GetClientAuth);
	CreateNative("ExiStats_GetClientName",			ExiNative_GetClientName);

	CreateNative("ExiStats_GetClientById",			ExiNative_GetClientById);
	CreateNative("ExiStats_GetClientByAuth",		ExiNative_GetClientByAuth);

	CreateNative("ExiStats_SetClientExperience",	ExiNative_SetClientExperience);
	CreateNative("ExiStats_SetClientGameTime",		ExiNative_SetClientGameTime);
	CreateNative("ExiStats_SetClientLastVisit",		ExiNative_SetClientLastVisit);

	CreateNative("ExiStats_GetClientExperience",	ExiNative_GetClientExperience);
	CreateNative("ExiStats_GetClientGameTime",		ExiNative_GetClientGameTime);
	CreateNative("ExiStats_GetClientLastVisit",		ExiNative_GetClientLastVisit);

	//CreateNative("ExiStats_ReDisplayAdminMenu",		ExiNative_ReDisplayAdminMenu);
	//CreateNative("ExiStats_ReDisplayClientMenu",	ExiNative_ReDisplayClientMenu);

	//CreateNative("ExiStats_AddToAdminMenu",			ExiNative_AddToAdminMenu);
	//CreateNative("ExiStats_AddToClientMenu",		ExiNative_AddToClientMenu);

	//CreateNative("ExiStats_AddedToAdminMenu",		ExiNative_AddedToAdminMenu);
	//CreateNative("ExiStats_AddedToClientMenu",		ExiNative_AddedToClientMenu);

	//CreateNative("ExiStats_UnRegisterMe",			ExiNative_UnRegisterMe);
}

// Main
public int ExiNative_Started(Handle plugin, int numParams)
{
	return ExiVar_Started;
}

public int ExiNative_GetDatabase(Handle plugin, int numParams)
{
	return view_as<int>(CloneHandle(ExiDB, plugin));
}

public int ExiNative_GetDatabaseType(Handle plugin, int numParams)
{
	return view_as<int>(ExiDB_type);
}

// Messages
public int ExiNative_Message(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);

	if (!IsClientInGame(client) || IsFakeClient(client))
	{
		return;
	}

	SetGlobalTransTarget(client);

	char buffer[MAX_BUFFER_LENGTH];
	GetNativeString(2, buffer, MAX_BUFFER_LENGTH);
	FormatNativeString(0, 2, 3, MAX_BUFFER_LENGTH, _, buffer);

	ExiFunction_SendMessage(client, buffer);
}

public int ExiNative_MessageAll(Handle plugin, int numParams)
{
	char buffer[MAX_BUFFER_LENGTH];

	for (int client = 1; client <= MaxClients; client++)
	{
		if (!IsClientInGame(client) || IsFakeClient(client))
		{
			continue;
		}

		SetGlobalTransTarget(client);

		GetNativeString(1, buffer, MAX_BUFFER_LENGTH);
		FormatNativeString(0, 1, 2, MAX_BUFFER_LENGTH, _, buffer);

		ExiFunction_SendMessage(client, buffer);
	}
}

// OTHER
public int ExiNative_GetClientById(Handle plugin, int numParams)
{
	return ExiPlayer_GetClientById(GetNativeCell(1));
}

public int ExiNative_GetClientByAuth(Handle plugin, int numParams)
{
	char buffer[32];
	GetNativeString(1, buffer, 32);
	return ExiPlayer_GetClientByAuth(buffer);
}

// SET
public int ExiNative_SetClientExperience(Handle plugin, int numParams)
{
	return view_as<int>(ExiPlayer_SetValues(EP_Exp, GetNativeCell(1), GetNativeCell(2), GetNativeCell(3)));
}

public int ExiNative_SetClientGameTime(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	return view_as<int>(ExiPlayer_SetValues(EP_GameTime, client, ExiPlayer[client][EP_GameTime] - ExiPlayer[client][EP_StartGameTime] + (ExiPlayer[client][EP_StartGameTime] = GetTime()), GetNativeCell(2)));
}

public int ExiNative_SetClientLastVisit(Handle plugin, int numParams)
{
	return view_as<int>(ExiPlayer_SetValues(EP_LastVisit, GetNativeCell(1), GetTime(), GetNativeCell(2)));
}

// GET
public int ExiNative_GetClientId(Handle plugin, int numParams)
{
	return ExiPlayer_GetValues(EP_Id, GetNativeCell(1));
}

public int ExiNative_GetClientAuth(Handle plugin, int numParams)
{
	char buffer[32];
	int cells = ExiPlayer_GetString(EP_Auth, GetNativeCell(1), buffer, 32);

	SetNativeString(2, buffer, GetNativeCell(3));

	return cells;
}

public int ExiNative_GetClientName(Handle plugin, int numParams)
{
	char buffer[32];
	int cells = ExiPlayer_GetString(EP_Name, GetNativeCell(1), buffer, 32);

	SetNativeString(2, buffer, GetNativeCell(3));

	return cells;
}

public int ExiNative_GetClientExperience(Handle plugin, int numParams)
{
	return ExiPlayer_GetValues(EP_Exp, GetNativeCell(1));
}

public int ExiNative_GetClientGameTime(Handle plugin, int numParams)
{
	return ExiPlayer_GetValues(EP_GameTime, GetNativeCell(1));
}

public int ExiNative_GetClientLastVisit(Handle plugin, int numParams)
{
	return ExiPlayer_GetValues(EP_LastVisit, GetNativeCell(1));
}