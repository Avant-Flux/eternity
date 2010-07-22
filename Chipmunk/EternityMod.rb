#!/usr/bin/ruby
#~ Name: Jason
#~ Date last edited: 07.21.2010
require 'rubygems'
require 'chipmunk'
require 'Chipmunk/Shape_3D'

class Entity_Body < Body_3D
	def initialize(space, x, y, z, width, height, mass=100, moment=150)
		super(space, x, y, z, width, height, :entity_bottom, :entity_side, mass, moment)
		
		xy_collision_fx do |b1_shape, b2_shape|
			if 
				nil
			else
				nil
			end
			1
		end
		
		xz_collision_fx do |s1_shape, s2_shape|
			nil
		end
	end
end

class Building_Body < Body_3D
	def initialize(space, x, y, z, width, height)
		super(space, x, y, z, width, height, :building_bottom, :building_side, 
				Float::INFINITY, Float::INFINITY)
		
		xy_collision_fx do |b1_shape, b2_shape|
			1
		end
		
		xz_collision_fx do |s1_shape, s2_shape|
			nil
		end
	end
end
