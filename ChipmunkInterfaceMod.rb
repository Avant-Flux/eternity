#!/usr/bin/ruby
#~ Name: Jason
#~ Date last edited: 05.10.2010

require 'rubygems'
require 'chipmunk'
require 'gosu'
require 'RMagick'

#NOTES
#Implement a 3D body
#	This allows for calls to look like this
#		body = CP::Body_3D
#		body.x

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
			#Z is depth
			@xy = Space.new
			@xz = Space.new
			
			@xz.gravity = CP::Vec2.new(0, 100)		#Gravity should not function in the horiz plane
			
			self.damping = 0
		end
		
		def add(arg)
			#Not all dependencies implemented yet
			@xy.add(arg.xy)
			@xz.add(arg.xz)
		end
		
		def step
			@xy.step(@dt)
			@xz.step(@dt)
		end
		
		def damping=(arg)
			@xy.damping = arg
			@xz.damping = arg
		end
		
		def add_static_shape=(arg)
			@xy.add_static_shape = arg
			@xz.add_static_shape = arg
		end
	end
	
	class Body_3D
		def initialize
			#Bounding box sizes are place holders.  Change them later.
			@xy = CP::Shape::Poly.new(CP::Body.new(10, 150), 
										CP::Shape::Polygon.vertices(4, 10), #10 sq units square
										CP::Vec2.new(x, y))
			@xz = CP::Shape::Poly.new(CP::Body.new(10, 150), 
										CP::Shape::Polygon.vertices(4, 10),	#10 sq units square
										CP::Vec2.new(x, z))
		end
		
		def x
			@xy.body.p.x
		end
		
		def y
			@xy.body.p.y
		end
		
		def z
			@xz.body.p.y
		end
		
		def x= arg
			@xy.body.p.x = arg
			@xz.body.p.x = arg
		end
		
		def y= arg
			@xy.body.p.y = arg
		end
		
		def z= arg
			@xz.body.p.y = arg
		end
	end
	
	module Shape
		module Polygon; class << self
			#Code taken from MoreChipmunkAndRMagick.rb from the gosu demos
			#modified by Jason Ko to be more usable and ruby-like
			
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
