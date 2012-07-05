# Draws animations on the ground, like AoE targeting circles.
class GroundEffect
	def initialize(window, space)
		@window = window
		@space = space
		
		@image = Gosu::Image.new(window, "./Sprites/Effects/firecircle.png", false)
		
		@angle = 0
		@color = Gosu::Color::RED
		@zoom = 0.01
	end
	
	def update
		if @angle > 360
			@angle -= 360
		else
			@angle += 30 * @space.dt
		end
	end
	
	def draw(x,y,z)
		# Should draw at this level, and all levels below.  Such will allow for
		# casting AoE even under overhangs.
		# 
		# Should probably develop a different effect type which simulates objects dropped from
		# the sky in that case, though.
		
		@window.scale @zoom,@zoom, x,y do
			@image.draw_rot	x,y,z, @angle, 0.5,0.5, 1,1, @color
		end
	end
end
