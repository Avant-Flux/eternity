#!/usr/bin/ruby

require 'rubygems'
require 'chipmunk'

# Gamestate which displays a splash screen when the game starts up
# May include a progress bar which shows how much time is left before
# the game finishes loading.
class SplashState < GameState
	def initialize(window, space, layer, name)
		super(window, space, layer, name)
		
		# Note: Currently being classified as a state like a level
		
		# The splash state needs access to the full stack
		# to know when things are done loading.
		#~ @stack = statestack
		
		#~ @splash_image = 
	end
	
	def update
		super
		# Increment loading bar
	end
	
	def draw
		#~ @splash_image.draw_centered()
		color = Gosu::Color::AQUA
		@window.draw_quad	0,0, color,
							20, 0, color,
							20, 20, color,
							0, 20, color
	end
	
	def finalize
		super
	end
end
