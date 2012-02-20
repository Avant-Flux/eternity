require 'set'

module Spells
	module Charge
		attr_reader :charge_time
		
		def init_charge(charge_time)
			@charge_time = charge_time	# Time it takes to prep the spell
			@charge = false				# Is the spell currently charged and ready to use?
		end
		
		def update
			if @start_time
				delta_time = @start_time - Gosu::milliseconds
				if delta_time >= @charge_time
					@charge = true
				end
			end
		end
		
		def button_down
			# Timestamp when the button is depressed
			@start_time = Gosu::milliseconds
		end
		
		def button_up
			# Attempt to cast when button is released
			# If there is a requisite charge time, and it has not been met,
			# the spell will fizzle.
			@charge = false
		end
	end
	
	module Offensive
		def cast(target)
			# Compute damage, AoE, splash, and other necessary factors
			
		end
		
		def attack(atk)
			# Metaprogramming method to specify the atk dmg of the spell
		end
	end
	
	module Support
		def cast(target)
			
		end
	end
	
	class Spell
		attr_reader :element, :charge_time, :mp_cost, :damage
		
		def initialize(caster)
			@caster = caster	# Reference to the Entity which cast the spell
			
			#~ @element = element
			#~ @mp_cost = mp_cost
			#~ @damage = damage
			@values = Hash.new
			
			init_stats
		end
		
		def update
			
		end
		
		def init_stats
			self.class.stats.each do |stat, value|
				attr_reader stat
				instance_variable_set "@#{stat}".to_sym, value
			end
		end
		
		def self.stats *arr
			return @default_values if arr.empty?
			
			arr.each do |stat|
				#~ attr_reader stat	# Allow the stats to be read by instances of the class
				
				meta_eval do 
					define_method stat do |val|
						#instance_variable_set(:@name, val)
						#instance_variable_get
						@default_values ||= Hash.new
						@default_values[stat] = val
					end
				end
			end
		end
		
		#~ stats :element, :attributes, :range, :area_of_effect, :mp_cost, :power, :charge_time
		stats :element, :area_of_effect, :mp_cost, :power, :charge_time
		
		meta_eval do
			define_method :attributes do |*args|
				@default_values ||= Hash.new
				@default_values[:attributes] = Set.new args
			end
			
			define_method :range do |range|
				@default_values ||= Hash.new
				@default_values[:range] = range
			end
		end
		
		def button_down
			
		end
		
		def button_up
			# Attempt to cast when button is released
			# If there is a requisite charge time, and it has not been met,
			# the spell will fizzle.
			
		end
		
		def cast(target)
			# Attempt to use this spell on the prescribed target
			
		end
	end
end
