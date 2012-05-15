#!/usr/bin/ruby

require 'rubygems'
require 'chipmunk'

module Physics
	class Space < CP::Space
		def initialize
			super()
			
			self.iterations = 10
			self.damping = 0.2
			
			@t_previous = Gosu.milliseconds
		end
		
		def step
			super(dt) # Timestep in seconds
			
			# Iteration for third dimension
		end
		
		private
		
		def dt
			# TODO: Add means of calculating timestep dynamically
			# Assumption:	dt will only be called once.
			# 				If this method is called more than once,
			# 				there is no guarantee the results will
			# 				be consistent between calls.
			dt = Gosu.milliseconds - @t_previous
			
			# convert to seconds
			dt /= 1000.0
			
			@t_previous = Gosu.milliseconds
			
			return dt
		end
	end
end
