#!/usr/bin/ruby
#~ Name: Jason
#~ Date last edited: 05.17.2010

require 'rubygems'
require 'gosu'
require 'chipmunk'

require 'ChipmunkInterfaceMod'
require 'Combative'

class Fixnum
	def between?(a, b)
		return true if self >= a && self < b
	end
end

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
		@current_frame = @animations[dir][0]
		@direction = dir
		
		@body = CP::Body_3D.new(pos[0], pos[1], pos[2], 
								@current_frame.width, @current_frame.height)
		
		@name = name
		@element = element
		@faction = 0		#express faction spectrum as an integer, Dark = -100, Light = 100
		#~ @direction = 0	#Angle in degrees using Gosu's coordinate system of pos-y = 0, cw = pos
		@visible = true		#Controls whether or not to render the Entity

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
		
		def add_all_to_space space
			@@all.each do |e|
				space.add(e)
			end
		end
		
		def draw_all
			@@all.each do |e|
				e.draw
			end
		end
		
		def update_all
			@@all.each do |e|
				e.update
			end
		end
	end
	
	def draw
		@current_frame.draw(@body.x, (@body.y - @body.z), @body.z, 1, 1)
	end
	
	def update
		@current_animation = @animations[compute_direction]
		
		@current_frame =if moving? #If it is moving
							#Animate at 10 fps
							@current_animation[Gosu::milliseconds / 100 % @current_animation.size]
						else
							@current_animation[0]
						end
	end
	
	def jump
		if @jump_count < 1
			@jump_count += 1
			@body.xz.body.v.y += 30
		elsif @body.z <= 0
			@jump_count = 0
		end
	end
	
	def move(dir, constant=@move_constant)
		angle =	case dir
					when :up
						((3*Math::PI)/2.0)
					when :down
						((Math::PI)/2.0)
					when :left
						(Math::PI)
					when :right
						0
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
		@body.a = angle
	end
	
	def run(dir)
		move(dir, @run_constant)
	end
	
	def moving?
		@body
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
	
	private
	def compute_direction
		#~ puts @body.a
		if @body.a.between?((15*Math::PI/8), (1*Math::PI/8))
			:right
		elsif @body.a.between?((1*Math::PI/8), (3*Math::PI/8))
			:down_right
		elsif @body.a.between?((3*Math::PI/8), (5*Math::PI/8))
			:down
		elsif @body.a.between?((5*Math::PI/8), (7*Math::PI/8))
			:down_left
		elsif @body.a.between?((7*Math::PI/8), (9*Math::PI/8))
			:left
		elsif @body.a.between?((9*Math::PI/8), (11*Math::PI/8))
			:up_left
		elsif @body.a.between?((11*Math::PI/8), (13*Math::PI/8))
			:up
		elsif @body.a.between?((13*Math::PI/8), (15*Math::PI/8))
			:up_right
		else
			:right #Workaround to catch the case where facing right is not being detected
		end
	end
end
