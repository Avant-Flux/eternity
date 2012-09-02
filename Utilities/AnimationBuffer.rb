# Cache uses a circular buffer combined with a hash table
# Allows for random access of loaded elements.
# Elements are stored in an array.
# Indexes are stored as values in a hash table, so that semantic keys can be used for random access.
# TODO: Optimize by using C-level memory allocation instead of an array
# When elements expire, they are removed from the array, as well as the hash.
# 
# This cache stores only animation frames
# Currently, the buffer and VRAM size is limited by 
class AnimationBuffer
	def initialize(active_size=60, cache_size=120)
		# All Ruby Hash objects are ordered by when keys are inserted
		@active_sprites = Hash.new	# Gosu::Image objects; stored in VRAM
		
		@temp = nil					# Gosu::Image object; waiting to be converted to blob data
		
		@frame_buffer = Hash.new	# Keys: sprite IDs, values: uncompressed image blob data in DRAM
		
		@max_active_size = active_size
		@max_buffer_size = cache_size
	end
	
	
	# Access element from cache
	# If desired element is not in the cache, then load it.
	def [](key)
		if @active_sprites[key]
			# Gosu::Image object already in VRAM
		else # Cache miss
			# Try to load from cache
			@
		end
	end
	
	private
	
	# Load a sprite from a file and convert it to uncompressed binary blob data in the cache.
	# Use @temp to store a Gosu::Image object used to load the file.
	# 
	# Will temporarily use some space in VRAM.
	def disk_to_buffer(entity, action, direction, frame_number)
		if @frame_buffer.size == @max_buffer_size
			# Maximum number of frames in buffer reached
			
		else
			# Space available in buffer
			
		end
	end
	
	# Take blob data stored in DRAM and make a Gosu::Image with data in VARM
	def buffer_to_vram(entity, action, direction, frame_number)
		file = "#{entity}_#{action}_#{direction}_" << ("%04i" % frame_number)
		
		Gosu::Image.new @window, @cached_sprites[file], false
	end
	
	# Convert Gosu::Image objects stored in VRAM into blob data in DRAM
	# Works for objects in temp as well as those in the cache Hash
	#~ def vram_to_buffer()
		#~ 
	#~ end
	
	# Should be defined by all descendants
	# This implementation is a dummy method
	def load(key)
		
		
		return nil
	end
	
	# Update the structure, expiring old elements as necessary
	def update(key)
		# Increment the head "pointer", but do not exceed the maximum index of the array
		@buffer_head = (@buffer_head + 1) % @circular_buffer.length
		
		output = if @circular_buffer[@buffer_head]
			# If there is already a value at the insertion point, prepare to return it
			@circular_buffer[@buffer_head]
		end
		
		@circular_buffer[@buffer_head] = key
		
		return output
	end
end
