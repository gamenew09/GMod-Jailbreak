-- First some standard GMod stuff
if SERVER then
   AddCSLuaFile( )
end

if CLIENT then
   SWEP.PrintName = "Weapon Checker"
   SWEP.Slot      = 0 -- add 1 to get the slot number key

   SWEP.ViewModelFOV  = 72
   SWEP.ViewModelFlip = true
end

SWEP.IllegalWeapons = {
	"ptp_cs"
}

-- Always derive from weapon_tttbase.
SWEP.Base				= "weapon_base"

--- Standard GMod values

SWEP.HoldType			= "ar2"

SWEP.Primary.ClipSize			= -1
SWEP.Primary.Damage			= 100
SWEP.Primary.DefaultClip		= -1
SWEP.Primary.Automatic			= true
SWEP.Primary.Ammo			="none"

SWEP.IronSightsPos = Vector( 6.05, -5, 2.4 )
SWEP.IronSightsAng = Vector( 2.2, -0.1, 0 )

SWEP.ViewModel  = "models/weapons/v_c4.mdl"
SWEP.WorldModel = "models/weapons/w_c4.mdl"

local deb = false

function SWEP:PrimaryAttack()
	
	if deb then return end
	
	deb = true
	
	local tr = {}
	tr.start = self.Owner:GetShootPos()
	tr.endpos = self.Owner:GetShootPos() + ( self.Owner:GetAimVector() * 100 )
	tr.filter = self.Owner
	tr.mask = MASK_SHOT
	local trace = util.TraceLine( tr )

	self.Weapon:SetNextPrimaryFire(CurTime() + 0.9)
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	
	if(trace.Hit)then
		if trace.Entity:IsPlayer() then
			local ilWeapons = {}
			local ply = trace.Entity
			local weaps = ply:GetWeapons()
			for i,v in pairs(weaps)do
				for i2, v2 in pairs(self.IllegalWeapons)do
					if(v2 == v:GetClass() or string.find(v:GetClass(), v2) ~= nil)then
						table.insert(ilWeapons, v)
					end
				end
			end
			local ilWeaponsStr = ""
			for i,v in pairs(ilWeapons)do
				ilWeaponsStr = ilWeaponsStr .. v:GetPrintName().."\n"
			end
			ply:PrintMessage(HUD_PRINTTALK, "Illegal Weapons: \n"..ilWeaponsStr)
		end
	end
	
	deb = false
	
end

/*---------------------------------------------------------
Reload
---------------------------------------------------------*/
function SWEP:SecondaryAttack()

end
/*---------------------------------------------------------
Reload
---------------------------------------------------------*/
function SWEP:Reload()
	return false
end

