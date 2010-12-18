#!/usr/bin/ruby

# Much code for this file has been borrowed from Chingu,
# specifically Chingu::Traits::Timer.  As such, this file is
# released under LGPL 2.1, as is the entirety of Chingu.

#--
#
# Chingu -- OpenGL accelerated 2D game framework for Ruby
# Copyright (C) 2009 ippa / ippa@rubylicio.us
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
#
#++

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
		@@timer = Gosu::milliseconds
		
		def initialize(repeat, &block)
			@repeat = repeat
			@block = block
			@init_time = Gosu::milliseconds
			set_time
			
			@@all << self
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
				set_time
			else
				@@all.delete self
			end
		end
		
		# Each decedent of TimeObject should implement this method.
		# Set_time will set the time variables needed to determine
		# when to run the provided code block.
		# It will essentially re-initialize the Timer.
		def set_time
			@init_time = Gosu::milliseconds
		end
	end
	
	class During < TimerObject
		def initialize(end_time, repeat=false, &block)
			super(repeat, &block)
		end
		
		private
		
		def set_time
			super
			@end_time = @init_time + end_time
		end
		
		def update
			if @@time < @end_time
				run
			else
				destroy
			end
		end
	end
	
	class After < TimerObject
		def initialize(delay, repeat=false, &block)
			super(repeat, &block)
		end
		
		private
		
		def set_time
			super
			@delay = @init_time + delay
		end
		
		def update
			if @@time > @delay
				run
				destroy
			end
		end
	end
	
	class Between < TimerObject
		def initialize(start_time, end_time, repeat=false, &block)
			super(repeat, &block)
		end
		
		private
		
		def set_time
			super
			@start_time = @init_time + start_time
			@end_time = @init_time + end_time
		end
		
		def update
			if @@time > @start_time && @@time < @end_time
				run
			else if @@time > @end_time
				destroy
			end
		end
	end
end
