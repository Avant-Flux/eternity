#!/usr/bin/ruby

require 'rubygems'
require 'chipmunk'

# Gamestate which displays a splash screen when the game starts up
# May include a progress bar which shows how much time is left before
# the game finishes loading.
class SplashState < GameState
	def initialize(window, space, layer, statestack)
		super(window, space, layer, false)
		
		# The splash state needs access to the full stack
		# to know when things are done loading.
		@stack = statestack
	end
	
	def update
		# Increment loading bar
	end
	
	def draw
		
	end
	
	def finalize
		
	end
end
