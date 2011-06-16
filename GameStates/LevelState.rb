#!/usr/bin/ruby

require 'rubygems'
require 'chipmunk'

class LevelState < GameState
	# Defines the behavior for a slice of a level.
	# A slice is similar to one floor of a building.

	def initialize(window, space, layer, name, camera)
		super(window, space, layer, name)
		
		@camera = camera
		@player = nil
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
	
	# Insert the player into the world defined by this gamestate
	def insert_player(player)
		@player = player
	end
	
	# Remove the player into the world defined by this gamestate
	def remove_player(player)
		@player = nil
	end
	
	def load
		
	end
	
	def dump
		
	end
end
