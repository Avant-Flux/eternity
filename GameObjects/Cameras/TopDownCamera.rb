module Camera
	# Camera which produces a straight-down top-down view.  Useful for maps etc.
	# Entites may be rendered in a symbolic format, as the trimetric do not make
	# sense in this projection.
	# 
	# Unlike the trimetric camera which follows a specific Entity in the world,
	# this camera creates a dummy Entity and follows that, in order to implement a free-look
	# camera.
	class TopDownCamera
		#~ attr_accessor :zoom
		#~ attr_accessor :transparency_mode
		attr_accessor :followed_entity
		
		MAX_ZOOM = 10
		MIN_ZOOM = 0.2
		DEFAULT_ZOOM = 1
		ZOOM_TICK = 0.2 # Percent to modulate the zoom by when zooming in or out
		
		attr_accessor :zoom
		
		
		def initialize(window, state_manager, zoom=DEFAULT_ZOOM, transparency_mode=:selective)
			@window =  window
			@state_manager = state_manager
			
			@window_offset_x = @window.width/2
			@window_offset_y = @window.height/2
			
			@transform = [
				1, 0, 0, 0,
				0, -1, 0, 0,
				0, 0, 1, 0,
				0, 0, 0, 1
			]
			
			@zoom = zoom
			
			@center = CP::ZERO_VEC_2
		end
		
		def update
			if @followed_entity
				#~ warp @followed_entity.p
				#~ self.px_old = @followed_entity.px
				#~ self.py_old = @followed_entity.py - @followed_entity.pz
				
				@center = @followed_entity.body.p
			else
				@center = CP::ZERO_VEC_2
			end
		end
		
		def draw
			# Move map origin to center of screen
			@window.translate @window.width/2, @window.height/2 do
				# Zoom in
				@window.scale @zoom,@zoom do
					# Transform coordinate system
					@window.transform *@transform do
						# Draw objects
						
						
						@window.translate -@center.x, -@center.y do
						
						@state_manager.each do |state|
							# Draw static objects
							state.each_static do |object|
								draw_static(object)
							end
							
							@window.scale 1/@zoom,1/@zoom do
								state.each_entity do |entity|
									draw_entity(entity)
								end
							end
							
							@window.flush
							
							if state != @state_manager.stack.last
								#~ @dimming_screen.draw
							end
						end
						
						end
					end
				end
			end
		end
		
		def draw_top_down(&block)
			
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
					
			#~ warp @followed_entity.body.p
		end
		
		def move(force, offset=CP::Vec2::ZERO)
			@shape.body.apply_force force, offset
		end
		
		# Warp to the specified coordinate
		#~ def warp(vec2)
			#~ self.p = vec2
		#~ end
		
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
		
		private
		
		def draw_static(object)
			z = object.body.pz + object.height
							
			color_modulation = 100
			base_color = Gosu::Color.new(200, 218-color_modulation/2,40,38)
			base_color.red += (z/30.0)*color_modulation
			color = base_color
			
			
			@window.draw_quad	object.body.p.x, object.body.p.y, color,
								object.body.p.x, object.body.p.y+object.depth, color,
								object.body.p.x+object.width, object.body.p.y+object.depth, color,
								object.body.p.x+object.width, object.body.p.y, color,
								z
		end
		
		def draw_entity(entity)
			radius = 10
			@window.draw_circle	entity.body.p.x*@zoom, entity.body.p.y*@zoom, entity.body.pz,
								radius, Gosu::Color::WHITE,
								:stroke_width => radius
		end
	end
end
