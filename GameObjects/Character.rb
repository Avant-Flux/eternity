#!/usr/bin/ruby

require './Chipmunk/Space_3D'
require "./Titles/Title_Holder"
require "./GameObjects/Entity"
#To be used for NPCs, such as enemy units
#Townspeople (ie shopkeeper etc) should be under a different class
class Character < Entity
	attr_accessor :charge, :str, :con
	attr_accessor :inventory, :equipment
	
	def initialize(space, name, pos = [0, 0, 0], 
					subsprites={:body => 1, :face => 1, :hair => 1, 
								:upper => "shirt1", :lower => "pants1", :footwear => "shoes1"},
					mass=120, moment=20)
					
		animations = Animations::Character.new subsprites
		super(space, animations, name, pos, mass, moment, 1, :none, 
				{:str => 10, :con => 10, :dex => 10, :agi => 10, :luk => 10,
				:pwr => 10, :ctl => 10, :per => 10}, 0)

		#Remember to set atk and def based on str and con as well as other factors
		
		@charge = 0			#0 is normal, 1 is fired-up, -1 is suppressed
		@inventory = {:consumable => [], :equipable => [], :key_items => []}
		@equipment =	{:head => nil, :right_hand => nil, :left_hand => nil, 
						:upper_body => nil, :lower_body => nil, :feet => nil, 
						:title => Title_Holder.new}
	end
	
	def lvl=(arg)
		@lvl = arg
		
		set_stats
		
		@hp[:current] = @hp[:max]
		@mp[:current] = @mp[:max]
	end
	
	def use_item
		
	end
	
	def say arg # Arg = whatever the character says
		
		# Character sprite is 80 pixels tall
		
		# Store each point of the text box in an ordered pair (x,y)
		point = Struct.new(:x,:y)
		point1 = point.new x.to_px - 50, y.to_px - height - 100
		point2 = point.new x.to_px + 50, y.to_px - height - 100
		point3 = point.new x.to_px - 50, y.to_px - height - 30
		point4 = point.new x.to_px + 50, y.to_px - height - 30
		
		# Define color for text box
		color = Gosu::Color::GREEN
		
		# Draw box to hold character text
		$window.draw_quad(point1.x, point1.y, color, 
						   point2.x, point2.y, color, 
						   point3.x, point3.y, color, 
						   point4.x, point4.y, color, z)
		
		# Draw triangle that points to character that is speaking
		$window.draw_triangle(x.to_px - 25, y.to_px - height - 30, Gosu::Color::GREEN, 
							  x.to_px + 25, y.to_px - height - 30, Gosu::Color::GREEN, 
							  x.to_px, y.to_px - height, Gosu::Color::GREEN)
		
		# Draw text in text box
		@font = Gosu::Font.new($window, "Times New Roman", 25) unless @font
		@font.draw(arg, x.to_px - 49, y.to_px - height - 95, z.to_px + 5)
	end
	
	private
	
	def set_atk
		@atk = @str + @equipment[:right_hand].atk + @equipment[:left_hand].atk
	end
	
	def set_def
		@def = @con + @equipment[:right_hand].def + @equipment[:left_hand].def + 
				@equipment[:head].def + @equipment[:upper_body].def + @equipment[:lower_body].def +
				@equipment[:feet].def
	end
	
	def set_stats
		if @lvl > 10
			compute_hp
			compute_mp
			compute_str
			compute_con
			compute_dex
			compute_agi
			compute_mnd
			compute_per
			compute_luk
		else
			stats_to_10
		end
	end
	
	def stats_to_10
		@hp[:max] = @mp[:max] = @str = @con = @dex = @agi = @mnd = @per = @luk = 
			if @lvl < 10
				@lvl+9
			else
				20
			end
	end
	
	def compute_hp
		@hp[:max] = energy case @element
							when :fire
								4
							when :water
								3
							when :lightning
								2
							when :wind
								1
							when :earth
								5
						end
	end
	
	def compute_mp
		@mp[:max] = energy case @element
							when :fire
								2
							when :water
								5
							when :lightning
								1
							when :wind
								4
							when :earth
								3
						end
	end
	
	def compute_str
		@str = rate case @element
						when :fire
							7
						when :water
							2
						when :lightning
							6
						when :wind
							1
						when :earth
							5
					end
	end
	
	def compute_con
		@con = rate case @element
						when :fire
							4
						when :water
							1
						when :lightning
							2
						when :wind
							3
						when :earth
							7
					end
	end
	
	def compute_dex
		@dex = rate case @element
						when :fire
							2
						when :water
							5
						when :lightning
							1
						when :wind
							6
						when :earth
							4
					end
	end
	
	def compute_agi
		@agi = rate case @element
						when :fire
							3
						when :water
							4
						when :lightning
							5
						when :wind
							7
						when :earth
							2
					end
	end
	
	def compute_mnd
		@mnd = rate case @element
						when :fire
							5
						when :water
							6
						when :lightning
							4
						when :wind
							2
						when :earth
							3
					end
	end
	
	def compute_per
		@per = rate case @element
						when :fire
							1
						when :water
							7
						when :lightning
							3
						when :wind
							5
						when :earth
							6
					end
	end
	
	def compute_luk
		@luk = rate case @element
						when :fire
							6
						when :water
							3
						when :lightning
							7
						when :wind
							4
						when :earth
							1
					end
	end
	
	def rate arg
		case arg
			when 7
				((43/9.0)*@lvl-(250/9.0)).floor
			when 6
				((38/9.0)*@lvl-(200/9.0)).floor
			when 5
				((10/3.0)*@lvl-(40/3.0)).floor
			when 4
				((20/9.0)*@lvl-(20/9.0)).floor
			when 3
				((16/9.0)*@lvl+(20/9.0)).floor
			when 2
				((4/3.0)*@lvl+(20/3.0)).ceil
			when 1
				((8/9.0)*@lvl+(100/9.0)).floor
		end
	end
	
	def energy arg
		case arg
			when 5
				((((28.0)/(9.0))*(@lvl-10))+20).floor
			when 4
				((((266.0)/(3.0))*(@lvl-10))+20).floor
			when 3
				((((166.0)/(3.0))*(@lvl-10))+20).floor
			when 2
				(22*@lvl-200).floor
			when 1
				((((88.0)/(9.0))*(@lvl-10))+20).floor
		end
	end
	
end
