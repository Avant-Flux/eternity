#!/usr/bin/ruby

require 'rubygems'
require 'gosu'
require 'texplay'
require 'RMagick'

class Building
	include Physics::ThreeD_Support
	include Physics::ThreeD_Support::Box
	
	attr_reader :shape

	def initialize(window, position, dimensions, options={})
		#~ Set default values for hash values if they are not already set.
		@window = window
		
		options[:mass] ||= :static
		options[:moment] ||= :static
		options[:collision_type] = :building
		
		#~ init_physics	:box, options[:position], options
		#~ init_physics	position, dimensions, options
		init_physics	position, dimensions, :static, :static, :building
		
		@wireframe = Wireframe::Box.new window, self
		
		
		scale = 0.15
		side_buffer = 4
		top_bottom_buffer = 4
		@textures = {
			:right => generate_side_texture("red", scale, side_buffer, top_bottom_buffer),
			:left => generate_side_texture("green", scale, side_buffer, top_bottom_buffer),
			:front => generate_front_texture("yellow", scale, side_buffer, top_bottom_buffer),
			:back => generate_front_texture("blue", scale, side_buffer, top_bottom_buffer),
			:top => generate_top_texture("white", scale, side_buffer, top_bottom_buffer)
		}
		
		# Create building shadow
		# Should have as close to the same cross-sectional area as the building as possible
		# Eventually, use the bitmap for the opengl stencil buffer used on the interior texture
		# When using the collision object, perhaps blur the edges to hide the fact that
		# the shadow is not exact.  Given the art style, even non-blurred edges
		# will most likely suffice for a while.
	end
	
	def update
		#~ @wireframe.update
	end
	
	def draw(zoom)
		@wireframe.draw zoom
		
		# Render textures
		#~ v = vertex(Physics::Shape::PerspRect::TOP_RIGHT_VERT)
		left_x = px
		left_y = py-(self.height(:meters) + self.depth(:meters)*Math.sin(70.to_rad))
		left_z = pz
		@textures[:right].draw left_x+self.width(:meters), left_y, left_z, zoom,
					:offset_x => 2, :offset_y => 2
		@textures[:left].draw left_x, left_y, left_z, zoom,
					:offset_x => 2, :offset_y => 2
					
		@textures[:front].draw px, py, pz, zoom,
					:offset_x => 2, :offset_y => @textures[:front].height-2
		@textures[:back].draw px+self.depth(:meters)*Math.cos(70.to_rad), left_y, pz, zoom,
					:offset_x => 2, :offset_y => 2
		
		@textures[:top].draw px, py, pz, zoom,
					:offset_x => 2, :offset_y => @textures[:top].height+self.height(:px)-2
		
		# Render building shadow
	end
	
	def export(path, name)
		scale = 1
		side_buffer = 4
		top_bottom_buffer = 4
	
		#~ export_top		path, name, scale, side_buffer, top_bottom_buffer
		#~ export_side		path, name, scale, side_buffer, top_bottom_buffer
		export_front	path, name, scale, side_buffer, top_bottom_buffer
	end
	
	private
	
	
	def generate_top_texture(color, scale, side_buffer, top_bottom_buffer)
		width = (self.width(:px)+ (self.depth(:px)*Math.cos(70.to_rad))).to_i
		height = (self.depth(:px)*Math.sin(70.to_rad)).to_i
		
		img = Magick::Image.new	width+side_buffer, height+top_bottom_buffer do
									self.background_color = "transparent"
								end
		
		outline = Magick::Draw.new
		
		#~ outline.stroke			"red"
		outline.fill =			color
		outline.fill_opacity	1
		#~ outline.stroke_width	3
		# Change from CS coordinates to cartesian
		outline.affine			1, 0, 0, -1, 0, img.rows
		# List points in clockwise order, starting from bottom left
		outline.polygon		side_buffer/2, top_bottom_buffer/2,
							side_buffer/2+self.depth(:px)*Math.cos(70.to_rad), 
								img.rows-top_bottom_buffer/2,
							img.columns-side_buffer/2, img.rows-top_bottom_buffer/2,
							img.columns-side_buffer/2-self.depth(:px)*Math.cos(70.to_rad), top_bottom_buffer/2
		
		outline.draw(img)
		
		return Gosu::Image.new(@window, img, false)
	end
	
	def generate_side_texture(color, scale, side_buffer, top_bottom_buffer)
		width = (self.depth(:px)*Math.cos(70.to_rad)).to_i
		height = (self.height(:px) + self.depth(:px)*Math.sin(70.to_rad)).to_i
		
		img = Magick::Image.new	width+side_buffer, height+top_bottom_buffer do
									self.background_color = "transparent"
								end
		
		outline = Magick::Draw.new
		
		#~ outline.stroke			"red"
		outline.fill =			color
		outline.fill_opacity	1
		#~ outline.stroke_width	0
		# Change from CS coordinates to cartesian
		outline.affine			1, 0, 0, -1, 0, img.rows
		# List points in clockwise order, starting from bottom left
		outline.polygon		side_buffer/2, top_bottom_buffer/2,
							side_buffer/2, self.height(:px)+top_bottom_buffer/2,	
							img.columns-side_buffer/2, img.rows-top_bottom_buffer/2,
							img.columns-side_buffer/2, img.rows-self.height(:px)-top_bottom_buffer/2
		
		outline.draw(img)
		
		return Gosu::Image.new(@window, img, false)
	end
	
	
	def generate_front_texture(color, scale, side_buffer, top_bottom_buffer)
		width = self.width(:px)
		height = self.height(:px)
		
		img = Magick::Image.new	width+side_buffer, height+top_bottom_buffer do
									self.background_color = "transparent"
								end
		
		outline = Magick::Draw.new
		
		#~ outline.stroke			"red"
		outline.fill =			color
		outline.fill_opacity	1
		#~ outline.stroke_width	0
		# Change from CS coordinates to cartesian
		outline.affine			1, 0, 0, -1, 0, img.rows
		# List points in clockwise order, starting from bottom left
		outline.polygon		side_buffer/2, top_bottom_buffer/2,
							side_buffer/2, img.rows-top_bottom_buffer/2,	
							img.columns-side_buffer/2, img.rows-top_bottom_buffer/2,
							img.columns-side_buffer/2, top_bottom_buffer/2
		
		outline.draw(img)
		
		return Gosu::Image.new(@window, img, false)
	end
	
	
	def export_top(path, name, scale, side_buffer, top_bottom_buffer)
		width = (self.width(:px, scale) + self.depth(:px, scale)*Math.sin(20/180.0*Math::PI)).to_i
		height = (self.depth(:px, scale)*Math.cos(20/180.0*Math::PI)).to_i
		
		rmagick_img = Magic::Image.new width+side_buffer, height+top_bottom_buffer
		img = Gosu::Image.new @window, rmagick_img, true # Set to true so edges don't blur
		
		draw = Magic::Draw.new
		
		
		#~ img = TexPlay.create_blank_image @window, width+side_buffer, height+top_bottom_buffer
		
		#~ color = :red	
		#~ img.move_to side_buffer/2, img.height-top_bottom_buffer/2
		#~ img.forward width(:px, scale), true, :color => color
		#~ img.turn(-70)
		#~ img.forward depth(:px, scale), true, :color => color
		#~ img.turn(-110)
		#~ img.forward width(:px, scale), true, :color => color
		#~ img.turn(-70)
		#~ img.forward depth(:px, scale), true, :color => color
		#~ 
		#~ img.fill width/2, depth/2, :color => :white
		
		filename = File.join path, "#{name}_top.png"
		
		img.save filename
	end
	
	def export_side(path, name, scale, side_buffer, top_bottom_buffer)
		width = (self.depth(:px, scale)*Math.sin(20/180.0*Math::PI)).to_i
		height = (self.height(:px, scale) + self.depth(:px, scale)*Math.cos(20/180.0*Math::PI)).to_i
		
		img = TexPlay.create_blank_image @window, width+side_buffer, height+top_bottom_buffer
		
		color = :red	
		img.move_to side_buffer/2, img.height-top_bottom_buffer/2
		img.turn(-70)
		img.forward depth(:px, scale), true, :color => color
		img.turn(-20)
		img.forward height(:px, scale), true, :color => color
		img.turn(-160)
		img.forward depth(:px, scale), true, :color => color
		img.turn(-20)
		img.forward height(:px, scale), true, :color => color
		
		img.fill width/2, height/2, :color => :white
		
		filename = File.join path, "#{name}_side.png"
		
		img.save filename
	end
	
	def export_front(path, name, scale, side_buffer, top_bottom_buffer)
		width = (self.width(:px, scale)).to_i
		height = (self.height(:px, scale)).to_i
		
		img = TexPlay.create_blank_image @window, width+side_buffer, height+top_bottom_buffer
		
		color = :red
		#~ img.move_to side_buffer/2, img.height-top_bottom_buffer/2
		#~ img.forward width(:px, scale), true, :color => color
		#~ img.turn(-90)
		#~ img.forward height(:px, scale), true, :color => color
		#~ img.turn(-90)
		#~ img.forward width(:px, scale), true, :color => color
		#~ img.turn(-90)
		#~ img.forward height(:px, scale), true, :color => color
		
		points = []
		points << [side_buffer/2, img.height-top_bottom_buffer/2]
		points << [side_buffer/2+self.width(:px, scale), img.height-top_bottom_buffer/2]
		points << [side_buffer/2+self.width(:px, scale), img.height-top_bottom_buffer/2-self.height(:px, scale)]
		points << [side_buffer/2, img.height-top_bottom_buffer/2-self.height(:px, scale)]
		
		points.size.times do |i|
			if i < points.size - 1
				img.line	points[i][0], points[i][1],
							points[i+1][0], points[i+1][1],
							:color => color
			else
				img.line	points[i][0], points[i][1],
							points[0][0], points[0][1],
							:color => color
			end
		end
		
		img.fill width/2, height/2, :color => :white
		
		filename = File.join path, "#{name}_front.png"
		
		img.save filename
	end
end
