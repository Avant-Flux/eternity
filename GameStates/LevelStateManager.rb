# Manages the segments of the level
# A level is made out one or more LevelState objects

class LevelStateManager
	def initialize(window)
		@window = window
		
		@stack = Array.new
		# @current = 0		# Index into the "stack" which indicates which level the player is on
	end
	
	def update(dt)
		@stack.each do |state|
			state.update dt
		end
	end
	
	def load(space, name)
		@stack.pop.remove_from space if @stack.size >= 1
		
		@stack.push LevelState.load @window, space, name
		@stack.last.add_to space
		
		# @current += 1
	end
	
	# TOOD: Add level cache for things not currently visible, but which need to be loaded quickly
end
