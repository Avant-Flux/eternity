class Grid < GameState
	def initialize(window, space, layers, name, visible=false)
		super window, space, layers, name, visible, true
		
	end
	
	def update
		
	end
	
	def draw(camera)
		# Draw a grid based on the unit vectors of the isometric space
		if @visible
			#~ puts "drawing grid"
			c = Gosu::Color::CYAN
			z = 500000
			
			v_x = Physics::Direction::X_HAT * 100
			v_y = Physics::Direction::Y_HAT * 100
			
			# Draw isometric X-axis
			@window.draw_line	0,0, c,
								(v_x.x).to_px(camera.zoom), (v_x.y).to_px(camera.zoom), c, z
			@window.draw_line	0,0, c,
								-(v_x.x).to_px(camera.zoom), -(v_x.y).to_px(camera.zoom), c, z
								
			# Draw isometric Y-axis
			@window.draw_line	0,0, c,
								(v_y.x).to_px(camera.zoom), (v_y.y).to_px(camera.zoom), c, z
			@window.draw_line	0,0, c,
								-(v_y.x).to_px(camera.zoom), -(v_y.y).to_px(camera.zoom), c, z
		end
	end
end
