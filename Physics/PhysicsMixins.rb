#!/usr/bin/ruby

module Physics
	module Dimensions
		module TwoD
			def width(units, scale=1)
				# Assume that if the shape does not respond to the width method,
				# then it is a circle.
				case units
					when :px
						if @animation
							(@animation.width * scale).round
						else
							self.width(:meters).to_px scale
						end
					when :meters
						if @shape.respond_to? :width
							return @shape.width
						else
							return @shape.radius * 2
						end
				end
			end
			
			def height(units, scale=1)
				# Assume that if the shape does not respond to the height method,
				# then it is a circle.
				
				case units
					when :px
						if @animation
							(@animation.height * scale).round
						else
							self.width(:meters).to_px scale
						end
					when :meters
						if @shape.respond_to? :height
							return @shape.height
						else
							return @shape.radius * 2
						end
				end
			end
			
			def radius(units, scale=1)
				case units
					when :px
						if @animation
							(@animation.width / 2.0 * scale).round
						else
							self.width(:meters).to_px scale
						end
					when :meters
						@shape.radius
				end
			end
			
			def diameter(units, scale=1)
				case units
					when :px
						if @animation
							(@animation.width * scale).round
						else
							self.width(:meters).to_px scale
						end
					when :meters
						radius(:meters) * 2
				end
			end
		end
		
		module ThreeD
			include Physics::Dimensions::TwoD
			
			def height(units, scale=1)
				case units
					when :px
						if @animation
							(@animation.height * scale).round
						else
							@height.to_px scale
						end
					when :meters
						if @animation
							@animation.height.to_meters
						else
							@height
						end
				end
			end
			
			def depth(units, scale=1)
				depth =	if @shape.is_a? Physics::Shape::Circle
							@shape.radius
						else
							@shape.height
						end
			
				return	case units
							when :px
								depth.to_px scale
							when :meters
								 depth
						end
			end
		end
	end
	
	# position, velocity, acceleration, etc
	module Positioning
		def p
			return @shape.body.p
		end
		
		def v
			return @shape.body.v
		end
		
		def p=(vec2)
			@shape.body.p = vec2
		end
		
		def v=(vec2)
			@shape.body.v = vec2
		end
		
		# Define alternate names for the previous methods
		alias :position :p;			alias :position= :p=
		alias :velocity :v;			alias :velocity= :v=
		
		# Setters and getters for individual values based on pseudo-3D space.
		# TODO remove changing both side and bottom x values if unnecessary.
		#For the z axis
		attr_accessor :fz, :vz, :pz
		#For position
		def px
			@shape.body.p.x
		end
		def py
			@shape.body.p.y
		end
		def px=(arg)
			@shape.body.p.x = arg
		end
		def py=(arg)
			@shape.body.p.y = arg
		end
		#For velocity
		def vx
			@shape.body.v.x
		end
		def vy
			@shape.body.v.y
		end
		def vx=(arg)
			@shape.body.v.x = arg
		end
		def vy=(arg)
			@shape.body.v.y = arg
		end
		
		def moving?
			@shape.body.v.length >= 0
		end
	end
	
	# force, torque, etc.
	module ForceApplication
		#~ def apply_force(arg=[0.0, 0.0, 0.0], offset=nil)
			#~ # Only apply x-coordinate force to one body, as the other should
			#~ # move in accordance to the constraint holding the two together.
			#~ 
			#~ # Default offset to nil in order to prevent the creation of unnecessary vectors.
			#~ if offset
				#~ @shape.body.apply_force CP::Vec2.new(arg[0], arg[1]), CP::Vec2.new(offset[0], offset[1])
			#~ else
				#~ @shape.body.apply_force CP::Vec2.new(arg[0], arg[1]), CP::ZERO_VEC_2
			#~ end
			#~ 
			#~ # Set force in the z direction regardless of the offset.
			#~ @fz += arg[2]
		#~ end
		
		def apply_force(force, offset=CP::ZERO_VEC_2)
			@shape.body.apply_force force, offset
		end
		
		def reset_forces
			@shape.body.reset_forces
		end
		
		def t
			@shape.body.t
		end
		
		def t=(arg)
			@shape.body.t = arg
		end
	end
	
	module Rotation
		def a; 			@shape.body.a; 		end
		def rot;		@shape.body.rot;		end
	
		def a=(arg); 	@shape.body.a = arg; 	end
		def rot=(arg);	@shape.body.rot = arg;	end
	end
	
	# Limits for v and w
	module SpeedLimit
		def v_limit;		@shape.body.v_limit;			end
		def w_limit;		@shape.body.w_limit;			end
		
		def v_limit=(arg);	@shape.body.v_limit = arg;		end
		def w_limit=(arg);	@shape.body.w_limit = arg;		end
	end
	
	module Elevation
		require 'set'
		
		def @elevation_queue.max
			max = -Float::INFINITY
			self.each do |elevation|
				max = elevation if elevation > max
			end
			
			return max
		end
		
		def elevation
			@elevation
		end
		
		def elevation=(arg)
			@elevation = arg
		end
		
		def set_elevation(elevation)
			@elevation_queue ||= Set.new
			@elevation_queue.add elevation
			@elevation = @elevation_queue.max
		end
		
		def reset_elevation(last_elevation)
			@elevation_queue.delete last_elevation
			if @elevation_queue.empty?
				@elevation = 0
			else
				@elevation = @elevation_queue.max
			end
		end
		
		#~ def set_elevation
			#~ @elevation = 0
			#~ 
			#~ $space.point_query pxy, Physics::PhysicsObject::LAYER_BOTTOM, 0 do |env|
				#~ if env.collision_type == :environment || env.collision_type == :building
					#~ #Raise elevation to the height of whatever is below.
					#~ height = env.physics_obj.height
					#~ @elevation = height if height > @elevation
				#~ end
			#~ end
			#~ 
			#~ # @output = []
			#~ $space.bb_query @bottom.bb, Physics::PhysicsObject::LAYER_BOTTOM, 0 do |shape|
				#~ puts "hey"
			#~ end
			#~ # Kernel::p @output
		#~ end
		
		def raise_to_elevation
			self.pz = @elevation
		end
	end
	
	# Methods that are used to manage Chipmunk attributes
	module Chipmunk
		def in_air?
			self.pz > 0
		end
		
		def layers
			@shape.layers
		end
		
		def layers=(arg)
			@shape.layers = arg
		end
		
		def static?
			@shape.static?
		end
		
		def add_to(space)
			space.add @shape
		end
		
		def remove_from(space)
			space.delete @shape
		end
		
		def reset_forces
			@shape.body.reset_forces
		end
		
		def vertex(index)
			@shape.vert index
		end
		
		def each_vertex(&block)
			@shape.each_vertex &block
		end
		
		def each_vertex_with_index(&block)
			@shape.each_vertex_with_index &block
		end
		
		def each_vertex_absolute(&block)
			@shape.each_vertex_absolute(&block)
		end
		
		def each_vertex_absolute_with_index(&block)
			@shape.each_vertex_absolute_with_index(&block)
		end
	end
end
