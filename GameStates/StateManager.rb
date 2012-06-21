class StateManager
	# TODO: Save states as they pop off the stack
	# TODO: F1 to reload doesn't work as expected.  Suspect that space is not being cleared.
	attr_reader :stack
	
	def initialize(window, player)
		@window = window	# Parent window
		@player = player
		#~ @layers = layers	# Bitvector specifying which layers to use with Chipmunk
		
		@space = Physics::Space.new
		@space.add_collision_handler :entity, :static, CollisionHandler::EntityEnv.new
		
		@stack = Array.new()
		
		
		@stack << LevelState.load(@window, @space, "Tutorial")
		add_player(@player)
	end
	
	def update
		# Only update the state on the top of the stack
		@space.step
		@stack.last.update
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
	
	def save
		# Save the internal status of the game world
		# Ideally, this should either pause the game or run in a separate thread
		@stack.each do |state|
			state.save
		end
	end
	
	def reload
		# Reload the state on top of the stack
		# Intended for testing purposes only
		state = @stack.pop
		@stack.push LevelState.load @window, @space, state.name
		
		@player.body.reset
		add_player @player
	end
    
    def top
        return stack[0]
    end
end
