require 'state_machine'

class CameraController
	def initialize(camera)
		super()
		
		# zoom: 1.9600000000000106
		# pitch: 0.8945329251994334
		# property: 5.2299999999999525
		
		Machine.new(:zoom, 2.5, 0.01,
						:kb_pgdown, :kb_pgup) # increase in zoom factor causes camera to get further away
		Machine.new(:pitch, 10.degrees, 0.01,
						:kb_home, :kb_end)
		Machine.new(:property, 3, 0.01,
						:kb_insert, :kb_delete)
		
		@camera = camera
		
		camera_offset
	end
	
	# Metacode dependent on the machines array defined above
	def update(dt, player)
		# Compute camera offset
		needs_update = false
		Machine.all.each do |name, machine|
			needs_update ||= machine.update
			
			# puts "#{name}: #{machine.value}"
		end
		
		if needs_update
			# puts "UPDATING"
			
			camera_offset
			
			# Orient camera towards the player
			# NOTE: Oni::Camera#look_at can cause unexpected camera shake, due to problems with floating point precision used for position.  Best to not call every frame.
			# may want to create Oni::Camera#set_auto_tracking instead
			#  -- Ogre defines setAutoTracking to turn towards the tracked entity every frame
			player_pos = [
				player.physics.body.p.x,
				player.physics.body.pz,
				-player.physics.body.p.y
			]
			player_pos.collect! do |i|
				i.round 1
			end
			@camera.look_at player_pos
		end
		
		
		pos = @offset.clone
		pos[0] += player.physics.body.p.x
		pos[1] += player.physics.body.pz
		pos[2] += -player.physics.body.p.y
		
		@camera.position = pos
	end
	
	[:button_down, :button_up].each do |method_name|
		define_method method_name do |sym|
			Machine.all.each do |name, machine|
				machine.send method_name, sym
			end
		end
	end
	
	def camera_offset
		# puts "=======OFFSET"
		
		zoom =Machine.all[:zoom].value
		pitch = Machine.all[:pitch].value
		property = Machine.all[:property].value
		
		# r = 3*zoom*Math.cos(pitch)
		r = property*zoom*Math.cos(pitch)
		angle = 17.degrees
		
		x = r*Math.sin(angle)
		z = r*Math.cos(angle)
		
		# pitch = 10.degrees
		r = 3.5*zoom
		y = r*Math.sin(pitch)
		
		@offset = [x,y,z]
	end
	
	def set_offset(player_pos)
		# Set camera offset
		
	end
	
	private
	
	class Machine
		attr_reader :name
		attr_accessor :value, :factor
		
		def initialize(name, property_value, growth_factor, increase_binding, decrease_binding)
			super()
			@name = name
			
			@value = property_value
			@factor = growth_factor
			
			# Key bindings to trigger increase and decrease events
			@increase_binding = increase_binding
			@decrease_binding = decrease_binding
			
			@@all ||= Hash.new
			@@all[@name] = self
		end
		
		class << self
			def all
				@@all
			end
		end
		
		def button_down(sym)
			if sym == @increase_binding
				increase
			elsif sym == @decrease_binding
				decrease
			end
		end
		
		def button_up(sym)
			if sym == @increase_binding || sym == @decrease_binding
				reset
			end
		end
		
		state_machine :state, :initial => :idle do
			state :idle do
				define_method :update do
					@value
					
					return false
				end
			end
			
			state :increasing do
				define_method :update do
					@value += @factor
					
					puts "INCREASE #{@name}: #{@value}"
					
					return true
				end
			end
			
			state :decreasing do
				define_method :update do
					@value -= @factor
					
					puts "DECREASE #{@name}: #{@value}"
					
					return true
				end
			end
			
			
			# transition callbacks here
			
			
			event :increase do
				transition any => :increasing
			end
			
			event :decrease do
				transition any => :decreasing
			end
			
			event :reset do
				transition any => :idle
			end
		end
	end
end