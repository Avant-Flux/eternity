#!/usr/bin/ruby

require 'rubygems'
require 'RMagick'

module TextureMap
	class Building
		# Attempt to load textures, and generate new ones
		# as necessary
		def initialize(window, gameobj)
			@window = window
			@gameobj = gameobj
			
			scale = 0.15
			side_buffer = 4
			top_bottom_buffer = 4
			
			@right = init_side("red", scale, side_buffer, top_bottom_buffer)
			#~ @left = init_side("green", scale, side_buffer, top_bottom_buffer)
			#~ @front = init_front("yellow", scale, side_buffer, top_bottom_buffer)
			#~ @back = init_front("blue", scale, side_buffer, top_bottom_buffer)
			#~ @top = init_top("white", scale, side_buffer, top_bottom_buffer)
			
			update
		end
		
		# Update the corrdinates do not call every frame,
		# only when object is edited
		def update
			left_x = @gameobj.px
			left_y = @gameobj.py-(@gameobj.height(:meters) + @gameobj.depth(:meters)*Math.sin(70.to_rad))
			
			@right_coord =	[left_x+@gameobj.width(:meters), left_y-@gameobj.pz, @gameobj.pz-1]
			#~ @left_coord =	[left_x, left_y-@gameobj.pz, @gameobj.pz-1]
			#~ @front_coord =	[@gameobj.px, @gameobj.py-@gameobj.pz, @gameobj.pz]
			#~ 
			#~ v = @gameobj.vertex_absolute(Physics::Shape::PerspRect::TOP_LEFT_VERT)
			#~ @back_coord =	[v.x, v.y-@gameobj.pz, @gameobj.pz-2]
			#~ @top_coord =	[@gameobj.px, @gameobj.py-@gameobj.pz, @gameobj.pz]
			
			
			@right_offset =	[2, 2]
			#~ @left_offset =	[2, 2]
			#~ @front_offset =	[2, @front.height-2]
			#~ @back_offset =	[2, @back.height-2]
			#~ @top_offset =	[2, @top.height+@gameobj.height(:px)-2]
		end
		
		def draw(zoom)
			# Render textures
			@right.draw @right_coord[0], @right_coord[1], @right_coord[2], zoom,
						:offset_x => @right_offset[0], :offset_y => @right_offset[1]
						#~ :opacity => 0.80
			#~ @left.draw @left_coord[0], @left_coord[1], @left_coord[2], zoom,
						#~ :offset_x => @left_offset[0], :offset_y => @left_offset[1]
						#~ :opacity => 0.80
						#~ 
			#~ @front.draw @front_coord[0], @front_coord[1], @front_coord[2], zoom,
						#~ :offset_x => @front_offset[0], :offset_y => @front_offset[1]
						#~ :opacity => 0.30
			#~ 
			#~ 
			#~ @back.draw @back_coord[0], @back_coord[1], @back_coord[2], zoom,
						#~ :offset_x => @back_offset[0], :offset_y => @back_offset[1]
						#~ :opacity => 0.80
			#~ 
			#~ @top.draw @top_coord[0], @top_coord[1], @top_coord[2], zoom,
						#~ :offset_x => @top_offset[0], :offset_y => @top_offset[1],
						#~ :opacity => 0xcc
		end
		
		private
		
		def init_top(color, scale, side_buffer, top_bottom_buffer)
			width = (@gameobj.width(:px)+ (@gameobj.depth(:px)*Math.cos(70.to_rad))).to_i
			height = (@gameobj.depth(:px)*Math.sin(70.to_rad)).to_i
			
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
								side_buffer/2+@gameobj.depth(:px)*Math.cos(70.to_rad), 
									img.rows-top_bottom_buffer/2,
								img.columns-side_buffer/2, img.rows-top_bottom_buffer/2,
								img.columns-side_buffer/2-@gameobj.depth(:px)*Math.cos(70.to_rad), top_bottom_buffer/2
			
			outline.draw(img)
			
			return Gosu::Image.new(@window, img, false)
		end
		
		def init_side(color, scale, side_buffer, top_bottom_buffer)
			width = (@gameobj.depth(:px)*Math.cos(70.to_rad)).to_i
			height = (@gameobj.height(:px) + @gameobj.depth(:px)*Math.sin(70.to_rad)).to_i
			
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
								side_buffer/2, @gameobj.height(:px)+top_bottom_buffer/2,	
								img.columns-side_buffer/2, img.rows-top_bottom_buffer/2,
								img.columns-side_buffer/2, img.rows-@gameobj.height(:px)-top_bottom_buffer/2
			
			outline.draw(img)
			
			return Gosu::Image.new(@window, img, false)
		end
		
		
		def init_front(color, scale, side_buffer, top_bottom_buffer)
			width = @gameobj.width(:px)
			height = @gameobj.height(:px)
			
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
	end
end
