require 'gl'
require 'glu'

include Gl
include Glu

class WeaponIndicator < Widget::Div
	# Establishes complete context for this widget, and maintains state of widget

	def initialize(window, x,y, options={})
		# Caching which bypasses the asset-manager cache
		@@weapon_gear ||= Gosu::Image.new window, 
							"#{Widget::IMAGE_DIR}/left_weapon.png", false
		# TODO: Allow different graphic for left and right weapon indicator (def shared parent)
		options[:width] = @@weapon_gear.width
		options[:height] = @@weapon_gear.height
		super window, options
	end
	
	def update
		
	end
	
	def draw
		super()
		
		color = Gosu::Color.rgba(0xf5a145ff)
		#~ color = Gosu::Color::GREEN
		percent = 75
		@window.draw_circle	self.render_x+self.width/2, self.render_y+self.height/2, @pz,
							self.width/2-12, color,
							:stroke_width => 14, :alpha => 1.0,
							:start_angle => 0, :angle => 360*percent/100.to_f
		\
		@@weapon_gear.draw self.render_x, self.render_y, @pz
		
		
		#~ @window.gl @pz do
			#~ glBegin(GL_LINES)
				#~ glVertex2i(30,30)
				#~ glVertex2i(200,30)
			#~ glEnd()
		#~ end
	end
end

