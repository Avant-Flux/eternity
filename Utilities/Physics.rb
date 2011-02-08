#!/usr/bin/ruby
 
module Physics
	#This is the new structure for the chipmunk handling of the game engine
	#It should create a complete abstraction of the underlying chipmunk code.
	#It may eventually be possible to forgo usage of chipmunk-ffi at some point
	#and simply use ffi and the C library.
	class PhysicsObject
		attr_reader :bottom, :side, :render_object
		
		DIRECTION_UP = (3*Math::PI/2.0)
		
		include Dimension
		include Positioning
		include ForceApplication
	
		def initialize(position, bottom, side, render_object=nil)
			@bottom = bottom
			@side = side
			@render_object = render_object
				#Set render_object to be the same as the side if no render object is supplied.
				@render_object ||= side
				
			self.position = position
			init_orientation
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
										dimentions[0], dimentions[2]
			
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
			return [@bottom.p.x, @bottom.p.y, @side.p.y]
		end
		
		def v
			return [@bottom.v.x, @bottom.v.y, @side.v.y]
		end
		
		def a
			return [@bottom.v.x, @bottom.v.y, @side.v.y]
		end
		
		def p=(arg=[0.0, 0.0, 0.0])
			@bottom.p.x = arg[0]
			@bottom.p.y = arg[1]
			@side.p.y = arg[2]
		end
		
		def v=(arg=[0.0, 0.0, 0.0])
			@bottom.v.x = arg[0]
			@bottom.v.y = arg[1]
			@side.v.y = arg[2]
		end
		
		def a=(arg=[0.0, 0.0, 0.0])
			@bottom.p.x = arg[0]
			@bottom.p.y = arg[1]
			@side.p.y = arg[2]
		end
		
		# Define alternate names for the previous methods
		alias :position :p
		alias :velocity :v
		alias :acceleration :a
		alias :position= :p=
		alias :velocity= :v=
		alias :acceleration= :a=
		
		# Setters and getters for vectors based on plane.
		def pxy;		@bottom.p;			end
		def pxz;		@side.p;			end
		def vxy;		@bottom.v;			end
		def vxz;		@side.v;			end
		def axy;		@bottom.a;			end
		def axz;		@side.a;			end
		def pxy=(arg);	@bottom.p = arg;	end
		def pxz=(arg);	@side.p = arg;		end
		def vxy=(arg);	@bottom.v = arg;	end
		def vxz=(arg);	@side.v = arg;		end
		def axy=(arg);	@bottom.a = arg;	end
		def axz=(arg);	@side.a = arg;		end
		
		# Setters and getters for individual values.
		#For position
		def px;			@bottom.p.x;		end
		def py;			@bottom.p.y;		end
		def pz;			@side.p.y;			end
		def px=(arg);	@bottom.p.x = arg;	end
		def py=(arg);	@bottom.p.y = arg;	end
		def pz=(arg);	@side.p.y = arg;	end
		#For velocity
		def vx;			@bottom.v.x;		end
		def vy;			@bottom.v.y;		end
		def vz;			@side.v.y;			end
		def vx=(arg);	@bottom.v.x = arg;	end
		def vy=(arg);	@bottom.v.y = arg;	end
		def vz=(arg);	@side.v.y = arg;	end
		#For acceleration
		def ax;			@bottom.a.x;		end
		def ay;			@bottom.a.y;		end
		def az;			@side.a.y;			end
		def ax=(arg);	@bottom.a.x = arg;	end
		def ay=(arg);	@bottom.a.y = arg;	end
		def az=(arg); 	@side.a.y = arg; 	end
	end
	
	module ForceApplication
		# force, torque, etc.
		def apply_force(arg=[0.0, 0.0, 0.0])
			
		end
	end
end
