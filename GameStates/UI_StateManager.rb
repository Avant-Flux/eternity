
class UI_StateManager
	def initialize(window, player, state_manager)
		@window = window
		@player = player
		@state_manager = state_manager
		
		@space = CP::Space.new
		
		#~ @stack = Array.new
		@stack = [
			UI_State.new(@window, @space, @player),
			Map.new(@window, @space, @player, @state_manager)
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
end
