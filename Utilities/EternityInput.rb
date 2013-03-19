# Stores specifics for input within Eternity
# General input managed by InputHandler

require 'set'

class EternityInput < InputHandler
	attr_accessor :player
	
	# def initialize(window, player, camera, state_manager, ui_state_manager)
	def initialize(window, player, camera)
		super()
		
		@window = window
		@player = player
		@camera = camera
		# @state_manager = state_manager
		# @ui_state_manager = ui_state_manager
		
		@movement_dir = Set.new
		
		init_gameplay_inputs
		bind_gameplay_inputs
		
		# init_map_inputs
		# bind_map_inputs
	end
	
	def update
		super()
	end
	
	def bind_input(action, key)
		# Bind a particular action
		# This is generally useful for rebinding a key at runtime
		bind_action action, key
	end
	
	private
	# TODO: Make move have priority over jump - ie, move is evaluated first
	# actually could be interesting if behavior is order-dependent
	# 	move -> jump => more horizontal
	# 	jump -> move => more vertical
	#
	# ideally want this processed in some component, not the input handler, so that the AI functions the same way as the player
	
	def init_gameplay_inputs
		# Create actions
		
		# new_action :close, :rising_edge do
		# 	@window.close
		# end
		
		# new_action :show_fps, :rising_edge do
		# 	@window.show_fps = !@window.show_fps
		# end
		puts "INIT INPUTS"
		
		[:up, :down, :left, :right].each do |direction|
			add_action direction do |action|
				action.while_active do
					# NOTE: This method causes the player to move faster at a diagonal
					
					if @player.running
						@player.move direction, :run
					else
						@player.move direction, :walk
					end
				end
			end
		end
		
		add_action :run do |action|
			action.on_rising_edge do
				@player.running = true							
			end
			
			action.on_falling_edge do
				@player.running = false			
			end
		end
		
		add_action :jump do |action|
			action.on_rising_edge do
				@player.jump
				
				# Change behavior if holding down movement buttons				
			end
		end
		
		add_action :attack do |action|
			action.on_rising_edge do
				@player.attack
			end
		end
		
		# new_action :reload_level, :rising_edge do
		# 	@state_manager.reload
		# end
		
		# Camera control
		#~ new_action :zoom_in, :rising_edge do
			#~ @camera.zoom_in
		#~ end
		#~ new_action :zoom_out, :active do
			#~ @camera.zoom_out
		#~ end
		# new_action :zoom_reset, :rising_edge do
		# 	@state_manager.camera.zoom_reset
		# end
		
		# new_action :open_map, :rising_edge do
		# 	@ui_state_manager.open_map
		# 	self.mode = :map
		# end
	end
	
	def bind_gameplay_inputs
		#TODO:	Change bind so there is only one bind method, which will search all input types
		#		and bind action appropriately.
		# 		The implication of this is that name symbols must be unique.
		# bind_action :close, Gosu::KbEscape
		# bind_action :show_fps, @window.char_to_button_id("f")
		
		bind_action :up, :kb_up
		bind_action :down, :kb_down
		bind_action :left, :kb_left
		bind_action :right, :kb_right
		
		bind_action :jump, :kb_space
		
		bind_action :run, :kb_lshift
		
		bind_action :attack, :kb_lcontrol
		
		# bind_action :reload_level, Gosu::KbF1
		
		#~ @inpman.bind_action :zoom_in, Gosu::Kb1
		#~ @inpman.bind_action :zoom_out, Gosu::MsWheelDown
		# bind_action :zoom_reset, Gosu::Kb0
		
		# bind_action :open_map, Gosu::KbTab
	end
	
	def init_map_inputs
		# self.mode = :map
		
		# new_action :close_map, :rising_edge do
		# 	@ui_state_manager.pop Map
		# 	self.mode = :gameplay
		# end
		
		# new_action :zoom_in, :active do
		# 	@ui_state_manager.current.camera.zoom_in
		# end
		
		# new_action :zoom_out, :active do
		# 	@ui_state_manager.current.camera.zoom_out
		# end
	end
	
	def bind_map_inputs
		# bind_action :close_map, Gosu::KbTab
		# bind_action :zoom_in, Gosu::KbLeftShift
		# bind_action :zoom_out, Gosu::KbRightShift
	end
end
