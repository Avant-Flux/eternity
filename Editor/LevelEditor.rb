#!/usr/bin/ruby
path = File.expand_path File.dirname(__FILE__)
path = path[0..(path.rindex(File::SEPARATOR)-1)]
Dir.chdir path

require './GameWindow'
##require './Editor/LE_UI_State'
require_all './Editor/LevelEditor_lib'

class LevelEditor < GameWindow
	def initialize
		super()
		self.caption = "Level Editor v0.00.1"
		
		@interface = LevelEditorInterface.new self, @space
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
		
		#if button_down? Gosu::MsLeft
		#	@state_manager.raycast_mouse do |shape| 
		#		
		#	end
		#end
		@interface.update
	end
	
	def switch_state( state_id )
		nil
	end
	
	def draw
		#~ super
		
		#if @selected_cursor == :box # right click active
			@camera.draw_trimetric do
				r = 2
				draw_circle *@state_manager.top.spawn,
							r, Gosu::Color::FUCHSIA,
							:stroke_width => r
			end
		#end
		
		if button_down? Gosu::MsMiddle
			@cur_mouse = @state_manager.raycast self.mouse_x,self.mouse_y
			dif_x = @cur_mouse.x - @pos_mouse.x
			dif_y = @cur_mouse.y - @pos_mouse.y

			@temp_var.body.p.x = @temp_var.body.p.x - dif_x
			@temp_var.body.p.y = @temp_var.body.p.y - dif_y

		end
		
		if button_down? Gosu::MsLeft
			unless button_down?(Gosu::KbLeftControl) || button_down?(Gosu::KbRightControl)
			

				@cur_mouse = @state_manager.raycast self.mouse_x,self.mouse_y
				dif_x = @cur_mouse.x - @pos_mouse.x
				dif_y = @cur_mouse.y - @pos_mouse.y

				@selected_building.body.p.x = @selected_building.body.p.x + dif_x
				@selected_building.body.p.y = @selected_building.body.p.y + dif_y
				
				@pos_mouse = @cur_mouse
			end
		end
		
		
		super()
		
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
                    mouse_down_scene
                end
            when Gosu::MsRight
        end
        
		if id == Gosu::MsLeft
		#@cur_mouse = @state_manager.raycast self.mouse_x,self.mouse_y
			@pos_mouse = @state_manager.raycast self.mouse_x,self.mouse_y
			@selected_cursor = :place if @selected_cursor == :default
			#mouse_down_UId
			closest_shape = nil
			@state_manager.raycast_mouse do |shape| 
					closest_shape ||= shape
					if shape.body.pz > closest_shape.body.pz
						closest_shape = shape
					end
					@selected_building = closest_shape				

			end
			
		elsif id == Gosu::MsRight
			@selected_cursor = :box if @selected_cursor == :default
			mouse_down_scene
			
		elsif id == Gosu::MsMiddle
			@pos_mouse = @state_manager.raycast self.mouse_x,self.mouse_y
			@pos_center = @state_manager.raycast self.width/2, self.height/2
			
			@temp_var = Entity.new self
			@temp_var.shape.collision_type = :none
			@temp_var.body.p = @pos_center
			
			@camera.followed_entity = @temp_var
			
		elsif id == Gosu::MsWheelDown
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
		#~ @inpman.button_up(id)
		
        case id
            when Gosu::KbA
                super id
            when Gosu::KbZ
                @EDITOR_STATE = :NONE
        end
        
		if id == Gosu::MsLeft
			if @selected_cursor == :place # left click active
				printf "mouse1"
				@selected_cursor = :default
				@selected_building = nil
			end
			@state_manager.rehash_space
		elsif id == Gosu::MsRight
			if @selected_cursor == :box # right click active
				print "mouse2"
				@selected_cursor = :default
			end
		elsif id == Gosu::MsMiddle
			@pos_center = @state_manager.raycast self.width/2, self.height/2
			@temp_var.body.p = @pos_center		
		
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
end

LevelEditor.new.show
