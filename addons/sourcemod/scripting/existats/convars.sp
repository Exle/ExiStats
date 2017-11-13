/**
 * =============================================================================
 * [ExiStats] Core
 * Fully modular statistics for game server.
 *
 * File: existats/convars.sp
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

ConVar ExiCVar_Update;

int ExiVar_Update;

void ExiConVar_OnPluginStart()
{
	(ExiCVar_Update = CreateConVar("sm_es_update", "2", "How often update database. 0 - immediately, 1,2,3.. - Every N rounds")).AddChangeHook(ExiConVar_ChangedCallback);
}

public void OnConfigsExecuted()
{
	ExiConVar_ChangedCallback(ExiCVar_Update, "", "");
}

public void ExiConVar_ChangedCallback(ConVar convar, const char[] oldValue, const char[] newValue)
{
	if (convar == ExiCVar_Update)
	{
		ExiVar_Update = convar.IntValue;
	}
}