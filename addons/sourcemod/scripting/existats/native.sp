/**
 * =============================================================================
 * [ExiStats] Core
 * Fully modular statistics for game server.
 *
 * File: existats/native.sp
 * Author: Exle / http://steamcommunity.com/profiles/76561198013509278/
 * =============================================================================
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License, version 3.0, as published by the
 * Free Software Foundation.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * As a special exception, AlliedModders LLC gives you permission to link the
 * code of this program (as well as its derivative works) to "Half-Life 2," the
 * "Source Engine," the "SourcePawn JIT," and any Game MODs that run on software
 * by the Valve Corporation.  You must obey the GNU General Public License in
 * all respects for all other code used.  Additionally, AlliedModders LLC grants
 * this exception to all derivative works.  AlliedModders LLC defines further
 * exceptions, found in LICENSE.txt (as of this writing, version JULY-31-2007),
 * or <http://www.sourcemod.net/license.php>.
 *
 * Version: $Id$
 */

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