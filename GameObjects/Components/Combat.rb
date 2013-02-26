module Component
	class Combat
		def initialize(animation)
			# TODO: Create better Model ID assigning algorithm
			@animation = animation
		end
		
		def update(dt)
			animation = @animation["sword_r-l"]
			if animation.time >= animation.length
				puts "DISABLE: #{animation.time} -->  #{animation.length}"
				animation.disable
				animation.time = 0.0
			end
		end
		
		def attack
			# puts "ATTACK"
			# p @animation.animations
			a = @animation["sword_r-l"]
			a.enable
			a.loop = false
			
			a.time = 0.5
		end
	end
end