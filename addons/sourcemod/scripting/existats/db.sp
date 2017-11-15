/**
 * =============================================================================
 * [ExiStats] Core
 * Fully modular statistics for game server.
 *
 * File: existats/db.sp
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

Database ExiDB;
ExiStatsDBType ExiDB_type;

#define TABLEPLAYERSMYSQL		"CREATE TABLE IF NOT EXISTS %splayers (id int(10) NOT NULL AUTO_INCREMENT, name varchar(32) NOT NULL, ip varchar(32) NOT NULL, auth int(32) NOT NULL, exp int(16) NOT NULL DEFAULT 1000, time int(12) NOT NULL DEFAULT 0, lastvisit int(12) NOT NULL DEFAULT 0, PRIMARY KEY (id), UNIQUE KEY auth (auth)) ENGINE=MyISAM DEFAULT CHARSET=utf8;"
#define TABLEPLAYERSSQL			"CREATE TABLE IF NOT EXISTS %splayers (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, name VARCHAR NOT NULL, ip VARCHAR NOT NULL, auth INTEGER UNIQUE ON CONFLICT IGNORE, exp INTEGER NOT NULL DEFAULT 1000, time INTEGER NOT NULL DEFAULT 0, lastvisit INTEGER NOT NULL DEFAULT 0);"

#define SELECTPLAYER			"SELECT id, exp, time, lastvisit FROM %splayers WHERE auth = '%s';"
#define INSERTPLAYER			"INSERT INTO %splayers (name, ip, auth, lastvisit) VALUES ('%s', '%s', %d, %d);"

#define UPDATEPLAYERVALUE		"UPDATE %splayers SET '%s' = %d WHERE id = %d;"
#define UPDATEPLAYERSTRING		"UPDATE %splayers SET '%s' = '%s' WHERE id = %d;"
#define UPDATEALLPLAYERVALUE	"UPDATE %splayers SET name = '%s', ip = '%s', exp = %d, time = %d, lastvisit = %d WHERE id = %d;"
#define RESETALLPLAYERS			"UPDATE %splayers SET exp = %d, time = 0, lastvisit = %d;"

#define MYSQL				(ExiDB_type == ESDB_MySQL)

Handle	ExiForward_OnDBReConnect;

void ExiDB_CreateNative()
{
	CreateNative("ExiStats_GetDatabase",		ExiNative_GetDatabase);
	CreateNative("ExiStats_GetDatabaseType",	ExiNative_GetDatabaseType);
	CreateNative("ExiStats_GetDatabasePrefix",	ExiNative_GetDatabasePrefix);
}

void ExiDB_OnPluginStart()
{
	ExiForward_OnDBReConnect = CreateGlobalForward("ExiStats_OnDBReConnect",	ET_Ignore);

	ExiDB_PreConnect();
}

void ExiDB_OnPluginEnd()
{
	delete ExiForward_OnDBReConnect;
}

void ExiDB_PreConnect()
{
	if (ExiDB != null)
	{
		return;
	}

	if (SQL_CheckConfig("existats"))
	{
		Database.Connect(ExiDB_Connect, "existats", 1);
	}
	else
	{
		char error[256];
		ExiDB_Connect((ExiDB = SQLite_UseDatabase("existats", error, 256)), error, 2);
	}
}

public Action ExiDB_ReconnectTimer(Handle timer)
{
	if (ExiDB == null)
	{
		Call_StartForward(ExiForward_OnDBReConnect);
		Call_Finish();

		ExiDB_PreConnect();
	}

	return Plugin_Stop;
}

public void ExiDB_Connect(Database db, const char[] error, any data)
{
	ExiDB = db;

	if (ExiDB == null || error[0])
	{
		ExiFunction_State(false);
		CreateTimer(10.0, ExiDB_ReconnectTimer, _, TIMER_FLAG_NO_MAPCHANGE);
	
		LogError("[DB] Connect Error [data %d]: %s", data, error[0] ? error : "Database INVALID HANDLE");
		return;
	}

	ExiDB_GetType();
	ExiDB.SetCharset("utf8");
	char query[512];
	FormatEx(query, 512, MYSQL ? TABLEPLAYERSMYSQL : TABLEPLAYERSSQL, ExiVar_DBPrefix);
	ExiDB.Query(ExiDB_Table, query, _, DBPrio_High);
}

void ExiDB_GetType()
{
	char ident[16];
	ExiDB.Driver.GetIdentifier(ident, 16);

	switch (ident[0])
	{
		case 'm': ExiDB_type = ESDB_MySQL;
		case 's': ExiDB_type = ESDB_SQLite;
		default: SetFailState("[DB] Ident Error: Driver \"%s\" is not supported!", ident);
	}
}

public void ExiDB_Table(Database db, DBResultSet results, const char[] error, any data)
{
	if (error[0])
	{
		ExiDB = null;
		ExiFunction_State(false);
		CreateTimer(10.0, ExiDB_ReconnectTimer);

		LogError("[DB] Table Error: %s", error);
		return;
	}

	ExiFunction_State();

	Handle ExiVar_MyHandle = GetMyHandle();
	Handle ExiVar_Iterator = GetPluginIterator();
	Handle ExiVar_Plugin;
	Function ExiVar_Function;

	while (MorePlugins(ExiVar_Iterator))
	{
		if ((ExiVar_Plugin = ReadPlugin(ExiVar_Iterator)) != null && ExiVar_Plugin != ExiVar_MyHandle && GetPluginStatus(ExiVar_Plugin) == Plugin_Running && (ExiVar_Function = GetFunctionByName(ExiVar_Plugin, "ExiStats_OnDBConnected")) != INVALID_FUNCTION)
		{
			Call_StartFunction(ExiVar_Plugin, ExiVar_Function);
			Call_PushCell(CloneHandle(ExiDB, ExiVar_Plugin));
			Call_PushCell(ExiDB_type);
			Call_Finish();
		}
	}

	delete ExiVar_Iterator;
}

// PLAYER
void ExiDB_OnClientAuthorized(int client)
{
	char query[256];

	FormatEx(query, 256, SELECTPLAYER, ExiVar_DBPrefix, ExiPlayer[client][EP_Steam64]);
	ExiDB.Query(ExiDB_ClientAuthorized, query, GetClientUserId(client));
}

public void ExiDB_ClientAuthorized(Database db, DBResultSet results, const char[] error, any data)
{
	if (db == null || error[0])
	{
		if (db == null)
		{
			ExiFunction_State(false);
			CreateTimer(10.0, ExiDB_ReconnectTimer);
		}

		LogError("[DB] Authorized Error: %s", error);
		return;
	}

	int client = GetClientOfUserId(data);
	if (!IsClientInGame(client))
	{
		return;
	}

	char client_auth[64];
	GetClientAuthId(client, AuthId_SteamID64, client_auth, 64);
	ExiPlayer[client][EP_Steam64] = StringToInt(client_auth);

	if (results.HasResults && results.FetchRow())
	{
		ExiPlayer[client][EP_Id]		= results.FetchInt(0);
		ExiPlayer[client][EP_Exp]		= results.FetchInt(1);
		ExiPlayer[client][EP_GameTime]	= results.FetchInt(2);
		ExiPlayer[client][EP_LastVisit]	= results.FetchInt(3);

		ExiPlayer_OnClienInfoReceived(client);
	}
	else
	{
		char query[256], client_name[MAX_NAME_LENGTH * 2 + 1], client_ip[16];

		GetClientName(client, client_name, MAX_NAME_LENGTH * 2 + 1);
		GetClientIP(client, client_ip, 16);
		ExiDB.Escape(client_name, client_name, MAX_NAME_LENGTH * 2 + 1);

		FormatEx(query, 256, INSERTPLAYER, ExiVar_DBPrefix, client_name, client_ip, ExiPlayer[client][EP_Steam64], GetTime());
		ExiDB.Query(ExiDB_ClientAuthorizedInsert, query, data);
	}
}

public void ExiDB_ClientAuthorizedInsert(Database db, DBResultSet results, const char[] error, any data)
{
	if (db == null || error[0])
	{
		if (db == null)
		{
			ExiFunction_State(false);
			CreateTimer(10.0, ExiDB_ReconnectTimer);
		}

		LogError("[DB] Authorized Error: %s", error);
		return;
	}

	OnClientAuthorized(GetClientOfUserId(data), "");
}

void ExiDB_SetValues(ExiPlayer_Info param, int client, int value)
{
	char query[256];
	ExiDB_GetColNameByParam(param, query, 256);
	Format(query, 256, UPDATEPLAYERVALUE, ExiVar_DBPrefix, query, value, ExiPlayer[client][EP_Id]);
	ExiDB_TQueryEx(query, _, 001);
}

void ExiDB_SetString(const char[] colname, int client, const char[] value)
{
	char query[256];
	FormatEx(query, 256, UPDATEPLAYERSTRING, ExiVar_DBPrefix, colname, value, ExiPlayer[client][EP_Id]);
	ExiDB_TQueryEx(query, _, 002);
}

void ExiDB_UpdateAllValues(int client)
{
	char query[256], client_name[MAX_NAME_LENGTH * 2 + 1], client_ip[16];

	GetClientName(client, client_name, MAX_NAME_LENGTH * 2 + 1);
	GetClientIP(client, client_ip, 16);
	ExiDB.Escape(client_name, client_name, MAX_NAME_LENGTH * 2 + 1);

	FormatEx(query, 256, UPDATEALLPLAYERVALUE, ExiVar_DBPrefix, client_name, client_ip, ExiPlayer[client][EP_Exp], (ExiPlayer[client][EP_GameTime] -= ExiPlayer[client][EP_StartGameTime] - (ExiPlayer[client][EP_StartGameTime] = GetTime())), (ExiPlayer[client][EP_LastVisit] = GetTime()), ExiPlayer[client][EP_Id]);

	ExiDB_TQueryEx(query, _, 003);
}

void ExiDB_ResetAll()
{
	char query[256];
	FormatEx(query, 256, RESETALLPLAYERS, ExiVar_DBPrefix, 1000, GetTime());
	ExiDB_TQueryEx(query, _, 004);
	ExiFunction_State();
}

stock void ExiDB_TQueryEx(const char[] query, DBPriority prio = DBPrio_Normal, any data = 0)
{
	if (ExiDB == null)
	{
		ExiFunction_State(false);
		CreateTimer(10.0, ExiDB_ReconnectTimer);
		LogError("[DB] Query Error: Database INVALID HANDLE");

		return;
	}

	ExiDB.Query(ExiDB_ErrorCheck, query, data, prio);
}

public void ExiDB_ErrorCheck(Database db, DBResultSet results, const char[] error, any data)
{
	if (!error[0])
	{
		return;
	}

	if (db == null)
	{
		ExiFunction_State(false);
		CreateTimer(10.0, ExiDB_ReconnectTimer);
		LogError("[DB] Query Error: Database INVALID HANDLE");
	}

	LogError("[DB] Query Check Error: data %d | %s", data, error);
}

void ExiDB_GetColNameByParam(ExiPlayer_Info param, char[] buffer, int maxlen)
{
	switch (param)
	{
		case EP_Id:			strcopy(buffer, maxlen, "id");
		case EP_Exp:		strcopy(buffer, maxlen, "exp");
		case EP_GameTime:	strcopy(buffer, maxlen, "time");
		case EP_LastVisit:	strcopy(buffer, maxlen, "lastvisit");
	}
}