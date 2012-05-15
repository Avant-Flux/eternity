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
		
		def step(dt)
			# TODO: Add means of calculating timestep dynamically
			super(dt)
			
			# Iteration for third dimension
		end
	end
end
