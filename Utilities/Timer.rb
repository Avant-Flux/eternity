#!/usr/bin/ruby

# Inspired by Chingu, specifically Chingu::Traits::Timer.

require 'rubygems'
require 'gosu'

module Timer
	# Note about timers:
	# The times supplied in the constructor of the Timer should be in milliseconds 
	# relative to the init time.

	class TimerObject	#Don't use this class directly
		def initialize(scope, repeat)
			@scope = scope
			@repeat = repeat
		end
		
		# Stuff to do every time Gosu::Window#update is called.
		def update
		end
		
		private
		
		# Allows the Timer to be garbage collected unless it is to repeat.
		# This only works if no other references are made to a timer
		# Thus, when creating timers, do not make make references.
		def destroy
			if @repeat
				reset_time
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
		def initialize(scope, end_time)
			super(scope, repeat)
			@end_time = Gosu::milliseconds + end_time
		end
		
		def active?
			if Gosu::milliseconds <= @end_time
				return true
			else
				destroy
				return false
			end
		end
	end
	
	class After < TimerObject
		def initialize(scope, delay, repeat=false)
			super(scope, repeat)
			@delay = delay
			@run_time = Gosu::milliseconds + delay
		end
		
		def active?
			if Gosu::milliseconds >= @run_time
				destroy
				
				return true
			end
		end
		
		private
		
		def reset_time
			@run_time += @delay
		end
	end
	
	class Between < TimerObject
		def initialize(scope, start_time, end_time, repeat=false)
			super(scope, repeat)
			init = Gosu::milliseconds
			@start_time = start_time
			@end_time = end_time
			
			@run_start = init + @start_time
			@run_end = init + @end_time
		end
		
		def active?
			if Gosu::milliseconds >= @run_start
				if Gosu::milliseconds <= @run_end
					return true
				else
					destroy
					return false
				end
			end
		end
		
		private
		
		def reset_time
			@run_start = @run_end + @start_time
			@run_end += @end_time
		end
	end
end
