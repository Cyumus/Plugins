

if ( SERVER ) then

	// resource.AddFile( "materials/VGUI/entities/.vmt" )
	// resource.AddFile( "materials/VGUI/entities/.vtf" )

	AddCSLuaFile( "shared.lua" )

	function SWEP:OnDrop()

		if ( ValidEntity( self.Weapon ) ) then
			self.Owner = nil
		end

	end

end

if ( CLIENT ) then

	SWEP.PrintName			= "Scripted Weapon"
	SWEP.Author				= ""
	SWEP.IconLetter			= "."


	function SWEP:DrawWorldModel()

		local pPlayer = self.Owner;

		if ( !ValidEntity( pPlayer ) ) then
			self.Weapon:DrawModel();
			return;
		end

		if ( !self.m_hHands ) then
			self.m_hHands = pPlayer:LookupAttachment( "anim_attachment_RH" );
		end

		local hand = pPlayer:GetAttachment( self.m_hHands );

		local offset = hand.Ang:Right() * self.HoldPos.x + hand.Ang:Forward() * self.HoldPos.y + hand.Ang:Up() * self.HoldPos.z;

		hand.Ang:RotateAroundAxis( hand.Ang:Right(),	self.HoldAng.x );
		hand.Ang:RotateAroundAxis( hand.Ang:Forward(),	self.HoldAng.y );
		hand.Ang:RotateAroundAxis( hand.Ang:Up(),		self.HoldAng.z );

		self.Weapon:SetRenderOrigin( hand.Pos + offset )
		self.Weapon:SetRenderAngles( hand.Ang )

		self.Weapon:DrawModel()

	end

end


SWEP.HoldType			= "pistol"
SWEP.Base				= "swep_357"

SWEP.Spawnable			= false
SWEP.AdminSpawnable		= false

SWEP.ViewModel			= ""
SWEP.WorldModel			= ""

SWEP.HoldPos 			= Vector( 0, 0, 0 )
SWEP.HoldAng			= Vector( 0, 0, 0 )

function SWEP:CanPrimaryAttack()
	return false
end

function SWEP:CanSecondaryAttack()
	return false
end
