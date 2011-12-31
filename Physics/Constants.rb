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
		
		#~ a = 85
		#~ X_HAT = CP::Vec2.new(Math.cos((90-a).to_rad),Math.sin((90-a).to_rad))
		#~ Y_HAT = CP::Vec2.new(Math.cos(a.to_rad), -Math.sin(a.to_rad))
		
		X_HAT = CP::Vec2.new 1, 0
		Y_HAT = CP::Vec2.new(Math.cos(70.to_rad), -Math.sin(70.to_rad))
		Z_HAT = CP::Vec2.new 0, -1
		# Scaling factor to covert the z stored (in meters)
		# to the units needed for the current projection
		#~ Z_SCALE = 1
		
		# Vector used to transform the coordinates used in the Eternity space
		# back to the standard values in the xy cartesian plane
		Y_HAT_BACK = CP::Vec2.new(Math.cos(70.to_rad)/Math.sin(70.to_rad),
								-1/Math.sin(70.to_rad))
		
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
