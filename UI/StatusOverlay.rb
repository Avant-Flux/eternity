#!/usr/bin/ruby
#~ Name: Jason
#~ Date last edited: 09.18.2010
require 'rubygems'
require 'gosu'
require 'texplay'

module UI
	module Overlay
		class Status
			def initialize(window, player)
				#Perhaps the structure of Player should be changed so that only the
				#	stats have to be passed and not the whole player.  Such a limitation
				#	would be better in terms of information hiding.
				@window = window
				@player = player
				
				#Draw a circle with a rectangle coming out of the right side
				#In the center of the circle will be the elemental symbol
				#	A ring around the edge will show an approximation of the 
				#		amount of mana the player has
				#	A number in the form (500 / 1000) or something like that,
				#		will show the exact amount of mana the player has.
				#		This number will be displayed under the elemental symbol.
				#
				#The rectangle area will show the level of the player, 
				#	as well as the amount of exp needed to reach the next level.
				#	The Player's HP bar will also be rendered in this area.
				#
				#	===It would be nice to come up with a circular representation
				#		for the HP as well, but that might not work out.  It works
				#		for the mana gauge because some moves (notably those under
				#		the lightning element) use a percentage of the total mana,
				#		and not a strict amount.
				width = 500
				height = 300
				@img = TexPlay.create_blank_image(@window, width, height)
				
				color = Gosu::Color.new(0xff666666)
				cx = 80
				cy = 85
				@img.circle cx, cy, 75, :color => color, :fill => true
				@img.rect cx,cy, 350,140, :color => color, :fill => true
				
				@font = Gosu::Font.new(@window, font="Times New Roman", font_size=25)
				@mana = "7500 / 10000"
				@hp = "1852 / 2000"
			end
			
			def update
				
			end
			
			def draw
				@img.draw(0,0,1000)
				@font.draw(@mana, 35,110, 1001)
				@font.draw(@hp, 225,85, 1001)
				@font.draw(@player.lvl, 185,120, 1001)
				@font.draw("256 / 300", 265,120, 1001)
				
				@font.draw("HP", 160, 85, 1001)
				@font.draw("Lvl", 150,120, 1001)
				@font.draw("Exp", 220, 120, 1001)
			end
			
			class Ring_Bar
				def initialize(window, cx,cy, radius, starting_percent=0)
					@window = window
					@cx = cx
					@cy = cy
					@radius = radius
					@percent = starting_percent
					render
				end
				
				def update
					
				end
				
				def draw
					@img.draw
				end
				
				def render
					canvas = Magick::Image.new(width, height) do
						self.background_color = "transparent"
					end
					gc = Magick::Draw.new
					
					gc.stroke('red')
					gc.stroke_width(stroke_width)
					gc.fill_opacity(0)
					gc.ellipse(width/2,height/2, a,b, 0,360)
					
					gc.draw(canvas)
					@img = Gosu::Image.new(@window, canvas, false)
				end
			end
			
			class Mana_Ring
				def initialize(window, player)
					@rings = Array.new
					
					outer_radius = 10
					width = 2
					#~ buffer = 2
					
					5.times do |i|
						@rings << Ring_Bar.new(window, outer_radius-(width*i))
					end
					render
				end
				
				def update
					
				end
				
				def draw
					
				end
				
				def render
					@rings.each do |ring|
						ring.render
					end
				end
			end
		end
	end
end
