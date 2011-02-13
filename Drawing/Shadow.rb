#!/usr/bin/ruby

require 'set'

require 'rubygems'
require 'gosu'
require 'texplay'
require './Drawing/GosuPatch'

# Handles the drawing of simple shadows.
class Shadow
	OPACITY_CONSTANT = 0.8
	
	def initialize(entity, circle)
		@entity = entity
		@circle = circle
		@draw_elevation = Set.new
	end
	
	def update
		#This could calculate scale and color multiple times for the same elevation.
		#~ @draw_elevation.clear
		#~ @draw_elevation << [0, scale(0), color(0)]
		#~ puts $space.methods
		#~ hash = $space.active_shapes_hash
			#~ shapes = hash.query_by_bb CP::BB.new(0,0,5,5) 
		#~ shapes = $space.bb_query CP::BB.new(0,0,5,5)
		#~ shapes.each do |env|
			#~ elevation = env.height
			#~ scale = scale(env.height)
			#~ color = color(env.height)
			#~ 
			#~ @draw_elevation << [elevation, scale, color]
		#~ end
		
		@color = color
		@scale = scale
	end
	
	def draw
		#~ @draw_elevation.each do |value|
			#~ @circle.draw_centered(@entity.x, @entity.y, value[0], 
						#~ :factor_x => value[1], :factor_y => value[1], 
						#~ :offset_z => -1, :color => value[2])
		#~ end
		
		#~ all_ones = 2**32-1
		#~ point_query @entity.shape.body.p, all_ones,0 do |env|
			#~ if env.collision_type == :environment || env.collision_type == :building
				#~ 
				#~ 
				#~ 
			#~ end
		#~ end
		
		
		
		@circle.draw_centered(@entity.physics.px, @entity.physics.py, @entity.physics.elevation, 
						:factor_x => @scale, :factor_y => @scale, 
						:offset_z => -1, :color => @color)
	end
	
	private
	
	# Calculate the color of the shadow to be rendered, and mix in
	# the correct opacity
	def color#(ground_height)
		color = 0x0000FF						#Current the shadows are blue for testing purposes
		#~ color += opacity(ground_height) << 24	#Shift the opacity to the correct place value in hex
		color += opacity << 24	#Shift the opacity to the correct place value in hex
	end
	
	# Determine the value of the alpha channel.
	def opacity#(ground_height)
		#Calculate the difference between the terrain and the entity.
		height = (@entity.z - @entity.elevation)
		#~ height = (@entity.z - ground_height)
		height = 1 if height < 1	
		
		#Compute a percent based on the inverse-square of the distance
		#and a constant which determines the base opacity.
		percent = OPACITY_CONSTANT/(height**2)
		
		#Convert the percent to a two-digit hex value
		output = (0xFF * percent).to_i
		#~ puts output.to_s 16
		
		return output
	end
	
	# Calculate the amount by which to scale the shadow
	def scale#(ground_height)
		(@entity.z - @entity.elevation + 1)
		#~ (@entity.z - ground_height + 1)
	end
end
