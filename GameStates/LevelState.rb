#!/usr/bin/ruby

require 'rubygems'
require 'chipmunk'

class LevelState < GameState
	# Defines the behavior for a slice of a level.
	# A slice is similar to one floor of a building.

	def initialize(window, space, layers, name, render_queue)
		super(window, space, layers, name)
		
		@queue = render_queue
	end
	
	def update
		super
	end
	
	def draw
		@queue.each do |game_object|
			game_object.draw
		end
	end
	
	def finalize
		super
	end
	
	# Insert the gameobject into the world defined by this gamestate
	def add_gameobject(obj)
		
	end
	
	# Remove the gameobject from the world defined by this gamestate
	def remove_gameobject(obj)
		
	end
	
	# Save all elements of the level, but not the camera
	def save
		# Get all physics objects with the appropriate layers variable
		# Get the corresponding game objects
		# Call some sort of serialization method on each game object
			# that method should explain how to re-create that game object from saved assets
		# Store game object re-creation details in one text or YAML file
	end
	
	def load(filename)
		
	end
end
