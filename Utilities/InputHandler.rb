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
	
	def new_sequence(name, buttons=[], threshold=20)
		@event_handlers << InputType::Sequence.new(name, buttons, threshold)
	end
	
	def new_chord(name, buttons=[], threshold=100)
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
	class Action
		attr_accessor :name, :state, :buttons
	
		def initialize(name, buttons=[]) #One action can have multiple buttons which trigger it
			@name = name
			@state = :idle
			@buttons = buttons
		end
		
		def button_down(id)
			# Update actions
			#~ @actions.select{ |k,a| 
				#~ a[:buttons].include?(id) 
			#~ }.each{ |k,a| 
				#~ a[:state] = :begin
			#~ }
			
			@state = :begin if @buttons.include? id
		end
		
		def button_up(id)
			# Update actions
			#~ @actions.select{ |k,a| 
				#~ a[:buttons].include?(id) 
			#~ }.each{ |k,a| 
				#~ a[:state] = :finish
			#~ }
			
			@state = :finish if @buttons.include? id
		end
		
		def update
			# Update actions
			#~ @actions.each{ |k,a| 
				#~ if a[:state] == :begin
					#~ a[:state] = :active
				#~ elsif a[:state] == :finish
					#~ a[:state] = :idle
				#~ end
			#~ }
			
			if @state == :begin
				@state = :active
			elsif @state == :finish
				@state = :idle
			end
		end
		
		def active?
			@state == :active
		end
	end
	
	class Sequence
		attr_accessor :name, :state, :buttons, :active, :threshold
	
		def initialize(name, buttons=[], threshold=20)
			@name = name
			@state = :idle
			@buttons = buttons
			@active = []
			@threshold = threshold
			@last_time = Gosu::milliseconds
						
			@buttons.size.times do
				@active << false
			end
		end
		
		def button_down(id)
			if i = @active.index(false) #Get the index of the next button in the sequence
				@active[i] = true if @buttons[i] == id
				@last_time = Gosu::milliseconds
			else
				#In this case, there are no more false values
				#ie, all the buttons in the sequence have been pressed
				@state = :begin
			end
		end
		
		def button_up(id)
			
		end
		
		def update
			#Invalidate the sequence if too much time has passed.
			if timeout
				@state = :finish
				reset
			end
			
			#Update the state
			if @state == :begin
				@state = :active
			elsif @state == :finish
				@state = :idle
			end
		end
		
		def active?
			@state == :active
		end
		
		def reset
			@active.fill false
		end
		
		def timeout
			Gosu::milliseconds - @last_time > @threshold
		end
	end
	
	class Chord
		attr_accessor :name, :state, :buttons, :active, :time
	
		def initialize(name, buttons=[], threshold=20)
			@name = name
			@state = :idle
			@buttons = buttons
			@active = []
			
			@last_time = Gosu::milliseconds
			@threshold = threshold #Max time in milliseconds to wait between buttons in the chord
			
			buttons.size.times do
				@active << false
			end
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
		
		def button_up(id)
			# Invalidate chords
			reset if @buttons.include?(id)
			@state = :finish
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
		
		def active?
			@state == :active
		end
		
		def reset
			@active.fill false
		end
		
		def timeout
			Gosu::milliseconds - @last_time > @threshold
		end
	end
	
	class Combo
		attr_accessor :name, :buttons
		
		def initialize(name, buttons=[])
			@name = name
			@buttons = buttons
		end
		
		def button_down(id)
			
		end
		
		def button_up(id)
			
		end
		
		def update
			
		end
		
		def active?
			@state == :active
		end
		
		def reset
			@active.fill false
		end
	end
end
