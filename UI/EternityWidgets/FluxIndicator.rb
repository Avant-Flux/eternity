class FluxIndicator < Widget::Div
	def initialize(window, x,y, options={})
		options = 	{
			:z_index => 0,
			:relative => window,
			:align => :left,
			
			:position => :static, # static, dynamic, relative
			
			:width => 1,
			:width_units => :px,
			:height => 1,
			:height_units => :px,
			
			:background_color => Gosu::Color::BLUE,
			
			:padding_top => 0,
			:padding_bottom => 0,
			:padding_left => 0,
			:padding_right => 0,
			
			# Positioning
			:top => 0,
			:bottom => 0,
			:left => 0,
			:right => 0
		}.merge! options
		
		super(window, x,y, options)
		
		@font = Gosu::Font.new @window, "Helvetica Bold", 25
		
		
		@flux_gear = Gosu::Image.new window,
						"./Development/Interface/interface720/fluxgear.png", false
	end
	
	def update
		super()
	end
	
	def draw
		super()
		
		# Flux
		# White fill
		scale_top_gear = 0.3
		top_gear_offset_y = 150+20
		@flux_gear.draw	(@window.width/2 - @flux_gear.width/2),
							@window.height - top_gear_offset_y, 100
	end
end

