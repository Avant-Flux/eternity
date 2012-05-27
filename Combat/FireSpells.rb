# All Fire spells are contained in this file

module Spells
	module Fire
		class FireSpell < Spell
			# Include abilities which are common to all fire spells (if any)
			element			:fire
		end
		
		class Fireball < FireSpell
			include Offensive
			
			attributes		:burn, :explode
			range			:projectile	# short, mid, far, projectile, siege
			area_of_effect	:splash
			
			mp_cost			10
			power			20
			charge_time		2000		# In milliseconds
		end
		
		class FireBurst < FireSpell
			include Offensive
			
			attributes		:burn, :explode
			range			:projectile
			area_of_effect	:splash
			
			mp_cost			10
			power			20
			charge_time		2000	
		end
		
		class Flamethrower < FireSpell
			include Offensive
			
			attributes		:burn, :cleave # Cleave just means that attacks hit all in pattern
			range			:far
			area_of_effect	:line
			
			mp_cost			20
			power			30
			charge_time		1000
		end
	end
end
