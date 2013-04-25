# Defines the behavior of static objects, but provides no rendering capacity

class StaticObject
	attr_reader :model, :physics
	
	DEFAULT_OPTIONS = {
		:collision_type => :static,
		
		:position => [0,0,0],
		:rotation => [1,0,0,0], # Rotation as a Quaternion
		:scale => [1,1,1],
		
		:width => nil,
		:depth => nil,
		:height => nil
	}
	
	def initialize(window, name, mesh_name, opts={})
		@model = Oni::Model.new window, name, mesh_name
		@model.rotate_3D opts[:rotation]
		@model.scale = opts[:scale]
		
		opts[:mass] = CP::INFINITY
		opts[:moment] = CP::INFINITY
		opts[:offset] = :centered
		
		opts[:width] = model.bb_width * opts[:scale][0]
		opts[:depth] = model.bb_depth * opts[:scale][1]
		opts[:height] = model.bb_height * opts[:scale][2]
		
		opts = DEFAULT_OPTIONS.merge opts
		@physics = Component::Collider::Rect.new self, opts
		@physics.body.a = @model.rotation
	end
	
	def update
		# THIS UPDATE IS DIFFERENT
		# Should only be called once, unlike all other update methods
		# This assumption is based on the fact that this is a STATIc object
		# If the object is moved for some reason, #update should be called again
		
		# Physics#update was created for non-statics, so it also updates angle to compensate
		# for characters being modeled facing down Ogre's Z-Axis (pos-z = out the screen)
		# for static objects, that is both unwanted, and unnecessary
		#
		# Also note that Physics#update is intended to be called every frame, 
		# but StaticObject#update is not. (because STATIC object)
		
		@physics.body.pz -= @physics.height/2
		@model.position = [@physics.body.p.x, @physics.body.pz+@physics.height/2, -@physics.body.p.y]
	end
end
