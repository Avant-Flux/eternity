#!/usr/bin/ruby

require 'set'

require 'rubygems'
require 'gosu'

class Camera
	include Physics::TwoD_Support
	include Physics::TwoD_Support::Rect
	
	attr_reader :shape, :queue
	attr_accessor :zoom
	
	MAX_ZOOM = 1
	MIN_ZOOM = 0.15
	DEFAULT_ZOOM = 0.30
	ZOOM_TICK = 0.005 # Percent to modulate the zoom by when zooming in or out

	def initialize(window)
		@window =  window
		@followed_entity = nil
		@zoom = DEFAULT_ZOOM #Must be a percentage
		# Center of screen
		pos = [window.width.to_meters / @zoom / 2, window.height.to_meters / @zoom / 2]
		
		#~ half_width = @window.width.to_meters
		#~ half_height = @window.height.to_meters
		#~ @bb = [-half_width, half_height, half_width, -half_height]
		
		#~ init_physics	:rectangle, pos, 
						#~ :height => window.height.to_meters / @zoom, 
						#~ :width => window.width.to_meters / @zoom,
		#~ init_physics	:circle, pos, :radius => 1,
						#~ :mass => 50, :moment => :static, :collision_type => :camera
						
		init_physics	pos, window.width.to_meters / @zoom, window.height.to_meters / @zoom, 
						50, :static, :camera
		
		@shape.sensor = true
		
		@queue = Hash.new
		
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
		
		#~ space.bb_query CP::BB.new(@shape.body.p.x + @bb[0], @shape.body.p.y + @bb[3],
								#~ @shape.body.p.x + @bb[2], @shape.body.p.y + @bb[1]) do |shape|
			#~ entity = shape.entity
			#~ @queue[entity.layers] ||= Set.new
			#~ @queue[entity.layers].add entity
			#~ arbiter.a.add arbiter.b.entity
		#~ end
	end
	
	# Return the amount in pixels to offset the rendering
	def offset
		return	@window.width / 2.0 - @shape.body.p.x.to_px(@zoom),
				@window.height / 2.0 - @shape.body.p.y.to_px(@zoom)
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
	
	def zoom_out
		if @zoom > MIN_ZOOM
			@zoom -= ZOOM_TICK
		end
	end
	
	def zoom_in
		if @zoom < MAX_ZOOM
			@zoom += ZOOM_TICK
		end
	end
	
	def zoom_reset
		@zoom = DEFAULT_ZOOM
	end
	
	# Move smoothly to a given point in the given time interval
	def pan(pos=[0,0,0], dt)
		
	end
end
