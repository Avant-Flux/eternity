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
	end
	
	def update
		#~ @shape.body.reset_forces
		#~ self.move(@entity.shape.body.f)
		if @followed_entity
			warp @followed_entity.p
		end
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
	
	def add(entity)
		#~ @queue.add entity
	end
	
	def delete(entity)
		#~ @queue.delete entity
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
	
	# Move smoothly to a given point in the given time interval
	def pan(pos=[0,0,0], dt)
		
	end
end
