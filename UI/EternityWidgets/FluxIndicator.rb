class FluxIndicator < Widget::Div
	def initialize(window, x,y, options={})
		@flux_gear = Gosu::Image.new window,
						"./Development/Interface/new_interface/flux_gauge.png", false
		options[:width] = @flux_gear.width
		options[:height] = @flux_gear.height
		
		super(window, x,y, options)
		
		@font = Gosu::Font.new @window, "Helvetica Bold", 25
		
		
		
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
		x = (@window.width/2 - @flux_gear.width/2)
		y = @window.height - top_gear_offset_y
		@flux_gear.draw	self.render_x, self.render_y, @pz
	end
end

