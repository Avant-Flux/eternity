#!/usr/bin/ruby
#Parent class of all Creatures, Fighting NPCs, and PCs
class Entity
	include PhysicsInterface
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
	
	attr_accessor :body, :shape
	attr_reader :level
	
	# strength		1
	# constitution	1
	# dexterity		1
	# power			1
	# control			1
	# flux			1
	
	#~ def initialize(window, animations, name, pos, mass, moment, lvl, element, faction=0)
	def initialize(window, name, mesh_name)
		# TODO: Allow setting mass and moment through constructor, or based on stats
		init_physics	:entity, Physics::Shape::Circle.new(self, 
						Physics::Body.new(self, 60, CP::INFINITY), 
						0.5)
		
		# init_stats
		@level = 1
		
		@model = Oni::Agent.new window, name, "#{mesh_name}.mesh"
	end
	
	def update(dt)
		@model.update dt
		@model.position = [@body.p.x, @body.pz, -@body.p.y]
		@model.rotation = @body.a + Math::PI/2
		# @sprite = @spritesheet[compute_direction]
	end
	
	def animation=(animation_name)
		@model.base_animation = animation_name
	end
	
	def resolve_ground_collision
		reset_jump
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
