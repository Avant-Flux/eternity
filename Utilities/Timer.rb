#!/usr/bin/ruby

# Inspired by Chingu, specifically Chingu::Traits::Timer.

require 'rubygems'
require 'gosu'

module Timer
	# Note about timers:
	# The times supplied in the constructor of the Timer should be in milliseconds 
	# relative to the init time.
	
	class << self
		def update_all
			TimerObject.update_all
		end
	end

	class TimerObject	#Don't use this class directly
		@@all = Array.new
		@@time = Gosu::milliseconds
		
		def initialize(repeat, &block)
			@repeat = repeat
			@block = block
			@@all << self
			
			#Return the time of init to descendants
			Gosu::milliseconds
		end
		
		# Create a method to update all instances without exposing the
		# container which holds these instances.
		class << self
			def update_all
				@@time = Gosu::milliseconds
				@@all.each do |timer|
					timer.update
				end
			end
		end
		
		# Stuff to do every time Gosu::Window#update is called.
		def update
		end
		
		private
		
		# Execute the stored block
		def run
			@block.call
		end
		
		# Allows the Timer to be garbage collected unless it is to repeat.
		# This only works if no other references are made to a timer
		# Thus, when creating timers, do not make make references.
		def destroy
			if @repeat
				reset_time
			else
				@@all.delete self
			end
		end
		
		# Each decedent of TimeObject should implement this method.
		# Will reset the time variables needed to determine
		# when to run the provided code block.
		# It will effectively re-initialize the Timer.
		def reset_time
		end
	end
	
	class During < TimerObject
		def initialize(end_time, repeat=false, &block)
			time = super(repeat, &block)
			@end_time = time + end_time
		end
		
		def update
			if @@time < @end_time
				run
			else
				destroy
			end
		end
		
		private
		
		def reset_time
			@end_time += Gosu::milliseconds
		end
	end
	
	class After < TimerObject
		def initialize(delay, repeat=false, &block)
			time = super(repeat, &block)
			@delay = time + delay
		end
		
		def update
			if @@time > @delay
				run
				destroy
			end
		end
		
		private
		
		def reset_time
			@delay += Gosu::milliseconds
		end
	end
	
	class Between < TimerObject
		def initialize(start_time, end_time, repeat=false, &block)
			time = super(repeat, &block)
			@start_time = time + start_time
			@end_time = time + end_time
		end
		
		def update
			if @@time > @start_time
				if @@time < @end_time
					run
				else
					destroy
				end
			end
		end
		
		private
		
		def reset_time
			new_init = Gosu::milliseconds
			@start_time += new_init
			@end_time += new_init
		end
	end
end
