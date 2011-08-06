module InputType
	#Hold methods common to all classes under the InputType module
	class BasicInput
		def initialize(inputs, buttons, trigger, functions={})
			# Hash of all inputs within the same mode as this one
			@inputs = inputs
			# Set of currently depressed button ids
			@buttons = buttons
			# Stores the things which much be triggered before this event fires
			@trigger = trigger
			
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
		
		[:begin?, :active?, :finish?, :idle?].each do |method|
			define_method method do
				# Take the question mark off the end
				sym = method.to_s[0..(method.length-2)].to_sym
				@state == sym
			end
		end
		
		private
		
		def next_state
			if @trigger.is_a? Fixnum # aka Gosu::KbA.class
				@buttons.include? @trigger
			else # Assume this is the name of another event
				@inputs.each_value do |input|
					if input.include? @trigger
						input[@trigger].active?
					end
				end
			end
		end
		
		def transition_to(next_state)
			if @active
				if next_state
					# Active and still active
					@function[:action].call if @function[:action]
				else
					# Falling edge
					@function[:falling_edge].call if @function[:falling_edge]
				end
			else
				if next_state
					# Rising edge
					@function[:rising_edge].call if @function[:rising_edge]
				else
					# Nothing of importance
					@function[:idle].call if @function[:idle]
				end
			end
		end
	end
	
	class Action < BasicInput
		def initialize(inputs, buttons, trigger, functions={})
			super inputs, buttons, trigger, functions
		end
		
		def update
			super
			
			#~ super set
			#~ super @trigger, :action
			#~ super bool
		end
	end
	
	
	
	class MultiButtonInput < BasicInput
		def initialize(inputs, buttons, trigger, current, functions={})
			# The current element to be examined must be an element of trigger
			
			super inputs, buttons, current, functions
			@all_triggers = trigger
		end
		
		def update
			@active = next_state
		end
	end
	
	class Sequence < MultiButtonInput
		def initialize(inputs, buttons, trigger, functions={})
			super inputs, buttons, trigger, trigger[0], functions
			@i = 0
		end
		
		def update
			state = next_state
			
			if @trigger == @all_triggers.last
				transition_to state
			end
			
			@active = state
		end
	end
	
	class Chord < MultiButtonInput
		def initialize(inputs, buttons, trigger, functions={})
			super inputs, buttons, trigger, nil, functions
		end
		
		def update
			state = true # Identity element of the logic AND
			@all_triggers.each do |trigger|
				@trigger = trigger
				
				state = state && next_state
				break unless state # Short circuit
			end
			
			transition_to state
		end
	end
	
	# Hold should be classified as a flag
	class Hold
		
	end
	
	
	#~ #Hold methods common to all classes  that require multiple button presses.
	#~ class MultiButtonInput < BasicInput
		#~ attr_accessor :threshold
	#~ 
		#~ def initialize(name, buttons, threshold)
			#~ super(name, buttons)
			#~ @threshold = threshold
			#~ 
			#~ @active = []
			#~ update_time
			#~ 
			#~ buttons.size.times do
				#~ @active << false
			#~ end
		#~ end
		#~ 
		#~ def button_up(id)
			#~ reset if @buttons.include?(id)
			#~ @state = :finish
		#~ end
		#~ 
		#~ def update
			#~ #Update the state
			#~ @state = case @state
				#~ when :begin
					#~ :active
				#~ when :finish
					#~ reset
					#~ :idle
				#~ when :process
					#~ if timeout #Invalidate the sequence if too much time has passed.
						#~ reset
						#~ :idle
					#~ else
						#~ :process
					#~ end
				#~ else
					#~ @state
			#~ end
		#~ end
		#~ 
		#~ def reset
			#~ @active.fill false
		#~ end
		#~ 
		#~ def timeout
			#~ Gosu::milliseconds - @last_time > @threshold
		#~ end
		#~ 
		#~ def update_time
			#~ @last_time = Gosu::milliseconds
		#~ end
	#~ end
#~ 
	#~ class Action < BasicInput
		#~ def initialize(name, buttons=[]) #One action can have multiple buttons which trigger it
			#~ super(name, buttons)
			#~ @start_time = Gosu::milliseconds
		#~ end
		#~ 
		#~ def button_down(id)
			#~ @state = :begin if @buttons.include? id
		#~ end
		#~ 
		#~ def button_up(id)
			#~ @state = :finish if @buttons.include? id
		#~ end
		#~ 
		#~ def update
			#~ if @state == :begin
				#~ @state = :active
				#~ reset
			#~ elsif @state == :finish
				#~ @state = :idle
			#~ end
		#~ end
		#~ 
		#~ def duration
			#~ current_time = Gosu::milliseconds
			#~ current_time - @start_time
		#~ end
		#~ 
		#~ private
		#~ 
		#~ def reset
			#~ @start_time = Gosu::milliseconds
		#~ end
	#~ end
	#~ 
	#~ class Sequence < MultiButtonInput
		#~ DEFAULT_THRESHOLD = 5000
		#~ 
		#~ def initialize(name, buttons=[], threshold=DEFAULT_THRESHOLD)
			#~ super(name, buttons, threshold)
		#~ end
		#~ 
		#~ def button_down(id)
			#~ if i=@active.index(false) #Get the index of the next button in the sequence
				#~ if @buttons[i] == id
					#~ @active[i] = true 
					#~ update_time
					#~ @state = :process
				#~ end
			#~ end
			#~ if @active.last == true
				#~ #In this case, there are no more false values
				#~ #ie, all the buttons in the sequence have been pressed
				#~ @state = :begin
			#~ end
		#~ end
	#~ end
	#~ 
	#~ class Chord < MultiButtonInput
		#~ DEFAULT_THRESHOLD = 20
		#~ 
		#~ def initialize(name, buttons=[], threshold=DEFAULT_THRESHOLD)
			#~ super(name, buttons, threshold)
		#~ end
		#~ 
		#~ def button_down(id)
			#~ # Update chords
			#~ 
			#~ #Get all the chords where the given button ID is part of that chord
			#~ #Set the corresponding index of the "active" array to true
			#~ #As one of the keys has been pressed, change the status to :process,
			#~ #	and store the time of the button press
			#~ if i = @buttons.index(id)
				#~ @active[i] = true
				#~ @state = :process
				#~ update_time
				#~ 
				#~ unless @active.include?(false)
					#~ #At this point, all buttons have been pressed
					#~ @state = :begin
				#~ end
			#~ end
		#~ end
	#~ end
	#~ 
	#~ class Combo < MultiButtonInput
		#~ DEFAULT_THRESHOLD = [1000]
		#~ TIMING_BUFFER = 1000 #Amount of milliseconds to buffer the target time on each side.
							#~ # Leave high for testing
		#~ #Change @threshold to pertain to the next button
		#~ 
		#~ def initialize(name, buttons=[], threshold=DEFAULT_THRESHOLD)
			#~ super(name, buttons, threshold[0])
			#~ 
			#~ #@thresholds[0] is the time to wait in between button1 and button2
			#~ @thresholds = threshold
			#~ 
			#~ #Copy the last threshold value into other indexes of @thresholds
			#~ unless @thresholds.size == @buttons.size
				#~ max = @buttons.size-1
				#~ min = @thresholds.size
				#~ 
				#~ time = @thresholds.last
				#~ 
				#~ (min..max).each do |i|
					#~ @thresholds[i] = time
				#~ end
			#~ end
		#~ end
		#~ 
		#~ def button_down(id)
			#~ if i = @active.index(false) #Get the index of the next button in the sequence
				#~ if @buttons[i] == id #If this is the button you are looking for
					#~ #If the time elapsed is within the desired timeframe
					#~ if within_range	#only check if it is past the minimum time
									#~ #update will check to make sure it is not over the max
						#~ #then set the marker to true.
						#~ #Then, get ready to receive the next input
						#~ update_time
						#~ 
						#~ @active[i] = true
						#~ @threshold = @thresholds[i]
						#~ 
						#~ @state = :process
					#~ else 
						#~ #else, if the time is outside the timeframe, reset
						#~ #This basically means that the button was pressed too early
						#~ #If it had been pressed too late, the problem would have been resolved by
						#~ #the method #update
						#~ @threshold = @thresholds[0]
						#~ @state = :idle
						#~ reset
					#~ end
				#~ end
			#~ end
			#~ 
			#~ #In this case, there are no more false values
			#~ #ie, all the buttons in the combo have been pressed
			#~ @state = :begin if @active.last == true
		#~ end
		#~ 
		#~ def button_up(id)
			#~ #Needs to be left blank to override the method inherited.
		#~ end
		#~ 
		#~ def update
			#~ #Allow timeout while @state is :active as well as :process
			#~ #This allows the combo to time out after the last button is pressed.
			#~ if @state == :active
				#~ @state = :idle if timeout 
			#~ end
			#~ 
			#~ super
		#~ end
		#~ 
		#~ def timeout
			#~ #make sure the time elapsed is not over the maximum wait time
			#~ time_elapsed = Gosu::milliseconds - @last_time
			#~ time_elapsed > @threshold + TIMING_BUFFER
		#~ end
		#~ 
		#~ def within_range
			#~ #Return true if the time is at least passed the minimum time
			#~ time_elapsed = Gosu::milliseconds - @last_time
			#~ time_elapsed > @threshold - TIMING_BUFFER
		#~ end
	#~ end
end
