#!/usr/bin/ruby

require 'rubygems'
require 'chipmunk-ffi'
require './Chipmunk/Shape3D'

module CP
	class Space_3D
		@@scale = 44
		
		class << self
			def scale
				@@scale
			end
			
			def scale= arg
				@@scale = arg
			end
		end
	end
end

class Numeric
	def to_px
		#~ Convert from meters to pixels
		self*CP::Space_3D.scale
	end
	
	def to_meters
		#~ Convert from pixels to meters
		self/(CP::Space_3D.scale.to_f) #Insure that integer division is not used
	end
end
