#!/usr/bin/ruby

module Combative
	#Returns the amount of damage dealt, or nil if the attack missed
	def melee_attack(enemy)
		if @stats[:composite][:atk] > enemy.stats[:composite][:def]
			if melee_hit?(enemy) || melee_rebound?(enemy)		#Check rebound unless already hit
				#If the attack hits them...
				damage = @stats[:composite][:atk] - enemy.stats[:composite][:def]
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
		check = @stats[:raw][:dex]-enemy.stats[:raw][:agi]

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

		rebound_chance =	if @stats[:raw][:luk] > 9000	#See if the attack can hit by luck
								50
							elsif @stats[:raw][:luk] > 4500
								48
							elsif @stats[:raw][:luk] > 2250
								45
							elsif @stats[:raw][:luk] > 1125
								40
							elsif @stats[:raw][:luk] > 562
								30
							elsif @stats[:raw][:luk] > 281
								10
							elsif @stats[:raw][:luk] > 140
								5
							elsif @stats[:raw][:luk] > 70
								4
							elsif @stats[:raw][:luk] > 35
								3
							elsif @stats[:raw][:luk] > 17
								2
							elsif @stats[:raw][:luk] > 8
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
