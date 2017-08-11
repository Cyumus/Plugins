

if ( SERVER ) then

	resource.AddFile( "materials/VGUI/entities/weapon_broom.vmt" )
	resource.AddFile( "materials/VGUI/entities/weapon_broom.vtf" )

	AddCSLuaFile( "shared.lua" )

	SWEP.HoldType			= "crossbow"

	function SWEP:OnDrop()

		if ( IsValid( self.Weapon ) ) then
			self.Owner = nil
		end

	end

end

if ( CLIENT ) then

	SWEP.PrintName			= "Broom"
	SWEP.Author				= ""
	SWEP.IconLetter			= "."

	function SWEP:DrawWorldModel()

		local pPlayer = self.Owner 

		if ( !IsValid( pPlayer ) ) then
			self.Weapon:DrawModel() 
			return 
		end

		if ( !self.m_hHands ) then
			self.m_hHands = pPlayer:LookupAttachment( "anim_attachment_RH" ) 
		end

		local hand = pPlayer:GetAttachment( self.m_hHands ) 

		local offset = hand.Ang:Right() * self.HoldPos.x + hand.Ang:Forward() * self.HoldPos.y + hand.Ang:Up() * self.HoldPos.z 

		hand.Ang:RotateAroundAxis( hand.Ang:Right(),	self.HoldAng.x ) 
		hand.Ang:RotateAroundAxis( hand.Ang:Forward(),	self.HoldAng.y ) 
		hand.Ang:RotateAroundAxis( hand.Ang:Up(),		self.HoldAng.z ) 

		self.Weapon:SetRenderOrigin( hand.Pos + offset )
		self.Weapon:SetRenderAngles( hand.Ang )

		self.Weapon:DrawModel()

	end

end


SWEP.Base				= "swep_crowbar"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/props_c17/escoba.mdl"
SWEP.WorldModel			= "models/props_c17/escoba.mdl"
SWEP.ViewModelFOV		= 85
SWEP.UseHands = true

SWEP.Primary.Hit			= Sound( "Weapon_Crowbar.Single" )
SWEP.Primary.Damage			= 5.0

SWEP.HoldPos 			= Vector( 2, 0, 0 )
SWEP.HoldAng			= Vector( 11, 153, 15 )


SWEP.LowerAngles = Angle( 50, -20, -10 )


function SWEP:PrimaryAttack( traceHit )
	local vecSrc = self.Owner:GetShootPos()
	local dist = self.Owner:GetEyeTrace().HitPos:Distance( self.Owner:GetPos() )
	if dist >= 35 then
		dist = 0
	else
		for i = 0, 1 do
			local Pos1 = self.Owner:GetEyeTrace().HitPos + self.Owner:GetEyeTrace().HitNormal
			local Pos2 = self.Owner:GetEyeTrace().HitPos - self.Owner:GetEyeTrace().HitNormal
			
			util.Decal( "Splash.Large", Pos1, Pos2 )
			/*util.DecalEx("decals/beersplash_subrect", self.Owner, Pos1, Pos2, 255, 255, 255, 0, 1, 1)*/
		end
		local info = EffectData()
		info:SetNormal( self.Owner:GetEyeTrace().HitNormal )
		info:SetOrigin( self.Owner:GetEyeTrace().HitPos )
	end
end

