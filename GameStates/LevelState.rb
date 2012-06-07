#!/usr/bin/ruby

require 'rubygems'
require 'chipmunk'

require 'set'

class LevelState #< GameState
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
	end
	
	def update
		@entities.each do |entity|
			entity.update
		end
		
		@magic_circle_angle ||= 0
		if @magic_circle_angle > 360
			@magic_circle_angle -= 360
		else
			@magic_circle_angle += 30 * @space.dt
		end
	end
	
	def draw
		draw_static_objects
		draw_shadows
		draw_ground_effects
		draw_entities
		#~ @window.camera.draw_billboarded do
			#~ c = 1
			#~ r = (@player.body.pz - @player.body.elevation + c).to_px
			#~ r = 1.to_px
			#~ 
			#~ position = @player.body.p.to_screen
			#~ x = position.x
			#~ y = (position.y - @player.body.elevation.to_px)
			#~ 
			#~ @window.draw_circle	x, y, @player.body.pz, r,
								#~ Gosu::Color.new(100, 255,0,0),
								#~ :stroke_width => 5
		#~ end
	end
	
	def draw_magic_circle(x,y,z)
		@magic_circle ||= Gosu::Image.new(@window, "./Sprites/Effects/firecircle.png", false)
		
		zoom = 0.01
		color = Gosu::Color::RED
		
		@window.scale zoom,zoom, x,y do
			@magic_circle.draw_rot(x,y,z, @magic_circle_angle, 0.5,0.5, 1,1, color)
		end
	end
	
	def finalize
		super
		
		# TODO: Refrain from using finalize and remove objects in some other manner.
		# 		Using finalize delays removal until the object is GCed
		
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
	
	def each_entity(*args)
		@entities.each *args, &block
	end
	
	def add_gameobject(obj)
		if obj.is_a? StaticObject
			@static_objects << obj
		else
			@entities.add obj
		end
		
		obj.add_to @space
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
	end
	
	def add_player(player)
		@player = player
		@player.add_to @space
		@entities << @player
		
		@player.body.p.x, @player.body.p.y, @player.body.pz = @spawn
	end
	
	# Save all elements of the level, but not the camera
	def save
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
				
				if args[0] && args[0][0] != "#" # Ignore empty lines, and commented out lines
					# check the first letter of the first word
					
					game_object = case args[0] # Check the first parameter
						when "Building"
							building_count += 1
							#~ Building.new	window, "#{name}_#{building_count}",
											#~ [args[1].to_f, args[2].to_f, args[3].to_f], 
											#~ [args[4].to_f, args[5].to_f, args[6].to_f]
							args.shift
                            puts "Creating new Building at #{args[3]},#{args[4]},#{args[5]} (size: #{args[0]},#{args[1]},#{args[2]} textures: '#{args[6]}','#{args[7]}')"
                            
                            6.times do |i|
								args[i] = args[i].to_f
                            end
                            
							Building.new window, *args
						when "d"
                            puts "#{args[0]} not implemented"
							nil
						when "r"
                            puts "#{args[0]} not implemented"
							nil
						when "e"
                            puts "#{args[0]} not implemented"
							nil
						when "NPC"
							#~ Entity.new window
                            args.shift
                            selected = characters[ args[0] ]
                            if selected == nil
                                puts "Invalid NPC type '#{args[0]}'"
                            else
                                puts "Creating new NPC #{args[0]} at #{args[1]},#{args[2]},#{args[3]}"
                                selected.new window,
                                             args[1].to_f, args[2].to_f, args[3].to_f
                            end
						when "Spawn"
                            puts "Setting level spawn to #{args[1]},#{args[2]},#{args[3]}"
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
			z_index = static.pz+static.height
			
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
	
	def draw_ground_effects
		@window.camera.draw_trimetric do
			draw_magic_circle	@player.body.p.x,@player.body.p.y,0
		end
	end
end
