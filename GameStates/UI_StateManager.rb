
class UI_StateManager
	def initialize(window, player, state_manager)
		@window = window
		@player = player
		@state_manager = state_manager
		
		@space = CP::Space.new
		
		@ui_state = UI_State.new @window, @space, @player
		@map = Map.new @window, @space, @player, @state_manager
	end
	
	def update
		#~ @space.step 1/60.0
		
		@ui_state.update
		@map.update
	end
	
	def draw
		@ui_state.draw
		
		@window.flush
		
		@map.draw
		
		@window.flush
	end
end
