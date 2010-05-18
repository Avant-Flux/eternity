#!/usr/bin/ruby
#~ Name: Jason
#~ Date last edited: 05.17.2010

module CP
	class Body_3D
		attr_reader :xy, :xz
	
		def initialize(x, y, z, width, height, mass=100, moment=150)
			#Bounding box sizes are place holders.  Change them later.

			half_width = width/2
			#Bottom Shape
			@xy = CP::Shape::Circle.new(CP::Body.new(mass, moment), half_width, CP::Vec2.new(0.0, 0.0))
			@xy.body.p = CP::Vec2.new(x, y)
										
			#Side Shape
			shape_array =	[CP::Vec2.new(0, -1*half_width), CP::Vec2.new(0, half_width), 
							CP::Vec2.new(height, half_width), CP::Vec2.new(height, -1*half_width)]
			@xz = CP::Shape::Poly.new(CP::Body.new(mass, Float::INFINITY), #Eliminate rotation 
										shape_array, CP::Vec2.new(0, 0))#This vector is the offset
			@xz.body.p = CP::Vec2.new(x, z)
			
			@xy.body.a = (3*Math::PI/2.0)
			@xz.body.a = (3*Math::PI/2.0)
		end
		
		def transfer_x
			#Transfer the x component of force on xz to xy
			#Then, copy the x component of position from xy to xz
			apply_force :xy, CP::Vec2.new(f(:xz).x,0)
			f(:xz).x = 0
			@xz.body.p.x = @xy.body.p.x
		end
		
		def apply_gravity
			if self.z < 0
				self.z = 0
			else
				gravity = @xz.body.m * 9.8 * -1
				apply_force(:xz, CP::Vec2.new(0, gravity), CP::Vec2.new(0,0))
			end
		end
		
		def apply_force(plane, force_vector, relative_offset=CP::Vec2.new(0,0))
			if plane == :xy
				@xy.body.apply_force(force_vector, relative_offset)
			elsif plane == :xz
				@xz.body.apply_force(force_vector, relative_offset)
			end
		end
		
		def reset_forces(plane)
			if plane == :xy
				@xy.body.reset_forces
			elsif plane == :xz
				@xz.body.reset_forces
			elsif plane == :all
				@xy.body.reset_forces
				@xz.body.reset_forces
			end
		end
		
		#Setters and getters for force
		def f plane
			p = if plane == :xy
				@xy
			elsif plane == :xz
				@xz
			end
			
			p.body.f
		end
		
		#Setters and getters should be changed to use aliases
		#Setters and Getters for Position
		def x
			@xy.body.p.x
		end
		
		def y
			@xy.body.p.y
		end
		
		def z
			@xz.body.p.y
		end
		
		def x= arg
			@xy.body.p.x = arg
			@xz.body.p.x = arg
		end
		
		def y= arg
			@xy.body.p.y = arg
		end
		
		def z= arg
			@xz.body.p.y = arg
		end
		
		#Setters and getters for velocity
		def v
			#Compute the magnitude of the velocity in 3D space
			#Use the cross product function in chipmunk
			#CROSS_PRODUCT @xy.body.v, @xz.body.v
			@xy.body.v.cross(@xz.body.v)
		end
		
		def vx
			@xy.body.v.x
		end
		
		def vy
			@xy.body.v.y
		end
		
		def vz
			@xz.body.v.y
		end
		
		def vx= arg
			@xy.body.v.x = arg
		end
		
		def vy= arg
			@xy.body.v.y = arg
		end
		
		def vz= arg
			@xz.body.v.y = arg
		end
	end
end
