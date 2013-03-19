require 'state_machine'

class InputHandler
	private # The contents of this file are a part of the InputHandler composite
	
	#Hold methods common to all classes under the InputType module
	class BasicInput
		attr_reader :name
		
		def initialize(name, &block)
			super()
			
			# Only necessary if name identifier must be contained in this class
			# If instance of this class will always be managed by an external class, then this may be unnecessary
			@name = name
			
			# Define callbacks in DSL
			# instace_eval &block if block_given?
			# yield self
			block.call self
			
			# puts "============INIT"
			# p @active_callback
			# p @inactive_callback
			# p @rising_edge_callback
			# p @falling_edge_callback
			# puts "=============="
			
			# Use blank lambdas as null objects
			@active_callback ||= lambda {}
			@inactive_callback ||= lambda {}
			@rising_edge_callback ||= lambda {}
			@falling_edge_callback ||= lambda {}
		end
		
		def button_down(id)
			# If a button is depressed, check if it pertains to this action
			
			if id == @trigger
				self.activate
			end
		end
		
		def button_up(id)
			# If any of the inputs being tracked deactivates, reset
			if id == @trigger
				self.deactivate
			end
		end
		
		# private :while_active, :while_idle, :on_rising_edge, :on_falling_edge
		def while_active(&block)
			@active_callback = block
		end
		
		def while_idle(&block)
			@inactive_callback = block
		end
		
		def on_rising_edge(&block)
			puts "def callback"
			@rising_edge_callback = block
		end
		
		def on_falling_edge(&block)
			@falling_edge_callback = block
		end
		
		# Return true when required inputs have been activated
		def complete(id)
			return id == @trigger
		end
		
		
		state_machine :state, :initial => :inactive do
			# Waiting to be triggered
			state :inactive do
				def update
					@inactive_callback.call
				end
			end
			
			# Triggered
			state :active do
				def update
					@active_callback.call
				end
			end
			
			# Will not be triggered
			state :disabled do
				def update
					nil # DO NOTHING
				end
			end
			
			
			before_transition :inactive => :active, :do => :rising_edge
			before_transition :active => :inactive, :do => :falling_edge
			
			after_transition :disabled => :inactive, :do => :reset
			
			
			event :activate do
				transition :inactive => :active
			end
			
			event :deactivate do
				transition :active => :inactive
			end
			
			event :disable do
				transition any => :disabled
			end
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
		
		# Return the current keybinding
		# To be used for debug purposes only
		def binding
			return @trigger
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
		
		def rising_edge
			@rising_edge_callback.call
		end
		
		def falling_edge
			@falling_edge_callback.call
		end
	end
	
	# An action can be mapped to multiple inputs.
	# If any one input is activated, the action should fire.
	class Action < BasicInput
		def initialize(name, &block)
			super(name, &block)
		end
		
		# def update
		# 	if 
		# 		super
		# 	end
		# end
		
		# def deactivate
		# 	@active = false
		# 	@buttons.delete @trigger
		# end
	end
	
	
	# Common ancestor of all input processing classes which require multiple inputs to activate.
	# Should NEVER be instantiated. Only exists to house common code.
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
	
	# Sequences require multiple inputs to activate.
	# Inputs must be activated with a certain spacing between each input.
	# Sequences are only active momentarily, starting when the final input is processed.
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
	
	# Chords require multiple inputs to activate.
	# Chords should only be active while ALL inputs are active.
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
