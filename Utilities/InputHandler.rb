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
			@last_time = Gosu::milliseconds
			
			buttons.size.times do
				@active << false
			end
		end
		
		def button_up(id)
			reset if @buttons.include?(id)
			@state = :finish
		end
		
		def reset
			@active.fill false
		end
		
		def timeout
			Gosu::milliseconds - @last_time > @threshold
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
			if i = @active.index(false) #Get the index of the next button in the sequence
				if @buttons[i] == id
					@active[i] = true 
					@last_time = Gosu::milliseconds
					@state = :process
				end
			end
			if @active.last == true
				#In this case, there are no more false values
				#ie, all the buttons in the sequence have been pressed
				@state = :begin
			end
		end
		
		def update
			#Update the state
			@state = case @state
				when :begin
					:active
				when :finish
					:idle
				when :process
					if timeout #Invalidate the sequence if too much time has passed.
						puts "hey"
						:idle
					else
						:process
					end
				else
					@state
			end
			
			reset if @state == :idle
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
				@last_time = Gosu::milliseconds
				
				unless @active.include?(false)
					#At this point, all buttons have been pressed
					@state = :begin
				end
			end
		end
		
		def update
			# Update chords from end state to idle
			# Invalidate old chords
			
			if @state == :begin
				@state = :active
			elsif @state == :finish
				@state = :idle
			elsif @state == :process and timeout
										#More time has elapsed than allotted by timeout
				@state = :idle
			end
			
			reset if @state == :idle
		end
	end
	
	class Combo < MultiButtonInput
		#Change @threshold to pertain to the next button
	
		def initialize(name, buttons=[], threshold=[100])
			super(name, buttons, threshold[0])
		end
		
		def button_down(id)
			if i = @active.index(false) #Get the index of the next button in the sequence
				if @buttons[i] == id
					@active[i] = true 
					@last_time = Gosu::milliseconds
					@state = :process
				end
			end
			if @active.last == true
				#In this case, there are no more false values
				#ie, all the buttons in the sequence have been pressed
				@state = :begin
			end
		end
		
		def update
			#Update the state
			@state = case @state
				when :begin
					:active
				when :finish
					:idle
				when :process
					if timeout #Invalidate the sequence if too much time has passed.
						puts "hey"
						:idle
					else
						:process
					end
				else
					@state
			end
			
			reset if @state == :idle
		end
	end
end
