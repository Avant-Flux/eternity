#!/usr/bin/ruby
path = File.expand_path File.dirname(__FILE__)
path = path[0..(path.rindex(File::SEPARATOR)-1)]
Dir.chdir path

require './GameWindow'
##require './Editor/LE_UI_State'
require_all './Editor/LevelEditor_lib'

class LevelEditor < GameWindow
    
    
	def initialize
		###~ super
        
        ##@ui_state = UI_State.new self, @space, @player
        
		super
		self.caption = "Level Editor v0.00.1"
		
		@interface = LevelEditorInterface.new self, @space
		
		# TODO: Implement custom cursors inside of the mouse handler class
		cursor_directory = File.join Dir.pwd, "Development", "Interface", "Level Editor"
		@cursor = {
			:default => Gosu::Image.new(self, File.join(cursor_directory, "default_cursor.png"), false),
			:place => Gosu::Image.new(self, File.join(cursor_directory, "place_cursor.png"), false),
			:box => Gosu::Image.new(self, File.join(cursor_directory, "box_cursor.png"), false)
		}
		@selected_cursor = :default
	end
	
	def update
		#~ super
        
		@ui_state.update
	end
	
	def draw
		##super
        
		if @selected_cursor == :box # right click active
			@camera.draw_trimetric do
				r = 20.to_meters
				draw_circle	0,0,0,
							r, Gosu::Color::FUCHSIA,
							:stroke_width => r
			end
		end
		
		super()
		
		#~ if @selected_cursor == :place # left click active
			#~ r = 20
			#~ draw_circle	self.mouse_x,self.mouse_y,0,
						#~ r, Gosu::Color::FUCHSIA,
						#~ :stroke_width => r
		#~ end
	end
	
	def button_down(id)
		super(id)
		
		if id == Gosu::MsLeft
			@selected_cursor = :place if @selected_cursor == :default
			
			click_UI
		elsif id == Gosu::MsRight
			@selected_cursor = :box if @selected_cursor == :default
			
			click_scene
		end
	end
	
	def button_up(id)
		super(id)
		
		
		if id == Gosu::MsLeft
			if @selected_cursor == :place # left click active
				@selected_cursor = :default
			end
		elsif id == Gosu::MsRight
			if @selected_cursor == :box # right click active
				@selected_cursor = :default
			end
		end
	end
	
	def needs_cursor?()
		false
	end
	
	private
	
	def update_screen
		
	end
	
	def draw_screen
		##super
        
		if @show_fps
			@font.draw "FPS: #{Gosu::fps}", 10,10,10, 1,1, Gosu::Color::FUCHSIA
		end
		
		@interface.draw
		
		flush
		
		@cursor[@selected_cursor].draw	self.mouse_x-@cursor[@selected_cursor].width/2, 
								self.mouse_y-@cursor[@selected_cursor].height/2, 0
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
