ENT.Type = "anim"
ENT.PrintName = "Base Reader"
ENT.Author = "La Corporativa"
ENT.Spawnable = false
ENT.AdminOnly = false
ENT.Category = "NutScript"


if (SERVER) then

	function ENT:Initialize()
		self:SetModel("models/props_combine/combine_smallmonitor001.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_NONE)
		self:SetUseType(SIMPLE_USE)
		local p = self:GetPhysicsObject()
		p:EnableCollisions( false )
	end

	function ENT:Use(activator)
		local status = 0
		if (!activator.nextUse or activator.nextUse < CurTime()) then
			local inventory = activator:getChar():getInv()
			for _, v in pairs(self.Cards) do
				if (inventory:hasItem(v)) then
					status = 1
					break
				end
			end
		end

		if (status != 1) then
			status = 2
			self:EmitSound("buttons/combine_button2.wav")
		end

		if (self.door and status == 1) then
			for _, door in pairs( ents.FindInSphere( self.door, 5 ) ) do
				if IsValid(door) then
					self:EmitSound("buttons/combine_button1.wav")
					door:Fire( "unlock", .1 )
					door:Fire( "open", .1 )

					timer.Simple(nut.config.get("openTime", 4.0), function()
						door:Fire( "close", .1 )
						door:Fire( "lock", .1 )
					end)
				end
			end
		end

		netstream.Start(activator, "changeStatus", status)
		activator.nextUse = CurTime() + 1
	end

else

	local status = 0
	local resetTime = 0
	local curstat = {
		[0] = {	"Unknown Level", { 90, 150, 170 }},
		[1] = { "Granted", { 90, 150, 100 }},
		[2] = { "Denied", { 150, 20, 20 } },
	}

	local grd = surface.GetTextureID("vgui/gradient_down")

	function ENT:Initialize()
		self.width = 170
		self.height = 180
		self.scale = .1
	end

	function ENT:Think()
		if resetTime < CurTime() then
			status = 0
		end
		self:NextThink( CurTime() + 1 )
	end

	function ENT:Draw()

		self:DrawModel()
		if LocalPlayer():GetPos():Distance( self:GetPos() ) > 200 then return end

		local pos, ang = self:GetPos(), self:GetAngles()
		local wide, tall = 165, 180
		pos=pos+self:GetRight()*7
		pos=pos+self:GetForward()*13
		pos=pos+self:GetUp()*20

		ang:RotateAroundAxis(ang:Up(), 90)
		ang:RotateAroundAxis(ang:Forward(), 90)

		cam.Start3D2D(pos, ang, .1)

			local alpha = 120 + math.sin( RealTime() * 80 ) * 10
			surface.SetDrawColor(80,80,80,alpha)
			surface.DrawRect(0,0,wide,tall)

			surface.SetTexture(grd)
			surface.SetDrawColor(10,10,10,alpha)
			surface.DrawTexturedRect(0,0,wide,tall)


			local alpha2 = math.abs( math.cos( RealTime() * 80 ) * 100 )
			local text = "Access Control"
			local tx, ty = surface.GetTextSize( text )
			/*
			surface.SetFont("DermaDefaultBold")
			surface.SetTextColor(255,255,255,255 - alpha2 )
			surface.SetTextPos( wide / 2 - tx / 2 ,60)
			surface.DrawText( text )
			*/
			draw.DrawText(text, "DermaDefaultBold", wide/2 - tx/2, 60, Color(255,255,255,255 - alpha2), 0)

			local text = "Unknown"

			if (status == 0) then
				text = self.Level
			else
				text = curstat[ status ][1]
			end


			local tx, ty = surface.GetTextSize( text )
			local col = curstat[ status ][2]
			/*
			surface.SetFont("DermaLarge")
			surface.SetTextColor( col[1]/2 , col[2]/2 , col[3]/3 ,255 - alpha2 )
			surface.SetTextPos( wide / 2 - tx / 2 + math.random( -2, 2 ), tall/2 - ty/2 + math.random( -2, 2 ))
			surface.DrawText( text )
			*/
			draw.DrawText(text, "DermaLarge", wide/2 - tx/2 + math.random(-2,2), tall/2 - ty/2 + math.random(-2,2), Color(col[1]/2 , col[2]/2 , col[3]/3 ,255 - alpha2), 0)
			/*
			surface.SetTextColor( col[1] , col[2] , col[3] ,255 - alpha2 )
			surface.SetTextPos( wide / 2 - tx / 2 , tall/2 - ty/2 )
			surface.DrawText( text )
			*/
			draw.DrawText(text, "DermaLarge", wide/2 - tx/2, tall/2 - ty/2, Color(col[1] , col[2] , col[3] ,255 - alpha2), 0)


		cam.End3D2D()
	end

	netstream.Hook("changeStatus", function(data)
		status = data
		resetTime = CurTime() + 2
	end)

end
