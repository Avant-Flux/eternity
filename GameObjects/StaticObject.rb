class StaticObject
	attr_reader :width, :depth, :height
	attr_reader :body, :shape
	attr_accessor :pz, :vz, :az, :g
	
	def initialize(window, dimensions, position)
		@window = window
		
		@width, @depth, @height = dimensions
		
		@shape = Physics::Shape::Poly.new self, CP::Body.new_static(),
					[CP::Vec2.new(0, 0),
					CP::Vec2.new(0, @depth),
					CP::Vec2.new(@width, @depth),
					CP::Vec2.new(@width, 0)], 
					CP::ZERO_VEC_2
		@body = @shape.body
		
		
		@body.p = CP::Vec2.new(position[0], position[1])
		@pz = position[2]
		
		
		@shape.collision_type = :static
		
		
		
		@tile_width = 5
		@tile_height = 5
		
		# NOTE:	This will cause issues with surfaces that can not be evenly
		# 		filled by tiles
		@x_count = (@width/@tile_width).to_i
		@y_count = (@depth/@tile_height).to_i
		
		
		@side = create_wireframe
	end
	
	def update
		
	end
	
	def draw_trimetric
		# Draw the trimetric portion of static objects
		# This accounts for the top surfaces of flat objects.
		
		#~ @window.clip_to 0,0, @width, @height do
		@window.translate @body.p.x, @body.p.y do
			draw_world @x_count,@y_count, @tile_width,@tile_height, @pz+@height
		end
		#~ end
	end
	
	def draw_billboarded
		# Draw the billboarded portion of static objects
		# Accounts for sides and slanted tops
		
		position = @body.p.to_screen
		x = position.x
		y = position.y - @body.pz.to_px
		
		
		
		#~ puts offset if x == 0 and y == 0
		
		#~ @window.translate 0, do
			@side.draw x,y-@side.height+@billboard_offset, @body.p.y
		#~ end
	end
	
	def add_to(space)
		space.add_static_shape @shape
	end
	
	def remove_from(space)
		space.remove_static_shape @shape
	end
	
	private
	
	def create_wireframe
		# Dimensions can not exceed 1022 x 1022, as per limitations of texplay
		# TODO: Patch texplay so it can handle images larger than one OpenGl texture
		# All angle measures are hard codede, based on the trimetric projection
		# found on wikipedia's axiometric projection page.
		# 65.1 => angle of Y_HAT with the horizontal
		# 8.79 => angle of X_HAT with the horizontal
		
		# TODO: Reduce memory consumption of algorithm
		#		Current implementation 
		# TODO:	Create separate wireframe class
		# TODO:	Wireframes should only be generated as a placeholder
		# 		Should attempt to load textures first.  If texture loading fails, generate
		# 		wireframe and save to the location of the missing texture.
		
		# Currently, image_x and image_y are in meters
		image_x = @width*Math.cos(8.79.to_rad) + @depth*Math.cos(65.1.to_rad)
		image_y = @height + @depth*Math.sin(65.1.to_rad) + @width*Math.sin(8.79.to_rad)
		side = TexPlay.create_blank_image(@window, 1000,1000)
		#~ @side = TexPlay.create_blank_image(@window, image_x.to_px,image_y.to_px)
		
		side.fill 0,0, :color => :white
		
		texplay_color = :red
		texplay_thickness = 7
		
		# Create points for bottom layer
		bottom_points = Array.new(4)
		bottom_points[0] = [0, @width*Math.sin(8.79.to_rad)]
		bottom_points[1] = [@width*Math.cos(8.79.to_rad), 0]
		bottom_points[2] = [image_x, @depth*Math.sin(65.1.to_rad)]
		bottom_points[3] = [@depth*Math.cos(65.1.to_rad), bottom_points[0][1] + bottom_points[2][1]]
		
		# Convert points to px
		bottom_points.each do |pt|
			pt.collect! do |i|
				i.to_px
			end
		end
		
		# Flip y axis
		bottom_points.each do |pt|
			#~ puts pt.class
			pt[1] = side.height - pt[1]
		end
		
		# Draw bottom layer
		polyline_points = [*bottom_points[0], *bottom_points[1], *bottom_points[2], *bottom_points[3]]
		#~ puts polyline_points
		side.polyline	polyline_points, :color => texplay_color, :closed => true, 
						:thickness => texplay_thickness
		
		# Offset points for top layer
		top_points = bottom_points.clone
		top_points.each do |pt|
			pt[1] -= @height.to_px
		end
		
		# Draw top layer
		polyline_points = [*top_points[0], *top_points[1], *top_points[2], *top_points[3]]
		side.polyline	polyline_points, :color => texplay_color, :closed => true, 
						:thickness => texplay_thickness
		
		# Draw lines connecting top and bottom
		4.times do |i|
			side.line	bottom_points[i][0], bottom_points[i][1], top_points[i][0], top_points[i][1],
						:color => texplay_color, :thickness => texplay_thickness
		end
		
		# Create offset for drawing @side
		@billboard_offset = @width*Math.sin(8.79.to_rad)
		@billboard_offset = @billboard_offset.to_px
		
		return side
	end
	
	def draw_world(x_count,y_count, tile_width,tile_height, z=0)
		x_count.times do |x|
			y_count.times do |y|
				x_factor = x.to_f/x_count
				y_factor = y.to_f/y_count
				color = Gosu::Color.new 150, x_factor*255, y_factor*255, (x_factor+y_factor)*150+105
				#~ color = Gosu::Color::WHITE
				
				x_offset = x*tile_width
				y_offset = y*tile_width
				
				draw_tile	x_offset,y_offset,z,	tile_height,tile_width, color
			end
		end
		
		#~ color = Gosu::Color.new 255-z/20, 255-z/20, 255-z/20
		#~ draw_tile	0, 0, z, x_count*tile_width, y_count*tile_height, color
	end
	
	def draw_tile(x,y,z, height,width, color)
		# Use z position in meters for z-index
		@window.draw_quad	x, y, color,
							x+width, y, color,
							x+width, y+height, color,
							x, y+height, color, z
	end
end
