#!/usr/bin/ruby

begin
  # In case you use Gosu via rubygems.
  require 'rubygems'
rescue LoadError
  # In case you don't.
end
begin
	require 'lib/gosu'
rescue LoadError
	require 'gosu'
end
require 'chingu'

require 'require_all'
#~ require 'profile'
require 'chipmunk'
require_all './Chipmunk'
require_all './GameObjects'
require_all './Utilities'
require_all './Drawing'
require_all './UI'

class Game_Window < Gosu::Window
	def initialize
		super(1100, 688, false)
		self.caption = "Project ETERNITY"
		$window = self
		$art_manager = ArtManager.new("./Sprites")
		
		#Create a variable to use to track the time elapsed in between frames.
		#This value is stored in seconds
		@@time_before = Gosu::milliseconds
		$dt = compute_dt
		
		@fpscounter = FPSCounter.new
		@inpman = InputHandler.new do
			new_action :up, [Gosu::KbUp]
			new_action :down, [Gosu::KbDown]
			new_action:left, [Gosu::KbLeft]
			new_action :right, [Gosu::KbRight]
			
			new_action :jump, [Gosu::KbE]
	
			new_action :run, [Gosu::KbLeftShift]
			
			new_chord :super, [Gosu::KbLeftShift, Gosu::KbU]
			new_sequence :super2, [Gosu::KbLeftShift, Gosu::KbP]
			new_combo :super3, [Gosu::KbQ, Gosu::KbJ, Gosu::KbK], [1000, 500, 200]
		end
		
		$space = init_CP_Space3D
		
		Building.new(:dimensions => [5, 6.5, 2], :position => [6, 11, 0])
		Building.new(:dimensions => [3, 3, 1], :position => [8, 14, 0])
		
		Building.new(:dimensions => [5, 6.5, 2], :position => [15, 11, 0])
		Building.new(:dimensions => [5, 6.5, 4], :position => [20, 11, 0])
		Building.new(:dimensions => [5, 3, 2], :position => [20, 14, 0])
		Building.new(:dimensions => [5, 6.5, 2], :position => [25, 11, 0])
		Building.new(:dimensions => [5, 6.5, 2], :position => [20, 11-6.5, 0])
		
		Building.new(:dimensions => [5, 6.5, 2], :position => [15-50, 11, 0])
		Building.new(:dimensions => [5, 6.5, 4], :position => [20-50, 11, 0])
		Building.new(:dimensions => [5, 3, 2], :position => [20-50, 14, 0])
		Building.new(:dimensions => [5, 6.5, 2], :position => [25-50, 11, 0])
		Building.new(:dimensions => [5, 6.5, 2], :position => [20-50, 11-6.5, 0])
		
		Building.new(:dimensions => [5, 6.5, 2], :position => [15, 11-50, 0])
		Building.new(:dimensions => [5, 6.5, 4], :position => [20, 11-50, 0])
		Building.new(:dimensions => [5, 3, 2], :position => [20, 14, 0])
		Building.new(:dimensions => [5, 6.5, 2], :position => [25, 11-50, 0])
		Building.new(:dimensions => [5, 6.5, 2], :position => [20, 11-6.5-50, 0])
		
		Building.new(:dimensions => [5, 6.5, 2], :position => [15, 11+50, 0])
		Building.new(:dimensions => [5, 6.5, 4], :position => [20, 11+50, 0])
		Building.new(:dimensions => [5, 3, 2], :position => [20, 14+50, 0])
		Building.new(:dimensions => [5, 6.5, 2], :position => [25, 11+50, 0])
		Building.new(:dimensions => [5, 6.5, 2], :position => [20, 11-6.5+50, 0])
		
		@player = Player.new("Raven", [5, 5, 0])
		@characters = Array.new
		20.times do |i|
			x = (i * 3) % 8 + 1
			y = (i * 10) % 6 + 1
			
			@characters << Character.new("NPC", [x, y, 0])
		end
		@player.track(@characters[0])
		@player.track(@characters[9])
		@player.track(@characters[12])
		@player.track(@characters[3])
		@player.track(@characters[18])
		
		@characters[0].say "hello world"
		@characters[2].say "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin eleifend lacus quis dolor semper a faucibus nulla pharetra. Fusce venenatis posuere libero, aliquam malesuada lectus tempus nec. Donec vel dapibus magna. Quisque iaculis enim nec eros pharetra placerat. Sed enim metus, lobortis sed varius quis, interdum ac libero. Vivamus risus."
		
		@UI = UI::Overlay::Status.new(@player)
		$camera = Camera.new(@player)
		
		#@effect = Animations::Effect.new($window, "Gale")
		#~ @background = Background.new($window,"Sprites/Textures/grass_texture2.png")
		@i = 0
	end
	
	def update
		$dt = compute_dt
		@fpscounter.update
		@UI.update
		#~ @effect.update
		#~ puts @characters[1].elevation
		#~ puts @player.elevation
		SpeechBubble.update_all
		
		$camera.update
		$space.shapes[:nonstatic].each do |shape|
			shape.body.reset_forces
		end
		
		@inpman.update
		process_input
		
		$space.shapes[:nonstatic].each do |shape|
			shape.entity.update
		end
		$space.shapes[:static].each do |shape|
			shape.entity.update
		end
		
		#~ puts "#{@player.position} + #{@player.elevation}"
		#~ puts @player.shape.body.f
		
		$space.step
	end
	
	def draw
		@fpscounter.draw
		@UI.draw
		
		translate(-$camera.x.to_px, -$camera.y.to_px) do
			#~ @background.draw
			#~ @effect.draw(500,60,3)
			SpeechBubble.draw_all
			
			$camera.queue.each do |i|
				i.draw
			end
			#~ @characters[0].say("hello world")
		end
	end
	
	def button_down(id)
		@inpman.button_down(id)
		
		if id == Gosu::KbEscape
			close
		end
		if id == Gosu::KbF
			@fpscounter.toggle
		end
		#~ puts button_id_to_char id
		#~ puts id
	end
	
	def button_up(id)
		@inpman.button_up(id)
	end
	
	private
	
	def init_CP_Space3D
		space = CP::Space3D.new
		
		#~ space.add_collision_func :type, :type do |first_shape, second_shape|
			#~ 
		#~ end
		
		entity_handler = CollisionHandler::Entity.new
		entity_env_handler = CollisionHandler::Entity_Env.new
		camera_collision = CollisionHandler::Camera.new

		space.add_collision_handler :entity, :environment, entity_env_handler
		space.add_collision_handler :entity, :building, entity_env_handler
		space.add_collision_handler :entity, :entity, entity_handler
		
		space.add_collision_handler :camera, :entity, camera_collision
		space.add_collision_handler :camera, :building, camera_collision
		
		return space
	end
		
	def process_input
		dir = @inpman.direction
		if dir != nil
			if @inpman.active? :run
				@player.run
			else
				@player.walk
			end
			
			@player.move dir
		end
		
		if @inpman.active?(:jump)
			@player.jump
		end
		
		if @inpman.active?(:super) || @inpman.active?(:super2) || @inpman.active?(:super3)
			puts "BAM!#{@i += 1}"
		end
	end
	
	def save_keybindings
		
	end
	
	def load_keybindings
		
	end
	
	def compute_dt
		time = Gosu::milliseconds
		dt = time - @@time_before
		@@time_before = time
		#~ return dt
		dt /= 1000.0 #convert from milliseconds to seconds
	end
end

class InputHandler
	def direction
		up =	active? :up
		down =	active? :down
		left =	active? :left
		right =	active? :right
		
		result =	if up && left
						:up_left
					elsif up && right
						:up_right
					elsif down && left
						:down_left
					elsif down && right
						:down_right
					elsif up
						:up
					elsif down
						:down
					elsif left
						:left
					elsif right
						:right
					else
						nil #No button for direction pressed
					end

		result
	end
end

class Numeric
	def to_seconds
		self / 1000
	end
end

Game_Window.new.show
