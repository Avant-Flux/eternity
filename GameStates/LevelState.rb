#!/usr/bin/ruby

require 'rubygems'
require 'chipmunk'

class LevelState < GameState
	# Defines the behavior for a slice of a level.
	# A slice is similar to one floor of a building.
	path = File.expand_path File.dirname(__FILE__)
	path = path[0..(path.rindex(File::SEPARATOR))]
	LEVEL_DIRECTORY = File.join path, "Levels"
	
	attr_accessor :spawn
	
	def initialize(window, space, layers, name, render_queue)
		super(window, space, layers, name)
		
		@queue = render_queue
		
		# Change position of buildings as well as all other game objects to be
		# specified in terms of the game's isometric projection.
		# Buildings have already been changed to behave in this way, other objects have not.
		# Change the behavior of the physics bindings, not the gameobjects
	end
	
	def update
		super
	end
	
	def draw(zoom)
		@queue.each do |game_object|
			game_object.draw zoom, @player
		end
	end
	
	def finalize
		super
	end
	
	def add_player(player)
		@player = player
		self.add_gameobject player
		player.set_position @space, @layers, @spawn

		#~ player.px = @spawn[0]
		#~ player.py = -@spawn[2]
		#~ 
		#~ pos = Physics::Direction::Y_HAT*@spawn[1]
		#~ player.px += pos.x
		#~ player.py -= pos.y
		#~ 
		#~ player.pz = @spawn[2]
		#~ player.px, player.py, player.pz = @spawn
	end
	
	# Save all elements of the level, but not the camera
	def save
		# Get all physics objects with the appropriate layers variable
		# Get the corresponding game objects
		# Call some sort of serialization method on each game object
			# that method should explain how to re-create that game object from saved assets
		# Store game object re-creation details in one text or YAML file
		path = File.join LEVEL_DIRECTORY, (@name + "save2.txt")
		
		File.open(path, "w") do |f|
			f.puts "# Eternity Level Data --- #{@name}"
			f.puts "Spawn #{@spawn[0]} #{@spawn[1]} #{@spawn[2]}"
			@gameobjects.each do |gameobj|
				line = "#{gameobj.class} "
				
				
				# Insert position
				# for vectors effected by isometric coordinates
				# perform a vector projection onto the unit vector
				# take the magnitude of the resultant vector
				
				x = gameobj.px
				y = gameobj.py >= 0 ? gameobj.py : gameobj.py * -1
				z =gameobj.pz
				line << "#{x} #{y} #{z} "
				
				
				# Insert dimensions
				line << "#{gameobj.width(:meters)} #{gameobj.depth(:meters)} #{gameobj.height(:meters)}"
				f.puts line
			end
		end
		
		puts "save complete"
	end
	
	# Create UVs for each environmental object
	def export(path)
		begin
			Dir.mkdir path
		rescue Errno::EEXIST
			# This directory already exists
		end
		
		@gameobjects.each_with_index do |gameobj, i|
			if gameobj.respond_to? :export
				gameobj.export path, "#{gameobj.class}_#{i}"
			end
		end
		
		puts "export of #{self.name} complete"
	end
	
	class << self
		def load(window, space, layers, name, render_queue)
			level =	LevelState.new window, space, layers, name, render_queue
			
			path = File.join LEVEL_DIRECTORY, (name + ".txt")
			
			building_count = 0
						
			File.open(path, "r").each do |line|
				args = line.split
				
				if args[0] && args[0][0] != "#" # Ignore empty lines, and commented out lines
					# check the first letter of the first word
					game_object = case args[0][0]
						when "B"
							building_count += 1
							Building.new	window, "#{name}_#{building_count}",
											[args[1].to_f, args[2].to_f, args[3].to_f], 
											[args[4].to_f, args[5].to_f, args[6].to_f]
						when "d"
							nil
						when "r"
							nil
						when "e"
							nil
						when "n"
							nil
						when "S" # Spawn
							level.spawn = [args[1].to_f, args[2].to_f, args[3].to_i]
							nil
						else
							raise ArgumentError, "improper gameobject type"
					end
					
					unless game_object == nil
						level.add_gameobject game_object
					end
				end
			end
			
			return level
		end
	end
end
