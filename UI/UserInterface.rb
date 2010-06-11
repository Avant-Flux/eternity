#!/usr/bin/ruby
#~ Name: Jason
#~ Date last edited: 06.07.2010

require 'rubygems'
require 'gosu'
require 'chingu'

require 'chipmunk'
require 'Chipmunk/ChipmunkInterfaceMod'

require 'Entity'
require "Creature"
require 'Character'
require 'Player'

require 'UI/TrackingOverlay.rb'

require 'texplay'

module HUD
	class Status_Window
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
			#~ @img.paint {
				#~ 
			#~ }
		end
		
		def update
			
		end
		
		def draw
			
		end
	end
end
