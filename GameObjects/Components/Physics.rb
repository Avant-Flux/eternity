module Component
	module Collider
		# TODO: Rename Collider to Physics
		# Requires renaming the current Physics module to something else to avoid symbol collision
		
		class Base
			attr_accessor :model
			attr_reader :shape, :body, :height
			
			def initialize(gameobj, model, shape_type, collision_type, friction,
						height, mass, moment, *args)
				@gameobj = gameobj
				@model = model
				@height = height
				
				@body =	if mass == CP::INFINITY
							Physics::StaticBody.new gameobj
						else
							Physics::Body.new gameobj, mass, moment
						end
				
				@shape = Physics::Shape.const_get(shape_type).new gameobj, @body, *args
				@shape.collision_type = collision_type
				
				@shape.u = friction
				
				# @body.v_limit = 50
				#~ @body.w_limit = 100 # Limit rotational velocity
			end
			
			def update(dt)
				if @model
					@model.position = [@body.p.x, @body.pz, -@body.p.y]
					@model.rotation = @body.a + Math::PI/2
				end
			end
			
			def warp(x,y,z)
				@body.p.x = x
				@body.p.y = y
				@body.pz = z
			end
			
			def add_to(space)
				if @body.is_a? Physics::StaticBody
					space.add_static_shape @shape
				else
					space.add_shape @shape
				end
				
				space.add_body @body
				
				# TODO:	Perform initial raycast when adding entity to space to determine
				# 		starting elevation.
			end
			
			def remove_from(space)
				if @body.is_a? Physics::StaticBody
					space.remove_static_shape @shape
				else
					space.remove_shape @shape
				end
				
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
				
				:radius => 1,
				
				:friction => 0.0,
				:model => nil
			}
			
			def initialize(gameobj, opts={})
				opts = DEFAULT_OPTIONS.merge opts
				
				super(gameobj, opts[:model], :Circle, opts[:collision_type], opts[:friction],
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
				
				:verts => 0,
				
				:friction => 0.0,
				:model => nil
			}
			
			def initialize(gameobj, opts={})
				opts = DEFAULT_OPTIONS.merge opts
				
				super(gameobj, opts[:model], :Poly, opts[:collision_type], opts[:friction],
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
				:depth => 1,
				
				:friction => 0.0,
				:model => nil
			}
			
			def initialize(gameobj, opts={})
				opts = DEFAULT_OPTIONS.merge opts
				
				super(gameobj, opts[:model], :Rect, opts[:collision_type], opts[:friction],
					opts[:height], opts[:mass], opts[:moment],
					opts[:width], opts[:depth], opts[:offset])
			end
		end
	end
end

