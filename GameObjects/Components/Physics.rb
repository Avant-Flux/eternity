module Component
	module Collider
		class Base
			attr_reader :shape, :body, :height
			
			def initialize(gameobj, shape_type, collision_type, 
						height, mass, moment, *args)
				@gameobj = gameobj
				
				@body = Physics::Body.new gameobj, mass, moment
				
				@shape = Physics::Shape.const_get(shape_type).new gameobj, @body, *args
				@shape.collision_type = collision_type
				
				@height = height
				
				# @body.v_limit = 50
				#~ @body.w_limit = 100 # Limit rotational velocity
			end
			
			def warp(x,y,z)
				@body.p.x = x
				@body.p.y = y
				@body.pz = z
			end
			
			def add_to(space)
				space.add_shape @shape
				space.add_body @body
				
				# TODO:	Perform initial raycast when adding entity to space to determine
				# 		starting elevation.
			end
			
			def remove_from(space)
				space.remove_shape @shape
				space.remove_body @body
			end
			
			def u=(friction)
				@shape.u = friction
			end
		end
		
		class Circle < Base
			DEFAULT_OPTIONS = {
				:offset => CP::ZERO_VEC_2,
				
				:height => 1,
				:mass => 1,
				:moment => CP::INFINITY,
				:collision_type => nil,
				
				:radius => 1
			}
			
			def initialize(gameobj, opts={})
				DEFAULT_OPTIONS.merge opts
				
				super(gameobj, :Circle, opts[:collision_type], 
					opts[:height], opts[:mass], opts[:moment],
					opts[:radius], opts[:offset])
			end
		end
		
		class Poly < Base
			DEFAULT_OPTIONS = {
				:offset => CP::ZERO_VEC_2,
				
				:height => 1,
				:mass => 1,
				:moment => CP::INFINITY,
				:collision_type => nil,
				
				:verts => 0
			}
			
			def initialize(gameobj, opts={})
				DEFAULT_OPTIONS.merge opts
				
				super(gameobj, :Poly, opts[:collision_type], 
					opts[:height], opts[:mass], opts[:moment],
					opts[:verts], opts[:offset])
			end
		end
		
		class Rect < Base
			DEFAULT_OPTIONS = {
				:offset => CP::ZERO_VEC_2,
				
				:height => 1,
				:mass => 1,
				:moment => CP::INFINITY,
				:collision_type => nil,
				
				:width => 1,
				:height => 1
			}
			
			def initialize(gameobj, opts={})
				DEFAULT_OPTIONS.merge opts
				
				super(gameobj, :Rect, opts[:collision_type], 
					opts[:height], opts[:mass], opts[:moment],
					opts[:width], opts[:height], opts[:offset])
			end
		end
	end
end

