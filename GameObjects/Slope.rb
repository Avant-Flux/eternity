# All slopes must be rectangular.  Thus, the incline must be aligned to
# north, south, east, or west.

class Slope < StaticObject
	def initialize(window, width,depth,height_low,height_high, x,y,z, slope_direction)
		super(window, width,depth,height_high, x,y,z)
		
		# Slope direction is one of -  :north, :south, :east, :west
		# Direction specifies which end is the higher elevation.
		# Thus, a slope which is low on the south end and high on the north end
		# would have a direction of north.
		@slope_direction = slope_direction
		
		@shape.collision_type = :slope
		
		@slope =	if @slope_direction == :north || @slope_direction == :south
						# Y and Z
						
						dz = (height_low - height_low)
						
						dy = 	if @slope_direction == :north
									north_y - south_y
								elsif @slope_direction == :south
									south_y - north_y
								end
						
						# return
						dz.to_f / dy.to_f
					elsif @slope_direction == :east || @slope_direction == :west
						# X and Z
						dz = (height_low - height_low)
						
						dx =	if @slope_direction == :east
									east_x - west_x
								elsif @slope_direction == :west
									west_x - east_x
								end
						
						
						# return
						dz.to_f / dx.to_f
					end
		
		axis = case @slope_direction
			when :north
				north_y
			when :south
				south_y
			when :east
				east_x
			when :west
				west_x
		end
		@slope_constant = (z + height_high) - @slope*axis
	end
	
	def height(x,y)
		# Return the height of the slope as a function of an Entity's position on the slope
		# TODO: Cap plane at the ends so that elevation is not calculated for outside objects
		if @slope_direction == :north || @slope_direction == :south
			# Y and Z
			return @slope*y + @slope_constant
		elsif @slope_direction == :east || @slope_direction == :west
			# X and Z
			return @slope*x + @slope_constant
		end
	end
	
	private
	
	def north_y
		@body.p.y + @depth
	end
	
	def south_y
		@body.p.y
	end
	
	def east_x
		@body.p.x
	end
	
	def west_x
		@body.p.x + @width
	end
end
