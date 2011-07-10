#!/usr/bin/ruby

require 'rubygems'
require 'gosu'

require './Combat/Combative'

require './Drawing/Animation'
require './Drawing/Shadow'

require './Stats/Stats'

#Parent class of all Creatures, Fighting NPCs, and PCs
class Entity
	include Physics::ThreeD_Support
	
	include Combative
	
	attr_reader :stats
	attr_reader  :moving, :direction, :move_constant, :movement_force
	attr_accessor :name, :element, :faction, :visible
	attr_accessor :lvl, :hp, :mp
	
	def initialize(window, animations, name, pos, mass, moment, lvl, element, stats, faction)
		@movement_force = CP::ZERO_VEC_2
		@walk_constant = 500
		@run_constant = 1200
		
		@animation = animations
		
		init_physics	:circle, pos, :radius => (@animation.width/2.0).to_meters, :mass => mass,
						:moment => moment, :collision_type => :entity
		
		@shadow = Shadow.new window, self
		
		
		#~ $space.add self
		#~ $space.set_elevation @shape
		
		@name = name
		@element = element
		@faction = 0		#express faction spectrum as an integer, Dark = -100, Light = 100
		@visible = true		#Controls whether or not to render the Entity

		@lvl = lvl
		@hp = {:current => 10, :max => 10}	#Arbitrary number for now
		@mp = {:current => 10, :max => 10}
		@stats = Hash.new
		@stats[:raw] = stats # strength, constitution, dexterity, mobility, power, skill, flux
		@stats[:composite]	=	{:attack => @stats[:raw][:strength], 
								:defence => @stats[:raw][:constitution]}
		@jump_count = 0
	end
	
	def update
		@animation.update(moving?, compute_direction)
		@shadow.update
		
		#~ if @physics.px.to_px - @animation.width <= 0
			#~ @physics.px = @animation.width.to_meters
		#~ end
		#~ 
		#~ if @physics.py.to_px - @animation.height <= 0
			#~ @physics.py = @animation.height.to_meters
		#~ end
	end
	
	
	def draw
		# TODO may have to pass the z index from the game state manager
		if visible
			@animation.draw px, py, pz
			@shadow.draw
		end
	end

	def resolve_ground_collision
		@jump_count = 0
	end
	
	def resolve_fall_damage(vz)
		
	end
	
	def jump
		if @jump_count < 3 && vz <=0 #Do not exceed the jump count, and velocity in negative.
			@jump_count += 1
			self.vz = 5 #On jump, set the velocity in the z direction
		end
	end
	
	def move(dir)
		unit_vector =	case dir
							when :up
								#~ ((3*Math::PI)/2.0)
								Physics::Direction::N
							when :down
								#~ ((Math::PI)/2.0)
								Physics::Direction::S
							when :left
								#~ (Math::PI)
								Physics::Direction::W
							when :right
								#~ 0
								Physics::Direction::E
							when :up_left
								#~ ((5*Math::PI)/4.0)
								Physics::Direction::NW
							when :up_right
								#~ ((7*Math::PI)/4.0)
								Physics::Direction::NE
							when :down_left
								#~ ((3*Math::PI)/4.0)
								Physics::Direction::SW
							when :down_right
								#~ ((Math::PI)/4.0)
								Physics::Direction::SE
						end
				
		@movement_force = unit_vector * @move_constant
		
		apply_force @movement_force
		self.a = unit_vector.to_angle
	end
	
	def walk
		@move_constant = @walk_constant
	end
	
	def run
		@move_constant = @run_constant
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
		"#{@name}: #{px}, #{py}, #{pz}, elevation: #{elevation}"
	end
	
	private
	EIGHTH = Math::PI/8
	SECTOR1 = (1*EIGHTH)
	SECTOR2 = (3*EIGHTH)
	SECTOR3 = (5*EIGHTH)
	SECTOR4 = (7*EIGHTH)
	SECTOR5 = (9*EIGHTH)
	SECTOR6 = (11*EIGHTH)
	SECTOR7 = (13*EIGHTH)
	
	def compute_direction
		angle = self.a
		
		#~ if angle < SECTOR1
			#~ :right
		#~ elsif angle < SECTOR2
			#~ :down_right
		#~ elsif angle < SECTOR3
			#~ :down
		#~ elsif angle < SECTOR4
			#~ :down_left
		#~ elsif angle < SECTOR5
			#~ :left
		#~ elsif angle < SECTOR6
			#~ :up_left
		#~ elsif angle < SECTOR7
			#~ :up
		#~ else #angle > (8*Math::PI/8) or between 0 and pi/8
			#~ :up_right
		#~ end
		
		if angle.between? Physics::Direction::NE_ANGLE, Physics::Direction::SE_ANGLE
			return :right
		elsif angle.between? Physics::Direction::SE_ANGLE, Physics::Direction::SW_ANGLE
			return :down
		elsif angle.between? Physics::Direction::SW_ANGLE, Physics::Direction::NW_ANGLE
			return :left
		elsif angle.between? Physics::Direction::NW_ANGLE, Physics::Direction::NE_ANGLE
			return :up
		else
			:left
		end
	end
end
