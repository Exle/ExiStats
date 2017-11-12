/**
 * =============================================================================
 * [ExiStats] Core
 * Fully modular statistics for game server.
 *
 * File: existats/functions.sp
 * Role: Separate functions.
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

#define MAX_BUFFER_LENGTH	(256 * 4)

void ExiFunction_CreateNative()
{
	CreateNative("ExiStats_Message",	ExiNative_Message);
	CreateNative("ExiStats_MessageAll",	ExiNative_MessageAll);
}

void Exi_State(bool start = true)
{
	if ((ExiVar_Started = start))
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i))
			{
				continue;
			}

			OnClientAuthorized(i, "");
		}
	}
}

void ExiFunction_ChatMessage(int client, const char[] format, any ...)
{
	if (!IsClientInGame(client))
	{
		return;
	}

	char buffer[MAX_BUFFER_LENGTH];

	SetGlobalTransTarget(client);
	VFormat(buffer, MAX_BUFFER_LENGTH, format, 3);

	ExiFunction_SendMessage(client, buffer);
}

stock void ExiFunction_ChatMessageAll(const char[] format, any ...)
{
	char buffer[MAX_BUFFER_LENGTH];

	for (int client = 1; client <= MaxClients; client++)
	{
		if (!IsClientInGame(client) || IsFakeClient(client))
		{
			continue;
		}

		SetGlobalTransTarget(client);
		VFormat(buffer, MAX_BUFFER_LENGTH, format, 2);

		ExiFunction_SendMessage(client, buffer);
	}
}

void ExiFunction_SendMessage(int client, char[] message, int author = 0)
{
	if (author == 0)
	{
		author = client;
	}

	Format(message, MAX_BUFFER_LENGTH, "%s\x01%s %s", ExiEngine == Engine_CSGO ? " " : "", EXICHATNAME, message);

	Handle msg = StartMessageOne("SayText2", client, USERMSG_RELIABLE | USERMSG_BLOCKHOOKS);

	if (GetFeatureStatus(FeatureType_Native, "GetUserMessageType") != FeatureStatus_Available || GetUserMessageId("SayText2") == INVALID_MESSAGE_ID)
	{
		PrintToChat(client, message);
		return;
	}

	if (GetUserMessageType() == UM_Protobuf)
	{
		Protobuf pb = UserMessageToProtobuf(msg);

		pb.SetInt("ent_idx", author);
		pb.SetBool("chat", true);
		pb.SetString("msg_name", message);
		pb.AddString("params", "");
		pb.AddString("params", "");
		pb.AddString("params", "");
		pb.AddString("params", "");
	}
	else
	{
		BfWrite bf = UserMessageToBfWrite(msg);

		bf.WriteByte(author);
		bf.WriteByte(true);
		bf.WriteString(message);
	}

	EndMessage();
}