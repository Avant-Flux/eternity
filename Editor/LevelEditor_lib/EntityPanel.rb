# Widget panel for selecting Entity objects to place in the world.
class EntityPanel < Widget::Div
	def initialize(window, sidebar, offset_y, options={})
		options = {
			:relative => sidebar,
			
			:top => offset_y, :bottom => :auto,
			:left => 5, :right => 5,
			
			:height => 400, :width => :auto,
			
			:background_color => Gosu::Color::RED
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
