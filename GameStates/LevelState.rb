#!/usr/bin/ruby

require 'rubygems'
require 'chipmunk'

require 'set'

# TODO: Remove @space from initialize, as it is not needed on init.
class LevelState #< GameState
	include Comparable
	
	# Defines the behavior for a slice of a level.
	# A slice is similar to one floor of a building.
	path = File.expand_path File.dirname(__FILE__)
	path = path[0..(path.rindex(File::SEPARATOR))]
	LEVEL_DIRECTORY = File.join path, "Levels"
	
	attr_reader :name
	attr_accessor :spawn
	
	def initialize(window, space, name)
		@window = window
		@space = space
		@name = name
		#~ super(window, space, layers, name)
		
		#~ @queue = render_queue
		
		@entities = Set.new
		
		# TODO:  Free @static_objects if #update is not necessary
		@static_objects = Array.new
		
		@magic_circle = GroundEffect.new window, space
	end
	
	def update
		@entities.each do |entity|
			entity.update
		end
		
		@magic_circle.update
	end
	
	def draw
		draw_static_objects
		draw_shadows
		draw_ground_effects
		draw_entities
	end
	
	# Clean up the things managed by this state
	# NOTE:	This method MUST be called when the state is cleared, or the
	# 		collision geometry will remain in the space.
	def finish
		# Player is an entity, and will be removed with the rest of them.
		# NOTE:	This implies that if player is in a sub-level (ie inside a building)
		# 		the player will have to be re-added to the space
		@entities.each do |entity|
			entity.remove_from @space
		end
		
		@static_objects.each do |obj|
			obj.remove_from @space
		end
	end
	
	def each_static(*args, &block)
		@static_objects.each *args, &block
	end
	
	def each_entity(*args, &block)
		@entities.each *args, &block
	end
	
	def add_gameobject(obj)
		if obj.is_a? StaticObject
			@static_objects << obj
		else
			@entities.add obj
		end
	end
	
	def delete_gameobject(obj)
		#~ super(obj)
		#~ @queue.delete obj
		
		collection = if obj.is_a? StaticObject
			@static_objects
		else
			@entities
		end
		
		collection.delete obj
		
		obj.remove_from @space
		
		return obj
	end
	
	def add_player(player)
		@player = player
		@player.body.p.x, @player.body.p.y, @player.body.pz = @spawn
		
		@player.add_to @space
		@entities << @player
		
		return @spawn
	end
	
	def add_to(space)
		# Must add entities last, so they can have proper elevation
		@space = space
		
		@static_objects.each do |obj|
			obj.add_to @space
		end
		
		@entities.each do |entity|
			entity.add_to @space
		end
	end
	
	# Save all elements of the level, but not the camera
	def dump
		# Get all physics objects with the appropriate layers variable
		# Get the corresponding game objects
		# Call some sort of serialization method on each game object
			# that method should explain how to re-create that game object from saved assets
		# Store game object re-creation details in one text or YAML file
		# 
		# Note:	All static objects must be loaded before any entities, otherwise unpredictable
		# 		behavior of entity placement will result.
		path = File.join LEVEL_DIRECTORY, (@name + "_SAVE_TEST.txt")
		
		File.open(path, "w") do |f|
			puts "begin saving"
			f.puts "# Eternity Level Data --- #{@name}"
			f.puts "Spawn #{@spawn[0]} #{@spawn[1]} #{@spawn[2]}"
			f.puts
			
			@static_objects.each do |gameobj|
				print "." # Output something so it's clear the save method is doing work
				
				# The tabs at the end of the lines are so that the file will line up nicely
				
				line = "#{gameobj.class}	"
				
				# Insert dimensions
				line << "#{gameobj.width} #{gameobj.depth} #{gameobj.height}		"
				
				# Insert position
				line << "#{gameobj.body.p.x} #{gameobj.body.p.y} #{gameobj.pz}"
				
				f.puts line
			end
			
			f.puts # Empty line as separator
			
			@entities.each do |gameobj|
				print "." # Output something so it's clear the save method is doing work
				
				next if gameobj == @player
				
				#~ line = "#{gameobj.class} "
				line = "NPC"
				
				# Insert dimensions
				#~ line << "#{gameobj.width} #{gameobj.depth} #{gameobj.height} "
				
				# Insert position
				#~ line << "#{gameobj.body.p.x} #{gameobj.body.p.y} #{gameobj.body.pz}"
				
				f.puts line
			end
		end
		
		puts ""
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
	
	def <=>(another)
		if another.is_a? String
			@name <=> another
		else
			@name <=> another.name
		end
	end
	
	class << self
		def load(window, space, name)
			# TODO: Throw exception if no spawn defined
            
            characters = {
                             "GENERIC" => Character
                         }
			
			level =	LevelState.new window, space, name
			
			path = File.join LEVEL_DIRECTORY, (name + ".txt")
			
			building_count = 0
			
			File.open(path, "r").each do |line|
				args = line.split
				
				# TODO: Strip leading whitespace, so indentation can be used in level format.
				if args[0] && args[0][0] != "#" # Ignore empty lines, and commented out lines
					# check the first letter of the first word
					
					game_object = case args[0] # Check the first parameter
						when "Building"
							building_count += 1
							
							args.shift
                            
                            6.times do |i|
								args[i] = args[i].to_f
                            end
                            
							Building.new window, *args
						when "NPC"
                            args.shift
                            selected = characters[ args[0] ]
                            if selected == nil
                                #~ puts "Invalid NPC type '#{args[0]}'"
                            else
                                #~ puts "Creating new NPC #{args[0]} at #{args[1]},#{args[2]},#{args[3]}"
                                selected.new window,
                                             args[1].to_f, args[2].to_f, args[3].to_f
                            end
						when "Spawn"
							level.spawn = [args[1].to_f, args[2].to_f, args[3].to_i]
							nil # "Return nothing"
						else
							raise ArgumentError, "improper gameobject type: #{args[0]}"
					end
					
					if game_object
						level.add_gameobject game_object
					end
				end
			end
			
			return level
		end
	end
	
	private
	
	def draw_static_objects
		@static_objects.each do |static|
			z_index = static.body.pz+static.height
			
			@window.camera.draw_trimetric z_index do
				static.draw_trimetric
			end
			
			@window.camera.draw_billboarded do
				static.draw_billboarded
			end
		end
	end
	
	def draw_entities
		@window.camera.draw_billboarded do
			@entities.each do |entity|
				entity.draw
			end
		end
	end
	
	def draw_shadows
		# Due to how alpha blending works, order should be arbitrary.
		# These methods could even be threaded to further improve performance.
		# However, Gosu is not threadsafe.
		draw_static_object_shadows
		draw_entity_shadows
	end
	
	def draw_ground_effects
		@window.camera.draw_trimetric do
			@magic_circle.draw	@player.body.p.x, @player.body.p.y, 0
		end
	end
	
	def draw_static_object_shadows
		# TODO: Cache calculations for static shadows.
		# Project shadow onto the terrain directly below the object.  ie, the highest of the low
		@static_objects.each do |static|
			# Set to zero, so in the worst case, shadows are draw on the ground.
			# NOTE: This assumes the world is zero-based.
			# 		Really should just be the lowest number possible for the current level.
			render_height = 0
			
			# l, b, r, t
			bb = CP::BB.new	static.body.p.x,				static.body.p.y, 
							static.body.p.x+static.width,	static.body.p.y+static.depth
			@space.bb_query bb, CP::ALL_LAYERS, CP::NO_GROUP do |shape|
				# For all objects inside the XY plane cross-section of the bounding volume
				# around the static object
				
				# Find the tallest static object underneath this static object
				if shape.static?
					new_height = shape.gameobject.height + shape.body.pz
					if new_height > render_height && new_height < static.body.pz
						render_height = new_height
					end
				end
			end
			
			# Do not draw shadows which would be obscured by the base of the static object.
			# Ex) Building is located at (0,0, 10), don't draw shadow if z = 10
			#~ next if render_height == static.body.pz
			
			# Render the actual environment shadow
			@window.camera.draw_trimetric render_height do
				# NOTE: Different alpha value need to be passed for each object, although other
				# 		aspects of color will remain the same.  Consider dropping to direct OpenGL
				# 		to optimize the solution to this problem.
				shadow_color = Gosu::Color.rgba(0xffffffaa) # TODO: Make instance variable
				c = shadow_color
				
				@window.draw_quad	static.body.p.x, static.body.p.y, c,
									static.body.p.x+static.width, static.body.p.y, c,
									static.body.p.x+static.width, static.body.p.y+static.depth, c,
									static.body.p.x, static.body.p.y+static.depth, c,
									render_height
			end
		end
	end
	
	def draw_entity_shadows
		@entities.each do |entity|
			@window.camera.draw_trimetric entity.body.elevation do
				distance = entity.body.pz - entity.body.elevation
				a = 1 # Quadratic
				b = 1 # Linear
				c = 1 # Constant
				factor = (a*distance + b)*distance + c
				
				c = 1
				r = (entity.body.pz - entity.body.elevation + c)
				
				c = 1
				alpha = 1/factor
				@window.draw_circle	entity.body.p.x, entity.body.p.y, entity.body.elevation,
									r,	Gosu::Color::BLACK,
									:stroke_width => r, :slices => 20, :alpha => alpha
			end
		end
	end
end
