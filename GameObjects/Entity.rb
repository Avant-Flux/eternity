#!/usr/bin/ruby
#Parent class of all Creatures, Fighting NPCs, and PCs

class Entity
	# include Statistics
	
	#~ include Combative
	
	#~ attr_reader :name, :stats, :lvl, :element
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
	
	attr_reader :physics, :movement
	
	def initialize(window, name, mesh_name)
		# init_stats
		@level = 1
		
		@model = Oni::Model.new window, name, "#{mesh_name}.mesh"
		@animation = Oni::Animation.new @model
		
		# @model = Component::Model.new window, mesh_name
		
		
		# TODO: Allow setting mass and moment through constructor, or based on stats
		# Weight should be between 70-90 kg
		# Max speed should not exceed 64km/hr
		# 	17 m / sec
		# TODO: Rename this component to Physics, and rename the Physics::Rect module
		@physics = Component::Collider::Circle.new self, :radius => 0.5, :height => 2,
						:mass => 70, :moment => CP::INFINITY, :collision_type => :entity
		@physics.u = 0.1
		@physics.model = @model
		
		@movement = Component::Movement.new @physics, @animation,
						:max_movement_speed => 12,
						:air_force_control => 0.10,
						
						:walk_force => 1200, :run_force => 2000,
						
						:jump_velocity => 5,
						:jump_limit => 20000000000000000
	end
	
	def update(dt)
		# TODO: Optimization - Update rotation of model only when the angle of the body is changed
		@model.update dt
		@animation.update dt
		@physics.update dt
		
		@movement.update dt
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
		@animation.base_animation = animation_name
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
end
