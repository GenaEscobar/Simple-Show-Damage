#include <sourcemod>
#include <sdktools>
#include <clientprefs>

#pragma semicolon 1
#pragma newdecls required

#define DATA "1.7"

Handle Cookie_ShowDamage;

C_ShowDamage[MAXPLAYERS + 1];
M_ModeDamage[MAXPLAYERS + 1];
M_NameDamage[MAXPLAYERS + 1];

public Plugin myinfo =
{
	name = "Simple Show iDamage",
	author = "GenaEscobar",
	description = "Version 1.7",
	version = DATA,
	url = "http://steamcommunity.com/id/genaescobar"
};

public void OnPluginStart()
{
	CreateConVar("sm_showdamage_version", DATA, "", FCVAR_NOTIFY|FCVAR_DONTRECORD);
	HookEvent("player_hurt", Event_PlayerHurt, EventHookMode_Post);
	
	RegConsoleCmd("sm_sd", Menu_ShowDamage, "Menu of Show damage");
	RegConsoleCmd("sm_showdamage", Menu_ShowDamage, "Menu of Show damage");
	
	Cookie_ShowDamage 					= RegClientCookie("Cookie_ShowDamage", "", CookieAccess_Private);
	int info;
	SetCookieMenuItem(ShowDamageCookieHandler, info, "Show Damage");
}


//Base of Menu & Cookies https://forums.alliedmods.net/showthread.php?t=264427

public void OnClientCookiesCached(int client)
{
	char value[16];
	
	GetClientCookie(client, Cookie_ShowDamage, value, sizeof(value));
	if(strlen(value) > 0) 
	{
		C_ShowDamage[client] = StringToInt(value);
	}
	else 
	{
		C_ShowDamage[client] = 1;
	}
}

public Action Menu_ShowDamage(int client, int args)
{
	MenuShowDamage(client); 
}

public void ShowDamageCookieHandler(int client, CookieMenuAction action, any info, char [] buffer, int maxlen)
{
	MenuShowDamage(client);
} 

void MenuShowDamage(int client)
{
	char title[40], show_damage[40], status_show_damage[40], status_mode_damage[40], mode_damage[40], name_damage[40], status_name_damage[40];
	
	Menu menu = CreateMenu(MenuShowDamageAction);
	
	Format(status_show_damage, sizeof(status_show_damage), (!C_ShowDamage[client]) ? "Activado" : "Desactivado", client);
	Format(show_damage, sizeof(show_damage), "Status: %s", status_show_damage);
	AddMenuItem(menu, "M_show_damage_hud", show_damage);
	
	Format(status_mode_damage, sizeof(status_mode_damage), (M_ModeDamage[client]) ? "Centro" : "Arriba", client);
	Format(mode_damage, sizeof(show_damage), "Modo: %s", status_mode_damage);
	AddMenuItem(menu, "M_mode_damage", mode_damage);
	
	Format(status_name_damage, sizeof(status_name_damage), (M_NameDamage[client]) ? "Activado" : "Desactivado", client);
	Format(name_damage, sizeof(name_damage), "Mostrar nombre: %s", status_name_damage);
	AddMenuItem(menu, "M_name_damage", name_damage);
	
	Format(title, sizeof(title), "Show Damage - By Gena", client);
	menu.SetTitle(title);
	SetMenuExitBackButton(menu, false);
	menu.Display(client, MENU_TIME_FOREVER);
}

public int MenuShowDamageAction(Menu menu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char menu1[56];
			menu.GetItem(param2, menu1, sizeof(menu1));
			
			if(StrEqual(menu1, "M_show_damage_hud"))
			{
				C_ShowDamage[param1] = !C_ShowDamage[param1];
				SetClientCookie(param1, Cookie_ShowDamage, (C_ShowDamage[param1]) ? "1" : "0");
			}
			if(StrEqual(menu1, "M_mode_damage"))
			{
				M_ModeDamage[param1] = !M_ModeDamage[param1];
				SetClientCookie(param1, Cookie_ShowDamage, (M_ModeDamage[param1]) ? "1" : "0");
			}
			if(StrEqual(menu1, "M_name_damage"))
			{
				M_NameDamage[param1] = !M_NameDamage[param1];
				SetClientCookie(param1, Cookie_ShowDamage, (M_NameDamage[param1]) ? "1" : "0");
			}
			MenuShowDamage(param1);
		}
	}
}


public Action Event_PlayerHurt(Handle event, const char[] name, bool dontBroadcast)
{
	int iAttacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	int iVictim = GetClientOfUserId(GetEventInt(event, "userid"));
	int iDamage = GetEventInt(event, "dmg_health");
	int iHitGroup = GetEventInt(event, "hitgroup"); // <- Obtain hitgroup of the shot (determine if shot hit the head)
	int iHP = GetEventInt(event, "health");
	
	if(C_ShowDamage[iAttacker]) 
		return Plugin_Continue;
	
	if(iVictim == iAttacker || iAttacker < 1 || iAttacker > MaxClients || !IsClientInGame(iAttacker) || IsFakeClient(iAttacker)) // check Attacker
		return Plugin_Continue;
	
	if(M_ModeDamage[iAttacker])
	{
		
		if (iHitGroup == 1) // Check if the shot hit the head
		{
			SetHudTextParams(0.57, 0.45, 1.3, 253, 229, 0, 200, 1); // Orange for headshots
		}
		else if (iDamage < 40)
		{
			SetHudTextParams(0.57, 0.45, 1.3, 255, 255, 255, 200, 1); // White
		}
		else if (iDamage < 80)
		{
			SetHudTextParams(-1.0, 0.45, 1.3, 255, 0, 0, 200, 1); // Red
		}
		else
		{
			SetHudTextParams(-1.0, 0.45, 1.3, 255, 0, 0, 200, 1); // Red Color of the Name
		}
		ShowHudText(iAttacker, 5, "%i", iDamage); // Display damage
		
		if(iHP == 0) // <- Dead players will have 0 remaining health, so you can make a conditional statement that checks that
		{
			if(M_NameDamage[iAttacker])
			{
				SetHudTextParams(0.51, 0.50, 2.0, 255, 0, 0, 200, 1);
				ShowHudText(iAttacker, 5, "%N", iVictim);
			}
			else if(!M_NameDamage[iAttacker])
			{
				SetHudTextParams(0.51, 0.50, 2.0, 255, 0, 0, 200, 1);
				ShowHudText(iAttacker, 5, "");
			}
		}
	}
	else
	{
		if(!M_NameDamage[iAttacker])
		{
			SetHudTextParams(-0.8, -0.8, 5.0, 255, 0, 0, 255, 0, 1.0, 0.5, 1.0);
			ShowHudText(iAttacker, 5, "Damage: %i\nHP: %d", iDamage, iHP);
			
			if(iHP == 0) // <- Dead players will have 0 remaining health, so you can make a conditional statement that checks that
			{
				ShowHudText(iAttacker, 5, "");
			}
		}
		else if(M_NameDamage[iAttacker])
		{
			SetHudTextParams(-0.8, -0.8, 5.0, 255, 0, 0, 255, 0, 1.0, 0.5, 1.0);
			ShowHudText(iAttacker, 5, "Victim: %N\nDamage: %i\nHP: %d", iVictim, iDamage, iHP);
			
			if(iHP == 0) // <- Dead players will have 0 remaining health, so you can make a conditional statement that checks that
			{
				ShowHudText(iAttacker, 5, "%N", iVictim);
			}
		}
	}
	return Plugin_Continue;
}
