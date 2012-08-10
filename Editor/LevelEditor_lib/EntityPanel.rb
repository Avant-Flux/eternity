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
		
		@font = Gosu::Font.new window, "Trebuchet MS", 25
		@window = window
		
		@entity_objects = []

		
		super(window, options)
		
		list_entity_objects
	end
	
	def update
		super()
	end
	
	def draw
		@entity_objects.each do |entity_object| 
			entity_object.draw 
		end
		super()
	end
	
	def list_entity_objects
		y_offset = 20
			@window.state_manager.top.each_entity do |object| 
				object = Widget::Button.new @window,
					:relative => self,
					
					:top => y_offset, :bottom => :auto,
					:left => 130, :right => 0,
					
					:width => 0, :height => @font.height,
					
					:font => @font, :text => "o" + object.to_s, :align => 'left' do
						#necessary?
				end
				
				@entity_objects << object
				puts "entity object: #{object}"
				y_offset += 2 + object.height

		end
	end
	
end
