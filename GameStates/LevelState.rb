#!/usr/bin/ruby

require 'rubygems'
require 'chipmunk'

class LevelState < GameState
	# Defines the behavior for a slice of a level.
	# A slice is similar to one floor of a building.

	def initialize(window, space, layer, name, camera)
		super(window, space, layer, name)
		
		@camera = camera
	end
	
	def update
		
	end
	
	def draw
		@camera.queue.each do |game_object|
			game_object.draw
		end
	end
	
	def finalize
		
	end
	
	# Insert the gameobject into the world defined by this gamestate
	def add_gameobject(obj)
		# Set the proper layer and then add the object to the space
		obj.layers = @layer
		obj.add_to @space
	end
	
	# Remove the gameobject from the world defined by this gamestate
	def remove_gameobject(obj)
		@space.delete obj
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
