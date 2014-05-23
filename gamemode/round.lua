ROUND_TIMER = {}

ROUND_TIMER.RoundTime = {}
ROUND_TIMER.RoundTime[1] = CONVAR_ROUNDLENGTH:GetInt() --This is a round. The 600 is how long in seconds the round will last.
ROUND_TIMER.RoundTime[2] = 10
----------SCRIPT DEFINITION--------
--Once the first round is complete, the next round will be initiated.
--This script was specifically designed to have one, ten minute round, which would end if every player died.
--No only that, but once a player is dead during the first round, they can not respawn until the round is over.
--The second round is basically an "in between" round, if a player dies during this round they are able to respawn right away.
--If a player is dead when the first round starts, they will be respawned for the round.
--The second round is there to give dead players time to respawn, and give the game server time to adjust anything before the first round starts again.
----------SCRIPT DEFINITION----------

----------FOR PEOPLE MODIFYING THIS SCRIPT--------
--Please provide credit where credit is due. find me, which is me, is the creator of this base script.--
--
--"ROUND_TIMER.Round" is a number variable which will give you the current round serverside or clientside.
--"ROUND_TIMER.Rounds" is a number variable which will tell you how many rounds currently exist.
--
--"RoundInitiated" is a hook that is run once a new round has begun, this is servside and clientside hook, here is an example use:
----function MY_FUNCTION()
----    if ROUND_TIMER.Round == 1 then
----        print("HEY! The first round is starting guys.")
----    end
----end
----hook.Add("RoundInitiated", "Description of my function.", MY_FUNCTION)
--
--Calling the function "ROUND_TIMER:NextRound()" will stop the current round and begin the next one immediately.
--Calling the function "ROUND_TIMER:GetRound()" will return the current round as a number variable relative to the "ROUND_TIMER.RoundTime" table.
----------FOR PEOPLE MODIFYING THIS SCRIPT----------

ROUND_TIMER.Time_Began = CurTime()
ROUND_TIMER.Rounds = #ROUND_TIMER.RoundTime
ROUND_TIMER.Round = 1

ROUND_TIMER.GetRound = function()
    return ROUND_TIMER.Round
end

ROUND_TIMER.NextRound = function()
    if ROUND_TIMER.Round == ROUND_TIMER.Rounds then
        ROUND_TIMER.Round = 1
    else
        ROUND_TIMER.Round = ROUND_TIMER.Round+1
    end

    if SERVER then
        umsg.Start("ROUND_TIMER_UpdateClient")
            umsg.Short(ROUND_TIMER.Round)
        umsg.End()
    end

    hook.Call("RoundInitiated")
    hook.Call("Round_Looping")
end

if SERVER then --SERVERSIDE WORK
    ROUND_TIMER.Loop = function()
        timer.Adjust("Round_Timer_Mod", ROUND_TIMER.RoundTime[ROUND_TIMER.Round], 0, function()
            ROUND_TIMER:NextRound()
			game.CleanUpMap() -- Resets everything, just like cleaning up in Sandbox.
			for i,v in pairs(player.GetAll())do
				v:SetColor(Color(255,255,255,255))
			end
        end)
    end
    hook.Add("Round_Looping", "Beginning the loop, this creates a never ending round system.", ROUND_TIMER.Loop)

    timer.Create("Round_Timer_Mod", ROUND_TIMER.RoundTime[ROUND_TIMER.Round], 0, function()end)
    ROUND_TIMER:Loop()

    ROUND_TIMER.DeathCheck = function(pl, attacker, dmginfo)
		//GAMEMODE:PlayerSpawnAsSpectator(pl)
        if ROUND_TIMER.Round == 1 then
			local prisonerAlive = GetAlivePlayers( 1 )
			local gaurdsAlive = GetAlivePlayers( 2 )
            if #prisonerAlive == 0 or #gaurdsAlive == 0 then
                ROUND_TIMER:NextRound()
				game.CleanUpMap() -- Resets everything, just like cleaning up in Sandbox.
				for i,v in pairs(player.GetAll())do
					v:SetColor(Color(255,255,255,255))
				end
            end
        end
    end
    hook.Add("PlayerDeathThink", "Disable spawning until new round.", ROUND_TIMER.DeathCheck)

    ROUND_TIMER.Initiate_Round = function()
        if ROUND_TIMER.Round == 1 then
            for k, v in pairs(player.GetAll()) do
                v:PrintMessage(HUD_PRINTCENTER, "A new round has begun!")
				--v:SetTeam()
				v:Spawn()
            end
        end
    end
    hook.Add("RoundInitiated", "Round has Initiated.", ROUND_TIMER.Initiate_Round)

end

if CLIENT then
	surface.CreateFont("ROUND_TIMER_Display", {
		font        = "Arial",
		size        = 25,
		weight        = 1000
	})

	usermessage.Hook("ROUND_TIMER_UpdateClient", function(msg)
		ROUND_TIMER.Round = msg:ReadShort()
		ROUND_TIMER.Time_Began = CurTime()
	end)

	ROUND_TIMER.HUD = function()
		local TimeLeft = math.Round((ROUND_TIMER.Time_Began+ROUND_TIMER.RoundTime[ROUND_TIMER.Round])-CurTime())
		local time2
		if(TimeLeft % 60 < 10)then
			time2 = "0"..TimeLeft % 60
		else
			time2 = TimeLeft % 60
		end
		
		local time = math.Round(math.max(TimeLeft/60, 0))..":"..time2
		
		if(ROUND_TIMER.Round == 1)then
			draw.SimpleTextOutlined("Round ends in: "..time, "ROUND_TIMER_Display", ScrW()/2, 20, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
		else
			draw.SimpleTextOutlined("Intermission ends in: "..TimeLeft, "ROUND_TIMER_Display", ScrW()/2, 20, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
		end
	end
	hook.Add("HUDPaint", "Draw Round Timer display.", ROUND_TIMER.HUD)
end