GM.Name = "JailBreak"
GM.Author = "Gamenew09"
GM.Email = "gamenew09@gmail.com"
GM.Website = "http://gamenew09.com"

DeriveGamemode( "base" )

-- Shared Includes --

AddCSLuaFile("config.lua")
AddCSLuaFile("cl_hud.lua")
AddCSLuaFile("sh_player.lua")
AddCSLuaFile()
if CLIENT then
	include("sh_player.lua")
	include("cl_hud.lua")
end
include("config.lua")

-- Convars --
CONVAR_ROUNDLENGTH = CreateConVar( "jb_roundlength", "210", { FCVAR_NOTIFY }, "The JailBreak round length in seconds.")

-- Set up teams --

TEAM_PRISONERS = 1
TEAM_GUARDS = 2
TEAM_DEAD = TEAM_SPECTATOR

team.SetUp(TEAM_PRISONERS, "Prisoners", Color( 255, 0, 0))
team.SetUp(TEAM_GUARDS, "Guards", Color( 0, 0, 255))
team.SetUp(TEAM_DEAD, "Spectator", Color( 0, 0, 0))

-- UTIL Functions --

function GetAlivePlayers( teamnum )
	local pool = {}
	for i,v in pairs(GetPlayersInTeam( teamnum )) do
		if IsValid(v)then
			if v:Alive() then
				table.insert(pool, v)
			end
		end
	end
	return pool
end

function GetPlayerByName(name)
	for i,v in pairs(player.GetAll())do
		if v:Name():lower() == name:lower() then
			return v
		end
	end
	return nil
end

function GetPlayersInTeam( teamnum )
	local pool = {}
	for i,v in pairs(player.GetAll())do
		if IsValid(v) then
			if v:Team() == teamnum then
				table.insert(pool, v)
			end
		end
	end
	return pool
end

function GetWarden()
	for i,v in pairs(player.GetAll())do
		if v:IsWarden() then
			if IsValid(v) then
				return v
			end
		end
	end
	return nil -- No one is warden, send an empty variable, aka nil.
end

function GM:Initialize()
	self.BaseClass.Initialize( self )
end

function file.AppendLine(filename, addme)
	data = file.Read(filename)
	if ( data ) then
		file.Write(filename, data .. "\n" .. tostring(addme))
	else
		file.Write(filename, tostring(addme))
	end
end

AddCSLuaFile("round.lua")
include("round.lua")