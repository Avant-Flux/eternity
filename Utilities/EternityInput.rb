# Stores specifics for input within Eternity
# General input managed by InputHandler

class EternityInput < InputHandler
	attr_accessor :player
	
	def initialize(player, camera)
		super()
		
		@player = player
		@camera = camera
		
		
		init_gameplay_inputs
		
		bind_inputs
	end
	
	def bind_input(action, key)
		# Bind a particular action
		# This is generally useful for rebinding a key at runtime
		bind_action action, key
	end
	
	private
	
	def init_gameplay_inputs
		# Create actions
		self.mode = :gameplay
		new_action :up, :active do
			@player.body.apply_force CP::Vec2.new(0,10), CP::ZERO_VEC_2
		end
		new_action :down, :active do
			@player.body.apply_force CP::Vec2.new(0,-10), CP::ZERO_VEC_2
		end
		new_action :left, :active do
			@player.body.apply_force CP::Vec2.new(-10,0), CP::ZERO_VEC_2
		end
		new_action :right, :active do
			@player.body.apply_force CP::Vec2.new(10,0), CP::ZERO_VEC_2
		end
		
		new_action :jump, :rising_edge do
			@player.jump
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
		bind_action :up, Gosu::KbUp
		bind_action :down, Gosu::KbDown
		bind_action :left, Gosu::KbLeft
		bind_action :right, Gosu::KbRight
		
		bind_action :jump, Gosu::KbSpace
		
		#~ @inpman.bind_action :zoom_in, Gosu::Kb1
		#~ @inpman.bind_action :zoom_out, Gosu::MsWheelDown
		#~ @inpman.bind_action :zoom_reset, Gosu::Kb0
	end
end
