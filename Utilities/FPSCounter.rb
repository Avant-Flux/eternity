#FPS Counter taken from Dahrkael RPG Template
#Modified by: Jason Ko 

require "rubygems"
require "gosu"
# FPS Counter based in fguillen's fpscounter
	class FPSCounter
		attr_accessor :show_fps
		attr_reader :fps
		
		def initialize(font_size=25, font="Trebuchet MS")
			@font = Gosu::Font.new($window, font, font_size)
			@frames_counter = 0
			@milliseconds_before = Gosu::milliseconds
			@show_fps = false
			@fps = 0
			
			@dt = 0
			@refresh_interval = 1
			@refresh_interval.to_f
		end
		
		def update
			@frames_counter += 1
			@dt += $dt
			
			if @dt >= @refresh_interval
				@fps = @frames_counter.to_f / @dt.to_f
				@frames_counter = 0
				@dt = 0
			end
		end
		
		def draw
			@font.draw("FPS: "+@fps.to_s, 0, 0, 9999) if @show_fps
		end
		
		def toggle
			@show_fps = !@show_fps
		end
	end
