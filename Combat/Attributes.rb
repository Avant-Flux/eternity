# Attributes should be defined as modules.
# These ARE NOT mixins.
# These modules contain methods which are to be called for the application of
# effects relevant to their respective modules.

module Attribute
	module Fire
		class << self
			def Offensive(entity)
				# Apply effects associated with all offensive fire magic
				
			end
			
			def Support(entity)
				# Apply effects associated with all support fire magic
				
			end
			
			def burn(entity, rounds=1)
				# This method contains the logic for burning things
				# Apply a certain number of rounds worth of burn damage
				# Apply the burn status
				# 	This way, the status can be used to call burn again next round
				if entity.attributes[:flammable] || entity.status[:flammable]
					# Create struct to track the burning
					unless entity.status[:burning]
						burn = Struct.new(:rounds, :spell)
						entity.status[:burning] = burn.new(rounds, spell)
					end
					
					# Apply burn if there are rounds remaining
					burn = entity.status[:burning]
					burn.rounds -= 1
					
					# Apply the actual burn effect
					
					
					if burn.rounds == 0
						entity.status[:burning] = nil
					end
				end
			end
			
			def explode(entity, knockback=1)
				# Fire element knockback effect
				# Knockback and perhaps also apply "residual" fire damage
				
			end
		end
		
		Burn = Struct.new(:rounds, :spell)
	end
	
	module Water
		class << self
			
		end
	end
	
	module Wind
		class << self
			def spirit_hit(entity, rounds=1)
				# Wind DoT
				# After a certain delay, the target gets hit with a flurry
				# of spectral blows
				
			end
		end
	end
	
	module Earth
		class << self
			def shove(entity, knockback=1)
				# Earth element knockback effect
				
			end
		end
	end
end
