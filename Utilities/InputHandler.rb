#	Based on the InputHandler created by Chad Godsey, Feb 21, 2010
#	InputHandler class
#		manage button mappings to several types of high level input
#			simple named actions
#			chords - multiple buttons at once
#			sequences - combos
begin
  # In case you use Gosu via RubyGems.
  require 'rubygems'
rescue LoadError
  # In case you don't.
end
require 'gosu'

require 'set'

require './Utilities/InputType'

class InputHandler
	# Make sure that the input handlers can not be accessed outside of this class
	
	def initialize
		# Map event names to functions
		# Map keys to event names
		@modes = {}
		
		# The current mode
		@mode = nil
		
		# Set of buttons which are currently being pressed
		@buttons = Set.new
	end
	
	def mode=(mode)
		@modes[mode] ||= {:sequence => {}, :chord => {}, :flag => {}, :action => {}}
		@mode = @modes[mode]
		#~ @modes.each do |key, mode|
			#~ puts "#{key} --> #{mode}"
		#~ end
		#~ puts mode
	end
	
	def update
		#~ # puts
		@mode.each do |type, events|
			# puts type
			events.each do |name, handler|
				# puts "eval: #{name}"
				handler.update
			end
		end
		
		# Process movement
		#~ if :up
			#~ 
		#~ end
		#~ if :down
			#~ 
		#~ end
		#~ if :left
			#~ 
		#~ end
		#~ if :right
			#~ 
		#~ end
		
		# Process attacks
		#~ attack_command =	if :magic
								#~ 
							#~ elsif :left_hand
								#~ 
							#~ elsif :right_hand
								#~ 
							#~ end
		# Put the attack command sensors in one collection
		# If that collection is not empty, player is attacking
		# Then, create the attack_command variable and apply modifiers
		#~ if attacking?
			#~ attack_command = ""
			#~ 
			#~ # Create attack modifiers
			#~ attack_command <<	if intense
									#~ # Detect by if button is down or if force is currently being added
									#~ # Not quite sure how to do the latter
									#~ if moving?
										#~ "dash_"
									#~ else
										#~ "intense_"
									#~ end
								#~ end
								#~ 
			#~ attack_command <<	if hold
									#~ "hold_"
								#~ else #tap
									#~ "tap_"
								#~ end
			#~ 
			#~ attack_command <<	if in_air?
									#~ "arial_"
								#~ else
									#~ ""
								#~ end
			#~ 
			#~ # Get attack type
			#~ attack_command <<	if :magic
									#~ "magic"
								#~ elsif :left_hand
									#~ "left_hand"
								#~ elsif :right_hand
									#~ "right_hand"
								#~ end
			#~ @player.send attack_command.to_sym
		#~ end
		#~ 
		#~ 
		#~ 
		#~ if :magic
			#~ if :running
				#~ # same as below
			#~ elsif :in_air
				#~ # same as below
			#~ else
				#~ if :hold
					#~ if :intense
						#~ # Intense hold attack
					#~ else
						#~ # Intense attack
					#~ end
				#~ elsif :tap
					#~ if :intense
						#~ # Intense tap attack
					#~ else
						#~ # Tap attack
					#~ end
				#~ end
			#~ end
		#~ elsif :left_hand
			#~ 
		#~ elsif :right_hand
			#~ 
		#~ end
		
		
	end
	
	def hold_duration(event)
		@event_handlers[@mode][event].duration
	end
	
	def button_down(id)
		#~ puts "button #{id} down"
		@buttons.add id
	end
	
	def button_up(id)
		#~ puts "button #{id} up"
		@buttons.delete id
	end
	
	[:action, :chord, :sequence].each do |input_type|
		define_method "new_#{input_type}".to_sym do |name, type, &block|
			if @mode[input_type][name]
				@mode[input_type][name].functions[type] = block
			else
				klass = eval "InputType::#{input_type.capitalize}"
				@mode[input_type][name] = klass.new(@mode, @buttons, type => block)
			end
		end
		
		define_method "bind_#{input_type}".to_sym do |name, trigger|
			@mode[input_type][name].bind trigger
		end
		
		define_method "unbind_#{input_type}".to_sym do |name|
			@mode[input_type][name].unbind
		end
		
		define_method "rebind_#{input_type}".to_sym do |name, trigger|
			@mode[input_type][name].rebind trigger
		end
	end
	
	def new_flag
		#~ @mode[input_type] = InputType::Flag.new
	end
	
	#~ private
	#~ 
	#~ def process_input
		#~ 
	#~ end
end
