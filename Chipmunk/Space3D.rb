#!/usr/bin/ruby

require 'set'

require 'rubygems'
require 'chipmunk'
require 'gosu'
require 'RMagick'
require './Chipmunk/Space'
require './Chipmunk/Shape3D'

module CP	
	class Space3D < Space
		TIMESTEP = 1/60.0
		alias :add_2D :add
	
		attr_reader :shapes, :g
		
		def initialize(damping=0.12, g=-9.8)
			super()
			@shapes = {:static => Set.new, :nonstatic => Set.new}
			@g = g		#Controls acceleration due to gravity in the z direction
			
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
			super TIMESTEP
			
			#Add code for one-dimensional movement in the z-direction here	
			@shapes[:nonstatic].each do |shape|
				shape.iterate TIMESTEP
				set_elevation shape
				
				if shape.z > shape.elevation
					shape.apply_gravity TIMESTEP, @g
				else# shape.z <= shape.elevation
					shape.z = shape.elevation
					shape.entity.resolve_ground_collision
					v,a = shape.reset_gravity
					shape.entity.resolve_fall_damage v
				end
			end
		end
				
		def add(shape)
			super shape
			@shapes[shape.staticness].add shape
		end
		
		def remove(shape)
			super shape
			@shapes[shape.staticness].delete shape
		end
		
		def clear
			@shapes.each do |static, set|
				set.each do |shape|
					super.remove shape, static
				end
				
				set.clear
			end
		end
		
		alias :remove_all :clear
		
		def set_elevation(shape)
			shape.elevation = 0
		
			all_ones = 2**32-1
			point_query shape.body.p, all_ones,0 do |env|
				if env.collision_type == :environment || env.collision_type == :building
					#Raise elevation to the height of whatever is below.
					if env.height > shape.elevation
						shape.elevation = env.height
					end
				end
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
