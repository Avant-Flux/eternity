require 'matrix'

require './Physics/Conversions'

module Physics
	MAX_Z = 10000000
	
	NORTH = CP::Vec2.new(0,1)
	SOUTH = CP::Vec2.new(0,-1)
	WEST = CP::Vec2.new(-1,0)
	EAST = CP::Vec2.new(1,0)
	
	MOVEMENT_THRESHOLD = 0.01
	
	class << self
		
	end
end	
