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

module Timer
	class << self
		def update_all
			TimerObject.update_all
		end
	end

	class TimerObject	#Don't use this class directly
		@@all = Array.new
		@@timer = Gosu::milliseconds
		
		def initialize(&block)
			@block = block
			@init_time = Gosu::milliseconds
			@@all << self
		end
		
		# Execute the stored block
		def run
			@block.call
		end
		
		# Allows the object to be garbage collected.
		# This only works if no other references are made to a timer
		# Thus, when creating timers, do not make make references.
		def destroy
			@@all.delete self
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
	end
	
	class During < TimerObject
		def initialize(end_time, &block)
			super(&block)
			@end_time = end_time
		end
		
		def update
			if @@time < @init_time + @end_time
				run
			else
				destroy
			end
		end
	end
	
	class After < TimerObject
		def initialize(delay, &block)
			super(&block)
			@delay = delay
		end
		
		def update
			
		end
	end
	
	class Between < TimerObject
		def initialize(start_time, end_time, &block)
			super(&block)
			@start_time = start_time
			@end_time = end_time
		end
		
		def update
			
		end
	end
	
	
	#
	# Executes block each update during 'time' milliseconds 
	#
	def during(time, options = {}, &block)
		ms = Gosu::milliseconds()
		@_last_timer = [options[:name], ms, ms + time, block]
		@_timers << @_last_timer
	end
      
      #
      # Executes block after 'time' milliseconds 
      #
      def after(time, options = {}, &block)
        if options[:name]
          return if timer_exists?(options[:name]) && options[:preserve]
          stop_timer(options[:name])
        end

        ms = Gosu::milliseconds()
        @_last_timer = [options[:name], ms + time, nil, block]
        @_timers << @_last_timer
        self
      end

      #
      # Executes block each update during 'start_time' and 'end_time'
      #
      def between(start_time, end_time, options = {}, &block)
        if options[:name]
          return if timer_exists?(options[:name]) && options[:preserve]
          stop_timer(options[:name])
        end

        ms = Gosu::milliseconds()
        @_last_timer = [options[:name], ms + start_time, ms + end_time, block]
        @_timers << @_last_timer
        self
      end

      #
      # Executes block every 'delay' milliseconds 
      #
      def every(delay, options = {}, &block)
        if options[:name]
          return if timer_exists?(options[:name]) && options[:preserve]
          stop_timer(options[:name])
        end
        
        ms = Gosu::milliseconds()
        @_repeating_timers << [options[:name], ms + delay, delay, block]
      end

      #
      # Executes block after the last timer ends 
      # ...use one-shots start_time for our trailing "then".
      # ...use durable timers end_time for our trailing "then".      
      #
      def then(&block)
        start_time = @_last_timer[2].nil? ? @_last_timer[1] : @_last_timer[2]
        @_timers << [@_last_timer[0], start_time, nil, block]
      end


      #
      # See if a timer with name 'name' exists
      #
      def timer_exists?(timer_name = nil)
        return false if timer_name.nil?
        @_timers.each { |name, | return true if timer_name == name }
        @_repeating_timers.each { |name, | return true if timer_name == name }
        return false
      end

      #
      # Stop timer with name 'name'
      #
      def stop_timer(timer_name)
        @_timers.reject! { |name, start_time, end_time, block| timer_name == name }
        @_repeating_timers.reject! { |name, start_time, end_time, block| timer_name == name }
      end
      
      #
      # Stop all timers
      #
      def stop_timers
        @_timers.clear
        @_repeating_timers.clear
      end
      
	def update_trait
        ms = Gosu::milliseconds()
        
        @_timers.each do |name, start_time, end_time, block|
          block.call  if ms > start_time && (end_time == nil || ms < end_time)
        end
                
        index = 0
        @_repeating_timers.each do |name, start_time, delay, block|
          if ms > start_time
            block.call  
            @_repeating_timers[index] = [name, ms + delay, delay, block]
          end
          index += 1
        end

        # Remove one-shot timers (only a start_time, no end_time) and all timers which have expired
        @_timers.reject! { |name, start_time, end_time, block| (ms > start_time && end_time == nil) || (end_time != nil && ms > end_time) }
      
		super
	end
end
