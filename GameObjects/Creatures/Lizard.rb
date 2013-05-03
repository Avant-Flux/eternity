class Lizard
	attr_reader :physics
	
	def initialize(window)
		@model = Component::Model.new window, "Lizard"
		
		scale = 0.2
		@model.scale scale, scale, scale
		
		@animation = Oni::Animation.new @model
		
		# TODO: Allow setting mass and moment through constructor, or based on stats
		# Weight should be between 70-90 kg
		# Max speed should not exceed 64km/hr
		# 	17 m / sec
		# TODO: Rename this component to Physics, and rename the Physics::Rect module
		@physics = Component::Collider::Rect.new self, 
						:width => @model.bb_depth*scale,
						:depth => @model.bb_width*scale,
						:height => @model.bb_height*scale,
						:mass => 72.5, :moment => 2, :friction => 0.0,
						:offset => :centered, :collision_type => :entity
		
		# @movement = Component::Movement.new @physics, @animation,
		# 				:max_movement_speed => 12,
		# 				:air_force_control => 0.30,
						
		# 				:walk_force => 1200, :run_force => 2000,
						
		# 				:jump_velocity => 4.3,
		# 				:jump_limit => 20000000000000000
	end
	
	def update(dt)
		@model.position = [@physics.body.p.x, @physics.body.pz, -@physics.body.p.y]
		@model.rotation = @physics.body.a + Math::PI/2
		
		# [@model, @animation, @physics, @movement].each do |component|
		[@model, @animation, @physics].each do |component|
			component.update dt
		end
	end
	
	def resolve_ground_collision
		
	end
end