PLUGIN.name = "Door Kick"
PLUGIN.author = "Thadah Denyse"
PLUGIN.desc = "Allows Combine to kick doors open."
// This plugin only works on models that have 'kickdoorbaton' animation (Basically, you must have a 'Combine' male model. (Like police.mdl)
// If the model hasn't got that animation, it'll disappear when the command is issued.


if CLIENT then
	local function ReceiveDoorKick(msg)		
		local client = msg:ReadEntity()
		local door = msg:ReadEntity()
		local ang = msg:ReadAngle()
	
		if IsValid(client) then
			if IsValid(client.kickDoorAnimObj) then client.kickDoorAnimObj:Remove() end
				local animObj = ents.CreateClientProp()
				animObj:SetModel(client:GetModel())
				animObj:SetPos(client:GetPos())
				animObj:SetAngles(ang)
				animObj:Spawn()
		
				local sequence = animObj:LookupSequence("adoorkick")
				animObj:SetSequence(sequence)
		
				client.kickDoorAnimObj = animObj
				client.kickAnimStartTime = CurTime()
		
				client:SetNoDraw(true)
				client:DrawViewModel(false)				
			end
		end
	usermessage.Hook( "door_kick", ReceiveDoorKick )

	local function KickDoorAnimationUpdate()	
		for _, client in pairs(player.GetAll()) do
			if IsValid(client.kickDoorAnimObj) then
				local deltaTime = CurTime() - client.kickAnimStartTime		
				if deltaTime < 1.4 then
					client.kickDoorAnimObj:SetCycle(deltaTime / 3)					
				else
					client:SetNoDraw(false)
					client:DrawViewModel(true)
					client.kickDoorAnimObj:Remove()		
				end	
			end	
		end	
	end
	hook.Add("Think", "door_kick_animation", KickDoorAnimationUpdate)

	-- To prevent the 'legs' to show up when you kick
	
	local function DrawLocalPlayer()
		return IsValid(LocalPlayer().kickDoorAnimObj)
	end
	hook.Add("ShouldDrawLocalPlayer", "door_kick_localplayer", DrawLocalPlayer)

	local function KickView(client, pos, ang)
		if IsValid(client.kickDoorAnimObj) then
			local origin = pos + client:GetAngles():Forward() * -64
			local angles = (pos - origin):Angle()
		
			local view = {
				["origin"] = origin,
				["angles"] = angles
			}	
		return view	
		end
	end
	hook.Add("CalcView", "doorkick_view", KickView)

end

nut.command.Register({
	syntax = "",
	onRun = function(client)
			
		local blockedDoors = {
		
			["rp_city8_spanish"] = {}
		
		}
		
		if !client:IsCombine() then
			
			nut.util.Notify("You are too weak to kick this door in!", client);
			return
			
		end
		
		if !client.isKickingDoor then
			
			local ent = client:GetEyeTraceNoCursor().Entity
			if IsValid(ent) and ent:GetClass() == "prop_door_rotating" then
			
				local dist = ent:GetPos():Distance( client:GetPos() )
				if dist > 60 and dist < 80 then
					
					local blocked = blockedDoors[game.GetMap()]
					if !blocked or !table.HasValue(blocked, ent:EntIndex()) then
					
						umsg.Start("door_kick")
						umsg.Entity(client)
						umsg.Entity(ent)
						umsg.Angle(client:GetAngles())
						umsg.End()
						
						client:Freeze(true)
						client.isKickingDoor = true
						
						timer.Simple(0.5, function()
				
							if IsValid(ent) then
								
								local door = ents.Create("prop_physics")
								door:SetPos(ent:GetPos())
								door:SetAngles(ent:GetAngles())
								door:SetModel(ent:GetModel())
								door:SetSkin(ent:GetSkin())
								door:Spawn()
								door:GetPhysicsObject():SetVelocity((door:GetPos() - client:GetPos()) * 8)
									
								door:EmitSound( string.format( "physics/wood/wood_plank_break%d.wav", math.random(1, 4)))
									
								ent:SetNoDraw(true)
								ent:SetNotSolid(true)
									
								timer.Simple(30, function()						
									if IsValid(ent) then			
										ent:SetNoDraw(false )
										ent:SetNotSolid(false)		
									end
								
									if IsValid(door) then door:Remove() end				
								end)	
							end
							
							timer.Simple( 0.9, function() 
							
								if IsValid( client ) then
							
									client:Freeze(false) 
									client.isKickingDoor = false 
								
								end	
							end)	
						end)
					
					else
						
						nut.util.Notify("This door can not be kicked in!", client)
						
					end
					
				elseif dist < 60 then
				
					nut.util.Notify("You are too close to kick the door down!", client)
				
				elseif dist > 80 then
					
					nut.util.Notify("You are too far to kick the door down!", client)			
				end
			else
				nut.util.Notify("You are looking at an invalid door", client)
			end
		end
	end
}, "doorkick")