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
	
	include Physics::ForceApplication
	include Physics::Rotation
	include Physics::SpeedLimit
	include Physics::Elevation
	
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
		
		init_physics	:circle, pos, :radius => @animation.width/2.0, :mass => mass,
						:moment => moment
		
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
		if visible
			@animation.draw @physics.px, @physics.py, @physics.pz
			@shadow.draw
		end
	end

	def resolve_ground_collision
		@jump_count = 0
	end
	
	def resolve_fall_damage(vz)
		
	end
	
	def jump
		if @jump_count < 3 && @physics.vz <=0 #Do not exceed the jump count, and velocity in negative.
			@jump_count += 1
			@physics.vz = 5 #On jump, set the velocity in the z direction
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
		
		@movement_force = unit_vector * @move_constant
		
		@physics.apply_force @movement_force
		@physics.a = angle
	end
	
	def walk
		@move_constant = @walk_constant
	end
	
	def run
		@move_constant = @run_constant
	end
	
	def moving?
		@physics.shape.body.v.length >= 0
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
	
	def elevation
		@physics.elevation
	end
	
	def elevation=(arg)
		@physics.elevation = arg
	end
	
	def position
		"#{@name}: #{@physics.px}, #{@physics.py}, #{@physics.pz}, elevation: #{@physics.elevation}"
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
		angle = @physics.a
		
		if angle < SECTOR1
			:right
		elsif angle < SECTOR2
			:down_right
		elsif angle < SECTOR3
			:down
		elsif angle < SECTOR4
			:down_left
		elsif angle < SECTOR5
			:left
		elsif angle < SECTOR6
			:up_left
		elsif angle < SECTOR7
			:up
		else #angle > (8*Math::PI/8) or between 0 and pi/8
			:up_right
		end
	end
end
