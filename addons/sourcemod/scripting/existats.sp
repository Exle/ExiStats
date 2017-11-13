/**
 * =============================================================================
 * [ExiStats] Core
 * Fully modular statistics for game server.
 *
 * File: existats.sp
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
//#include "existats/menu.sp"

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
	//ExiMenu_OnPluginStart();

	ExiEngine = GetEngineVersion();
}

public void OnPluginEnd()
{
	ExiDB_OnPluginEnd();
	ExiPlayer_OnPluginEnd();
	//ExiMenu_OnPluginEnd();
}