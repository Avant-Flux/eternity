# Displays debug information on screen
class DebugDisplay
	def initialize(window, space, player)
		@window = window
		@space = space
		@player = player
		
		@font = Gosu::Font.new @window, "Helvetica Bold", 25
	end
	
	def update
		
	end
	
	def draw
		player_info
		camera_info
	end
	
	private
	
	def debug_print(heading, content, x=0,y=0, options={})
		options = {
			:color => Gosu::Color::WHITE, 
			:indent => 30
		}.merge! options
		
		@window.translate x,y do
			@font.draw	heading, 
								0, @font.height*0, 0,
								1,1, options[:color]
			
			content.each_with_index do |line, i|
				@font.draw	line,
									options[:indent], @font.height*(i+1), 0,
									1,1, options[:color]
			end
		end
	end
	
	def player_info
		format = "%.3f"
		
		debug_print "Player", [
			"px, py, pz : #{format % @player.body.p.x}, #{format % @player.body.p.y}, #{format % @player.body.pz}",
			"vx, vy, vz : #{format % @player.body.v.x}, #{format % @player.body.v.y}, #{format % @player.body.vz}",
			"fx, fy, az : #{format % @player.body.f.x}, #{format % @player.body.f.y}, #{format % @player.body.az}"
		], 0,100
	end
	
	def camera_info
		format = "%.3f"
		
		debug_print "Camera", [
			"zoom: #{format % @window.camera.zoom}"
		], 0,0
	end
end
