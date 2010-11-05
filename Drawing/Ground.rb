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
	
		def initialize(texture, width, depth, pos=[0,0])
			#Texture must be in the Code/Sprites/Textures directory
			#	Specify the name only.  It is assumed the image is a png.
			#
			#The width and depth of the ground can each be specified as -1 to signify that the
			#	width and height of the image should be used.
			#Position is given in meters relative to the chipmunk space
			#	Can not specify z coordinate, as the ground must always be rendered at z=0
			@width = width
			@depth = depth
			@x = pos[0]
			@y = pos[1]
			
			
			#~ image_path = "./Sprites/Textures/#{texture}.png"
			
			#~ @texture = Gosu::Image.new($window, image_path, args[:tileable])
			
			@texture = Texture.new(texture)
			
			set_dimensions
		end
		
		def update
			
		end
		
		def draw
			#Use Gosu::Window#clip_to in order to restrain the drawing of images which may
			#exceed the desired boundary of the texture.
			
			#The traversal code assumes that the texture map is a rectangular matrix.  
			#It can not be a ragged array, or there will be problems.
			$window.clip_to @x, @y, @width, @depth do
				@texture.draw @x, @y, 0
				
				max_y = (@depth/@texture.depth.to_f).ceil-1
				
				(0..((@width/@texture.width.to_f).ceil-1)).each do |x|
				i = x % @texture_map.width
					(0..max_y).each do |y|
					j = y % @texture_map.depth
						@texture_map[j][i]
					end
				end
			end
		end
	end
	
	
	#~ The texture and texture map are related.  As such, they should have the same
	#~ file same, just different extensions to reflect the different types of data.
	
	class Texture
		#The texture should hold multiple Gosu::Image variables, which are combined
		#in the Ground class with a texture map to form a cohesive renderable object.
		def initialize(name)
			
		end
	end
	
	class Texture_Map
		#This is a class which holds the information to map the images in the 
		#contained texture to their locations in the rendered grid.
		
		
		def initialize
			@map = Array.new
		end
		
		
	end
	
	class CircularArray < Array
		def initialize(*args)
			super args
		end
		
		def next
			x = self.shift	#Get the first element
			self << x		#Stick it on the end
			return x		#Return the former first element
		end
	end
end
