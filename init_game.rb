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
		
		@tile_width = 50
		@tile_height = 50
		
		
		@font = Gosu::Font.new(self, "Trebuchet MS", 25)
		
		@player = Entity.new(self)
		
		@camera = Camera.new(self)
		@camera.followed_entity = @player
		
		@inpman = InputHandler.new
		@inpman.mode = :gameplay
		@inpman.new_action :up, :active do
			@player.y += @tile_height/10
		end
		@inpman.new_action :down, :active do
			@player.y -= @tile_height/10
		end
		@inpman.new_action :left, :active do
			@player.x -= @tile_width/10
		end
		@inpman.new_action :right, :active do
			@player.x += @tile_width/10
		end
		
		#TODO:	Change bind so there is only one bind method, which will search all input types
		#		and bind action appropriately.
		@inpman.bind_action :up, Gosu::KbUp
		@inpman.bind_action :down, Gosu::KbDown
		@inpman.bind_action :left, Gosu::KbLeft
		@inpman.bind_action :right, Gosu::KbRight
	end
	
	def update
		#~ process_input
		@inpman.update
	end
	
	def draw
		if @show_fps
			@font.draw "FPS: #{Gosu::fps}", 10,10,10, :color => Gosu::Color::FUCHSIA
		end
		
		
		x_count = 10
		y_count = 10
		
		@camera.draw do
			draw_world		x_count,y_count,	@tile_width,@tile_height
						
			draw_circle		@player.x,@player.y,3,	200,	Gosu::Color::RED
			
			@player.draw	@player.x, @player.y, 5,		Gosu::Color::RED
		end
	end
	
	def button_down(id)
		# Part of the update loop, not event-driven
		@inpman.button_down(id)
		
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
			when Gosu::Kb0
				@camera.zoom_reset
			when Gosu::Kb1
				puts "zoom in"
				@camera.zoom_in
			when Gosu::Kb2
				puts "zoom out"
				@camera.zoom_out
		end
	end
	
	def button_up(id)
		# Part of the update loop, not event-driven
		@inpman.button_up(id)
		
		if id == Gosu::KbA
			@steppable = false
		end
	end
	
	def needs_cursor?()
		true
	end
	
	def draw_world(x_count,y_count, tile_width,tile_height)
		(0..x_count).each do |x| x *= tile_width
			(0..y_count).each do |y| y *= tile_height
				#~ color = Gosu::Color.new rand*255, rand*255, rand*255
				x_factor = x.to_f/self.width
				y_factor = y.to_f/self.height
				color = Gosu::Color.new x_factor*255, y_factor*255, (x_factor+y_factor)*150+105
				
				draw_tile	x,y,0,	tile_height,tile_width, color
			end
		end
	end
	
	def draw_tile(x,y,z, height,width, color)
		self.draw_quad	x, y, color,
						x+width, y, color,
						x+width, y+height, color,
						x, y+height, color
	end
	
	def draw_circle(x,y,z, r, color, options={})
		options = {
			:stroke_width => 3,	# Width of the line
			:slices => 30, # Number of subdivisions around the z axis.
			:loops => 1, # Number of concentric rings about the origin.
			
			:start_angle => 0
		}.merge! options
		
		self.gl z do
			@quadric ||= gluNewQuadric()
			
			glColor(color.red, color.green, color.blue)
			glTranslatef(x,y,0)
			# Given Gosu's coordinate system, 0deg is down, pos rotation is CCW
			gluPartialDisk(@quadric, r-options[:stroke_width], r, 
							options[:slices], options[:loops],
							options[:start_angle], 360)
		end
	end
end



Game_Window.new.show
