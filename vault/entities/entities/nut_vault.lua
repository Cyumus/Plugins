AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Vault"
ENT.Author = "Cyumus"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.Category = "NutScript"

function ENT:SetupDataTables()

	self:DTVar( "Bool", 0, "BeingDrilled" );
	self:DTVar( "Float", 1, "DrillTime");
	self:DTVar( "Bool", 2, "BrokenInto")

end

if (SERVER) then
	function ENT:Use(activator)
		if (self.state) then
			if (!self.owner) then
				self.owner = activator:Name()
			end
			if (self.owner == activator:Name()) then
				if (self.state == "robbed") then
					nut.util.Notify("The lock has been forced with a drill and you have been robbed!", activator)
				elseif (self.state == "closed") then
					self.state = "opened"
					self:SetNetVar("state", "opened")
					nut.util.Notify("You opened the vault.", activator)
				elseif (self.state == "opened") then
					self:SetNetVar("state", "closed")
					self.state = "closed"
					nut.util.Notify("You closed the vault.", activator)
				end				
			else
				nut.util.Notify("You're not the owner of this vault.", client)
			end
		end
	end
	function ENT:Initialize()
		self:SetModel("models/props_vtmb/safe.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		self.money = self.money or 0
		
		self:SetNetVar("state", self.state or "closed")
		self:SetNetVar("owner", self.owner)
		
		local physicsObject = self:GetPhysicsObject()

		if (IsValid(physicsObject)) then
			physicsObject:Wake()
		end
		self:SetDTBool(0, false)
		self:SetDTBool(2, false)
		print(self:GetClass())

	end
	
	function ENT:SetAmount(arg1, arg2)

		if arg1 == "BeingDrilled" then
			
			self:SetDTBool(0, arg2)

		elseif arg1 == "DrillTime" then
			
			self:SetDTFloat(1, arg2)

		end

	end;

	function ENT:drillIntoVault()

		if self:GetDTBool(2) == true then return end;

		self:SetAmount("BeingDrilled", true)
		
		self:SetDTBool(2, true)

		local drill = ents.Create( "prop_dynamic" ) 

		local physicsObject = self:GetPhysicsObject()

		drill:SetParent( physicsObject:GetEntity() )
		drill:SetModel("models/warz/melee/powerdrill.mdl")
		drill:SetPos(self:GetPos() + (self:GetForward() * 30) + (self:GetRight() * -13) + (self:GetUp() * 20))
		drill:SetAngles(self:GetAngles() + Angle(0, 180, 0))
		drill:Spawn()

		local sparks = ents.Create("env_spark")

		sparks:SetParent( drill )
		sparks:SetPos(self:GetPos() + (self:GetForward() * 21) + (self:GetRight() * -13) + (self:GetUp() * 22))
		sparks:Fire("StartSpark","",0)

		sparks:Spawn()

		print(drill:GetPos())


		for i = 1, self:GetDTFloat(1) do

			timer.Simple(i, function()

				local timeLeft = self:GetDTFloat(1)
				local newTimeLeft = timeLeft - 1

				self:SetDTFloat(1, newTimeLeft)

			end)

		end

		timer.Simple(self:GetDTFloat(1), function()

			drill:Remove()
			sparks:Remove()

			self:SetDTBool(0, false)
			
			
			if (self.money) then
				nut.currency.Spawn(self.money, self:GetPos() + self:GetForward() * 50)
				
				self.money = 0
				self:SetDTBool(0, false)
				self:SetDTBool(2, false)
				self.state = "robbed"
				self:SetNetVar("state", "robbed")
			end
		end)

	end

elseif (CLIENT) then

local glowMaterial = Material("sprites/glow04_noz");

-- Called when the entity should draw.
function ENT:Draw()
	self:DrawModel();
	
	local r, g, b, a = self:GetColor();
	local angles = self:GetAngles();
	local position = self:GetPos();

	local fix_angles = self.Entity:GetAngles()
	local fix_rotation = Vector(0, 90, 90)
	position = position + self:GetRight()*-12
	position = position + self:GetForward()*1
	position = position + self:GetUp()*14
	fix_angles:RotateAroundAxis(fix_angles:Right(), fix_rotation.x)
	fix_angles:RotateAroundAxis(fix_angles:Up(), fix_rotation.y)
	fix_angles:RotateAroundAxis(fix_angles:Forward(), fix_rotation.z)

	local beingDrilled = self:GetDTBool(0)
	local drillTime    = self:GetDTFloat(1)
	local state = self:GetNetVar("state")
	if (state) then
		if (state == "robbed") then
			cam.Start3D2D( position + (self:GetUp() * 18) + (self:GetForward() * 20) + (self:GetRight() * 11.75), fix_angles, 0.25 )
				draw.DrawText("Broken", "DermaDefaultBold", 0, 0, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER )
			cam.End3D2D();
		elseif (state == "opened") then
			cam.Start3D2D( position + (self:GetUp() * 18) + (self:GetForward() * 20) + (self:GetRight() * 11.75), fix_angles, 0.25 )
				draw.DrawText("Opened", "DermaDefaultBold", 0, 0, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER )
			cam.End3D2D();
		elseif (state == "closed") then
			cam.Start3D2D( position + (self:GetUp() * 18) + (self:GetForward() * 20) + (self:GetRight() * 11.75), fix_angles, 0.25 )
				draw.DrawText("Closed", "DermaDefaultBold", 0, 0, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER )
			cam.End3D2D();
		end
	end
	
	if beingDrilled == true then

		cam.Start3D2D( position + (self:GetUp() * 14) + (self:GetForward() * 20) + (self:GetRight() * 0), fix_angles, 0.25 )
			draw.DrawText(drillTime, "DermaDefaultBold", 0, 0, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER )
		cam.End3D2D();

	end
	
	

end;
end