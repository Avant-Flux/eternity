
class UI_StateManager
	def initialize(window, player, state_manager)
		@window = window
		@player = player
		@state_manager = state_manager
		
		@space = CP::Space.new
		
		@map = Map.new(@window, @space, @player, @state_manager)
		#~ @stack = Array.new5
		@stack = [
			UI_State.new(@window, @space, @player),
		]
	end
	
	def update
		#~ @space.step 1/60.0
		
		@stack.each do |interface|
			interface.update
		end
	end
	
	def draw
		@stack.each do |interface|
			interface.draw
			
			@window.flush
		end
	end
	
	def current
		return @stack.last
	end
	
	# Close all states, up to and including a state of the given class
	# If no parameter, then just pop one state
	# WARNING: Can completely deplete the stack, which will result in no UI
	def pop(klass=nil)
		if klass
			begin
				state = @stack.pop
			end until(state.is_a? klass)
		else
			@stack.pop
		end
	end
	
	def open_map
		@stack << @map 
	end
end
