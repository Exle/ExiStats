/**
 * =============================================================================
 * [ExiStats] Core
 * Fully modular statistics for game server.
 *
 * File: existats/events.sp
 * Role: Work with events.
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

void ExiEvent_OnPluginStart()
{
	if (!HookEventEx("player_changename", ExiEvents_OnPlayerChangeName, EventHookMode_Pre)
	&& !HookEventEx("round_end", ExiEvents_OnRoundEnd, EventHookMode_PostNoCopy)
	&& !HookEventEx("dod_round_win", ExiEvents_OnRoundEnd, EventHookMode_PostNoCopy)
	&& !HookEventEx("cs_win_panel_round", ExiEvents_OnRoundEnd, EventHookMode_PostNoCopy)
	&& !HookEventEx("game_round_end", ExiEvents_OnRoundEnd, EventHookMode_PostNoCopy)
	&& !HookEventEx("round_end_message", ExiEvents_OnRoundEnd, EventHookMode_PostNoCopy)
	&& !HookEventEx("round_win", ExiEvents_OnRoundEnd, EventHookMode_PostNoCopy)
	&& !HookEventEx("teamplay_round_win", ExiEvents_OnRoundEnd, EventHookMode_PostNoCopy)
	&& !HookEventEx("arena_win_panel", ExiEvents_OnRoundEnd, EventHookMode_PostNoCopy)
	&& !HookEventEx("pve_win_panel", ExiEvents_OnRoundEnd, EventHookMode_PostNoCopy))
	{
		char buffer[128];
		GetGameDescription(buffer, 128);
		SetFailState("Game \'%s\' not supported", buffer);
	}
}

public void ExiEvents_OnPlayerChangeName(Event event, const char[] name, bool dontBroadcast)
{
	if (!ExiVar_Started)
	{
		return;
	}

	int client = GetClientOfUserId(event.GetInt("userid"));

	char newname[MAX_NAME_LENGTH], oldname[MAX_NAME_LENGTH];
	event.GetString("newname", newname, MAX_NAME_LENGTH);
	event.GetString("oldname", oldname, MAX_NAME_LENGTH);
	ExiPlayer_SetName(client, oldname, newname);
}

public void ExiEvents_OnRoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	if (!ExiVar_Started)
	{
		return;
	}

	static int ExiVar_RoundsPlayed = 0;

	if (++ExiVar_RoundsPlayed >= ExiVar_Update)
	{
		for (int client = 1; client <= MaxClients; client++)
		{
			if (!IsClientInGame(client) || IsFakeClient(client))
			{
				continue;
			}

			ExiDB_UpdateAllValues(client);
		}

		ExiVar_RoundsPlayed = 0;
	}
}