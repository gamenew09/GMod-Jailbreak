function GetWarden()
	for i,v in pairs(player.GetAll())do
		if v:GetNWBool( "warden" ) == true then
			if IsValid(v) then
				return v
			end
		end
	end
	return nil -- No one is warden, send an empty variable, aka nil.
end

function DrawProgressBar(posx, posy, sizex, sizey, value, inColor, textBef, textAft)
	draw.RoundedBox( 4, posx, posy, sizex, sizey, Color(40, 40, 40, 30))
	if value > 0 then
		draw.RoundedBox( 4, posx, posy, math.Clamp(value, 0, 200) * 2, sizey, inColor)
		draw.RoundedBox( 4, posx, posy, math.Clamp(value, 0, 200) * 2, sizey, Color(255, 255, 255, 40))
	end
	surface.SetFont("Deathrun_SmoothBig")
	local tW, tH = surface.GetTextSize(tostring(value))
	if textBef then
		textBef = tostring(textBef)
		textAft = tostring(textAft)
		if textAft == "nil"then
			textAft = ""
		end
		draw.DrawText( textBef..tostring(value)..textAft, "Deathrun_SmoothBig", posx+(200 / 2), posy, Color( 255,255,255,255 ), TEXT_ALIGN_CENTER )
	else
		draw.DrawText( tostring(value), "Deathrun_SmoothBig", posx+(200 / 2), posy, Color( 255,255,255,255 ), TEXT_ALIGN_CENTER )
	end
end

function CoolHud()
	local ply = LocalPlayer()
	local HP = ply:Health()
	local Armor = ply:Armor()
	
	draw.RoundedBox( 4, 0, 0, 200, 40, Color(255, 255, 255, 255))
	
	if(GetWarden() == nil)then		
		draw.DrawText( "Warden is dead! Freeday!", "Deathrun_Smooth", (200 / 2), 10, Color( 0,0,0,255 ), TEXT_ALIGN_CENTER )
	else
		draw.DrawText( "Warden: "..GetWarden():Name(), "Deathrun_Smooth", 200 / 2, 10, Color( 0,0,0,255 ), TEXT_ALIGN_CENTER )
	end
	DrawProgressBar(130, ScrH() - 100, 200, 40, math.max(HP, 0), Color(220, 108, 108, 255), "Health: ")
	if Armor >= 1 then
		DrawProgressBar(335, ScrH() - 100, 200, 40, Armor, Color(115, 115, 235, 255), "Armor: ")
	end
end

hook.Add("HUDPaint", "jb_hud", CoolHud)