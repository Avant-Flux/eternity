require './Physics/Conversions'

module Physics
	MAX_Z = 10000000

	# Set the scale for conversion between meters and pixels
	@@scale = 640/165.0*100 # Pixels per meter
	class << self
		def scale
			@@scale
		end
		
		def scale=(arg)
			@@scale = arg
		end
	end
	
	module Direction
		X_HAT = CP::Vec2.new 1, 0
		Y_HAT = CP::Vec2.new(1, -1*Math.tan(70.to_rad)).normalize
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
end	
