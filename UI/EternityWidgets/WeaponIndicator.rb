require 'gl'
require 'glu'

include Gl
include Glu

class WeaponIndicator < Widget::Div
	# Establishes complete context for this widget, and maintains state of widget

	def initialize(window, x,y, options={})
		options =	{
						:resolution => "720p"
						}.merge! options
		
		# Caching which bypasses the asset-manager cache
		@@weapon_gear ||= if options[:resolution] == "720p"
			Gosu::Image.new window, "./Development/Interface/interface720/weapongear.png", false
		elsif options[:resolution] == "1080p"
			Gosu::Image.new window, "./Development/Interface/interface1080/weapongear.png", false
		end
		
		options[:width] = @@weapon_gear.width
		options[:height] = @@weapon_gear.height
		super window, x,y, options
	end
	
	def update
		
	end
	
	def draw
		@@weapon_gear.old_draw weapon_offset_x, weapon_offset_y, z
		@window.gl @pz do
			glBegin(GL_LINES)
				glVertex2i(30,30)
				glVertex2i(200,30)
			glEnd()
		end
	end
end

