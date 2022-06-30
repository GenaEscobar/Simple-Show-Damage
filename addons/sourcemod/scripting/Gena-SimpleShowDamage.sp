#include <sourcemod>
#include <sdktools>

#pragma semicolon 1
#pragma newdecls required

#define DATA "1.6"

public Plugin myinfo =
{
	name = "Simple Show iDamage",
	author = "GenaEscobar",
	description = "Version 1.6 by Koen",
	version = DATA,
	url = "http://steamcommunity.com/id/genaescobar"
};

public void OnPluginStart()
{
	CreateConVar("sm_showdamage_version", DATA, "", FCVAR_NOTIFY|FCVAR_DONTRECORD);
	
	HookEvent("player_hurt", Event_PlayerHurt, EventHookMode_Post);
}


public Action Event_PlayerHurt(Handle event, const char[] name, bool dontBroadcast)
{
	int iAttacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	int iVictim = GetClientOfUserId(GetEventInt(event, "userid"));
	int iDamage = GetEventInt(event, "dmg_health");
	int iHitGroup = GetEventInt(event, "hitgroup"); // <- Obtain hitgroup of the shot (determine if shot hit the head)
	int iHP = GetEventInt(event, "health");
	
	if(iVictim == iAttacker || iAttacker < 1 || iAttacker > MaxClients || !IsClientInGame(iAttacker) || IsFakeClient(iAttacker)) // check Attacker
		return Plugin_Continue;

	if (iHP == 0) // <- Dead players will have 0 remaining health, so you can make a conditional statement that checks that
	{
		SetHudTextParams(0.51, 0.50, 2.0, 255, 0, 0, 200, 1);
		ShowHudText(iAttacker, 5, "%N", iVictim);
	}
	else
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
	}
	return Plugin_Continue;
}
