#!/usr/bin/ruby
#~ Name: Jason
#~ Date last edited: 02.05.2010

#Parent class of all Creatures, Fighting NPCs, and PCs
class Entity
	attr_accessor :x, :y, :z, :direction 
	attr_reader :animations, :current_animation
	attr_accessor :element, :faction, :hidden
	attr_accessor :lvl, :hp, :max_hp, :mp, :max_mp
	attr_accessor :atk, :def, :dex, :agi, :mnd, :per, :luk
		
	def initialize(animations, pos, lvl, hp, mp, element, stats, faction)
		@animations = animations
		@current_animation = @animations[:down]
		
		@x = pos[0]
		@y = pos[1]
		@z = pos[2]
		
		@element = element
		@faction = 0		#express faction spectrum as an integer, Dark = -100, Light = 100
		@direction = 0		#Angle in degrees using Gosu's coordinate system of pos-y = 0, cw = pos
		@hidden = false		#Controls physical hiding; might not actually be needed
		
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
	
	def hidden?			#Controls physical hiding (ie, in shadows)
		@hidden
	end

	def randomize_stats
		
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
	
	def attack(entity)
		unless @atk <= entity.def
			hit = melee_hit?(entity) || melee_rebound?(entity)
			
			if hit#If the attack hits them...
				entity.hp -= (@atk )
			end
		else
			nil	#No change to hp
		end
	end
	
	def melee_hit?(entity)
		check = @dex-entity.agi
		
		hit_chance = if check >= 95
						100
					elsif check >= 85
						95
					elsif check >= 0
						80
					elsif check >= -20
						50
					elsif check >= -60
						20
					elsif check >= -85
						5
					elsif check <= -95
						0
					end
		
		rand(100) < hit_chance
	end
	
	def melee_rebound?
		if @luk > 9000	#See if the attack can hit by luck
			true
		elsif @luk > 
			nil
		else
			false
		end
	end
	
	def shoot(entity)
		
	end
	
	def use_skill(entity)
		
	end
end