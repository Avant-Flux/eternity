#!/usr/bin/env ruby
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
		
		@tile_width = 5
		@tile_height = 5
		
		@font = Gosu::Font.new(self, "Trebuchet MS", 25)
		
		@space = CP::Space.new
		@space.iterations = 10
		@space.damping = 0.2
		
		@player = Entity.new(self)
		@space.add_shape @player.shape
		@space.add_body @player.body
		
		@npcs = Array.new
		@npcs[0] = Entity.new(self)
		@npcs.each do |npc|
			@space.add_shape npc.shape
			@space.add_body npc.body
		end
		
		@camera = Camera.new(self)
		@camera.followed_entity = @player
		
		init_input_system
		bind_inputs
	end
	
	def update
		#~ process_input
		
		@inpman.update
		@space.step 1/60.0
		#~ puts @player.body.p
		#~ @player.body.reset_forces
		@player.update
	end
	
	def draw
		@camera.draw_trimetric do
			x_count = 10
			y_count = 10
			
			draw_world			x_count,y_count,	@tile_width,@tile_height, 0
			
			draw_circle			@player.body.p.x,@player.body.p.y,0,	200,	Gosu::Color::RED
			
			draw_magic_circle	@player.body.p.x,@player.body.p.y,0
		end
		#~ 
		@camera.draw_trimetric 3 do
			x_count = 3
			y_count = 3
			
			draw_world			x_count,y_count,	@tile_width,@tile_height, 3
		end
		
		@camera.draw_billboarded do
			@player.draw	Gosu::Color::RED
			@npcs.each do |npc|
				npc.draw	Gosu::Color::BLUE
			end
		end
		
		@camera.flush
		
		if @show_fps
			@font.draw "FPS: #{Gosu::fps}", 10,10,10, :color => Gosu::Color::FUCHSIA
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
		
		if id == Gosu::MsWheelDown
			@camera.zoom_in
		elsif id == Gosu::MsWheelUp
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
	
	def draw_world(x_count,y_count, tile_width,tile_height, z=0)
		(0..x_count).each do |x|
			(0..y_count).each do |y|
				x_factor = x.to_f/x_count
				y_factor = y.to_f/y_count
				color = Gosu::Color.new x_factor*255, y_factor*255, (x_factor+y_factor)*150+105
				#~ color = Gosu::Color::WHITE
				
				x_offset = x*tile_width
				y_offset = y*tile_width
				
				draw_tile	x_offset,y_offset,z,	tile_height,tile_width, color
				#~ position = CP::Vec2.new(x_offset, y_offset).to_screen
				#~ position1 = Physics::Direction::X_HAT * x_offset
				#~ position1 += Physics::Direction::Y_HAT * y_offset
				#~ 
				#~ position2 = Physics::Direction::X_HAT * (x_offset + tile_width)
				#~ position2 += Physics::Direction::Y_HAT * (y_offset + )
				#~ 
				#~ self.draw_quad	position1.x, position1.y, color,
								
			end
		end
		
		#~ color = Gosu::Color.new 255-z/20, 255-z/20, 255-z/20
		#~ self.draw_tile	0, 0, z, x_count*tile_width, y_count*tile_height, color
	end
	
	def draw_tile(x,y,z, height,width, color)
		# Use z position in meters for z-index
		self.draw_quad	x, y, color,
						x+width, y, color,
						x+width, y+height, color,
						x, y+height, color, z
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
	
	def draw_magic_circle(x,y,z)
		@magic_circle ||= Gosu::Image.new(self, "./Sprites/Effects/firecircle.png", false)
		@magic_circle_angle ||= 0
		if @magic_circle_angle > 360
			@magic_circle_angle = 0
		else
			@magic_circle_angle += 1
		end
		zoom = 0.01
		color = Gosu::Color::RED
		
		self.scale zoom,zoom, x,y do
			#~ self.translate -@magic_circle.width/2, -@magic_circle.height/2 do
				#~ @magic_circle.old_draw(x,y,z, 1,1, color)
				@magic_circle.draw_rot(x,y,z, @magic_circle_angle, 0.5,0.5, 1,1, color)
			#~ end
		end
	end
	
	def init_input_system
		@inpman = InputHandler.new
		
		@inpman.mode = :gameplay
		@inpman.new_action :up, :active do
			@player.body.apply_force CP::Vec2.new(0,10), CP::ZERO_VEC_2
		end
		@inpman.new_action :down, :active do
			@player.body.apply_force CP::Vec2.new(0,-10), CP::ZERO_VEC_2
		end
		@inpman.new_action :left, :active do
			@player.body.apply_force CP::Vec2.new(-10,0), CP::ZERO_VEC_2
		end
		@inpman.new_action :right, :active do
			@player.body.apply_force CP::Vec2.new(10,0), CP::ZERO_VEC_2
		end
		
		@inpman.new_action :jump, :rising_edge do
			@player.jump
		end
		
		# Camera control
		#~ @inpman.new_action :zoom_in, :rising_edge do
			#~ @camera.zoom_in
		#~ end
		#~ @inpman.new_action :zoom_out, :active do
			#~ @camera.zoom_out
		#~ end
		@inpman.new_action :zoom_reset, :rising_edge do
			@camera.zoom_reset
		end
	end
	
	def bind_inputs
		#TODO:	Change bind so there is only one bind method, which will search all input types
		#		and bind action appropriately.
		@inpman.bind_action :up, Gosu::KbUp
		@inpman.bind_action :down, Gosu::KbDown
		@inpman.bind_action :left, Gosu::KbLeft
		@inpman.bind_action :right, Gosu::KbRight
		
		@inpman.bind_action :jump, Gosu::KbSpace
		
		#~ @inpman.bind_action :zoom_in, Gosu::Kb1
		#~ @inpman.bind_action :zoom_out, Gosu::MsWheelDown
		#~ @inpman.bind_action :zoom_reset, Gosu::Kb0
	end
end



Game_Window.new.show
