#!/usr/bin/ruby
path = File.expand_path File.dirname(__FILE__)
path = path[0..(path.rindex(File::SEPARATOR)-1)]
Dir.chdir path

require './GameWindow'

class LevelEditor < GameWindow
	def initialize
		super
	end
	
	def update
		super
		
	end
	
	def draw
		super
	end
	
	def button_down(id)
		super(id)
		
		if id == Gosu::MsLeft
			click_UI
		elsif id == Gosu::MsRight
			click_scene
		end
	end
	
	def button_up(id)
		super(id)
	end
	
	private
	
	def update_screen
		
	end
	
	def draw_screen
		if @show_fps
			@font.draw "FPS: #{Gosu::fps}", 10,10,10, 1,1, Gosu::Color::FUCHSIA
		end
		
		@interface.draw
		
		# Draw circle around the mouse pointer
		self.draw_circle	self.mouse_x, self.mouse_y, 0,
							50, Gosu::Color::RED
	end
	
	def click_UI
		#~ @mouse.click_UI CP::Vec2.new(mouse_x, mouse_y)
		puts "x: #{self.mouse_x}   y: #{self.mouse_y}"
	end
	
	def click_scene
		# Calculate displacement from center of screen in px
		#~ dx_px = mouse_x - self.width/2.0
		#~ dy_px = mouse_y - self.height/2.0
		#~ 
		#~ # Use that to calculate displacement from center point of camera tracking
		#~ dx_meters = dx_px / Physics.scale / @camera.zoom
		#~ dy_meters = dy_px / Physics.scale / @camera.zoom
		#~ 
		#~ # Calculate absolute position of click within game world
		#~ v = CP::Vec2.new dx_meters, dy_meters
		#~ v.x += @camera.p.x
		#~ v.y += @camera.p.y
		#~ 
		#~ # Initiate click event
		#~ @mouse.click_scene v
		
		puts "x: #{@camera.followed_entity.body.p.x}   y:#{@camera.followed_entity.body.p.y}"
		
		@camera.draw_trimetric do
			self.draw_circle	0, 
								0, 
								0,
								5, Gosu::Color::RED, 
								:stroke_width => 100
		end
		
	end
end

LevelEditor.new.show
