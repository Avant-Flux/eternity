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
require './Chipmunk/Shape'
require_all './Physics'
require_all './GameObjects'
require_all './Utilities'
require_all './Drawing'
require_all './UI'

class Game_Window < Gosu::Window
	def initialize
		fps = 60
		super(1100, 688, false, (1.0/fps)*1000)
		self.caption = "Project ETERNITY"
		$window = self
		$art_manager = ArtManager.new("./Sprites")
		@font = Gosu::Font.new($window, "Trebuchet MS", 25)
		@show_fps = false
		
		$space = init_space
		
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
				
		#~ Building.new(:dimensions => [5, 6.5, 2], :position => [6, 11, 0])
		#~ Building.new(:dimensions => [3, 3, 1], :position => [8, 14, 0])
		
		#~ Building.new(:dimensions => [5, 6.5, 2], :position => [15, 11, 0])
		#~ Building.new(:dimensions => [5, 6.5, 4], :position => [20, 11, 0])
		#~ Building.new(:dimensions => [5, 3, 2], :position => [20, 14, 0])
		#~ Building.new(:dimensions => [5, 6.5, 2], :position => [25, 11, 0])
		#~ Building.new(:dimensions => [5, 6.5, 2], :position => [20, 11-6.5, 0])
		#~ 
		#~ Building.new(:dimensions => [5, 6.5, 2], :position => [15-50, 11, 0])
		#~ Building.new(:dimensions => [5, 6.5, 4], :position => [20-50, 11, 0])
		#~ Building.new(:dimensions => [5, 3, 2], :position => [20-50, 14, 0])
		#~ Building.new(:dimensions => [5, 6.5, 2], :position => [25-50, 11, 0])
		#~ Building.new(:dimensions => [5, 6.5, 2], :position => [20-50, 11-6.5, 0])
		#~ 
		#~ Building.new(:dimensions => [5, 6.5, 2], :position => [15, 11-50, 0])
		#~ Building.new(:dimensions => [5, 6.5, 4], :position => [20, 11-50, 0])
		#~ Building.new(:dimensions => [5, 3, 2], :position => [20, 14, 0])
		#~ Building.new(:dimensions => [5, 6.5, 2], :position => [25, 11-50, 0])
		#~ Building.new(:dimensions => [5, 6.5, 2], :position => [20, 11-6.5-50, 0])
		#~ 
		#~ Building.new(:dimensions => [5, 6.5, 2], :position => [15, 11+50, 0])
		#~ Building.new(:dimensions => [5, 6.5, 4], :position => [20, 11+50, 0])
		#~ Building.new(:dimensions => [5, 3, 2], :position => [20, 14+50, 0])
		#~ Building.new(:dimensions => [5, 6.5, 2], :position => [25, 11+50, 0])
		#~ Building.new(:dimensions => [5, 6.5, 2], :position => [20, 11-6.5+50, 0])
		
		@player = Player.new("Raven", [5, 5, 0])
		@characters = Array.new
		20.times do |i|
			x = (i * 3) % 8 + 1
			y = (i * 10) % 6 + 1
			
			@characters << Character.new("NPC", [x, y, 0])
		end
		#~ @player.track(@characters[0])
		#~ @player.track(@characters[9])
		#~ @player.track(@characters[12])
		#~ @player.track(@characters[3])
		#~ @player.track(@characters[18])
		
		#~ @characters[0].say "hello world"
		#~ @characters[2].say "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin eleifend lacus quis dolor semper a faucibus nulla pharetra. Fusce venenatis posuere libero, aliquam malesuada lectus tempus nec. Donec vel dapibus magna. Quisque iaculis enim nec eros pharetra placerat. Sed enim metus, lobortis sed varius quis, interdum ac libero. Vivamus risus."
		
		#~ @UI = UI::Overlay::Status.new(@player)
		#~ $camera = Camera.new(@player)
		
		#@effect = Animations::Effect.new($window, "Gale")
		#~ @background = Background.new($window,"Sprites/Textures/grass_texture2.png")
		@i = 0
	end
	
	def update
		#~ @UI.update
		#~ @effect.update
		#~ puts @characters[1].elevation
		#~ puts @player.elevation
		#~ SpeechBubble.update_all
		
		#~ puts @player.position
		#~ puts @player.physics.a
		@player.physics.reset_forces
		@player.update
		#~ puts "#{@player.x}, #{@player.y}, #{@player.z} : #{@player.physics.py}, #{@player.physics.pxz.y}"
		#~ printf "%.3f %.3f %.3f : %.3f %.3f\n", @player.x,@player.y,@player.z,@player.physics.py,@player.physics.pxz.y
		#~ printf "%.3f %.3f %.3f\n", @player.physics.vx, @player.physics.vy, @player.physics.vz
		#~ printf "%.3f %.3f %.3f\n", @player.physics.pxy.y, @player.physics.pxz.y, @player.physics.pz
		#~ puts @player.physics.vxy == @player.physics.vxy
		
		#~ $camera.update
		#~ $space.shapes[:nonstatic].each do |shape|
			#~ shape.body.reset_forces
		#~ end
		
		@inpman.update
		process_input
		
		#~ $space.shapes[:nonstatic].each do |shape|
			#~ shape.entity.update
		#~ end
		#~ $space.shapes[:static].each do |shape|
			#~ shape.entity.update
		#~ end
		
		#~ puts "#{@player.position} + #{@player.elevation}"
		#~ puts @player.shape.body.f
		
		$space.step
	end
	
	def draw
		@font.draw "FPS: #{Gosu::fps}", 0, 0, 9999 if @show_fps
		
		#~ @UI.draw
		#~ 
		translate(-@player.x.to_px + self.width/2, -@player.y.to_px + self.height/2) do
			@player.draw
			@characters.each {|i| i.draw}
		#~ translate(-$camera.x.to_px, -$camera.y.to_px) do
			#~ SpeechBubble.draw_all
			#~ 
			#~ $camera.queue.each do |i|
				#~ i.draw
			#~ end
		end
	end
	
	def button_down(id)
		@inpman.button_down(id)
		
		if id == Gosu::KbEscape
			close
		end
		if id == Gosu::KbF
			@show_fps = !@show_fps
		end
		#~ puts button_id_to_char id
		#~ puts id
	end
	
	def button_up(id)
		@inpman.button_up(id)
	end
	
	private
	
	def init_space
		space = Physics::Space.new 1/60.0, -9.8, 0.12
		
		entity_handler = CollisionHandler::Entity.new
		entity_env_handler = CollisionHandler::Entity_Env.new
		camera_collision = CollisionHandler::Camera.new

		space.add_collision_handler :entity, :environment, entity_env_handler
		space.add_collision_handler :entity, :building, entity_env_handler
		space.add_collision_handler :entity, :entity, entity_handler
		
		space.add_collision_handler :camera, :render_object, camera_collision
		
		space.add_collision_func :render_object, :render_object, :begin do |arbiter|
			false
		end
		
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
