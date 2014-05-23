local meta = FindMetaTable("Player") --Get the meta table of player

-- Warden Functions --

function meta:SetAsWarden()
	if (GetWarden() ~= nil)then return false end
	self:SetNWBool("warden", true)
	return true
end

function meta:LaunchInAir(times, force, random, timewait) -- Thanks ChrisRulesTheWorld
	if type(times) ~= "number" then times = 1 end 
	if type(force) ~= "number" then force = 1000 end 
	if type(random) ~= "boolean" then random = false end
	if type(timewait) ~= "number" then timewait = 2 end
	local tF = force
	for i = 1, times do
		if random then
			force = math.random(234, tF)
		end
		self:SetVelocity( pl:GetAimVector() * force )
		if times ~= 1 then
			wait(2)
		end
	end
end

function meta:IsWarden()
	return self:GetNWBool( "warden" ) == true
end