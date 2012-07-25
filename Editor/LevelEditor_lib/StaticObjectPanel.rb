# Widget panel for selecting static objects to place in the world.
class StaticObjectPanel < Widget::Div
	def initialize(window, sidebar, offset_y, options={})
		options = {
			:relative => sidebar,
			
			:top => offset_y, :bottom => :auto,
			:left => 5, :right => 5,
			
			:height => 400, :width => :auto,
			
			:background_color => Gosu::Color::GREEN
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
