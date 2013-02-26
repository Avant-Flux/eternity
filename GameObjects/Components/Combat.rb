module Component
	class Combat
		def initialize(animation)
			# TODO: Create better Model ID assigning algorithm
			@animation = animation
			
			@attack_left = true # either swing sword to the left, or to the right
		end
		
		def update(dt)
			animation =	if @attack_left
							@animation["sword_r-l"]
						else
							@animation["sword_l-r"]
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
			
			# Turn it off if it's over
			if animation.ended?
				animation.disable
				animation.time = 0.0
			end
		end
		
		def attack
			# puts "ATTACK"
			@animation["sword_r-l"].disable
			@animation["sword_l-r"].disable
			
			a =	if @attack_left
					puts "left"
					@animation["sword_r-l"]
				else
					puts "right"
					@animation["sword_l-r"]
				end
			@attack_left = !@attack_left
			
			
			# p @animation.animations
			a.enable
			a.loop = false
			
			a.time = 0.0
			
			# Sync stepping portion of animation with the movement rate
			
		end
	end
end