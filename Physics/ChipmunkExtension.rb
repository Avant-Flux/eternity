#!/usr/bin/ruby

require 'rubygems'
require 'chipmunk-ffi'

module Physics
	module Shape
		class Circle < CP::Shape::Circle
			attr_reader :entity
		
			def initialize(entity, *args)
				@entity = entity
				super(*args)
			end
		end
		
		class Rect < CP::Shape::Rect
			attr_reader :entity
		
			def initialize(entity, *args)
				@entity = entity
				super(*args)
			end
		end
		
		class Poly < CP::Shape::Poly
			attr_reader :entity
			
			def initialize(entity, *args)
				@entity = entity
				super(*args)
			end
		end
	end
	
	class Body < CP::Body
		attr_reader :entity
	
		def initialize(entity, *args)
			@entity = entity
			super(*args)
		end
	end
end
