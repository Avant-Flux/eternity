#!/usr/bin/ruby

# Remember to move the render shape as well!
# Define xy plane as horizontal plane, and xz plane as vertical plane.

module Physics
	# position, velocity, acceleration, etc
	module Positioning
		def p
			return [px, py, pz]
		end
		
		def v
			return [vx, vy, vz]
		end
		
		def a
			return [ax, ay, az]
		end
		
		def p=(vec=[0.0, 0.0, 0.0])
			px,py,pz = vec
		end
		
		def v=(vec=[0.0, 0.0, 0.0])
			vx,vy,vz = vec
		end
		
		def a=(vec=[0.0, 0.0, 0.0])
			ax,ay,az = vec
		end
		
		# Define alternate names for the previous methods
		alias :position :p;			alias :position= :p=
		alias :velocity :v;			alias :velocity= :v=
		alias :acceleration :a;		alias :acceleration= :a=
		
		# Setters and getters for vectors based on plane.
		# Try not to use these unless you are using Chipmunk methods which generate vectors.
		def pxy;		@bottom.body.p;									end
		def pxz;		@side.body.p;									end
		def vxy;		@bottom.body.v;									end
		def vxz;		@side.body.v;									end
		def axy;		@bottom.body.a;									end
		def axz;		@side.body.a;									end
		def pxy=(arg);	@bottom.body.p = arg;	@side.body.p.x = arg.x;		end
		def pxz=(arg);	@side.body.p = arg;		@bottom.body.p.x = arg.x;	end
		def vxy=(arg);	@bottom.body.v = arg;	@side.body.v.x = arg.x;		end
		def vxz=(arg);	@side.body.v = arg;		@bottom.body.v.x = arg.x;	end
		def axy=(arg);	@bottom.body.a = arg;	@side.body.a.x = arg.x;		end
		def axz=(arg);	@side.body.a = arg;		@bottom.body.a.x = arg.x;	end
		
		# Setters and getters for individual values.
		# TODO remove changing both side and bottom x values if unnecessary.
		#For position
		def px;			@bottom.body.p.x; 								end
		def py;			@bottom.body.p.y;								end
		def pz;			@side.body.p.y - @bottom.body.p.y;				end
		def px=(arg);	@bottom.body.p.x = arg; @side.body.p.x = arg;	end
		def py=(arg);	@bottom.body.p.y = arg;							end
		def pz=(arg);	@side.body.p.y = @bottom.body.p.y + arg;		end
		#For velocity
		def vx;			@bottom.body.v.x;								end
		def vy;			@bottom.body.v.y;								end
		def vz;			@side.body.v.y;									end
		def vx=(arg);	@bottom.body.v.x = arg; @side.body.v.x = arg;	end
		def vy=(arg);	@bottom.body.v.y = arg;							end
		def vz=(arg);	@side.body.v.y = arg;							end
		#For acceleration
		def ax;			@bottom.body.a.x;								end
		def ay;			@bottom.body.a.y;								end
		def az;			@side.body.a.y;									end
		def ax=(arg);	@bottom.body.a.x = arg; @side.body.a.x = arg;	end
		def ay=(arg);	@bottom.body.a.y = arg;							end
		def az=(arg); 	@side.body.a.y = arg; 							end
	end
	
	# force, torque, etc.
	module ForceApplication
		def apply_force(arg=[0.0, 0.0, 0.0])
			# Only apply x-coordinate force to one body, as the other should
			# move in accordance to the constraint holding the two together.
			@bottom.body.apply_force CP::Vec2.new arg[0], arg[1]
			@side.body.apply_force CP::Vec2.new 0, arg[2]
		end
		
		def t
			@bottom.body.t
		end
		
		def t=(arg)
			@bottom.body.t = arg
		end
	end
end
