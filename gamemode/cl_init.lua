include("shared.lua")
if CLIENT then
	surface.CreateFont( "Deathrun_Smooth", { font = "Trebuchet18", size = 14, weight = 700, antialias = true } )
	surface.CreateFont( "Deathrun_SmoothMed", { font = "Trebuchet18", size = 24, weight = 700, antialias = true } )
	surface.CreateFont( "Deathrun_SmoothBig", { font = "Trebuchet18", size = 34, weight = 700, antialias = true } )
end

if SERVER then return end

--include("cl_hud.lua")

function draw.AAText( text, font, x, y, color, align )

    draw.SimpleText( text, font, x+1, y+1, Color(0,0,0,math.min(color.a,120)), align )
    draw.SimpleText( text, font, x+2, y+2, Color(0,0,0,math.min(color.a,50)), align )
    draw.SimpleText( text, font, x, y, color, align )

end

function GM:PostDrawViewModel( vm, ply, weapon )
	if ( weapon.UseHands || !weapon:IsScripted() ) then
		local hands = LocalPlayer():GetHands()
		if ( IsValid( hands ) ) then hands:DrawModel() end
	end
end

local PLAYER = getmetatable("Player")

local hudElementsDontDraw = { "CHudHealth"}

function GM:OnSpawnMenuOpen()
    net.Start( "DropWeapon" )
	net.SendToServer()
end

-- INPUT --
local keys = {}
local prevKeys = {}

hook.Add( "Think", "InputCheck", function ()
	keys[KEY_Z] = input.IsKeyDown(KEY_Z)
	if(keys[KEY_Z] == true and prevKeys[KEY_Z] == false)then
		ClientCreateWardenPoint()
	end
	prevKeys[KEY_Z] = keys[KEY_Z]
end)

function ClientCreateWardenPoint()
	net.Start( "WardenPoint" )
	net.SendToServer()
	-- We do this so everyone can see the warden point, and I hope this isn't ugly.
end

local function ChangeTeams()
    local Menu = vgui.Create("DFrame")
    Menu:SetPos(ScrW() / 2 - 400, ScrH() / 2 - 400)
    Menu:SetSize(800, 700)
    Menu:SetText("My Menu")
    Menu:SetDraggable(false)
    Menu:ShowCloseButton(true)
    Menu:MakePopup()
 
    local Text = vgui.Create("DLabel",Menu)
    //You can leave out the parentheses if there is a single string as an argument.
    Text:SetText("Choose your team:")
	Text:SizeToContents()
    Text:Center()
end
usermessage.Hook("ChangeTeamsGUI", ChangeTeams)

-- Hide Original Hud --
 function hidehud(name)
	for i,v in pairs(hudElementsDontDraw)do
		if name == v then
			return false
		end
	end
	return true
end
hook.Add("HUDShouldDraw", "HideOurHud:D", hidehud)