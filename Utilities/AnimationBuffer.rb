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
	def initialize(window, active_size=60, cache_size=120)
		@window = window
		
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
			@frame_buffer.each do |key, image|
				# Only perform one iteration. Just want to get the oldest object.
				@frame_buffer.delete key
				
				break
			end
		end
		
		# There should now be at least one slot remaining in the buffer
		file = "#{entity}_#{action}_#{direction}_" << ("%04i" % frame_number)
		@temp = Gosu::Image.new @window, file, false
		@frame_buffer[file] = ImageBlob.new(@temp)
		@temp = nil
	end
	
	# Take blob data stored in DRAM and make a Gosu::Image with data in VARM
	def buffer_to_vram(entity, action, direction, frame_number)
		file = "#{entity}_#{action}_#{direction}_" << ("%04i" % frame_number)
		
		if @active_sprites.size == @max_active_size
			# Maximum number of frames in VRAM reached.
			
			@active_sprites.each do |key, image|
				# Only perform one iteration. Just want to get the oldest object.
				@active_sprites.delete key
				
				break
			end
		end
		
		# There should now be room in VRAM for one more frame
		@active_sprites[file] = Gosu::Image.new @window, @cached_sprites[file], false
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
	
	# Private class to wrap uncompressed image blob data
	class ImageBlob
		def initialize(image)
			image = if image.respond_to? :to_blob
				image.to_blob
			end
			
			@data = binary_blob
		end
		
		def to_blob
			return @data
		end
	end
end
