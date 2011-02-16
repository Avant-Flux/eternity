#!/usr/bin/ruby

require 'rubygems'
require 'chipmunk-ffi'

module Physics
	module Shape
		class Circle < CP::Shape::Circle
			attr_reader :physics_obj
		
			def initialize(physics_obj, *args)
				@physics_obj = physics_obj
				super(*args)
			end
		end
		
		class Rect < CP::Shape::Rect
			attr_reader :physics_obj
		
			def initialize(physics_obj, *args)
				@physics_obj = physics_obj
				super(*args)
			end
		end
	end
	
	class Body < CP::Body
		attr_reader :physics_obj
	
		def initialize(physics_obj, *args)
			@physics_obj = physics_obj
			super(*args)
		end
	end
end
