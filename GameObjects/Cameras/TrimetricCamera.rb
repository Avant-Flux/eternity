#!/usr/bin/ruby

require 'set'

require 'rubygems'
require 'gosu'

module Camera
	# Draws any objects it finds within the scene.
	# Static objects must implement #draw_trimetric and #draw_billboarded
	# Non-statics must implement #draw_billboarded
	# 
	# All objects must implement z_index
	class TrimetricCamera
		#~ include Physics::TwoD_Support
		#~ include Physics::TwoD_Support::Rect
		#~ 
		#~ attr_reader :shape, :queue
		#~ attr_accessor :transparency_mode
		
		attr_accessor :followed_entity
		
		MAX_ZOOM = 10
		MIN_ZOOM = 0.02
		DEFAULT_ZOOM = 0.16
		ZOOM_TICK = 0.01 # Percent to modulate the zoom by when zooming in or out
	
		attr_accessor :zoom
		
		
		def initialize(window, space, zoom=DEFAULT_ZOOM, transparency_mode=:selective)
			@window =  window
			@space = space
			
			@window_offset_x = @window.width/2
			@window_offset_y = @window.height/2
			
			@trimetric_transform = [
				Physics::Direction::X_HAT.x, Physics::Direction::X_HAT.y, 0, 0,
				Physics::Direction::Y_HAT.x, Physics::Direction::Y_HAT.y, 0, 0,
				0, 0, 1, 0,
				0, 0, 0, 1
			]
			
			#~ @followed_entity = nil
			@zoom = zoom #Must be a percentage
			@transparency_mode = transparency_mode # :selective, :always_on, :always_off
			
			#~ # Center of screen
			#~ pos = [window.width.to_meters / @zoom / 2, window.height.to_meters / @zoom / 2]
			#~ 
			#~ init_physics	pos, window.width.to_meters / @zoom, window.height.to_meters / @zoom, 
							#~ 50, :static, :camera, :centered
			#~ 
			#~ @shape.sensor = true
			#~ 
			#~ shape_metaclass = class << @shape; self; end
			#~ [:add, :delete].each do |method|
				#~ shape_metaclass.send :define_method, method do |gameobj|
					#~ self.gameobj.queue[gameobj.layers].send method, gameobj
				#~ end
			#~ end
			
			@queue = []
			
			#~ @bounding_box = CP::BB.new() # l,b,r,t
			#~ @body = Physics::Body.new self, 10, CP::INFINITY
			#~ @shape = Physics::Shape::Rect.new self, @body, window.width.to_meters, window.width.to_meters
			#~ @shape.sensor = true
		end
		
		def update
			#~ @shape.body.reset_forces
			#~ self.move(@entity.shape.body.f)
			
			#~ if @followed_entity
				#~ self.px_old = @followed_entity.px
				#~ self.py_old = @followed_entity.py - @followed_entity.pz
			#~ end
			
			# TODO: Try sensor object instead of bb query, as bb query method seems to cause tearing
			# NOTE: Cause of screen tearing seems to be related to running too many OpenGL apps (browser tabs)
			shape = @followed_entity.shape
			radius = @window.width.to_meters*4
			@space.bb_query CP::BB.new(shape.body.p.x - radius, shape.body.p.y - radius,
									shape.body.p.x + radius, shape.body.p.y + radius) do |shape|
				@queue << shape.gameobject
			end
		end
		
		# Render code blocks to the display
		def draw
			# NOTE: Current rendering algorithm is 3-pass
			
			@queue.sort! do |a, b|
				# Return -1, 0, or 1, just like Comparable<=>
				screen_pos_a = a.body.p.to_screen
				screen_pos_b = b.body.p.to_screen
				
				screen_pos_a.y <=> screen_pos_b.y
				#~ screen_pos_b.y <=> screen_pos_a.y
				#~ b.body.p.y <=> a.body.p.y
			end
			
			position = @followed_entity.body.p.to_screen
			
			# Center the entire game world around the given position
			@window.translate @window_offset_x, @window_offset_y do
				# Zoom in on the given position
				@window.scale @zoom,@zoom do
					# Set origin of the entire game world to the given position
					@window.translate -position.x, -position.y+@followed_entity.body.pz.to_px do
						draw_trimetric
						draw_shadows
						draw_billboarded
					end
				end
			end
			
			@window.flush
			@queue.clear
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
		
		private
		
		def draw_trimetric
			@queue.each do |gameobject|
				# Go up the screen to compensate for z position, then draw trimetric
				# TODO: Move z calculation into Entity and StaticObject for better polymorphism
				z = if gameobject.is_a? Entity
					gameobject.body.pz
				elsif gameobject.is_a? StaticObject
					gameobject.body.pz + gameobject.height
				end
				
				@window.translate 0, -z.to_px do
					@window.transform *@trimetric_transform do
						gameobject.draw_trimetric
					end
				end
			end
		end
		
		def draw_shadows
			@queue.each do |gameobject|
				if gameobject.is_a? Entity
					@window.translate 0, -gameobject.body.elevation.to_px do
						@window.transform *@trimetric_transform do
							gameobject.draw_shadow
						end
					end
				elsif gameobject.is_a? StaticObject
					render_height = gameobject.shadow_height(@space)
					#~ if gameobject.is_a?(Slope) || render_height != gameobject.body.pz
					
						@window.translate 0, -render_height.to_px do
							@window.transform *@trimetric_transform do
								gameobject.draw_shadow render_height
							end
						end
					#~ end
				end
			end
		end
		
		def draw_billboarded
			@queue.each do |gameobject|
				gameobject.draw_billboarded
			end
		end
	end
end
