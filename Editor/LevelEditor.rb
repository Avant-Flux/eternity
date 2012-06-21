#!/usr/bin/ruby
path = File.expand_path File.dirname(__FILE__)
path = path[0..(path.rindex(File::SEPARATOR)-1)]
Dir.chdir path

require './GameWindow'
##require './Editor/LE_UI_State'
require_all './Editor/LevelEditor_lib'

class LevelEditor < GameWindow
    
    
	def initialize
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
        
        @ui_state_manager.pop
        
        @buildings = {}
        load_buildings
        
        ## State data ##
        
        @EDITOR_STATE = :NONE
        @SELECTED_BUILDING = "$none$"
	end
	
	def update
		super
        
        case @EDITOR_STATE
            # Placing buildings, NPCs, and spawn points may have different cursors in the future
            when :NONE
                @selected_cursor = :default
            when :PLACING_BUILDING
                @selected_cursor = :place
            when :PLACING_NPC
                @selected_cursor = :place
            when :PLACING_SPAWN
                @selected_cursor = :place
            when :BOX
                @selected_cursor = :box
        end
	end
    
    def switch_state( state_id )
        nil
    end
	
	def draw
		#~ super
        
		if @selected_cursor == :box # right click active
			@camera.draw_trimetric do
				r = 20.to_meters
				draw_circle	0,0,0,
							r, Gosu::Color::FUCHSIA,
							:stroke_width => r
			end
		end
		
		super()
        
        @ui_state_manager.draw
        
        draw_screen
		
		#~ if @selected_cursor == :place # left click active
			#~ r = 20
			#~ draw_circle	self.mouse_x,self.mouse_y,0,
						#~ r, Gosu::Color::FUCHSIA,
						#~ :stroke_width => r
		#~ end
	end
	
	def button_down(id)
        #~ @inpman.button_down(id)
		
        case id
            when Gosu::KbEscape
                super id
            when Gosu::KbF
                super id
            when Gosu::KbA
                super id
            when Gosu::KbZ
                @EDITOR_STATE = :PLACING_BUILDING
            when Gosu::MsLeft
                if @EDITOR_STATE == :PLACING_BUILDING
                    click_scene
                end
            when Gosu::MsRight
        end
        
		#~ if id == Gosu::MsLeft
		#~ 	@selected_cursor = :place if @selected_cursor == :default
		#~ 	
		#~ 	click_UI
		#~ elsif id == Gosu::MsRight
		#~ 	@selected_cursor = :box if @selected_cursor == :default
		#~ 	
		#~ 	click_scene
		#~ end
	end
	
	def button_up(id)
		#~ @inpman.button_up(id)
		
        case id
            when Gosu::KbA
                super id
            when Gosu::KbZ
                @EDITOR_STATE = :NONE
            when Gosu::MsLeft
            when Gosu::MsRight
        end
        
		#~ if id == Gosu::MsLeft
		#~ 	if @selected_cursor == :place # left click active
		#~ 		@selected_cursor = :default
		#~ 	end
		#~ elsif id == Gosu::MsRight
		#~ 	if @selected_cursor == :box # right click active
		#~ 		@selected_cursor = :default
		#~ 	end
		#~ end
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
        
		case @EDITOR_STATE
            when :NONE
                #~ Remove print later; debug only
                puts "no state"
            when :PLACING_BUILDING
                # Temporary variable values
                @SELECTED_BUILDING = "buildingA"
                
                # TODO: x,y,z to be set with raytrace
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
        path = File.join "Levels", "Buildings.txt"
        
        File.open( path, "r" ).each do |line|
            args = line.split
            @buildings[ args[0] ] = {
                                        :size => [ args[1].to_f, args[2].to_f, args[3].to_f ],
                                        :textures => [ args[4], args[5] ]
                                    }
            puts "recognized new building type #{args[0]}"
        end
    end
end

LevelEditor.new.show
