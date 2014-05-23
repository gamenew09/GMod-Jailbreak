include("shared.lua")

local PLAYER = getmetatable("Player")

local SpawnPoints = {
	{
		ClassName = "info_player_terrorist",
		Team = 1
	},
	{
		ClassName = "info_player_counterterrorist",
		Team = 2
	}
}

AddCSLuaFile( "cl_init.lua" ) -- Make sure clientside
AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent.
AddCSLuaFile( "cl_hud.lua" )  -- and shared scripts are sent.

include("sh_player.lua")

print(TEAM_PRISONERS .. " ".. TEAM_GUARDS)

util.AddNetworkString("WardenPoint")
util.AddNetworkString("DropWeapon")

-- Setup Net Hooks --
net.Receive( "WardenPoint", function (len, ply)
	if not ply:IsWarden() then return end
	--pcall(function () -- Hopefully prevents the hit pos from being nil.
		CreateWardenPoint(ply:GetEyeTrace().HitPos)
	--end)
end)

net.Receive( "DropWeapon", function (len, ply)
	pcall(function () -- Hopefully prevents the hit pos from being nil.
		if(ply:GetActiveWeapon():GetClass() == "weapon_fists")then return end -- Never drop your hands. That sounds very odd.
		ply:DropWeapon(ply:GetActiveWeapon())
	end)
end)

hook.Add( "PlayerNoClip", "jb_default_noclip", function( ply, desiredState )
	local ret = false
	if ( desiredState == false ) then -- the player wants to turn noclip off
		ret = true -- always allow
	elseif ( ply:IsAdmin() ) then
		ret = true -- allow administrators to enter noclip
	end
	local word = "disallowed"
	if ret then
		word = "allowed"
	end
	print("Noclip for "..ply:GetName().. " was "..tostring(word)..".")
	return ret
end )

local count = 1

local WardenPoints = {}

function GM:GetWardenPoints()
	return WardenPoints
end

function GM:PlayerSelectSpawn( pl )
	for i,v in pairs(SpawnPoints)do
		local className = v.ClassName
		local teamNum = v.Team
		print(pl:GetName())
		print(pl:Team() .. " == ".. teamNum.. " is ".. tostring(pl:Team() == teamNum))
		if pl:Team() == teamNum then
			local spawns = ents.FindByClass(className)
			return spawns[math.random(#spawns)]
		end
	end
	print("Resulting to first team's spawn class.")
	local spawns = ents.FindByClass(SpawnPoints[1].ClassName) -- Gets the first team's spawn
	return spawns[math.random(#spawns)]
end

function CreateWardenPoint(vec)
	if(count >= 10) then return end
	local ent = ents.Create( 'jb_wardenpoint' )
	print("HI!")
	ent:SetPos( vec )
	ent:Spawn()
	ent:Activate()
	table.insert(WardenPoints, point)
	print('YAY!')
	count = count + 1
	local curCount = count
	timer.Create( "DeletePoint".. count, 5, 1, function ()
		print("Destroying...")
		count = count - 1
		ent:Remove()
		table.remove(WardenPoints, curCount)
	end)
end

function ChangeMyTeam( ply, cmd, args )
	if ply == nil then
		print("Only players can run this command.")
		return
	end
    ply:SetTeam( args[1] )
    ply:Spawn()
end
concommand.Add( "jb_set_team", ChangeMyTeam )

-- Choose the model for hands according to their player model.
function GM:PlayerSetHandsModel( ply, ent )
	local simplemodel = player_manager.TranslateToPlayerModelName( ply:GetModel() )
	local info = player_manager.TranslatePlayerHands( simplemodel )
	if ( info ) then
		ent:SetModel( info.model )
		ent:SetSkin( info.skin )
		ent:SetBodyGroups( info.body )
	end
end

function GM:PlayerInitialSpawn(ply)
	//ply:SetTeam(TEAM_PRISONERS)
end

function GM:PlayerSetModel( ply )
	if(not ply:Alive())then return end
	if(ply:Team() == TEAM_GUARDS)then
		ply:SetModel("models/player/police.mdl" )
	else
		ply:SetModel("models/player/Group01/Male_01.mdl" )
	end
	print("Set player's model.")
end

function GM:GetFallDamage( ply, speed )
    vel = speed - 580
    return (vel*(100/(1024-580)))
end

function GM:PlayerSpawn( ply )
	--player_manager.SetPlayerClass( ply, "player_default" )
	ply:SetNoCollideWithTeammates( true )
	self:PlayerSetModel( ply )
	print("Player Spawned!")
	self:PlayerLoadout(ply)
	ply:SetupHands()
end

function GM:PlayerLoadout(ply)
	ply:StripWeapons()
	ply:Give("weapon_fists")
	if ply:Team() == TEAM_PRISONERS then
		if math.random(1, 100) > 75 then
			ply:PrintMessage(HUD_PRINTTALK, "Hey, you spawned with a knife!")
			ply:Give("ptp_cs_knife")
		end
		if math.random(1, 250) > 200 then 
			ply:PrintMessage(HUD_PRINTTALK, "Hey, you spawned with a CV-47!")
			ply:Give("ptp_cs_ak47")
			ply:GiveAmmo(590, "smg1", true)
		end
		ply:SelectWeapon("weapon_fists")
	end
	if ply:Team() == TEAM_GUARDS then
		ply:Give("weapon_weaponchecker")
		ply:Give("ptp_cs_knife")
		ply:Give("ptp_cs_ak47")
		ply:GiveAmmo(9999, "smg1", true)
	end
	print("Player Loaded!")
end

hook.Add("ShowTeam", "jb_Show", function (ply)
	umsg.Start( "ChangeTeamsGUI", ply ) -- Sending a message to the client.
    umsg.End()
end)

function SpawnAllPlayers()
	for i,v in pairs(player.GetAll())do
		v:Spawn()
	end
end

function GM:PlayerDeathThink( ply )
	if(JB_CONFIG.ConfigMode == false)then
		GAMEMODE:PlayerSpawnAsSpectator( ply )
	end
end

function GM:PlayerDeath( victm, inflictor, killer )
	victm:ShouldDropWeapon( true )
	--victm:SetNWBool("warden", false)
end

function OnChat( ply, text, public )
	if string.sub(text, 1,1) == "!" then
		text = string.lower(text)
		if (string.sub(text, 2, 11) == "whoswarden") then
			local warden = GetWarden()
			if warden == nil then
				ply:ChatPrint("No one is warden.")
			else
				local addon = ""
				if ply:IsAdmin() then
					addon = " Warden's SteamID is "..warden:SteamID()
				end
				ply:ChatPrint(warden:GetName() .. " is warden."..addon)
			end
		end
		if (string.sub(text, 2, 15) == "splitprisoners")then
			print("Called splitprisoners.")
			if(not ply:IsWarden())then
				ply:PrintMessage( HUD_PRINTTALK, "Only wardens can split prisoners into teams." )
				return false
			end
			if(#GetAlivePlayers(TEAM_PRISONERS) <= 1)then
				ply:PrintMessage( HUD_PRINTTALK, "There is only one prisoner, what is the point?" )
				return false
			end
			
			for i,v in pairs(GetAlivePlayers(TEAM_PRISONERS))do
				if math.random(1, 100) < 50 then
					v:SetColor(Color(255, 0, 0, 255))
				else
					v:SetColor(Color(0, 0, 255, 255))
				end
			end
		end
		if (string.sub(text, 2, 5) == "roll")then
			if not ply:IsWarden() then
				ply:PrintMessage( HUD_PRINTTALK, "Only wardens can roll numbers." )
				return false
			end
			text = string.Explode( " ", text )
			local max = 10
			if #text > 1 then
				max = tonumber(text[2])
				if max > 200 then
					ply:PrintMessage( HUD_PRINTTALK, "You can't roll above a 200!" )
					return false
				end
				PrintMessage( HUD_PRINTTALK, ply:GetName().." rolled a "..math.random(1, max).."." )
			end
		end
		if (string.sub(text, 2, 12) == "setaswarden")then
			print(ply:Name() .." with SteamID of "..ply:SteamID().. " is trying to call "..string.sub(text, 2))
			if not ply:IsAdmin() then
				ply:PrintMessage( HUD_PRINTTALK, "Only admins can set players as the warden." )
				return false
			end
			text = string.Explode( " ", text )
			local max = 10
			if #text > 1 then
				local p = GetPlayerByName(text[2])
				if p == nil then
					ply:PrintMessage( HUD_PRINTTALK, "That player doesn't exist." )
					return false
				end
				if not IsValid(p) then
					ply:PrintMessage( HUD_PRINTTALK, "That player doesn't exist." )
					return false
				end
				local warden = GetWarden()
				if warden == nil then
					p:SetAsWarden()
				else
					warden:SetNWBool("warden", false)
					p:SetAsWarden()
				end
				return false
			else
				ply:PrintMessage( HUD_PRINTTALK, "You must specify a player to set as warden." )
				return false
			end
		end
		return false
	end
	return true
end
hook.Add( "PlayerSay", "OnChat", OnChat )