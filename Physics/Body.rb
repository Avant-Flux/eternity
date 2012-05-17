module Physics
	class Body < CP::Body
		attr_reader :gameobject
		attr_accessor :pz, :vz, :az, :g
		attr_accessor :elevation
		
		def initialize(gameobject, *args)
			super(*args)
			
			@gameobject = gameobject
			
			# Create values for 3rd dimension of physics
			@elevation = 0	# Attempt to remove elevation if it is only needed for shadows
			@pz = 0
			@vz = 0 
			@az = 0
			@g = -9.8
		end
	end
end
