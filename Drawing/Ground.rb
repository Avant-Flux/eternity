#!/usr/bin/ruby

#This file describes how to draw a section of terrain, in it's most basic state, 
#a image spread out on the lowest z-index across the xy-plane.

require 'rubygems'
require 'gosu'
require 'chipmunk'

require 'chipmunk'
require './Chipmunk/Space_3D'
require './Chipmunk/EternityMod'

class Ground
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
		
		
		image_path = "./Sprites/Textures/#{texture}.png"
		
		@texture = Gosu::Image.new($window, image_path, args[:tileable])
		
		set_dimensions
	end
	
	def update
		
	end
	
	def draw
		@texture.draw @x, @y, @z
	end
	
	private
	
	def set_dimensions
		if width = -1
			@width = @texture.width
		else
			@width = @args[:width]
		end
		if depth = -1
			@depth = @texture.height
		else
			@depth = @args[:depth]
		end
	end
end
