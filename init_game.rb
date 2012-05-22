#!/usr/bin/env ruby
Dir.chdir File.dirname(__FILE__)

require 'rubygems'
require "bundler/setup"

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
#~ require_all './GameStates'

#~ require_all './UI'

require 'gl'
require 'glu'

include Gl
include Glu


class Game_Window < Gosu::Window
	def initialize
		@target_fps = 60
		# Window should have a 16:9 aspect ratio
		super(1280, 720, false, (1.0/@target_fps)*1000)
		self.caption = "Eternity 0.11.0"
		
		@tile_width = 5
		@tile_height = 5
		
		@font = Gosu::Font.new self, "Trebuchet MS", 25
		
		@space = Physics::Space.new
		
		@player = Entity.new self
		
		@npcs = Array.new
		@npcs[0] = Entity.new self
		
		
		@entities = Array.new
		@entities.push @player
		@entities.push *@npcs
		
		
		@static_objects = Array.new
		@static_objects.push StaticObject.new self, [50,50,0], [0,0,0] # Main area
		
		@static_objects.push StaticObject.new self, [10,10,2], [-5,-5,0] # Raised spawn
		
		@static_objects.push StaticObject.new self, [30,10,3], [20,50,0] # First step
		@static_objects.push StaticObject.new self, [30,10,6], [20,60,0] # Second step
		
		@static_objects.push StaticObject.new self, [15,15,1], [0,16,6] # Floating platform
		@static_objects.push StaticObject.new self, [15,15,3], [15,16,0] # Step to floating platform
		
		@static_objects.each do |static|
			static.add_to @space
		end
		
		@entities.each do |entity|
			entity.add_to @space
		end
		
		@camera = Camera.new self
		@camera.followed_entity = @player
		
		@inpman = EternityInput.new @player, @camera
		#~ @inpman.bind_inputs
		
		@space.add_collision_handler :entity, :static, CollisionHandler::EntityEnv.new
	end
	
	def update
		# process_input
		@inpman.update
		
		@space.step
		#~ puts @player.body.p
		#~ @player.body.reset_forces
		@player.update
	end
	
	def draw
		@static_objects.each do |static|
			@camera.draw_trimetric static.pz+static.height do
				static.draw_trimetric
			end
		end
		
		# Draw shadows
		@entities.each do |entity|
			@camera.draw_trimetric entity.body.elevation do
				distance = entity.body.pz - entity.body.elevation
				a = 1 # Quadratic
				b = 1 # Linear
				c = 1 # Constant
				factor = (a*distance + b)*distance + c
				
				c = 1
				r = (entity.body.pz - entity.body.elevation + c)
				
				c = 1
				alpha = 1/factor
				self.draw_circle	entity.body.p.x, entity.body.p.y, entity.body.elevation,
									r,	Gosu::Color::BLACK,
									:stroke_width => r, :slices => 20, :alpha => alpha
			end
		end
		
		@camera.draw_trimetric do
			#~ draw_circle			@player.body.p.x,@player.body.p.y,0,	10,	Gosu::Color::RED
			
			draw_magic_circle	@player.body.p.x,@player.body.p.y,0
		end
		
		# Draw the entities themselves
		@camera.draw_billboarded do
			@entities.each do |entity|
				entity.draw
			end
		end
		
		@camera.flush
		
		
		# Draw UI etc (screen-relative "flat" elements)
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
		x_count.times do |x|
			y_count.times do |y|
				x_factor = x.to_f/x_count
				y_factor = y.to_f/y_count
				color = Gosu::Color.new 150, x_factor*255, y_factor*255, (x_factor+y_factor)*150+105
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
			:stroke_width => 1,	# Width of the line
			:slices => 30, # Number of subdivisions around the z axis.
			:loops => 1, # Number of concentric rings about the origin.
			
			:start_angle => 0,
			
			:alpha => 1 # Float value
		}.merge! options
		
		self.gl z do
			@quadric ||= gluNewQuadric()
			
			glEnable(GL_BLEND)
			glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
			
			glColor4f(color.red, color.green, color.blue, options[:alpha])
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
end



Game_Window.new.show
