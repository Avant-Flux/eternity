#!/usr/bin/ruby

require 'rubygems'
require 'chipmunk-ffi'

class LevelState < GameState
	# Defines the behavior for a slice of a level.
	# A slice is similar to one floor of a building.

	def initialize(window, space, layer, name, camera)
		super(window, space, layer, name)
		
		@camera = camera
	end
	
	def update
		@space.step
	end
	
	def draw
		@camera.queue.each do |game_object|
			game_object.draw
		end
	end
	
	def finalize
		
	end
end
