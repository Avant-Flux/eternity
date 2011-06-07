#!/usr/bin/ruby

require 'set'

require 'rubygems'
require 'gosu'

class Camera
	include Physics::TwoD_Support
	
	attr_reader :shape, :queue

	def initialize(entity)
		@entity = entity
		
		# Perhaps store coordinate pair for center of screen?
		@center = Struct.new(:x, :y).new
		@center.x = $window.width.to_meters / 2
		@center.y = $window.height.to_meters / 2
		
		pos = [@entity.x - @center.x,
				@entity.y - @center.y]
		
		init_physics	:rectangle, pos, 
						:height => $window.height.to_meters, :width => $window.width.to_meters,
						:mass => @entity.mass, :moment => :static, :collision_type => :camera
		
		@shape.sensor = true
		
		$space.add_2D @shape
		
		@queue = Set.new
	end
	
	def update
		#~ @shape.body.reset_forces
		#~ self.move(@entity.shape.body.f)
		warp @entity.p
	end
	
	def add(entity)
		@queue.add entity
	end
	
	def delete(entity)
		@queue.delete entity
	end
	
	def move(force, offset=CP::ZERO_VEC_2)
		@shape.body.apply_force force, offset
	end
	
	def warp(vec2)
		self.p = vec2
		self.p.x -= @center.x
		self.p.y -= @center.y + @entity.z
	end
	
	def x
		@shape.body.p.x
	end
	
	def y
		@shape.body.p.y
	end
end
