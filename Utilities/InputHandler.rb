#	Based on the InputHandler created by Chad Godsey, Feb 21, 2010
#	InputHandler class
#		manage button mappings to several types of high level input
#			simple named actions
#			chords - multiple buttons at once
#			sequences - combos
# 	This is a general input manager class, that can be used independently of
# 	this game and engine.
# TODO: Define global keybindings, which execute regardless of gameplay state
# TODO: Use Gosu::Window#button_down? to detect button state, instead of maintaining a separate boolean
begin
  # In case you use Gosu via RubyGems.
  require 'rubygems'
rescue LoadError
  # In case you don't.
end
# require 'gosu'

require 'set'
require 'state_machine'

require './Utilities/InputAction'

class InputHandler
	# InputHandler passes inputs to various InputType objects, which perform the heavy lifting
	# Make sure that the input handlers can not be accessed outside of this class
	
	def initialize
		# Map event names to functions
		# Map keys to event names
		
		# Set of buttons which are currently being pressed
		@buttons = Set.new
		
		# Hold all InputAction instances managed by this handler
		@actions = Hash.new
	end
		
	def update
		#~ # puts
		# @mode.each do |type, events|
		# 	# puts type
		# 	events.each do |name, handler|
		# 		# puts "eval: #{name}"
		# 		handler.update
		# 	end
		# end
		
		@actions.each do |name, action|
			action.update
		end
	end
	
	def hold_duration(event)
		@event_handlers[@mode][event].duration
	end
	
	def button_down(sym)
		puts "button #{sym} down"
		# @buttons.add sym
		@actions.each do |name, action|
			action.button_down sym
		end
	end
	
	def button_up(sym)
		puts "button #{sym} up"
		# @buttons.delete sym
		@actions.each do |name, action|
			action.button_up sym
		end
	end
	
	def add_action(name, &block)
		action = Action.new name, &block
		
		@actions[action.name] = action
	end
	
	def bind_action(name, binding)
		@actions[name].bind binding
	end
	
	# get action
	def [](action_name)
		@actions[action_name]
	end
	
	def new_flag
		#~ @mode[input_type] = InputType::Flag.new
	end
	
	def inspect
		output = ""
		@modes.each do |mode_name, events|
			output << "=== #{mode_name} ==="
			output << "\n"
			
			events.each do |event_type, event_list|
				output << "\t" # Indent line
				# TODO: Use sprintf for correct alignment
				output << "---#{event_type}---"
				
				output << "\n"
				
				
				event_list.each do |event_name, event|
					output << "\t\t" # Double indent
					# TODO: Use sprintf
					output << "#{event_name.to_s}"
					
					output << " : "
					
					output << "#{event.binding}"
					output << "\n"
				end
				
			end
		end
		
		return output
	end
end
