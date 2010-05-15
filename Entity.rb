#!/usr/bin/ruby
#~ Name: Jason
#~ Date last edited: 05.14.2010

require 'rubygems'
require 'gosu'
require 'chipmunk'

require 'ChipmunkInterfaceMod'
require 'Combative'

#Parent class of all Creatures, Fighting NPCs, and PCs
class Entity
	include Combative
	
	attr_reader :body
	attr_reader :animations, :current_animation, :moving, :direction
	attr_accessor :name, :element, :faction, :visible
	attr_accessor :lvl, :hp, :max_hp, :mp, :max_mp
	attr_accessor :atk, :def, :dex, :agi, :mnd, :per, :luk
	
	@@all = Array.new

	def initialize(name, animations, pos, dir, lvl, hp, mp, element, stats, faction)
		@@all << self
		
		@move_constant = 1500
		@run_constant = 5000
		
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
		
		@jumping = false
		@jump_count = 0
	end
		
	class << self
		def all
			@@all
		end
		
		def apply_gravity_to_all
			@@all.each do |e|
				e.body.apply_gravity
			end
		end
	end
	
	def draw
		img =	if @moving
					#Animate at 10 fps
					@current_animation[Gosu::milliseconds / 100 % @current_animation.size]
				else
					@current_animation[0]
				end
		img.draw(@body.x, (@body.y - @body.z), @body.z, 1, 1)
	end
	
	def jump
		if @jump_count < 1
			@jump_count += 1
			@body.xz.body.v.y += 30
		elsif @body.z <= 0
			@jump_count = 0
		end
	end
	
	def move(constant=@move_constant)
		unless @direction == nil
			angle =	case @direction
						when :up
							((3*Math::PI)/2.0)
						when :down
							((Math::PI)/2.0)
						when :left
							(Math::PI)
						when :right
							(2*Math::PI)
						when :up_left
							((5*Math::PI)/4.0)
						when :up_right
							((7*Math::PI)/4.0)
						when :down_left
							((3*Math::PI)/4.0)
						when :down_right
							((Math::PI)/4.0)
					end
			
			unit_vector = angle.radians_to_vec2				
			#~ scalar = (@body.xy.body.v.dot(unit_vector))/(unit_vector.dot(unit_vector))
			#~ proj = (unit_vector * scalar)
			
			force = unit_vector * constant
			
			@body.apply_force :xy, force , CP::Vec2.new(0,0)
		else
			@body.reset_forces :all
		end
	end
	
	def run()
		move(@run_constant)
	end
	
	def direction=(arg)
		@direction = arg
		unless @direction == nil
			@current_animation = @animations[@direction]
		end
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
