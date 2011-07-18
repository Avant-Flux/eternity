#!/usr/bin/ruby

class MenuState < InterfaceState
	def initialize(window, space, layer, name, player)
		super(window, space, layer, name, player)
	end
	
	def update
		super
	end
	
	def draw
		color = Gosu::Color::WHITE
		top_margin = 20
		bottom_margin = 20
		left_margin = 20
		right_margin = 20
		
		@window.draw_quad	left_margin, top_margin, color,
							@window.width - right_margin, top_margin, color,
							left_margin, @window.height - bottom_margin, color,
							@window.width - right_margin, @window.height - bottom_margin, color
	end
	
	def finalize
		super
	end
end
