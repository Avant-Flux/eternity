#!/usr/bin/ruby

require 'rubygems'
require 'gosu'

#Parent class of all Creatures, Fighting NPCs, and PCs
class Entity
	include Physics::ThreeD_Support
	include Physics::ThreeD_Support::Cylinder
	
	include Combative
	
	attr_reader :name, :stats, :lvl, :element
	attr_reader  :moving, :move_constant, :movement_force
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
	
	
	def draw(camera)
		# TODO may have to pass the z index from the game state manager
		if visible
			@animation.draw px, py, pz, px_ - py_, camera.zoom
			@shadow.draw camera.zoom
		end
	end
	
	def self.stats *arr
		# Method taken from _why's Dwemthy's Array
		# and subsequently modified
		return @default_stats if arr.empty?
		
		#~ attr_accessor *arr
		
		# Create one method to set each value, for the names given
		# in the arguments array
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
		
		@mp[:max] = 300# Arbitrary
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
	
	def jump
		#~ if @jump_count < 3 #Do not exceed the jump count.
			@jump_count += 1
			self.vz = 5 #On jump, set the velocity in the z direction
		#~ end
	end
	
	def move(dir)
		unit_vector =	case dir
							when :up
								Physics::Direction::N
							when :down
								Physics::Direction::S
							when :left
								Physics::Direction::W
							when :right
								Physics::Direction::E
							when :up_left
								Physics::Direction::NW
							when :up_right
								Physics::Direction::NE
							when :down_left
								Physics::Direction::SW
							when :down_right
								Physics::Direction::SE
						end
		
		#~ if in_air?
		if pz > elevation
			# Apply force for movement in air.
			# Should be less than ground movement force in most instances
			# 	if it's not, it sees like the character can fly
			# Needs to be enough to allow for jump modulation, and jumping forward from standstill
			@movement_force = unit_vector * @move_constant/10
		else
			# Apply force for movement on the ground
			@movement_force = unit_vector * @move_constant
		end
		
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
	
	def compute_direction
		angle = self.a
		
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
