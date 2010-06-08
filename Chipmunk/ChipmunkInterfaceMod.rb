#!/usr/bin/ruby
#~ Name: Jason
#~ Date last edited: 06.08.2010

require 'rubygems'
require 'chipmunk'
require 'gosu'
require 'RMagick'
require 'Chipmunk/CPBody_3D'

module CP
	class Space
		def add(shape)
			add_body shape.body
			add_shape shape
		end
	end
	
	class Space_3D
		attr_reader :xy, :xz, :dt
	
		def initialize(dt=(1.0/60.0))
			@dt = dt
			
			#X is horizontal
			#Y is vertical
			#Z is height
			@xy = Space.new
			@xz = Space.new
			
			#Gravity should not function in the horiz plane			
			@xz.gravity = CP::Vec2.new(0, 0)
			@xy.gravity = CP::Vec2.new(0, 0)
			
			#0.2 Seems like a good damping for ice
			@xy.damping = 0.5
			@xz.damping = 1
		end
		
		def gravity
			@xy.gravity
		end
		
		def gravity= arg
			@xy.gravity = arg
		end
		
		def add(arg)
			#Not all dependencies implemented yet
			@xy.add(arg.body.xy)
			@xz.add(arg.body.xz)
		end
		
		def step
			@xy.step(@dt)
			@xz.step(@dt)
		end
		
		def damping= arg
			@xy.damping = arg
			@xz.damping = arg
		end
		
		def add_static_shape= arg
			@xy.add_static_shape = arg
			@xz.add_static_shape = arg
		end
	end
	
	module Shape
		module Polygon; class << self
			#Code taken from MoreChipmunkAndRMagick.rb from the gosu demos
			#modified to be more usable and ruby-like
			
			# Produces the vertices of a regular polygon.
			def vertices(sides, size)
			   vertices = []
			   sides.times do |i|
				   angle = -2 * Math::PI * i / sides
				   vertices << angle.radians_to_vec2() * size
			   end
			   return vertices
			end
			
			# Produces the image of a polygon.
			def image(vertices)
			   box_image = Magick::Image.new(EDGE_SIZE  * 2, EDGE_SIZE * 2) { self.background_color = 'transparent' }
			   gc = Magick::Draw.new
			   gc.stroke('red')
			   gc.fill('plum')
			   draw_vertices = vertices.map { |v| [v.x + EDGE_SIZE, v.y + EDGE_SIZE] }.flatten
			   gc.polygon(*draw_vertices)
			   gc.draw(box_image)
			   return Gosu::Image.new(self, box_image, false)
			end
		end; end
	end
	
	module Vector
		class Vec2 < CP::Vec2
			
		end
	end
	
	class Vec2
		def z
			self.y
		end
		
		def z=(arg)
			self.y=arg
		end
	end
	
	module Bound
		class Rect_Prism
		#Get the vertices in an array and convert them into a bounding shape
			def initialize(vert)
				
			end
		end
	end
end

class Numeric 
	#Code taken from MoreChipmunkAndRMagick.rb from the gosu demos
   def radians_to_vec2
       CP::Vec2.new(Math::cos(self), Math::sin(self))
   end
end
