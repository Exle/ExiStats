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