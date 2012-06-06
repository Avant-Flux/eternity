# Stores specifics for input within Eternity
# General input managed by InputHandler

require 'set'

class EternityInput < InputHandler
	attr_accessor :player
	
	def initialize(player, camera, state_manager)
		super()
		
		@player = player
		@camera = camera
		@state_manager = state_manager
		
		@movement_dir = Set.new
		
		init_gameplay_inputs
		
		bind_inputs
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
			
			@player.move move_direction
		end
	end
	
	def init_gameplay_inputs
		# Create actions
		self.mode = :gameplay
		
		[:up, :down, :left, :right].each do |direction|
			new_action direction, :rising_edge do
				@movement_dir.add direction
			end
			
			new_action direction, :falling_edge do
				@movement_dir.delete direction
			end
		end
		
		new_action :jump, :rising_edge do
			@player.jump
		end
		
		new_action :reload_level, :rising_edge do
			@state_manager.reload
		end
		
		# Camera control
		#~ new_action :zoom_in, :rising_edge do
			#~ @camera.zoom_in
		#~ end
		#~ new_action :zoom_out, :active do
			#~ @camera.zoom_out
		#~ end
		new_action :zoom_reset, :rising_edge do
			@camera.zoom_reset
		end
	end
	
	def bind_inputs
		#TODO:	Change bind so there is only one bind method, which will search all input types
		#		and bind action appropriately.
		# 		The implication of this is that name symbols must be unique.
		bind_action :up, Gosu::KbUp
		bind_action :down, Gosu::KbDown
		bind_action :left, Gosu::KbLeft
		bind_action :right, Gosu::KbRight
		
		bind_action :jump, Gosu::KbSpace
		
		bind_action :reload_level, Gosu::KbF1
		
		#~ @inpman.bind_action :zoom_in, Gosu::Kb1
		#~ @inpman.bind_action :zoom_out, Gosu::MsWheelDown
		bind_action :zoom_reset, Gosu::Kb0
	end
end
