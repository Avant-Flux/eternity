module Physics
	module TwoD_Support
		include Physics::Chipmunk
		include Physics::Dimensions::TwoD
		include Physics::Positioning
		include Physics::ForceApplication
		include Physics::Rotation
		include Physics::SpeedLimit
	
		def init_physics_base(position, mass, moment, collision_type)
			# Allow setting of static mass or moment
			if mass == :static
				mass = Float::INFINITY
			end
			if moment == :static
				moment = Float::INFINITY
			end
			
			body = Physics::Body.new self, mass, moment
			
			# Set up proper methods for accessing dimensions
			body.p.x = position[0]
			body.p.y = position[1]
			
			return body
		end
		
		module Circle
			def init_physics(position, radius, mass, moment, collision_type, offset=CP::Vec2::ZERO)
				body = init_physics_base position, mass, moment, collision_type
				
				@shape = Physics::Shape::Circle.new self, body, radius, offset
				@shape.body.a = Physics::Direction::N_ANGLE
				@shape.collision_type = collision_type
			end
		end
		
		module Rect
			def init_physics(position, width, height, mass, moment, collision_type, offset=CP::Vec2::ZERO)
				body = init_physics_base position, mass, moment, collision_type
				
				@shape = Physics::Shape::Rect.new self, body, width, height, offset
				@shape.collision_type = collision_type
			end
		end
		
		module Square
			def init_physics(position, side, mass, moment, collision_type, offset=CP::Vec2::ZERO)
				body = init_physics_base position, mass, moment, collision_type
				
				@shape = Physics::Shape::Rect.new self, body, side, side, offset
				@shape.collision_type = collision_type
			end
		end
		
		module PerspRect
			def init_physics(position, width, height, mass, moment, collision_type, offset=CP::Vec2::ZERO)
				body = init_physics_base position, mass, moment, collision_type
				
				@shape = Physics::Shape::PerspRect.new self, body, width, height, offset
				@shape.collision_type = collision_type
			end
		end
		
		module Poly
			def init_physics(position, verts, mass, moment, collision_type, offset=CP::Vec2::ZERO)
				body = init_physics_base position, mass, moment, collision_type
				
				@shape = Physics::Shape::Poly.new self, body, verts, offset
				@shape.collision_type = collision_type
			end
		end
	end
end
