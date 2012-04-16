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
		
		
		x_scale = 0.75
		y_scale = 0.65
		# OpenGL transform is column-major
		@tile_transform = [
			x_scale*Math.cos((8.79).to_rad), x_scale*Math.sin((8.79).to_rad), 0, 0,
			y_scale*Math.cos((65.1).to_rad), -y_scale*Math.sin((65.1).to_rad), 0, 0,
			0 ,0, 1, 0,
			0, 0, 0, 1
		]
		
		@player = Struct.new(:x, :y).new(0, 0)
		
		@zoom = 1
	end
	
	def update
		#~ process_input
		#~ @inpman.update
	end
	
	def draw
		if @show_fps
			@font.draw "FPS: #{Gosu::fps}", 10,10,10, :color => Gosu::Color::FUCHSIA
		end
		
		tile_width = 50
		tile_height = 50
		
		x_count = 10
		y_count = 10
		
		
		self.translate self.width/2, self.height/2 do # Translate relative to screen coordinates
			self.transform *@tile_transform do
				self.translate -@player.x*tile_width, -@player.y*tile_height do # Relative to world
					self.scale @zoom,@zoom, @player.x*tile_width,@player.y*tile_height  do
						draw_world	x_count,y_count,	tile_width,tile_height
						
						draw_circle	@player.x*tile_width,@player.y*tile_height,3,	200,
									Gosu::Color::RED
						
						draw_player	@player.x*tile_width, @player.y*tile_height, 5,	 Gosu::Color::RED
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
		
		case id
			when Gosu::Kb0
				@zoom = 1
			when Gosu::Kb1
				puts "zoom in"
				@zoom += 1
			when Gosu::Kb2
				puts "zoom out"
				@zoom -= 1
		end
		if @zoom < 1
			@zoom = 1
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
	
	def draw_player(x,y,z, color)
		# Draw a square in perspective centered on the player location
		width = 6
		height = 6
		
		half_width = width/2
		half_height = height/2
		
		self.translate -half_width, -half_height do
			self.draw_quad	x, y, color,
							x+width, y, color,
							x+width, y+height, color,
							x, y+height, color
		end
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
