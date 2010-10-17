#!/usr/bin/ruby

require 'set'

require 'rubygems'
require 'chipmunk'
require 'gosu'
require 'RMagick'
require './Chipmunk/Space'
require './Chipmunk/Shape_3D'

module CP	
	class Space_3D < Space
		attr_reader :dt, :g, :shapes
		
		def initialize(damping=0.12, g=-9.8, dt=(1.0/60.0))
			super()
			@shapes = {:static => Set.new, :nonstatic => Set.new}
			@g = g		#Controls acceleration due to gravity in the z direction
			@dt = dt	#Controls the timestep of the space.  
						#	Could be falsified as slower than update rate for bullet time
			
			#X is horizontal
			#Y is vertical
			#Z is height
			
			#This CP::Space functions as the xy plane, while the gravity is controlled as if 
			#	it was in the z direction.
			#Gravity should not function in the horiz plane, thus gravity is always <0, 0>
			self.gravity = CP::Vec2.new(0, 0)
			
			#0.9 Seems like a good damping for ice
			self.damping = damping
		end
		
		def step
			super @dt
			
			#Add code for one-dimensional movement in the z-direction here	
			@shapes[:nonstatic].each do |shape|
				shape.iterate @dt
			
				if shape.z > shape.elevation
					shape.apply_gravity @dt
				elsif shape.z < shape.elevation
					shape.z = shape.elevation
					shape.reset_gravity
					shape.entity.step @dt
				end
			end
		end
				
		def add(arg)
			super arg.shape
			@shapes[static?(arg.shape)].add arg.shape
		end
		
		def remove(arg)
			super arg.shape
			@shapes[static?(arg.shape)].delete arg.shape
		end
		
		def clear
			@shapes.each do |static, set|
				set.each do |shape|
					super.remove shape, static
				end
				
				set.clear
			end
		end
		
		private
		
		def static?(shape)
			if shape.body.m == Float::INFINITY
				return :static
			else
				return :nonstatic
			end
		end
	end
end

class Numeric
	#Code taken from MoreChipmunkAndRMagick.rb from the gosu demos
   def radians_to_vec2
       CP::Vec2.new(Math::cos(self), Math::sin(self))
   end
end
