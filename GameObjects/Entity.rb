#!/usr/bin/ruby

require 'rubygems'
require 'gosu'

#~ require './Combat/Combative'
#~ 
#~ require './Drawing/Animation'
#~ require './Drawing/Shadow'
#~ 
#~ require './Stats/Stats'

#Parent class of all Creatures, Fighting NPCs, and PCs
class Entity
	include Physics::ThreeD_Support
	include Physics::ThreeD_Support::Cylinder
	
	include Combative
	
	attr_reader :name, :stats, :lvl, :element
	attr_reader  :moving, :direction, :move_constant, :movement_force
	attr_accessor :faction, :visible, :intense
	
	def initialize(window, animations, name, pos, mass, moment, lvl, element, faction)
		@movement_force = CP::Vec2::ZERO
		@walk_constant = 500
		@run_constant = 1200
		
		@intense = false
		
		@animation = animations
		
		init_physics	pos, (@animation.width/2.0).to_meters, mass, moment, :entity
		
		@shadow = Shadow.new window, self
		
		@name = name
		@element = element
		@faction = 0		#express faction spectrum as an integer, Dark = -100, Light = 100
		@visible = true		#Controls whether or not to render the Entity

		@lvl = lvl
		
		@jump_count = 0
		
		init_stats
	end
	
	def update
		@animation.update(moving?, compute_direction)
		@shadow.update
	end
	
	
	def draw(zoom)
		# TODO may have to pass the z index from the game state manager
		if visible
			@shadow.draw zoom
			@animation.draw px, py, pz, zoom
		end
	end
	
	def self.stats *arr
		# Method taken from _why's Dwemthy's Array
		# and subsequently modified
		return @default_stats if arr.empty?
		
		#~ attr_accessor *arr
		
		arr.each do |method|
			meta_eval do
				define_method method do |val|
					@default_stats ||= {}
					@default_stats[method] = val
				end
			end
		end
	end
	
	def init_stats
		@stats = Hash.new
		@stats[:raw] = {} # strength, constitution, dexterity, mobility, power, skill, flux
		
		self.class.stats.each do |stat, val|
			#~ instance_variable_set("@#{stat}", val)
			@stats[:raw][stat] = val
		end
		
		@stats[:composite]	=	{:attack => @stats[:raw][:strength], 
								:defence => @stats[:raw][:constitution]}
		
		@hp = {}
		@mp = {}
		
		@hp[:max] = @stats[:raw][:constitution]*5
		@hp[:current] = @hp[:max]
		
		@mp[:max] = 10 # Arbitrary
		@mp[:current] = @mp[:max]
	end

	stats :strength, :constitution, :dexterity, :power, :control, :flux
	
	# Create setters and getters for hp and mp
	[:hp, :mp].each do |stat|
		eval %Q{
			def #{stat}
				@#{stat}[:current]
			end
			
			def #{stat}= val
				@#{stat}[:current] = val
			end
			
			def max_#{stat}
				@#{stat}[:max]
			end
		}
	end
	

	def resolve_ground_collision
		@jump_count = 0
	end
	
	def resolve_fall_damage(vz)
		
	end
	
	def jump
		#~ if @jump_count < 3 #Do not exceed the jump count.
			@jump_count += 1
			self.vz = 5 #On jump, set the velocity in the z direction
		#~ end
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
