#!/usr/bin/ruby
#Parent class of all Creatures, Fighting NPCs, and PCs

class Entity
	# include Statistics
	
	#~ include Physics::ThreeD_Support
	#~ include Physics::ThreeD_Support::Cylinder
	#~ include Physics::Movement::Entity
	
	#~ include Combative
	
	#~ attr_reader :name, :stats, :lvl, :element
	#~ attr_reader  :moving, :move_constant, :movement_force
	#~ attr_accessor :faction, :visible, :intense
	#~ # Attributes:	Innate properties
	#~ # Status:		Properties imposed by effects, like status effects
	#~ attr_reader :attributes, :status
	
	attr_reader :level
	
	# strength		1
	# constitution	1
	# dexterity		1
	# power			1
	# control			1
	# flux			1
	
	attr_reader :physics
	
	def initialize(window, name, mesh_name)
		# init_stats
		@level = 1
		
		@model = Oni::Agent.new window, name, "#{mesh_name}.mesh"
		
		# @model = 
		@animation = nil
		
		# TODO: Allow setting mass and moment through constructor, or based on stats
		# Weight should be between 70-90 kg
		# Max speed should not exceed 64km/hr
		# 	17 m / sec
		# TODO: Rename this component to Physics, and rename the Physics::Rect module
		@physics = Component::Collider::Circle.new self, :radius => 0.5, :height => 2,
						:mass => 70, :moment => CP::INFINITY, :collision_type => :entity
		@physics.u = 0.1
		
		@movement = Component::Movement.new @physics, @animation,
						:max_movement_speed => 12,
						:walk_force => 2000, :run_force => 90000,
						:jump_limit => 20000000000000000
	end
	
	def update(dt)
		# TODO: Optimization - Update rotation of model only when the angle of the body is changed
		@model.update dt
		@model.position = [@physics.body.p.x, @physics.body.pz, -@physics.body.p.y]
		@model.rotation = @physics.body.a + Math::PI/2
		
		# Walk speed modulation notes
		# What is walk speed? (like, velocity)
		# 	stride length, step time (time elapsed for one step)
		# Should have a baseline walk speed, and then speed up or down from there
		# 	How much can you scale without distorting? - no distortion
		# 	Better to speed up or slow down? - shouldn't matter
		# Scale step rate linearly with velocity
		
		if @physics.body.v.length < 0.3
			# Effectively still
			# Don't reset the animation if it is already set
			# Doing that every frame will make the animation loop the first frame
			@model.base_animation = "" if @model.base_animation != ""
		else
			# Moving
			@model.base_animation = "my_animation" if @model.base_animation != "my_animation"
		end
	end
	
	def body
		# TODO: Depreciate method
		@physics.body
	end
	
	def shape
		# TODO: Depreciate method
		@physics.shape
	end
	
	def jump(*args)
		# TODO: Depreciate method
		@movement.jump *args
	end
	
	def move(*args)
		# TODO: Depreciate method
		@movement.move *args
	end
	
	def running
		# TODO: Depreciate method
		@movement.running
	end
	
	def running=(arg)
		# TODO: Depreciate method
		@movement.running = arg
	end
	
	def jump_count
		# TODO: Depreciate method
		@movement.jump_count
	end
	
	def animation=(animation_name)
		@model.base_animation = animation_name
	end
	
	def resolve_ground_collision
		@movement.reset_jump
	end
	
	def visible?
		@model.visible?
	end
	
	def create
		
	end
	
	def load
		
	end
	
	def save
		
	end
	
	def position
		#TODO: Depreciate method
		"#{@name}: #{px}, #{py}, #{pz}, elevation: #{elevation}"
	end
	
	private
	
	def compute_direction
		#~ angle = @body.a
		#~ puts angle
		
		# All angles are in CP space - thus, radians
		#~ puts angle + Math::PI # 2PI is left, angle increases CCW
		#~ puts ((angle + Math::PI)/(Math::PI*2))*8
		
		#~ return (((@body.a + Math::PI)/(Math::PI*2))*8).to_i - 1
		return 4*@body.a/Math::PI + 3
	end
end
