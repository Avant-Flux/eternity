class StateManager
	def initialize(window, space, player)
		@window = window	# Parent window
		@space = space		# Chipmunk space used for queries and to add gameobjects to
		@player = player
		#~ @layers = layers	# Bitvector specifying which layers to use with Chipmunk
		
		@stack = Array.new()
		
		
		@level_state = LevelState.new @window, @space, @player
	end
	
	def update
		@level_state.update
	end
	
	def draw
		@level_state.draw
	end
end
