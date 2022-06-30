#include <sourcemod>
#include <sdktools>

#pragma semicolon 1
#pragma newdecls required

#define DATA "1.5"

public Plugin myinfo =
{
	name = "Surf-Show iDamage",
	author = "GenaEscobar",
	description = "Based in: Fortnite show damage - Frangug",
	version = DATA,
	url = "http://steamcommunity.com/id/genaescobar"
};

public void OnPluginStart()
{
	CreateConVar("sm_showdamage_version", DATA, "", FCVAR_NOTIFY|FCVAR_DONTRECORD);
	
	HookEvent("player_hurt", Event_PlayerHurt);
}


public Action Event_PlayerHurt(Handle event, const char[] name, bool dontBroadcast)
{	
	int iAttacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	int iVictim = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if(iVictim == iAttacker || iAttacker < 1 || iAttacker > MaxClients || !IsClientInGame(iAttacker) || IsFakeClient(iAttacker)) // check Attacker
		return;

	int iDamage = GetEventInt(event, "dmg_health"); 
	int iHp = GetClientHealth(iVictim);

	if(iDamage < 100){
		SetHudTextParams(-1.0, 0.45, 1.3, 255, 0, 0, 200, 1); //red
			
		if(iDamage < 80){
			SetHudTextParams(0.57, 0.45, 1.3, 253, 229, 0, 200, 1); //orange
					
			if(iDamage < 40){
				SetHudTextParams(0.57, 0.45, 1.3, 255, 255, 255, 200, 1); //white
			}	
		}
		ShowHudText(iAttacker, 5, "%i", iDamage); //Damage in HUD
	}
	
	if(iHp < 1){
		SetHudTextParams(0.51, 0.50, 2.0, 255, 0, 0, 200, 1); 
		ShowHudText(iAttacker, 4, "%N", iVictim); //Dead player's NAME
	}
}