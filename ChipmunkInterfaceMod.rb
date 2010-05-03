#!/usr/bin/ruby
#~ Name: Jason
#~ Date last edited: 04.22.2010

require 'rubygems'
require 'chipmunk'

module CP
	class Space
		def add(arg)
			add_body arg.shape.body
			add_shape arg.shape
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
			
			@xz.gravity = P::Vec2.new(0, 100);		#Gravity should not function in the horiz plane
			
			self.damping = 0;
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
	
	module Bound
		class Rect_Prism
		#Get the vertices in an array and convert them into a bounding shape
			def initialize(vert)
				
			end
		end
	end
end
