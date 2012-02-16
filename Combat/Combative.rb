#!/usr/bin/ruby

module Combative
	DEFAULT_CHARGE_TIME = 2000
	
	attr_accessor :magic_charge
	@magic_charge = false
	
	def charge_time(attack_type)
		# Time in milliseconds needed to charge an attack
		case attack_type
			when :magic
				return DEFAULT_CHARGE_TIME
			when :left_hand
				if @equipment[:left_hand]
					return @equipment[:left_hand].charge_time
				else
					# Assumes that LH button fires RH event when no weapon is equipped in LH
					return charge_time :right_hand
				end
			when :right_hand
				return @equipment[:right_hand].charge_time
		end
	end
	
	[:magic].each do |attack_type|
		define_method attack_type do ||
			puts attack_type
			self.mp -= 10
		end
		
		define_method "intense_#{attack_type}".to_sym do ||
			puts "intense_#{attack_type}"
		end
		
		define_method "charge_#{attack_type}".to_sym do ||
			puts "charge_#{attack_type}"
		end
		
		define_method "intense_charge_#{attack_type}".to_sym do ||
			puts "intense_charge_#{attack_type}"
		end
	end
	
	[:left_hand, :right_hand].each do |attack_type|
		define_method attack_type do ||
			puts attack_type
		end
		
		define_method "intense_#{attack_type}".to_sym do ||
			puts "intense_#{attack_type}"
		end
		
		define_method "charge_#{attack_type}".to_sym do ||
			puts "charge_#{attack_type}"
		end
		
		define_method "intense_charge_#{attack_type}".to_sym do ||
			puts "intense_charge_#{attack_type}"
		end
	end
	
	#Returns the amount of damage dealt, or nil if the attack missed
	def melee_attack(enemy)
		#~ if @stats[:composite][:atk] > enemy.stats[:composite][:def]
			#~ if melee_hit?(enemy) || melee_rebound?(enemy)		#Check rebound unless already hit
				#~ #If the attack hits them...
				#~ damage = @stats[:composite][:atk] - enemy.stats[:composite][:def]
				#~ enemy.hp -= damage
#~ 
				#~ return damage
			#~ else
				#~ return nil	#Missed~~~
			#~ end
		#~ else
			#~ return 0		#No change to hp
		#~ end
		
		attack_mod =	if @equipment
							@equipment[:left_hand].attack
						else
							0
						end
		
		defence_mod =	if enemy.respond_to? :equipment
							x = 0
							enemy.equipment.each_pair do |type, armor|
								if armor && !(type == :right_hand || type == :left_hand || type == :title)
									x += armor.defence
								end
							end
							
							puts "#{enemy.class} - armor #{x}"
							(x*0.8).to_i
						else
							0
						end
		
		defence = enemy.stats[:raw][:constitution] + defence_mod
		offense = @stats[:raw][:strength] + attack_mod
		
		if offense > defence
			# Use random number based on dex to determine exact damage
			#~ if melee_hit? enemy
				puts "def: #{defence}"
				puts "offense #{offense}"
				
				damage = offense - defence
				
				if damage < 0
					damage = 0
					puts "no damage"
				end
				
				enemy.hp -= damage
			#~ end
			
			if enemy.hp < 0
				enemy.hp = 0
			end
		end
	end

	def melee_hit?(enemy)
		dodge = enemy.stats[:raw][:constitution] - enemy.level
		
		check = @stats[:raw][:dex] - dodge
		
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
