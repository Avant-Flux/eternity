#!/usr/bin/ruby
path = File.expand_path File.dirname(__FILE__)
path = path[0..(path.rindex(File::SEPARATOR)-1)]
Dir.chdir path

require './GameWindow'
##require './Editor/LE_UI_State'
require_all './Editor/LevelEditor_lib'

class LevelEditor < GameWindow
attr_accessor :selected_cursor
attr_reader :state_manager, :buildings, :inpman # TODO: Remove if possible

	def initialize
		super()
		self.caption = "Level Editor v0.00.1"
		# deliberately different from the name in GameWindow, created so indicator can be
		# drawn in a different location
		@show_framerate = false
		
		#camera from state manager
		@camera = @state_manager.camera
		
		
		
		
		
		
		
		# TODO: Implement custom cursors inside of the mouse handler class
		cursor_directory = File.join Dir.pwd, "Development", "Interface", "Level Editor"
		@cursor = {
			:default => Gosu::Image.new(self, File.join(cursor_directory, "default_cursor.png"), false),
			:place => Gosu::Image.new(self, File.join(cursor_directory, "place_cursor.png"), false),
			:box => Gosu::Image.new(self, File.join(cursor_directory, "box_cursor.png"), false),
			:menu => Gosu::Image.new(self, File.join(cursor_directory, "menu_cursor.png"),false)
		}
		@selected_cursor = :default
		
		
		
		@compass = Compass.new	self,
			:relative => self,
			
			:top => :auto, :bottom => 20,
			:left => 20, :right => :auto
		
		
		@interface = EditorStateManager.new self, @inpman
		
		
		@ui_state_manager.pop(UI_State)
		
		@buildings = {}
		load_buildings
		
		## State data ##
		
		@EDITOR_STATE = :NONE
		@SELECTED_BUILDING = "$none$"
		
		@inpman.mode = :editor
	end
	
	def update
		@selected_cursor = :default
		
		super

		
		@compass.update
		@interface.update
	end
	
	def draw
		super()
		
		##super
        @compass.draw
        
		
		@interface.draw
		
		flush
		
		@cursor[@selected_cursor].draw	self.mouse_x-@cursor[@selected_cursor].width/2, 
										self.mouse_y-@cursor[@selected_cursor].height/2, 0
		
		if @show_framerate
			@font.draw "FPS: #{Gosu::fps}", 10,self.height-@font.height,10, 1,1, Gosu::Color::FUCHSIA
		end
	end
	
	def button_down(id)
        @inpman.button_down(id)
		
		case id
			when Gosu::KbEscape
				close
			when Gosu::KbF
				@show_framerate = !@show_framerate
		end
		
		@interface.button_down(id)
	end
	
	def button_up(id)
		@inpman.button_up(id)
		
        case id
            when Gosu::KbA
                super id
            when Gosu::KbZ
                @EDITOR_STATE = :NONE
        end
        
        @interface.button_up(id)
	end
	
	def needs_cursor?()
		false
	end
	
	private
	
    def load_buildings
		path = File.join "Levels", "Tutorial.txt"
		@count = 0
		File.open( path, "r" ).each do |line|
			args = line.split
			@buildings[ args[0] ] = {
				:size => [ args[1].to_f, args[2].to_f, args[3].to_f ],
				:textures => [ args[4], args[5] ]
			}
			#puts "recognized new building type #{args[0]}"
			@count += 1
		end
		puts "building count: #{@buildings.length}"
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
		end
		
	end
	
	def bind_menu_inputs
		@inpman.bind_action :menu_click, Gosu::MsLeft
	end
end

LevelEditor.new.show
