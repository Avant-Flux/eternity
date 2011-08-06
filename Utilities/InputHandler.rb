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
		#~ @modes.each do |key, mode|
			#~ puts "#{key} --> #{mode}"
		#~ end
		#~ puts mode
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
		#~ puts "button #{id} down"
		@buttons.add id
	end
	
	def button_up(id)
		#~ puts "button #{id} up"
		@buttons.delete id
	end
	
	[:action, :chord, :sequence].each do |input_type|
		eval %Q{
			def new_#{input_type}(name, type, &block)
				if @mode[:#{input_type}][name]
					@mode[:#{input_type}][name].functions[type] = block
				else
					@mode[:#{input_type}][name] = InputType::#{input_type.to_s.capitalize}.new(@mode, @buttons, type => block)
				end
				
			end
			
			def bind_#{input_type}(name, trigger)
				@mode[:#{input_type}][name].bind trigger
			end
			
			def unbind_#{input_type}(name)
				@mode[:#{input_type}][name].unbind
			end
			
			def rebind_#{input_type}(name, trigger)
				@mode[:#{input_type}][name].rebind trigger
			end
		}
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
