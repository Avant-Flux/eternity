class Numeric
	def to_px
		# Convert from meters to pixels
		(self*Physics.scale).to_i
	end
	
	def to_meters
		# Convert from pixels to meters
		self/(Physics.scale.to_f) #Insure that integer division is not used
	end
	
	def to_em(font)
		# Convert from pixels to ems
		# Font assumed to be Gosu::Font object
		self/font.text_width('m')
	end
	
	#Code taken from MoreChipmunkAndRMagick.rb from the gosu demos
	def radians_to_vec2
		CP::Vec2.new(Math::cos(self), Math::sin(self))
	end
	
	# Convert from degrees to radians
	def to_rad
		self * Math::PI / 180
	end
	
	# Convert from radians to degrees
	def to_deg
		self / Math::PI * 180
	end
end

module CP
	class Vec2
		def to_screen
			# Convert from world to screen coordinates
			position = CP::Vec2.new(0,0)
			position += Physics::Direction::X_HAT * self.x
			position += Physics::Direction::Y_HAT * self.y
			
			return position
		end
		
		def to_world
			# Convert from screen to world coordinates
			transform = [[0.895324,-0.194743],[0.273363,0.457149],[-0.111135,0.555586]]
			
			#~ transform = 
		end
	end
end
