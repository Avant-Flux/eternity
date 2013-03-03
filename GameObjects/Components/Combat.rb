module Component
	class Combat
		def initialize(animation)
			# TODO: Create better Model ID assigning algorithm
			@animation = animation
			
			@attack_right = true # either swing sword to the left, or to the right
			@animation["sword_r-l"].loop = false
			@animation["sword_l-r"].loop = false
		end
		
		def update(dt)
			animation =	if @attack_right
							# puts "right"
							@animation["sword_l-r"]
						else
							# puts "left"
							@animation["sword_r-l"]
						end
			
			# Revert rate to normal when foot hits the ground
			# This way, the actual slash is always at the same rate.
			# 
			# NOTE:
			# This does not work if we want really real sword animation,
			# where the foot should hit the ground at the same time the sword connects.
			# In that case, sync time of step to stepping portion of swing
			# 	Syncing timing of step to sword animation should happen in #attack
			# 	but the rate of playback should be constant, and should override
			# 	movement animations.
			
			# Transition out
			if animation.ended?
				animation.disable
				animation.time = 0.0
				
				# Attack from the other side next time
				@attack_right = !@attack_right
			end
		end
		
		def attack
			# puts "ATTACK"
			
			# NOTE: Plays same animation multiple times if you attempt to cancel an attack into another attack
			# Want to make it so you can't cancel attacks, to improve animation, but want to be able to attack again at the end of the attack animation to transition smoothly into another attack
			a =	if @attack_right
					puts "right"
					@animation["sword_r-l"].disable
					
					@animation["sword_l-r"]
				else
					puts "left"
					@animation["sword_l-r"].disable
					
					@animation["sword_r-l"]
				end
			
			a.enable
			
			
			# Sync stepping portion of animation with the movement rate
			a.time = 0.0
			# a.rate = 1.0			
		end
	end
end