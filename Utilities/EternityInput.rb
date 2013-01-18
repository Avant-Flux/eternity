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
		
		self.mode = :gameplay
	end
	
	def update
		super()
		
		move_player
	end
	
	def bind_input(action, key)
		# Bind a particular action
		# This is generally useful for rebinding a key at runtime
		bind_action action, key
	end
	
	private
	
	def move_player
		# NOTE:	Currently favors movement left and up
		# 		Thus, if both up and down are pressed, the player will move up
		#~ puts @movement_dir.inspect
		
		unless @movement_dir.empty?
			move_direction = ""
			if @movement_dir.include? :up
				if move_direction == ""
					move_direction += "up"
				end
			end	
			if @movement_dir.include? :down
				if move_direction == ""
					move_direction += "down"
				end
			end
			
			if @movement_dir.include? :left
				unless move_direction == ""
					move_direction += "_"
				end
				
				move_direction += "left"
			elsif @movement_dir.include? :right
				unless move_direction == ""
					move_direction += "_"
				end
				
				move_direction += "right"
			end
			
			move_direction = move_direction.to_sym
			
			if @player.running
				@player.move move_direction, :run
			else
				@player.move move_direction, :walk
			end
		end
	end
	
	def init_gameplay_inputs
		# Create actions
		self.mode = :gameplay
		
		# new_action :close, :rising_edge do
		# 	@window.close
		# end
		
		# new_action :show_fps, :rising_edge do
		# 	@window.show_fps = !@window.show_fps
		# end
		
		[:up, :down, :left, :right].each do |direction|
			new_action direction, :rising_edge do
				@movement_dir.add direction
			end
			
			new_action direction, :falling_edge do
				@movement_dir.delete direction
			end
		end
		
		new_action :run, :rising_edge do
			@player.running = true
		end
		new_action :run, :falling_edge do
			@player.running = false
		end
		
		new_action :jump, :rising_edge do
			@player.jump
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
	
	def bind_gameplay_inputs
		#TODO:	Change bind so there is only one bind method, which will search all input types
		#		and bind action appropriately.
		# 		The implication of this is that name symbols must be unique.
		# bind_action :close, Gosu::KbEscape
		# bind_action :show_fps, @window.char_to_button_id("f")
		
		bind_action :up, 200
		bind_action :down, 208
		bind_action :left, 203
		bind_action :right, 205
		
		bind_action :jump, 57 # Spacebar
		
		bind_action :run, 42 # LeftShift
		
		# bind_action :reload_level, Gosu::KbF1
		
		#~ @inpman.bind_action :zoom_in, Gosu::Kb1
		#~ @inpman.bind_action :zoom_out, Gosu::MsWheelDown
		# bind_action :zoom_reset, Gosu::Kb0
		
		# bind_action :open_map, Gosu::KbTab
	end
	
	def bind_map_inputs
		# bind_action :close_map, Gosu::KbTab
		# bind_action :zoom_in, Gosu::KbLeftShift
		# bind_action :zoom_out, Gosu::KbRightShift
	end
end
