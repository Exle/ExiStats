void ExiNative_AskPluginLoad2()
{
	CreateNative("ExiStats_Started",		ExiNative_Started);
	CreateNative("ExiStats_UnRegisterMe",	ExiNative_UnRegisterMe);

	ExiDB_CreateNative();
	ExiFunction_CreateNative();
	ExiPlayer_CreateNative();
	//ExiMenu_CreateNative();
}

// Exi_
public int ExiNative_Started(Handle plugin, int numParams)
{
	return ExiVar_Started;
}

public int ExiNative_UnRegisterMe(Handle plugin, int numParams)
{
	return ExiVar_Started;
}

// ExiDB_
public int ExiNative_GetDatabase(Handle plugin, int numParams)
{
	return view_as<int>(CloneHandle(ExiDB, plugin));
}

public int ExiNative_GetDatabaseType(Handle plugin, int numParams)
{
	return view_as<int>(ExiDB_type);
}

// ExiFunction
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

// ExiPlayer
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

public int ExiNative_GetClientId(Handle plugin, int numParams)
{
	return ExiPlayer_GetValues(EP_Id, GetNativeCell(1));
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

// ExiMenu
/*public int ExiNative_AddMenuItem(Handle plugin, int numParams)
{
	// ExiStats_AddMenuItem(ExiStatsMenuType type, ExiStatsMenuItemType itemtype, const char[] name, Display);

	ExiStatsMenuType type = GetNativeCell(1);

	char buffer[64];
	GetNativeString(3, buffer, 64);

	if (!buffer[0])
	{
		ThrowNativeError(SP_ERROR_NATIVE, "Empty name", buffer);
		return false;
	}
	else if (FindInMenu(type, itemtype, buffer))
	{
		ThrowNativeError(SP_ERROR_NATIVE, "%s \'%s\' already registered", type == ESMIT_Category ? "category" : "item", buffer);
		return false;
	}

	DataPack dp = new DataPack();
	dp.WriteCell(plugin);
	dp.WriteCell(GetNativeCell(1));
	dp.WriteCell(GetNativeCell(2));
	dp.WriteFunction(GetNativeCell(4));
	dp.WriteFunction(GetNativeCell(5));
}*/