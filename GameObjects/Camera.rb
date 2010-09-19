#!/usr/bin/ruby
#~ Name: Jason
#~ Date last edited: 09.18.2010
require 'set'

require 'rubygems'
require 'gosu'
require 'chipmunk'
require 'Chipmunk/Shape'
require 'Chipmunk/EternityMod'
 
class Camera
	def initialize(width, depth, entity)
		mass = entity.shape.body.m
		@shape = CP::Shape::Rect.new(CP::Body.new(mass, Float::INFINITY), :top_left, width, depth)
		@entity = entity
		
		@queue = Set.new
	end
end
