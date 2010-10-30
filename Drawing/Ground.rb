#!/usr/bin/ruby

#This file describes how to draw a section of terrain, in it's most basic state, 
#a image spread out on the lowest z-index across the xy-plane.

#Internal coordinates should be handled in pixels so everything lines up,
#but the coordinates accepted from the user should be in meters so that 
#the texture can be rendered in the appropriate space.

require 'rubygems'
require 'gosu'
require 'chipmunk'

require 'chipmunk'
require './Chipmunk/Space_3D'
require './Chipmunk/EternityMod'

module Ground
	class Renderer
		attr_accessor :x, :y
	
		def initialize(texture, args={})#	:tileable, :pos, :width, :depth are hash arguments
			#Texture must be in the Code/Sprites/Textures directory
			#	Specify the name only.  It is assumed the image is a png.
			#
			#The width and depth of the ground can each be specified as -1 to signify that the
			#	width and height of the image should be used.
			#Position is given in meters relative to the chipmunk space
			#	Can not specify z coordinate, as the ground must always be rendered at z=0
			
			#Set default values
			args[:tileable] = false unless args[:tileable]
			args[:pos] = [0,0] unless args[:pos]
			
			@x = pos[0]
			@y = pos[1]
			@z = 0
			
			@width = 0
			@depth = 0
			
			
			image_path = "./Sprites/Textures/#{texture}.png"
			
			@texture = Gosu::Image.new($window, image_path, args[:tileable])
			
			set_dimensions
		end
		
		def update
			
		end
		
		def draw
			#Use Gosu::Window#clip_to in order to restrain the drawing of images which may
			#exceed the desired boundary of the texture.
			$window.clip_to @x, @y, @width, @depth do
				@texture.draw @x, @y, @z
			end
		end
		
		private
		
		def set_dimensions
			if width == -1
				@width = @texture.width
			else
				@width = @args[:width]
			end
			if depth == -1
				@depth = @texture.height
			else
				@depth = @args[:depth]
			end
		end
	end
	
	
	#~ The texture and texture map are related.  As such, they should have the same
	#~ file same, just different extensions to reflect the different types of data.
	
	class Texture
		#The texture should hold multiple Gosu::Image variables, which are combined
		#in the Ground class with a texture map to form a cohesive renderable object.
		def initialize
			
		end
	end
	
	class Texture_Map
		#This is a class which holds the information to map the images in the 
		#contained texture to their locations in the rendered grid.
		def initialize
			
		end
	end
end
