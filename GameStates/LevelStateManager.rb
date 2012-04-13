# Manages the segments of the level
# A level is made out one or more LevelState objects

class LevelStateManager < StateManager
	def initialize(window, space, layers, camera)
		super(window, space, layers)
		
		@camera = camera	# Camera used to cull which objects should be displayed
		@current = 0		# Index into the "stack" which indicates which level the player is on
	end
	
	def load(name)
		@stack.push LevelState.load @window, @space, @layers, name, @camera.queue
		@current += 1
	end
end
