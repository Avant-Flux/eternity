#!/usr/bin/ruby
#~ Name: Jason
#~ Date last edited: 08.02.2010

#~ Notes:
#~ Remove the xz CP::Space and store the z-based gravity application function in this class
#~ Rewrite Space_3D as a descendant of CP::Space

require 'rubygems'
require 'chipmunk'
require 'gosu'
require 'RMagick'
require 'Chipmunk/Shape_3D'

module CP
	class Space
		def add(shape, static=:nonstatic)
			add_body shape.body
			
			if static == :nonstatic
				add_shape shape
			elsif static == :static
				add_static_shape shape
			end
		end
		
		def remove
			
		end
	end
	
	class Space_3D < Space
		attr_reader :dt, :g, :shapes
		
		def initialize(damping=0.5, g=9.8, dt=(1.0/60.0))
			super()
			@shapes = {:static => Array.new, :nonstatic => Array.new}
			@g = g		#Controls acceleration due to gravity in the z direction
			@dt = dt	#Controls the timestep of the space.  
						#	Could be falsified as slower than update rate for bullet time
			
			#X is horizontal
			#Y is vertical
			#Z is height
			
			#This CP::Space functions as the xy plane, while the gravity is controlled as if 
			#	it was in the z direction.
			#Gravity should not function in the horiz plane, thus gravity is always <0, 0>
			self.gravity = CP::Vec2.new(0, 0)
			
			#0.2 Seems like a good damping for ice
			self.damping = damping
		end
		
		def step
			super @dt
			
			#Add code for one-dimensional movement in the z-direction here
			@shapes[:nonstatic].each do |shape|
				if shape.z > shape.elevation
					shape.apply_gravity @dt
				else
					shape.z = shape.elevation
					shape.reset_gravity
				end
				
				if shape.entity.jumping?
					shape.entity.jump
				end
				shape.entity.jumping = false
				shape.iterate @dt
			end
			#~ Entity.all.each do |entity|
				#~ if entity.jumping?
					#~ entity.jump
				#~ end
								#~ 
				#~ entity.jumping = false				
			#~ end
			
		end
				
		def add(arg, static=:nonstatic)
			super arg.shape, static
			@shapes[static] << arg.shape 
		end
		
		def remove
			
		end
	end
	
	module Shape
		module Polygon; class << self
			#Code taken from MoreChipmunkAndRMagick.rb from the gosu demos
			#modified to be more usable and ruby-like <- work in progress
			
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
