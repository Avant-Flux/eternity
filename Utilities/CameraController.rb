require 'state_machine'

class CameraController
	# TODO: Create private classes for separate properties (ie, machines) so instance_varible_get does not have to be used.  May want to implement delegation first.
	
	# property :zoom, :in, :out
	# property :pitch, :up, :down
	
	s = Struct.new "Machine", :value, :increase, :decrease, :increase_binding, :decrease_binding
	machines = [
		s.new(:zoom, :out, :in, :kb_pgdown, :kb_pgup), # increase in zoom factor causes camera to get further away
		s.new(:pitch, :up, :down, :kb_home, :kb_end),
		s.new(:property, :in, :out, :kb_insert, :kb_delete)
	]
	
	def initialize(camera)
		super()
		
		@camera = camera
		
		@zoom = 2.5			# coefficient of distance
		@pitch = 10.degrees	# stored in radians
		@property = 3
		
		@zoom_factor = 0.01
		@pitch_factor = 0.01
		@property_factor = 0.01
		
		camera_offset
	end
	
	def camera_offset
		puts "=======OFFSET"
		
		r = 3*@zoom*Math.cos(@pitch)
		# r = @property*@zoom*Math.cos(@pitch)
		angle = 17.degrees
		
		x = r*Math.sin(angle)
		z = r*Math.cos(angle)
		
		# @pitch = 10.degrees
		r = 3.5*@zoom
		y = r*Math.sin(@pitch)
		
		@offset = [x,y,z]
	end
	
	def set_offset(player_pos)
		# Set camera offset
		pos = @offset.clone
		[0,1,2].each do |i|
			pos[i] += player_pos[i]
		end
		@camera.position = pos
	end
	
	# Metacode dependent on the machines array defined above
	define_method :update do |dt, player|
		# Compute camera offset
		needs_update = false
		machines.each do |machine|
			needs_update ||= send "update_#{machine.value}"
			
			puts "#{machine.value}: #{instance_variable_get "@#{machine.value}"}"
		end
		
		puts "UPDATING" if needs_update
		
		camera_offset if needs_update
		
		player_pos = [
			player.physics.body.p.x,
			player.physics.body.pz,
			-player.physics.body.p.y		
		]
		
		# Orient camera towards the player
		@camera.look_at player_pos
		
		set_offset player_pos
	end
	
	# Raise or lower value value as appropriate when specified keys are depressed
	define_method :button_down do |sym|
		machines.each do |machine|
			if sym == machine.increase_binding
				send "#{machine.value}_#{machine.increase}"
			elsif sym == machine.decrease_binding
				send "#{machine.value}_#{machine.decrease}"
			end
		end
	end
	
	# Reset values when corresponding buttons are released
	define_method :button_up do |sym|
		machines.each do |machine|
			if sym == machine.increase_binding || sym == machine.decrease_binding
				send "#{machine.value}_reset"
			end
		end
	end
	
	machines.each do |machine|
		attr_accessor "#{machine.value}_factor".to_sym
		
		state_machine "#{machine.value}_machine", :initial => :none do
			state :none do
				define_method "update_#{machine.value}" do
					value = instance_variable_get "@#{machine.value}"
					
					return false
				end
			end
			
			[machine.increase, machine.decrease].each do |value_change_state|
				operator =	if value_change_state == machine.increase
								:+
							else# value_change_state == machine.decrease
								:-
							end
				
				
				state value_change_state do
					define_method "update_#{machine.value}" do
						var_name = "@#{machine.value}"
						
						# Increment or decrement the value depending on value of "operator"
						# Operations performed LISP-style
						instance_variable_set(
							var_name,
							
							instance_variable_get(var_name).send(
								operator,
								instance_variable_get("@#{machine.value}_factor")
							)
						)
						
						puts "UPDATE #{machine.value} #{operator}"
						
						return true
					end
				end
			end
			
			# transition callbacks here
			
			
			event "#{machine.value}_#{machine.increase}".to_sym do
				transition any => machine.increase
			end
			
			event "#{machine.value}_#{machine.decrease}".to_sym do
				transition any => machine.decrease
			end
			
			event "#{machine.value}_reset".to_sym do
				transition any => :none
			end
		end
	end
end