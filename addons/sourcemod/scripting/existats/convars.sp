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