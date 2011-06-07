#!/usr/bin/ruby

# Remember to move the render shape as well!
# Define xy plane as horizontal plane, and xz plane as vertical plane.

class Numeric
	#Code taken from MoreChipmunkAndRMagick.rb from the gosu demos
	def radians_to_vec2
		CP::Vec2.new(Math::cos(self), Math::sin(self))
	end
end



module Physics
	# position, velocity, acceleration, etc
	module Positioning
		def p
			return [px, py, pz]
		end
		
		def v
			return [vx, vy, vz]
		end
		
		def p=(vec=[0.0, 0.0, 0.0])
			self.px,self.py,self.pz = vec
		end
		
		def v=(vec=[0.0, 0.0, 0.0])
			self.vx,self.vy,self.vz = vec
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
	end
	
	# force, torque, etc.
	module ForceApplication
		def apply_force(arg=[0.0, 0.0, 0.0], offset=nil)
			# Only apply x-coordinate force to one body, as the other should
			# move in accordance to the constraint holding the two together.
			
			# Default offset to nil in order to prevent the creation of unnecessary vectors.
			if offset
				@shape.body.apply_force CP::Vec2.new(arg[0], arg[1]), CP::Vec2.new(offset[0], offset[1])
			else
				@shape.body.apply_force CP::Vec2.new(arg[0], arg[1]), CP::ZERO_VEC_2
			end
			
			# Set force in the z direction regardless of the offset.
			@fz += arg[2]
		end
		
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
		def elevation
			@elevation
		end
		
		def elevation=(arg)
			@elevation = arg
		end
		
		def set_elevation
			@elevation = 0
			
			$space.point_query pxy, Physics::PhysicsObject::LAYER_BOTTOM, 0 do |env|
				if env.collision_type == :environment || env.collision_type == :building
					#Raise elevation to the height of whatever is below.
					height = env.physics_obj.height
					@elevation = height if height > @elevation
				end
			end
			
			#~ @output = []
			$space.bb_query @bottom.bb, Physics::PhysicsObject::LAYER_BOTTOM, 0 do |shape|
				puts "hey"
			end
			#~ Kernel::p @output
		end
		
		def raise_to_elevation
			self.pz = @elevation
		end
	end
	
	module Interface
		def x; 			@physics.px;			end
		def y; 			@physics.py;			end
		def z; 			@physics.pz;			end
		
		def x=(arg); 	@physics.px = arg;		end
		def y=(arg); 	@physics.py = arg;		end
		def z=(arg); 	@physics.pz = arg;		end
		
		def elevation;			@physics.elevation;			end
		def elevation=(arg);	@physics.elevation = arg;	end
	end
end
