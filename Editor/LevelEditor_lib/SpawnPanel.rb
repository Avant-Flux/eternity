# Widget panel for selecting spawn objects to place in the world.
# Spawns dictate the starting locations for NPCs and the Player
class SpawnPanel < Widget::Div
	def initialize(window, sidebar, offset_y, options={})
		options = {
			:relative => sidebar,
			
			:top => offset_y, :bottom => :auto,
			:left => 5, :right => 5,
			
			:height => 400, :width => :auto,
			
			:background_color => Gosu::Color::BLUE
		}.merge! options
		
		super(window, options)
	end
	
	def update
		super()
	end
	
	def draw
		super()
	end
end
