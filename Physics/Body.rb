require 'set'

module Physics
	class Body < CP::Body
		ROTATION_THRESHOLD = 0.04 # radians per second (properly, radians per unit time)
		
		# TODO: Remove pointer to gameobject if it proves unnecessary
		# 		Currently only used for #resolve_ground_collision
		attr_reader :gameobject
		attr_reader :elevation_queue
		attr_accessor :pz, :vz, :az, :g
		#~ attr_accessor :elevation
		
		def initialize(gameobject, *args)
			super(*args)
			
			@gameobject = gameobject
			
			# Create values for 3rd dimension of physics
			
			# Set contains all objects which could possibly contribute to the elevation
			# Populated by the "collision" of objects within the space
			@elevation_queue = Set.new
			
			
			@pz = 0
			@vz = 0 
			@az = 0
			
			# Friction for this object.
			# Will be added to Space friction to get coefficient of friction
			@u = 0.4
			@u_axis = 0.2 # friction about axis can, and should, be different than surface friction
		end
		
		def reset
			# Restore the body to it's original state.
			@elevation_queue.clear
			
			@pz = 0
			@vz = 0
			@az = 0
			
			self.p.x = self.p.y = 0.0
			self.v.x = self.v.y = 0.0
			self.f.x = self.f.y = 0.0
			self.a = 0.0 # angle
			self.w = 0.0 # Angular velocity
			self.t = 0.0 # Torque (double)
		end
		
		def elevation
			# Highest height lower than the entity
			# NOTE: Current implementation does not allow for tunnels
			max_elevation = 0
			
			@elevation_queue.each do |env|
				# new_elevation = if env.is_a? Slope
				# 	env.height_at(self.p.x, self.p.y)
				# else
				# 	env.height
				# end
				new_elevation = env.physics.height
				
				new_elevation += env.physics.body.pz
				
				if new_elevation > max_elevation
					max_elevation = new_elevation
				end
			end
			
			return max_elevation
		end
		
		def in_air?
			return @pz > self.elevation
		end
		
		# ===== Resistive "forces"
		# Force used very loosely, applying to both linear and rotational motion
		def air_resistance
			self.v.normalize
			return CP::ZERO_VEC_2
		end
		
		def friction(g, space_u)
			movement_direction = self.v.normalize
			
			u = space_u + @u # Total friction coefficient accounts for both space and this object
			
			# Normal force
			# Currently assuming that all terrain is flat
			# TODO:	Update normal force to take account of terrain
			# 		Normal = mg*cos(theta)
			normal = self.m * g
			
			movement_direction*u*normal # g is negative, so the direction will be reversed
			# TODO: Figure out what the magic "2" is for (i think it's just a scaling factor to account for the unrealistic character proportion)
		end
		
		def resistive_torque(g)
			# counter torque - similar to resistive forces
			# force essentially needs to go cw to generate cw torque
			# cw torque will counter ccw angular motion
			
			# Apply angular acceleration in the reverse direction of motion
			# acceleration should be relative to the moment of inertia
			
			# NOTE: In real physics, forces induce torque
			# the only way to get rotation without translation, is to counter the force without countering the torque on the object
			# 	apply one force for torque
			# 	apply a second force at the axis
			# 		this will modify the net force, without affecting torque
			# 
			# In a program, this is rather inefficient
			# 	Why add a value just to subtract it back out?
			# 	Instead, just apply a torque
			rotation = nil
			
			
			if self.w > ROTATION_THRESHOLD # Only apply resistive forces if object is in motion
				#~ puts "spinning"
				puts "CCW"
				
				rotation = 1
			elsif self.w < -ROTATION_THRESHOLD
				puts "CW"
				
				rotation = -1
			else
				# If velocity is below a certain threshold, set it to zero.
				# Used to combat inaccuracies with floats.
				
				self.w = 0.0
			end
			
			
			unless rotation
				# --- EXCEPTION FLOW
				# This body is not rotating
				# Thus, there is no resistance
				return 0
			end
			
			# The body is rotating
			# Apply necessary resistance
			
			# should be applying "negative" torque
			# opposite the current rotation
			
			# varying radius of force can be a neat way to simulate conservation of angular momentum
			
			# TODO: Eliminate need to multiply by -1
			
			u = 0.2 # friction about axis can, and should, be different than surface friction
			force = CP::Vec2.new(rotation * -1*self.m*g * @u_axis, 0)
			radius = CP::Vec2.new(0,1) # TODO: Optimize - 
			
			return radius.cross force
		end
	end
	
	class StaticBody < CP::StaticBody
		attr_reader :gameobject
		attr_accessor :pz
		
		def initialize(gameobject, *args)
			super(*args)
			# Beoran's C bindings of Chipmunk also set this property:
			# body->node.idleTime = (cpFloat)INFINITY;
			
			@gameobject = gameobject
			@pz = 0
		end
	end
	
end
