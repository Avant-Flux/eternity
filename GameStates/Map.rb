# Draw the in-game map
# Different types of objects are drawn in different colors
# Topology represented by darkness of element
# 	Higher elements are darker, like is Assassin's Creed 2

# TODO: Create entity to track camera position.
# 		Move to position of player when map is opened.
# 		Then, allow moving with mouse, or movement keys.
class Map
	attr_reader :camera
	
	def initialize(window, space, player, state_manager)
		@window = window
		@space = space
		@player = player
		
		@state_manager = state_manager
		
		x_padding = 50
		y_padding = 50
		@background = Widget::Div.new window,
				:width => window.width-x_padding, :height => window.height-y_padding,
				
				:left => x_padding/2, :top => y_padding/2,
				
				:background_color => Gosu::Color.new(200, 0,0,0),
				:padding_top => y_padding/2, :padding_bottom => y_padding/2, 
				:padding_left => x_padding/2, :padding_right => x_padding/2
		
		x_padding = 50
		y_padding = 50
		@dimming_screen = Widget::Div.new window,
				:width => window.width-x_padding, :height => window.height-y_padding,
				
				:left => x_padding/2, :top => y_padding/2,
				
				:background_color => Gosu::Color.new((0.70*255).to_i, 0,0,0)
		
		@colors = {
			:building => Gosu::Color.new((0.05*255).to_i, 218,40,38)
		}
		
		
		@x = @player.body.p.x+@background.render_x+10
		@y = @player.body.p.y+@background.render_y+10
		
		@camera = Camera::TopDownCamera.new @window, @state_manager
		@camera.follow @player
	end
	
	def update
		@camera.update
	end
	
	def draw
		@window.clip_to	@background.render_x, @background.render_y, 
							@background.width-50, @background.height-50 do
			@background.draw
			
			@camera.draw
		end
	end
end
