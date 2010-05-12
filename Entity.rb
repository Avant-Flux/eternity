#!/usr/bin/ruby
#~ Name: Jason
#~ Date last edited: 05.10.2010

require 'rubygems'
require 'gosu'
require 'chipmunk'

require 'ChipmunkInterfaceMod'
require 'Combative'

#Parent class of all Creatures, Fighting NPCs, and PCs
class Entity
	include Combative

	attr_accessor :body
	attr_reader :animations, :current_animation, :moving, :direction
	attr_accessor :name, :element, :faction, :visible
	attr_accessor :lvl, :hp, :max_hp, :mp, :max_mp
	attr_accessor :atk, :def, :dex, :agi, :mnd, :per, :luk
	
	@@all = Array.new

	def initialize(name, animations, pos, dir, lvl, hp, mp, element, stats, faction)
		@@all << self
		
		@animations = animations
		@current_animation = @animations[dir]
		@direction = dir
		
		@body = CP::Body_3D.new(pos[0], pos[1], pos[2])
		
		@name = name
		@element = element
		@faction = 0		#express faction spectrum as an integer, Dark = -100, Light = 100
		#~ @direction = 0	#Angle in degrees using Gosu's coordinate system of pos-y = 0, cw = pos
		@visible = true		#Controls whether or not to render the Entity
		@moving = false

		@lvl = lvl
		@max_hp = @hp = hp
		@max_mp = @mp = mp

		@atk = stats[0]
		@def = stats[1]
		@dex = stats[2]
		@agi = stats[3]
		@mnd = stats[4]
		@per = stats[5]
		@luk = stats[6]
	end
	
	def self.all
		@@all
	end
	
	def self.apply_gravity_to_all
		Entity.all.each do |e|
			e.body.apply_gravity
		end
	end
	
	def draw
		img =	if @moving
					#Animate at 10 fps
					@current_animation[Gosu::milliseconds / 100 % @current_animation.size]
				else
					@current_animation[0]
				end
		img.draw(@body.x, @body.y - @body.z, @body.z, 1, 1)
	end
	
	def jump
		@body.apply_force(:xz, CP::Vec2.new(0,8000), CP::Vec2.new(0,0))
	end
	
	def direction=(arg)
		@direction = arg
		@current_animation = @animations[@direction]
	end

	def warp(x, y, z=@z)
		@x = x
		@y = y
		@z = z
	end

	def move(x,y,z=0)
		move_x x
		move_y y
		move_z z
	end

	def move_x(inc)
		@x += inc
	end

	def move_y(inc)
		@y += inc
	end

	def move_z(inc)
		@z += inc
	end

	def visible?
		@visible
	end

	def set_random_element
		@element = case rand 5
			when 0
				:fire
			when 1
				:water
			when 2
				:earth
			when 3
				:wind
			when 4
				:lightning
		end
	end
	
	def create
		
	end
	
	def load
		
	end
	
	def save
		
	end
end
