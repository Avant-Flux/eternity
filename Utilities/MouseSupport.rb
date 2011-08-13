#!/usr/bin/ruby

require 'rubygems'
require 'chipmunk'

class MouseHandler
	def initialize(space, layers)#, radius, mass, moment)
		@space = space
		@layers = layers
		#~ body = CP::Body.new mass, moment
		#~ @mouse_shape = CP::Shape::Circle.new body, radius
		
		#~ @mouse_shape.collision_type = :pointer
		
		#~ space.add @mouse_shape
	end
	
	def click(position)
		target = nil
		@space.point_query position, @layers, CP::NO_GROUP do |shape|
			if target
				#~ puts "#{shape.gameobj.class}:#{shape.gameobj.pz} <=> #{target.gameobj.class}:#{target.gameobj.pz}"
				if shape.gameobj.pz >= target.gameobj.pz
					# Use this shape instead of the current target if it is further up the draw stack
					target = shape
				end
			else
				target = shape
			end
		end
		
		if target
			if target.gameobj.respond_to? :click_event
				target.gameobj.click_event
			end
		end
	end
end
