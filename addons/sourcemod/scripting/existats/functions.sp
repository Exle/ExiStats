#include <sourcemod>

#define MAX_BUFFER_LENGTH	(256 * 4)

stock void ExiFunction_ChatMessage(int client, const char[] format, any ...)
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

stock void ExiFunction_SendMessage(int client, char[] message, int author = 0)
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