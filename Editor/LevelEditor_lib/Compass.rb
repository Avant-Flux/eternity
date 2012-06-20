# Maintains a compass rose for the trimetric projection
class Compass < Widget::Div
	#~ include Widget::Background::Image
	
	def initialize(window, x,y, options={})
		image_directory = File.join Dir.pwd, "Development", "Interface", "Level Editor"
		
		file = File.join image_directory, "compass.png"
		
		@img = Gosu::Image.new(window, file, false)
		
		
		options = {
			:background_color => Gosu::Color::NONE,
			
			:width => @img.width,
			:height => @img.height
		}.merge! options
		
		super(window, x,y, options)
	end
	
	def update
		super()
	end
	
	def draw
		super()
		@img.draw render_x, render_y, @pz
	end
end
