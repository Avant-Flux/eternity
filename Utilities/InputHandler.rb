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

require 'set'

require './Utilities/InputType'

class InputHandler
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
		@modes[mode] ||= {:action => {}, :sequence => {}, :chord => {}, :flag => {}}
		@mode = @modes[mode]
	end
	
	def update
		@mode.each do |type, events|
			events.each do |name, handler|
				handler.update
			end
		end
	end
	
	def hold_duration(event)
		@event_handlers[@mode][event].duration
	end
	
	def button_down(id)
		@buttons.add id
	end
	
	def button_up(id)
		@buttons.delete id
	end
	
	#~ [:action, :chord, :sequence].each do |input_type|
		#~ eval &Q{
			#~ def new_#{input_type}(name, &block)
				#~ @mode[:events][input_type] = block
			#~ end
			#~ 
			#~ def bind_#{input_type}(name, )
				#~ @mode[:keymap]
			#~ end
			#~ 
			#~ def unbind_#{input_type}(name)
				#~ 
			#~ end
			#~ 
			#~ def rebind_#{input_type}(name, )
				#~ unbind_#{input_type}(name)
				#~ bind_#{input_type}()
			#~ end
		#~ }
	#~ end
	
	# Manage actions
	def new_action(name, &function)
		@mode[:action][name] = InputType::Action.new(@mode, @buttons, function)
	end
	
	def bind_action(name, *binding)
		#~ @mode[:events][:action][name].active?
	end
	
	def unbind_action
		
	end
	
	# Manage chords
	def new_chord
		
	end
	
	def bind_chord(name, *binding)
		@mode[:keymap][binding] => name
		
	end
	
	def unbind_chord
		
	end
	
	# Manage sequences
	def new_sequence
		
	end
	
	def bind_sequence(name, *binding)
		
	end
	
	def unbind_sequence
		
	end
	
	private
	
	def process_input
		
	end
	
	def new_action(name, buttons=[])
		@event_handlers[@mode] ||= Hash.new
		@event_handlers[@mode][name]= InputType::Action.new(name, buttons)
	end
	
	def new_sequence(name, buttons=[], threshold=InputType::Sequence::DEFAULT_THRESHOLD)
		@event_handlers[@mode] ||= Hash.new
		@event_handlers[@mode][name]= InputType::Sequence.new(name, buttons, threshold)
	end
	
	def new_chord(name, buttons=[], threshold=InputType::Chord::DEFAULT_THRESHOLD)
		@event_handlers[@mode] ||= Hash.new
		@event_handlers[@mode][name]= InputType::Chord.new(name, buttons, threshold)
	end
	
	def new_combo(name, buttons=[], threshold=InputType::Combo::DEFAULT_THRESHOLD)
		@event_handlers[@mode] ||= Hash.new
		@event_handlers[@mode][name]= InputType::Combo.new(name, buttons, threshold)
	end
end
