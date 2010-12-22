#!/usr/bin/ruby
require 'rubygems'
require 'gosu'
require 'texplay'

class Subsprite < Gosu::Image
	attr_reader :type, :id

	def initialize(basepath, type, name)
		path = File.join(basepath, type.to_s.capitalize, "#{name}.png")
		super $window, path, false
	end

	def clone()
		super()
	end
end
