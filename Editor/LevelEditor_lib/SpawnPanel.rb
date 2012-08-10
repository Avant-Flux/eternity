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
		@font = Gosu::Font.new window, "Trebuchet MS", 25
		@window = window
		
		@spawn_locations = []
		@spawn_location_strings = []

		
		list_spawn
	end
	
	def update
		super()
	end
	
	def draw
		@spawn_location_strings.each do |spawn_location_string| 
			spawn_location_string.draw 
		end
		super()
	end
	
	def list_spawn
		y_offset = 20
		if @spawn_location_strings.length < 1
			@spawn_locations << @window.state_manager.top.spawn
		end
		
		
		
			@spawn_locations.each do |object| 
				object = Widget::Button.new @window,
					:relative => self,
					
					:top => y_offset, :bottom => :auto,
					:left => 130, :right => 0,
					
					:width => 0, :height => @font.height,
					
					:font => @font, :text => "o" + object.to_s, :align => 'left' do
						#necessary?
				end
				
				@spawn_location_strings << object
				y_offset += 2 + object.height

		end
	end
	
end
