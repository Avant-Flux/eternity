#!/usr/bin/ruby

require 'rubygems'
require 'chipmunk'

class LevelState < GameState
	# Defines the behavior for a slice of a level.
	# A slice is similar to one floor of a building.
	LEVEL_DIRECTORY = File.join $base_directory, "Levels"

	def initialize(window, space, layers, name, render_queue)
		super(window, space, layers, name)
		
		@queue = render_queue
		
		# Change position of buildings as well as all other game objects to be
		# specified in terms of the game's isometric projection.
		# Buildings have already been changed to behave in this way, other objects have not.
		# Change the behavior of the physics bindings, not the gameobjects
		
		#~ add_gameobject Building.new window, [0,0,0], [1,1,1]
		
		#~ add_gameobject Building.new window, [2,0,0], [3,2,3]
		#~ add_gameobject Building.new window, [2,2,0], [3,2,5]
		#~ add_gameobject Building.new window, [8.5,0,0], [2,2,3]
		#~ 
		#~ add_gameobject Building.new window, [12,-5,0], [5,8,9]
		#~ 
		#~ add_gameobject Building.new window, [2,-5,0], [1,1,6]
	end
	
	def update
		super
	end
	
	def draw(zoom)
		@queue.each do |game_object|
			game_object.draw zoom
		end
	end
	
	def finalize
		super
	end
	
	class << self
		# Save all elements of the level, but not the camera
		def save
			# Get all physics objects with the appropriate layers variable
			# Get the corresponding game objects
			# Call some sort of serialization method on each game object
				# that method should explain how to re-create that game object from saved assets
			# Store game object re-creation details in one text or YAML file
		end
		
		def load(window, space, layers, name, render_queue)
			level =	LevelState.new window, space, layers, name, render_queue
			
			path = File.join LEVEL_DIRECTORY, (name << ".txt")
						
			File.open(path, "r").each do |line|
				args = line.split
				
				if args[0] && args[0][0] != "#" # Ignore empty lines, and commented out lines
					# check the first letter of the first word
					game_object = case args[0][0]
						when "b"
							Building.new window, [args[1].to_f, args[2].to_f, args[3].to_f], 
												 [args[4].to_f, args[5].to_f, args[6].to_f]
						when "d"
							nil
						when "r"
							nil
						when "e"
							nil
						when "n"
							nil
					end
					
					if game_object == nil
						raise ArgumentError, "improper gameobject type"
					end
					
					level.add_gameobject game_object
				end
			end
			
			return level
		end
	end
end
