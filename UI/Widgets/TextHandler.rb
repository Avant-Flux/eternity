#!/usr/bin/ruby

class Point
	attr_accessor :x, :y
	
	def initialize(x=nil, y=nil)
		@x = x
		@y = y
	end
	
	def set(x, y)
		@x = x
		@y = y
	end
end

# Managed text-based output classes.
class TextHandler
	def initialize
		
	end
end

class SpeechBubble
	
end
