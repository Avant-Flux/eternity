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
		
		
		@inpman.mode = :editor
	end
	
	def update
		
		
		super

		@selected_cursor = :default
		@inpman.mode = :editor
		
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
end

LevelEditor.new.show
