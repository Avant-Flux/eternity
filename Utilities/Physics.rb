#!/usr/bin/ruby
 
module Physics
	#This is the new structure for the chipmunk handling of the game engine
	#It should create a complete abstraction of the underlying chipmunk code.
	#It may eventually be possible to forgo usage of chipmunk-ffi at some point
	#and simply use ffi and the C library.
	class PhysicsObject
		attr_reader :bottom, :side, :render_object
		
		DIRECTION_UP = (3*Math::PI/2.0)
		
		#~ include Physics::Dimension
		#~ include Physics::Positioning
		#~ include Physics::ForceApplication
		#~ include Physics::Gravitation
	
		def initialize(position, bottom, side, render_object=nil)
			@bottom = bottom
			@side = side
			@render_object = render_object
				#Set render_object to be the same as the side if no render object is supplied.
				@render_object ||= side
				@render_object.collision_type = :render_object
			
				
			self.position = position
			init_orientation
			init_gravity
		end
		
		private
		
		def init_orientation
			# Set the initial angle of the bodies.  The bodies are initialized pointing
			# at 0 rad, aka right.  Thus, they need to be rotated before being used.
			[@bottom, @side, @render_object].each do |shape|
				shape.body.a = DIRECTION_UP
			end
		end
	end
	
	class MovableObject < PhysicsObject
		def initialize(pos, bottom, side)
			super(pos, bottom, side)
			
			link_side_and_bottom
		end
		
		private
		
		def link_side_and_bottom
			# For this to work, the side must be unable to rotate, 
			# and the bottom free to rotate.
			
			# Use a slide joint to implement this link.
				# Connect the stable end of the joint to the side, and
				# the moving "pin" to the bottom.
				
				# Allow the groove to extend infinitely downwards so that
				# the movement of the object modeled is inhibited as little
				# as possible.
		end
	end
	
	class Entity < MovableObject
		def initialize(mass, moment, pos=[0,0,0], dimentions=[1,1,1])
			#Use the supplied mass for the circle only, as the rectangle should not rotate.
			
			#Define the bottom of the Entity as a circle, and the side as a rectangle.
			#This approximates the volume as a cylinder.
			
			bottom = CP::Shape::Circle.new CP::Body.new(mass,moment), dimentions[0], CP::ZERO_VEC_2
			side = CP::Shape::Rect.new	CP::Body.new(mass,Float::INFINITY), :bottom_left,
										dimentions[1], dimentions[2]
			
			super(pos, bottom, side)
		end
	end
	
	class EnvironmentObject < PhysicsObject
		def initialize(pos=[0,0,0], dimentions=[1,1,1])
			bottom =	CP::Shape::Rect.new	CP::Body.new(Float::INFINITY,Float::INFINITY), 
											:bottom_left, dimentions[0], dimentions[1]
			side =		CP::Shape::Rect.new	CP::Body.new(Float::INFINITY,Float::INFINITY), 
											:bottom_left, dimentions[0], dimentions[3]
			
			render_object = CP::Shape::Rect.new	CP::Body.new(Float::INFINITY,Float::INFINITY), 
												:bottom_left, side.width, side.height + bottom.height
			
			super(pos, bottom, side, render_object)
		end
	end
	
	# Remember to move the render shape as well!
	# Define xy plane as horizontal plane, and xz plane as vertical plane.
	
	module Dimension
		# height, width, depth, etc
		def height
			@side.height
		end
		
		def width
			@side.width
		end
		
		def depth
			@bottom.height
		end
	end
	
	module Positioning
		# position, velocity, acceleration, etc
		def p
			return [@bottom.body.p.x, @bottom.body.p.y, @side.body.p.y]
		end
		
		def v
			return [@bottom.body.v.x, @bottom.body.v.y, @side.body.v.y]
		end
		
		def a
			return [@bottom.body.v.x, @bottom.body.v.y, @side.body.v.y]
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
		#For position
		def px;			@bottom.body.p.x; 						end
		def py;			@bottom.body.p.y;						end
		def pz;			@side.body.p.y;							end
		def px=(arg);	@bottom.body.p.x = arg; @side.body.p.x = arg;	end
		def py=(arg);	@bottom.body.p.y = arg;					end
		def pz=(arg);	@side.body.p.y = arg;					end
		#For velocity
		def vx;			@bottom.body.v.x;						end
		def vy;			@bottom.body.v.y;						end
		def vz;			@side.body.v.y;							end
		def vx=(arg);	@bottom.body.v.x = arg; @side.body.v.x = arg;	end
		def vy=(arg);	@bottom.body.v.y = arg;					end
		def vz=(arg);	@side.body.v.y = arg;					end
		#For acceleration
		def ax;			@bottom.body.a.x;						end
		def ay;			@bottom.body.a.y;						end
		def az;			@side.body.a.y;							end
		def ax=(arg);	@bottom.body.a.x = arg; @side.body.a.x = arg;	end
		def ay=(arg);	@bottom.body.a.y = arg;					end
		def az=(arg); 	@side.body.a.y = arg; 					end
		
		# For dealing with render objects		
		def distinct_render?
			# Returns true if the render object is distinct from the side
			return @side.equal? @render_object
		end
		
		def set_render_vector(type)
			if distinct_render?
				method = (type.to_s + "=").to_sym
				@render_object.send method, @side.send(type)
			end
		end
	end
	
	module ForceApplication
		# force, torque, etc.
		def apply_force(arg=[0.0, 0.0, 0.0])
			# Only apply x-coordinate force to one body, as the other should
			# move in accordance to the constraint holding the two together.
			@bottom.body.apply_force CP::Vec2.new arg[0], arg[1]
			@side.body.apply_force CP::Vec2.new 0, arg[1]
		end
	end
	
	module Gravitation
		def init_gravity
			 
		end
	
		def g;			@side.g;		end
		def g=(arg);	@side.g = arg;	end
	end
end
