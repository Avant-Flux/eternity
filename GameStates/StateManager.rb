class StateManager
	def initialize(window, space, player)
		@window = window	# Parent window
		@space = space		# Chipmunk space used for queries and to add gameobjects to
		@player = player
		#~ @layers = layers	# Bitvector specifying which layers to use with Chipmunk
		
		@stack = Array.new()
		
		
		@stack << LevelState.new(@window, @space, @player)
	end
	
	def update
		# Only update the state on the top of the stack
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
end
