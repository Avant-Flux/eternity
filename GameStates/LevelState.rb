#!/usr/bin/ruby

require 'rubygems'
require 'chipmunk'

# require 'nokogiri'
require 'xmlsimple'

require 'set'

# TODO: Remove @space from initialize, as it is not needed on init.
class LevelState #< GameState
	include Comparable
	
	# Defines the behavior for a slice of a level.
	# A slice is similar to one floor of a building.
	path = File.expand_path File.dirname(__FILE__)
	path = path[0..(path.rindex(File::SEPARATOR))]
	LEVEL_DIRECTORY = File.join path, "Levels"
	
	
	def initialize(window, space, name)
		@space = space
		@name = name
		#~ super(window, space, layers, name)
		
		#~ @queue = render_queue
		
		@entities = Set.new
		
		# TODO:  Free @static_objects if #update is not necessary
		@static_objects = Array.new
	end
	
	def update(dt)
		# @entities.each do |entity|
		# 	entity.update
		# end
		
		# @static_objects.each do |static|
		# 	static.update
		# end
	end
	
	def draw
		
	end
	
	def add_static_object(obj)
		@static_objects << obj
	end
	
	# # Clean up the things managed by this state
	# # NOTE:	This method MUST be called when the state is cleared, or the
	# # 		collision geometry will remain in the space.
	# def finish
	# 	# Player is an entity, and will be removed with the rest of them.
	# 	# NOTE:	This implies that if player is in a sub-level (ie inside a building)
	# 	# 		the player will have to be re-added to the space
	# 	@entities.each do |entity|
	# 		entity.remove_from @space
	# 	end
		
	# 	@static_objects.each do |obj|
	# 		obj.remove_from @space
	# 	end
	# end
	
	# def each_static(*args, &block)
	# 	@static_objects.each *args, &block
	# end
	
	# def each_entity(*args, &block)
	# 	@entities.each *args, &block
	# end
	
	# def add_gameobject(obj)
	# 	if obj.is_a? StaticObject
	# 		@static_objects << obj
	# 	else
	# 		@entities.add obj
	# 	end
	# end
	
	# def delete_gameobject(obj)
	# 	#~ super(obj)
	# 	#~ @queue.delete obj
		
	# 	collection = if obj.is_a? StaticObject
	# 		@static_objects
	# 	else
	# 		@entities
	# 	end
		
	# 	collection.delete obj
		
	# 	obj.remove_from @space
		
	# 	return obj
	# end
	
	# def add_player(player)
	# 	@player = player
	# 	@player.body.p.x, @player.body.p.y, @player.body.pz = @spawn
		
	# 	@player.add_to @space
	# 	@entities << @player
		
	# 	return @spawn
	# end
	
	# def add_to(space)
	# 	# Must add entities last, so they can have proper elevation
	# 	@space = space
		
	# 	@static_objects.each do |obj|
	# 		obj.add_to @space
	# 	end
		
	# 	@entities.each do |entity|
	# 		entity.add_to @space
	# 	end
	# end
	
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
				line << "#{gameobj.body.p.x} #{gameobj.body.p.y} #{gameobj.body.pz}"
				
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
		def load(window, space, state_name)
			# dir = "/home/ravenskrag/Code/GameDev/Eternity/Development/Exported/Levels"
			state = LevelState.new window, space, state_name
			
			
			filepath = File.join LEVEL_DIRECTORY, state_name, "#{state_name}.scene"
			# xml = Nokogiri::XML::Document.parse(File.open(filepath))
			
			# i = 0
			# xml.xpath("//node").each do |node|
			# 	model_name = 
			# 	static = Oni::Model.new window, "#{state_name}_#{i}", "#{model_name}.mesh"
			# 	i+=1
				
			# 	state.add_static_object static
			# end
			File.open(filepath) do |file|
				# TODO: Figure out how to phrase queries properly. Current method not scalable.
				# TODO: Use Nokogiri to implement proper queries
				
				xml = XmlSimple.xml_in file, 'KeyAttr' => 'node'
				xml["nodes"][0]["node"].each do |node|
					if node["name"] =~ /Lamp/
						# Set up lighting
					elsif node["name"] =~ /Camera/
						# Ignore camera
					elsif node["name"] =~ /Armature/
						# Use this as spawn points
						
					else
						mesh_file = node["entity"][0]["meshFile"]
						node_name = node["name"]
						
						position =	[
										node["position"][0]["x"].to_f, 
										node["position"][0]["y"].to_f,
										node["position"][0]["z"].to_f
									]
						
						rotation =	[
										node["rotation"][0]["x"].to_f, 
										node["rotation"][0]["y"].to_f,
										node["rotation"][0]["z"].to_f
									]
						
						scale =		[
										node["scale"][0]["x"].to_f, 
										node["scale"][0]["y"].to_f,
										node["scale"][0]["z"].to_f
									]
						
						
						
						puts "#{name} --- #{mesh_file}: #{position}, #{rotation}, #{scale}"
						
						model = Oni::Model.new window, node_name, mesh_file
						# p model.methods
						model.position = position
						model.rotation_3D = rotation
						model.scale = scale
						
						state.add_static_object model
					end
				end
			end
			
			return state
		end
	end
end
