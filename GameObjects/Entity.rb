#!/usr/bin/ruby
#~ Name: Jason
#~ Date last edited: 09.13.2010

require 'rubygems'
require 'gosu'
require 'chipmunk'

require 'Chipmunk/ChipmunkInterfaceMod'
require 'Chipmunk/EternityMod'
require 'Combat/Combative'
require 'Drawing/Animations'

require 'Stats/Stats'

class Fixnum
	def between?(a, b)
		return true if self >= a && self < b
	end
end

#Parent class of all Creatures, Fighting NPCs, and PCs
class Entity
	include Combative
	
	attr_reader :shape, :stats
	attr_reader :animations, :moving, :direction
	attr_accessor :name, :elevation, :element, :faction, :visible
	attr_accessor :lvl, :hp, :max_hp, :mp, :max_mp
	
	@@all = Array.new

	def initialize(window, space, animations, name, pos, mass, moment, lvl, element, stats, faction)
		@@all << self
		
		@move_constant = 150
		@run_constant = 500
		
		@animations = animations
		
		@shape = CP::Shape_3D::Circle.new(self, space, :entity, pos, 0,
											(@animations.width/2).to_meters, 
											@animations.height.to_meters,
											mass, moment)
		space.add self
		
		@name = name
		@element = element
		@faction = 0		#express faction spectrum as an integer, Dark = -100, Light = 100
		@visible = true		#Controls whether or not to render the Entity

		@lvl = lvl
		@hp = {:current => 10, :max => 10}	#Arbitrary number for now
		@mp = {:current => 10, :max => 10}
		@stats = Hash.new
		@stats[:raw] = stats
		@stats[:composite] = {:atk => @stats[:raw][:str], :def => @stats[:raw][:con]}
		
		@jump_count = 0
	end
		
	class << self
		def all
			@@all
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
		
		def reset_all
			@@all.each do |e|
				e.shape.body.reset_forces
			end
		end
	end
	
	def update
		@animations.direction = compute_direction
		@animations.moving = moving?
		@animations.update
		
		if @shape.x.to_px - @animations.width <= 0
			@shape.x = @animations.width.to_meters
		end
		
		if @shape.y.to_px - @animations.height <= 0
			@shape.y = @animations.height.to_meters
		end
	end
	
	
	def draw
		if visible
			@animations.draw @shape.x.to_px, @shape.y.to_px, @shape.z.to_px
			#~ puts "#{@shape.x}, #{@shape.y}, #{@shape.z}"
		end
	end
	
	def jump
		if @jump_count < 3 && @shape.vz <=0 #Do not exceed the jump count, and velocity in negative.
			@jump_count += 1
			@shape.vz = 5 #On jump, set the velocity in the z direction
		elsif @shape.z <= @shape.elevation
			@jump_count = 0
		end
	end
	
	def move(dir)
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
		#~ scalar = (@shape.xy.body.v.dot(unit_vector))/(unit_vector.dot(unit_vector))
		#~ proj = (unit_vector * scalar)
		
		force = unit_vector * @move_constant
		
		@shape.body.apply_force force, CP::Vec2.new(0,0)
		@shape.body.a = angle
	end
	
	def run(dir)
		move(dir, @run_constant)
	end
	
	def moving?
		@shape.body.v.length >= 0
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
	
	def position
		"#{@name}: #{@shape.x}, #{@shape.y}, #{@shape.z}"
	end
	
	private	
	def compute_direction
		#~ puts @shape.a
		angle = @shape.body.a
		if angle.between?((15*Math::PI/8), (1*Math::PI/8))
			:right
		elsif angle.between?((1*Math::PI/8), (3*Math::PI/8))
			:down_right
		elsif angle.between?((3*Math::PI/8), (5*Math::PI/8))
			:down
		elsif angle.between?((5*Math::PI/8), (7*Math::PI/8))
			:down_left
		elsif angle.between?((7*Math::PI/8), (9*Math::PI/8))
			:left
		elsif angle.between?((9*Math::PI/8), (11*Math::PI/8))
			:up_left
		elsif angle.between?((11*Math::PI/8), (13*Math::PI/8))
			:up
		elsif angle.between?((13*Math::PI/8), (15*Math::PI/8))
			:up_right
		else
			:right #Workaround to catch the case where facing right is not being detected
		end
	end
end
