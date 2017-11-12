#if defined existats_included
	#endinput
#endif
#define _existats_included

#define EXICHATNAME "\x03[\x04ExiStats\x03]\x01"

#include <existats/version>

/**
 *	Database type
 */
enum ExiStatsDBType
{
	ESDB_SQLite, 	/**< SQLite type */
	ESDB_MySQL,		/**< MySQL type */
};

/**
 *	Menu type
 */
enum ExiStatsMenuType
{
    ESMT_Admin,
    ESMT_Client
}

/**
 *	Menu type
 */
enum ExiStatsMenuItemType
{
    ESMIT_Category,
    ESMIT_Item
}

/**
 *	Called when plugin started and database connected
 *
 *	@param db	Database handle
 *	@param type	Database type (mysql or sql)
 *
 */
forward void ExiStats_OnDBConnected(Database db, ExiStatsDBType type);

/**
 *	Called when the connection error to the database and retry the connection
 */
forward void ExiStats_OnDBReConnect();

/**
 *	Called when the player is logged and all data received
 *
 *	@param client		Client index
 *	@param id			Client id in database
 *	@param auth			Client auth id
 *	@param exp			Client experience
 *	@param gameTime		The time spent on the server
 *	@param lastvisit	Last entry to the server
 *
 */
forward void ExiStats_OnClienInfoReceived(int client, int id, const char[] auth, int exp, int gameTime, int lastvisit);

/**
 *	Called when the player experience updated
 *
 *	@param client		Client index
 *	@param exp			Client experience
 *	@param newexp		New client experience
 *
 */
forward void ExiStats_OnClienExperienceUpdated(int client, int exp, int &newexp);

native bool ExiStats_Started();

native Database ExiStats_GetDatabase();
native ExiStatsDBType ExiStats_GetDatabaseType();

native void ExiStats_Message(int client, const char[] format, any ...);
native void ExiStats_MessageAll(const char[] format, any ...);

native int ExiStats_GetClientById(int id);
native int ExiStats_GetClientByAuth(const char[] auth);

native bool ExiStats_SetClientExperience(int client, int value, bool immediately = false);
native bool ExiStats_SetClientGameTime(int client, bool immediately = false);
native bool ExiStats_SetClientLastVisit(int client, bool immediately = false);

native int ExiStats_GetClientId(int client);

native int ExiStats_GetClientExperience(int client);
native int ExiStats_GetClientGameTime(int client);
native int ExiStats_GetClientLastVisit(int client);

public SharedPlugin __pl_existats = 
{
	name = "existats",
	file = "existats.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public __pl_existats_SetNTVOptional()
{
	MarkNativeAsOptional("ExiStats_Started");
	MarkNativeAsOptional("ExiStats_GetDatabase");
	MarkNativeAsOptional("ExiStats_GetDatabaseType");

	MarkNativeAsOptional("ExiStats_Message");
	MarkNativeAsOptional("ExiStats_MessageAll");

	MarkNativeAsOptional("ExiStats_GetClientById");
	MarkNativeAsOptional("ExiStats_GetClientByAuth");

	MarkNativeAsOptional("ExiStats_SetClientExperience");
	MarkNativeAsOptional("ExiStats_SetClientGameTime");
	MarkNativeAsOptional("ExiStats_SetClientLastVisit");

	MarkNativeAsOptional("ExiStats_GetClientId");

	MarkNativeAsOptional("ExiStats_GetClientAuth");
	MarkNativeAsOptional("ExiStats_GetClientName");

	MarkNativeAsOptional("ExiStats_GetClientExperience");
	MarkNativeAsOptional("ExiStats_GetClientGameTime");
	MarkNativeAsOptional("ExiStats_GetClientLastVisit");
}
#endif