/**
 * =============================================================================
 * [ExiStats] Core
 * Fully modular statistics for game server.
 *
 * File: existats/menu.sp
 * Role: Menu functions.
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

ArrayList ExiArray_MenuCategory,
    ExiArray_MenuItem;

void ExiMenu_CreateNative()
{
	CreateNative("ExiStats_ReDisplayClientMenu",	ExiNative_ReDisplayClientMenu);

	CreateNative("ExiStats_AddMenuItem",		    ExiNative_AddMenuItem);
    CreateNative("ExiStats_AddMenuCategory",        ExiNative_AddMenuCategory);

	CreateNative("ExiStats_AddedItem",		        ExiNative_AddedItem);
    CreateNative("ExiStats_AddedCategory",	        ExiNative_AddedCategory);
}

void ExiMenu_OnPluginStart()
{
    ExiArray_MenuCategory = new ArrayList(2);
    ExiArray_MenuItem = new ArrayList(2);
}

void ExiMenu_OnPluginEnd()
{
    delete ExiArray_Menu;
    delete ExiArray_MenuItem;
}