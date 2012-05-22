class StaticObject
	attr_reader :height
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
		
		@x_count = @width/@tile_width
		@y_count = @depth/@tile_height
		
		
		# Dimensions can not exceed 1022 x 1022, as per limitations of texplay
		@side = TexPlay.create_blank_image(@window, 512,512)
		
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
		
		@window.translate @body.p.x, @body.p.y do
			#~ @side.old_draw x,y, @body.pz
		end
	end
	
	def add_to(space)
		space.add_static_shape @shape
	end
	
	private
	
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
				#~ position = CP::Vec2.new(x_offset, y_offset).to_screen
				#~ position1 = Physics::Direction::X_HAT * x_offset
				#~ position1 += Physics::Direction::Y_HAT * y_offset
				#~ 
				#~ position2 = Physics::Direction::X_HAT * (x_offset + tile_width)
				#~ position2 += Physics::Direction::Y_HAT * (y_offset + )
				#~ 
				#~ self.draw_quad	position1.x, position1.y, color,
			end
		end
		
		#~ color = Gosu::Color.new 255-z/20, 255-z/20, 255-z/20
		#~ self.draw_tile	0, 0, z, x_count*tile_width, y_count*tile_height, color
	end
	
	def draw_tile(x,y,z, height,width, color)
		# Use z position in meters for z-index
		@window.draw_quad	x, y, color,
							x+width, y, color,
							x+width, y+height, color,
							x, y+height, color, z
	end
end
