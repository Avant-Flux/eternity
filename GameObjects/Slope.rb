# All slopes must be rectangular.  Thus, the incline must be aligned to
# north, south, east, or west.

# TODO: Fix "falling down little stairs" issue when going down slopes.
class Slope < StaticObject
	def initialize(window, width,depth,height_low,height_high, x,y,z, slope_direction)
		super(window, width,depth,height_high, x,y,z)
		@height_high = height_high
		@height_low = height_low
		
		# Slope direction is one of -  :north, :south, :east, :west
		# Direction specifies which end is the higher elevation.
		# Thus, a slope which is low on the south end and high on the north end
		# would have a direction of north.
		@slope_direction = slope_direction
		
		@shape.collision_type = :slope
		
		@slope =	if @slope_direction == :north || @slope_direction == :south
						# Y and Z
						
						dz = (height_high - height_low)
						
						dy = 	if @slope_direction == :north
									@depth
								elsif @slope_direction == :south
									-@depth
								end
						
						# return
						dz.to_f / dy.to_f
					elsif @slope_direction == :east || @slope_direction == :west
						# X and Z
						dz = (height_high - height_low)
						
						dx =	if @slope_direction == :east
									east_x - west_x
								elsif @slope_direction == :west
									west_x - east_x
								end
						
						
						# return
						dz.to_f / dx.to_f
					end
		
		axis = axis = case @slope_direction
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
		
		@surface_points = slope_verts # Used to draw quad for top of object
		@surface_z = @body.pz+@height_low
	end
	
	def draw_trimetric
		#~ @window.translate @body.p.x, @body.p.y do
			#~ 
		#~ end
	end
	
	def draw_billboarded
		@window.draw_quad	@surface_points[0].x, @surface_points[0].y, @color,
							@surface_points[1].x, @surface_points[1].y, @color,
							@surface_points[2].x, @surface_points[2].y, @color,
							@surface_points[3].x, @surface_points[3].y, @color,
							@surface_z
	end
	
	def height
		return @height_high
	end
	
	def height_at(x,y)
		# Return the height of the slope as a function of an Entity's position on the slope
		# TODO: Cap plane at the ends so that elevation is not calculated for outside objects
		z = if @slope_direction == :north || @slope_direction == :south
			# Y and Z
			@slope*y + @slope_constant
		elsif @slope_direction == :east || @slope_direction == :west
			# X and Z
			@slope*x + @slope_constant
		end
		
		return z.round(1)
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
	
	def slope_verts
		points = []
		@shape.each_vertex_absolute_with_index do |vert, i|
			vert = vert.to_screen
			
			vert_is_raised = case @slope_direction
				when :north
					if i == 1 || i == 2
						true
					end
				when :south
					if i == 0 || i == 3
						true
					end
				when :east
					if i == 2 || i == 3
						true
					end
				when :west
					if i == 0 || i == 1
						true
					end
			end
			
			vert.y -= if vert_is_raised
				 @height_high.to_px
			else
				@height_low.to_px
			end
			
			points << vert
		end
		
		return points
	end
end
