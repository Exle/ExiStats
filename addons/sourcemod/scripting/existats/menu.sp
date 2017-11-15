/**
 * =============================================================================
 * [ExiStats] Core
 * Fully modular statistics for game server.
 *
 * File: existats/menu.sp
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

#define CLIENTMENU	0
#define ADMINMENU	1

ArrayList ExiArray_MenuItem[2];

void ExiMenu_CreateNative()
{
	CreateNative("ExiStats_ReDisplayMenu",			ExiNative_ReDisplayMenu);
	CreateNative("ExiStats_ReDisplayAdminMenu",		ExiNative_ReDisplayAdminMenu);

	CreateNative("ExiStats_AddMenuItem",		    ExiNative_AddMenuItem);
	CreateNative("ExiStats_AddAdminMenuItem",		ExiNative_AddAdminMenuItem);

	CreateNative("ExiStats_AddedMenuItem",			ExiNative_AddedMenuItem);
	CreateNative("ExiStats_AddedAdminMenuItem",		ExiNative_AddedAdminMenuItem);
}

void ExiMenu_OnPluginStart()
{
    for (int i; i < 2; i++)
    {
		ExiArray_MenuItem[i] = new ArrayList(2);
    }
}

void ExiMenu_OnPluginEnd()
{
    for (int i; i < 2; i++)
    {
		delete ExiArray_MenuItem[i];
    }
}

void ExiMenu_MainMenu(int client, int mode = 0)
{
    if (!client || !IsClientInGame(client))
	{
		ReplyToCommand(client, "%s %t", EXICHATNAME, "Command is in-game only");
		return;
	}

    int length = ExiArray_MenuItem[mode].Length;
    if (!length)
    {
        PrintToChat(client, "%s %t", EXICHATNAME, "Menu is empty");
        return;
    }

    Menu ExiVar_Menu = new Menu(ExiMenu_MainMenuHandler);
	ExiVar_Menu.SetTitle(mode ? "ExiStats Admin" : "ExiStats");

	if (!mode)
	{
    	ExiMenu_AddFormatMenuItem(ExiVar_Menu, _, "admin", "%T", "Admin menu", client);
		ExiVar_Menu.ExitBackButton = true;
	}
	else
	{
		ExiMenu_AddFormatMenuItem(ExiVar_Menu, _, "reset all", "%T", "Reset all stats", client);
		ExiMenu_AddFormatMenuItem(ExiVar_Menu, _, "reset player", "%T", "Reset player stats", client);
	}

	char buffer[64], index[16];

    for (int i; i <= length; i++)
    {
		if (!ExiMenu_GetFormatItem(client, mode, i, buffer, 64))
		{
			continue;
		}

		FormatEx(index, 16, "%s%d", !mode ? "c" : "a", i);
		ExiVar_Menu.AddItem(index, buffer);
    }

    ExiVar_Menu.Display(client, MENU_TIME_FOREVER);
}

public int ExiMenu_MainMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Cancel:
		{
			if (param2 == MenuCancel_ExitBack)
			{
				ExiMenu_MainMenu(param1);
			}
		}
		case MenuAction_Select:
		{
			char buffer[64];
			menu.GetItem(param2, buffer, 64);

			switch (buffer[1])
			{
				case 'd': ExiMenu_MainMenu(param1, true);
				case 'e':
				{
					if (buffer[6] == 'a')
					{
						ExiDB_ResetAll();
					}
					else
					{
						ExiMenu_ResetPlayer(param1);
					}
				}
				default:
				{
					int mode = buffer[0] == 'a' ? 1 : 0;
					int id = StringToInt(buffer[1]);

					Handle plugin = ExiArray_MenuItem[mode].Get(id, 0);
					DataPack dp = ExiArray_MenuItem[mode].Get(id, 1);
					dp.Reset();

					dp.ReadString(buffer, 64);
					dp.ReadFunction();
					Function callback = dp.ReadFunction();

					if (plugin == null || callback == INVALID_FUNCTION)
					{
						return;
					}

					Call_StartFunction(plugin, callback);
					Call_PushCell(param1);
					Call_PushString(buffer);
					Call_Finish();
				}
			}
		}
	}
}

void ExiMenu_ResetPlayer(int client)
{
    Menu ExiVar_Menu = new Menu(ExiMenu_ResetPlayerHandler);
	ExiVar_Menu.SetTitle("Reset player stats", client);
	ExiVar_Menu.ExitBackButton = true;

	AddTargetsToMenu(ExiVar_Menu, 0, true, false);

    ExiVar_Menu.Display(client, MENU_TIME_FOREVER);
}

public int ExiMenu_ResetPlayerHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Cancel:
		{
			if (param2 == MenuCancel_ExitBack)
			{
				ExiMenu_MainMenu(param1, true);
			}
		}
		case MenuAction_Select:
		{
			char buffer[16];
			menu.GetItem(param2, buffer, 16);
			int target = GetClientOfUserId(StringToInt(buffer));

			if (!target)
			{
				ExiFunction_ChatMessage(param1, "%s %t", EXICHATNAME, "Player no longer available");
			}
			else if (!CanUserTarget(param1, target))
			{
				ExiFunction_ChatMessage(param1, "%s %t", EXICHATNAME, "Unable to target");
			}
			else
			{
				ExiCmd_PerformReset(param1, target);
			}
		}
	}
}

bool ExiMenu_GetFormatItem(int client, int mode = 0, int index, char[] buffer, int maxlength)
{
	Handle plugin = ExiArray_MenuItem[mode].Get(index, 0);
	DataPack dp = ExiArray_MenuItem[mode].Get(index, 1);
	dp.Reset();

	char name[64];
	dp.ReadString(name, 64);
	Function disp = dp.ReadFunction();

	if (plugin != null && disp != INVALID_FUNCTION)
	{
		return false;
	}
	
	Call_StartFunction(plugin, disp);
	Call_PushCell(client);
	Call_PushStringEx(buffer, maxlength, SM_PARAM_STRING_UTF8|SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
	Call_PushCell(maxlength);
	Call_Finish();

	if (!buffer[0])
	{
		strcopy(buffer, maxlength, name);
	}

	return true;
}

void ExiMenu_AddFormatMenuItem(Menu menu, int style = ITEMDRAW_DEFAULT, const char[] info, const char[] format, any ...)
{
	char buffer[128];
	VFormat(buffer, 128, format, 5);
	menu.AddItem(info, buffer, style);
}

int ExiMenu_FindInMenu(int mode, const char[] name)
{
	int length;
	char buffer[64];
	DataPack dp;
	for (int i; i < length; i++)
	{
		(dp = ExiArray_MenuItem[mode].Get(i, 1)).Reset();
		dp.ReadString(buffer, 64);
		if (strcmp(name, buffer) == 0)
		{
			return i;
		}
	}

	return -1;
}

void ExiMenu_AddMenuItem(int mode, Handle plugin, const char[] name, Function disp, Function cb)
{
	DataPack dp = new DataPack();
	dp.WriteString(name);
	dp.WriteFunction(disp);
	dp.WriteFunction(cb);

	int length = ExiArray_MenuItem[mode].Length;
	ExiArray_MenuItem[mode].Resize(length + 1);
	ExiArray_MenuItem[mode].Set(length, plugin, 0);
	ExiArray_MenuItem[mode].Set(length, dp, 1);
}