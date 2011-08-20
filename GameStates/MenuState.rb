#!/usr/bin/ruby

class MenuState < InterfaceState
	def initialize(window, space, layer, name, open, close, player)
		super(window, space, layer, name, open, close)
		@player = player
	end
	
	def update
		super
	end
	
	def draw
		color = Gosu::Color::WHITE
		top_margin = 40
		bottom_margin = 40
		left_margin = 40
		right_margin = 40
		
		@window.draw_quad	left_margin, top_margin, color,
							@window.width - right_margin, top_margin, color,
							left_margin, @window.height - bottom_margin, color,
							@window.width - right_margin, @window.height - bottom_margin, color
	end
	
	def finalize
		super
	end
end
