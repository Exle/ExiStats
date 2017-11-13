/**
 * =============================================================================
 * [ExiStats] Core
 * Fully modular statistics for game server.
 *
 * File: existats/player.sp
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

enum ExiPlayer_Info
{
	EP_Id,
	EP_Exp,
	EP_GameTime,
	EP_LastVisit,
	EP_StartGameTime
};

any ExiPlayer[MAXPLAYERS + 1][ExiPlayer_Info];

Handle	ExiForward_OnClienInfoReceived,
		ExiForward_OnClienExperienceUpdated,
		ExiForward_OnClienNameUpdated;

void ExiPlayer_CreateNative()
{
	CreateNative("ExiStats_GetClientId",			ExiNative_GetClientId);

	CreateNative("ExiStats_GetClientById",			ExiNative_GetClientById);
	CreateNative("ExiStats_GetClientByAuth",		ExiNative_GetClientByAuth);

	CreateNative("ExiStats_SetClientExperience",	ExiNative_SetClientExperience);
	CreateNative("ExiStats_SetClientGameTime",		ExiNative_SetClientGameTime);
	CreateNative("ExiStats_SetClientLastVisit",		ExiNative_SetClientLastVisit);

	CreateNative("ExiStats_GetClientExperience",	ExiNative_GetClientExperience);
	CreateNative("ExiStats_GetClientGameTime",		ExiNative_GetClientGameTime);
	CreateNative("ExiStats_GetClientLastVisit",		ExiNative_GetClientLastVisit);
}

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

	ExiDB_OnClientAuthorized(client);
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
	char client_auth[32];
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i) || IsFakeClient(i) || GetClientAuthId(i, AuthId_Steam3, client_auth, 32) && strcmp(auth, client_auth) != 0)
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
		Call_PushCell(ExiPlayer[client][EP_Exp]);
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

bool ExiPlayer_SetName(int client, const char[] oldname, const char[] newname, bool immediately = false)
{
	if (!(0 < client < MaxClients) || !IsClientInGame(client) || IsFakeClient(client))
	{
		return false;
	}

	if ((!ExiVar_Update || immediately) && ExiVar_Started)
	{
		Call_StartForward(ExiForward_OnClienNameUpdated);
		Call_PushCell(client);
		Call_PushString(oldname);
		Call_PushString(newname);
		Call_Finish();

		ExiDB_SetString("name", client, newname);
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