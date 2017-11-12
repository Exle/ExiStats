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