#!/usr/bin/ruby

require 'set'

require 'rubygems'
require 'gosu'

class Camera
	#~ include Physics::TwoD_Support
	#~ include Physics::TwoD_Support::Rect
	#~ 
	#~ attr_reader :shape, :queue
	#~ attr_accessor :zoom
	#~ 
	#~ attr_accessor :transparency_mode
	
	attr_accessor :followed_entity
	
	#~ 
	#~ alias :px_old :px
	#~ alias :py_old :py
	#~ alias :px_old= :px=
	#~ alias :py_old= :py=
	
	MAX_ZOOM = 10
	MIN_ZOOM = 1
	DEFAULT_ZOOM = 1
	ZOOM_TICK = 0.2 # Percent to modulate the zoom by when zooming in or out

	attr_accessor :x_hat, :y_hat, :zoom
	
	
	def initialize(window, zoom=DEFAULT_ZOOM, transparency_mode=:selective)
		@window =  window
		@window_offset_x = @window.width/2
		@window_offset_y = @window.height/2
		
		@trimetric_transform = [
			Physics::Direction::X_HAT.x, Physics::Direction::X_HAT.y, 0, 0,
			Physics::Direction::Y_HAT.x, Physics::Direction::Y_HAT.y, 0, 0,
			0 ,0, 1, 0,
			0, 0, 0, 1
		]
		
		@zoom = 1
		
		#~ @followed_entity = nil
		#~ @zoom = zoom #Must be a percentage
		#~ @transparency_mode = transparency_mode # :selective, :always_on, :always_off
		#~ 
		#~ # Center of screen
		#~ pos = [window.width.to_meters / @zoom / 2, window.height.to_meters / @zoom / 2]
		#~ 
		#~ init_physics	pos, window.width.to_meters / @zoom, window.height.to_meters / @zoom, 
						#~ 50, :static, :camera, :centered
		#~ 
		#~ @shape.sensor = true
		#~ 
		#~ @queue = Hash.new
		#~ 
		#~ shape_metaclass = class << @shape; self; end
		#~ [:add, :delete].each do |method|
			#~ shape_metaclass.send :define_method, method do |gameobj|
				#~ self.gameobj.queue[gameobj.layers].send method, gameobj
			#~ end
		#~ end
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
	
	def flush
		# Render code blocks to the display
		position = @followed_entity.body.p.to_screen
		
		# Set origin of the entire game world to the given position
		@window.translate -position.x, -position.y do
			# Center the entire game world around the given position
			@window.translate @window_offset_x, @window_offset_y do
				# Zoom in on the given position
				@window.scale @zoom,@zoom, position.x, position.y do
					# Trimetric view transform
					@window.transform *@trimetric_transform do
						@trimetric_block.call
					end
					
					@window.flush
					
					@billboard_block.call
				end
			end
		end
		
		@window.flush
	end
	
	def draw_trimetric(&block)
		# Capture block to be rendered with trimetric transform
		@trimetric_block = block
	end
	
	def draw_billboarded(&block)
		# Non-trimetric world draw
		# Draw is referenced in screen coordinates, not world coordinates
		# However, the coordinate system has been translated around the tracked entity
		@billboard_block = block
	end
	
	def screen_offset(offset)
		# Offset the camera by a measure relative to the screen
		
	end
	
	def world_offset(offset)
		# Offset the camera by a measure relative to the world
		
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
