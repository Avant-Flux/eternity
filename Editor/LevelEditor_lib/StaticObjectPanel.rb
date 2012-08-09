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
		
		@font = Gosu::Font.new window, "Trebuchet MS", 25
		
		@window = window
		
		@static_objects = []
		
		list_static_objects
		
		#if not @buildings == nil

		#end
		
		super(window, options)
	end
	
	def update
		#list_static_objects
	
		super()
	end
	
	def draw
	@static_objects.each do |static_object| 
		static_object.draw 
	end
		super()
	end
	
	def list_static_objects
		y_offset = 20
		if not @window.buildings == nil
			@window.buildings.each do |object| 
			puts object
				object = Widget::Button.new @window,
					:relative => self,
					
					:top => y_offset, :bottom => :auto,
					:left => 300, :right => 0,
					
					:width => 0, :height => @font.height,
					
					:font => @font, :text => object.to_s, :align => 'right' do
						#necessary?
					end
					
					@static_objects << object
					y_offset += 2 + object.height
			end
		end
	
	end
	
end