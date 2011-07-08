#!/usr/bin/ruby

require 'set'

require 'rubygems'
require 'gosu'

class Camera
	include Physics::TwoD_Support
	
	attr_reader :shape, :queue

	def initialize(window)
		@followed_entity = nil
		
		# Center of screen
		pos = [window.width.to_meters / 2, window.height.to_meters / 2]
		
		init_physics	:rectangle, pos, 
						:height => window.height.to_meters, :width => window.width.to_meters,
						:mass => 50, :moment => :static, :collision_type => :camera
		
		@shape.sensor = true
		
		@queue = Hash.new
		#~ @queue = Set.new
		
		shape_metaclass = class << @shape; self; end
		[:add, :delete].each do |method|
			shape_metaclass.send :define_method, method do |entity|
				self.entity.queue[entity.layers].send method, entity
			end
		end
	end
	
	def update
		#~ @shape.body.reset_forces
		#~ self.move(@entity.shape.body.f)
		if @followed_entity
			warp @followed_entity.p
		end
	end
	
	# Return the amount in pixels to offset the rendering
	def offset
		corner = @shape.vert(0) # Should be the bottom-right vertex
		offset = corner - @shape.body.p
		return offset.x.to_px, offset.y.to_px
	end
	
	def follow(entity)
		@followed_entity = entity
		
		#~ pos = [@entity.x - @center.x,
				#~ @entity.y - @center.y]
				
		warp @followed_entity.p
	end
	
	def [](key)
		@queue[key] ||= Set.new
	end
	
	def move(force, offset=CP::ZERO_VEC_2)
		@shape.body.apply_force force, offset
	end
	
	def warp(vec2)
		self.p = vec2
	end
	
	def x
		@shape.body.p.x
	end
	
	def y
		@shape.body.p.y
	end
	
	# Move smoothly to a given point in the given time interval
	def pan(pos=[0,0,0], dt)
		
	end
end
