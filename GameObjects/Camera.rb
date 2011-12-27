#!/usr/bin/ruby

require 'set'

require 'rubygems'
require 'gosu'

class Camera
	include Physics::TwoD_Support
	include Physics::TwoD_Support::Rect
	
	attr_reader :shape, :queue
	attr_accessor :zoom
	
	alias :px_old :px
	alias :py_old :py
	alias :px_old= :px=
	alias :py_old= :py=
	
	MAX_ZOOM = 1
	MIN_ZOOM = 0.01
	DEFAULT_ZOOM = 0.30
	ZOOM_TICK = 0.005 # Percent to modulate the zoom by when zooming in or out

	def initialize(window, zoom=DEFAULT_ZOOM)
		@window =  window
		@followed_entity = nil
		@zoom = zoom #Must be a percentage
		# Center of screen
		pos = [window.width.to_meters / @zoom / 2, window.height.to_meters / @zoom / 2]
		
		init_physics	pos, window.width.to_meters / @zoom, window.height.to_meters / @zoom, 
						50, :static, :camera, :centered
		
		@shape.sensor = true
		
		@queue = Hash.new
		
		shape_metaclass = class << @shape; self; end
		[:add, :delete].each do |method|
			shape_metaclass.send :define_method, method do |gameobj|
				self.gameobj.queue[gameobj.layers].send method, gameobj
			end
		end
	end
	
	def update
		#~ @shape.body.reset_forces
		#~ self.move(@entity.shape.body.f)
		if @followed_entity
			#~ warp @followed_entity.p
			self.px_old = @followed_entity.px
			self.py_old = @followed_entity.py - @followed_entity.pz
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
		return	@window.width / 2.0 - px_old.to_px(@zoom),
				@window.height / 2.0 - py_old.to_px(@zoom)
	end
	
	def [](key)
		@queue[key] ||= Set.new
	end
	
	# ==================================
	# ===== Camera Control Methods =====
	# ==================================
	
	def follow(entity)
		@followed_entity = entity
		
		#~ pos = [@entity.x - @center.x,
				#~ @entity.y - @center.y]
				
		warp @followed_entity.p
	end
	
	def move(force, offset=CP::Vec2::ZERO)
		@shape.body.apply_force force, offset
	end
	
	# Warp to the specified coordinate
	def warp(vec2)
		self.p = vec2
	end
	
	# Move smoothly to a given point in the given time interval
	def pan(pos=[0,0,0], dt)
		
	end
	# ======================================
	# ===== End Camera Control Methods =====
	# ======================================


	# Add the corresponding game object when it's in the air,
	# and thus "detached" from the physics object which typically
	# controls rendering.
	# Actually, this needs to trigger whenever pz > 0,
	# as this separation will occur even when the entity is not
	# in the air.
	def arial_camera_add(gameobj)
		half_width = gameobj.width(:meters)/2.0
		height = gameobj.height(:meters)
		
		# Create bb in local coordinates
		l = -half_width
		b = 0
		r = half_width
		t = height
		
		# Translate to global
		t += gameobj.py - gameobj.pz
		b += gameobj.py - gameobj.pz
		l += gameobj.px
		r += gameobj.px
		
		bb = CP::BB.new l,b,r,t
		#~ if @shape.bb.intersect? bb
		@shape.add gameobj
		#~ end
	end
	
	# =========================
	# ===== Zoom Controls =====
	# =========================
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
	# =============================
	# ===== End Zoom Controls =====
	# =============================
	
	# ==============================
	# ===== Position Accessors =====
	# ==============================
	def px
		if @followed_entity
			@followed_entity.px
		else
			self.px_old
		end
	end
	
	def py
		if @followed_entity
			@followed_entity.py
		else
			self.py_old
		end
	end
	
	def pz
		if @followed_entity
			@followed_entity.pz
		else
			0
		end
	end
	
	def py_
		if @followed_entity
			@followed_entity.py_
		else
			0
		end
	end
	# ==================================
	# ===== End Position Accessors =====
	# ==================================
end
