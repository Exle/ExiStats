/**
 * =============================================================================
 * [ExiStats] Core
 * Fully modular statistics for game server.
 *
 * File: existats/commands.sp
 * Role: Registration console commands.
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

void ExiCmd_OnPluginStart()
{
	RegAdminCmd("sm_es_reset", ExiCmd_Reset, ADMFLAG_ROOT, "Reset players stats");
}

public Action ExiCmd_Reset(int client, int args)
{
	if (args < 1)
	{
		ReplyToCommand(client, "[SM] Usage: sm_es_reset <player>");
		return Plugin_Handled;
	}

	char arg[64];
	GetCmdArg(1, arg, sizeof(arg));

	char target_name[MAX_TARGET_LENGTH];
	int target_list[MAXPLAYERS], target_count;
	bool tn_is_ml;

	if ((target_count = ProcessTargetString(
			arg,
			client,
			target_list,
			MAXPLAYERS,
			COMMAND_FILTER_NO_BOTS,
			target_name,
			MAX_TARGET_LENGTH,
			tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}

	for (int i = 0; i < target_count; i++)
	{
		ExiCmd_PerformReset(client, target_list[i]);
	}

	if (tn_is_ml)
	{
		ShowActivity2(client, EXICHATNAME, " %t", "Reseted Target", target_name);
	}
	else
	{
		ShowActivity2(client, EXICHATNAME, " %t", "Reseted Target", "_s", target_name);
	}

	return Plugin_Handled;
}

void ExiCmd_PerformReset(int client, int target)
{
	ExiPlayer_SetValues(EP_Exp, target, 0);
	ExiPlayer_SetValues(EP_GameTime, target, 0);

	if (client != target)
	{
		LogAction(client, target, "\"%L\" Reseted stats \"%L\"", client, target);
	}
	else
	{
		ExiFunction_ChatMessage(target, "%t", "Reseted Himself");
		LogAction(client, target, "\"%L\" Reseted himself stats", target);
	}
}