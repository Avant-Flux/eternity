module Physics
	class Body < CP::Body
		# TODO: Remove pointer to gameobject if it proves unnecessary
		
		attr_reader :gameobject
		attr_accessor :pz, :vz, :az, :g
		#~ attr_accessor :elevation
		
		def initialize(gameobject, *args)
			super(*args)
			
			@gameobject = gameobject
			
			# Create values for 3rd dimension of physics
			
			# TODO: Attempt to remove elevation if it is only needed for shadows
			# Elevation is set by the space
			#~ @elevation = nil
			@elevation_heap = Containers::MaxHeap.new
			@elevation_heap << 0
			
			@pz = 0
			@vz = 0 
			@az = 0
		end
		
		def elevation
			@elevation_heap.max
		end
		
		def add_elevation(elevation)
			@elevation_heap << elevation unless @elevation_heap.max == elevation
		end
		
		def delete_elevation(elevation)
			@elevation_heap.delete elevation
			
			if @elevation_heap.empty?
				# This accounts for the player entering areas with no defined ground
				puts "OUT OF BOUNDS"
				@elevation_heap << 0
			end
		end
	end
end
