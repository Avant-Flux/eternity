#!/usr/bin/ruby

require 'rubygems'
require 'chipmunk'

class LevelState < GameState
	# Defines the behavior for a slice of a level.
	# A slice is similar to one floor of a building.

	def initialize(window, space, layers, name, render_queue)
		super(window, space, layers, name)
		
		@queue = render_queue
		add_gameobject Building.new window, :position => [6,6,0], :width => 2, :depth => 2, :height => 2
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
