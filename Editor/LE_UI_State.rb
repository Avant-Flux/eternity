#!/usr/bin/ruby

require 'rubygems'
require 'gosu'
require 'chipmunk'

require 'require_all'

require 'gl'
require 'glu'

include Gl
include Glu

class UI_State# < InterfaceState
	def initialize(window, space, player)
		@window = window
		@space = space
		@player = player
		
		
		@font = Gosu::Font.new @window, "Helvetica Bold", 25
        
        
        @editor_state = "POINTING"
        
        @compass = Gosu::Image.new window,
                        "./Development/Interface/Level Editor/compass.png", false
        @cursor_default = Gosu::Image.new window,
                        "./Development/Interface/Level Editor/default_cursor.png", false
        @cursor_place = Gosu::Image.new window,
                        "./Development/Interface/Level Editor/place_cursor.png", false
        @cursor_box = Gosu::Image.new window,
                        "./Development/Interface/Level Editor/box_cursor.png", false
		
	end
	
	def update
		#~ super
		
		# Optimize: only reset text when values change
		@level.text = "#{@player.level}"
		@hp_numerical_display.text = "#{@player.hp} | #{@player.max_hp}"
		@mp_numerical_display.text = "#{@player.mp} | #{@player.max_mp}"
	end
	
	def draw
		#~ # ========= Chat Box ========= 
		#~ # Aligned to bottom-left
		#~ height = 80
		#~ width = 200
		#~ corner = [0, @window.height - height]
		#~ chat_corner = corner.clone
		#~ chat_width = width
		#~ 
		#~ alpha = (0.10 * 255).to_i
		#~ color = Gosu::Color.argb alpha, 255, 255, 255
		#~ 
		#~ @window.draw_quad	corner[0],corner[1], color,
							#~ corner[0]+width,corner[1], color,
							#~ corner[0],corner[1]+height, color,
							#~ corner[0]+width,corner[1]+height, color
							#~ 
		#~ margin = 10
		#~ chat_margin = margin
		
        draw_compass
        draw_cursor
	end
    
    def draw_compass
        x = @window.width - 128
        y = 0
        z = 100
        @compass.draw x, y, z
    end
    
    def draw_cursor
        x = 0
        y = 0
        z = 100
        case @editor_state
            when "POINTING"
                @cursor_default.draw x, y, z
            when "PLACING"
                @cursor_place.draw x, y, z
            when "DRAWING"
                @cursor_box.draw x, y, z
        end
    end
	
	def finalize
		super
	end
	
	private
end
