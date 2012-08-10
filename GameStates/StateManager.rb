class StateManager
	def initialize(window, player)
		@window = window	# Parent window
		@player = player
		#~ @layers = layers	# Bitvector specifying which layers to use with Chipmunk
		
		@space = Physics::Space.new
		@space.set_default_collision_func do
			puts "default"
			
			false
		end
		@space.add_collision_handler :entity, :static, CollisionHandler::EntityEnv.new
		@space.add_collision_handler :entity, :slope, CollisionHandler::EntitySlope.new
		
		@stack = Array.new	# Active gamestates
		@cache = Hash.new	# States loaded into memory, but not currently active
		
		
		self.load "Tutorial"
		self.push "Tutorial"
		
		
		add_player(@player)
	end
	
	def update
		# Only update the state on the top of the stack
		@space.step
		@stack.last.update if @stack.last
	end
	
	def draw
		# Draw previous state, and then a translucent black quad, to "dim the lights"
		# on the previous area.  This is useful for when the player enters buildings.
		# Then draw the next state.
		# Repeat until all states are drawn
		# 
		# Algorithm assumes each state appears in the stack only once, and no two
		# states are equivalent.
		@stack.each_with_index do |state|
			state.draw
			
			@window.camera.flush
			
			if state != @stack.last
				# Render translucent quad
				color = Gosu::Color.new(130, 0,0,0)
				@window.draw_quad	0, 0, color,
									@window.width, 0, color,
									@window.width, @window.height, color,
									0, @window.height, color
									
			end
		end
	end
	
	def add_player(player)
		state = @stack.last
		state.add_player player
	end
	
	def top
		return @stack[0]
	end
	
    # Iterate over all states
	def each(&block)
		@stack.each &block
	end
    
    # Move gamestate from cache to active stack
    # Places gameobjects into the physics space
	def push(state_name)
		state = @cache.delete(state_name)
		state.add_to @space
		
		@stack << state
	end
	
	alias :<< :push
	
	# Remove top state, and tell it to clean up after itself
	# TODO: Move player back to appropriate spot in previous state.  Not the same as the spawn.
	
	# Move top active state to inactive set
	# Returns true if the operation was successful
	def pop
		state = @stack.pop
		if state
			state.finish
			@cache[state.name] = state
			
			return true
		else
			return false
		end
	end
	
	# Load a LevelState with the given name into memory
	# Loaded states are placed in the cache, not the active stack
	def load(state_name)
		@cache[state_name] = LevelState.load(@window, @space, state_name)
	end
	
	# Save level with given name to disk
	# Searches within only the cache
	def dump(state_name)
		# TODO: Refine dump() so it cascades
		if state = @cache.delete(state_name)
			state.dump
		end
	end
	
	# Pop all states, and dump all states to disk
	def clear
		while state = self.pop;	end
		
		@cache.each do |name, state|
			state.dump
		end
		
		@cache.clear
	end
	
	# ==================================
	# Raycasting
	# ==================================
	
	def raycast_mouse(&block)
		@space.point_query raycast(@window.mouse_x, @window.mouse_y), &block
	end
	
	def raycast(screen_x,screen_y)
		screen_pos = CP::Vec2.new screen_x, screen_y
		screen_pos.x += -@window.width/2
		screen_pos.y += -@window.height/2
		
		world_position = screen_pos.to_world
		world_position /= @window.camera.zoom
		world_position += @window.camera.followed_entity.body.p
		
		# DEBUG CODE
		# Draw circle on screen to show the raycast point
		#~ @window.camera.draw_billboarded do 
			#~ render_position = world_position.to_screen
			#~ @window.draw_circle		render_position.x, render_position.y, 
									#~ 0,300,Gosu::Color::GREEN, :stroke_width => 50
		#~ end
		
		return world_position
	end
	
	def save
		# Save the internal status of the game world
		# Ideally, this should either pause the game or run in a separate thread
		@stack.each do |state|
			state.save
		end
	end
	
	def rehash_space
		@space.rehash_static
	
	end
	
	def reload
		# Reload the state on top of the stack
		# Intended for testing purposes only
		state = self.pop
		
		@stack.push LevelState.load @window, @space, state.name
		
		@player.body.reset
		add_player @player
	end
end
