#!/usr/bin/ruby

require 'rubygems'
require 'gosu'
require 'texplay'

require './Drawing/Wireframe'

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
		# Render building shadow
	end
	
	def export(path, name)
		scale = 0.10
		side_buffer = 4
		top_bottom_buffer = 4
	
		#~ export_top		path, name, scale, side_buffer, top_bottom_buffer
		#~ export_side		path, name, scale, side_buffer, top_bottom_buffer
		export_front	path, name, scale, side_buffer, top_bottom_buffer
	end
	
	private
	
	def export_top(path, name, scale, side_buffer, top_bottom_buffer)
		width = (self.width(:px, scale) + self.depth(:px, scale)*Math.sin(20/180.0*Math::PI)).to_i
		height = (self.depth(:px, scale)*Math.cos(20/180.0*Math::PI)).to_i
		
		img = TexPlay.create_blank_image @window, width+side_buffer, height+top_bottom_buffer
		
		color = :red	
		img.move_to side_buffer/2, img.height-top_bottom_buffer/2
		img.forward width(:px, scale), true, :color => color
		img.turn(-70)
		img.forward depth(:px, scale), true, :color => color
		img.turn(-110)
		img.forward width(:px, scale), true, :color => color
		img.turn(-70)
		img.forward depth(:px, scale), true, :color => color
		
		img.fill width/2, depth/2, :color => :white
		
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
