#!/usr/bin/ruby

require 'rubygems'
require 'chipmunk'

module Physics
	class Space < CP::Space
		def initialize
			super()
			
			self.iterations = 10
			self.damping = 0.2
		end
		
		def step
			# TODO: Add means of calculating timestep dynamically
			@t_previous = Gosu.milliseconds
			
			dt = Gosu.milliseconds - @t_previous
			
			# convert to seconds
			dt /= 1000.0
			
			@t_previous = Gosu.milliseconds
			
			
			super(dt) # Timestep in seconds
			
			# Iteration for third dimension
		end
	end
end
