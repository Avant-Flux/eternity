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
		# Set the current input mode.
		# If the mode does not currently exist, create it.
		
		if @modes[mode]
			# If the mode already exists, make sure to mark relevant input types as active
			# Currently only marks actions
			# TODO: Update other input types as well
			@modes[mode][:action].each do |name, handler|
				handler.buttons.each do |button|
					if @buttons.include? button
						handler.active = true
						break
					end
				end
				 
			end
		else
			@modes[mode] = {:sequence => {}, :chord => {}, :flag => {}, :action => {}}
		end
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
	end
	
	def hold_duration(event)
		@event_handlers[@mode][event].duration
	end
	
	def button_down(id)
		puts "button #{id} down"
		@buttons.add id
	end
	
	def button_up(id)
		puts "button #{id} up"
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
	
	#~ private
	#~ 
	#~ def process_input
		#~ 
	#~ end
end
