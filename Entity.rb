#!/usr/bin/ruby
#~ Name: Jason
#~ Date last edited: 02.23.2010

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

	#Returns the amount of damage dealt, or nil if the attack missed
	def melee_attack(enemy)
		if @atk > enemy.def
			if melee_hit?(enemy) || melee_rebound?(enemy)		#Check rebound unless already hit
				#If the attack hits them...
				damage = @atk - enemy.def
				enemy.hp -= damage

				return damage
			else
				return nil	#Missed~~~
			end
		else
			return 0		#No change to hp
		end
	end

	def melee_hit?(enemy)
		check = @dex-enemy.agi

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
		if hit_chance == 0
			false
		else
			percent_check hit_chance
		end
	end

	def melee_rebound?(enemy)
		#~ The BigMath class has methods to compute e and e^(x)
			#~ puts 1/(1+3*exp(BigDecimal.new('-3')*x, 10))

		rebound_chance =	if @luk > 9000	#See if the attack can hit by luck
								50
							elsif @luk > 4500
								48
							elsif @luk > 2250
								45
							elsif @luk > 1125
								40
							elsif @luk > 562
								30
							elsif @luk > 281
								10
							elsif @luk > 140
								5
							elsif @luk > 70
								4
							elsif @luk > 35
								3
							elsif @luk > 17
								2
							elsif @luk > 8
								1
							else
								0
							end
		if rebound_chance == 0
			false
		else
			percent_check rebound_chance
		end
	end

	def shoot(enemy)

	end

	def use_skill(enemy)

	end

	private

	#Description:	Checks if an operation succeeds using a percentage chance
	#				Analogous to rolling a 100-sided die
	def percent_check(percent)
		rand(100) < percent
	end
end
