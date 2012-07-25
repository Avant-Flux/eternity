#!/usr/bin/ruby
path = File.expand_path File.dirname(__FILE__)
path = path[0..(path.rindex(File::SEPARATOR)-1)]
Dir.chdir path

require './GameWindow'
##require './Editor/LE_UI_State'
require_all './Editor/LevelEditor_lib'

class LevelEditor < GameWindow
attr_accessor :selected_cursor
attr_reader :state_manager # TODO: Remove if possible

	def initialize
		super()
		self.caption = "Level Editor v0.00.1"
				
		@interface = LevelEditorInterface.new self
		@temp_var = Entity.new self
		
		@temp_var.shape.collision_type = :none
		@temp_var.body.p.x = @state_manager.top.spawn[0]
		@temp_var.body.p.y = @state_manager.top.spawn[1]
		@temp_var.body.pz = @state_manager.top.spawn[2]
		@camera.followed_entity = @temp_var
		
		# TODO: Implement custom cursors inside of the mouse handler class
		cursor_directory = File.join Dir.pwd, "Development", "Interface", "Level Editor"
		@cursor = {
			:default => Gosu::Image.new(self, File.join(cursor_directory, "default_cursor.png"), false),
			:place => Gosu::Image.new(self, File.join(cursor_directory, "place_cursor.png"), false),
			:box => Gosu::Image.new(self, File.join(cursor_directory, "box_cursor.png"), false),
			:menu => Gosu::Image.new(self, File.join(cursor_directory, "menu_cursor.png"),false)
		}
		@selected_cursor = :default
		
		
		
		@ui_state_manager.pop
		
		@buildings = {}
		load_buildings
		
		## State data ##
		
		@EDITOR_STATE = :NONE
		@SELECTED_BUILDING = "$none$"
		
		init_menu_inputs
		bind_menu_inputs
		init_editor_inputs
		bind_editor_inputs
		@inpman.mode = :editor
	end
	
	def update
		@selected_cursor = :default
		
		super
		if self.mouse_x >= @interface.sidebar.body.p.x
			@inpman.mode = :editor_menu
		else
			@inpman.mode = :editor
		end
		
		@interface.update
	end
	
	def draw
		#~ super
		
		#if @selected_cursor == :box # right click active
			@camera.draw_trimetric 0 do
				r = 2
				draw_circle *@state_manager.top.spawn,
							r, Gosu::Color::RED,
							:stroke_width => r
			end
		#end
		
		super()
		
		draw_screen
	end
	
	def button_down(id)
        @inpman.button_down(id)
		
        case id
            when Gosu::KbEscape
                close
            when Gosu::KbZ
                @EDITOR_STATE = :PLACING_BUILDING
            when Gosu::MsLeft
                if @EDITOR_STATE == :PLACING_BUILDING
                    mouse_down_scene
                end
        end
        
			
			
		if id == Gosu::MsWheelDown
			if button_down? Gosu::MsLeft
				@selected_building.body.pz -= 1
			else
				@camera.zoom_in
			end
		elsif id == Gosu::MsWheelUp
			if button_down? Gosu::MsLeft
				@selected_building.body.pz += 1
			else
				@camera.zoom_out
			end
				
				
		end
	end
	
	def button_up(id)
		@inpman.button_up(id)
		
        case id
            when Gosu::KbA
                super id
            when Gosu::KbZ
                @EDITOR_STATE = :NONE
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
	
	
	def mouse_up_UI
		
	end
	
	def mouse_down_UI
		#~ @mouse.click_UI CP::Vec2.new(mouse_x, mouse_y)
		#puts "x: #{self.mouse_x}   y: #{self.mouse_y}"
		
	end
	
	def mouse_up_scene
		
	end
	
	def mouse_down_scene
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
		
		x = @camera.followed_entity.body.p.x
		y = @camera.followed_entity.body.p.y
		
		#puts "x: #{x}   y:#{y}"
		
		
		@camera.draw_trimetric do
			r = 5
			#self.draw_circle	x, y, 0,	r,
			#					Gosu::Color::WHITE, :stroke_width => r
		end
        
		case @EDITOR_STATE
			when :NONE
			#~ Remove print later; debug only
			puts "no state"
			when :PLACING_BUILDING
				# Temporary variable values
				@SELECTED_BUILDING = "buildingA"
				
				# TODO: x,y,z to be set with raytrace
				# TODO: Separate different editor states into classes for clarity
				x = 0
				y = 0
				z = 0
				#
				
				if @SELECTED_BUILDING != "$none$"
					building_data = *@buildings[ @SELECTED_BUILDING ]
					building = Building.new self,
											building_data[ :size ],
											x, y, z,
											building_data[ :textures ]
				
					@state_manager.get_top.add_gameobject building
				else
					puts "No selected building"
				end
			when :PLACING_NPC
				nil
			when :PLACING_SPAWN
				nil
			when :BOX
				nil
        end
	end
    
    def load_buildings
		path = File.join "Levels", "Tutorial.txt"
		
		File.open( path, "r" ).each do |line|
			args = line.split
			@buildings[ args[0] ] = {
				:size => [ args[1].to_f, args[2].to_f, args[3].to_f ],
				:textures => [ args[4], args[5] ]
			}
			#puts "recognized new building type #{args[0]}"
		end
    end
    
    def init_editor_inputs
		@inpman.mode = :editor
		
		@inpman.new_action :set_pan, :rising_edge do
			@old_mouse = @state_manager.raycast self.mouse_x,self.mouse_y
		end
		
		@inpman.new_action :pan, :active do
			@cur_mouse = @state_manager.raycast self.mouse_x,self.mouse_y
			dif_x = @cur_mouse.x - @old_mouse.x
			dif_y = @cur_mouse.y - @old_mouse.y

			@temp_var.body.p.x = @temp_var.body.p.x - dif_x
			@temp_var.body.p.y = @temp_var.body.p.y - dif_y
		end
		
		@inpman.new_action :move_object, :active do
			unless button_down?(Gosu::KbLeftControl) || button_down?(Gosu::KbRightControl)
				@cur_mouse = @state_manager.raycast self.mouse_x,self.mouse_y
				dif_x = @cur_mouse.x - @pos_mouse.x
				dif_y = @cur_mouse.y - @pos_mouse.y
				
				if @selected_building
					@selected_building.body.p.x = @selected_building.body.p.x + dif_x
					@selected_building.body.p.y = @selected_building.body.p.y + dif_y
				end
				
				@pos_mouse = @cur_mouse
			end
		end
		
		@inpman.new_action :select_object, :rising_edge do
			@pos_mouse = @state_manager.raycast self.mouse_x,self.mouse_y
			
			closest_shape = nil
			@state_manager.raycast_mouse do |shape| 
				closest_shape ||= shape
				if shape.body.pz > closest_shape.body.pz
					closest_shape = shape
				end
				@selected_building = closest_shape				
			end
		end
		
		@inpman.new_action :msleft_up, :falling_edge do
			@selected_building = nil
			@state_manager.rehash_space
		end
		
		@inpman.new_action :place_cursor, :active do
			@selected_cursor = :place #if @selected_cursor == :default
		end
		
	end
	
	def bind_editor_inputs
		@inpman.mode = :editor
		
		@inpman.bind_action :pan, Gosu::MsMiddle
		@inpman.bind_action :set_pan, Gosu::MsMiddle
		#~ @inpman.bind_action :test2, Gosu::MsMiddle
		
		@inpman.bind_action :select_object, Gosu::MsLeft
		@inpman.bind_action :move_object, Gosu::MsLeft
		@inpman.bind_action :msleft_up, Gosu::MsLeft
		
		@inpman.bind_action :place_cursor, Gosu::MsLeft
		
	end
	
	def init_menu_inputs
		@inpman.mode = :editor_menu
		
		
		
		@inpman.new_action :menu_click, :rising_edge do
			@interface.click(self.mouse_x, self.mouse_y)
			puts "do some stuff"
		end
		
	end
	
	def bind_menu_inputs
		@inpman.bind_action :menu_click, Gosu::MsLeft
	end
end

LevelEditor.new.show
