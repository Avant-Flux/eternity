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
	
	attr_accessor :spawn
	
	def initialize(window, space)
		@window = window
		@space = space
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
	end
	
	def draw
		draw_static_objects
		draw_shadows
		draw_ground_effects
		draw_entities
	end
	
	def draw_magic_circle(x,y,z)
		@magic_circle ||= Gosu::Image.new(@window, "./Sprites/Effects/firecircle.png", false)
		@magic_circle_angle ||= 0
		if @magic_circle_angle > 360
			@magic_circle_angle = 0
		else
			@magic_circle_angle += 1
		end
		zoom = 0.01
		color = Gosu::Color::RED
		
		@window.scale zoom,zoom, x,y do
			@magic_circle.draw_rot(x,y,z, @magic_circle_angle, 0.5,0.5, 1,1, color)
		end
	end
	
	def finalize
		super
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
		path = File.join LEVEL_DIRECTORY, (@name + ".txt")
		
		File.open(path, "w") do |f|
			puts "begin saving"
			f.puts "# Eternity Level Data --- #{@name}"
			f.puts "Spawn #{@spawn[0]} #{@spawn[1]} #{@spawn[2]}"
			@gameobjects.each do |gameobj|
			print "."
				line = "#{gameobj.class} "
				
				x = gameobj.px_
				y = gameobj.py_
				z = gameobj.pz_
				
				# Round all values to two decimal places
				# A beneficial side effect is that -0.0 will never be stored for zero
				
				# Alternatively, do it this way...
				#~ x = x.round 2
				#~ y = y.round 2
				#~ z = z.round 2
				#~ 
				#~ if x == 0
					#~ x = 0
				#~ end
				#~ if y == 0
					#~ y = 0
				#~ end
				#~ if z == 0
					#~ z = 0
				#~ end
				
				# Insert position
				line << "#{x} #{y} #{z} "
				
				# Insert dimensions
				line << "#{gameobj.width(:meters)} #{gameobj.depth(:meters)} #{gameobj.height(:meters)}"
				f.puts line
			end
		end
		
		puts "\nsave complete"
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
			# TODO: Through exception if no spawn defined
			
			level =	LevelState.new window, space
			
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
							StaticObject.new	window, 
												[args[0].to_f, args[1].to_f, args[2].to_f], 
												[args[3].to_f, args[4].to_f, args[5].to_f]
						when "d"
							nil
						when "r"
							nil
						when "e"
							nil
						when "NPC"
							# TODO: Move NPC to spawn
							# TODO: Allow specifying NPC position in file
							Entity.new window
						when "Spawn"
							level.spawn = [args[1].to_f, args[2].to_f, args[3].to_i]
							nil # "Return nothing"
						else
							raise ArgumentError, "improper gameobject type"
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
			@window.camera.draw_trimetric static.pz+static.height do
				static.draw_trimetric
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
