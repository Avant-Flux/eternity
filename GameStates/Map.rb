# Draw the in-game map
# Different types of objects are drawn in different colors
# Topology represented by darkness of element
# 	Higher elements are darker, like is Assassin's Creed 2

class Map
	attr_accessor :zoom
	
	def initialize(window, space, player, state_manager)
		@window = window
		@space = space
		@player = player
		
		@state_manager = state_manager
		
		x_padding = 50
		y_padding = 50
		@background = Widget::Div.new window, x_padding/2, y_padding/2,
				:width => window.width-x_padding, :height => window.height-y_padding,
				:background_color => Gosu::Color.new(200, 0,0,0),
				:padding_top => y_padding/2, :padding_bottom => y_padding/2, 
				:padding_left => x_padding/2, :padding_right => x_padding/2
		
		x_padding = 50
		y_padding = 50
		@dimming_screen = Widget::Div.new window, x_padding/2, y_padding/2,
				:width => window.width-x_padding, :height => window.height-y_padding,
				:background_color => Gosu::Color.new((0.70*255).to_i, 0,0,0)
		
		@colors = {
			:building => Gosu::Color.new((0.05*255).to_i, 218,40,38)
		}
		
		
		@x = @background.render_x+10
		@y = @background.render_y+10
		@zoom = 1
		@map_transform = [
			1, 0, 0, 0,
			0, 1, 0, 0,
			0, 0, -1, 0,
			0, 0, 0, 1
		]
	end
	
	def update
		
	end
	
	def draw
		# Draw base of map
		@background.draw
		
		@window.flush
		
		# Draw objects 
		@state_manager.stack.each do |state|
			# Draw static objects
			state.each_static do |object|
				# Clip to map confines
				# Move object within map confines
				# Zoom in
				#~ @window.scale 4,4, 0,0 do
				@window.clip_to	@background.render_x, @background.render_y, 
								@background.width-50, @background.height-50 do
				#~ @window.translate @x, @y do
				#~ @window.translate -@x, -@y do
				@window.translate @x, @y do
				@window.scale @zoom,@zoom do
				
				#~ @window.translate -@x, -@y do
				@window.transform *@map_transform do
				
					z = object.pz + object.height
					
					color_modulation = 100
					base_color = Gosu::Color.new(200, 218-color_modulation/2,40,38)
					base_color.red += (z/30.0)*color_modulation
					color = base_color
					
					
					@window.draw_quad	object.body.p.x, object.body.p.y, color,
										object.body.p.x, object.body.p.y+object.depth, color,
										object.body.p.x+object.width, object.body.p.y+object.depth, color,
										object.body.p.x+object.width, object.body.p.y, color,
										z
														
				end
				end
				end
				end
			
			end
			
			@window.flush
			
			if state != @state_manager.stack.last
				@dimming_screen.draw
			end
		end
		
		@window.flush
	end
end
