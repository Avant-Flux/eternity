#!/usr/bin/ruby

require 'rubygems'
require 'chipmunk-ffi'

module Physics
	module Shape
		class Circle < CP::Shape::Circle
			attr_reader :game_obj
		
			def initialize(game_obj, *args)
				@game_obj = game_obj
				super(*args)
			end
		end
		
		class Rect < CP::Shape::Rect
			attr_reader :game_obj
		
			def initialize(game_obj, *args)
				@game_obj = game_obj
				super(*args)
			end
		end
	end
end
