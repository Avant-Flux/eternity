#!/usr/bin/ruby

require 'set'

require 'rubygems'
require 'gosu'

module Camera
	class TrimetricCamera
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
		MIN_ZOOM = 0.02
		DEFAULT_ZOOM = 0.16
		ZOOM_TICK = 0.01 # Percent to modulate the zoom by when zooming in or out
	
		attr_accessor :zoom
		
		
		def initialize(window, zoom=DEFAULT_ZOOM, transparency_mode=:selective)
			@window =  window
			@window_offset_x = @window.width/2
			@window_offset_y = @window.height/2
			
			@trimetric_transform = [
				Physics::Direction::X_HAT.x, Physics::Direction::X_HAT.y, 0, 0,
				Physics::Direction::Y_HAT.x, Physics::Direction::Y_HAT.y, 0, 0,
				0, 0, 1, 0,
				0, 0, 0, 1
			]
			
			@zoom = zoom
			
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
			
			@trimetric_queue = TrimetricQueue.new
			@billboard_queue = Array.new
		end
		
		def update
			#~ @shape.body.reset_forces
			#~ self.move(@entity.shape.body.f)
			if @followed_entity
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
			
			# Center the entire game world around the given position
			@window.translate @window_offset_x, @window_offset_y do
				# Zoom in on the given position
				@window.scale @zoom,@zoom do
					# Set origin of the entire game world to the given position
					@window.translate -position.x, -position.y+@followed_entity.body.pz.to_px do
						# Draw all trimetric world elements
						@trimetric_queue.each do |z, queue|
							@window.translate 0, -z.to_px do
								# Trimetric view transform
								@window.transform *@trimetric_transform do
									queue.each do |block|
										# TODO: Call culling for trimetric elements here
										block.call
									end
								end
							end
						end
						
						# Draw non-trimetric world elements
						@billboard_queue.each do |block|
							# TODO: Cull billboarded elements here.
							block.call
						end
					end
				end
			end
			
			@window.flush
			
			@trimetric_queue.clear
			@billboard_queue.clear
		end
		
		def draw_trimetric(z=0, &block)
			# The z parameter specifies world z coordinate, not z-index
			@trimetric_queue.draw(z, block)
		end
		
		def draw_billboarded(&block)
			# Non-trimetric world draw
			# Draw is referenced in screen coordinates, not world coordinates
			# However, the coordinate system has been translated around the tracked entity
			# TODO: Consider if it is necessary to pass z-index or z position
			@billboard_queue << block
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
		
		def move(force, offset=CP::Vec2::ZERO)
			@shape.body.apply_force force, offset
		end
		
		# Move smoothly to a given point in the given time interval
		def pan(pos=[0,0,0], dt)
			
		end
		# ======================================
		# ===== End Camera Control Methods =====
		# ======================================
	
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
		
		
		# ===========================
		# ===== Culling Methods =====
		# ===========================
		
		# Reject gameobject if it falls outside the viewing volume
		# Return true if object rejected
		def cull?(gameobj)
			return false
		end
		
		# Returns true if and only if the object inside the viewing volume
		def visible?(gameobj)
			return true
		end
		
		# ===============================
		# ===== End Culling Methods =====
		# ===============================
		
		class TrimetricQueue < Hash
			def initialize(*args)
				super(*args)
			end
			
			# Capture block to be rendered with trimetric transform
			def draw(z=0, block)
				# Trimetric queue is a hash table: key = z index, value = draw block
				# 
				self[z] ||= Array.new
				self[z] << block
			end
			
			def clear
				# ===== WARNING =====
				# Memory will leak if empty arrays stick around indefinitely
				self.each do |z, queue|
					queue.clear
				end
			end
		end
	end
end
