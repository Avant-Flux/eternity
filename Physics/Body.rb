require 'set'

module Physics
	class Body < CP::Body
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
				new_elevation = if env.is_a? Slope
					env.height_at(self.p.x, self.p.y)
				else
					env.height
				end
				
				new_elevation += env.body.pz
				
				if new_elevation > max_elevation
					max_elevation = new_elevation
				end
			end
			
			return max_elevation
		end
		
		def z_index
			z = 0
			
			@elevation_queue.each do |env|
				new_z = env.height + env.body.pz
				
				if new_z > z
					z = new_z
				end
			end
			
			return z + self.elevation
		end
		
		def in_air?
			return @pz > self.elevation
		end
	end
	
	class StaticBody < CP::Body
		attr_reader :gameobject
		attr_accessor :pz
		
		#~ def initialize(gameobject)
		def initialize()
			super(CP::INFINITY, CP::INFINITY)
			# Beoran's C bindings of Chipmunk also set this property:
			# body->node.idleTime = (cpFloat)INFINITY;
			
			@pz = 0
		end
	end
	
end
