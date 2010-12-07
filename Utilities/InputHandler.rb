# File created by
#	Chad Godsey
#	Feb 21, 2010
#Modified by Raven
#
#	InputHandler class
#		used to manage button mappings to several types of high level input
#			simple named actions
#			chords - multiple buttons at once
#			sequences - combos
#	Now, if user defines def_kb_bindings, that method will be called on init.
begin
  # In case you use Gosu via RubyGems.
  require 'rubygems'
rescue LoadError
  # In case you don't.
end
require 'gosu'

class InputHandler
	def initialize()
		@event_handlers = []
		
		def_kb_bindings
	end
	
	def def_kb_bindings
	end
	
	def new_action(name, buttons=[])
		@event_handlers << InputType::Action.new(name, buttons)
	end
	
	def new_sequence(name, buttons=[], threshold=InputType::Sequence::DEFAULT_THRESHOLD)
		@event_handlers << InputType::Sequence.new(name, buttons, threshold)
	end
	
	def new_chord(name, buttons=[], threshold=InputType::Chord::DEFAULT_THRESHOLD)
		@event_handlers << InputType::Chord.new(name, buttons, threshold)
	end
	
	def new_combo(name, buttons=[], threshold=InputType::Combo::DEFAULT_THRESHOLD)
		@event_handlers << InputType::Combo.new(name, buttons, threshold)
	end
	
	def button_down(id)
		@event_handlers.each do |i|
			i.button_down id
		end
	end
	
	def button_up(id)
		@event_handlers.each do |i|
			i.button_up id
		end
	end
	
	def update
		@event_handlers.each do |i|
			i.update
		end
	end
	
	def active?(name)
		@event_handlers.each do |i|
			if i.name == name
				return i.active?
			end
		end
	end
end

module InputType
	#Hold methods common to all classes under the InputType module
	class BasicInput
		attr_accessor :name, :buttons, :state
		
		def initialize(name, buttons=[])
			@name = name
			@buttons = buttons
			@state = :idle
		end
		
		def active?
			@state == :active
		end
	end
	
	#Hold methods common to all classes  that require multiple button presses.
	class MultiButtonInput < BasicInput
		attr_accessor :threshold
	
		def initialize(name, buttons, threshold)
			super(name, buttons)
			@threshold = threshold
			
			@active = []
			update_time
			
			buttons.size.times do
				@active << false
			end
		end
		
		def button_up(id)
			reset if @buttons.include?(id)
			@state = :finish
		end
		
		def update
			#Update the state
			@state = case @state
				when :begin
					:active
				when :finish
					reset
					:idle
				when :process
					if timeout #Invalidate the sequence if too much time has passed.
						reset
						:idle
					else
						:process
					end
				else
					@state
			end
		end
		
		def reset
			@active.fill false
		end
		
		def timeout
			Gosu::milliseconds - @last_time > @threshold
		end
		
		def update_time
			@last_time = Gosu::milliseconds
		end
	end

	class Action < BasicInput
		def initialize(name, buttons=[]) #One action can have multiple buttons which trigger it
			super(name, buttons)
		end
		
		def button_down(id)
			@state = :begin if @buttons.include? id
		end
		
		def button_up(id)
			@state = :finish if @buttons.include? id
		end
		
		def update
			if @state == :begin
				@state = :active
			elsif @state == :finish
				@state = :idle
			end
		end
	end
	
	class Sequence < MultiButtonInput
		DEFAULT_THRESHOLD = 5000
		
		def initialize(name, buttons=[], threshold=DEFAULT_THRESHOLD)
			super(name, buttons, threshold)
		end
		
		def button_down(id)
			if i=@active.index(false) #Get the index of the next button in the sequence
				if @buttons[i] == id
					@active[i] = true 
					update_time
					@state = :process
				end
			end
			if @active.last == true
				#In this case, there are no more false values
				#ie, all the buttons in the sequence have been pressed
				@state = :begin
			end
		end
	end
	
	class Chord < MultiButtonInput
		DEFAULT_THRESHOLD = 20
		
		def initialize(name, buttons=[], threshold=DEFAULT_THRESHOLD)
			super(name, buttons, threshold)
		end
		
		def button_down(id)
			# Update chords
			
			#Get all the chords where the given button ID is part of that chord
			#Set the corresponding index of the "active" array to true
			#As one of the keys has been pressed, change the status to :process,
			#	and store the time of the button press
			if i = @buttons.index(id)
				@active[i] = true
				@state = :process
				update_time
				
				unless @active.include?(false)
					#At this point, all buttons have been pressed
					@state = :begin
				end
			end
		end
	end
	
	class Combo < MultiButtonInput
		DEFAULT_THRESHOLD = [1000]
		TIMING_BUFFER = 200 #Amount of milliseconds to buffer the target time on each side.
		#Change @threshold to pertain to the next button
		
		def initialize(name, buttons=[], threshold=DEFAULT_THRESHOLD)
			super(name, buttons, threshold[0])
			
			#@thresholds[0] is the time to wait in between button1 and button2
			@thresholds = threshold
			
			#Copy the last threshold value into other indexes of @thresholds
			unless @thresholds.size == @buttons.size
				max = @buttons.size-1
				min = @thresholds.size-1
				
				time = @thresholds[min]
				
				((min+1)..max).each do |i|
					@thresholds[i] = time
				end
			end
		end
		
		def button_down(id)
			if i = @active.index(false) #Get the index of the next button in the sequence
				if @buttons[i] == id #If this is the button you are looking for
					#If the time elapsed is within the desired timeframe
					if within_range	#only check if it is past the minimum time
									#update will check to make sure it is not over the max
						#then set the marker to true.
						#Then, get ready to receive the next input
						update_time
						
						@active[i] = true
						@threshold = @thresholds[i]
						
						@state = :process
					else 
						#else, if the time is outside the timeframe, reset
						#This basically means that the button was pressed too early
						#If it had been pressed too late, the problem would have been resolved by
						#the method #update
						@threshold = @thresholds[0]
						@state = :idle
						reset
					end
				end
			end
			
			#In this case, there are no more false values
			#ie, all the buttons in the combo have been pressed
			@state = :begin if @active.last == true
		end
		
		def button_up(id)
			#Needs to be left blank to override the method inherited.
		end
		
		def update
			#Allow timeout while @state is :active as well as :process
			#This allows the combo to time out after the last button is pressed.
			if @state == :active
				@state = :finish if timeout 
			end
			
			super
		end
		
		def timeout
			#make sure the time elapsed is not over the maximum wait time
			time_elapsed = Gosu::milliseconds - @last_time
			time_elapsed > @threshold + TIMING_BUFFER
		end
		
		def within_range
			#Return true if the time is at least passed the minimum time
			time_elapsed = Gosu::milliseconds - @last_time
			time_elapsed > @threshold - TIMING_BUFFER
		end
	end
end
