module InputType
	#Hold methods common to all classes under the InputType module
	class BasicInput
		attr_accessor :functions, :active
		
		def initialize(inputs, buttons, functions={})
			# Hash of all inputs within the same mode as this one
			@inputs = inputs
			# Set of currently depressed button ids
			@buttons = buttons
			
			# Store the functions to be called on 
			# rising edge, falling edge, active and idle
			@functions = functions
			
			@active = false
		end
		
		def active?
			@active
		end
		
		# Update the state of the handler.  The next signal
		# argument determines the state after the transition
		def update
			# Ideally #update would be a dynamically defined singleton
			# In that singleton method, the appropriate blocks would be
			# called if they had been defined on initialization
			state = next_state
			transition_to state
			@active = state
		end
		
		def bound?
			@trigger != nil
		end
		
		def bind(trigger)
			@trigger = trigger
		end
		
		def unbind
			super
			@all_triggers = nil
		end
		
		# In theory this is supposed to be different from bind
		# bind should add a new binding
		# rebind should erase all previous bindings and create a new binding
		# Thus, bind should be used when creating multiple triggers
		# 	for the same function.
		#~ def rebind(trigger)
			#~ unbind
			#~ bind trigger
		#~ end
		
		private
		
		def next_state
			if @trigger.is_a? Fixnum # aka Gosu::KbA.class
				return @buttons.include? @trigger
			else # Assume this is the name of another event
				@inputs.each_value do |input|
					if input.include? @trigger
						return input[@trigger].active?
					end
				end
			end
		end
		
		def transition_to(next_state)
			if @active
				if next_state
					# Active and still active
					@functions[:active].call if @functions[:active]
				else
					# Falling edge
					@functions[:falling_edge].call if @functions[:falling_edge]
				end
			else
				if next_state
					# Rising edge
					@functions[:rising_edge].call if @functions[:rising_edge]
				else
					# Nothing of importance
					@functions[:idle].call if @functions[:idle]
				end
			end
		end
	end
	
	class Action < BasicInput
		def initialize(inputs, buttons, functions={})
			super inputs, buttons, functions
		end
		
		def update
			#~ puts Gosu::milliseconds
			super
			
			#~ super set
			#~ super @trigger, :action
			#~ super bool
		end
		
		def deactivate
			@active = false
			@buttons.delete @trigger
		end
	end
	
	
	
	class MultiButtonInput < BasicInput
		def initialize(inputs, buttons, functions={})
			super inputs, buttons, functions
		end
		
		def bind(trigger)
			# The current element to be examined must be an element of trigger
			super trigger[0]
			@all_triggers = trigger
		end
		
		def unbind
			super
			@all_triggers = nil
		end
		
		private
		
		def transition_to(next_state)
			if @active
				if next_state
					# Active and still active
					if @functions[:active]
						reset_subfunctions
						@functions[:active].call
					end
				else
					# Falling edge
					if @functions[:falling_edge]
						reset_subfunctions
						@functions[:falling_edge].call
					end
				end
			else
				if next_state
					# Rising edge
					if @functions[:rising_edge]
						reset_subfunctions
						@functions[:rising_edge].call
						
					end
				else
					# Nothing of importance
					if @functions[:idle]
						reset_subfunctions
						@functions[:idle].call
					end
				end
			end
		end
		
		# Set all functions which are used as triggers for this one to false
		def reset_subfunctions
			@all_triggers.each do |trigger|
				@inputs.each_value do |active_inputs|
					if active_inputs[trigger] && trigger != @trigger
						puts "deactivating"
						active_inputs[trigger].deactivate
					end
				end
			end
		end
	end
	
	class Sequence < MultiButtonInput
		def initialize(inputs, buttons, functions={})
			super inputs, buttons, functions
			
			@i = 0
			@a = 0
		end
		
		def update
			@a += 1
			#~ puts @a
			#~ puts @buttons
			# Try to process as many additional triggers as possible on this step
			#~ puts Gosu::milliseconds
			#~ puts @trigger
			#~ begin
				@trigger = @all_triggers[@i]
				state = next_state
				
				#~ if state
					#~ if @i < @all_triggers.size
						#~ puts "loop"
						#~ @i += 1
					#~ end
				#~ else
					#~ if @i > 0
						#~ puts "decrement"
						#~ @i = @all_triggers.size-1
					#~ end
					#~ break
				#~ end
			#~ end while @i < @all_triggers.size
			
			if @i == @all_triggers.size-1
				#~ puts "transition" if state
				transition_to state
				unless state
					@i = 0
					#~ puts "hey #{@i}"
				end
			else
				if state
					state = false
					#~ puts "ho #{@i}"
					#~ @i = 0
					@i += 1
				else
					#~ puts "wut #{@i}"
					@i = 0
				end
			end
			
			@active = state
		end
	end
	
	class Chord < MultiButtonInput
		def initialize(inputs, buttons, functions={})
			super inputs, buttons, functions
		end
		
		def update
			state = nil # Identity element of the logic AND
			@all_triggers.each_with_index do |trigger, i|
				@trigger = trigger
				
				state = next_state
				break unless state # Short circuit
			end
			
			transition_to state
			@active = state
		end
	end
	
	# Hold should be classified as a flag
	class Hold
		
	end
end
