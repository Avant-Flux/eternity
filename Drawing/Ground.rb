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
	def initialize(texture, width, depth, tileable, pos=[0,0,0])
		#Texture must be in the Code/Sprites/Textures directory
		#Position is given in meters relative to the chipmunk space
		
	end
	
	def update
		
	end
	
	def draw
		
	end
end
