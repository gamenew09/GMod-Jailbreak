AddCSLuaFile() -- Make sure clientside

ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "Warden Point"
ENT.Author = "Gamenew09"
ENT.Purpose = "Used for JailBreak."

ENT.Spawnable = false
ENT.AdminSpawnable = false

ENT.rotate = 0
ENT.lasttime = SysTime()

function ENT:Initialize()
 
	--self:SetModel( "models/props_interiors/BathTub01a.mdl" ) -- Temporary Model
	self:SetHealth(10000)
	self:PhysicsInit( SOLID_NONE )      -- Make us work with physics,
	self:SetMoveType( MOVETYPE_VPHYSICS )   -- after all, gmod is a physics
	self:SetSolid( SOLID_NONE )         -- Toolbox
 
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
end

function ENT:Draw()
	//Drawing the model
	--self:DrawModel()
	
	local Pos = self:GetPos() + Vector(0, 0, 20)
	local Ang1 = Angle( 0, 0, 90 )
	local Ang2 = Angle( 0, 0, 90 )
	
	Ang1:RotateAroundAxis( Ang1:Right(), self.rotate )
	Ang2:RotateAroundAxis( Ang2:Right(), self.rotate + 180 )
	
	local text = "Warden Point"
	local fontName = "Deathrun_SmoothBig"
	
	cam.IgnoreZ(true)
	
	//Draws front
	cam.Start3D2D( Pos + Ang1:Up() * 0, Ang1, 0.2 )
		draw.DrawText( text, fontName, 0, -50, Color( 0, 255, 0, 255 ),TEXT_ALIGN_CENTER )
	cam.End3D2D()
	
	//Draws back
	cam.Start3D2D( Pos + Ang2:Up() * 0, Ang2, 0.2 )
		draw.DrawText( text, fontName, 0, -50, Color( 0, 255, 0, 255 ),TEXT_ALIGN_CENTER )
	cam.End3D2D()
	
	cam.Start3D2D( self:GetPos() + Ang2:Up() * 0, Angle(0, 0, 0), 0.2 )
		-- 0, -50
		surface.SetDrawColor(Color( 255, 255, 255, 255 ))
		surface.DrawRect(-50, -50, 128, 128)
	cam.End3D2D()
	
	cam.IgnoreZ(false)
	
	//Resets the rotation
	if( self.rotate > 359 ) then self.rotate = 0 end
	
	//Rotates
	self.rotate = self.rotate - ( 100*( self.lasttime-SysTime() ) )
	self.lasttime = SysTime()
end

function ENT:Think()
    -- We don't need to think, we are just a prop after all!
end