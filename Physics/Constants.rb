require 'matrix'

require './Physics/Conversions'

module Physics
	MAX_Z = 10000000

	# Set the scale for conversion between meters and pixels
	@@scale = 390/165.0*100 # Pixels per meter
	class << self
		def scale
			@@scale
		end
		
		def scale=(arg)
			@@scale = arg
		end
	end
	
	module Direction
		x_scale = 1.2
		y_scale = 0.8
		
		X_HAT = CP::Vec2.new(Math.cos((8.79).to_rad), Math.sin((8.79).to_rad)) * x_scale * Physics.scale
		Y_HAT = CP::Vec2.new(Math.cos((65.1).to_rad), -Math.sin((65.1).to_rad)) * y_scale * Physics.scale
		Z_HAT = CP::Vec2.new 0, -1
		
		N = Y_HAT
		S = -Y_HAT
		E = X_HAT
		W = -X_HAT
		NE = (N + E).normalize
		NW = (N + W).normalize
		SE = (S + E).normalize
		SW = (S + W).normalize
		
		N_ANGLE = N.to_angle
		S_ANGLE = S.to_angle
		E_ANGLE = E.to_angle
		W_ANGLE = W.to_angle
		NE_ANGLE = NE.to_angle
		NW_ANGLE = NW.to_angle
		SE_ANGLE = SE.to_angle
		SW_ANGLE = SW.to_angle
	end
	
	module Transform
		matrix = Matrix[[Physics::Direction::X_HAT.x, Physics::Direction::Y_HAT.x, 0],
				[Physics::Direction::X_HAT.y, Physics::Direction::Y_HAT.y, 1]]
		
		SCREEN_TO_WORLD = matrix.transpose*(matrix*matrix.transpose).inverse
		printf #{SCREEN_TO_WORLD}
	end
end	
