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
	
	def initialize(window, name)
		# init_stats
		@level = 1
		
		@model = Component::Model.new window, name
		@animation = Oni::Animation.new @model
		
		# TODO: Allow setting mass and moment through constructor, or based on stats
		# Weight should be between 70-90 kg
		# Max speed should not exceed 64km/hr
		# 	17 m / sec
		# TODO: Rename this component to Physics, and rename the Physics::Rect module
		@physics = Component::Collider::Circle.new self, :radius => 0.4, :height => 1.75,
						:mass => 72.5, :friction => 0.0,
						:collision_type => :entity, :model => @model
		
		@movement = Component::Movement.new @physics, @animation,
						:max_movement_speed => 12,
						:air_force_control => 0.30,
						
						:walk_force => 1200, :run_force => 2000,
						
						:jump_velocity => 4.3,
						:jump_limit => 20000000000000000
		
		@equipment = Component::Equipment.new( window, @physics, @model, @animation,
			:head => "Hair",
			
			:body => "jacket",
			:legs => "pants",
			:feet => "shoes",
			
			:weapon_right => "Falchion"
		)
		
		# @stats = Component::Stats.new do
		# 	strength		1
		# 	constitution	1
		# 	dexterity		1
		# 	power			1
		# 	control			1
		# 	flux			1
		# end
		
		# @stats.strength
		# @stats.strength = 1
		
		@combat = Component::Combat.new @animation
	end
	
	def update(dt)
		# TODO: Figure out what order components should update in
		# If physics is always updated first, perhaps it should be updated as a system
		# TODO: Optimization - Update rotation of model only when the angle of the body is changed
		
		# NOTE: Do not update Movement component here, as it needs to updated BEFORE the physics step, while everything in this update should be evaluated AFTER
		[@model, @animation, @combat, @physics, @equipment].each do |component|
			component.update dt
		end
	end
	
	def attack
		@combat.attack
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
	
	def resolve_ground_collision
		@movement.reset_jump
	end
	
	def visible?
		@model.visible?
	end
	
	def save
		
	end
	
	class << self
		def load
			
		end
	end
end
