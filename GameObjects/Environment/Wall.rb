class Wall
	# Create a thin, un-crossable wall 
	include Physics::ThreeD_Support
	include Physics::ThreeD_Support::Box
	
	def initialize(window, position, orientation, length, height)
		# Width is automatically generated to be "thin"
		@window = window
		
		width = 1
		dimensions = case orientation
			when :horizontal
				[length, width, 0]
			when :vertical
				[width, length, 0]
		end
		
		init_physics	position, dimensions, :static, :static, :building
	end
	
	def update
		
	end
	
	def draw
		
	end
end
