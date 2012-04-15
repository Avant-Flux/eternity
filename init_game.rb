#!/usr/bin/ruby
Dir.chdir File.dirname(__FILE__)

require 'rubygems'
require 'gosu'
require 'chipmunk'

require 'require_all'
#~ require 'profile'
#~ require 'ruby-prof'
#~ RubyProf.start

require_all './Utilities'

require_all './Physics'

require_all './Combat'
require_all './Drawing'
require_all './Equipment'
require_all './Stats'
require_all './Titles'

require_all './GameObjects'
require_all './GameStates'

require_all './UI'


class Game_Window < Gosu::Window
	def initialize
		fps = 60
		# Window should have a 16:9 aspect ratio
		super(1280, 720, false, (1.0/fps)*1000)
		self.caption = "Eternity 0.11.0"
		
		@font = Gosu::Font.new(self, "Trebuchet MS", 25)
		
		# OpenGL transform is column-major, 
		@tile_transform = [
			Math.cos((8.79).to_rad), Math.sin((8.79).to_rad), 0, 0,
			-Math.cos((65.1).to_rad), Math.sin((65.1).to_rad), 0, 0,
			0 ,0, 1, 0,
			0, 0, 0, 1
		]
		
		@player = Struct.new(:x, :y).new(0, 0)
	end
	
	def update
		#~ process_input
		#~ @inpman.update
	end
	
	def draw
		if @show_fps
			@font.draw "FPS: #{Gosu::fps}", 10,10,10, :color => Gosu::Color::FUCHSIA
		end
		
		width = 50
		height = 50
		
		x_count = 10
		y_count = 10
		
		self.translate self.width/2, self.height/2 do # Translate relative to screen coordinates
			self.transform *@tile_transform do
				self.translate -@player.x*width, @player.y*height do # Relative to world
					(0..x_count).each do |x| x *= width
						(0..y_count).each do |y| y *= height
							#~ color = Gosu::Color.new rand*255, rand*255, rand*255
							x_factor = x.to_f/self.width
							y_factor = y.to_f/self.height
							color = Gosu::Color.new x_factor*255, y_factor*255, (x_factor+y_factor)*150+105
							
							draw_tile	x,y,0,	height,width, color
						end
					end
				end
			end
		end
	end
	
	def button_down(id)
		# Part of the update loop, not event-driven
		#~ @inpman.button_down(id)
		
		if id == Gosu::KbEscape
			close
		end
		if id == Gosu::KbF
			@show_fps = !@show_fps
		end
		if id == Gosu::KbA
			@steppable = true
		end
		
		case id
			when Gosu::KbUp
				@player.y += 1
			when Gosu::KbDown
				@player.y -= 1
			when Gosu::KbLeft
				@player.x -= 1
			when Gosu::KbRight
				@player.x += 1
		end
	end
	
	def button_up(id)
		# Part of the update loop, not event-driven
		#~ @inpman.button_up(id)
		
		if id == Gosu::KbA
			@steppable = false
		end
	end
	
	def needs_cursor?()
		true
	end
	
	def draw_tile(x,y,z, height,width, color)
		self.draw_quad	x, y, color,
						x+width, y, color,
						x+width, y+height, color,
						x, y+height, color
	end
end



Game_Window.new.show
